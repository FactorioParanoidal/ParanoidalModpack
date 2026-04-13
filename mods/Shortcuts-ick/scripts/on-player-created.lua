--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of on-player-created.lua:
	* Equipment
	* Vehicle
	* With technology to unlock
	* Set shortcuts toggled
]]

function ick_reset_available_shortcuts(player)

	local setting = settings.startup

	local function disable_shortcuts(name) -- checks if the setting is active
		if setting[name].value then
			player.set_shortcut_available(name, false)
		end
	end

	local function enable_shorctus(name)
		if setting[name].value then
			player.set_shortcut_available(name, true)
		end
	end


	-- EQUIPMENT
	local function disable_shortcuts_equipment(type) -- checks if the setting is active and if the player has the equipment equiped
		if setting[type].value then
			local equiped = false
			local power_armor = player.get_inventory(defines.inventory.character_armor)
			if power_armor and power_armor.valid then
				if power_armor[1].valid_for_read then
					if power_armor[1].grid and power_armor[1].grid.valid and power_armor[1].grid.width > 0 then
						for _, equipment in pairs(power_armor[1].grid.equipment) do
							if equipment.type == type then
								equiped = true
								break
							end
						end
					end
				end
			end
			player.set_shortcut_available(type, equiped)
		end
	end

	disable_shortcuts_equipment("active-defense-equipment")
	disable_shortcuts_equipment("belt-immunity-equipment")
	disable_shortcuts_equipment("night-vision-equipment")


	-- VEHICLE
	if player.vehicle then
		local type = player.vehicle.type
		if type ~= "car" and type ~= "spider-vehicle" then
			disable_shortcuts("driver-is-gunner")
		end
		if type ~= "spider-vehicle" then
			disable_shortcuts("targeting-with-gunner")
			disable_shortcuts("targeting-without-gunner")
		end
		if type ~= "locomotive" and type ~= "cargo-wagon" and type ~= "fluid-wagon" and type ~= "artillery-wagon" then
			disable_shortcuts("train-mode-toggle")
		end
		if player.vehicle.get_requester_point() and player.vehicle.get_requester_point().enabled then else
			disable_shortcuts("vehicle-logistic-requests")
			disable_shortcuts("vehicle-trash-not-requested")
		end
		if player.vehicle.grid then else
			disable_shortcuts("vehicle-logistics-while-moving")
		end
	else
		disable_shortcuts("driver-is-gunner")
		disable_shortcuts("targeting-with-gunner")
		disable_shortcuts("targeting-without-gunner")
		disable_shortcuts("train-mode-toggle")
		disable_shortcuts("vehicle-logistic-requests")
		disable_shortcuts("vehicle-trash-not-requested")
		disable_shortcuts("vehicle-logistics-while-moving")
	end


	-- WITH TECHNOLOGY TO UNLOCK
	if settings.startup["ick-compatibility-mode"].value == true then
		enable_shorctus("tree-killer")
		enable_shorctus("rail-block-visualization-toggle")
		enable_shorctus("player-trash-not-requested")
		if setting["artillery-toggle"].value ~= "disabled" then
			player.set_shortcut_available("artillery-jammer-tool", true)
		end
	end

	-- SET SHORTCUTS TOGGLED
	if setting["flashlight-toggle"].value then
		player.set_shortcut_toggled("flashlight-toggle", true)
	end

end

script.on_event(defines.events.on_player_created, function(event)
	ick_reset_available_shortcuts(game.players[event.player_index])
end)
script.on_event(defines.events.on_player_toggled_map_editor, function(event)
	ick_reset_available_shortcuts(game.players[event.player_index])
end)
