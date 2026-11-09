local Public = {}

local warn_color = { r = 255, g = 90, b = 54 }

function Public.init_storage()
	storage.planets_lib = storage.planets_lib or {}

	storage.planets_lib.cargo_pods_seen_on_platforms = storage.planets_lib.cargo_pods_seen_on_platforms or {}
	storage.planets_lib.cargo_pod_canceled_whisper_ticks = storage.planets_lib.cargo_pod_canceled_whisper_ticks or {}
end

local cargo_drops_technology_names = {}
for _, planet in pairs(prototypes.space_location) do
	cargo_drops_technology_names[planet.name] = "planetslib-" .. planet.name .. "-cargo-drops"
end

local function pod_contents_is_allowed(pod_contents, planet_name)
	local whitelists = prototypes.mod_data.Planetslib.data.planet_cargo_drop_whitelists

	local old_whitelisted_names_all_planets = storage.planets_lib.whitelisted_names_all_planets or {}
	local old_whitelisted_names = storage.planets_lib.whitelisted_names or {}
	local old_whitelisted_types_all_planets = storage.planets_lib.whitelisted_types_all_planets or {}
	local old_whitelisted_types = storage.planets_lib.whitelisted_types or {}

	for _, item in pairs(pod_contents) do
		local entity = prototypes.entity[item.name]

		local whitelisted_by_item_name = whitelists.all.item_names[item.name]
			or (whitelists[planet_name] and whitelists[planet_name].item_names[item.name])

		local whitelisted_by_entity_type = entity
			and (
				whitelists.all.entity_types[entity.type]
				or (whitelists[planet_name] and whitelists[planet_name].entity_types[entity.type])
			)

		-- Check the legacy whitelist. An item is allowed when it is whitelisted
		-- by name or by entity type, either globally or for this planet.
		local old_whitelist_condition = old_whitelisted_names_all_planets[item.name]
			or (old_whitelisted_names[planet_name] and old_whitelisted_names[planet_name][item.name])
			or (
				entity
				and (
					old_whitelisted_types_all_planets[entity.type]
					or (old_whitelisted_types[planet_name] and old_whitelisted_types[planet_name][entity.type])
				)
			)

		if not whitelisted_by_item_name and not whitelisted_by_entity_type and not old_whitelist_condition then
			return false
		end
	end

	return true
end

local function warn_player_of_canceled_pod(player, platform, planet_name)
	if not (player and player.valid) then
		return false
	end
	if not (player.surface and player.surface.valid and platform.surface and platform.surface.valid) then
		return false
	end
	if player.surface.index ~= platform.surface.index then
		return false
	end

	local whisper_hash = platform.index .. "-" .. player.name

	local last_whisper_tick = storage.planets_lib.cargo_pod_canceled_whisper_ticks[whisper_hash]

	if (not last_whisper_tick) or (game.tick - last_whisper_tick >= 60 * 10) then
		player.print({
			"planetslib.cargo-pod-canceled",
			"[space-platform=" .. platform.index .. "]",
			"[technology=" .. "planetslib-" .. planet_name .. "-cargo-drops" .. "]",
		}, { color = warn_color })

		storage.planets_lib.cargo_pod_canceled_whisper_ticks[whisper_hash] = game.tick
		return true
	end
	return false
end

local function destroy_pod_on_platform(pod, platform, planet_name)
	local hub = platform.hub
	if hub and hub.valid then
		local pod_inventory = pod.get_inventory(defines.inventory.cargo_unit)
		local hub_inventory = hub.get_inventory(defines.inventory.hub_main)

		if pod_inventory and hub_inventory then
			for _, item in pairs(pod_inventory.get_contents()) do
				hub_inventory.insert(item)
			end
		end
	end

	for _, player in pairs(game.connected_players) do
		warn_player_of_canceled_pod(player, platform, planet_name)
	end

	local pod_unit_number = pod.unit_number

	pod.destroy()

	storage.planets_lib.cargo_pods_seen_on_platforms[pod_unit_number] = nil
end

local function prune_stale_cargo_pods()
	for unit_number, entry in pairs(storage.planets_lib.cargo_pods_seen_on_platforms) do
		if not (entry.entity and entry.entity.valid) then
			storage.planets_lib.cargo_pods_seen_on_platforms[unit_number] = nil
		end
	end
end

local function examine_cargo_pods(platform, planet_name)
	prune_stale_cargo_pods()

	local cargo_pods = platform.surface.find_entities_filtered({ type = "cargo-pod" })

	if #cargo_pods == 0 then
		return
	end

	for _, pod in pairs(cargo_pods) do
		local destination = pod and pod.valid and pod.cargo_pod_destination
		local destination_planet_name = nil

		if destination then
			if destination.surface and destination.surface.planet then
				destination_planet_name = destination.surface.planet.name
			elseif
				destination.station
				and destination.station.valid
				and destination.station.surface
				and destination.station.surface.planet
				and destination.station.surface.planet.valid
			then
				destination_planet_name = destination.station.surface.planet.name
			end
		end

		if
			destination_planet_name == planet_name
			and not storage.planets_lib.cargo_pods_seen_on_platforms[pod.unit_number]
		then
			local pod_contents = pod.get_inventory(defines.inventory.cargo_unit).get_contents()

			local has_only_allowed_cargo = pod_contents_is_allowed(pod_contents, planet_name)

			local nearby_hubs = platform.surface.find_entities_filtered({
				name = { "space-platform-hub", "cargo-bay" },
				position = pod.position,
				radius = 4,
			})

			local launched_from_platform = #nearby_hubs > 0

			storage.planets_lib.cargo_pods_seen_on_platforms[pod.unit_number] = {
				launched_from_platform = launched_from_platform,
				entity = pod,
				platform_index = platform.index,
			}

			if launched_from_platform and not has_only_allowed_cargo then
				destroy_pod_on_platform(pod, platform, planet_name)
			end
		end
	end
end

-- Exposed for the test-only seams registered in control.lua when FUnit is
-- active. This is purely additive; the locals remain the single implementation
-- and are still used internally, so behaviour is unchanged.
Public.pod_contents_is_allowed = pod_contents_is_allowed
Public.examine_cargo_pods = examine_cargo_pods
Public.warn_player_of_canceled_pod = warn_player_of_canceled_pod

function Public.on_cargo_pod_started_ascending(event)
	local cargo_pod = event.cargo_pod
	if not (cargo_pod and cargo_pod.valid) then
		return
	end

	local surface = cargo_pod.surface
	if not (surface and surface.valid) then
		return
	end

	local platform = surface.platform
	if not (platform and platform.valid) then
		return
	end

	local planet_name = nil
	if platform.space_location and platform.space_location.valid and platform.space_location.name then
		planet_name = platform.space_location.name
	end

	if not planet_name then
		return
	end

	local force = cargo_pod.force
	if not (force and force.valid) then
		return
	end

	local cargo_drops_tech = force.technologies[cargo_drops_technology_names[planet_name]]

	if (not cargo_drops_tech) or cargo_drops_tech.researched then
		return
	end

	local has_nothing_effect = false
	for _, effect in pairs(cargo_drops_tech.prototype.effects) do
		if effect.type == "nothing" then
			has_nothing_effect = true
			break
		end
	end

	if not has_nothing_effect then
		return
	end

	examine_cargo_pods(platform, planet_name)
end

-- Deprecated whitelist API, not sure if we'll ever remove it?
remote.add_interface("planetslib", {
	add_to_cargo_drop_item_name_whitelist = function(name, planet_name)
		if type(name) ~= "string" then
			error("name must be a string")
		end

		if planet_name then
			if not storage.planets_lib.whitelisted_names then
				storage.planets_lib.whitelisted_names = {}
			end

			if not storage.planets_lib.whitelisted_names[planet_name] then
				storage.planets_lib.whitelisted_names[planet_name] = {}
			end
			storage.planets_lib.whitelisted_names[planet_name][name] = true
		else
			if not storage.planets_lib.whitelisted_names_all_planets then
				storage.planets_lib.whitelisted_names_all_planets = {}
			end

			storage.planets_lib.whitelisted_names_all_planets[name] = true
		end
	end,
	remove_from_cargo_drop_item_name_whitelist = function(name, planet_name)
		if type(name) ~= "string" then
			error("name must be a string")
		end
		if planet_name then
			if not storage.planets_lib.whitelisted_names then
				storage.planets_lib.whitelisted_names = {}
			end

			if not storage.planets_lib.whitelisted_names[planet_name] then
				storage.planets_lib.whitelisted_names[planet_name] = {}
			end
			storage.planets_lib.whitelisted_names[planet_name][name] = nil
		else
			if not storage.planets_lib.whitelisted_names_all_planets then
				storage.planets_lib.whitelisted_names_all_planets = {}
			end
			storage.planets_lib.whitelisted_names_all_planets[name] = nil
		end
	end,
	add_to_cargo_drop_item_type_whitelist = function(type_name, planet_name)
		if type(type_name) ~= "string" then
			error("type_name must be a string")
		end
		if planet_name then
			if not storage.planets_lib.whitelisted_types then
				storage.planets_lib.whitelisted_types = {}
			end

			if not storage.planets_lib.whitelisted_types[planet_name] then
				storage.planets_lib.whitelisted_types[planet_name] = {}
			end
			storage.planets_lib.whitelisted_types[planet_name][type_name] = true
		else
			if not storage.planets_lib.whitelisted_types_all_planets then
				storage.planets_lib.whitelisted_types_all_planets = {}
			end
			storage.planets_lib.whitelisted_types_all_planets[type_name] = true
		end
	end,
	remove_from_cargo_drop_item_type_whitelist = function(type_name, planet_name)
		if type(type_name) ~= "string" then
			error("type_name must be a string")
		end
		if planet_name then
			if not storage.planets_lib.whitelisted_types then
				storage.planets_lib.whitelisted_types = {}
			end

			if not storage.planets_lib.whitelisted_types[planet_name] then
				storage.planets_lib.whitelisted_types[planet_name] = {}
			end
			storage.planets_lib.whitelisted_types[planet_name][type_name] = nil
		else
			if not storage.planets_lib.whitelisted_types_all_planets then
				storage.planets_lib.whitelisted_types_all_planets = {}
			end
			storage.planets_lib.whitelisted_types_all_planets[type_name] = nil
		end
	end,
})

return Public
