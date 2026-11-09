--------------------------------------------------------------------------------
-- BLUEPRINT LIBRARY
-- Data types and enums.
--------------------------------------------------------------------------------
local lib = {}

---A blueprint-like object
---@alias bplib.Blueprintish LuaItemStack|LuaRecord

---@class bplib.ModData
---@field overlap_entity_names {[string]: true} A set of entity names that will trigger `bplib-overlaps` events.
---@field position_entity_names {[string]: true} A set of entity names that will trigger `bplib-positions` events.
---@field extract_entity_names {[string]: true} A set of entity names that will trigger `bplib-extract` events.

---@class bplib.ExtractEvent
---@field name "bplib-extract"
---@field tick MapTick
---@field player_index uint32 Player who is extracting entities into a blueprint.
---@field blueprint LuaItemStack|LuaRecord The blueprint that entities are being extracted into.
---@field entities {[uint32]: LuaEntity} Map from blueprint entity indices to world entities that were extracted into the blueprint.

---@class bplib.PositionsEvent
---@field name "bplib-positions"
---@field tick MapTick
---@field player_index uint32 Player who is applying a blueprint.
---@field blueprint LuaItemStack|LuaRecord The blueprint that is being applied.
---@field bbox BoundingBox The bounding box of the area where the blueprint is being applied.
---@field positions {[uint32]: MapPosition} Map from blueprint entity indices to world positions where those entities will be placed.

---@class bplib.OverlapsEvent
---@field name "bplib-overlaps"
---@field tick MapTick
---@field player_index uint32 Player who is applying a blueprint.
---@field blueprint LuaItemStack|LuaRecord The blueprint that is being applied.
---@field bbox BoundingBox The bounding box of the area where the blueprint is being applied.
---@field positions {[uint32]: MapPosition} Map from blueprint entity indices to world positions where those entities will be placed. This contains all positions that were calculated by bplib, regardless of overlap.
---@field overlaps {[uint32]: LuaEntity} Map from blueprint entity indices to world entities that overlap with those blueprint entities. This contains only overlaps.

return lib
