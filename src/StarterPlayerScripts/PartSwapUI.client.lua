--!strict
--[[
    PartSwapUI — T6
    5 slot display (head, torso, arms, legs, back)
    Tap slot → modal shows available segments for that slot
    Tap segment → swap (fires remote to server)
    Stat preview before confirming
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local SegmentData = require(ReplicatedStorage:WaitForChild("SegmentData"))

local PartSwapUI = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PartSwapUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- State
local currentSegments: { [string]: string } = {}
local currentInventory: { string } = {}
local activeSlot: string? = nil

local SLOT_ICONS: { [string]: string } = {
    head = "🧠",
    torso = "🛡️",
    arms = "💪",
    legs = "🦵",
    back = "🎒",
}

-- Slot buttons frame
local slotFrame = Instance.new("Frame")
slotFrame.Name = "SlotFrame"
slotFrame.Size = UDim2.new(0, 300, 0, 50)
slotFrame.Position = UDim2.new(0.5, -150, 0.85, 0)
slotFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
slotFrame.BackgroundTransparency = 0.3
slotFrame.Parent = screenGui

local slotButtons: { [string]: TextButton } = {}
local slotIndex = 0
for _, slot in GameConfig.SEGMENT_SLOTS do
    local btn = Instance.new("TextButton")
    btn.Name = "Slot_" .. slot
    btn.Size = UDim2.new(0, 56, 0, 44)
    btn.Position = UDim2.new(0, slotIndex * 60, 0, 3)
    btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    btn.Text = SLOT_ICONS[slot] or slot
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.Parent = slotFrame

    btn.MouseButton1Click:Connect(function()
        activeSlot = slot
        showSwapModal(slot)
    end)

    slotButtons[slot] = btn
    slotIndex += 1
end

-- Swap modal
local modalFrame = Instance.new("Frame")
modalFrame.Name = "SwapModal"
modalFrame.Size = UDim2.new(0, 250, 0, 300)
modalFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
modalFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
modalFrame.Visible = false
modalFrame.Parent = screenGui

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = modalFrame

closeButton.MouseButton1Click:Connect(function()
    modalFrame.Visible = false
    activeSlot = nil
end)

local segmentScroll = Instance.new("ScrollingFrame")
segmentScroll.Name = "SegmentList"
segmentScroll.Size = UDim2.new(1, -20, 1, -50)
segmentScroll.Position = UDim2.new(0, 10, 0, 40)
segmentScroll.BackgroundTransparency = 1
segmentScroll.ScrollBarThickness = 6
segmentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
segmentScroll.Parent = modalFrame

local segmentLayout = Instance.new("UIListLayout")
segmentLayout.SortOrder = Enum.SortOrder.LayoutOrder
segmentLayout.Padding = UDim.new(0, 4)
segmentLayout.Parent = segmentScroll

local function showSwapModal(slot: string)
    -- Clear old entries
    for _, child in segmentScroll:GetChildren() do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local segments = SegmentData.GetBySlot(slot)
    local canvasHeight = 0

    for i, seg in segments do
        local btn = Instance.new("TextButton")
        btn.Name = "Seg_" .. seg.id
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Color3.new(seg.color.R * 0.6, seg.color.G * 0.6, seg.color.B * 0.6)
        btn.Text = seg.species .. " " .. seg.slot .. " | P:" .. seg.stats.power .. " S:" .. seg.stats.speed .. " D:" .. seg.stats.defense
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.LayoutOrder = i
        btn.Parent = segmentScroll

        btn.MouseButton1Click:Connect(function()
            local swapPart = ReplicatedStorage:FindFirstChild("DungeonRemotes")
            if swapPart then
                local remote = swapPart:FindFirstChild("SwapPart") :: RemoteEvent
                if remote then
                    remote:FireServer(slot, seg.id)
                    currentSegments[slot] = seg.id
                    modalFrame.Visible = false
                    activeSlot = nil
                    updateSlotDisplay()
                end
            end
        end)

        canvasHeight += 44
    end

    segmentScroll.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    modalFrame.Visible = true
end

local function updateSlotDisplay()
    for _, slot in GameConfig.SEGMENT_SLOTS do
        local btn = slotButtons[slot]
        if btn then
            local segId = currentSegments[slot]
            if segId then
                local seg = SegmentData.GetById(segId)
                if seg then
                    btn.BackgroundColor3 = Color3.new(seg.color.R, seg.color.G, seg.color.B)
                end
            end
        end
    end
end

-- Listen for server data
local remotesFolder = ReplicatedStorage:WaitForChild("DungeonRemotes")
local clientReady = remotesFolder:WaitForChild("ClientReady") :: RemoteEvent
clientReady.OnClientEvent:Connect(function(floor: number, segments: { [string]: string }, inventory: { string })
    currentSegments = segments
    currentInventory = inventory
    updateSlotDisplay()
end)

return PartSwapUI
