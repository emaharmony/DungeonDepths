--!strict
--[[
    SpeciesData — Species definitions for Dungeon Depths
]]

local SpeciesData = {}

local SPECIES: { [string]: { name: string, colorFamily: string, theme: string } } = {
    crab    = { name = "Crab",    colorFamily = "warm",    theme = "coastal armor" },
    spider  = { name = "Spider",  colorFamily = "dark",    theme = "web and venom" },
    slime   = { name = "Slime",   colorFamily = "nature",  theme = "ooze and absorb" },
    bat     = { name = "Bat",     colorFamily = "shadow",  theme = "echo and flight" },
    golem   = { name = "Golem",   colorFamily = "earth",   theme = "stone and fortify" },
    ghost   = { name = "Ghost",   colorFamily = "ethereal", theme = "phase and wail" },
    dragon  = { name = "Dragon",  colorFamily = "fire",    theme = "flame and scale" },
    fungus  = { name = "Fungus",  colorFamily = "organic", theme = "spore and growth" },
}

function SpeciesData.Get(id: string): { name: string, colorFamily: string, theme: string }?
    return SPECIES[id]
end

function SpeciesData.GetAll(): { [string]: { name: string, colorFamily: string, theme: string } }
    return SPECIES
end

return SpeciesData