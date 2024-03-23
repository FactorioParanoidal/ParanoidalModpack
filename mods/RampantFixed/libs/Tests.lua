if (testsG) then
    return testsG
end
local tests = {}

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

local function createDebugMenu(player, universeDebugSettings)
	if not universeDebugSettings[player.name] then
		universeDebugSettings[player.name] = {}
	end
	local debugSettings = universeDebugSettings[player.name]
	
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
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		style = "close_button"
	}
	local buttonCaption = "oneshot biters:"
	if debugSettings.oneshotBiters then
		buttonCaption = buttonCaption .. " ON"
	else
		buttonCaption = buttonCaption .. " OFF"
	end
	root.add{type = "button", name = "rampantFixed_Debug_OneshotBitersSwitch", caption = buttonCaption, style = "rampantFixed_menu_button"}

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
	
	root.add{type = "button", name = "rampantFixed_Debug_BasesManagment", caption = "Bases managment", style = "rampantFixed_menu_button"}
	root.add{type = "button", name = "rampantFixed_Debug_SquadsManagment", caption = "Squads managment", style = "rampantFixed_menu_button"}
	
	
	-- root.add{type = "button", name = "rampantFixed_showSurfaceIteractionFrame", caption = {"description.rampantFixed--surfaceIteraction_frame"}, style = "rampantFixed_menu_button"}
end

function tests.onDebugElementClick(event, universe)
	local guiElement = event.element
	if guiElement.name == "rampantFixed_DebugMenu" then 
		createDebugMenu(game.players[event.player_index], universe.debugSettings)
	elseif guiElement.name == "rampantFixed_DebugMenuClose" then
		guiElement.parent.parent.destroy()						
	elseif guiElement.name == "rampantFixed_Debug_OneshotBitersSwitch" then
		local player = game.players[event.player_index]
		if not universe.debugSettings[player.name] then
			universe.debugSettings[player.name] = {oneshotBiters = true}
		else	
			universe.debugSettings[player.name].oneshotBiters = not universe.debugSettings[player.name].oneshotBiters
		end
		
		local buttonCaption = "oneshot biters:"
		if universe.debugSettings[player.name].oneshotBiters then
			buttonCaption = buttonCaption .. " ON"
		else
			buttonCaption = buttonCaption .. " OFF"
		end
		guiElement.caption = buttonCaption
	end
end

function tests.debug_onUnitDamaged(event, universeDebugSettings)
	if not event.cause.player then
		return false
	end
	if (not universeDebugSettings[event.cause.player.name]) or (not universeDebugSettings[event.cause.player.name].oneshotBiters) then
		return false
	end
	event.entity.health = 0
	event.final_health = event.entity.health					
	return true
end



testsG = tests
return tests
