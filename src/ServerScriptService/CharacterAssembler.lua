--!strict
--[[
    CharacterAssembler — T3
    Takes player + 5 segment IDs → welds segment models to character rig
    Recompute stats on any segment swap
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local SegmentData = require(ReplicatedStorage:WaitForChild("SegmentData"))

local CharacterAssembler = {}

local assembledModels: { [number]: Model } = {}

local function createSegmentPart(segmentId: string, slot: string): Part
    local seg = SegmentData.GetById(segmentId)
    local part = Instance.new("Part")
    part.Name = "Segment_" .. slot
    part.Size = Vector3.new(
        if slot == "torso" then 2 else 1,
        if slot == "legs" then 2 else 1,
        if slot == "back" then 1.5 else 1
    )
    part.BrickColor = BrickColor.new(Color3.new(
        if seg then seg.color.R else 0.5,
        if seg then seg.color.G else 0.5,
        if seg then seg.color.B else 0.5
    ))
    part.Material = Enum.Material.Neon
    part.Anchored = false
    part.CanCollide = false
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    return part
end

local function getPositionForSlot(slot: string): Vector3
    if slot == "head" then return Vector3.new(0, 3, 0)
    elseif slot == "torso" then return Vector3.new(0, 1.5, 0)
    elseif slot == "arms" then return Vector3.new(0, 1.5, 0.5)
    elseif slot == "legs" then return Vector3.new(0, -0.5, 0)
    elseif slot == "back" then return Vector3.new(0, 1.5, -0.75)
    else return Vector3.new(0, 0, 0)
    end
end

function CharacterAssembler.Assemble(player: Player, segments: { [string]: string })
    -- Remove old model
    CharacterAssembler.Disassemble(player)

    local character = player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
    if not humanoidRootPart then return end

    local model = Instance.new("Model")
    model.Name = "SegmentRig_" .. player.Name
    model.Parent = character

    local torso = createSegmentPart(segments.torso or "crab_torso_01", "torso")
    torso.Position = humanoidRootPart.Position + getPositionForSlot("torso")
    torso.Parent = model

    -- Weld torso to HumanoidRootPart
    local torsoWeld = Instance.new("WeldConstraint")
    torsoWeld.Part0 = humanoidRootPart
    torsoWeld.Part1 = torso
    torsoWeld.Parent = torso

    for _, slot in GameConfig.SEGMENT_SLOTS do
        if slot == "torso" then continue end
        local segId = segments[slot] or ("crab_" .. slot .. "_01")
        local part = createSegmentPart(segId, slot)
        part.Position = humanoidRootPart.Position + getPositionForSlot(slot)
        part.Parent = model

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = torso
        weld.Part1 = part
        weld.Parent = part
    end

    assembledModels[player.UserId] = model

    -- Recompute stats and update combat
    local totalStats = CharacterAssembler.ComputeStats(segments)
    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
    if humanoid then
        humanoid.MaxHealth = GameConfig.BASE_HP + totalStats.defense * 5
        humanoid.Health = humanoid.MaxHealth
    end
end

function CharacterAssembler.ComputeStats(segments: { [string]: string }): { power: number, speed: number, defense: number, special: number }
    local totals = { power = 0, speed = 0, defense = 0, special = 0 }
    for _, slot in GameConfig.SEGMENT_SLOTS do
        local segId = segments[slot]
        if segId then
            local seg = SegmentData.GetById(segId)
            if seg then
                totals.power += seg.stats.power
                totals.speed += seg.stats.speed
                totals.defense += seg.stats.defense
                totals.special += seg.stats.special
            end
        end
    end
    return totals
end

function CharacterAssembler.Disassemble(player: Player)
    local oldModel = assembledModels[player.UserId]
    if oldModel then
        oldModel:Destroy()
        assembledModels[player.UserId] = nil
    end
end

return CharacterAssembler
