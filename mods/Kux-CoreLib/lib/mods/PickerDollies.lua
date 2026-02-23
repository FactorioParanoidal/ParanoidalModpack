require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.PickerDollies : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.PickerDollies
local PickerDollies = {
	__class  = "PickerDollies",
	__guid   = "b4f4811e-d7e6-4fdd-ac5d-97042bce5a7c",
	__origin = "Kux-CoreLib/lib/mods/PickerDollies.lua",
}
if not KuxCoreLib.__classUtils.ctor(PickerDollies) then return self end
---------------------------------------------------------------------------------------------------

local ModInfo = KuxCoreLib.ModInfo

local _eventDistributor_callback
local _dolly_moved_entity_id = nil --[[@as uint?]]
local _filter = nil --[[@as EventFilter?]]

--https://mods.factorio.com/mod/PickerDollies

--[[
---@class PickerDollies.dolly_moved_entity
---@field player_index uint        The index of the player who moved the entity
---@field moved_entity LuaEntity   The entity that was moved
---@field start_pos    MapPosition The position that the entity was moved from
]]

---@class PickerDollies.dolly_moved_entity: EventData
---@field player_index uint                 Player index
---@field moved_entity LuaEntity            The entity that was moved. See 'transporter mode' note below
---@field start_pos MapPosition             The start position from which the entity was moved
---@field start_direction defines.direction The start direction of the entity (since 2.5.0)
---@field start_unit_number integer?        The original unit number of the entity (since 2.5.0)
---[View documentation](https://github.com/hgschmie/factorio-even-pickier-dollies/blob/main/API.md)

---@param e PickerDollies.dolly_moved_entity
local function on_entity_moved(e)
	_eventDistributor_callback(e)
end

---@param eventDistributor_callback function?
---@param filter EventFilter?
function PickerDollies.initialize(eventDistributor_callback, filter)
	--[[TRACE]]trace("PickerDollies.initialize")
	_eventDistributor_callback = _eventDistributor_callback or eventDistributor_callback or error("Invalid Argument: 'eventDistributor' must not be nil.")
	_filter = _filter or filter

	if(ModInfo.current_stage == "control") then return end -- ok, but wait for on_init or on_load

	if not remote.interfaces["PickerDollies"] or not remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
		log("WARNING: PickerDollies is not available. event on_entity_moved woll not be raised.")
		return
	end

	_dolly_moved_entity_id = remote.call("PickerDollies", "dolly_moved_entity_id") --[[@as uint]]
	local handler = script.get_event_handler(_dolly_moved_entity_id)
	if(handler) then error("PickerDollies event handler already registered") end
	script.on_event(_dolly_moved_entity_id, on_entity_moved)
end

---@param entity_name string
function add_blacklist_name(entity_name)
	remote.call('PickerDollies', 'add_blacklist_name', entity_name)
end

---@param entity_name string
function remove_blacklist_name(entity_name)
	remote.call('PickerDollies', 'remove_blacklist_name', entity_name)
end

---@return table<string, true>
function get_blacklist_names()
	return remote.call('PickerDollies', 'get_blacklist_names')
end

---@param entity_name string
---@param distance number
function add_oblong_name(entity_name, distance)
	return remote.call('PickerDollies', 'add_oblong_name', entity_name, distance)
end

---@param entity_name string
function remove_oblong_name(entity_name)
	return remote.call('PickerDollies', 'remove_oblong_name', entity_name)
end

---@return table<string, number>
function get_oblong_names()
	return remote.call('PickerDollies', 'get_oblong_names')
end


function PickerDollies.move_shadow_entities(main_entity, shadow_names, old_pos)
	local surface = main_entity.surface
	shadow_names = type(shadow_names)~="table" and {shadow_names} or shadow_names
	for _, shadow_name in pairs(shadow_names) do
		local entity = surface.find_entity(shadow_name, old_pos)
		if(not entity) then return end
		entity.teleport(main_entity.position)
	end
end

function PickerDollies.move_entity(surface_name, entity_name, start_pos, new_pos)
	local surface = game.surfaces[surface_name]
	local entity = surface.find_entity(entity_name, start_pos)
	if(not entity) then return end
	entity.teleport(new_pos)
end

---------------------------------------------------------------------------------------------------

KuxCoreLib.__classUtils.finalize(PickerDollies)
return PickerDollies
