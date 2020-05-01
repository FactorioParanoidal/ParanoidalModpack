require("mod-gui")
function remote_doit(who, args)
	--remote.call("DeleteEmptyChunks", "getSurface")
	--remote.call("DeleteEmptyChunks", "getRadius")
	--remote.call("DeleteEmptyChunks", "getPaving")
	--remote.call("DeleteEmptyChunks", "DeleteEmptyChunks", {surface="nauvis", radius=0, paving=false})
	local target_surface = settings.global["DeleteEmptyChunks_surface"].value
	local radius = settings.global["DeleteEmptyChunks_radius"].value
	local keep_paving = settings.global["DeleteEmptyChunks_paving"].value
	if args.surface ~= nil then
		target_surface = args.surface
	end
	if args.radius ~= nil then
		radius = args.radius
	end
	if args.paving ~= nil then
		keep_paving = args.paving
	end
	doit(who, target_surface, radius, keep_paving)
end

function doit(who, target_surface, radius, keep_paving)
	-- Get list of possible paving
	local paving = {}
	local paving_base = {"stone-path", "concrete", "hazard-concrete-left", "hazard-concrete-right", "refined-concrete", "refined-hazard-concrete-left", "refined-hazard-concrete-right",
	                     "acid-refined-concrete", "black-refined-concrete", "blue-refined-concrete", "brown-refined-concrete", "cyan-refined-concrete", "green-refined-concrete",
	                     "orange-refined-concrete", "pink-refined-concrete", "purple-refined-concrete", "red-refined-concrete", "yellow-refined-concrete"}
	if keep_paving then
		paving = getPavingTiles()
		--log(table_to_csv(paving))
	end
	
	-- Get list of all player positions and forces
	local playerForceNames = {}
	local playerPositions = {}
	for _, player in pairs(game.players) do
		table.insert( playerForceNames, player.force.name )
		table.insert( playerPositions, {x = math.floor(player.position.x / 32), y = math.floor(player.position.y / 32)})
	end
	if #playerForceNames > 1 then printAll({'DeleteEmptyChunks_text_force', table_to_csv(playerForceNames)}) end

	-- Verify surface exists
	local surface = nil
	local surface_list = {}
	for _, candidate in pairs (game.surfaces) do
		table.insert( surface_list, candidate.name )
		if candidate.name == target_surface then
			surface = candidate
		end
	end
	--log(table_to_csv(surface_list))
	
	-- Let the players know what is happening
	if surface == nil and #surface_list > 0 then
		printAll({'DeleteEmptyChunks_text_mod_nosurface', target_surface, table_to_csv(surface_list)})
	else
		if #paving > 0 then
			if radius > 0 then
				printAll({'DeleteEmptyChunks_text_notifier_pr', who, radius})
			else
				printAll({'DeleteEmptyChunks_text_notifier_p', who})
			end
			printAll({'DeleteEmptyChunks_text_notifier_paving', #paving, #paving_base, #paving - #paving_base})
		else
			if radius > 0 then
				printAll({'DeleteEmptyChunks_text_notifier_r', who, radius})
			else
				printAll({'DeleteEmptyChunks_text_notifier', who})
			end
		end
		-- Perform chunk deletion on specified surface
		if surface ~= nil then
			-- First Pass
			local list = getKeepList(surface, playerForceNames, radius == 0 and 1 or 0, paving)
			-- Save players from the void
			for _, position in pairs(playerPositions) do
				if list.coordinates[position.x] == nil then
					list.coordinates[position.x]={}
				end
				list.coordinates[position.x][position.y]=1
			end
			-- Second Pass
			local result = deleteChunks(surface, list.coordinates, radius)
			-- Report results to all players
			printAll({'DeleteEmptyChunks_text_starting', list.total, surface.name, list.total - list.uncharted})
			if result.kept > 0 then
				if list.occupied > 0 then
					if list.paved > 0 then
						if result.adjacent > 0 then
							printAll({'DeleteEmptyChunks_text_keep_epa', result.kept, list.occupied, list.paved, result.adjacent})
						else
							printAll({'DeleteEmptyChunks_text_keep_ep', result.kept, list.occupied, list.paved})
						end
					else
						if result.adjacent > 0 then
							printAll({'DeleteEmptyChunks_text_keep_ea', result.kept, list.occupied, result.adjacent})
						else
							printAll({'DeleteEmptyChunks_text_keep_e', result.kept, list.occupied})
						end
					end
				elseif list.paved > 0 then
					if result.adjacent > 0 then
						printAll({'DeleteEmptyChunks_text_keep_pa', result.kept, list.paved, result.adjacent})
					else
						printAll({'DeleteEmptyChunks_text_keep_p', result.kept, list.paved})
					end
				end
			end
			printAll({'DeleteEmptyChunks_text_delete', result.deleted})
			if game.active_mods["rso-mod"] then
				remote.call("RSO", "disableStartingArea")
				remote.call("RSO", "resetGeneration", surface)
			end
		end
	end
end

function printAll(text)
	log(text)
	game.print(text)
end

function table_to_csv(list)
	local str = ""
	for _, item in pairs (list) do
		if string.len(str) > 0 then
			str = str .. "\", \"" .. item
		else
			str = "\"" .. item
		end
	end
	if string.len(str) > 0 then
		str = str .. "\""
	end
	return str
end

function getPavingTiles()
	local paving = {}
	local ground = {}
	-- Ignored tileset for "Base mod" as of 0.17.66
	-- Paving: {"stone-path", "concrete", "hazard-concrete-left", "hazard-concrete-right", "refined-concrete", "refined-hazard-concrete-left", "refined-hazard-concrete-right",
	--          "acid-refined-concrete", "black-refined-concrete", "blue-refined-concrete", "brown-refined-concrete", "cyan-refined-concrete", "green-refined-concrete",
	--          "orange-refined-concrete", "pink-refined-concrete", "purple-refined-concrete", "red-refined-concrete", "yellow-refined-concrete"}
	local Base_tiles = {"deepwater", "deepwater-green", "dirt-1", "dirt-2", "dirt-3", "dirt-4", "dirt-5",
	                    "dirt-6", "dirt-7", "dry-dirt", "grass-1", "grass-2", "grass-3", "grass-4", "lab-dark-1",
	                    "lab-dark-2", "lab-white", "out-of-map", "red-desert-0", "red-desert-1", "red-desert-2",
	                    "red-desert-3", "sand-1", "sand-2", "sand-3", "tutorial-grid", "water", "water-green",
	                    "landfill", "water-mud", "water-shallow"}
	for _, v in ipairs(Base_tiles) do
		table.insert(ground, v)
	end
	
	-- Ignored tileset for "Alien Biome" exported from 0.4.15
	-- Paving: none
	local AlienBiomes_tiles = {"frozen-snow-0", "frozen-snow-1", "frozen-snow-2", "frozen-snow-3", "frozen-snow-4", "frozen-snow-5", "frozen-snow-6", "frozen-snow-7", "frozen-snow-8", "frozen-snow-9",
	                           "mineral-aubergine-dirt-1", "mineral-aubergine-dirt-2", "mineral-aubergine-dirt-3", "mineral-aubergine-dirt-4", "mineral-aubergine-dirt-5", "mineral-aubergine-dirt-6",
	                           "mineral-aubergine-sand-1", "mineral-aubergine-sand-2", "mineral-aubergine-sand-3",
	                           "mineral-beige-dirt-1", "mineral-beige-dirt-2", "mineral-beige-dirt-3", "mineral-beige-dirt-4", "mineral-beige-dirt-5", "mineral-beige-dirt-6",
	                           "mineral-beige-sand-1", "mineral-beige-sand-2", "mineral-beige-sand-3",
	                           "mineral-black-dirt-1", "mineral-black-dirt-2", "mineral-black-dirt-3", "mineral-black-dirt-4", "mineral-black-dirt-5", "mineral-black-dirt-6",
	                           "mineral-black-sand-1", "mineral-black-sand-2", "mineral-black-sand-3",
	                           "mineral-brown-dirt-1", "mineral-brown-dirt-2", "mineral-brown-dirt-3", "mineral-brown-dirt-4", "mineral-brown-dirt-5", "mineral-brown-dirt-6",
	                           "mineral-brown-sand-1", "mineral-brown-sand-2", "mineral-brown-sand-3",
	                           "mineral-cream-dirt-1", "mineral-cream-dirt-2", "mineral-cream-dirt-3", "mineral-cream-dirt-4", "mineral-cream-dirt-5", "mineral-cream-dirt-6",
	                           "mineral-cream-sand-1", "mineral-cream-sand-2", "mineral-cream-sand-3",
	                           "mineral-dustyrose-dirt-1", "mineral-dustyrose-dirt-2", "mineral-dustyrose-dirt-3", "mineral-dustyrose-dirt-4", "mineral-dustyrose-dirt-5", "mineral-dustyrose-dirt-6",
	                           "mineral-dustyrose-sand-1", "mineral-dustyrose-sand-2", "mineral-dustyrose-sand-3",
	                           "mineral-grey-dirt-1", "mineral-grey-dirt-2", "mineral-grey-dirt-3", "mineral-grey-dirt-4", "mineral-grey-dirt-5", "mineral-grey-dirt-6",
	                           "mineral-grey-sand-1", "mineral-grey-sand-2", "mineral-grey-sand-3",
	                           "mineral-purple-dirt-1", "mineral-purple-dirt-2", "mineral-purple-dirt-3", "mineral-purple-dirt-4", "mineral-purple-dirt-5", "mineral-purple-dirt-6",
	                           "mineral-purple-sand-1", "mineral-purple-sand-2", "mineral-purple-sand-3",
	                           "mineral-red-dirt-1", "mineral-red-dirt-2", "mineral-red-dirt-3", "mineral-red-dirt-4", "mineral-red-dirt-5", "mineral-red-dirt-6",
	                           "mineral-red-sand-1", "mineral-red-sand-2", "mineral-red-sand-3",
	                           "mineral-tan-dirt-1", "mineral-tan-dirt-2", "mineral-tan-dirt-3", "mineral-tan-dirt-4", "mineral-tan-dirt-5", "mineral-tan-dirt-6",
	                           "mineral-tan-sand-1", "mineral-tan-sand-2", "mineral-tan-sand-3",
	                           "mineral-violet-dirt-1", "mineral-violet-dirt-2", "mineral-violet-dirt-3", "mineral-violet-dirt-4", "mineral-violet-dirt-5", "mineral-violet-dirt-6",
	                           "mineral-violet-sand-1", "mineral-violet-sand-2", "mineral-violet-sand-3",
	                           "mineral-white-dirt-1", "mineral-white-dirt-2", "mineral-white-dirt-3", "mineral-white-dirt-4", "mineral-white-dirt-5", "mineral-white-dirt-6",
	                           "mineral-white-sand-1", "mineral-white-sand-2", "mineral-white-sand-3",
	                           "vegetation-blue-grass-1", "vegetation-blue-grass-2",
	                           "vegetation-green-grass-1", "vegetation-green-grass-2", "vegetation-green-grass-3", "vegetation-green-grass-4",
	                           "vegetation-mauve-grass-1", "vegetation-mauve-grass-2",
	                           "vegetation-olive-grass-1", "vegetation-olive-grass-2",
	                           "vegetation-orange-grass-1", "vegetation-orange-grass-2",
	                           "vegetation-purple-grass-1", "vegetation-purple-grass-2",
	                           "vegetation-red-grass-1", "vegetation-red-grass-2",
	                           "vegetation-turquoise-grass-1", "vegetation-turquoise-grass-2",
	                           "vegetation-violet-grass-1", "vegetation-violet-grass-2",
	                           "vegetation-yellow-grass-1", "vegetation-yellow-grass-2",
	                           "volcanic-blue-heat-1", "volcanic-blue-heat-2", "volcanic-blue-heat-3", "volcanic-blue-heat-4",
	                           "volcanic-green-heat-1", "volcanic-green-heat-2", "volcanic-green-heat-3", "volcanic-green-heat-4",
	                           "volcanic-orange-heat-1", "volcanic-orange-heat-2", "volcanic-orange-heat-3", "volcanic-orange-heat-4",
	                           "volcanic-purple-heat-1", "volcanic-purple-heat-2", "volcanic-purple-heat-3", "volcanic-purple-heat-4"}
	if game.active_mods["alien-biomes"] then
		for _, v in ipairs(AlienBiomes_tiles) do
			table.insert(ground, v)
		end
	end
	
	-- Ignored tileset for "Space Exploration" exported from 0.1.137
	-- Paving:  {"se-space-platform-plating", "se-space-platform-scaffold", "se-spaceship-floor"}
	local SpaceExploration_tiles = {"se-asteroid", "se-regolith", "se-space"}
	if game.active_mods["space-exploration"] then
		for _, v in ipairs(SpaceExploration_tiles) do
			table.insert(ground, v)
		end
	end
	
	-- Ignored tileset for "Krastorio2" exported from 0.9.11
	-- Paving:  {"kr-black-reinforced-plate", "kr-white-reinforced-plate"}
	local Krastorio2_tiles = {"kr-creep"}
	if game.active_mods["Krastorio2"] then
		for _, v in ipairs(Krastorio2_tiles) do
			table.insert(ground, v)
		end
	end
	
	for _, t in pairs(game.tile_prototypes) do
		local found = false
		for _, s in pairs(ground) do
			if t.name == s then
				found = true
				break
			end
		end
		if not found then
			table.insert(paving, t.name)
		end
	end
	return paving
end

function getKeepList(surface, playerForceNames, overlap, pavers)
	local count_entities = surface.count_entities_filtered
	local count_tiles = surface.count_tiles_filtered
	local count_total_chunks = 0
	local count_uncharted = 0
	local count_with_entities = 0
	local count_with_paving = 0
	local keepcords = {}
	local chunks = surface.get_chunks()
	for chunk in (chunks) do
		local chunk_occupied = false
		local chunk_charted = false
		local chunk_paved = false
		local chunkArea = {{chunk.x*32-overlap, chunk.y*32-overlap}, {chunk.x*32+32+overlap, chunk.y*32+32+overlap}}
		for _, forceName in pairs (playerForceNames) do
			if game.forces[forceName].is_chunk_charted( surface, chunk ) then
				chunk_charted = true
				break
			end
		end
		if chunk_charted then
			for _, forceName in pairs (playerForceNames) do
				if count_entities{area=chunkArea, force=forceName, limit=1} ~= 0 then
					chunk_occupied = true
					break
				end
			end
			if not chunk_occupied and #pavers > 0 then
				local pavedArea = {{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}
				if count_tiles{area=pavedArea, name=pavers, limit=1} ~= 0 then
					chunk_paved = true
				end
			end
			if chunk_occupied or chunk_paved then 
				if keepcords[chunk.x] == nil then
					keepcords[chunk.x]={}
				end
				keepcords[chunk.x][chunk.y]=1
				if chunk_occupied then 
					count_with_entities = count_with_entities + 1
				elseif chunk_paved then 
					count_with_paving = count_with_paving + 1
				end
			end
		else
			count_uncharted = count_uncharted + 1
		end
		count_total_chunks = count_total_chunks + 1
	end
	-- Compatibility with Mining Drones, Mining_Drones_0.3.2/script/mining_drone.lua:24
	-- Of course it just has to be right on a chunk boundry.
	if game.active_mods["Mining_Drones"] and surface.name == 'nauvis' then
		local x = 1000000/32
		local y = 1000000/32
		if keepcords[x-1] == nil then
			keepcords[x-1]={}
		end
		keepcords[x-1][y-1]=1
		keepcords[x-1][y]=1
		if keepcords[x] == nil then
			keepcords[x]={}
		end
		keepcords[x][y-1]=1
		keepcords[x][y]=1
	end
	return {total=count_total_chunks, occupied=count_with_entities, paved=count_with_paving, coordinates=keepcords, uncharted = count_uncharted}
end

function deleteChunks(surface, coordinates, radius)
	local count_adjacent = 0
	local count_keep = 0
	local count_deleted = 0
	local chunks = surface.get_chunks()
	for chunk in (chunks) do
		local mustClean = true
		if coordinates[chunk.x] ~= nil and coordinates[chunk.x][chunk.y] ~= nil then
			mustClean = false
		elseif radius > 0 then
			for i, x in pairs(coordinates) do
				if chunk.x <= i + radius and chunk.x >= i - radius then
					for j, y in pairs(x) do
						if chunk.y <= j + radius and chunk.y >= j - radius then
							mustClean = false
							count_adjacent = count_adjacent + 1
							break
						end
					end
					if not mustClean then
						break
					end
				end
			end
		end
		if mustClean then
			surface.delete_chunk({chunk.x, chunk.y})
			count_deleted = count_deleted + 1
		else
			count_keep = count_keep + 1
		end
	end
	return {adjacent=count_adjacent, deleted=count_deleted, kept=count_keep}
end

function show_gui(player)
	if not (player and player.valid) then return end
	local gui = mod_gui.get_button_flow(player)
	if not (gui and gui.valid) then return end
	if not gui.DeleteEmptyChunks then
		gui.add{
			type = "sprite-button",
			name = "DeleteEmptyChunks",
			sprite = "DeleteEmptyChunks_button",
			style = mod_gui.button_style,
			tooltip = {'DeleteEmptyChunks_buttontext'}
		}
	end
end

function hide_gui(player)
	if not (player and player.valid) then return end
	local gui = mod_gui.get_button_flow(player)
	if not (gui and gui.valid) then return end
	if gui.DeleteEmptyChunks then
		gui.DeleteEmptyChunks.destroy()
	end
end

commands.add_command("DeleteEmptyChunks", {'DeleteEmptyChunks_command'}, function(param)
	local args = {}
	if param.player_index then
		local player = game.players[param.player_index]
		if player.admin then
			if param.parameter then
				args = load("return "..param.parameter)()
			end
			remote_doit(player.name, args)
		else
			player.print({'DeleteEmptyChunks_adminsonly'})
		end
	else
		if param.parameter then
			args = load("return "..param.parameter)()
		end
		remote_doit("Server console", args)
	end
end)

remote.add_interface('DeleteEmptyChunks', {
	getSurface = function() return settings.global["DeleteEmptyChunks_surface"].value end,
	getRadius = function() return settings.global["DeleteEmptyChunks_radius"].value end,
	getPaving = function() return settings.global["DeleteEmptyChunks_paving"].value end,
	DeleteEmptyChunks = remote_doit
})

do---- Init ----
script.on_init(function()
	for _, player in pairs(game.players) do
		if player and player.valid then 
			if player.admin then
				show_gui(player)
			else
				hide_gui(player)
			end
		end
	end
end)

script.on_configuration_changed(function(data)
	for _, player in pairs(game.players) do
		if player and player.valid then
			if player.gui.left.DeleteEmptyChunks_button then player.gui.left.DeleteEmptyChunks_button.destroy()	end
			if player.admin then
				show_gui(player)
			else
				hide_gui(player)
			end
		end
	end
end)

script.on_event({defines.events.on_player_created, defines.events.on_player_joined_game, defines.events.on_player_respawned}, function(event)
	if event.player_index then
		local player = game.players[event.player_index]
		if player and player.valid then
			if player.admin then
				show_gui(player)
			else
				hide_gui(player)
			end
		end
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local gui = event.element
	if event.player_index then
		local player = game.players[event.player_index]
		if not (player and player.valid and gui and gui.valid) then return end
		if player.admin then
			local target_surface = settings.global["DeleteEmptyChunks_surface"].value
			local radius = settings.global["DeleteEmptyChunks_radius"].value
			local keep_paving = settings.global["DeleteEmptyChunks_paving"].value
			if gui.name == "DeleteEmptyChunks" then doit(player.name, target_surface, radius, keep_paving) end
		else
			player.print({'DeleteEmptyChunks_adminsonly'})
		end
	end
end)

script.on_event(defines.events.on_player_promoted, function(event)
	if event.player_index then
		show_gui(game.players[event.player_index])
	end
end)

script.on_event(defines.events.on_player_demoted, function(event)
	if event.player_index then
		hide_gui(game.players[event.player_index])
	end
end)
end
