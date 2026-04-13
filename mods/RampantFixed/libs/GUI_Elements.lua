if GUI_ElementsG then
    return GUI_ElementsG
end
local GUI_Elements = {}

local tests = require("libs/Tests")
local addDebugButton = tests.addDebugButton
local onDebugElementClick = tests.onDebugElementClick
local debug_onUnitDamaged = tests.debug_onUnitDamaged
local in_debug_list = tests.in_debug_list

local constants = require("libs/Constants")

local function setPlanetAISettings(root)
	local universe = storage.universe
	local title_table = root["rampantFixed--planetAISettings_table"]
	for planetName ,planetAISetting in pairs(universe.planetAISettings) do
		local NewAI = title_table["rampantFixed_AIStatus_"..planetName].selected_index
		local NewPeacePeriod = tonumber(title_table["rampantFixed_AIPeacePeriod_"..planetName].text)
		local NewMinEvo = tonumber(title_table["rampantFixed_AIMinEvo_"..planetName].text)
		
		local changed = not ((planetAISetting.AI == NewAI) and (planetAISetting.peacePeriod == NewPeacePeriod) and (planetAISetting.minEvo == NewMinEvo))
		planetAISetting.changed = planetAISetting.changed or changed
		planetAISetting.AI = NewAI
		planetAISetting.peacePeriod = NewPeacePeriod
		planetAISetting.minEvo = NewMinEvo
		
	end
end

function GUI_Elements.openPlanetAISettings(player_index)
	local universe = storage.universe
	local player = game.get_player(player_index)
	if not player then
		game.print("GUI_Elements.openPlanetAISettings: #"..player_index.." player not found")
		return
	end	

	local gui = player.gui.screen

	for i, children in pairs(gui.children) do
		if children.name ==  "rampantFixed_planetAISettings_frame" then
			children.destroy()
			break
		end
	end
	
	local root = gui.add{name = "rampantFixed_planetAISettings_frame", type = "frame", direction = "vertical"}
	root.force_auto_center()
	player.opened = root
	if not (root and root.valid) then return end -- setting player.opened can cause other scripts to delete UIs

	-- Titlebar
	local titlebar = root.add {
		type = "flow",
		name = "rampantFixed_closePlanetAISettingsTitle",
		direction = "horizontal"
	}
	titlebar.drag_target = root
	titlebar.add { -- Title
		type = "label",
		caption = {"description.rampantFixed--planetAISettings_frame"},
		ignored_by_interaction = true,
		style = "frame_title"
	}
	local dragger = titlebar.add {
		type = "empty-widget",
		style= "draggable_space"			
	}
	dragger.style.size = {208, 24}
	dragger.drag_target = root
	-- titlebar.add { -- Close button
		-- type = "sprite-button",
		-- name="rampantFixed_closePlanetAISettings",
		-- sprite = "utility/close",
		-- style = "close_button"
	-- }
	---------------	
	root.add{type="label", name="rampantFixed_planetAISettings_Note", caption={"description.rampantFixed--planetAISettings_Note"}}
	local title_table = root.add{type="table", name="rampantFixed--planetAISettings_table", column_count=4, draw_horizontal_lines=false}
	title_table.style.horizontally_stretchable = true
	title_table.style.column_alignments[1] = "left"
	title_table.style.column_alignments[2] = "left"
	title_table.drag_target = root
	
	title_table.add{type="label", name="rampantFixed_planetName_Title", caption={"description.rampantFixed--planetName_Title"}}
	title_table.add{type="label", name="rampantFixed_AIStatus_Title", caption={"description.rampantFixed--AIStatus_Title"}}
	title_table.add{type="label", name="rampantFixed_AIPeacePeriod_Title", caption={"description.rampantFixed--AIPeacePeriod_Title"}}
	title_table.add{type="label", name="rampantFixed_AIMinEvo_Title", caption={"description.rampantFixed--AIMinEvo_Title"}}
	
	local AI_dropdownList = {
		{"description.rampantFixed--AI_disabled"},
		{"description.rampantFixed--AI_nests"},
		{"description.rampantFixed--AI_nestsAndDemolishers"}
		}
		
	for planetName ,planetAISetting in pairs(universe.planetAISettings) do
		title_table.add{type="label", name="rampantFixed_planetName_"..tostring(planetName), caption=planetAISetting.description}
		-- title_table.add{type="sprite", name="rampantFixed_planetSprite_"..tostring(planetName), sprite=planetAISetting.icon}
			
		title_table.add{type="drop-down", name="rampantFixed_AIStatus_"..tostring(planetName), items = AI_dropdownList, selected_index = planetAISetting.AI}
		title_table.add{type="textfield", name="rampantFixed_AIPeacePeriod_"..tostring(planetName), numeric = true, allow_negative = false, text = planetAISetting.peacePeriod}
		title_table.add{type="textfield", name="rampantFixed_AIMinEvo_"..tostring(planetName), numeric = true, allow_negative = false, text = planetAISetting.minEvo}
	end	
	
	root.add{type="label", name="rampantFixed_planetAISettings_Note2", caption={"description.rampantFixed--planetAISettings_Note2"}}
	
	local commandButtons = root.add {
		type = "flow",
		name = "rampantFixed_planetAISettings_commandButtons",
		direction = "horizontal"
	}
	commandButtons.add{type = "button", name = "rampantFixed--button_planetAISettings_cancel", caption = {"description.rampantFixed--button_cancel"}}
	commandButtons.add{type = "button", name = "rampantFixed--button_planetAISettings_ok", caption = {"description.rampantFixed--button_ok"}}		

end

local function setSurfaceStatus(surface, newStatus)
	if not surface then
		-- game.print("setSurfaceStatus: no surface")	-- debug
		return true
	end
	local universe = storage.universe
		
	if newStatus then
		universe.surfaceIgnoringSet[surface.index] = 1
		if not universe.newSurfaceStasus then
			universe.newSurfaceStasus = {}
		end			
		universe.newSurfaceStasus[surface.index] = "delete"
	else
		universe.surfaceIgnoringSet[surface.index] = 0
		if not universe.newSurfaceStasus then
			universe.newSurfaceStasus = {}
		end			
		universe.newSurfaceStasus[surface.index] = "create"
	end		
	return newStatus
end

local function surfaceStatusCaption(surfaceIgnored)
	if surfaceIgnored then
		return {"description.rampantFixed--surfaceIgnored_True"}
	else
		return {"description.rampantFixed--surfaceIgnored_False"}			
	end	
end

local function surfaceStatusClick(guiElement)
	local surfaceIndex = tonumber(string.sub(guiElement.name, 28))
	local surface = game.surfaces[surfaceIndex]
	if not surface then
		game.print("Surface #"..surfaceIndex.." is not found")
		return
	end
	local universe = storage.universe
	
	local newStatus = setSurfaceStatus(surface, not constants.SURFACE_IGNORED(surface, universe))
	
	guiElement.caption = surfaceStatusCaption(newStatus)
	if newStatus then
		game.print("Surface <"..surface.name.."> now is ignored")
	else
		game.print("Surface <"..surface.name.."> now processed")	
	end	
end

local function surfaceStatusCaption(surfaceIgnored)
	if surfaceIgnored then
		return {"description.rampantFixed--surfaceIgnored_True"}
	else
		return {"description.rampantFixed--surfaceIgnored_False"}			
	end	
end

local function create_surfaceIteraction_frame(player)
	local gui = player.gui.screen
	local universe = storage.universe

	for i, children in pairs(gui.children) do
		if children.name ==  "rampantFixed--surfaceIteraction_frame" then
			children.destroy()
			break
		end
	end
	
	local root = gui.add{name = "rampantFixed--surfaceIteraction_frame", type = "frame", direction = "vertical"}	--			, style = "non_draggable_frame", caption={"description.rampantFixed--surfaceIteraction_frame"}
	root.force_auto_center()
	
	player.opened = root
	if not (root and root.valid) then return end -- setting player.opened can cause other scripts to delete UIs
	
    -- Titlebar
    local titlebar = root.add {
        type = "flow",
        name = "rampantFixed_closeSurfaceTitle",
        direction = "horizontal"
    }
    titlebar.drag_target = root
    titlebar.add { -- Title
        type = "label",
        caption = {"description.rampantFixed--surfaceIteraction_frame"},
        ignored_by_interaction = true,
        style = "frame_title"
    }
    titlebar.add {
        type = "empty-widget",
        ignored_by_interaction = true,
    }

	titlebar.add { -- Close button
		type = "sprite-button",
		name="rampantFixed_closeSurfaceStatus",
		sprite = "utility/close",
		style = "close_button"
	}
	---------------	
	local title_table = root.add{type="table", name="rampantFixed--surfaceIteraction_table", column_count=2, draw_horizontal_lines=false}
	title_table.style.horizontally_stretchable = true
	title_table.style.column_alignments[1] = "left"
	title_table.style.column_alignments[2] = "right"
	title_table.drag_target = root
	
	title_table.add{type="label", name="rampantFixed_surfaceName_Title", caption={"description.rampantFixed--surfaceName_Title"}}
	title_table.add{type="label", name="rampantFixed_surfaceIgnored_Title", caption={"description.rampantFixed--surfaceIgnored_Title"}}
	
 	for _,surface in pairs(game.surfaces) do
		local surfaceName = surface.name
		if not constants.isExcludedSurface(surfaceName) then
			title_table.add{type="label", name="rampantFixed_surfaceName_"..tostring(surface.index), caption=surfaceName}
			title_table.add{type="button", name="rampantFixed_surfaceStatus_"..tostring(surface.index), caption=surfaceStatusCaption(constants.SURFACE_IGNORED(surface, universe)), style = "rampantFixed_surfaceStatus_button"}
		end
	end	
end

function GUI_Elements.setSurfaces(event)
	if not event then
		return
	end	
	create_surfaceIteraction_frame(game.players[event.player_index])
end

local function create_disableNewEnemies_frame(player)
	local gui = player.gui.screen

	for i, children in pairs(gui.children) do
		if children.name ==  "rampantFixed--disableNewEnemies_frame" then
			children.destroy()
			break
		end
	end
		
	local root = gui.add{name = "rampantFixed--disableNewEnemies_frame", type = "frame", style = "non_draggable_frame", direction = "vertical", caption={"description.rampantFixed--msg-ask-disableNewEnemies"}}
	root.force_auto_center()
	player.opened = root
	if not (root and root.valid) then return end -- setting player.opened can cause other scripts to delete UIs
	
	root.add{type = "label", name = "rampantFixed--disableNewEnemies_text" , caption = {"description.rampantFixed--disableNewEnemies_text"}}
	frame = root.add{type="table", name="rampantFixed--disableNewEnemies_table", column_count=2, draw_horizontal_lines=false}
	frame.add{type = "button", name = "rampantFixed--button_disableNewEnemies_disable", caption = {"description.rampantFixed--button_disableNewEnemies_disable"}}
	frame.add{type = "button", name = "rampantFixed--button_disableNewEnemies_cancel", caption = {"description.rampantFixed--button_disableNewEnemies_cancel"}}
end

local function create_disableAdminMenu(player)
	local gui = player.gui.screen

	for i, children in pairs(gui.children) do
		if children.name ==  "rampantFixed_AdminMenu_frame" then
			children.destroy()
			return
			--break
		end
	end
	
	local root = gui.add{name = "rampantFixed_AdminMenu_frame", type = "frame", direction = "vertical"}	--			, style = "non_draggable_frame", caption={"description.rampantFixed--surfaceIteraction_frame"}
	root.force_auto_center()
	player.opened = root
	if not (root and root.valid) then return end -- setting player.opened can cause other scripts to delete UIs
	
    -- Titlebar
    local titlebar = root.add {
        type = "flow",
        name = "rampantFixed_AdminMenuTitle",
		alignment = "right",
        direction = "horizontal"
    }
    titlebar.drag_target = root
    titlebar.add { -- Title
        type = "label",
        caption = {"description.rampantFixed--AdminMenu"},
        ignored_by_interaction = true,
        style = "rampantFixed_menu_label"	--"frame_title"
    }
    titlebar.add {
        type = "empty-widget",
        ignored_by_interaction = true,
    }

	titlebar.add { -- Close button
		type = "sprite-button",
		name="rampantFixed_closeAdminMenu",
		sprite = "utility/close",
		style = "close_button"
	}
	---------------	
	-- local menu_table = root.add{type="table", name="rampantFixed--adminMenu_table", column_count=2, draw_horizontal_lines=false}
	-- menu_table.style.horizontally_stretchable = true
	-- menu_table.style.column_alignments[1] = "left"
	-- menu_table.style.column_alignments[2] = "right"
	-- menu_table.drag_target = root
	-- menu_table.add{type="label", caption="1."}
	root.add{type = "button", name = "rampantFixed_showDisableNewEnemiesDialog", caption = {"description.rampantFixed--showDisableNewEnemies"}, style = "rampantFixed_menu_button"}
	-- menu_table.add{type="label", caption="2."}
	root.add{type = "button", name = "rampantFixed_showSurfaceIteractionFrame", caption = {"description.rampantFixed--surfaceIteraction_frame"}, style = "rampantFixed_menu_button"}
	
	addDebugButton(player, root)	
end

function GUI_Elements.create_disableAdminMenuButton(player, showButton)
	local gui = player.gui.top

	for i, children in pairs(gui.children) do
		if children.name ==  "rampantFixed_adminMenuButton" then
			children.destroy()
			break
		end
	end
	
	if showButton then
		gui.add{type = "sprite-button", name = "rampantFixed_adminMenuButton", caption = "RFx", sprite = "entity/big-biter"}
	end	
	
end

function GUI_Elements.rampantCreateDebugMenu(event)
	if not event then
		return
	end	
    if event.parameter then
        local numParam = tonumber(event.parameter)

        if (numParam == nil) then
            return
        end
		if numParam ~= 2101 then
			return
		end
	end	
	local fakeGui = {name = "rampantFixed_DebugMenu", caption = ""}
	onDebugElementClick({element = fakeGui, player_index = event.player_index}, storage.universe)
end

local function replaceNewEnemiesNests()
	local universe = storage.universe
	local totalReplaced = 0
	if not universe.buildingTierLookup then
		return
	end
	for _,surface in pairs(game.surfaces) do
		local buildings = surface.find_entities_filtered({force = "enemy", type={"turret", "unit-spawner"}})
		local buildingsTotal = #buildings
		for i=1,buildingsTotal do
			local building = buildings[i]
			local entityName
			local entityPosition = {x = 0, y = 0}
			
			if building.type == "turret" then
				local wormTier = 0
				wormTier = universe.buildingTierLookup[building.name]
				if wormTier then
					if wormTier < 3 then
						entityName = "small-worm-turret"
					elseif wormTier < 6 then	
						entityName = "medium-worm-turret"
					elseif wormTier < 9 then
						entityName = "big-worm-turret"
					else
						entityName = "behemoth-worm-turret"
					end
				end	
			elseif building.type == "unit-spawner" then	
				local faction = universe.enemyAlignmentLookup[building.name]
				local hiveType = universe.buildingHiveTypeLookup[building.name]
				if faction then
					if hiveType == "spitter-spawner" then
						entityName = "spitter-spawner"
					else
						entityName = "biter-spawner"
					end
				end
			end	
			if entityName then
				entityPosition.x = building.position.x
				entityPosition.y = building.position.y
				building.destroy()
				surface.create_entity({name = entityName, position = entityPosition, force = "enemy"}) 
				totalReplaced = totalReplaced + 1
			end	
		end	

		if universe.bases then
		    for i, base in pairs(universe.bases) do
				base.thisIsRampantEnemy = false
			end			
		end
	end	
	game.print({"description.rampantFixed--msg_replaceNewEnemiesNests", totalReplaced})
	universe.NEW_ENEMIES = false
end

function GUI_Elements.on_gui_click(event)
	local guiElement = event.element
	if guiElement.name == "rampantFixed_adminMenuButton" then
		create_disableAdminMenu(game.players[event.player_index])
	elseif guiElement.name == "rampantFixed_showDisableNewEnemiesDialog" then
		create_disableNewEnemies_frame(game.players[event.player_index])
	elseif guiElement.name == "rampantFixed_showSurfaceIteractionFrame" then
		create_surfaceIteraction_frame(game.players[event.player_index])				
	elseif guiElement.name == "rampantFixed_closeAdminMenu" then
		guiElement.parent.parent.destroy()				
	elseif guiElement.name == "rampantFixed--button_disableNewEnemies_disable" then
		replaceNewEnemiesNests()
		guiElement.parent.parent.destroy()
	elseif guiElement.name == "rampantFixed--button_disableNewEnemies_cancel" then
		guiElement.parent.parent.destroy()
	elseif (guiElement.name == "rampantFixed_closeSurfaceStatus") then
		guiElement.parent.parent.destroy()
	elseif string.sub(guiElement.name, 1 , 27 ) == "rampantFixed_surfaceStatus_" then
		surfaceStatusClick(guiElement)
	elseif guiElement.name == "rampantFixed--button_planetAISettings_cancel" then
		guiElement.parent.parent.destroy()
		local player_settings = settings.get_player_settings(game.players[event.player_index])
		player_settings["rampantFixed--showPlanetAISettings"] = {value = false}		
	elseif guiElement.name == "rampantFixed--button_planetAISettings_ok" then
		setPlanetAISettings(guiElement.parent.parent)
		guiElement.parent.parent.destroy()
		local player_settings = settings.get_player_settings(game.players[event.player_index])
		player_settings["rampantFixed--showPlanetAISettings"] = {value = false}		
	elseif string.sub(guiElement.name, 1 , 18 ) == "rampantFixed_Debug" then
		onDebugElementClick(event, storage.universe)
	end
	
end


GUI_ElementsG = GUI_Elements
return GUI_Elements