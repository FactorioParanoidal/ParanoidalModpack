if (testsG) then
    return testsG
end
local tests = {}

local powerup = require("libs/Powerup")


local debug_players_list = {}
debug_players_list["Dimm2101"] = true

function tests.in_debug_list(player)
	if player and player.valid and debug_players_list[player.name] then
		return true
	end
	return false
end

function tests.addDebugButton(player, root)
	if tests.in_debug_list(player) then
		root.add{type = "button", name = "rampantFixed_DebugMenu", caption = "DEBUG", style = "rampantFixed_menu_button"}		
	end
end

local function createDebugMenu(player, universeDebugSettings, universePowerupSettings)
	if not universePowerupSettings[player.name] then
		universePowerupSettings[player.name] = {}
	end
	local powerupSettings = universePowerupSettings[player.name]
	local endlessAmmo = powerupSettings and powerupSettings.endlessAmmo
	local oneshotBiters = powerupSettings and powerupSettings.oneshotBiters
	local bonusHP = powerupSettings and powerupSettings.bonusHP
	
	local gui = player.gui.screen

	for i, children in pairs(gui.children) do
		if children.name ==  "rampantFixed_DebugMenu_frame" then
			children.destroy()
			return
		end
	end
	
	local root = gui.add{name = "rampantFixed_DebugMenu_frame", type = "frame", direction = "vertical"}
	root.force_auto_center()
	player.opened = root
	if not (root and root.valid) then return end -- setting player.opened can cause other scripts to delete UIs
	
    -- Titlebar
    local titlebar = root.add {
        type = "flow",
        name = "rampantFixed_DebugMenuTitle",
		alignment = "right",
        direction = "horizontal"
    }
    titlebar.drag_target = root
    titlebar.add { -- Title
        type = "label",
        caption = "DEBUG",
        ignored_by_interaction = true,
        style = "rampantFixed_menu_label"	--"frame_title"
    }
    titlebar.add {
        type = "empty-widget",
        ignored_by_interaction = true,
    }

	titlebar.add { -- Close button
		type = "sprite-button",
		name= "rampantFixed_DebugMenuClose",
		sprite = "utility/close",
		style = "close_button"
	}
	local buttonCaption = "oneshot biters:"
	if oneshotBiters then
		buttonCaption = buttonCaption .. " ON"
	else
		buttonCaption = buttonCaption .. " OFF"
	end
	root.add{type = "button", name = "rampantFixed_Debug_OneshotBitersSwitch", caption = buttonCaption, style = "rampantFixed_menu_button"}

	buttonCaption = "endless ammo:"
	if endlessAmmo then
		buttonCaption = buttonCaption .. " ON"
	else
		buttonCaption = buttonCaption .. " OFF"
	end
	root.add{type = "button", name = "rampantFixed_Debug_endlessAmmoSwitch", caption = buttonCaption, style = "rampantFixed_menu_button"}

	buttonCaption = "add 750hp:"
	if bonusHP then
		buttonCaption = buttonCaption .. " ON"
	else
		buttonCaption = buttonCaption .. " OFF"
	end
	root.add{type = "button", name = "rampantFixed_Debug_addHPSwitch", caption = buttonCaption, style = "rampantFixed_menu_button"}

    local pointButtons = root.add {
        type = "flow",
        name = "rampantFixed_pointButtons",
		alignment = "right",
        direction = "horizontal"
    }
	pointButtons.add({type = "label", caption = "AI Points:"})
	pointButtons.add{type = "button", name = "rampantFixed_Debug_SetPointsTo0", caption = "-> 0"}
	pointButtons.add{type = "button", name = "rampantFixed_Debug_Add100Points", caption = "+100"}
	pointButtons.add{type = "button", name = "rampantFixed_Debug_Add1000Points", caption = "+1000"}
	
	root.add{type = "button", name = "rampantFixed_Debug_BasesManagment", caption = "Bases managment (not yet)", style = "rampantFixed_menu_button"}
	root.add{type = "button", name = "rampantFixed_Debug_SquadsManagment", caption = "Squads managment (pre-alpha)", style = "rampantFixed_menu_button"}
	
	
	local showPheromonesTitle
	if universeDebugSettings.showPheromones then
		showPheromonesTitle = "Hide pheromones"
	else
		showPheromonesTitle = "Show pheromones"
	end
	root.add{type = "button", name = "rampantFixed_Debug_ShowPheromones", caption = showPheromonesTitle, style = "rampantFixed_menu_button"}

	local showNestsActivenessTitle
	if universeDebugSettings.showNestsActiveness then
		showNestsActivenessTitle = "Hide nests activeness"
	else
		showNestsActivenessTitle = "Show nests activeness"
	end
	root.add{type = "button", name = "rampantFixed_Debug_ShowNestsActiveness", caption = showNestsActivenessTitle, style = "rampantFixed_menu_button"}
	
	root.add{type = "button", name = "rampantFixed_Debug_showResourceGenerator", caption = "Show/Hide resource generator", style = "rampantFixed_menu_button"}
	
	-- root.add{type = "button", name = "rampantFixed_showSurfaceIteractionFrame", caption = {"description.rampantFixed--surfaceIteraction_frame"}, style = "rampantFixed_menu_button"}
end

local function createSquadFrame(root, group)
	local squadName = "squad"..group.unique_id
	local frame = root.add{name = "rampantFixed_Debug"..squadName, type = "frame", style = "non_draggable_frame", direction = "horizontal", }
	frame.add{type = "button", name = "rampantFixed_Debug_squadButton", caption = "x, y ="}
	return frame
end

local function createSquadMenu(player, universe)
	local root = player.gui.screen.add{name = "rampantFixed_SquadMenu_frame", type = "frame", direction = "vertical"}
	root.force_auto_center()
	player.opened = root
	if not (root and root.valid) then return end -- setting player.opened can cause other scripts to delete UIs
   -- Titlebar
    local titlebar = root.add {
        type = "flow",
        name = "rampantFixed_SquadMenuTitle",
		alignment = "right",
        direction = "horizontal"
    }
    titlebar.drag_target = root
    titlebar.add { -- Title
        type = "label",
        caption = "Squads",
        ignored_by_interaction = true,
        style = "rampantFixed_menu_label"	--"frame_title"
    }
    titlebar.add {
        type = "empty-widget",
        ignored_by_interaction = true,
    }

	titlebar.add { -- Close button
		type = "sprite-button",
		name= "rampantFixed_Debug_SquadMenuClose",
		sprite = "utility/close",
		style = "close_button"
	}
		for groupNumber, squad in pairs(universe.groupNumberToSquad) do
			if squad.map and squad.group.valid then
				local group = squad.group
				squadFrame = createSquadFrame(root, group)
				squadFrame.rampantFixed_Debug_squadButton.caption = "x, y ="..math.floor(group.position.x)..", "..math.floor(group.position.y).. ", "..#group.members.." biters"
				if squad.settlers then
					squadFrame.rampantFixed_Debug_squadButton.caption = squadFrame.rampantFixed_Debug_squadButton.caption..", settler"
				end
			end
		end

end

function tests.onDebugElementClick(event, universe)
	local guiElement = event.element	
	if guiElement.name == "rampantFixed_DebugMenu" then 
		createDebugMenu(game.players[event.player_index], universe.debugSettings, universe.powerupSettings)
	elseif guiElement.name == "rampantFixed_DebugMenuClose" then
		guiElement.parent.parent.destroy()						
	elseif guiElement.name == "rampantFixed_Debug_OneshotBitersSwitch" then
		local player = game.players[event.player_index]
		if not universe.powerupSettings[player.name] then
			universe.powerupSettings[player.name] = {}
		end
		local powerupSettings = universe.powerupSettings[player.name]
		powerup.setOneshotBiters(player, universe.powerupSettings, not powerupSettings.oneshotBiters)
		local buttonCaption = "oneshot biters:"
		if powerupSettings.oneshotBiters then
			buttonCaption = buttonCaption .. " ON"
		else
			buttonCaption = buttonCaption .. " OFF"
		end
		guiElement.caption = buttonCaption
	elseif guiElement.name == "rampantFixed_Debug_endlessAmmoSwitch" then
		local player = game.players[event.player_index]
		if not universe.powerupSettings[player.name] then
			universe.powerupSettings[player.name] = {}
		end
		local powerupSettings = universe.powerupSettings[player.name]
		powerup.setEndlessAmmo(player, powerupSettings, not powerupSettings.endlessAmmo)
		
		local buttonCaption = "endless ammo:"
		if powerupSettings.endlessAmmo then
			buttonCaption = buttonCaption .. " ON"
			powerup.savePlayerAmmo(player, universe.powerupSettings)
		else
			buttonCaption = buttonCaption .. " OFF"
		end
		guiElement.caption = buttonCaption
	elseif guiElement.name == "rampantFixed_Debug_addHPSwitch" then
		local player = game.players[event.player_index]
		if not universe.powerupSettings[player.name] then
			universe.powerupSettings[player.name] = {}
		end
		local powerupSettings = universe.powerupSettings[player.name]
		local bonusHP_value = 750
		local bonusHP_toSet = (bonusHP_value - ((powerupSettings.bonusHP and bonusHP_value) or 0))
		
		powerup.setBonusHP(player, powerupSettings, bonusHP_toSet)
		
		local buttonCaption = "add ".. bonusHP_value.."hp:"
		if bonusHP_toSet == 0 then
			buttonCaption = buttonCaption .. " OFF"
		else
			buttonCaption = buttonCaption .. " ON"
		end
		guiElement.caption = buttonCaption
	elseif guiElement.name == "rampantFixed_Debug_SquadsManagment" then
		createSquadMenu(game.players[event.player_index], universe)	-- altha
	elseif guiElement.name == "rampantFixed_Debug_SquadMenuClose" then
		guiElement.parent.parent.destroy()						
	elseif guiElement.name == "rampantFixed_Debug_squadButton" then
		local pos1 = string.find(guiElement.parent.name, "quad") + 4;		
		local group_number = string.sub(guiElement.parent.name, pos1)
		group_number = tonumber(group_number)
		local squad = universe.groupNumberToSquad[group_number]
		if squad and squad.valid then
			end	
		for groupNumber, squad in pairs(universe.groupNumberToSquad) do
			if squad.map and squad.group.valid then
				if squad.group.unique_id == group_number then
					game.print("group_number = ".. group_number.. ": [gps=" .. squad.group.position.x .. "," .. squad.group.position.y .."]")
					-- local player = game.players[event.player_index]
					-- player.set_controller({type = defines.controllers.editor, position  = {squad.group.position.x, squad.group.position.y}, surface = squad.group.surface})
				end
			end
		end
	elseif guiElement.name == "rampantFixed_Debug_ShowPheromones" then
		local player = game.players[event.player_index]
		local map = universe.maps[game.players[event.player_index].surface.index]
		if not map then
			return
		end	
		local universeDebugSettings = universe.debugSettings
		universeDebugSettings.showPheromones = not universeDebugSettings.showPheromones
		tests.showChunkPheromones(map, universeDebugSettings.showPheromones)
	elseif guiElement.name == "rampantFixed_Debug_ShowNestsActiveness" then
		local player = game.players[event.player_index]
		local map = universe.maps[game.players[event.player_index].surface.index]
		if not map then
			return
		end	
		local universeDebugSettings = universe.debugSettings
		universeDebugSettings.showNestsActiveness = not universeDebugSettings.showNestsActiveness
		tests.showNestsActiveness(map, universeDebugSettings.showNestsActiveness)			
		if universeDebugSettings.showNestsActiveness then
			guiElement.caption = "Hide nests activeness"
		else
			guiElement.caption = "Show nests activeness"
		end
	elseif guiElement.name == "rampantFixed_Debug_showResourceGenerator" then
		local player = game.players[event.player_index]
		local map = universe.maps[game.players[event.player_index].surface.index]
		if not map then
			return
		end	
		local universeDebugSettings = universe.debugSettings
		universeDebugSettings.showResourceGenerator = not universeDebugSettings.showResourceGenerator
		tests.showChunkResourceGenerator(map, universeDebugSettings.showResourceGenerator)
	end
end

function tests.showChunkPheromones(map, showText)
	for x, nestsY in pairs(map) do
		if (type(x) == "number") and (math.floor(x)==x) then
			for y, chunk in pairs(nestsY) do
				local chunkText = ""..chunk[1].."/"..chunk[5]
				local renderingObject
				if chunk.textId then
					renderingObject = rendering.get_object_by_id(chunk.textId)	
				end
				if renderingObject then
					if showText then					
						renderingObject.text = chunkText
					else
						renderingObject.destroy()
						chunk.textId = nil
					end	
				else	
					if showText then					
						renderingObject = rendering.draw_text({
						text = chunkText, 
						surface = map.surface,
						target = {x = chunk.x, y = chunk.y},
						color = {r = 0, g = 0.5, b = 0, a = 0.5},
						forces = {"player"},
						scale = 5
						})
						chunk.textId = renderingObject.id
					end	
				 end
			end
		end
	end
end

function tests.showChunkResourceGenerator(map, showText)
	for x, nestsY in pairs(map) do
		if (type(x) == "number") and (math.floor(x)==x) then
			for y, chunk in pairs(nestsY) do
				local chunkText = ""..(map.chunkToResource[chunk] or "").."=>".. tostring(chunk[3])
				local renderingObject
				if chunk.textResourceId then
					renderingObject = rendering.get_object_by_id(chunk.textResourceId)	
				end
				if renderingObject then
					if showText then					
						renderingObject.text = chunkText
					else
						renderingObject.destroy()
						chunk.textResourceId = nil
					end	
				else	
					if showText then					
						renderingObject = rendering.draw_text({
						text = chunkText, 
						surface = map.surface,
						target = {x = chunk.x, y = chunk.y+30},
						color = {r = 0.5, g = 0.5, b = 0, a = 0.5},
						forces = {"player"},
						scale = 5
						})
						chunk.textResourceId = renderingObject.id
					end	
				 end
			end
		end
	end

end

function tests.showNestsActiveness(map, showText)
	for chunk, value in pairs(map.chunkToNests) do
		local renderingObject
		if chunk.rectangleId then
			renderingObject = rendering.get_object_by_id(chunk.rectangleId)	
		end
		if renderingObject then
			if showText then					
				renderingObject.color = {0.0, 0.0, 0.4, 0.6}
				-- renderingObject.text = chunkText
			else
				renderingObject.destroy()
				chunk.rectangleId = nil
			end	
		else	
			if showText then
				renderingObject	= rendering.draw_rectangle({
					color = {0.0, 0.0, 0.4, 0.6},
					width = 8,
					left_top = {chunk.x, chunk.y},
					right_bottom = {chunk.x+32, chunk.y+32},
					surface = map.surface,
					-- time_to_live = 0,
					draw_on_ground = true,
					visible = true
				})
				chunk.rectangleId = renderingObject.id
			end	
		 end
	end
	for chunk, value in pairs(map.chunkToActiveRaidNest) do
		local renderingObject
		if chunk.rectangleId then
			renderingObject = rendering.get_object_by_id(chunk.rectangleId)	
		end
		if renderingObject then
			if showText then					
				renderingObject.color = {0.4, 0.0, 0.0, 0.6}
			else
				renderingObject.destroy()
				chunk.rectangleId = nil
			end	
		else	
			if showText then					
				renderingObject	= rendering.draw_rectangle({
					color = {0.4, 0.0, 0.0, 0.6},
					width = 8,
					left_top = {chunk.x, chunk.y},
					right_bottom = {chunk.x+32, chunk.y+32},
					surface = map.surface,
					-- time_to_live = 0,
					draw_on_ground = true,
					visible = true
				})
				chunk.rectangleId = renderingObject.id
			end	
		 end
	end
	for chunk, value in pairs(map.chunkToActiveNest) do
		local renderingObject
		if chunk.rectangleId then
			renderingObject = rendering.get_object_by_id(chunk.rectangleId)	
		end
		if renderingObject then
			if showText then					
				renderingObject.color = {0.7, 0.0, 0.0, 0.6}
			else
				rendering.destroy(chunk.rectangleId)
				chunk.rectangleId = nil
			end	
		else	
			if showText then					
				renderingObject	= rendering.draw_rectangle({
					color = {0.7, 0.0, 0.0, 0.6},
					width = 8,
					left_top = {chunk.x, chunk.y},
					right_bottom = {chunk.x+32, chunk.y+32},
					surface = map.surface,
					-- time_to_live = 0,
					draw_on_ground = true,
					visible = true
				})
				chunk.rectangleId = renderingObject.id
			end	
		 end
	end
end


testsG = tests
return tests
