--!strict
--[[
    GameConfig — Tuning constants for Dungeon Depths
]]

local GameConfig = {}

-- Combat
GameConfig.BASE_HP = 100
GameConfig.BASE_ATTACK_INTERVAL = 1.0 -- seconds
GameConfig.ENEMY_ATTACK_INTERVAL = 1.5
GameConfig.MIN_DAMAGE = 1

-- Floor
GameConfig.STARTING_FLOOR = 1
GameConfig.M1_MAX_FLOOR = 20
GameConfig.FLOOR_SIZE_X = 60
GameConfig.FLOOR_SIZE_Z = 60

-- Stats
GameConfig.STAT_KEYS = { "power", "speed", "defense", "special" }

-- Rarity weights for drop table
GameConfig.RARITY_WEIGHTS = {
    common = 60,
    uncommon = 25,
    rare = 10,
    epic = 4,
    legendary = 1,
}

-- Death
GameConfig.RESPAWN_FLOOR = 1
GameConfig.KEEP_PARTS_ON_DEATH = true

-- Segments
GameConfig.SEGMENT_SLOTS = { "head", "torso", "arms", "legs", "back" }

-- Zone floors
GameConfig.ZONE_FLOORS = {
    stone = { 1, 20 },
}

-- Starting species
GameConfig.DEFAULT_SPECIES = "crab"

return GameConfig