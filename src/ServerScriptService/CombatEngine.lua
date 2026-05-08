--!strict
--[[
    CombatEngine — T5
    Auto-attack: player attacks nearest enemy on interval
    Damage = power - enemy_defense (min 1)
    Enemy attacks player on interval
    On enemy death: roll drop table, spawn segment pickup
    On player death: save parts, respawn at floor 1
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local SegmentData = require(ReplicatedStorage:WaitForChild("SegmentData"))
local CharacterAssembler = require(ServerScriptService:WaitForChild("CharacterAssembler"))

local CombatEngine = {}

local activeLoops: { [number]: boolean } = {}

-- Simple drop table
local function rollDrop(floor: number): string?
    local allSegments = SegmentData.GetAll()
    local keys = {}
    for id, seg in allSegments do
        -- Higher floors can drop rarer segments
        if floor >= 10 or seg.rarity == "common" then
            table.insert(keys, id)
        end
    end
    if #keys == 0 then return nil end
    return keys[math.random(1, #keys)]
end

local function spawnPickup(segmentId: string, position: Vector3)
    local pickup = Instance.new("Part")
    pickup.Name = "SegmentPickup_" .. segmentId
    pickup.Size = Vector3.new(1, 1, 1)
    pickup.Position = position + Vector3.new(0, 1, 0)
    pickup.BrickColor = BrickColor.new("Bright yellow")
    pickup.Material = Enum.Material.Neon
    pickup.Anchored = true
    pickup.CanCollide = false
    pickup.Parent = workspace

    -- Add billboard GUI for segment name
    local seg = SegmentData.GetById(segmentId)
    if seg then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 100, 0, 30)
        bb.StudsOffset = Vector3.new(0, 1.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent = pickup
        local label = Instance.new("TextLabel")
        label.Text = seg.species .. " " .. seg.slot
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Parent = bb
    end
end

function CombatEngine.Start(player: Player, floor: number)
    CombatEngine.Stop(player)

    activeLoops[player.UserId] = true

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
    if not humanoid then return end

    -- Attack speed based on player speed stat
    local segments = {
        head = "crab_head_01",
        torso = "crab_torso_01",
        arms = "crab_arms_01",
        legs = "crab_legs_01",
        back = "crab_back_01",
    }
    local stats = CharacterAssembler.ComputeStats(segments)
    local attackInterval = math.max(0.3, GameConfig.BASE_ATTACK_INTERVAL - stats.speed * 0.03)

    task.spawn(function()
        while activeLoops[player.UserId] and humanoid and humanoid.Health > 0 do
            -- Find nearest enemy
            local nearestEnemy: Instance? = nil
            local nearestDist = math.huge
            local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
            if not rootPart then break end

            for _, enemy in workspace:GetDescendants() do
                if enemy:IsA("Model") and enemy.Name:find("Enemy_") then
                    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") :: BasePart
                    local enemyHumanoid = enemy:FindFirstChild("Humanoid") :: Humanoid
                    if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                        local dist = (rootPart.Position - enemyRoot.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestEnemy = enemy
                        end
                    end
                end
            end

            if nearestEnemy and nearestDist < 15 then
                local enemyHumanoid = nearestEnemy:FindFirstChild("Humanoid") :: Humanoid
                local enemyRoot = nearestEnemy:FindFirstChild("HumanoidRootPart") :: BasePart
                if enemyHumanoid and enemyRoot then
                    local damage = math.max(GameConfig.MIN_DAMAGE, stats.power - math.floor(floor * 0.5))
                    enemyHumanoid:TakeDamage(damage)

                    -- Check enemy death
                    if enemyHumanoid.Health <= 0 then
                        local drop = rollDrop(floor)
                        if drop then
                            spawnPickup(drop, enemyRoot.Position)
                        end
                        nearestEnemy:Destroy()
                    end
                end
            end

            task.wait(attackInterval)
        end
    end)

    -- Enemy attack loop
    task.spawn(function()
        while activeLoops[player.UserId] and humanoid and humanoid.Health > 0 do
            for _, enemy in workspace:GetDescendants() do
                if enemy:IsA("Model") and enemy.Name:find("Enemy_") then
                    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") :: BasePart
                    local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
                    if enemyRoot and rootPart then
                        local dist = (rootPart.Position - enemyRoot.Position).Magnitude
                        if dist < 10 then
                            local enemyDamage = math.max(GameConfig.MIN_DAMAGE, 5 + floor * 2 - stats.defense)
                            humanoid:TakeDamage(enemyDamage)
                        end
                    end
                end
            end
            task.wait(GameConfig.ENEMY_ATTACK_INTERVAL)
        end

        -- Player death
        if humanoid and humanoid.Health <= 0 then
            if GameConfig.KEEP_PARTS_ON_DEATH then
                -- Parts are already saved in playerData
            end
            -- Respawn at floor 1
            task.wait(2)
            player:LoadCharacter()
        end
    end)
end

function CombatEngine.Stop(player: Player)
    activeLoops[player.UserId] = nil
end

return CombatEngine
