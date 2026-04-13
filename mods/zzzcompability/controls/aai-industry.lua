local version = 020073 -- 2.0.73

local util = require("utils.aai-industry-old-util")

local function init_crash_sequence()
	local surface = game.surfaces["nauvis"]
	local range = 20
	local trees = surface.find_entities_filtered({ type = "tree", area = { { -range, -range }, { range, range } } })
	for _, tree in pairs(trees) do
		local distance = math.sqrt(tree.position.x * tree.position.x + tree.position.y * tree.position.y)
		if math.random() > (distance / range) * 3 - 2 then
			if math.random() < 0.1 and distance > range / 2 then
			--surface.create_entity{name="fire-flame-on-tree", position = tree.position}
			else
				tree.destroy()
			end
		end
	end

	local create_list = {
		-- { names = { "rock-small" }, count = 30, radius = 10 },
		-- { names = { "rock-small" }, count = 30, radius = 20 },
		-- { names = { "rock-small" }, count = 30, radius = 40 },
		{ names = { "big-remnants" }, count = 5, radius = 15 },
		{ names = { "medium-remnants" }, count = 10, radius = 25 },
		{ names = { "small-remnants" }, count = 15, radius = 50 },
		{ names = { "aai-big-ship-wreck-1", "massive-explosion" }, count = 1, radius = 10 },
		{ names = { "aai-big-ship-wreck-2", "big-explosion" }, count = 1, radius = 10 },
		{ names = { "aai-big-ship-wreck-3" }, count = 3, radius = 10 },
		{ names = { "aai-medium-ship-wreck-1", "medium-explosion" }, count = 3, radius = 25 },
		{ names = { "aai-medium-ship-wreck-2" }, count = 3, radius = 25 },
		{ names = { "aai-small-ship-wreck" }, count = 30, radius = 50 },
		{ names = { "fire-flame-on-tree" }, count = 25, radius = 15, min_radius = 5 },
		{
			names = { "dead-dry-hairy-tree", "fire-flame-on-tree", "fire-flame-on-tree" },
			count = 10,
			radius = 20,
			min_radius = 5,
		},
	}
	local containers = {}
	for _, settings in pairs(create_list) do
		local min_radius = settings.min_radius or 0
		for i = 1, settings.count, 1 do
			local try_position =
				util.orientation_to_vector(math.random(), min_radius + (settings.radius - min_radius) * math.random())
			local safe_position =
				surface.find_non_colliding_position("aai-big-ship-wreck-1", try_position, settings.radius, 1)
			safe_position = safe_position or try_position
			for _, name in pairs(settings.names) do
				if name == "rock-small" then
					surface.create_decoratives({
						check_collision = false,
						decoratives = {
							{ name = name, position = safe_position, amount = math.ceil(math.random() * 7) },
						},
					})
				else
					local entity =
						surface.create_entity({ name = name, position = safe_position, force = game.forces["player"] })
					if name == "aai-big-ship-wreck-1" then
						entity.insert({ name = "burner-assembling-machine" })
					end
					if name == "aai-big-ship-wreck-2" then
						entity.insert({ name = "iron-plate", count = 6 })
					end
					if name == "aai-big-ship-wreck-3" then
						entity.insert({ name = "motor", count = 1 })
					end
					if entity.type == "container" then
						table.insert(containers, entity)
					end
				end
			end
		end
	end
	storage.starting_containers = containers
end

local function on_init()
	storage.version = version

	-- only run at the start

	if game.tick < 2 then
		init_crash_sequence()
	end
end

script.on_init(on_init)
script.on_event(defines.events.on_player_created, on_player_created)
