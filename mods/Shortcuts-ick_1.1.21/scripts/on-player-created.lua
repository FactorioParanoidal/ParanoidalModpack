--[[ Copyright (c) 2021 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of on-player-created.lua:
	* Functions
	* Special cases
	* Equipment and vehicle
	* Mod
	* Mod with own shortcut
]]

if settings.startup["ick-compatibility-mode"].value == false then
	script.on_event(defines.events.on_player_created, function(event)

	-- FUNCTIONS
		local player = game.players[event.player_index]
		local tech = player.force.technologies
		local mods = game.active_mods
		local setting = settings.startup

		local function disable_shortcuts(name)
			if setting[name].value then
				player.set_shortcut_available(name, false)
			end
		end

		local function disable_shortcuts_1(mod_name, tech_name, name)
			if mods[mod_name] and setting[name].value and tech[tech_name].researched == false then
				player.set_shortcut_available(name, false)
			end
		end

		local function disable_shortcuts_2(mod_name, tech_name, name)
			if mods[mod_name] and tech[tech_name].researched == false then
				player.set_shortcut_available(name, false)
			end
		end


		-- EQUIPMENT and VEHICLE
		disable_shortcuts("active-defense-equipment")
		disable_shortcuts("belt-immunity-equipment")
		disable_shortcuts("night-vision-equipment")
		disable_shortcuts("discharge-defense-remote")

		disable_shortcuts("driver-is-gunner")
		disable_shortcuts("spidertron-logistics")
		disable_shortcuts("spidertron-logistic-requests")
		disable_shortcuts("targeting-with-gunner")
		disable_shortcuts("targeting-without-gunner")
		disable_shortcuts("train-mode-toggle")


		-- SPECIAL CASES
		if setting["flashlight-toggle"].value then
			player.set_shortcut_toggled("flashlight-toggle", true)
		end

		if tech["railway"].researched == false then
			disable_shortcuts("rail-block-visualization-toggle")
		end

		if tech["artillery"].researched == false and setting["artillery-targeting-remote"].value then
			player.set_shortcut_available("artillery-targeting-remote", false)
		end

		local artillery_toggle = setting["artillery-toggle"].value
		if tech["artillery"].researched == false and (artillery_toggle == "both" or artillery_toggle == "artillery-wagon" or artillery_toggle == "artillery-turret") then
			player.set_shortcut_available("artillery-jammer-tool", false)
		end

		local spidertron_remote = setting["spidertron-remote"].value
		if tech["spidertron"].researched == false then
			if spidertron_remote == "enabled" or spidertron_remote == "enabled-hidden" then
				player.set_shortcut_available("spidertron-remote", false)
			end
		end


		-- MOD
		if tech["spidertron"].researched == false then
			disable_shortcuts_2("aai-programmable-vehicles", "automobilism", "path-remote-control")
			disable_shortcuts_2("aai-programmable-vehicles", "automobilism", "unit-remote-control")
		end

		if mods["AdvancedArtilleryRemotesContinued"] and setting["artillery-targeting-remote"].value and tech["artillery"].researched == false then
			player.set_shortcut_available("artillery-cluster-remote", false)
			player.set_shortcut_available("artillery-discovery-remote", false)
		end

		disable_shortcuts_1("AtomicArtilleryRemote", "atomic-artillery", "atomic-artillery-targeting-remote")
		-- disable_shortcuts_1("jetpack", "jetpack-1", "jetpack")
		disable_shortcuts_1("landmine-thrower", "landmine-thrower", "landmine-thrower-remote")
		disable_shortcuts_1("MIRV", "mirv-technology", "mirv-targeting-remote")
		disable_shortcuts_1("VehicleWagon2", "vehicle-wagons", "winch")
		disable_shortcuts_1("WellPlanner", "oil-processing", "well-planner")


		-- MOD WITH OWN SHORTCUT
		if tech["automobilism"].researched == false then
			disable_shortcuts_2("car-finder", "spidertron", "car-finder-button")
		end

		disable_shortcuts_2("circuit-checker", "circuit-network", "check-circuit")
		disable_shortcuts_2("Kux-OrbitalIonCannon", "orbital-ion-cannon", "ion-cannon-targeter")
		disable_shortcuts_2("ModuleInserter", "modules", "module-inserter")

		if mods["Nanobots"] then
			disable_shortcuts_2("PickerInventoryTools", "personal-roboport-equipment", "toggle-equipment-bot-chip-feeder")
			disable_shortcuts_2("PickerInventoryTools", "personal-roboport-equipment", "toggle-equipment-bot-chip-items")
			disable_shortcuts_2("PickerInventoryTools", "personal-roboport-equipment", "toggle-equipment-bot-chip-launcher")
			disable_shortcuts_2("PickerInventoryTools", "personal-roboport-equipment", "toggle-equipment-bot-chip-nanointerface")
			disable_shortcuts_2("PickerInventoryTools",  "personal-roboport-equipment", "toggle-equipment-bot-chip-trees")
		end

		disable_shortcuts_2("pump", "oil-processing", "pump-shortcut")
		disable_shortcuts_2("RailSignalPlanner", "rail-signals", "give-rail-signal-planner")
		disable_shortcuts_2("Spider_Control", "spidertron", "squad-spidertron-follow")
		disable_shortcuts_2("Spider_Control", "spidertron", "squad-spidertron-remote")
		disable_shortcuts_2("Spider_Control", "spidertron", "squad-spidertron-list")
		disable_shortcuts_2("Spider_Control", "spidertron", "squad-spidertron-link-tool")
		disable_shortcuts_2("SpidertronWaypoints", "spidertron", "spidertron-remote-waypoint")
		disable_shortcuts_2("SpidertronWaypoints", "spidertron", "spidertron-remote-patrol")
		disable_shortcuts_2("VehicleSnap", "automobilism", "VehicleSnap-shortcut")

	end)
end
