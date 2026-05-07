--!strict
--[[
    GameInit — Entry point for Dungeon Depths
    T8: On player join, load inventory, assemble character, start dungeon at floor 1
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local GameConfig = require(game:GetService("ReplicatedStorage"):FindFirstChild("GameConfig"))
local SegmentData = require(game:GetService("ReplicatedStorage"):FindFirstChild("SegmentData"))
local Remotes = require(game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"))
local CharacterAssembler = require(ServerScriptService:FindFirstChild("CharacterAssembler"))
local FloorGenerator = require(ServerScriptService:FindFirstChild("FloorGenerator"))
local CombatEngine = require(ServerScriptService:FindFirstChild("CombatEngine"))

local GameInit = {}

local playerData: { [number]: { floor: number, segments: { [string]: string }, inventory: { string } } } = {}

-- Default loadout: all crab parts
local function defaultLoadout(): { [string]: string }
    local loadout: { [string]: string } = {}
    for _, slot in GameConfig.SEGMENT_SLOTS do
        loadout[slot] = "crab_" .. slot .. "_01"
    end
    return loadout
end

local function defaultInventory(): { string }
    local inv = {}
    for _, slot in GameConfig.SEGMENT_SLOTS do
        table.insert(inv, "crab_" .. slot .. "_01")
    end
    return inv
end

function GameInit.OnPlayerAdded(player: Player)
    -- Load or init data
    local data = {
        floor = GameConfig.STARTING_FLOOR,
        segments = defaultLoadout(),
        inventory = defaultInventory(),
    }

    -- Try DataStore load
    pcall(function()
        local store = DataStoreService:GetDataStore("DungeonDepths_" .. player.UserId)
        local saved = store:GetAsync("profile")
        if saved then
            data = saved
        end
    end)

    playerData[player.UserId] = data

    -- Setup remotes if not yet
    if not Remotes.GetFolder() then
        Remotes.Setup()
    end

    -- Wait for character
    local character = player.Character or player.CharacterAdded:Wait()
    CharacterAssembler.Assemble(player, data.segments)

    -- Generate starting floor
    FloorGenerator.Generate(data.floor)

    -- Start combat loop
    CombatEngine.Start(player, data.floor)

    -- Handle swap part remote
    local swapPart = Remotes.Get("SwapPart") :: RemoteEvent
    swapPart.OnServerEvent:Connect(function(p: Player, slot: string, segmentId: string)
        if p.UserId ~= player.UserId then return end
        if data.segments[slot] then
            local seg = SegmentData.GetById(segmentId)
            if seg and seg.slot == slot then
                data.segments[slot] = segmentId
                CharacterAssembler.Assemble(player, data.segments)
            end
        end
    end)

    -- Handle floor progress
    local progressFloor = Remotes.Get("ProgressFloor") :: RemoteEvent
    progressFloor.OnServerEvent:Connect(function(p: Player)
        if p.UserId ~= player.UserId then return end
        data.floor = math.min(data.floor + 1, GameConfig.M1_MAX_FLOOR)
        FloorGenerator.Generate(data.floor)
        CombatEngine.Start(player, data.floor)
    end)

    -- Client ready signal
    local clientReady = Remotes.Get("ClientReady") :: RemoteEvent
    clientReady:FireClient(player, data.floor, data.segments, data.inventory)
end

function GameInit.OnPlayerRemoving(player: Player)
    local data = playerData[player.UserId]
    if data then
        pcall(function()
            local store = DataStoreService:GetDataStore("DungeonDepths_" .. player.UserId)
            store:SetAsync("profile", data)
        end)
        playerData[player.UserId] = nil
    end
    CombatEngine.Stop(player)
end

Players.PlayerAdded:Connect(GameInit.OnPlayerAdded)
Players.PlayerRemoving:Connect(GameInit.OnPlayerRemoving)

return GameInit