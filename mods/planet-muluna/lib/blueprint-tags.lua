--- Helpers for reading and merging bplib entity tags in blueprints.
--
-- `set_blueprint_entity_tags` replaces the entire tag table for an entity, so
-- multiple mods or handlers that add tags for the same entity must read and
-- merge the existing tags first.
-- @module lib.blueprint-tags
local Public = {}

---Return the tags stored on a blueprint entity, or an empty table.
---@param blueprint LuaItemStack|LuaRecord
---@param index uint32
---@return Tags
function Public.get_tags(blueprint, index)
    return blueprint.get_blueprint_entity_tags(index) or {}
end

---Merge tags into the tags already stored on a blueprint entity.
---@param blueprint LuaItemStack|LuaRecord
---@param index uint32
---@param tags Tags
---@return Tags merged_tags
function Public.add_tags(blueprint, index, tags)
    local merged = Public.get_tags(blueprint, index)
    for key, value in pairs(tags or {}) do
        merged[key] = value
    end
    blueprint.set_blueprint_entity_tags(index, merged)
    return merged
end

return Public
