require "gui"

local function pprint(msg)
	game.print(tostring(msg))
end

local function versionStringToNumber(s)
	local p1 = string.match(s, "%d+%p%d+")
	local p2 = string.match(s, "%d+", 1 + #p1)
	local n = tonumber(p1..p2)
	return n
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

script.on_event(defines.events.on_gui_click, function(event)
		if event.element.name == "close" then
			event.element.parent.destroy()
		end
	end
)

script.on_event(defines.events.on_research_finished, function()
		for _, p in pairs(game.players) do
			local guiLeft = p.gui.left
			if guiLeft.EMC_frame then
				guiLeft.EMC_frame.destroy()
				legendDropdown(guiLeft)
			end
		end
	end
)

--redraws map to update colors when mod is installed on old save games.
script.on_configuration_changed(function(data)
		if data.mod_changes ~= nil and data.mod_changes["Enhanced_Map_Colors"] ~= nil then
			if data.mod_changes["Enhanced_Map_Colors"].old_version == nil then -- saved game, no mod
				rechart("No Enhanced Map Colors previously installed, calling rechart for player ")
			elseif versionStringToNumber(data.mod_changes.Enhanced_Map_Colors.old_version) <= 1.401 then --save game, old mod version --last color change 0.15.x --should be one version less than current?
				rechart("Old Enhanced Map Colors version previously installed, calling rechart for player ")
				if versionStringToNumber(data.mod_changes.Enhanced_Map_Colors.old_version) <= 1.39 then --save game, old mod version 
					destroyOldMainGuiButton() --not really needed
				end
			end
		end
	end
)

script.on_event("EMC-Hotkey", function(event) --open/close gui legend
		local guiLeft = game.players[event.player_index].gui.left
		if guiLeft["EMC_frame"] == nil then
			legendDropdown(guiLeft)
		else
			guiLeft["EMC_frame"].destroy()
		end
	end
)