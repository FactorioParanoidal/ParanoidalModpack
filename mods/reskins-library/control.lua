-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Requires
---@diagnostic disable-next-line: different-requires

---@type Reskins.Lib.Version
local _version = require("__reskins-library__.api.version")

---@type Reskins.Control
local _control = require("__reskins-library__.prototypes.functions.control-functions")

---The color to use for message notifications.
local message_color = "#9cdcfe" -- Light blue

---
---Checks for supported mods for which a reskin mod is missing, and notifies the player if so.
---
---@param player LuaPlayer # The player to notify.
local function check_for_missing_reskin(player)
	local supported_mods = {
		angels = {
			"angelsrefining",
			"angelssmelting",
			"angelspetrochem",
			"angelsbioprocessing",
			"angelsaddons-storage",
			"angelsindustries",
			-- "angelsexploration",
			-- "angelsaddons-cab",
			-- "angelsaddons-mobility",
		},
		bobs = {
			"bobassembly",
			-- "bobclasses",
			"bobelectronics",
			"bobequipment",
			-- "bobenemies",
			"bobgreenhouse",
			-- "bobinserters",
			"boblogistics",
			"bobmining",
			"bobmodules",
			"bobores",
			"bobplates",
			"bobpower",
			"bobrevamp",
			"bobtech",
			"bobvehicleequipment",
			"bobwarfare",
		},
		compatibility = {
			"aai-loaders",
			"miniloader",
			"loaders-modernized",
			"miniloader-redux",
			"LoaderRedux",
			"deadlock-beltboxes-loaders",
			"vanilla-loaders-hd",
			"DeadlockCrating",
			"mini-machines",
			"CircuitProcessing",
			"angels-smelting-extended",
			"Clowns-Processing",
			"extendedangels",
			"RealisticReactorGlow",
			"P-U-M-P-S",
			"NauvisDay",
			"classic-beacon",
			"classic-mining-drill",
			"semi-classic-mining-drill",
			"IntermodalContainers",
		},
	}

	-- Make sure at least one reskin mod is present
	if script.active_mods["reskins-bobs"] or script.active_mods["reskins-angels"] or script.active_mods["reskins-compatibility"] then
		-- Iterate through each of the reskin mods
		for reskin, mod_list in pairs(supported_mods) do
			-- Check if notification for this reskin is needed
			if storage.notify[reskin].status then
				goto continue
			end
			local count = -1
			local notify_mod_name

			-- Check for each of the mods supported by the reskin mod, store the first result found, count the number of matches
			for _, mod in pairs(mod_list) do
				-- A supported mod is present
				if script.active_mods[mod] then
					-- Store the name of the first positive result
					if count == -1 then
						notify_mod_name = mod
					end
					count = count + 1
				end
			end

			-- Notify the player, set the flag not to do so again
			if notify_mod_name then
				storage.notify[reskin].status = true
				if count == 0 then
					player.print({
						"",
						"[",
						{ "reskins-library.reskins-suite-name" },
						"] ",
						{
							"reskins-notifications.reskins-notify-missing-single",
							{ "", "[color=" .. message_color .. "]", { "reskins-supported-mods." .. notify_mod_name }, "[/color]" },
							{ "", "[color=" .. message_color .. "]", { "reskins-library.reskins-" .. reskin .. "-mod-name" }, "[/color]" },
						},
					})
				else
					player.print({
						"",
						"[",
						{ "reskins-library.reskins-suite-name" },
						"] ",
						{
							"reskins-notifications.reskins-notify-missing-multiple",
							{ "", "[color=" .. message_color .. "]", { "reskins-supported-mods." .. notify_mod_name }, "[/color]" },
							count,
							{ "", "[color=" .. message_color .. "]", { "reskins-library.reskins-" .. reskin .. "-mod-name" }, "[/color]" },
						},
					})
				end
			end

			-- Label to continue to the next iteration
			::continue::
		end
	end
end

----------------------------------------------------------------------------------------------------
-- ON INIT
----------------------------------------------------------------------------------------------------
script.on_init(_control.on_init)

----------------------------------------------------------------------------------------------------
-- ON CONFIGURATION CHANGED
----------------------------------------------------------------------------------------------------

---
---Notify the player of changes that occurred at particular versions.
---
---@param data ConfigurationChangedData # The data from the configuration change event.
local function notify(data)
	for _, player in pairs(game.connected_players) do
		if player.admin then
			if player.mod_settings["reskins-lib-display-notifications"].value == true then
				-- Check for supported mods for which a reskin mod is missing, and notify
				check_for_missing_reskin(player)

				-- Notify of changes when updated in a save we were already present in
				if data.mod_changes and data.mod_changes["reskins-library"] and data.mod_changes["reskins-library"].old_version then
					-- 1.0.4 update
					if _version.is_older(data.mod_changes["reskins-library"].old_version, "1.0.4") then
						player.print({ "", "[", { "reskins-library.reskins-suite-name" }, "] ", { "reskins-updates.reskins-lib-1-0-4-update", { "mod-setting-name.reskins-lib-blend-mode" } } })
					end

					-- 1.1.3 update
					if not _version.is_older(data.mod_changes["reskins-library"].old_version, "1.1.3") then
						if script.active_mods["reskins-bobs"] and not script.active_mods["reskins-compatibility"] then
							player.print({
								"",
								"[",
								{ "reskins-library.reskins-suite-name" },
								"] ",
								{ "reskins-updates.reskins-lib-1-1-3-update-bobs", { "", "[color=" .. message_color .. "]", { "reskins-library.reskins-compatibility-mod-name" }, "[/color]" } },
							})
						end

						if script.active_mods["reskins-angels"] and not script.active_mods["reskins-compatibility"] then
							player.print({
								"",
								"[",
								{ "reskins-library.reskins-suite-name" },
								"] ",
								{ "reskins-updates.reskins-lib-1-1-3-update-angels", { "", "[color=" .. message_color .. "]", { "reskins-library.reskins-compatibility-mod-name" }, "[/color]" } },
							})
						end
					end
				end
			end
		end
	end
end

script.on_configuration_changed(notify)

----------------------------------------------------------------------------------------------------
-- RUNTIME
----------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_player_joined_game, function(event)
	---@cast event EventData.on_player_joined_game
	local player = game.get_player(event.player_index)
	if player and player.admin then
		if player.mod_settings["reskins-lib-display-notifications"].value == true then
			-- Check for supported mods for which a reskin mod is missing, and notify
			check_for_missing_reskin(player)
		end
	end
end)
