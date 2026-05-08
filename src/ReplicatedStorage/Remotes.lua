--!strict
--[[
    Remotes — Shared remote event/function definitions
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

Remotes.FOLDER_NAME = "DungeonRemotes"

function Remotes.Setup()
    local folder = Remotes.GetFolder()
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = Remotes.FOLDER_NAME
        folder.Parent = ReplicatedStorage
    end

    local function ensureRemote(name: string, className: string)
        local existing = folder:FindFirstChild(name)
        if existing then
            return existing
        end
        local remote = Instance.new(className)
        remote.Name = name
        remote.Parent = folder
        return remote
    end

    ensureRemote("SwapPart", "RemoteEvent")
    ensureRemote("ProgressFloor", "RemoteEvent")
    ensureRemote("RequestSegments", "RemoteFunction")
    ensureRemote("ClientReady", "RemoteEvent")
    ensureRemote("CombatEvent", "RemoteEvent")
    ensureRemote("FloorEvent", "RemoteEvent")
    ensureRemote("SegmentPickup", "RemoteEvent")
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
