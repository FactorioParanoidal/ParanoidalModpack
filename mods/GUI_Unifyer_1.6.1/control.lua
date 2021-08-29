local mod_gui = require("mod-gui")
local gui_button_style = "slot_button_notext"
local gui_button_style_whitetext = "slot_button_whitetext"

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

local function change_one_icon(player, sprite, button, tooltip)
	if player and player.valid and sprite and button then
		local button_flow = mod_gui.get_button_flow(player)
		local modbutton = button_flow[button]
		if modbutton then
			if modbutton.type == "button" or modbutton.type == "sprite-button" then
				modbutton.style = gui_button_style
				set_button_sprite(modbutton, sprite)
				if tooltip then
					modbutton.tooltip = tooltip
				end
			end
		end
	end
end

local function fix_buttons(player)
	if not player or not player.valid then return end
	local button_flow = mod_gui.get_button_flow(player)
	local iconlist = {
		{"helmod_button", 				"helmod_planner-command", 				{'guiu.helmod_button'}},
		{"factoryplanner_button", 		"fp_button_toggle_interface", 			{'guiu.factoryplanner_button'}},
		{"moduleinserter_button", 		"module_inserter_config_button", 		{'guiu.moduleinserter_button'}},
		{"placeables_button", 			"buttonPlaceablesVisible"},
		{"todolist_button", 			"todo_maximize_button", 				{'guiu.todolist_button'}},
		{"creativemod_button", 			"creative-mod_main-menu-open-button"},
		{"beastfinder_button", 			"beastfinder-menu-button", 				{'guiu.beastfinder_button'}},
		{"bobclasses_button", 			"bob_avatar_toggle_gui"},
		{"bobinserters_button", 		"bob_logistics_inserter_button"},
		{"cleanmap_button", 			"CleanMap"},
		{"cleanmap_button", 			"DeleteEmptyChunks"},
		{"deathcounter_button", 		"DeathCounterMainButton", 				{'guiu.deathcounter_button'}},
		{"ingteb_button", 				"ingteb"},
		{"outpostplanner_button", 		"OutpostBuilder"},
		{"rocketsilostats_button", 		"rocket-silo-stats-toggle", 			{'guiu.rocketsilostats_button'}},
		{"schallsatellitecontroller_button", "Schall-SC-mod-button"},
		{"actualcrafttimesremade_button", "ACTR_mod_button"},
		{"betterbotsfixed_button", 		"betterbots_top_btn", 					{'guiu.betterbotsfixed_button'}},
		{"changemapsettings_button", 	"change-map-settings-toggle-config", 	{'guiu.changemapsettings_button'}},
		{"doingthingsbyhand_button", 	"DoingThingsByHandMainButton", 			{'guiu.doingthingsbyhand_button'}},
		{"facautoscreenshot_button", 	"togglegui", 							{'guiu.facautoscreenshot_button'}},
		{"killlostbots_button", 		"KillLostBots"},
		{"kraskaskatotalrawresourcescalc_button", "ttrrc_main_frame_button", 	{'guiu.kraskaskatotalrawresourcescalc_button'}},
		{"kuxcraftingtools_button", 	"CraftNearbyGhostItemsButton"},
		{"kuxorbitalioncannon_button", 	"ion-cannon-button", 					{'guiu.kuxorbitalioncannon_button'}},
		{"markers_button", 				"markers_gui_toggle", 					{'guiu.markers_button'}},
		{"notenoughtodo_button", 		"TODO_CLICK01_", 						{'guiu.notenoughtodo_button'}},
		{"oshahotswap_button", 			"hotswap-menu-button", 					{'guiu.oshahotswap_button'}},
		{"pickerinventorytools_button", "filterfill_requests"},
		{"poweredentities_button", 		"poweredEntitiesRecalculateButton", 	{'guiu.poweredentities_button'}},
		{"researchcounter_button", 		"research-counter-button", 				{'guiu.researchcounter_button'}},
		{"richtexthelper_button", 		"RICH_CLICK_20_player01", 				{'guiu.richtexthelper_button'}},
		{"ritnteleportation_button", 	"ritn-button-main", 					{'guiu.ritnteleportation_button'}},
		{"solarcalc_button", 			"kaktusbot-sc-open-calc-button", 		{'guiu.solarcalc_button'}},
		{"solarratio_button", 			"niet-sr-guibutton"},
		{"spacemod_button", 			"space_toggle_button", 					{'guiu.spacemod_button'}},
		{"trainlog_button", 			"train_log"},
		{"trainpubsub_button", 			"tm_sprite_button"},
		{"upgradeplannernext_button", 	"upgrade_planner_config_button"},
		{"whatsmissing_button", 		"whats-missing-button"},
		--{"attachnotes_button", ""},
		--{"avatars_button", ""},
		--{"blackmarket2_button", ""},
		--{"modmashsplinterboom_button", "landmine-toggle-button"},
		--{"modmashsplinternewworlds_button", "planets-toggle-button"},
		--{"picksrocketstats_button", "pi_rss_but_toggle"},
		--{"dana_button", "modGuiButton"}, -- can't find the button name!
		--{"deleteadjacentchunk_button", ""},
		--{"schallendgameevolution_button", "Schall-EE-mod-button"},
		--{"nullius_button", ""},
		--{"newgameplus_button", ""},
	}

	for _, k in pairs(iconlist) do
		if k[3] then
			change_one_icon(player, k[1], k[2], k[3])
		elseif k[2] then
			change_one_icon(player, k[1], k[2])
		end
	end

	--game.print(serpent.block(mod_gui.get_button_flow(player)))

	--------------------------------
	--------- UNIQUE ONES ----------
	--------------------------------

	-- what-is-it-really-used-for
	local wiiuf_button = button_flow.wiiuf_flow and button_flow.wiiuf_flow.search_flow and button_flow.wiiuf_flow.search_flow["looking-glass"]
	if wiiuf_button then
		wiiuf_button.style = gui_button_style
		wiiuf_button.tooltip = {'guiu.wiiuf_button'}
		set_button_sprite(wiiuf_button, "wiiuf_button")
	end

	-- LandfillEverythingU
	local landfilleverythingu_button = button_flow.le_flow and button_flow.le_flow.le_button
	if landfilleverythingu_button then
		landfilleverythingu_button.style = gui_button_style
		set_button_sprite(landfilleverythingu_button, "landfilleverythingu_button")
	end

	-- TheFatController
	local thefatcontroller_button = button_flow.fatControllerButtons and button_flow.fatControllerButtons.toggleTrainInfo
	if thefatcontroller_button then
		thefatcontroller_button.style = gui_button_style
		thefatcontroller_button.tooltip = {'guiu.thefatcontroller_button'}
		set_button_sprite(thefatcontroller_button, "thefatcontroller_button")
	end

	-- quickbarimportexport
	if button_flow["qbie_flow_choose_action"] then
		local quickbarimportexport_button = button_flow["qbie_flow_choose_action"]["qbie_button_show_options"]
		local quickbarimport_button = button_flow["qbie_flow_choose_action"]["qbie_button_import"]
		local quickbarexport_button = button_flow["qbie_flow_choose_action"]["qbie_button_export"]
		if quickbarimportexport_button then
			quickbarimportexport_button.style = gui_button_style
			set_button_sprite(quickbarimportexport_button, "quickbarimportexport_button")
		end
		if quickbarimport_button then
			quickbarimport_button.style = gui_button_style
			set_button_sprite(quickbarimport_button, "quickbarimport_button")
		end
		if quickbarexport_button then
			quickbarexport_button.style = gui_button_style
			set_button_sprite(quickbarexport_button, "quickbarexport_button")
		end
	end

	-- AttilaZoomMod
	for i=1,15 do
		local attilazoommod_button = button_flow["Attila_zm_btn_"..tostring(i)]
		if attilazoommod_button then
			attilazoommod_button.style = gui_button_style_whitetext
			attilazoommod_button.tooltip = {'guiu.attilazoommod_button'}
			set_button_sprite(attilazoommod_button, "attilazoommod_button")
		end
	end

	-- AutoTrash
	local autotrash_button = button_flow["at_config_button"]
	if autotrash_button then
		autotrash_button.style = gui_button_style
	end

	-- TogglePeacefulMode
	local togglepeacefulmode_button = button_flow["tpm-button"]
	if togglepeacefulmode_button and togglepeacefulmode_button.type == "sprite-button" then
		togglepeacefulmode_button.style = gui_button_style
		togglepeacefulmode_button.tooltip = {'guiu.togglepeacefulmode_button'}
	end

end

--Factorissimo2
local function update_factorissimo(event)
	if event then
		local player = game.players[event.player_index]
		if not player or not player.valid then return end
		local button_flow = mod_gui.get_button_flow(player)
		if player.force.technologies["factory-preview"] and player.force.technologies["factory-preview"].researched and event.element and event.element.valid and event.element.name == "factory_camera_toggle_button" and button_flow.factory_camera_toggle_button then
			if button_flow.factory_camera_toggle_button.sprite == "technology/factory-architecture-t1" then
				button_flow.factory_camera_toggle_button.sprite = "factorissimo2_button"
				button_flow.factory_camera_toggle_button.tooltip = {'guiu.factorissimo2_button'}
			elseif button_flow.factory_camera_toggle_button.sprite == "technology/factory-preview" then
				button_flow.factory_camera_toggle_button.sprite = "factorissimo2_inspect_button"
				button_flow.factory_camera_toggle_button.tooltip = {'guiu.factorissimo2_button'}
			end
		end
	else
		for idx, player in pairs(game.players) do
			if player and player.valid then
				local button_flow = mod_gui.get_button_flow(player)
				if player.force.technologies["factory-preview"] and player.force.technologies["factory-preview"].researched and button_flow.factory_camera_toggle_button then
					if button_flow.factory_camera_toggle_button.sprite == "technology/factory-architecture-t1" then
						button_flow.factory_camera_toggle_button.sprite = "factorissimo2_button"
						button_flow.factory_camera_toggle_button.tooltip = {'guiu.factorissimo2_button'}
					elseif button_flow.factory_camera_toggle_button.sprite == "technology/factory-preview" then
						button_flow.factory_camera_toggle_button.sprite = "factorissimo2_inspect_button"
						button_flow.factory_camera_toggle_button.tooltip = {'guiu.factorissimo2_button'}
					end
				end
			end
		end
	end
end

local function on_player_cursor_stack_changed(event)
	local player = game.players[event.player_index]
    if not player or not player.valid then return end
    if player.is_cursor_blueprint() then
    	local button_flow = mod_gui.get_button_flow(player)

    	-- blueprint-request
    	local blueprintrequest_button = button_flow["blueprint-request-button"]
		if blueprintrequest_button then
			blueprintrequest_button.style = gui_button_style
			set_button_sprite(blueprintrequest_button, "blueprintrequest_button")
		end
    end
end

local function on_gui_opened(event)
	local player = game.players[event.player_index]
    if not player or not player.valid then return end
    local button_flow = mod_gui.get_button_flow(player)

    -- PickerInventoryTools
    local requests = button_flow["filterfill_requests"]
    if requests then
    	if requests.filterfill_requests_btn_bp then requests.filterfill_requests_btn_bp.style = gui_button_style end
    	if requests.filterfill_requests_btn_2x then requests.filterfill_requests_btn_2x.style = gui_button_style end
    	if requests.filterfill_requests_btn_5x then requests.filterfill_requests_btn_5x.style = gui_button_style end
    	if requests.filterfill_requests_btn_10x then requests.filterfill_requests_btn_10x.style = gui_button_style end
    	if requests.filterfill_requests_btn_max then requests.filterfill_requests_btn_max.style = gui_button_style end
    	if requests.filterfill_requests_btn_0x then requests.filterfill_requests_btn_0x.style = gui_button_style end
    end
    local filters = button_flow["filterfill_filters"]
    if filters then
    	if filters.filterfill_filters_btn_all then filters.filterfill_filters_btn_all.style = gui_button_style end
    	if filters.filterfill_filters_btn_down then filters.filterfill_filters_btn_down.style = gui_button_style end
    	if filters.filterfill_filters_btn_right then filters.filterfill_filters_btn_right.style = gui_button_style end
    	if filters.filterfill_filters_btn_set_all then filters.filterfill_filters_btn_set_all.style = gui_button_style end
    	if filters.filterfill_filters_btn_clear_all then filters.filterfill_filters_btn_clear_all.style = gui_button_style end
    end
end

local function on_init()
	for idx, player in pairs(game.players) do
		fix_buttons(player)
	end
	update_factorissimo()
end

local function on_configuration_changed()
	for idx, player in pairs(game.players) do
		fix_buttons(player)
	end
	update_factorissimo()
end

local function on_research_finished()
	for idx, player in pairs(game.players) do
		fix_buttons(player)
	end
	update_factorissimo()
end

local function on_gui_click(event)
	local player = game.players[event.player_index]
	fix_buttons(player)
	update_factorissimo(event)
end


local function on_player_created(event)
	fix_buttons(game.players[event.player_index])
end

local function on_player_changed_surface(event)
	fix_buttons(game.players[event.player_index])
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_game_created_from_scenario, on_init)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_research_finished, on_research_finished)
script.on_event(defines.events.on_player_display_resolution_changed, on_gui_click)
script.on_event(defines.events.on_player_changed_surface, on_player_changed_surface)