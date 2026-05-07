--!strict
--[[
    Remotes — Shared remote event/function definitions
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

Remotes.FOLDER_NAME = "DungeonRemotes"

function Remotes.Setup()
    local folder = Instance.new("Folder")
    folder.Name = Remotes.FOLDER_NAME
    folder.Parent = ReplicatedStorage

    local swapPart = Instance.new("RemoteEvent")
    swapPart.Name = "SwapPart"
    swapPart.Parent = folder

    local progressFloor = Instance.new("RemoteEvent")
    progressFloor.Name = "ProgressFloor"
    progressFloor.Parent = folder

    local requestSegments = Instance.new("RemoteFunction")
    requestSegments.Name = "RequestSegments"
    requestSegments.Parent = folder

    local clientReady = Instance.new("RemoteEvent")
    clientReady.Name = "ClientReady"
    clientReady.Parent = folder

    local combatEvent = Instance.new("RemoteEvent")
    combatEvent.Name = "CombatEvent"
    combatEvent.Parent = folder

    local floorEvent = Instance.new("RemoteEvent")
    floorEvent.Name = "FloorEvent"
    floorEvent.Parent = folder

    local segmentPickup = Instance.new("RemoteEvent")
    segmentPickup.Name = "SegmentPickup"
    segmentPickup.Parent = folder
end

function Remotes.GetFolder(): Folder?
    return ReplicatedStorage:FindFirstChild(Remotes.FOLDER_NAME) :: Folder?
end

function Remotes.Get(eventType: string): RemoteEvent | RemoteFunction?
    local folder = Remotes.GetFolder()
    if folder then
        return folder:FindFirstChild(eventType)
    end
    return nil
end

return Remotes