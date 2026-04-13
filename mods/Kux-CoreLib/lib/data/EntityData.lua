require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.EntityData : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.EntityData
local EntityData = {
	__class  = "KuxCoreLib.EntityData",
	__guid   = "{990068A3-AA60-4453-A786-A4F2C7E7CA7F}",
	__origin = "Kux-CoreLib/lib/data/EntityData.lua",
}
if not KuxCoreLib.__classUtils.ctor(EntityData) then return self end
---------------------------------------------------------------------------------------------------
local Table= KuxCoreLib.Table
local DataRaw = KuxCoreLib.DataRaw
local utils = KuxCoreLib.PrototypeData.extend.utils

---@type EntityData.scale_util
EntityData.scale_util = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/data/entity-scale-util")

---Clone an entity prototype
---@param type string
---@param name string
---@param newName string
---@param patch {[string]:any}?
---@return data.EntityPrototype
 function EntityData.clone(type, name, newName, patch)
	local base = data.raw[type][name]
	if(not base) then error("Prototype not found: "..name.." (type: "..type..")") end
	local entity = table.deepcopy(base)--[[@as data.EntityPrototype]]
	entity.name = newName
	if(entity.minable) then
		if entity.minable.results then

		elseif entity.minable.result then
			if(entity.minable.result == name) then entity.minable.result = newName end
		end
	end
	entity["base"] = base -- additional data, only for data stage
	if(patch) then utils.patch(entity, patch) end -- apply patch if any
	return entity
end

---Remove entries from entity.collision_mask table.
---@param entity table? The entity prototype
---@param mask string|table The entries to remove
---@return boolean #true if the entry was found and removed; otherwise false
function EntityData.removeCollisionMask(entity, mask)
    if(not entity or mask==nil or not entity.collision_mask) then return false end
    if(type(mask)~="table") then mask={mask} end
    for _, v in ipairs(mask) do
        print("Table.remove(entity.collision_mask, "..v..")")
        return Table.remove(entity.collision_mask, v)
    end
    return false
end

---Remove entries from entity.collision_mask_with_flags table.
---@param entity table? The entity prototype
---@param mask string|table The entries to remove
---@return boolean #true if the entry was found and removed; otherwise false
function EntityData.removeCollisionMaskWithFlags(entity,mask)
    if(not entity or mask==nil or not entity.collision_mask_with_flags) then return false end
    if(type(mask)~="table") then mask={mask} end
    for _, v in ipairs(mask) do
        return Table.remove(entity.collision_mask_with_flags, v)
    end
    return false
end

---Finds an entity by name
---@param entityName string
---@param throwOnError boolean|nil
---@return table|nil
function EntityData.find(entityName, throwOnError)
    for _,typeName in ipairs(DataRaw.entityTypes) do
        local entity = data.raw[typeName][entityName]
        if(entity) then return entity --[[@as table]] end
    end
    if(throwOnError) then error("Entity not found. Name:'"..entityName.."'") end
    return nil
end


function EntityData.findType(entityName)
    for _,typeName in ipairs(DataRaw.entityTypes) do
		if data.raw[typeName] then
			local entity = data.raw[typeName][entityName]
			if(entity) then return typeName end
		end
    end
end

---
---@param value BoundingBox
---@return number? x1,number? y1,number? x2,number? y2
---<p>Usage: <code>local x1,y1,x2,y2 = splitBoundingBox4(entity.collision_box)</code></p>
function EntityData.unpackBoundingBox4(value)
	if not value then return nil end
	local lt = value[1] or value.left_top or error("left_top missing")
	local rb = value[2] or value.right_bottom or error("right_bottom missing")
	local x1 = lt[1] or lt.x or error("left_top.x missing")
	local y1 = lt[2] or lt.y or error("left_top.y missing")
	local x2 = rb[1] or rb.x or error("right_bottom.x missing")
	local y2 = rb[2] or rb.y or error("right_bottom.y missing")
	return x1,y1,x2,y2
end
local unpackBoundingBox4 = EntityData.unpackBoundingBox4

---Get the size of an entity
---@param entity data.EntityPrototype|LuaEntity
---@return number,number
function EntityData.getSize(entity)
	---@diagnostic disable-next-line: param-type-mismatch, cast-local-type
	if entity.object_name then entity = entity.prototype end ---@cast entity data.EntityPrototype

	-- tile_width, tile_height is rarely used anymore, as it is only used for alignment (tile-edge or tile center)
	if entity.collision_box then
		local x1,y1,x2,y2 = unpackBoundingBox4(entity.collision_box)
		local w, h = x2 - x1, y2 - y1

		if w < 0.5 and entity.tile_width == 0 then w = 0 end
		if h < 0.5 and entity.tile_height == 0 then h = 0 end

		return math.ceil(w), math.ceil(h)
	end
	if entity.tile_width and entity.tile_height then
		return entity.tile_width, entity.tile_height
	end
	return 0,0 --???
end

---Get tile offset of an entity
---@param entity data.EntityPrototype|LuaEntity
---@param revert boolean
---@return Vector
function EntityData.getTileOffset(entity, revert)
	local w,h
    ---@diagnostic disable-next-line: param-type-mismatch, cast-local-type
	if entity.object_name then entity = entity.prototype end ---@cast entity data.EntityPrototype

	if entity.tile_width then w = entity.tile_width
	elseif entity.collision_box then w = math.ceil(entity.collision_box.right_bottom.x - entity.collision_box.left_top.x)
	elseif entity.selection_box then w = math.ceil(entity.selection_box.right_bottom.x - entity.selection_box.left_top.x)
	end

	if entity.tile_height then h = entity.tile_height
	elseif entity.collision_box then h = math.ceil(entity.collision_box.right_bottom.y - entity.collision_box.left_top.y)
	elseif entity.selection_box then h = math.ceil(entity.selection_box.right_bottom.y - entity.selection_box.left_top.y)
	end

	local xOffset = (w % 2 == 0) and 0 or (revert and -0.5 or 0.5)
	local yOffset = (h % 2 == 0) and 0 or (revert and -0.5 or 0.5)

	return {x = xOffset, y = yOffset}
end


---Scale an entity prototype
---@param entity data.EntityPrototype
---@param scale number The scale factor
function EntityData.scale(entity, scale) EntityData.scale_util.scale(entity, scale) end

---------------------------------------------------------------------------------------------------
return EntityData