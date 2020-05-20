require "gui"

local function onGuiClick(event)
	if event.element.name == "close" then
		event.element.parent.destroy()
	end
end
	
local function onResearchFinished()
	for _, p in pairs(game.players) do
		local guiLeft = p.gui.left
		if guiLeft.EMC_frame then
			guiLeft.EMC_frame.destroy()
			legendDropdown(guiLeft)
		end
	end
end

local function pprint(msg)
	game.print(tostring(msg))
end

local function rechart(msg)
	pprint(msg)
	game.forces.player.rechart()
end
	
local function destroyOldMainGuiButton()
	for _,p in pairs(game.players) do
		if p.gui.top.EMC_legend_Main then
			p.gui.top.EMC_legend_Main.destroy()
		end
		if p.gui.left.EMC_legend_Main then
			p.gui.left.EMC_legend_Main.destroy()
		end
	end	
end

local function modChange(event)
	if event.mod_changes == nil then return end
	if event.mod_changes.Enhanced_Map_Colors == nil then return end

	local previousOldEMCModVersion = event.mod_changes.Enhanced_Map_Colors.old_version
	local currentNewEMCModVersion = event.mod_changes.Enhanced_Map_Colors.new_version

	destroyOldMainGuiButton()
	if previousOldEMCModVersion == nil then 
		rechart("No Enhanced Map Colors previously installed, calling rechart for player ")
		return
	end -- no previous mod
	if currentNewEMCModVersion == nil then
		rechart("Enhanced Map Colors removed, calling rechart for player ")
		return
	end --mod removed ¯\_(ツ)_/¯
	if tostring(tostring(previousOldEMCModVersion) <= tostring(currentNewEMCModVersion)) then
		rechart("Old Enhanced Map Colors version previously installed, calling rechart for player ")
		return
	end	-- mod was updated, rechart map
end

local function customInputForLegend(event)
	local guiLeft = game.players[event.player_index].gui.left
	if guiLeft["EMC_frame"] == nil then
		legendDropdown(guiLeft)
	else
		guiLeft["EMC_frame"].destroy()
	end
end

script.on_event(defines.events.on_gui_click, onGuiClick)

script.on_event(defines.events.on_research_finished, onResearchFinished)

--redraws map to update colors when mod is installed on old save games.
script.on_configuration_changed(modChange)

script.on_event("EMC-Hotkey", customInputForLegend) --open/close gui legend