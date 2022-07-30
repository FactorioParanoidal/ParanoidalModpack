Updates = {}

local function migrate_from_original_mod()
	for _, force in pairs(game.forces) do
		if force.technologies['factory-connection-type-circuit'].researched then
			force.recipes['factory-circuit-connector'].enabled = true
		end
	end
	for _, surface in pairs(game.surfaces) do
		for _, entity in pairs(surface.find_entities_filtered{name = {
			'factory-fluid-dummy-connector-' .. defines.direction.north,
			'factory-fluid-dummy-connector-' .. defines.direction.south,
			'factory-fluid-dummy-connector-' .. defines.direction.east,
			'factory-fluid-dummy-connector-' .. defines.direction.west,
			'factory-connection-indicator-belt-d0',
			'factory-connection-indicator-chest-d0',
			'factory-connection-indicator-chest-d10',
			'factory-connection-indicator-chest-d20',
			'factory-connection-indicator-chest-d60',
			'factory-connection-indicator-chest-d180',
			'factory-connection-indicator-chest-d600',
			'factory-connection-indicator-chest-b0',
			'factory-connection-indicator-chest-b10',
			'factory-connection-indicator-chest-b20',
			'factory-connection-indicator-chest-b60',
			'factory-connection-indicator-chest-b180',
			'factory-connection-indicator-chest-b600',
			'factory-connection-indicator-fluid-d0',
			'factory-connection-indicator-fluid-d5',
			'factory-connection-indicator-fluid-d10',
			'factory-connection-indicator-fluid-d30',
			'factory-connection-indicator-fluid-d120',
			'factory-overlay-controller',
			'factory-power-pole'
		}}) do
			entity.destroy()
		end
	end
end

Updates.init = function()
	global.update_version = 2
	migrate_from_original_mod()
end

local function fix_common_issues()
	for _, factory in pairs(global.factories) do
		-- Fix issues when forces are deleted
		if not factory.force.valid then
			factory.force = game.forces["player"]
		end
	end
end

Updates.run = function()
	fix_common_issues()
	if global.update_version == 1 and global.saved_factories then
		local changed = false
		local bad, good = {}, {}
		for name, factory in pairs(global.saved_factories) do
			if type(name) ~= 'number' then
				changed = true
				bad[#bad+1] = name
				good[#good+1] = factory
			end
		end
		for _, v in pairs(bad) do global.saved_factories[v] = nil end
		for _, v in pairs(good) do global.saved_factories[#global.saved_factories + 1] = v end
		if changed then game.print('Some factory items were deleted because of a Factorissimo update. Please use /give-lost-factory-buildings') end
	end
	global.update_version = 2
end
