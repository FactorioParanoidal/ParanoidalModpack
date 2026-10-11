-- Кабель в опорах эстакадных рельсов: после исследования paranoidal-rail-support-power на каждой опоре
-- силы стоит скрытый столб без зоны питания; столбы соседних опор соединяются проводами (data:
-- tweaks/custom/elevated-rail-supports.lua). Без elevated-rails модуль ничего не регистрирует.
local M = {}

local TECH = "paranoidal-rail-support-power"
local POLE_BY_SUPPORT = {
	["rail-support"] = "paranoidal-rail-support-pole-1",
	["paranoidal-rail-support-2"] = "paranoidal-rail-support-pole-2",
	["paranoidal-rail-support-3"] = "paranoidal-rail-support-pole-3",
}
local SUPPORT_NAMES, POLE_NAMES = {}, {}
for support, pole in pairs(POLE_BY_SUPPORT) do
	SUPPORT_NAMES[#SUPPORT_NAMES + 1] = support
	POLE_NAMES[#POLE_NAMES + 1] = pole
end

local function active()
	return script.active_mods["elevated-rails"] and prototypes.entity["paranoidal-rail-support-pole-1"] ~= nil
end

-- support unit_number -> hidden pole
local function poles()
	storage.rail_support_poles = storage.rail_support_poles or {}
	return storage.rail_support_poles
end

local function powered(force)
	local tech = force and force.valid and force.technologies[TECH]
	return tech and tech.researched or false
end

local function remove(unit_number)
	local list = poles()
	local pole = list[unit_number]
	if pole and pole.valid then pole.destroy() end
	list[unit_number] = nil
end

local function attach(support)
	if not (support and support.valid) then return end
	local name = POLE_BY_SUPPORT[support.name]
	if not name or not powered(support.force) then return end
	local id = support.unit_number
	local current = poles()[id]
	if current and current.valid and current.name == name then return end
	remove(id)
	-- Pole of a replaced (upgraded) support at the same spot; its own record is cleared on destruction.
	for _, stale in pairs(support.surface.find_entities_filtered{name = POLE_NAMES, position = support.position, radius = 0.1}) do
		stale.destroy()
	end
	local pole = support.surface.create_entity{
		name = name,
		position = support.position,
		force = support.force,
		create_build_effect_smoke = false,
	}
	if not pole then return end
	pole.destructible = false
	poles()[id] = pole
	script.register_on_object_destroyed(support)
end

local function detach_force(force)
	for id, pole in pairs(poles()) do
		if not pole.valid then
			poles()[id] = nil
		elseif pole.force == force then
			remove(id)
		end
	end
end

local function sync_force(force)
	if not (force and force.valid) then return end
	if not powered(force) then
		detach_force(force)
		return
	end
	for _, surface in pairs(game.surfaces) do
		for _, support in pairs(surface.find_entities_filtered{name = SUPPORT_NAMES, force = force}) do
			attach(support)
		end
	end
end

-- on_init / on_configuration_changed: mod added mid-game, research state changed, prototypes changed.
function M.sync()
	if not active() then return end
	for id, pole in pairs(poles()) do
		if not pole.valid then poles()[id] = nil end
	end
	for _, force in pairs(game.forces) do
		sync_force(force)
	end
end

-- Preserve earlier zzz handlers, as the other modules do.
local function on(event, callback)
	local previous = script.get_event_handler(event)
	script.on_event(event, function(e)
		if previous then previous(e) end
		callback(e)
	end)
end

function M.install()
	if not active() then return end
	for _, event in ipairs({defines.events.on_built_entity, defines.events.on_robot_built_entity,
		defines.events.script_raised_built, defines.events.script_raised_revive}) do
		on(event, function(e) attach(e.entity) end)
	end
	on(defines.events.on_entity_cloned, function(e) attach(e.destination) end)
	on(defines.events.on_object_destroyed, function(e)
		if e.useful_id and storage.rail_support_poles and storage.rail_support_poles[e.useful_id] then
			remove(e.useful_id)
		end
	end)
	on(defines.events.on_research_finished, function(e)
		if e.research.name == TECH then sync_force(e.research.force) end
	end)
	on(defines.events.on_research_reversed, function(e)
		if e.research.name == TECH then sync_force(e.research.force) end
	end)
	on(defines.events.on_technology_effects_reset, function(e) sync_force(e.force) end)
end

return M
