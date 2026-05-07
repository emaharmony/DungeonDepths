--!strict
--[[
    ZoneData — Zone definitions for Dungeon Depths (M1: Stone only)
]]

local ZoneData = {}

local ZONES: { [string]: { name: string, floorRange: { number }, enemyPool: { string }, tileset: string } } = {
    stone = {
        name = "Stone Caverns",
        floorRange = { 1, 20 },
        enemyPool = { "crab", "spider", "slime", "bat" },
        tileset = "gray_blocks",
    },
}

function ZoneData.GetByFloor(floor: number): { name: string, floorRange: { number }, enemyPool: { string }, tileset: string }?
    for _, zone in ZONES do
        if floor >= zone.floorRange[1] and floor <= zone.floorRange[2] then
            return zone
        end
    end
    return nil
end

function ZoneData.GetAll(): { [string]: { name: string, floorRange: { number }, enemyPool: { string }, tileset: string } }
    return ZONES
end

return ZoneData