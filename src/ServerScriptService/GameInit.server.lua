--!strict
--[[
    GameInit — Entry point for Dungeon Depths
    T8: On player join, load inventory, assemble character, start dungeon at floor 1
]]

print("[DungeonDepths] GameInit starting...")

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local SegmentData = require(ReplicatedStorage:WaitForChild("SegmentData"))
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local CharacterAssembler = require(ServerScriptService:WaitForChild("CharacterAssembler"))
local FloorGenerator = require(ServerScriptService:WaitForChild("FloorGenerator"))
local CombatEngine = require(ServerScriptService:WaitForChild("CombatEngine"))

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
        print("[DungeonDepths] Remotes initialized")
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
    if not swapPart then
        warn("[DungeonDepths] SwapPart remote missing")
        return
    end
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
    if not progressFloor then
        warn("[DungeonDepths] ProgressFloor remote missing")
        return
    end
    progressFloor.OnServerEvent:Connect(function(p: Player)
        if p.UserId ~= player.UserId then return end
        data.floor = math.min(data.floor + 1, GameConfig.M1_MAX_FLOOR)
        FloorGenerator.Generate(data.floor)
        CombatEngine.Start(player, data.floor)
    end)

    -- Client ready signal
    local clientReady = Remotes.Get("ClientReady") :: RemoteEvent
    if clientReady then
        clientReady:FireClient(player, data.floor, data.segments, data.inventory)
    end

    print("[DungeonDepths] Player initialized: " .. player.Name)
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

for _, player in Players:GetPlayers() do
    task.defer(GameInit.OnPlayerAdded, player)
end

print("[DungeonDepths] GameInit ready")

return GameInit
