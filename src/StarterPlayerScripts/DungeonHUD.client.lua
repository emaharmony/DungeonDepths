--!strict
--[[
    DungeonHUD — T7
    Floor number (big, center-top)
    HP bar
    Currently equipped parts (5 icons)
    Depth zone name
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ZoneData = require(ReplicatedStorage:WaitForChild("ZoneData"))

local DungeonHUD = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DungeonHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Floor number (big, center-top)
local floorLabel = Instance.new("TextLabel")
floorLabel.Name = "FloorLabel"
floorLabel.Size = UDim2.new(0, 200, 0, 40)
floorLabel.Position = UDim2.new(0.5, -100, 0, 10)
floorLabel.BackgroundColor3 = Color3.new(0, 0, 0)
floorLabel.BackgroundTransparency = 0.5
floorLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
floorLabel.Font = Enum.Font.GothamBold
floorLabel.TextSize = 28
floorLabel.Text = "Floor 1"
floorLabel.Parent = screenGui

-- Zone name
local zoneLabel = Instance.new("TextLabel")
zoneLabel.Name = "ZoneLabel"
zoneLabel.Size = UDim2.new(0, 200, 0, 20)
zoneLabel.Position = UDim2.new(0.5, -100, 0, 52)
zoneLabel.BackgroundTransparency = 1
zoneLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
zoneLabel.Font = Enum.Font.Gotham
zoneLabel.TextSize = 14
zoneLabel.Text = "Stone Caverns"
zoneLabel.Parent = screenGui

-- HP bar background
local hpBg = Instance.new("Frame")
hpBg.Name = "HPBarBg"
hpBg.Size = UDim2.new(0, 200, 0, 16)
hpBg.Position = UDim2.new(0.5, -100, 0, 76)
hpBg.BackgroundColor3 = Color3.new(0.3, 0, 0)
hpBg.BorderSizePixel = 0
hpBg.Parent = screenGui

local hpCorner = Instance.new("UICorner")
hpCorner.CornerRadius = UDim.new(0, 8)
hpCorner.Parent = hpBg

-- HP bar fill
local hpFill = Instance.new("Frame")
hpFill.Name = "HPBarFill"
hpFill.Size = UDim2.new(1, 0, 1, 0)
hpFill.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
hpFill.BorderSizePixel = 0
hpFill.Parent = hpBg

local hpFillCorner = Instance.new("UICorner")
hpFillCorner.CornerRadius = UDim.new(0, 8)
hpFillCorner.Parent = hpFill

-- HP text
local hpText = Instance.new("TextLabel")
hpText.Name = "HPText"
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.BackgroundTransparency = 1
hpText.TextColor3 = Color3.new(1, 1, 1)
hpText.Font = Enum.Font.GothamBold
hpText.TextSize = 12
hpText.Text = "100/100"
hpText.Parent = hpBg

-- Equipped parts display
local partsFrame = Instance.new("Frame")
partsFrame.Name = "PartsFrame"
partsFrame.Size = UDim2.new(0, 300, 0, 30)
partsFrame.Position = UDim2.new(0.5, -150, 0, 98)
partsFrame.BackgroundTransparency = 1
partsFrame.Parent = screenGui

local SLOT_ICONS: { [string]: string } = {
    head = "🧠",
    torso = "🛡️",
    arms = "💪",
    legs = "🦵",
    back = "🎒",
}

local partLabels: { [string]: TextLabel } = {}
local slotIdx = 0
for _, slot in GameConfig.SEGMENT_SLOTS do
    local label = Instance.new("TextLabel")
    label.Name = "Part_" .. slot
    label.Size = UDim2.new(0, 56, 0, 28)
    label.Position = UDim2.new(0, slotIdx * 60, 0, 0)
    label.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    label.BackgroundTransparency = 0.5
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = SLOT_ICONS[slot] .. " ???"
    label.Parent = partsFrame
    partLabels[slot] = label
    slotIdx += 1
end

-- Update functions
local currentFloor = 1
local currentSegments: { [string]: string } = {}

function DungeonHUD.UpdateFloor(floor: number)
    currentFloor = floor
    floorLabel.Text = "Floor " .. tostring(floor)
    local zone = ZoneData.GetByFloor(floor)
    if zone then
        zoneLabel.Text = zone.name
    end
end

function DungeonHUD.UpdateHP(current: number, max: number)
    local pct = math.clamp(current / math.max(max, 1), 0, 1)
    hpFill.Size = UDim2.new(pct, 0, 1, 0)
    hpText.Text = tostring(math.floor(current)) .. "/" .. tostring(math.floor(max))
    if pct < 0.3 then
        hpFill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    elseif pct < 0.6 then
        hpFill.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
    else
        hpFill.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
    end
end

function DungeonHUD.UpdateParts(segments: { [string]: string })
    currentSegments = segments
    for _, slot in GameConfig.SEGMENT_SLOTS do
        local label = partLabels[slot]
        if label then
            local segId = segments[slot]
            if segId then
                local seg = SegmentData.GetById(segId)
                if seg then
                    label.Text = SLOT_ICONS[slot] .. " " .. seg.species
                else
                    label.Text = SLOT_ICONS[slot] .. " " .. (segId:match("_(.+)_") or segId)
                end
            else
                label.Text = SLOT_ICONS[slot] .. " ???"
            end
        end
    end
end

-- Health update loop
task.spawn(function()
    while true do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
            if humanoid then
                DungeonHUD.UpdateHP(humanoid.Health, humanoid.MaxHealth)
            end
        end
        task.wait(0.25)
    end
end)

-- Listen for server data
local remotesFolder = ReplicatedStorage:WaitForChild("DungeonRemotes")
local clientReady = remotesFolder:WaitForChild("ClientReady") :: RemoteEvent
clientReady.OnClientEvent:Connect(function(floor: number, segments: { [string]: string }, inventory: { string })
    DungeonHUD.UpdateFloor(floor)
    DungeonHUD.UpdateParts(segments)
end)

return DungeonHUD
