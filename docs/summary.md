# DungeonDepths — Project Summary

**Last Updated:** 2026-06-05
**Status:** Early Prototype (★ — minimal, needs redesign)
**Genre:** Dungeon Crawler / Roguelike
**GitHub:** github.com/emaharmony/DungeonDepths
**Mac Repo:** /Users/ema/projects/repos/DungeonDepths
**Windows Path:** D:\Projects\Roblox\DungeonDepths
**Rojo Port:** 34876
**Branch:** feature/dungeon-depths-m1-descent

---

## Game Overview

Dungeon crawler with procedurally generated floors. Collect segments, assemble characters, descend deeper. Roguelike progression with zone-based difficulty.

### Architecture
- **12 files** (mix of .lua and .luau), 72K total
- Server: GameInit, FloorGenerator, CombatEngine, CharacterAssembler
- Client: DungeonHUD, PartSwapUI
- Shared: GameConfig, Remotes, SpeciesData, ZoneData, SegmentData
- Uses older .lua extension (not .luau) for some files — inconsistency

### Current State
- Very early — basic floor generation + combat
- Only ~5% complete per portfolio evaluation
- Needs significant redesign to be viable
- Mix of .lua and .luau file extensions (inconsistency)

---

## Milestones

| Phase | Status |
|-------|--------|
| Floor generation | ✅ Basic |
| Combat engine | ✅ Basic |
| Character assembly | ⚠️ Rough |
| Progression system | ❌ Not started |
| Multiple zones | ❌ Not started |
| Enemies + bosses | ❌ Not started |
| Items + loot | ❌ Not started |
| Audio/VFX | ❌ Not started |
| Publish | ❌ Not started |