-- Runtime of the turret ranks. Paranoidal fork of HeroTurretRedux 1.0.38: rank rules of
-- heroturrets 9.1.11 (Beta 8) plus the 2.0 features of Redux (wires, circuit behaviour, priority
-- targets, quality, base-turret ghosts and blueprints).
--
-- Load: a turret's rank is checked only when that turret is the cause of a death. Every event is
-- registered once, with native filters, so trees, rocks, buildings and other deaths never reach
-- Lua. Ranked prototypes and startup settings are read once when the script loads.
local util = heroturrets.util
local D = heroturrets.defines

local M = {}

local TURRET_TYPES = {"ammo-turret", "electric-turret", "fluid-turret", "artillery-turret"}
local MAX_COUNTER = 4294967295

local startup = settings.startup
local kill_multiplier = {
	["ammo-turret"] = startup["heroturrets-setting-ammo-turret-kill-multiplier"].value,
	["fluid-turret"] = startup["heroturrets-setting-fluid-turret-kill-multiplier"].value,
	["electric-turret"] = startup["heroturrets-setting-electric-turret-kill-multiplier"].value,
	["artillery-turret"] = startup["heroturrets-setting-artillery-turret-kill-multiplier"].value,
}
-- Types whose kills raise the rank.
local ranks_up = {
	["ammo-turret"] = true,
	["fluid-turret"] = true,
	["electric-turret"] = true,
	["artillery-turret"] = startup["heroturrets-allow-artillery-turrets"].value,
}
local exact_counter = startup["heroturrets-kill-counter"].value == "Exact"
local damage_counter = startup["heroturrets-damage-counter"].value == "On"
local rank_by_damage = startup["heroturrets-allow-damage"].value == "Enabled"
local max_health_on_rank = startup["heroturrets-max-health-on-rank"].value

---------------------------------------------------------------------------------------------------
-- Rank tables
---------------------------------------------------------------------------------------------------
local rank_count = #util.get_rank_names()

-- Beta 8: linear table from the first to the last reference value over all ranks.
local function spread(first, last)
	local diff = (last - first) / rank_count
	if diff <= 0 then return nil end
	local result, current = {}, first
	for k = 1, rank_count - 1 do
		result[k] = current
		current = math.floor(current + diff)
	end
	result[rank_count] = last
	return result
end

local function custom_table(enabled, csv)
	if not enabled then return nil end
	csv = util.local_trim(csv or "")
	if csv == "" then return nil end
	local parsed = util.parseCustomRankTable(csv)
	if not parsed or #parsed == 0 then
		log("HeroTurretRedux: custom rank table is invalid, using the default one: " .. csv)
		return nil
	end
	if #parsed == rank_count then return parsed end
	return spread(parsed[1], parsed[#parsed])
end

local function rank_table(reference, use_custom, csv)
	local result = rank_count == #reference and reference or spread(reference[1], reference[#reference])
	return custom_table(use_custom, csv) or result
end

local kill_table = rank_table(D.turret_levelup_kills,
	startup["heroturrets-use-csv-kills"].value, startup["heroturrets-csv-kill"].value)
local damage_table = rank_table(D.turret_levelup_damage,
	startup["heroturrets-use-csv-damage"].value, startup["heroturrets-csv-damage"].value)
local top_rank = math.min(#kill_table, #damage_table)

---------------------------------------------------------------------------------------------------
-- Ranked prototypes: name -> {rank, base}; base -> {[rank] = ranked name}
---------------------------------------------------------------------------------------------------
local ranked, ladders = {}, {}
for name in pairs(prototypes.get_entity_filtered({{filter = "type", type = TURRET_TYPES}})) do
	local rank, base = string.match(name, "^hero%-turret%-(%d+)%-for%-(.+)$")
	if rank then
		rank = tonumber(rank)
		ranked[name] = {rank = rank, base = base}
		local ladder = ladders[base]
		if not ladder then
			ladder = {}
			ladders[base] = ladder
		end
		ladder[rank] = name
	end
end
M.ranked = ranked

-- Runtime-global settings, read lazily and refreshed on change (same on every peer).
local allow_ghost_rank, allow_blueprint_rank
local function runtime_settings()
	if allow_ghost_rank == nil then
		allow_ghost_rank = settings.global["heroturrets-allow-ghost-rank"].value
		allow_blueprint_rank = settings.global["heroturrets-allow-blueprint-rank"].value
	end
end

local function state()
	local s = storage.heroturrets
	if not s then
		s = {}
		storage.heroturrets = s
	end
	s.dying_targets = s.dying_targets or {}
	return s
end

---------------------------------------------------------------------------------------------------
-- Turret replacement
---------------------------------------------------------------------------------------------------
-- Priority targets of a turret or a turret ghost, by index.
local function priority_targets(entity)
	local targets = {}
	for index = 1, 1000 do
		local ok, target = pcall(entity.get_priority_target, index)
		if not ok or not target then break end
		targets[index] = target
	end
	return targets
end

local function restore_targets(entity, targets)
	for index, target in pairs(targets) do
		if target.valid then pcall(entity.set_priority_target, index, target) end
	end
end

-- Wires: {connector id -> {{target, origin}}}. Ghosts are read the same way.
local function wire_connections(entity)
	local result = {}
	local ok, connectors = pcall(entity.get_wire_connectors, false)
	if not ok or not connectors then return result end
	for id, connector in pairs(connectors) do
		if connector.connection_count > 0 then
			local list = {}
			for _, connection in pairs(connector.connections) do
				list[#list + 1] = {target = connection.target, origin = connection.origin}
			end
			result[id] = list
		end
	end
	return result
end

local function restore_wires(entity, wires)
	if not next(wires) then return end
	local ok, connectors = pcall(entity.get_wire_connectors, true)
	if not ok or not connectors then return end
	for id, list in pairs(wires) do
		local connector = connectors[id]
		if connector then
			for _, connection in pairs(list) do
				if connection.target.valid then connector.connect_to(connection.target, false, connection.origin) end
			end
		end
	end
end

local function control_settings(entity)
	local behaviour = entity.get_control_behavior()
	if not behaviour then return nil end
	local data = {
		circuit_enable_disable = behaviour.circuit_enable_disable,
		circuit_condition = behaviour.circuit_condition,
		connect_to_logistic_network = behaviour.connect_to_logistic_network,
		logistic_condition = behaviour.logistic_condition,
		read_ammo = behaviour.read_ammo,
	}
	if entity.type ~= "artillery-turret" then
		data.set_priority_list = behaviour.set_priority_list
		data.set_ignore_unlisted_targets = behaviour.set_ignore_unlisted_targets
		data.ignore_unlisted_targets_condition = behaviour.ignore_unlisted_targets_condition
	end
	return data
end

local function restore_control(entity, data)
	if not data then return end
	local behaviour = entity.get_or_create_control_behavior()
	if not behaviour then return end
	for key, value in pairs(data) do behaviour[key] = value end
end

-- Replaces a turret by another prototype at the same place. Ammo stacks (with partial magazines and
-- quality), health, wires, circuit settings and priority targets are kept. keep_counters = false
-- resets kills and damage (demotion).
local function replace_turret(entity, new_name, keep_counters)
	local surface, position, force = entity.surface, entity.position, entity.force
	local direction, orientation, quality = entity.direction, entity.orientation, entity.quality
	local health, max_health = entity.health, entity.max_health
	local kills, damage = entity.kills, entity.damage_dealt
	local last_user = entity.last_user
	local ignore_unprioritised = nil
	if entity.type ~= "artillery-turret" then ignore_unprioritised = entity.ignore_unprioritised_targets end
	local targets = priority_targets(entity)
	local wires = wire_connections(entity)
	local control = control_settings(entity)

	local ammo, buffer = entity.get_inventory(defines.inventory.turret_ammo), nil
	if ammo and not ammo.is_empty() then
		buffer = game.create_inventory(#ammo)
		for i = 1, #ammo do
			if ammo[i].valid_for_read then buffer[i].transfer_stack(ammo[i]) end
		end
	end

	if not (entity.can_be_destroyed() and entity.destroy({raise_destroy = true})) then
		if buffer then
			for i = 1, #buffer do
				if buffer[i].valid_for_read then ammo[i].transfer_stack(buffer[i]) end
			end
			buffer.destroy()
		end
		return nil
	end

	local new_entity = surface.create_entity({
		name = new_name, position = position, force = force, direction = direction,
		orientation = orientation, quality = quality, raise_built = true,
	})
	if new_entity and new_entity.valid then
		if not max_health_on_rank and health ~= max_health then new_entity.health = health end
		new_entity.kills = keep_counters and kills or 0
		new_entity.damage_dealt = keep_counters and damage or 0
		if last_user then new_entity.last_user = last_user end
		local inventory = buffer and new_entity.get_inventory(defines.inventory.turret_ammo)
		if inventory then
			for i = 1, math.min(#buffer, #inventory) do
				if buffer[i].valid_for_read then inventory[i].transfer_stack(buffer[i]) end
			end
		end
		restore_targets(new_entity, targets)
		if ignore_unprioritised ~= nil then new_entity.ignore_unprioritised_targets = ignore_unprioritised end
		restore_wires(new_entity, wires)
		restore_control(new_entity, control)
	end
	if buffer then
		-- Anything that did not fit goes on the ground instead of disappearing.
		for i = 1, #buffer do
			if buffer[i].valid_for_read then surface.spill_item_stack({position = position, stack = buffer[i], force = force}) end
		end
		buffer.destroy()
	end
	return new_entity
end
M.replace_turret = replace_turret

---------------------------------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------------------------------
-- Beta 8: the highest rank whose threshold (x type multiplier, minus the kill being counted) is met.
local function check_rank(turret, multiplier)
	local name = turret.name
	local info = ranked[name]
	local current = info and info.rank or 0
	if current >= top_rank then return end
	local ladder = ladders[info and info.base or name]
	if not ladder then return end
	local kills = turret.kills
	if not rank_by_damage and kills < kill_table[current + 1] * multiplier - 1 then return end
	local damage = rank_by_damage and turret.damage_dealt or 0
	for rank = top_rank, current + 1, -1 do
		if kills >= kill_table[rank] * multiplier - 1 or (rank_by_damage and damage >= damage_table[rank] * multiplier) then
			local target = ladder[rank]
			if target then
				replace_turret(turret, target, true)
				return
			end
		end
	end
end

local function on_entity_died(event)
	local cause = event.cause
	if cause and cause.valid then
		local turret_type = cause.type
		if ranks_up[turret_type] then check_rank(cause, kill_multiplier[turret_type]) end
	end
	-- A dying ranked turret: keep its priority targets for the base-turret ghost.
	runtime_settings()
	if allow_ghost_rank then return end
	local entity = event.entity
	if entity.valid and ranked[entity.name] and entity.unit_number then
		local ignore_unprioritised = nil
		if entity.type ~= "artillery-turret" then ignore_unprioritised = entity.ignore_unprioritised_targets end
		state().dying_targets[entity.unit_number] = {
			targets = priority_targets(entity), ignore_unprioritised = ignore_unprioritised,
		}
	end
end

-- A ranked turret's ghost becomes the base turret's ghost (unless ranked ghosts are allowed).
local function on_post_entity_died(event)
	local s = storage.heroturrets
	local saved = nil
	if s and s.dying_targets and event.unit_number then
		saved = s.dying_targets[event.unit_number]
		s.dying_targets[event.unit_number] = nil
	end
	runtime_settings()
	if allow_ghost_rank then return end
	local ghost = event.ghost
	if not (ghost and ghost.valid) then return end
	local info = ranked[ghost.ghost_name]
	if not info then return end

	local surface, position, force = ghost.surface, ghost.position, ghost.force
	local direction, quality = ghost.direction, ghost.quality
	local targets = saved and saved.targets or priority_targets(ghost)
	local ignore_unprioritised = saved and saved.ignore_unprioritised
	if ignore_unprioritised == nil then
		local ok, value = pcall(function() return ghost.ignore_unprioritised_targets end)
		if ok then ignore_unprioritised = value end
	end
	local wires = wire_connections(ghost)
	ghost.destroy()
	local new_ghost = surface.create_entity({
		name = "entity-ghost", inner_name = info.base, position = position, force = force,
		direction = direction, quality = quality,
	})
	if not (new_ghost and new_ghost.valid) then return end
	restore_targets(new_ghost, targets)
	if ignore_unprioritised ~= nil then pcall(function() new_ghost.ignore_unprioritised_targets = ignore_unprioritised end) end
	restore_wires(new_ghost, wires)
end

-- A ranked turret that is built keeps at least the kills of its rank (Beta 8).
local function exact_tags(event)
	if event.tags then return event.tags end
	local items = event.consumed_items
	if items and items.valid then
		for i = 1, #items do
			local stack = items[i]
			if stack.valid_for_read and stack.type == "item-with-tags" then return stack.tags end
		end
	end
	return nil
end

local function on_built(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if exact_counter then
		local tags = exact_tags(event)
		if tags and tags.kills then
			entity.kills = tags.kills
			if damage_counter and tags.damage_dealt then entity.damage_dealt = tags.damage_dealt end
			return
		end
	end
	local info = ranked[entity.name]
	if not info or not kill_table[info.rank] then return end
	local multiplier = kill_multiplier[entity.type] or 1
	entity.kills = math.min(MAX_COUNTER, math.max(kill_table[info.rank] * multiplier, entity.kills or 0))
	entity.damage_dealt = math.max(damage_table[info.rank] * multiplier, entity.damage_dealt or 0)
end

-- Exact counter: the mined turret's kills travel in the item tags.
local function on_mined(event)
	local entity, buffer = event.entity, event.buffer
	if not (entity and entity.valid and buffer and buffer.valid) then return end
	local kills = entity.kills
	if not kills or kills <= 0 then return end
	for i = 1, #buffer do
		local stack = buffer[i]
		if stack.valid_for_read and stack.type == "item-with-tags" then
			stack.set_tag("kills", kills)
			stack.custom_description = kills .. " Kills"
			if damage_counter and entity.damage_dealt then stack.set_tag("damage_dealt", entity.damage_dealt) end
		end
	end
end

-- Blueprints place base turrets instead of ranked ones (unless ranked blueprints are allowed).
local function blueprint_of(event)
	local stack = event.stack
	if stack and stack.valid_for_read and stack.is_blueprint then return stack end
	local record = event.record
	if record and record.valid and record.type == "blueprint" then return record end
	local player = game.get_player(event.player_index)
	if not player then return nil end
	for _, candidate in pairs({player.blueprint_to_setup, player.cursor_stack}) do
		if candidate and candidate.valid_for_read and candidate.is_blueprint then return candidate end
	end
	return nil
end

local function on_player_setup_blueprint(event)
	runtime_settings()
	if allow_blueprint_rank then return end
	local blueprint = blueprint_of(event)
	if not blueprint then return end
	local entities = blueprint.get_blueprint_entities()
	if not entities then return end
	local changed = false
	for _, entity in pairs(entities) do
		local info = ranked[entity.name]
		if info then
			entity.name = info.base
			changed = true
		end
	end
	if changed then blueprint.set_blueprint_entities(entities) end
end

---------------------------------------------------------------------------------------------------
-- Registration
---------------------------------------------------------------------------------------------------
-- Deaths that can raise a rank (enemies, worms, nests, turrets) or leave a ranked ghost (turrets).
local DIED_TYPES = {"unit", "unit-spawner", "turret", "character", "car", "spider-vehicle",
	"ammo-turret", "electric-turret", "fluid-turret", "artillery-turret"}

local function type_filters(types)
	local filters = {}
	for _, name in ipairs(types) do filters[#filters + 1] = {filter = "type", type = name} end
	return filters
end

function M.register()
	script.on_init(state)
	script.on_configuration_changed(function()
		local s = state()
		s.dying_turret_targets = nil -- 1.0.38 kept them forever when no ghost was created
		s.allow_pickup_rotations, s.initialized = nil, nil
	end)
	script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
		if string.find(event.setting, "heroturrets-", 1, true) == 1 then allow_ghost_rank = nil end
	end)

	if next(ladders) == nil then return end -- no ranked turrets were generated

	local turret_filters = type_filters(TURRET_TYPES)
	script.on_event(defines.events.on_entity_died, on_entity_died, type_filters(DIED_TYPES))
	script.on_event(defines.events.on_post_entity_died, on_post_entity_died, turret_filters)
	for _, id in ipairs({defines.events.on_built_entity, defines.events.on_robot_built_entity,
		defines.events.script_raised_built, defines.events.script_raised_revive}) do
		script.on_event(id, on_built, turret_filters)
	end
	if exact_counter then
		script.on_event(defines.events.on_player_mined_entity, on_mined, turret_filters)
		script.on_event(defines.events.on_robot_mined_entity, on_mined, turret_filters)
	end
	script.on_event(defines.events.on_player_setup_blueprint, on_player_setup_blueprint)
end

-- Interface for zzzparanoidal's demotion tool: a ranked turret becomes its base turret, kills and
-- damage start from zero (Beta 8). Returns the new turret or nil.
function M.demote(entity)
	if not (entity and entity.valid) then return nil end
	local info = ranked[entity.name]
	if not info then return nil end
	return replace_turret(entity, info.base, false)
end

return M
