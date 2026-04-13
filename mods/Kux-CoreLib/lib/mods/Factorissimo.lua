require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides array functions
---@class KuxCoreLib.Factorissimo
local Factorissimo = {
	__class  = "Factorissimo",
	__guid   = "b5a1824b-c824-474c-a87a-25e7288d7423",
	__origin = "Kux-CoreLib/lib/mods/Factorissimo.lua",
}
if not KuxCoreLib.__classUtils.ctor(Factorissimo) then return self end
---------------------------------------------------------------------------------------------------
---Provides Factorissimo in the global namespace
---@return KuxCoreLib.Factorissimo
function Factorissimo.asGlobal() return KuxCoreLib.__classUtils.asGlobal(Factorissimo) end
---------------------------------------------------------------------------------------------------

local entity_names = {
	["factory-1"] = true,
	["factory-2"] = true,
	["factory-3"] = true,
}

---Gets the Factorissimo API
---@type Factorissimo.API
Factorissimo.api = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/mods/Factorissimo-API") --[[@as Factorissimo.API]]

function Factorissimo.isAvailable()
	return remote.interfaces['factorissimo'] ~= nil
end

---Gets a value indicating whether surface is is a Factorissimo floor
---@param surface LuaSurface|string Surface or surface name
---@return boolean
function Factorissimo.isFactoryFloor(surface)
	local trace = print; trace = function() end
	if not Factorissimo.isAvailable() then trace("isFactoryFloor", surface, "=> Factorissimo not availabe") return false end
	trace("isFactoryFloor", surface)

	local surface_name =
		type(surface) == "string" and surface or
		is_obj(surface) and surface.name or
		error("Invalid surface type: " .. type(surface))
	trace("  surface_name: "..surface_name)

	local result =
		surface_name:match("Factory floor %d+") or
		surface_name:match("factory%-floor%-%d+") or
		surface_name:match("%-factory%-floor$") -- Factorissimo >= 3.x ?
	trace("  result: "..tostring(result))
	return result ~= nil
end

function Factorissimo.isFactoryEntity(entity)
	if(not entity) then return false end
	--return entity_names[entity.name]
	return entity.name:match("^factory%-%d+$")
end

local function find_rectangle_by_tile_match(factory, tile)
	for index, value in ipairs(factory.layout.rectangles) do
		if(value.tile == tile) then
			return value
		end
	end
	log("factory.layout.rectangles:\n"..serpent.block(factory.layout.rectangles))
	error("rectangle not found '"..tile.."'. see log for details.")
end

---Creates a new MapPosition
---@param x number
---@param y number
---@return MapPosition
local function new_MapPosition(x, y)
	local p = {x = x,y = y}
	return setmetatable(p, {
		__index = function(t, k)
			if(k == 1) then return t.x end
			if(k == 2) then return t.y end
			return rawget(t, k)
		end,
		__newindex = function(t, k, v)
			if(k == 1) then t.x = v end
			if(k == 2) then t.y = v end
			rawset(t, k, v)
		end,
	})
end

---Creates a new BoundingBox
---@param left_top MapPosition
---@param right_bottom MapPosition
---@return BoundingBox
local function new_BoundingBox(left_top, right_bottom)
	local result = {
		left_top = left_top,
		right_bottom = right_bottom
	}
	return setmetatable(result, {
		__index = function(t, k)
			if(k == 1) then return t.left_top end
			if(k == 2) then return t.right_bottom end
			return rawget(t, k)
		end,
		__newindex = function(t, k, v)
			if(k == 1) then
				t.left_top.x = v.x
				t.left_top.y = v.y
			elseif(k == 2) then
				t.right_bottom.x = v.x
				t.right_bottom.y = v.y
			else
				rawset(t, k, v)
			end
		end,
	})
end

---@param factory Factorissimo.FactoryObject
---@param rect table
---@return BoundingBox
local function get_absolute_rectangle(factory, rect)
	return new_BoundingBox(
		new_MapPosition(rect.x1 + factory.inside_x, rect.y1 + factory.inside_y),
		new_MapPosition(rect.x2 + factory.inside_x, rect.y2 + factory.inside_y)
	)

	--add shorthands
	-- result.left_top[1]=result.left_top.x
	-- result.left_top[2]=result.left_top.y
	-- result.right_bottom[1]=result.right_bottom.x
	-- result.right_bottom[2]=result.right_bottom.y
	-- result[1]=result.left_top
	-- result[2]=result.right_bottom
	--TODO: revise. this is not a union

	-- return result
end

---Gets the factory floor rectangle for the factyory at the given position
---@param surface LuaSurface
---@param position MapPosition
---@return BoundingBox? #the factory floor rectangle or nil if not found
---@deprecated
function Factorissimo.getFactoryFloorRect(surface, position)
	local factory = Factorissimo.api.find_surrounding_factory(surface, position)
	if(factory == nil) then return nil end
	return Factorissimo.getFloorRect(factory)
end

---Gets the factory floor rectangle for the factyory
---@param factory Factorissimo.FactoryObject
---@return BoundingBox #the factory floor rectangle
function Factorissimo.getFloorRect(factory)
	if(not factory) then error("not in a factory") end
	local rect = factory.layout.rectangles[2]
	assert(rect.tile:match("factory%-floor"), "not a floor rectangle")
	return get_absolute_rectangle(factory, rect)
end

---Gets the factory wall rectangle for the factyory at the given position
---@param surface LuaSurface
---@param position MapPosition
---@return BoundingBox? #the factory wall rectangle or nil if not found
---@deprecated
function Factorissimo.getFactoryWallRect(surface, position)
	local factory = Factorissimo.api.find_surrounding_factory(surface, position)
	if(not factory) then return nil end
	return Factorissimo.getWallRect(factory)
end

---Gets the factory wall rectangle for the factyory
---@param factory Factorissimo.FactoryObject
---@return BoundingBox #the factory wall rectangle
function Factorissimo.getWallRect(factory)
	if(not factory) then error("Invalid Argument. 'factory' must not be nil") end
	local rect = factory.layout.rectangles[1]
	assert(rect.tile:match("factory%-wall"), "not a wall rectangle")
	return get_absolute_rectangle(factory, rect)
end

---Gets the top level surface of an entity
---@param obj LuaEntity|Factorissimo.FactoryObject
---@return LuaSurface? #the top level surface or nil if not built
function Factorissimo.getToplevelSurface(obj)
	if type(obj)=="userdata" and obj.object_name=="LuaEntity" then local entity = obj --[[@as LuaEntity]]
		if(not Factorissimo.isFactoryFloor(entity.surface)) then return entity.surface end
		while true do
			local factory = Factorissimo.api.find_surrounding_factory(entity.surface, entity.position)
			if(not factory) then return entity.surface end
			entity = factory.building
			if(not entity) then return nil end --factory is not built
		end
	elseif type(obj)=="table" then local factory = obj --[[@as Factorissimo.FactoryObject]]
		local entity = factory.building
		if(not entity) then --factory is not built
			surface_name = factory.inside_surface.name:match("^(.-)%-factory%-floor")
			return game.surfaces[surface_name] --maybe nil
		end
		if(not Factorissimo.isFactoryFloor(entity.surface)) then return entity.surface end
		return Factorissimo.getToplevelSurface(entity)
		-- TODO use factory.inside_surface.planet
	else
		error("Invalid Argument. 'obj' must be a LuaEntity or FactoryObject")
	end
end

---Gets the planet to which the specified object belongs
---@param obj LuaEntity|Factorissimo.FactoryObject
---@return LuaPlanet? #the planet to which the obj belongs or nil
---@deprecated Not yet implemented
function Factorissimo.getPlanet(obj)
	-- TODO: Factorissimo API request: inside_surface.planet should return the real planet
	-- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/119
	if type(obj)=="userdata" and obj.object_name=="LuaEntity" then local entity = obj --[[@as LuaEntity]]
		return entity.surface.planet
	elseif type(obj)=="table" then local factory = obj --[[@as Factorissimo.FactoryObject]]
		return factory.inside_surface.planet
	else
		error("Invalid Argument. 'obj' must be a LuaEntity or FactoryObject")
	end
end

---Gets the factory object for the given argument
---@param arg LuaEntity|Factorissimo.FactoryObject|LuaPlayer
---@return (Factorissimo.FactoryObject)?
function Factorissimo.getFactory(arg)
	if(not arg) then return nil end
	if(type(arg)~="table") then return nil end
	---@cast arg table
	if(arg.object_name == "LuaEntity") then
		local entity = arg --[[@as LuaEntity]]
		if(Factorissimo.isFactoryEntity(entity)) then
			return Factorissimo.api.get_factory_by_entity(entity)
		else
			if(not Factorissimo.isFactoryFloor(entity.surface)) then return nil end
			return Factorissimo.api.find_surrounding_factory(entity.surface, entity.position)
		end
	elseif(arg.object_name == "LuaPlayer") then
		local player = arg --[[@as LuaPlayer]]
		if(not Factorissimo.isFactoryFloor(player.surface)) then return nil end
		return Factorissimo.api.find_surrounding_factory(player.surface, player.position)
	else
		--TODO: check if arg is a factory object
		return arg --[[@as Factorissimo.FactoryObject]]
	end
end

---Gets the top level factory object for the given argument
---@param arg LuaEntity|Factorissimo.FactoryObject
---@return (Factorissimo.FactoryObject)?
function Factorissimo.getToplevelFactory(arg)
	local factory = Factorissimo.getFactory(arg)
	if(not factory) then return nil end
	while true do
		local entity = factory.building
		if(not entity) then return nil end --factory is not built
		if(not Factorissimo.isFactoryFloor(entity.surface)) then return factory end
		factory = Factorissimo.api.find_surrounding_factory(entity.surface, entity.position)
		if(not factory) then return nil end
	end
end

---Gets a value indicating wether the player is in a factory
---@param player LuaPlayer
---@return boolean
function Factorissimo.isPlayerInFactory(player)
	return Factorissimo.isAvailable and
		Factorissimo.api.find_surrounding_factory(player.surface, player.position)~=nil
end

---@deprecated use Factorissimo.getToplevelSurface
Factorissimo.get_toplevel_surface = Factorissimo.getToplevelSurface
---@deprecated use Factorissimo.getWallRect
Factorissimo.getFactoryWallRect_2 = Factorissimo.getWallRect
---@deprecated use Factorissimo.getWallRect
Factorissimo.getFactoryFloorRect_2 = Factorissimo.getFloorRect

return Factorissimo