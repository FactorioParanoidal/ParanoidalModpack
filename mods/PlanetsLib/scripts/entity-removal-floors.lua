--- Runtime implementation of PlanetsLib entity removal floors.
---
--- Ported from the lunar-rock removal mechanic in "Muluna, Moon of Nauvis".
--- Rules are configured in data stage with
--- PlanetsLib.assign_entity_removal_floor() and stored in the Planetslib
--- mod-data prototype. This module only reads that mod-data, so it stays out of
--- the data stage entirely.
-- @module scripts.entity-removal-floors

local Public = {}

local DEFAULT_WAITING_MESSAGE = { "planetslib.entity-removal-floor-waiting" }
local TILE_GHOST_NAME = "tile-ghost"
local RECHECK_RADIUS = 6

-- Must match the supported list in lib/entity-removal-floors.lua.
local SUPPORTED_ENTITY_TYPES = {
	["simple-entity"] = true,
	["plant"] = true,
	["tree"] = true,
	["container"] = true,
}

local rules_by_planet = {}
local entity_names_by_planet = {}
local enabled = false

--== Rule index ==--

local function normalize_entity_names(entities)
	local names = {}
	if type(entities) == "string" then
		names[entities] = true
	elseif type(entities) == "table" then
		for key, value in pairs(entities) do
			if type(key) == "number" then
				if type(value) == "string" then
					names[value] = true
				end
			elseif value then
				names[key] = true
			end
		end
	end
	return names
end

local function build_rule_index()
	rules_by_planet = {}
	entity_names_by_planet = {}

	local constants = PlanetsLib.constants.entity_removal_floors or {}
	for planet_name, planet_rules in pairs(constants) do
		if type(planet_rules) == "table" then
			local by_entity = {}
			local entity_names = {}

			local function add(entity_name, config)
				if type(entity_name) ~= "string" or type(config) ~= "table" then
					return
				end
				local entity_prototype = prototypes.entity[entity_name]
				if not entity_prototype then
					log(
						"[PlanetsLib] Ignoring entity removal floor rule for "
							.. planet_name
							.. "/"
							.. entity_name
							.. ": entity prototype not found."
					)
					return
				end
				if not SUPPORTED_ENTITY_TYPES[entity_prototype.type] then
					log(
						"[PlanetsLib] Ignoring entity removal floor rule for "
							.. planet_name
							.. "/"
							.. entity_name
							.. ": entity type is not supported ("
							.. tostring(entity_prototype.type)
							.. ")."
					)
					return
				end
				if type(config.default_tile) ~= "string" then
					log(
						"[PlanetsLib] Ignoring entity removal floor rule for "
							.. planet_name
							.. "/"
							.. entity_name
							.. ": default_tile is missing."
					)
					return
				end
				local tile = prototypes.tile[config.default_tile]
				if not tile then
					log(
						"[PlanetsLib] Ignoring entity removal floor rule for "
							.. planet_name
							.. "/"
							.. entity_name
							.. ": tile not found: "
							.. config.default_tile
					)
					return
				end
				if tile.destroys_dropped_items then
					log(
						"[PlanetsLib] Ignoring entity removal floor rule for "
							.. planet_name
							.. "/"
							.. entity_name
							.. ": default tile destroys dropped items: "
							.. config.default_tile
					)
					return
				end

				local default_tile_item = config.default_tile_item
				if default_tile_item and not prototypes.item[default_tile_item] then
					log(
						"[PlanetsLib] Entity removal floor rule for "
							.. planet_name
							.. "/"
							.. entity_name
							.. " references a missing item ("
							.. tostring(default_tile_item)
							.. "); tile-item fallback is disabled."
					)
					default_tile_item = nil
				end

				by_entity[entity_name] = {
					default_tile = config.default_tile,
					default_tile_item = default_tile_item,
					waiting_message = config.waiting_message or DEFAULT_WAITING_MESSAGE,
				}
				entity_names[entity_name] = true
			end

			-- Accept the canonical per-entity shape, a single rule stored directly
			-- on the planet, and the grouped rule form so that mods can write
			-- rules directly into the mod-data table.
			if planet_rules.default_tile ~= nil then
				for entity_name in pairs(normalize_entity_names(planet_rules.entities)) do
					add(entity_name, planet_rules)
				end
			else
				for key, value in pairs(planet_rules) do
					if type(value) == "table" then
						if value.default_tile ~= nil and value.entities ~= nil then
							for entity_name in pairs(normalize_entity_names(value.entities)) do
								add(entity_name, value)
							end
						elseif value.default_tile ~= nil then
							add(key, value)
						end
					end
				end
			end

			if next(by_entity) then
				rules_by_planet[planet_name] = by_entity
				entity_names_by_planet[planet_name] = entity_names
			end
		end
	end

	enabled = next(rules_by_planet) ~= nil
end

local function get_rule(entity)
	if not (entity and entity.valid) then
		return nil
	end
	local surface = entity.surface
	local planet = surface and surface.valid and surface.planet
	local rules = planet and rules_by_planet[planet.name]
	return rules and rules[entity.name]
end

local function is_eligible(entity)
	local rule = get_rule(entity)
	if not rule or not SUPPORTED_ENTITY_TYPES[entity.type] then
		return nil
	end
	return rule
end

---Whether any entity removal floors are configured. Used by control.lua to skip
---event registration entirely when the feature is unused.
-- @return boolean
function Public.is_enabled()
	return enabled
end

---Returns entity name filters for on_marked_for_deconstruction.
-- @return table
function Public.get_entity_filters()
	local filters = {}
	local seen = {}
	for _, entity_names in pairs(entity_names_by_planet) do
		for entity_name in pairs(entity_names) do
			if not seen[entity_name] then
				seen[entity_name] = true
				filters[#filters + 1] = { filter = "name", name = entity_name }
			end
		end
	end
	return filters
end

--== Storage ==--

local function ensure_storage()
	storage.entity_removal_floors = storage.entity_removal_floors or {}
	storage.entity_removal_floors.queued = storage.entity_removal_floors.queued or {}
	storage.entity_removal_floors.queued_next_index = storage.entity_removal_floors.queued_next_index or 1
	storage.entity_removal_floors.tiles = storage.entity_removal_floors.tiles or {}
	storage.entity_removal_floors.cleanup = storage.entity_removal_floors.cleanup or {}
	storage.entity_removal_floors.cleanup_next_index = storage.entity_removal_floors.cleanup_next_index or 1
end

local function storage_state()
	return storage.entity_removal_floors
end

local function tile_key(x, y)
	return tostring(x) .. ":" .. tostring(y)
end

local function player_from_index(player_index)
	if not player_index then
		return nil
	end
	local player = game.get_player(player_index)
	if player and player.valid then
		return player
	end
	return nil
end

--== Footprint analysis ==--

---Returns the whole-tile footprint of an entity as left, right, top, bottom.
-- Entities may be placed off-grid, so use the entity's nominal footprint
-- instead of its raw bounding box, which can clip an extra tile by a fraction.
-- @param entity LuaEntity
-- @return number, number, number, number
local function get_floor_bounds(entity)
	local bounding_box = entity.bounding_box
	if not bounding_box then
		local x = math.floor(entity.position.x)
		local y = math.floor(entity.position.y)
		return x, x, y, y
	end

	local tile_width = math.max(1, math.ceil(bounding_box.right_bottom.x - bounding_box.left_top.x))
	local tile_height = math.max(1, math.ceil(bounding_box.right_bottom.y - bounding_box.left_top.y))
	local center_x = (bounding_box.left_top.x + bounding_box.right_bottom.x) / 2
	local center_y = (bounding_box.left_top.y + bounding_box.right_bottom.y) / 2
	local footprint_left = math.floor(center_x - (tile_width - 1) / 2)
	local footprint_top = math.floor(center_y - (tile_height - 1) / 2)

	return footprint_left,
		footprint_left + tile_width - 1,
		footprint_top,
		footprint_top + tile_height - 1
end

---Returns the list of footprint tiles whose prototype destroys dropped items.
-- @param entity LuaEntity
-- @return table, boolean
local function analyse_floor(entity)
	local surface = entity.surface
	local left, right, top, bottom = get_floor_bounds(entity)
	local unsafe = {}
	local all_safe = true

	for x = left, right do
		for y = top, bottom do
			local tile = surface.get_tile(x, y)
			if not tile or not tile.valid or tile.prototype.destroys_dropped_items then
				all_safe = false
				unsafe[#unsafe + 1] = {
					x = x,
					y = y,
					key = tile_key(x, y),
				}
			end
		end
	end

	return unsafe, all_safe
end

--== Replacement tile selection ==--

local function has_stationary_roboport_coverage(surface, force, position)
	if not surface or not surface.valid or not force then
		return false
	end

	for _, network in pairs(surface.find_logistic_networks_by_construction_area(position, force)) do
		for _, cell in pairs(network.cells) do
			if cell.valid and not cell.mobile and cell.is_in_construction_range(position) then
				return true
			end
		end
	end
	return false
end

---Whether a tile ghost of the given tile can be built at a tile position.
-- Uses the engine's own tile build check so tile conditions and collision masks
-- match what construction robots will actually be able to build.
-- @param surface LuaSurface
-- @param tile_name string
-- @param x number
-- @param y number
-- @return boolean
local function tile_can_be_built(surface, tile_name, x, y)
	if not surface or not surface.valid or not prototypes.tile[tile_name] then
		return false
	end
	return surface.can_place_entity({
		name = TILE_GHOST_NAME,
		inner_name = tile_name,
		position = { x + 0.5, y + 0.5 },
	})
end

-- Safe tiles that have at least one placing item. Used as a last-resort
-- fallback when neither the rule's default tile nor an inventory tile can be
-- built on a particular footprint tile.
local all_placeable_safe_tiles
local function get_all_placeable_safe_tiles()
	if all_placeable_safe_tiles then
		return all_placeable_safe_tiles
	end
	local result = {}
	for tile_name, tile in pairs(prototypes.tile or {}) do
		if
			not tile.destroys_dropped_items
			and tile.items_to_place_this
			and #tile.items_to_place_this > 0
		then
			result[#result + 1] = tile_name
		end
	end
	table.sort(result)
	all_placeable_safe_tiles = result
	return result
end

---Selects a buildable tile for one unsafe footprint tile.
-- Character players outside a stationary roboport network can fall back to
-- another tile item in their inventory when they do not carry enough of the
-- rule's default tile item. A candidate is only selected when the optional
-- buildability check accepts it.
-- @param contents table Inventory contents (ItemStackDefinition[]).
-- @param default_item_count number Amount of the rule's default tile item held.
-- @param required_count number Number of unsafe tiles to cover.
-- @param in_stationary_roboport_range boolean
-- @param is_character boolean
-- @param default_tile string
-- @param default_tile_item string|nil
-- @param is_tile_buildable function|nil Optional function(tile_name) -> boolean.
-- @return string
local function select_replacement_tile(
	contents,
	default_item_count,
	required_count,
	in_stationary_roboport_range,
	is_character,
	default_tile,
	default_tile_item,
	is_tile_buildable
)
	local required = math.max(1, required_count)
	local function buildable(tile_name)
		return not is_tile_buildable or is_tile_buildable(tile_name)
	end

	local can_use_default = (not is_character or in_stationary_roboport_range or not default_tile_item)
		or default_item_count >= required
	if can_use_default and buildable(default_tile) then
		return default_tile
	end

	local fallback
	for _, item in ipairs(contents or {}) do
		if item.count and item.count > 0 and item.name ~= default_tile_item then
			local prototype = prototypes.item[item.name]
			local placement = prototype and prototype.place_as_tile_result
			if placement and placement.result then
				local tile = type(placement.result) == "string"
						and prototypes.tile[placement.result]
					or placement.result
				local tile_name = tile and tile.name
				if
					tile_name
					and tile_name ~= default_tile
					and not tile.destroys_dropped_items
					and buildable(tile_name)
				then
					if item.count >= required then
						return tile_name
					end
					if not fallback then
						fallback = tile_name
					end
				end
			end
		end
	end
	if fallback then
		return fallback
	end
	-- Prefer the configured default as the last resort when it is buildable,
	-- even if the player does not carry enough of its item yet.
	if buildable(default_tile) then
		return default_tile
	end

	-- The default tile may not be buildable on this particular footprint tile.
	-- Fall back to any safe tile that has a placing item and passes the engine's
	-- tile build check. This keeps the queued floor buildable even when the
	-- player does not carry the required replacement tile.
	for _, tile_name in ipairs(get_all_placeable_safe_tiles()) do
		if buildable(tile_name) then
			return tile_name
		end
	end

	return default_tile
end

local function choose_replacement_tiles(player, entity, unsafe, force_name, rule)
	local surface = entity.surface
	local contents = {}
	local default_item_count = 0
	local in_stationary_range = false
	local is_character = false

	if player and player.valid and player.controller_type == defines.controllers.character then
		local character = player.character
		local inventory = player.get_main_inventory()
		if character and character.valid and inventory then
			local force = game.forces[force_name] or player.force
			in_stationary_range = has_stationary_roboport_coverage(surface, force, entity.position)
			default_item_count = rule.default_tile_item and inventory.get_item_count(rule.default_tile_item) or 0
			contents = inventory.get_contents()
			is_character = true
		end
	end

	local replacements = {}
	local first
	for _, tile in ipairs(unsafe) do
		local tile_name = select_replacement_tile(
			contents,
			default_item_count,
			#unsafe,
			in_stationary_range,
			is_character,
			rule.default_tile,
			rule.default_tile_item,
			function(candidate)
				return tile_can_be_built(surface, candidate, tile.x, tile.y)
			end
		)
		replacements[tile.key] = tile_name
		first = first or tile_name
	end
	return replacements, first
end

--== Queue bookkeeping ==--

local function add_inverted_tile(surface_index, x, y, index)
	local by_surface = storage_state().tiles[surface_index]
	if not by_surface then
		by_surface = {}
		storage_state().tiles[surface_index] = by_surface
	end

	local by_x = by_surface[x]
	if not by_x then
		by_x = {}
		by_surface[x] = by_x
	end

	local by_y = by_x[y]
	if not by_y then
		by_y = {}
		by_x[y] = by_y
	end

	by_y[index] = true
end

local function remove_inverted_tile(surface_index, x, y, index)
	local by_surface = storage_state().tiles[surface_index]
	if not by_surface then
		return
	end
	local by_x = by_surface[x]
	if not by_x then
		return
	end
	local by_y = by_x[y]
	if not by_y then
		return
	end

	by_y[index] = nil
	if next(by_y) == nil then
		by_x[y] = nil
	end
	if next(by_x) == nil then
		by_surface[x] = nil
	end
	if next(by_surface) == nil then
		storage_state().tiles[surface_index] = nil
	end
end

local function queue_indices_at(surface_index, x, y)
	local by_surface = storage_state().tiles[surface_index]
	local by_x = by_surface and by_surface[x]
	return by_x and by_x[y] or nil
end

local function queue_uses_tile(surface_index, x, y)
	local by_surface = storage_state().tiles[surface_index]
	local by_x = by_surface and by_surface[x]
	local by_y = by_x and by_x[y]
	return by_y ~= nil and next(by_y) ~= nil
end

local function ensure_tile_ghost(surface, x, y, force_name, tile_name)
	local tile = surface.get_tile(x, y)
	if not tile or not tile.valid or not tile.prototype.destroys_dropped_items then
		return nil
	end
	for _, ghost in pairs(tile.get_tile_ghosts(force_name)) do
		if ghost.valid and ghost.ghost_name == tile_name then
			return false
		end
	end

	return surface.create_entity({
		name = TILE_GHOST_NAME,
		inner_name = tile_name,
		position = { x + 0.5, y + 0.5 },
		force = force_name,
	})
end

local function remove_created_ghosts(entry)
	for _, created in pairs(entry.created_ghosts or {}) do
		if not queue_uses_tile(entry.surface_index, created.x, created.y) then
			local ghost = created.ghost
			local tile_name = created.name or entry.replacement_tile
			if ghost and ghost.valid and ghost.ghost_name == tile_name then
				ghost.destroy({ raise_destroy = true })
			end
		end
	end
end

local function cleanup_entry(index)
	local entry = storage_state().queued[index]
	if not entry then
		return
	end

	for _, tile in pairs(entry.tiles or {}) do
		remove_inverted_tile(entry.surface_index, tile.x, tile.y, index)
	end
	storage_state().queued[index] = nil
	remove_created_ghosts(entry)
end

local function find_queue_index(entity)
	if not entity or not entity.valid then
		return nil
	end

	for index, entry in pairs(storage_state().queued or {}) do
		local queued = entry.entity
		if queued and queued.valid then
			if queued == entity then
				return index
			end
			if
				entry.surface_index == entity.surface_index
				and entry.position
				and entry.position.x == entity.position.x
				and entry.position.y == entity.position.y
			then
				return index
			end
		end
	end

	return nil
end

--== Deconstruction handling ==--

local function find_deconstruction_force(entity)
	if not entity or not entity.valid then
		return nil
	end

	for _, force in pairs(game.forces) do
		if entity.is_registered_for_deconstruction(force) then
			return force
		end
	end

	local last_user = entity.last_user
	if last_user and last_user.valid then
		return last_user.force
	end

	return entity.force
end

local function cancel_entity_deconstruction(entity, force_name, player)
	if not entity or not entity.valid then
		return
	end
	entity.cancel_deconstruction(force_name or entity.force.name, player)
end

local function cancel_all_deconstruction(entity)
	if not entity or not entity.valid then
		return
	end

	for _, force in pairs(game.forces) do
		if entity.valid and entity.is_registered_for_deconstruction(force) then
			cancel_entity_deconstruction(entity, force.name, nil)
		end
	end
end

local function cancel_marked_entity(entity)
	if not entity or not entity.valid then
		return
	end

	local last_user = entity.last_user
	if last_user and last_user.valid then
		cancel_entity_deconstruction(entity, last_user.force.name, last_user)
	end

	if entity.valid and entity.to_be_deconstructed() then
		cancel_all_deconstruction(entity)
	end
end

local function warning_message(entity, rule, tile_name)
	local message = rule.waiting_message or DEFAULT_WAITING_MESSAGE
	if type(message) == "table" and message[1] == DEFAULT_WAITING_MESSAGE[1] then
		return {
			message[1],
			{ "entity-name." .. entity.name },
			{ "tile-name." .. (tile_name or rule.default_tile) },
		}
	end
	return message
end

local function warn_waiting_for_floor(entity, player, force_name, rule, tile_name)
	local message = warning_message(entity, rule, tile_name)
	if player and player.valid then
		player.create_local_flying_text({
			text = message,
			create_at_cursor = true,
		})
	elseif entity and entity.valid then
		local force = game.forces[force_name] or entity.force
		force.print(message)
	end
end

local function queue_entity(entity, rule, force_name, player_index, replacement_tiles, first_replacement)
	local surface = entity.surface
	local unsafe, all_safe = analyse_floor(entity)
	if all_safe then
		return nil
	end

	local index = storage_state().queued_next_index
	storage_state().queued_next_index = index + 1

	local entry = {
		entity = entity,
		surface_index = surface.index,
		position = { x = entity.position.x, y = entity.position.y },
		planet = surface.planet and surface.planet.name,
		entity_name = entity.name,
		force = force_name or entity.force.name,
		player_index = player_index,
		replacement_tile = first_replacement
			or (type(replacement_tiles) == "string" and replacement_tiles)
			or rule.default_tile,
		replacement_tiles = {},
		default_tile = rule.default_tile,
		waiting_message = rule.waiting_message or DEFAULT_WAITING_MESSAGE,
		tiles = {},
		remaining = {},
		created_ghosts = {},
		built_by = {},
	}
	storage_state().queued[index] = entry

	local left, right, top, bottom = get_floor_bounds(entity)
	for x = left, right do
		for y = top, bottom do
			local key = tile_key(x, y)
			entry.tiles[key] = { x = x, y = y }
			add_inverted_tile(surface.index, x, y, index)
		end
	end

	for _, tile in ipairs(unsafe) do
		local tile_name = type(replacement_tiles) == "string" and replacement_tiles
			or (type(replacement_tiles) == "table" and replacement_tiles[tile.key])
			or rule.default_tile
		entry.replacement_tiles[tile.key] = tile_name
		entry.remaining[tile.key] = { x = tile.x, y = tile.y }
		local ghost = ensure_tile_ghost(surface, tile.x, tile.y, entry.force, tile_name)
		if ghost then
			entry.created_ghosts[tile.key] = {
				ghost = ghost,
				x = tile.x,
				y = tile.y,
				name = tile_name,
			}
		end
	end

	return index
end

local function reissue_deconstruction(entry)
	local entity = entry.entity
	if not entity or not entity.valid then
		return
	end

	local force = game.forces[entry.force] or entity.force
	local player = player_from_index(entry.player_index)
	entity.order_deconstruction(force, player)
end

local function create_pending_tile_cleanup(entry)
	local entity = entry.entity
	if not entity or not entity.valid then
		return
	end

	local surface = entity.surface
	local tiles = {}
	for key, builder in pairs(entry.built_by or {}) do
		if builder == "robot" then
			local created = entry.created_ghosts and entry.created_ghosts[key]
			if created then
				local tile_name = created.name
					or (entry.replacement_tiles and entry.replacement_tiles[key])
					or entry.replacement_tile
				local tile = surface.get_tile(created.x, created.y)
				if tile and tile.valid and tile.name == tile_name then
					tiles[#tiles + 1] = { x = created.x, y = created.y, name = tile_name }
				end
			end
		end
	end

	if #tiles == 0 then
		return
	end

	local left, right, top, bottom = get_floor_bounds(entity)
	local index = storage_state().cleanup_next_index
	storage_state().cleanup_next_index = index + 1
	storage_state().cleanup[index] = {
		entity = entity,
		surface_index = entry.surface_index,
		force = entry.force,
		tile_name = tiles[1] and tiles[1].name or entry.replacement_tile,
		area = {
			{ left, top },
			{ right + 1, bottom + 1 },
		},
		tiles = tiles,
		state = "waiting_entity",
	}
end

local function order_cleanup_tiles(pending)
	local surface = game.surfaces[pending.surface_index]
	if not surface or not surface.valid then
		return {}
	end

	local force = game.forces[pending.force]
	local remaining = {}
	for _, tile_position in pairs(pending.tiles or {}) do
		local tile = surface.get_tile(tile_position.x, tile_position.y)
		local tile_name = tile_position.name or pending.tile_name
		if tile and tile.valid and tile.name == tile_name then
			if queue_uses_tile(pending.surface_index, tile_position.x, tile_position.y) then
				remaining[#remaining + 1] = tile_position
			elseif force and not tile.to_be_deconstructed(force) then
				tile.order_deconstruction(force)
			end
		end
	end
	return remaining
end

local function process_pending_tile_cleanup()
	ensure_storage()
	for index, pending in pairs(storage_state().cleanup) do
		local entity = pending.entity
		if pending.state == "waiting_entity" then
			if not entity or not entity.valid then
				pending.state = "waiting_items"
				pending.wait_until = game.tick + 30
			end
		end

		if pending.state == "waiting_items" and game.tick >= (pending.wait_until or 0) then
			local surface = game.surfaces[pending.surface_index]
			if not surface or not surface.valid then
				storage_state().cleanup[index] = nil
			else
				local items = surface.find_entities_filtered({
					name = "item-on-ground",
					area = pending.area,
				})
				local has_items = false
				for _, item in pairs(items) do
					if item.valid then
						has_items = true
						break
					end
				end

				if not has_items then
					local remaining = order_cleanup_tiles(pending)
					if #remaining == 0 then
						storage_state().cleanup[index] = nil
					else
						pending.tiles = remaining
					end
				end
			end
		end
	end
end

local function refresh_queue_entry(index)
	local entry = storage_state().queued[index]
	if not entry then
		return
	end

	local entity = entry.entity
	if not entity or not entity.valid then
		cleanup_entry(index)
		return
	end

	local surface = entity.surface
	if not surface or not surface.valid then
		cleanup_entry(index)
		return
	end

	local unsafe, all_safe = analyse_floor(entity)
	if all_safe then
		create_pending_tile_cleanup(entry)
		cleanup_entry(index)
		reissue_deconstruction(entry)
		return
	end

	entry.remaining = {}
	entry.created_ghosts = entry.created_ghosts or {}
	entry.replacement_tiles = entry.replacement_tiles or {}
	for _, tile in ipairs(unsafe) do
		local tile_name = entry.replacement_tiles[tile.key]
			or entry.replacement_tile
			or entry.default_tile
		entry.replacement_tiles[tile.key] = tile_name
		entry.remaining[tile.key] = { x = tile.x, y = tile.y }
		local ghost = ensure_tile_ghost(surface, tile.x, tile.y, entry.force, tile_name)
		if ghost then
			entry.created_ghosts[tile.key] = {
				ghost = ghost,
				x = tile.x,
				y = tile.y,
				name = tile_name,
			}
		end
	end
end

local function refresh_queue_entries_at(surface_index, position)
	local by_surface = storage_state().tiles[surface_index]
	if not by_surface then
		return
	end
	local by_x = by_surface[position.x]
	if not by_x then
		return
	end
	local by_y = by_x[position.y]
	if not by_y then
		return
	end

	local indices = {}
	for index in pairs(by_y) do
		indices[#indices + 1] = index
	end
	for _, index in ipairs(indices) do
		refresh_queue_entry(index)
	end
end

local function cancel_marked_entities_near(surface, position)
	local planet = surface.planet
	local entity_names = planet and entity_names_by_planet[planet.name]
	if not entity_names then
		return
	end

	local names = {}
	for entity_name in pairs(entity_names) do
		names[#names + 1] = entity_name
	end
	if #names == 0 then
		return
	end

	local radius = RECHECK_RADIUS
	local entities = surface.find_entities_filtered({
		area = {
			{ position.x - radius, position.y - radius },
			{ position.x + radius + 1, position.y + radius + 1 },
		},
		name = names,
		to_be_deconstructed = true,
	})

	for _, entity in pairs(entities) do
		if is_eligible(entity) then
			local _, all_safe = analyse_floor(entity)
			if not all_safe then
				cancel_marked_entity(entity)
			end
		end
	end
end

local function record_ghost_builders(event, builder, surface)
	if not builder or not event.tiles then
		return
	end

	for _, tile in pairs(event.tiles) do
		local position = tile.position
		local tile_name
		if event.tile then
			tile_name = event.tile.name
		elseif surface then
			local current = surface.get_tile(position.x, position.y)
			tile_name = current and current.valid and current.name or nil
		end
		if tile_name then
			local key = tile_key(position.x, position.y)
			local indices = queue_indices_at(event.surface_index, position.x, position.y)
			for index in pairs(indices or {}) do
				local entry = storage_state().queued[index]
				local expected_tile = entry
					and entry.replacement_tiles
					and entry.replacement_tiles[key]
					or (entry and entry.replacement_tile)
				if
					entry
					and entry.created_ghosts
					and entry.created_ghosts[key]
					and expected_tile == tile_name
				then
					entry.built_by = entry.built_by or {}
					entry.built_by[key] = builder
				end
			end
		end
	end
end

local function on_tiles_changed(event, check_marked_entities, only_unsafe_tiles, builder)
	ensure_storage()
	Public.prune_invalid_entries()
	local surface = game.surfaces[event.surface_index]
	if not surface or not surface.valid then
		return
	end

	local planet = surface.planet
	local has_rules = planet and rules_by_planet[planet.name] ~= nil
	local has_queue = storage_state().tiles[surface.index] ~= nil
	if not has_rules and not has_queue then
		return
	end

	record_ghost_builders(event, builder, surface)

	for _, tile in pairs(event.tiles or {}) do
		local position = tile.position
		refresh_queue_entries_at(surface.index, position)

		if check_marked_entities then
			local current = surface.get_tile(position.x, position.y)
			if not only_unsafe_tiles or (current and current.valid and current.prototype.destroys_dropped_items) then
				cancel_marked_entities_near(surface, position)
			end
		end
	end
end

local function on_marked_for_deconstruction(event)
	ensure_storage()
	Public.prune_invalid_entries()
	local entity = event.entity
	local rule = is_eligible(entity)
	if not rule then
		return
	end

	local player = player_from_index(event.player_index)
	local deconstruction_force = player and player.force or find_deconstruction_force(entity)
	local force_name = deconstruction_force and deconstruction_force.name or entity.force.name
	local existing_index = find_queue_index(entity)

	if existing_index then
		cancel_entity_deconstruction(entity, force_name, player)
		if entity.valid and entity.to_be_deconstructed() then
			cancel_all_deconstruction(entity)
		end
		local existing_entry = storage_state().queued[existing_index]
		warn_waiting_for_floor(
			entity,
			player,
			force_name,
			rule,
			existing_entry and existing_entry.replacement_tile or nil
		)
		refresh_queue_entry(existing_index)
		return
	end

	local unsafe, all_safe = analyse_floor(entity)
	if all_safe then
		return
	end

	local replacement_tiles, replacement_tile = choose_replacement_tiles(player, entity, unsafe, force_name, rule)
	cancel_entity_deconstruction(entity, force_name, player)
	if entity.valid and entity.to_be_deconstructed() then
		cancel_all_deconstruction(entity)
	end
	queue_entity(entity, rule, force_name, event.player_index, replacement_tiles, replacement_tile)
end

local function apply_undo_actions(actions)
	ensure_storage()
	local removed = 0

	for _, action in pairs(actions or {}) do
		local target = action.target
		if target and target.name and target.position then
			local surface_index = action.surface_index
			for index, entry in pairs(storage_state().queued) do
				local entity = entry.entity
				if
					entity
					and entity.valid
					and entity.name == target.name
					and entity.position.x == target.position.x
					and entity.position.y == target.position.y
					and (not surface_index or entry.surface_index == surface_index)
				then
					cleanup_entry(index)
					removed = removed + 1
					break
				end
			end

			for pending_index, pending in pairs(storage_state().cleanup or {}) do
				local entity = pending.entity
				if
					entity
					and entity.valid
					and entity.name == target.name
					and entity.position.x == target.position.x
					and entity.position.y == target.position.y
					and (not surface_index or pending.surface_index == surface_index)
				then
					order_cleanup_tiles(pending)
					storage_state().cleanup[pending_index] = nil
				end
			end
		end
	end

	return removed
end

--== Event entry points ==--

---Initialises storage and builds the rule index.
function Public.on_init()
	build_rule_index()
	ensure_storage()
end

---Rebuilds the rule index and drops queue entries whose rule no longer exists.
-- @param configuration_changed_data table|nil
function Public.on_configuration_changed(configuration_changed_data)
	build_rule_index()
	ensure_storage()

	for index, entry in pairs(storage_state().queued) do
		local entity = entry.entity
		local rule = entity and entity.valid and get_rule(entity) or nil
		local valid_tiles = true
		if entry.replacement_tiles then
			for _, tile_name in pairs(entry.replacement_tiles) do
				if not prototypes.tile[tile_name] then
					valid_tiles = false
					break
				end
			end
		elseif not prototypes.tile[entry.replacement_tile] then
			valid_tiles = false
		end
		if not rule or not valid_tiles then
			cleanup_entry(index)
		end
	end

	for index, pending in pairs(storage_state().cleanup) do
		local valid = true
		for _, tile_position in pairs(pending.tiles or {}) do
			local tile_name = tile_position.name or pending.tile_name
			if not prototypes.tile[tile_name] then
				valid = false
				break
			end
		end
		if not valid then
			storage_state().cleanup[index] = nil
		end
	end
end

---Event handler for on_marked_for_deconstruction.
-- @param event table
function Public.on_marked_for_deconstruction(event)
	on_marked_for_deconstruction(event)
end

---Event handler for entity-built tile events.
-- @param event table
-- @param builder string "player" or "robot"
function Public.on_tile_built(event, builder)
	on_tiles_changed(event, false, nil, builder)
end

---Event handler for script_raised_set_tiles.
-- @param event table
function Public.on_script_raised_set_tiles(event)
	on_tiles_changed(event, true, true, nil)
end

---Event handler for tile-mined events.
-- @param event table
function Public.on_tile_mined(event)
	on_tiles_changed(event, true, false, nil)
end

---Event handler for on_undo_applied.
-- @param event table
function Public.on_undo_applied(event)
	return apply_undo_actions(event.actions)
end

---Periodic cleanup of temporary floor tiles built by construction robots.
function Public.process_pending_tile_cleanup()
	process_pending_tile_cleanup()
end

---Removes queue entries whose entity no longer exists.
function Public.prune_invalid_entries()
	ensure_storage()
	for index, entry in pairs(storage_state().queued) do
		if not entry.entity or not entry.entity.valid then
			cleanup_entry(index)
		end
	end
end

-- Build the index as soon as the module loads so control.lua can skip event
-- registration when nothing is configured.
build_rule_index()

--== Test-only seam helpers ==--
-- These are exposed through the planetslib_funit remote interface in control.lua.
-- They are inert unless FUnit is active.

function Public._test_get_floor_bounds(entity)
	return get_floor_bounds(entity)
end

function Public._test_analyse_floor(entity)
	return analyse_floor(entity)
end

function Public._test_has_stationary_roboport_coverage(surface, force, position)
	return has_stationary_roboport_coverage(surface, force, position)
end

function Public._test_select_replacement_tile(
	contents,
	default_item_count,
	required_count,
	in_stationary_roboport_range,
	is_character,
	default_tile,
	default_tile_item
)
	return select_replacement_tile(
		contents,
		default_item_count,
		required_count,
		in_stationary_roboport_range,
		is_character,
		default_tile,
		default_tile_item
	)
end

function Public._test_select_replacement_tile_for_tile(
	contents,
	default_item_count,
	required_count,
	in_stationary_roboport_range,
	is_character,
	default_tile,
	default_tile_item,
	surface_index,
	x,
	y
)
	local surface = game.surfaces[surface_index]
	if not surface or not surface.valid then
		return nil
	end
	return select_replacement_tile(
		contents,
		default_item_count,
		required_count,
		in_stationary_roboport_range,
		is_character,
		default_tile,
		default_tile_item,
		function(tile_name)
			return tile_can_be_built(surface, tile_name, x, y)
		end
	)
end

function Public._test_queue_entity(entity, force_name, player_index, replacement_tile)
	local rule = is_eligible(entity)
	if not rule then
		return nil
	end
	return queue_entity(entity, rule, force_name or entity.force.name, player_index, replacement_tile)
end

function Public._test_apply_undo_actions(actions)
	return apply_undo_actions(actions)
end

function Public._test_clear_surface_state(surface_index)
	ensure_storage()
	for index, entry in pairs(storage_state().queued) do
		if entry.surface_index == surface_index then
			cleanup_entry(index)
		end
	end
	for index, pending in pairs(storage_state().cleanup) do
		if pending.surface_index == surface_index then
			storage_state().cleanup[index] = nil
		end
	end
	storage_state().tiles[surface_index] = nil
end

function Public._test_get_queued(surface_index)
	ensure_storage()
	local result = {}
	for index, entry in pairs(storage_state().queued or {}) do
		if entry.surface_index == surface_index then
			result[#result + 1] = {
				index = index,
				entity = entry.entity,
				replacement_tile = entry.replacement_tile,
				replacement_tiles = entry.replacement_tiles,
				remaining = entry.remaining,
				created_ghosts = entry.created_ghosts,
				built_by = entry.built_by,
			}
		end
	end
	return result
end

function Public._test_get_cleanup(surface_index)
	ensure_storage()
	local result = {}
	for index, pending in pairs(storage_state().cleanup or {}) do
		if pending.surface_index == surface_index then
			result[#result + 1] = {
				index = index,
				entity = pending.entity,
				tile_name = pending.tile_name,
				tiles = pending.tiles,
				state = pending.state,
			}
		end
	end
	return result
end

return Public
