require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.CollisionMaskData
local CollisionMaskData = {
	__class  = "CollisionMaskData",
	__guid   = "72c0af7b-5840-4c8d-857d-b564bd4547bd",
	__origin = "Kux-CoreLib/lib/data/CollisionMaskData.lua",
}
if not KuxCoreLib.__classUtils.ctor(CollisionMaskData) then return self end
---------------------------------------------------------------------------------------------------
function CollisionMaskData.asGlobal() return KuxCoreLib.__classUtils.asGlobal(CollisionMaskData) end
---------------------------------------------------------------------------------------------------
local collision_mask_util = require("__core__/lualib/collision-mask-util") --[[@as collision_mask_util]]
CollisionMaskData.collision_mask_util = collision_mask_util

-- Factorio 2.0:
-- found in prototypes: {"water_tile", "item", "resource", "player", "doodad", "ground_tile", "floor", "object",
	-- "elevated_rail", "train", "is_object", "is_lower_object", "cliff"}

-- item
-- meltable
-- object
-- player
-- water_tile
-- is_object
-- is_lower_object
-- elevated_rail
-- floor
-- car
-- transport_belt
-- rail
-- train
-- elevated_train
-- trigger_target
-- resource
-- doodad
-- ground_tile
-- cliff

local function fix_layer_name_from_before_v20(layer_name)
    if layer_name == "not-colliding-with-itself" or layer_name == "consider-tile-transitions" or layer_name == "colliding-with-tiles-only" then
		return nil -- moved to an attribute
	end
	if string.sub(layer_name, -6) == "-layer" then
        return string.sub(layer_name, 1, -7) -- Entfernt das "-layer" Suffix
    end
	layer_name = string.gsub(layer_name, "-layer$", "")
	layer_name = string.gsub(layer_name, "-", "_")
    return layer_name
end

CollisionMaskData.fix_layer_name_from_before_2_0 = fix_layer_name_from_before_v20

---
---@param prototype data.EntityPrototype
---@param layer string
function CollisionMaskData.try_add_layer(prototype, layer)
	if(not prototype) then return end
	if(not prototype.type) then --assume {type, name}
		local t = data.raw[prototype[1]]; if not t then return end
		local p = t[prototype[2]]; if not p then return end
		prototype = p --[[@as data.EntityPrototype]]
	end
	prototype.collision_mask = prototype.collision_mask or collision_mask_util.get_default_mask(prototype.type)
	if isV1 then
		---@diagnostic disable-next-line: undefined-field
		collision_mask_util.add_layer(prototype.collision_mask, layer)
	else
		if layer == "not-colliding-with-itself" then
			prototype.collision_mask.not_colliding_with_itself = true
		elseif layer == "consider-tile-transitions" then
			prototype.collision_mask.consider_tile_transitions = true
		elseif layer == "colliding-with-tiles-only" then
			prototype.collision_mask.colliding_with_tiles_only = true
		else
			layer = fix_layer_name_from_before_v20(layer)
			prototype.collision_mask.layers[layer] = true
		end
	end
end

---
---@param prototype data.EntityPrototype
---@param layer string
function CollisionMaskData.try_remove_layer(prototype, layer)
	if(not prototype) then return end
	if(not prototype.type) then --assume {type, name}
		local t = data.raw[prototype[1]]; if not t then return end
		local p = t[prototype[2]]; if not p then return end
		prototype = p
	end
	if isV1 then
		---@diagnostic disable: undefined-field
		prototype.collision_mask = prototype.collision_mask or collision_mask_util.get_default_mask(prototype.type)
		collision_mask_util.remove_layer(prototype.collision_mask, layer)
		---@diagnostic enable: undefined-field
	else
		if layer == "not-colliding-with-itself" then
			prototype.collision_mask.not_colliding_with_itself = false
		elseif layer == "consider-tile-transitions" then
			prototype.collision_mask.consider_tile_transitions = false
		elseif layer == "colliding-with-tiles-only" then
			prototype.collision_mask.colliding_with_tiles_only = false
		else
			layer = fix_layer_name_from_before_v20(layer) or error("Invalid layer name: "..layer)
			prototype.collision_mask.layers[layer] = nil
		end
	end
end

---
---@param prototype data.EntityPrototype
---@return string[]
function CollisionMaskData.extract_layers(prototype)
    local layers_array = {}
    if prototype.collision_mask and prototype.collision_mask.layers then
        for layer, _ in pairs(prototype.collision_mask.layers) do
            table.insert(layers_array, layer)
        end
    end
    return layers_array
end

return CollisionMaskData