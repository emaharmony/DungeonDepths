--!strict
--[[
    FloorGenerator — T4
    Generate single rectangular room per floor
    Stone zone tileset (gray blocks, torches)
    Place enemies based on floor number
    Clear path forward (exit door on far wall)
]]

local ServerScriptService = game:GetService("ServerScriptService")
local GameConfig = require(game:GetService("ReplicatedStorage"):FindFirstChild("GameConfig"))
local ZoneData = require(game:GetService("ReplicatedStorage"):FindFirstChild("ZoneData"))

local FloorGenerator = {}

local currentFloorModel: Model? = nil
local floorEnemies: { Instance } = {}

local function clearFloor()
    if currentFloorModel then
        currentFloorModel:Destroy()
        currentFloorModel = nil
    end
    for _, enemy in floorEnemies do
        if enemy and enemy.Parent then
            enemy:Destroy()
        end
    end
    floorEnemies = {}
end

local function createFloor(floor: number): Model
    local model = Instance.new("Model")
    model.Name = "Floor_" .. floor

    local zone = ZoneData.GetByFloor(floor)
    local zoneName = if zone then zone.tileset else "gray_blocks"

    -- Floor plate
    local floorPlate = Instance.new("Part")
    floorPlate.Name = "FloorPlate"
    floorPlate.Size = Vector3.new(GameConfig.FLOOR_SIZE_X, 1, GameConfig.FLOOR_SIZE_Z)
    floorPlate.Position = Vector3.new(0, -0.5, 0)
    floorPlate.Anchored = true
    floorPlate.BrickColor = BrickColor.new("Medium stone grey")
    floorPlate.Material = Enum.Material.Slate
    floorPlate.Parent = model

    -- Walls
    local wallPositions = {
        { pos = Vector3.new(0, 5, -GameConfig.FLOOR_SIZE_Z / 2), size = Vector3.new(GameConfig.FLOOR_SIZE_X, 10, 1) },
        { pos = Vector3.new(0, 5, GameConfig.FLOOR_SIZE_Z / 2), size = Vector3.new(GameConfig.FLOOR_SIZE_X, 10, 1) },
        { pos = Vector3.new(-GameConfig.FLOOR_SIZE_X / 2, 5, 0), size = Vector3.new(1, 10, GameConfig.FLOOR_SIZE_Z) },
        { pos = Vector3.new(GameConfig.FLOOR_SIZE_X / 2, 5, 0), size = Vector3.new(1, 10, GameConfig.FLOOR_SIZE_Z) },
    }
    for i, wall in wallPositions do
        local part = Instance.new("Part")
        part.Name = "Wall_" .. i
        part.Size = wall.size
        part.Position = wall.pos
        part.Anchored = true
        part.BrickColor = BrickColor.new("Dark stone grey")
        part.Material = Enum.Material.Cobblestone
        part.Parent = model
    end

    -- Exit door on far wall (positive Z)
    local exitDoor = Instance.new("Part")
    exitDoor.Name = "ExitDoor"
    exitDoor.Size = Vector3.new(4, 6, 1)
    exitDoor.Position = Vector3.new(0, 3, GameConfig.FLOOR_SIZE_Z / 2 - 0.5)
    exitDoor.Anchored = true
    exitDoor.BrickColor = BrickColor.new("Really red")
    exitDoor.Material = Enum.Material.Neon
    exitDoor.Transparency = 0.3
    exitDoor.Parent = model

    -- Torches (4 along walls)
    for torchIndex = 1, 4 do
        local torch = Instance.new("Part")
        torch.Name = "Torch_" .. torchIndex
        torch.Size = Vector3.new(0.5, 2, 0.5)
        torch.Position = Vector3.new(
            (if torchIndex % 2 == 0 then 1 else -1) * GameConfig.FLOOR_SIZE_X * 0.4,
            3,
            (if torchIndex <= 2 then -1 else 1) * GameConfig.FLOOR_SIZE_Z * 0.4
        )
        torch.Anchored = true
        torch.BrickColor = BrickColor.new("Bright orange")
        torch.Material = Enum.Material.Neon
        torch.Parent = model

        local light = Instance.new("PointLight")
        light.Brightness = 1
        light.Range = 20
        light.Color = Color3.fromRGB(255, 170, 0)
        light.Parent = torch
    end

    -- Spawn point
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "FloorSpawn"
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Position = Vector3.new(0, 0.5, -GameConfig.FLOOR_SIZE_Z / 2 + 5)
    spawn.Anchored = true
    spawn.CanCollide = false
    spawn.Parent = model

    return model
end

local function spawnEnemies(floor: number, model: Model)
    local zone = ZoneData.GetByFloor(floor)
    if not zone then return end

    local enemyCount = math.min(2 + floor, 10)
    local pool = zone.enemyPool

    for i = 1, enemyCount do
        local species = pool[math.random(1, #pool)]
        local enemy = Instance.new("Model")
        enemy.Name = "Enemy_" .. i .. "_" .. species

        local body = Instance.new("Part")
        body.Name = "HumanoidRootPart"
        body.Size = Vector3.new(2, 2, 2)
        body.Position = Vector3.new(
            math.random(-20, 20),
            1.5,
            math.random(-10, 10)
        )
        body.BrickColor = BrickColor.new(Color3.new(
            if species == "crab" then 0.8 elseif species == "spider" then 0.2
            elseif species == "slime" then 0.3 else 0.4,
            if species == "crab" then 0.4 elseif species == "spider" then 0.1
            elseif species == "slime" then 0.9 else 0.3,
            if species == "crab" then 0.2 elseif species == "spider" then 0.3
            elseif species == "slime" then 0.3 else 0.5
        ))
        body.Anchored = false
        body.Parent = enemy

        local humanoid = Instance.new("Humanoid")
        humanoid.MaxHealth = 30 + floor * 10
        humanoid.Health = humanoid.MaxHealth
        humanoid.Parent = enemy

        enemy.Parent = model
        table.insert(floorEnemies, enemy)
    end
end

function FloorGenerator.Generate(floor: number)
    clearFloor()
    local model = createFloor(floor)
    spawnEnemies(floor, model)
    model.Parent = workspace
    currentFloorModel = model
end

function FloorGenerator.GetEnemies(): { Instance }
    return floorEnemies
end

function FloorGenerator.GetCurrentFloorModel(): Model?
    return currentFloorModel
end

return FloorGenerator