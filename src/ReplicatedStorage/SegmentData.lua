--!strict
--[[
    SegmentData — 8 species × 5 slots = 40 segments
    Each segment has stats, ability, rarity, color, and asset reference.
]]

local SegmentData = {}

local SPECIES_LIST = { "crab", "spider", "slime", "bat", "golem", "ghost", "dragon", "fungus" }
local SLOTS = { "head", "torso", "arms", "legs", "back" }

local STAT_PROFILES: { [string]: { power: number, speed: number, defense: number, special: number } } = {
    crab    = { power = 8,  speed = 4,  defense = 10, special = 3  },
    spider  = { power = 5,  speed = 12, defense = 4,  special = 4  },
    slime   = { power = 4,  speed = 6,  defense = 6,  special = 9  },
    bat     = { power = 3,  speed = 14, defense = 2,  special = 6  },
    golem   = { power = 10, speed = 2,  defense = 14, special = 1  },
    ghost   = { power = 6,  speed = 8,  defense = 3,  special = 10 },
    dragon  = { power = 14, speed = 6,  defense = 8,  special = 7  },
    fungus  = { power = 4,  speed = 5,  defense = 7,  special = 12 },
}

local ABILITIES: { [string]: { [string]: string } } = {
    crab   = { head = "pinch",     torso = "harden",  arms = "pinch",  legs = "scurry",  back = "shellshield" },
    spider = { head = "bite",      torso = "webwrap", arms = "webshot", legs = "leap",    back = "spidersense" },
    slime  = { head = "absorb",    torso = "split",    arms = "stretch", legs = "ooze",    back = "bounce" },
    bat    = { head = "echosqueak", torso = "dodge",   arms = "flap",   legs = "roost",   back = "sonicwave" },
    golem  = { head = "headslam",   torso = "fortify", arms = "smash",  legs = "stomp",   back = "stoneback" },
    ghost  = { head = "wail",      torso = "phase",    arms = "chill",  legs = "float",   back = "spiritshield" },
    dragon = { head = "fireball",   torso = "scalearmor", arms = "slash", legs = "dash",   back = "wingburn" },
    fungus = { head = "sporecloud", torso = "regenerate", arms = "spore",  legs = "root",   back = "mushroomcap" },
}

local COLORS: { [string]: { R: number, G: number, B: number } } = {
    crab   = { R = 0.8,  G = 0.4,  B = 0.2  },
    spider = { R = 0.2,  G = 0.1,  B = 0.3  },
    slime  = { R = 0.3,  G = 0.9,  B = 0.3  },
    bat    = { R = 0.4,  G = 0.3,  B = 0.5  },
    golem  = { R = 0.5,  G = 0.5,  B = 0.5  },
    ghost  = { R = 0.7,  G = 0.8,  B = 1.0  },
    dragon = { R = 0.9,  G = 0.2,  B = 0.1  },
    fungus = { R = 0.6,  G = 0.5,  B = 0.2  },
}

local SEGMENTS: { [string]: GameConfig.Segment } = {}

for _, species in SPECIES_LIST do
    for _, slot in SLOTS do
        local id = species .. "_" .. slot .. "_01"
        local stats = STAT_PROFILES[species]
        SEGMENTS[id] = {
            id = id,
            species = species,
            slot = slot,
            rarity = "common",
            stats = {
                power = stats.power + (if slot == "head" then 2 elseif slot == "arms" then 1 else 0),
                speed = stats.speed + (if slot == "legs" then 2 elseif slot == "back" then 1 else 0),
                defense = stats.defense + (if slot == "torso" then 2 elseif slot == "back" then 1 else 0),
                special = stats.special + (if slot == "head" then 1 else 0),
            },
            ability = ABILITIES[species][slot],
            depth_zone = "stone",
            asset_id = id,
            color = COLORS[species],
        }
    end
end

function SegmentData.GetAll(): { [string]: GameConfig.Segment }
    return SEGMENTS
end

function SegmentData.GetById(id: string): GameConfig.Segment?
    return SEGMENTS[id]
end

function SegmentData.GetBySlot(slot: string): { GameConfig.Segment }
    local result = {}
    for _, seg in SEGMENTS do
        if seg.slot == slot then
            table.insert(result, seg)
        end
    end
    return result
end

function SegmentData.GetBySpecies(species: string): { GameConfig.Segment }
    local result = {}
    for _, seg in SEGMENTS do
        if seg.species == species then
            table.insert(result, seg)
        end
    end
    return result
end

return SegmentData