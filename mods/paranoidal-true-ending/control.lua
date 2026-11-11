-- True ending (ПР-084): Space Age's victory at the solar system edge is switched off; the edge ends chapter 1 (a message
-- and a custom event for the achievements), the victory comes when a platform reaches the Shattered Planet with the Ark
-- in its hub. Every result is kept in storage, so a loaded save neither repeats nor forgets them (the original mod kept
-- its "finished" list in a local table: lost on load, the victory could come again).
--
-- Remote interface "paranoidal-true-ending":
--   get_on_ending_event()  id of the custom event {fact = "chapter-1" | "true-ending", force_index, platform_index}
--   get_state()            {chapter_one = {[force_index] = tick}, finished = {[force_index] = {tick, platform}},
--                           told = {[platform_index] = true}, victory_call = how the game state was set}
local names = require("shared.names")

local ending_event = script.generate_event_name()
local BEYOND = {[names.edge] = true, [names.halfway] = true, [names.belt] = true, [names.target] = true}
local COLOR = {r = 1, g = 0.8, b = 0.35}
local SANDBOX_FORCE = "bpsb-sb-"

local function ensure_storage()
	storage.chapter_one = storage.chapter_one or {}
	storage.finished = storage.finished or {}
	storage.told = storage.told or {}
end

-- Space Age's freeplay script would declare the victory at the edge: switch it off (its own flag, kept in its storage).
local function disable_space_age_victory()
	local interface = remote.interfaces["space_finish_script"]
	if interface and interface.set_no_victory then
		remote.call("space_finish_script", "set_no_victory", true)
		log("paranoidal-true-ending: Space Age victory at the solar system edge switched off, no_victory = "
			.. tostring(interface.get_no_victory and remote.call("space_finish_script", "get_no_victory")))
	end
end

script.on_init(function()
	ensure_storage()
	disable_space_age_victory()
end)

script.on_configuration_changed(function()
	ensure_storage()
	disable_space_age_victory()
end)

local function is_sandbox(force)
	return script.active_mods["blueprint-sandboxes"] ~= nil and string.sub(force.name, 1, #SANDBOX_FORCE) == SANDBOX_FORCE
end

local function location_name(name)
	return {"space-location-name." .. name}
end

local function arks(platform)
	local hub = platform.hub
	if not (hub and hub.valid) then return 0 end
	local inventory = hub.get_inventory(defines.inventory.hub_main)
	if not inventory then return 0 end
	local count = 0
	for _, stack in pairs(inventory.get_contents()) do
		if stack.name == names.ark then count = count + stack.count end
	end
	return count
end

local function chapter_one(force, platform)
	if storage.chapter_one[force.index] then return end
	storage.chapter_one[force.index] = game.tick
	force.print({"paranoidal-true-ending.chapter-one", platform.name, location_name(names.edge),
		location_name(names.target), {"technology-name." .. names.promethium_technology},
		{"technology-name." .. names.technology}, {"item-name." .. names.ark}}, {color = COLOR})
	script.raise_event(ending_event, {fact = "chapter-1", force_index = force.index, platform_index = platform.index})
end

local function set_victory(force)
	-- the same call as Space Age's own victory script; the engine's list of keys has no victorious_force
	local ok = pcall(game.set_game_state, {game_finished = true, player_won = true, can_continue = true,
		victorious_force = force})
	if ok then return "with victorious_force" end
	game.set_game_state({game_finished = true, player_won = true, can_continue = true})
	return "without victorious_force"
end

local function true_ending(force, platform)
	if storage.finished[force.index] then return end
	storage.finished[force.index] = {tick = game.tick, platform = platform.name}
	game.set_win_ending_info({
		title = {"paranoidal-true-ending.victory-title"},
		message = {"paranoidal-true-ending.victory-message", platform.name, {"item-name." .. names.ark},
			location_name(names.target)},
		final_message = {"paranoidal-true-ending.victory-final"},
		image_path = "__base__/script/freeplay/victory-space-age.png",
	})
	game.reset_game_state()
	local fame = pcall(function() game.enable_galaxy_of_fame_button = true end)
	storage.victory_call = set_victory(force) .. (fame and "" or ", no galaxy of fame button")
	log("paranoidal-true-ending: true ending for force " .. force.name .. " (" .. storage.victory_call .. ")")
	script.raise_event(ending_event, {fact = "true-ending", force_index = force.index, platform_index = platform.index})
end

local function on_platform_changed_state(event)
	local platform = event.platform
	if not (platform and platform.valid) then return end
	local force = platform.force
	if not (force and force.valid) or is_sandbox(force) then return end
	local location = platform.last_visited_space_location
	local name = location and location.name
	if name ~= names.target then storage.told[platform.index] = nil end
	if not (name and BEYOND[name]) then return end
	-- every place beyond the edge counts: a platform may pass the edge without stopping there
	chapter_one(force, platform)
	if name ~= names.target or storage.finished[force.index] then return end
	if arks(platform) > 0 then
		true_ending(force, platform)
	elseif not storage.told[platform.index] then
		storage.told[platform.index] = true
		force.print({"paranoidal-true-ending.no-ark", platform.name, location_name(names.target),
			{"item-name." .. names.ark}}, {color = COLOR})
	end
end

script.on_event(defines.events.on_space_platform_changed_state, on_platform_changed_state)

remote.add_interface("paranoidal-true-ending", {
	get_on_ending_event = function() return ending_event end,
	get_state = function()
		return {chapter_one = storage.chapter_one, finished = storage.finished, told = storage.told,
			victory_call = storage.victory_call}
	end,
})
