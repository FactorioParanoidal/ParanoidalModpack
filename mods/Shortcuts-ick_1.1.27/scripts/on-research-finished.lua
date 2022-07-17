--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of on-research-finished.lua:
	* Functions
	* Special cases
	* Mod
	* Mod with own shortcut
]]

if settings.startup["ick-compatibility-mode"].value == false then
	script.on_event(defines.events.on_research_finished, function(event)
		for _, player in pairs(event.research.force.players) do

		-- FUNCTIONS
		local research = event.research.name
		local mods = game.active_mods
		local setting = settings.startup

		local function enable_shortcut(setting_name, name)
			if setting[setting_name].value then
				player.set_shortcut_available(name, true)
			end
		end

		local function enable_shortcut_1(mod_name, tech_name, name)
			if mods[mod_name] and setting[name].value and research == tech_name then
				player.set_shortcut_available(name, true)
			end
		end

		local function enable_shortcut_2(mod_name, tech_name, name)
			if mods[mod_name] and research == tech_name then
				player.set_shortcut_available(name, true)
			end
		end


		-- SPECIAL CASES
		if research == "railway" then
			enable_shortcut("rail-block-visualization-toggle", "rail-block-visualization-toggle")
		end

		if research == "artillery" then
			enable_shortcut("artillery-targeting-remote", "artillery-targeting-remote")
		end

		local artillery_toggle = setting["artillery-toggle"].value
		if research == "artillery" and (artillery_toggle == "both" or artillery_toggle == "artillery-wagon" or artillery_toggle == "artillery-turret") then
			player.set_shortcut_available("artillery-jammer-tool", true)
		end

		local spidertron_remote = setting["spidertron-remote"].value
		if research == "spidertron" and (spidertron_remote == "enabled" or spidertron_remote == "enabled-hidden") then
			player.set_shortcut_available("spidertron-remote", true)
		end


		-- MOD
		if mods["aai-programmable-vehicles"] and (research == "automobilism" or research == "spidertron") then
			enable_shortcut("aai-remote-controls", "path-remote-control")
			enable_shortcut("aai-remote-controls", "unit-remote-control")
		end

		if mods["AdvancedArtilleryRemotesContinued"] and setting["artillery-targeting-remote"].value and research == "artillery" then
			player.set_shortcut_available("artillery-cluster-remote", true)
			player.set_shortcut_available("artillery-discovery-remote", true)
		end

		if (mods["artillery-bombardment-remote"] or mods["artillery-bombardment-remote-reloaded"]) and setting["artillery-targeting-remote"].value then
			if research == "artillery-bombardment-remote" then
				player.set_shortcut_available("artillery-bombardment-remote", true)
			end
			if research == "smart-artillery-bombardment-remote" then
				player.set_shortcut_available("smart-artillery-bombardment-remote", true)
			end
			if research == "smart-artillery-exploration-remote" then
				player.set_shortcut_available("smart-artillery-exploration-remote", true)
			end
		end

		enable_shortcut_1("AtomicArtilleryRemote", "atomic-artillery", "atomic-artillery-targeting-remote")
		-- enable_shortcut_1("jetpack", "jetpack-1", "jetpack")
		enable_shortcut_1("landmine-thrower", "landmine-thrower", "landmine-thrower-remote")
		enable_shortcut_1("MIRV", "mirv-technology", "mirv-targeting-remote")
		enable_shortcut_1("VehicleWagon2", "vehicle-wagons", "winch")
		enable_shortcut_1("WellPlanner", "oil-processing", "well-planner")


		-- MOD WITH OWN SHORTCUT
		if mods["car-finder"] and (research == "automobilism" or research == "spidertron") then
			player.set_shortcut_available("car-finder-button", true)
		end

		enable_shortcut_2("circuit-checker", "circuit-network", "check-circuit")
		enable_shortcut_2("Kux-OrbitalIonCannon", "orbital-ion-cannon", "ion-cannon-targeter")
		enable_shortcut_2("ModuleInserter", "modules", "module-inserter")
		enable_shortcut_2("ModuleInserterER", "modules", "module-inserter")

		if mods["Nanobots"] then
			enable_shortcut_2("PickerInventoryTools", "personal-roboport-equipment", "toggle-equipment-bot-chip-feeder")
			enable_shortcut_2("PickerInventoryTools", "personal-roboport-equipment", "toggle-equipment-bot-chip-items")
			enable_shortcut_2("PickerInventoryTools", "personal-roboport-equipment", "toggle-equipment-bot-chip-launcher")
			enable_shortcut_2("PickerInventoryTools", "personal-roboport-equipment", "toggle-equipment-bot-chip-nanointerface")
			enable_shortcut_2("PickerInventoryTools", "personal-roboport-equipment", "toggle-equipment-bot-chip-trees")
		end

		enable_shortcut_2("pump", "oil-processing", "pump-shortcut")
		enable_shortcut_2("RailSignalPlanner", "rail-signals", "give-rail-signal-planner")
		enable_shortcut_2("RailSignalPlannerNeo", "rail-signals", "give-rail-signal-planner")
		enable_shortcut_2("Spider_Control", "spidertron", "squad-spidertron-follow")
		enable_shortcut_2("Spider_Control", "spidertron", "squad-spidertron-remote")
		enable_shortcut_2("Spider_Control", "spidertron", "squad-spidertron-list")
		enable_shortcut_2("Spider_Control", "spidertron", "squad-spidertron-link-tool")
		enable_shortcut_2("SpidertronWaypoints", "spidertron", "spidertron-remote-waypoint")
		enable_shortcut_2("SpidertronWaypoints", "spidertron", "spidertron-remote-patrol")
		enable_shortcut_2("VehicleSnap", "automobilism", "VehicleSnap-shortcut")

		end
	end)
end
