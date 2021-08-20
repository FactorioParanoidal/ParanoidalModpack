local mod_gui = require("mod-gui")

local function set_button_sprite(button, spritepath)
	if spritepath == nil then
		spritepath = ""
	end

	if button.type == "button" then
		-- normal button, we need to add a sprite as child
		if spritepath == "" then
			if button["button_sprite"] then
				button["button_sprite"].destroy()
			end
		else
			if button["button_sprite"] == nil then
				local sprite = button.add({type="sprite", name="button_sprite", sprite=spritepath, ignored_by_interaction=true })
				sprite.style.stretch_image_to_widget_size = true
				sprite.style.size = {32,32}
			else
				button["button_sprite"].sprite = spritepath
			end
		end
	end

	if button.type == "sprite-button" then
		-- sprite button, no special handling
		button.sprite = spritepath
		button.hovered_sprite = spritepath
		button.clicked_sprite = spritepath
	end
end

local function fix_buttons(player)
	local button_flow = mod_gui.get_button_flow(player)

	-- helmod
	local helmod_button = button_flow["helmod_planner-command"]
	if helmod_button then
		helmod_button.style = "slot_button"
		set_button_sprite(helmod_button, "helmod")
	end

	-- factoryplanner
	local factoryplanner_button = button_flow["fp_button_toggle_interface"]
	if factoryplanner_button then
		factoryplanner_button.style = "slot_button_notext"
		set_button_sprite(factoryplanner_button, "factoryplanner")
	end

	-- ModuleInserter
	local moduleinserter_button = button_flow["module_inserter_config_button"]
	if moduleinserter_button then
		moduleinserter_button.style = "slot_button"
	end

	-- Placeables
	local placeables_button = button_flow["buttonPlaceablesVisible"]
	if placeables_button then
		placeables_button.style = "slot_button_notext"
		set_button_sprite(placeables_button, "placeables")
	end

	-- Todo-List
	local todolist_button = button_flow["todo_maximize_button"]
	if todolist_button then
		todolist_button.style = "slot_button_notext"
		set_button_sprite(todolist_button, "todolist")
	end

	-- what-is-it-really-used-for
	local wiiuf_button = button_flow.wiiuf_flow and button_flow.wiiuf_flow.search_flow and button_flow.wiiuf_flow.search_flow["looking-glass"]
	if wiiuf_button then
		wiiuf_button.style = "slot_button"
		set_button_sprite(wiiuf_button, "what-is-it-really-used-for")
	end

	-- creative-mod
	local creativemod_button = button_flow["creative-mod_main-menu-open-button"]
	if creativemod_button then
		creativemod_button.style = "slot_button"
		set_button_sprite(creativemod_button, "creativemod_button")
	end

	-- BeastFinder
	local beastfinder_button = button_flow["beastfinder-menu-button"]
	if beastfinder_button then
		beastfinder_button.style = "slot_button"
		set_button_sprite(beastfinder_button, "beastfinder_button")
	end

end


local function on_init()
	for idx, player in pairs(game.players) do
		fix_buttons(player)
	end
end

local function on_configuration_changed()
	for idx, player in pairs(game.players) do
		fix_buttons(player)
	end
end

local function on_player_created(event)
	fix_buttons(game.players[event.player_index])
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_gui_click, on_configuration_changed)