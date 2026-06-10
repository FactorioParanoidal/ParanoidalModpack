require("__SpaceModFeorasFork__/milestones")
local mod_gui = require("mod-gui")

storage = storage or {}

local function format_launch_log(ticks, player)
	local seconds = math.floor(ticks / 60)
	local minutes = math.floor(seconds / 60)
	local hours = math.floor(minutes / 60)

	local show_days = settings.get_player_settings(player)["SpaceX-log-days"].value or false
	if show_days then
		local days = math.floor(hours / 24)
		return string.format("%dd %02dh %02dm %02ds", days, hours % 24, minutes % 60, seconds % 60)
	else
		return string.format("%dh %02dm %02ds", hours, minutes % 60, seconds % 60)
	end
end

local function gui_open_log(player)
	local gui = mod_gui.get_frame_flow(player)
	local log = gui.spacex_log
	if not log then
		return
	end
	log.clear()
	local scroll = log.add({ type = "scroll-pane", name = "scroll" })
	scroll.style.maximal_height = 600
	local logtable =
		scroll.add({ type = "table", name = "spacex_log_table", column_count = 3, style = "SpaceMod_table_style" })
	logtable.style.column_alignments[1] = "center"
	logtable.style.column_alignments[2] = "center"
	logtable.draw_horizontal_lines = true
	logtable.draw_vertical_lines = true
	logtable.draw_horizontal_line_after_headers = true
	logtable.add({ type = "label", caption = { "spacex-log-launch" }, style = "caption_label" })
	logtable.add({ type = "label", caption = { "spacex-log-time" }, style = "caption_label" })
	logtable.add({ type = "label", caption = { "spacex-log-notes" }, style = "caption_label" })
	for i = #storage.launch_log, 1, -1 do
		local launch = storage.launch_log[i]
		logtable.add({ type = "label", caption = launch.number, style = "Launch_label_style" })
		logtable.add({ type = "label", caption = format_launch_log(launch.log, player), style = "Launch_label_style" })
		logtable.add({
			type = "textfield",
			name = "spacex-logdetail" .. i,
			enabled = player.admin,
			text = launch.detail,
		})
	end
end

local function gui_open_spacex(player)
	local gui = mod_gui.get_frame_flow(player)
	local frame = gui.space_progress_frame
	if not frame then
		return
	end
	frame.clear()

	-- Launch history, if any
	if storage.completed > 0 then
		local launch =
			frame.add({ type = "table", name = "launch_info", column_count = 2, style = "SpaceMod_item_table_style" })
		launch.add({ type = "label", caption = { "instellar-launch", storage.completed }, style = "caption_label" })
		local log_button = launch.add({
			type = "button",
			name = "launch_log",
			style = mod_gui.button_style,
			caption = { "spacex-log-caption" },
			tooltip = { "spacex-log-tooltip" },
		})
		log_button.style.height = 30

		-- Update log only if already visibile
		gui_open_log(player)
	end

	-- Current required items to launch
	local current_stage = storage.stages[storage.current_stage]
	frame.add({
		type = "label",
		caption = { "stage-" .. current_stage.number .. "-progress-stage", #storage.stages },
		style = "caption_label",
	})
	local items_to_launch = frame.add({
		type = "table",
		name = "stage-" .. current_stage.number,
		column_count = 2,
		style = "SpaceMod_item_table_style",
	})
	items_to_launch.style.column_alignments[2] = "center"
	items_to_launch.draw_horizontal_lines = true
	items_to_launch.draw_vertical_lines = true
	items_to_launch.draw_horizontal_line_after_headers = true
	items_to_launch.add({
		type = "label",
		caption = { "stage-" .. current_stage.number .. "-progress-title" },
		style = "caption_label",
	})
	items_to_launch.add({ type = "label", caption = { "progress-title" }, style = "caption_label" })
	for _, item in pairs(current_stage.requirements) do
		local item_name = items_to_launch.add({ type = "label", caption = { "SpaceX-Progress." .. item.item_name } })
		local item_prog = items_to_launch.add({ type = "label", caption = item.launched .. "/" .. item.required })
		if item.launched == item.required then
			item_name.style.font_color = { r = 0.7, g = 0.7, b = 0.7, a = 1.0 }
			item_prog.style.font_color = { r = 0.7, g = 0.7, b = 0.7, a = 1.0 }
		end
	end
end

local function update_combinator(combinator)
	if combinator.valid == true then
		local cb = combinator.get_or_create_control_behavior()
		local is_stage_combinator = combinator.name == "spacex-combinator-stage"
		local split_signal = settings.startup["SpaceX-split-combinator"].value
		local append_items = not is_stage_combinator
		local append_stage = (split_signal and is_stage_combinator) or (not split_signal and not is_stage_combinator)
		local current_stage = storage.stages[storage.current_stage]
		local signals = {}

		if append_items then
			for i, item in pairs(current_stage.requirements) do
				table.insert(signals, {
					name = item.item_name,
					count = item.required - item.launched,
					index = i,
				})
			end
		end
		if append_stage then
			table.insert(signals, {
				name = "signal-S",
				count = current_stage.number,
				index = #signals + 1,
			})
		end
		local cb_section = cb.get_section(1)
		for i = 1, cb_section.filters_count, 1 do
			cb_section.clear_slot(i)
		end
		for _, signal in pairs(signals) do
			cb_section.set_slot(signal.index, { value = signal.name, min = signal.count, max = signal.count })
		end
	end
end

local function update_all_combinators()
	for _, spacexCom in pairs(storage.combinators) do
		update_combinator(spacexCom.entity)
	end
end

local function init_launch_multiplier()
	if storage.launch_mult == nil or storage.launch_mult ~= settings.startup["SpaceX-launch-multiplier"].value then
		storage.launch_mult = settings.startup["SpaceX-launch-multiplier"].value or 1
		for _, stage in pairs(storage.stages) do
			for _, item in pairs(stage.requirements) do
				item.required = math.max(math.floor(item.base_required * storage.launch_mult + 0.5), 1)
			end
		end
		for _, player in pairs(game.players) do
			gui_open_spacex(player)
		end
	end
end

local function init_stages()
	if storage.stages == nil then
		storage.stages = {
			{
				number = 1,
				requirements = { { item_name = "satellite", base_required = 7, launched = 0 } },
			},
			{
				number = 2,
				requirements = {
					{ item_name = "drydock-structural", base_required = 10, launched = 0 },
					{ item_name = "drydock-assembly", base_required = 2, launched = 0 },
				},
			},
			{
				number = 3,
				requirements = {
					{ item_name = "protection-field", base_required = 1, launched = 0 },
					{ item_name = "fusion-reactor", base_required = 1, launched = 0 },
					{ item_name = "habitation", base_required = 1, launched = 0 },
					{ item_name = "life-support", base_required = 1, launched = 0 },
					{ item_name = "astrometrics", base_required = 1, launched = 0 },
					{ item_name = "command", base_required = 1, launched = 0 },
					{ item_name = "fuel-cell", base_required = 2, launched = 0 },
					{ item_name = "laser-cannon", base_required = 2, launched = 0 },
					{ item_name = "space-thruster", base_required = 4, launched = 0 },
					{ item_name = "hull-component", base_required = 10, launched = 0 },
					{ item_name = "ftl-drive", base_required = 1, launched = 0 },
				},
			},
		}
	end
	if not settings.startup["SpaceX-classic-mode"].value and #storage.stages == 3 then
		table.insert(storage.stages, {
			number = 4,
			requirements = {
				{ item_name = "exploration-satellite", base_required = 25, launched = 0 },
				{ item_name = "space-ai-robot", base_required = 2, launched = 0 },
				{ item_name = "space-water-tank", base_required = 2, launched = 0 },
				{ item_name = "space-oxygen-tank", base_required = 2, launched = 0 },
				{ item_name = "space-fuel-tank", base_required = 4, launched = 0 },
				{ item_name = "space-map", base_required = 1, launched = 0 },
			},
		})
	end
end

local function init_spacex()
	init_stages()
	storage.current_stage = storage.current_stage or 1
	init_launch_multiplier()
	storage.finished = storage.finished or false
	storage.combinators = storage.combinators or {}
	storage.completed = storage.completed or 0
	storage.launch_log = storage.launch_log or {}
	update_all_combinators()

	-- Set no victory via rocket launch
	for _, interface in pairs{ "silo_script", "better-victory-screen" } do
		if remote.interfaces[interface] and remote.interfaces[interface]["set_no_victory"] then
			remote.call(interface, "set_no_victory", true)
		end
	end
end

local function init_gui(player)
	local button = mod_gui.get_button_flow(player).space_toggle_button
	if button then
		if player.force.technologies["rocket-silo"].researched ~= true then
			button.destroy()
		end
		return
	end

	if player.force.technologies["rocket-silo"].researched then
		mod_gui.get_button_flow(player).add({
			type = "button",
			name = "space_toggle_button",
			style = mod_gui.button_style,
			caption = { "space-toggle-button-caption" },
		})
	end
end

script.on_configuration_changed(function(event)
	if event.mod_changes or event.mod_startup_settings_changed then
		-- Add existing combinators to global
		storage.combinators = {}
		for _, surface in pairs(game.surfaces) do
			for _, spacexCom in
				pairs(surface.find_entities_filtered({ type = "constant-combinator", name = "spacex-combinator" }))
			do
				table.insert(storage.combinators, { entity = spacexCom })
			end
			for _, spacexCom in
				pairs(
					surface.find_entities_filtered({ type = "constant-combinator", name = "spacex-combinator-stage" })
				)
			do
				table.insert(storage.combinators, { entity = spacexCom })
			end
		end
		-- Update launch mult and combinators
		storage.launch_mult = nil
		init_spacex()
		-- Check research
		for _, force in pairs(game.forces) do
			if force.technologies["space-assembly"].researched then
				-- Migration to enable recipe
				force.recipes["spacex-combinator"].enabled = true
				if settings.startup["SpaceX-split-combinator"].value then
					-- Enabled, was disabled before. Migration
					if force.recipes["spacex-combinator-stage"].enabled == false then
						force.recipes["spacex-combinator-stage"].enabled = true
						update_all_combinators()
					end
				else
					-- Disabled, was enabled before. Migration
					if force.recipes["spacex-combinator-stage"].enabled == true then
						force.recipes["spacex-combinator-stage"].enabled = false
						update_all_combinators()
					end
				end
			end
		end
		-- Check classic mode
		if storage.stages then
			if settings.startup["SpaceX-classic-mode"].value then
				if #storage.stages == 4 then
					table.remove(storage.stages, #storage.stages)
				end
				if storage.current_stage == 4 then
					storage.current_stage = 3
				end
			else
				if #storage.stages == 3 then
					init_stages()
				end
			end
		end
		-- Reset GUI
		if game.players ~= nil then
			for _, player in pairs(game.players) do
				local gui = mod_gui.get_frame_flow(player)
				local frame = gui.space_progress_frame
				if frame then
					frame.destroy()
				end
				local button = gui.space_toggle_button
				if button then
					button.destroy()
				end
				local log = gui.spacex_log
				if log then
					log.destroy()
				end
				init_gui(player)
			end
		end
	end
end)

local function gui_open_spacex_completed(player)
	local gui = mod_gui.get_frame_flow(player)
	local gui_spacex = gui.spacex_completed
	if gui_spacex then
		gui_spacex.destroy()
		return
	end
	gui_spacex = gui.add({
		type = "frame",
		name = "spacex_completed",
		direction = "vertical",
		style = mod_gui.frame_style,
	})
	gui_spacex.add({ type = "label", caption = { "spacex-launch-title" }, style = "caption_label" })
	gui_spacex.add({ type = "label", caption = { "spacex-completion-text" }, style = "Launch_label_style" })
	gui_spacex.add({ type = "label", caption = " ", style = "Launch_label_style" })
	for i = 1, 3 do
		gui_spacex.add({ type = "label", caption = { "spacex-completion-text" .. i }, style = "Launch_label_style" })
		gui_spacex.add({ type = "label", caption = " ", style = "Launch_label_style" })
	end
	if player.admin then
		gui_spacex.add({
			type = "button",
			name = "spacex_completion_button",
			style = mod_gui.button_style,
			caption = { "spacex-completion-caption" },
			tooltip = { "spacex-completion-tooltip" },
		})
	else
		gui_spacex.add({
			type = "button",
			name = "notadmin_button",
			style = mod_gui.button_style,
			caption = { "spacex-notadmin-caption" },
			tooltip = { "spacex-notadmin-tooltip" },
		})
	end
end

local function gui_open_space_completed_after()
	for _, p in pairs(game.players) do
		local gui_continue = mod_gui.get_frame_flow(p)
		local gui_continue_launch = gui_continue.spacex_completed
		gui_continue_launch = gui_continue.add({
			type = "frame",
			name = "spacex_completed",
			direction = "vertical",
			caption = { "spacex-continue-title" },
			style = mod_gui.frame_style,
		})
		for i = 1, 2 do
			gui_continue_launch.add({
				type = "label",
				caption = { "spacex-continue-text" .. i },
				style = "Launch_label_style",
			})
		end
		if p.admin then
			local sctable = gui_continue_launch.add({
				type = "table",
				name = "continue_msg_Table",
				column_count = 2,
				style = "SpaceMod_table_style",
			})
			sctable.style.minimal_width = 400
			sctable.style.horizontally_stretchable = true
			sctable.style.column_alignments[2] = "right"
			sctable.add({
				type = "button",
				name = "spacex_continue_button",
				style = mod_gui.button_style,
				caption = { "spacex-continue-caption" },
				tooltip = { "spacex-continue-tooltip" },
			})
			sctable.add({
				type = "button",
				name = "spacex_finish_button",
				style = mod_gui.button_style,
				caption = { "spacex-finish-caption" },
				tooltip = { "spacex-finish-tooltip" },
			})
		else
			gui_continue_launch.add({
				type = "button",
				name = "notadmin_button",
				style = mod_gui.button_style,
				caption = { "spacex-notadmin-caption" },
				tooltip = { "spacex-notadmin-tooltip" },
			})
		end
	end
end

script.on_event(defines.events.on_gui_text_changed, function(event)
	local element = event.element
	local player = game.players[event.player_index]
	if not player.admin then
		return
	end

	if string.find(element.name, "spacex-logdetail") then
		local cur_log = tonumber(string.match(element.name, "%d+"))
		storage.launch_log[cur_log].detail = element.text
	end
end)

local function on_entity_build(event)
	event.entity.operable = false
	table.insert(storage.combinators, { entity = event.entity })
	update_combinator(event.entity)
end
local event_filter = {
	{ filter = "name", name = "spacex-combinator", mode = "or" },
	{ filter = "name", name = "spacex-combinator-stage", mode = "or" },
}
script.on_event(defines.events.on_built_entity, on_entity_build, event_filter)
script.on_event(defines.events.on_robot_built_entity, on_entity_build, event_filter)

local function on_entity_cloned(event)
	event.destination.operable = false
	table.insert(storage.combinators, { entity = event.destination })
	update_combinator(event.destination)
end
script.on_event(defines.events.on_entity_cloned, on_entity_cloned, event_filter)

local function on_remove_entity(event)
	local entity = event.entity
	for i, combinator in ipairs(storage.combinators) do
		if combinator.entity == entity then
			table.remove(storage.combinators, i)
			return
		end
	end
end
script.on_event(defines.events.on_pre_player_mined_item, on_remove_entity, event_filter)
script.on_event(defines.events.on_robot_pre_mined, on_remove_entity, event_filter)
script.on_event(defines.events.on_entity_died, on_remove_entity, event_filter)

local function spacex_continue()
	storage.stages = nil
	storage.launch_mult = nil
	storage.current_stage = nil
	init_spacex()
	storage.finished = false
end

local function gui_open_stage_complete(player, stage_number)
	local gui = mod_gui.get_frame_flow(player)
	local gui_stage = gui.stage_complete
	if gui_stage then
		gui_stage.destroy()
		return
	end

	gui_stage = gui.add({
		type = "frame",
		name = "stage_complete",
		direction = "vertical",
		caption = { "stage-" .. stage_number .. "-completion-title" },
		style = mod_gui.frame_style,
	})
	gui_stage.add({
		type = "label",
		caption = { "stage-" .. stage_number .. "-completion-text" },
		style = "Launch_label_style",
	})
	gui_stage.add({
		type = "button",
		name = "stage_complete_button",
		style = mod_gui.button_style,
		caption = { "stage-" .. stage_number .. "-completion-caption" },
		tooltip = { "stage-" .. stage_number .. "-completion-tooltip" },
	})
end

local function close_all_spacex_completed_gui()
	for _, player in pairs(game.players) do
		local gui = mod_gui.get_frame_flow(player)
		local gui_spacex = gui.spacex_completed
		if gui_spacex then
			gui_spacex.destroy()
		end
	end
end

script.on_event(defines.events.on_gui_click, function(event)
	local clicked_button = event.element.name
	local player = game.players[event.player_index]
	local gui = mod_gui.get_frame_flow(player)
	local frame = gui.space_progress_frame
	local spacex_log = gui.spacex_log

	if clicked_button == "space_toggle_button" then
		if frame then
			frame.destroy()
			if spacex_log then
				spacex_log.destroy()
			end
			return
		end
		frame = gui.add({
			type = "frame",
			name = "space_progress_frame",
			direction = "vertical",
			caption = { "space-progress-frame-title" },
			style = mod_gui.frame_style,
		})
		gui_open_spacex(player)
	elseif clicked_button == "spacex_continue_button" then
		close_all_spacex_completed_gui()
		spacex_continue()
		gui_open_spacex(player)
	elseif clicked_button == "spacex_finish_button" then
		close_all_spacex_completed_gui()
		if frame then
			frame.destroy()
		end
		if spacex_log then
			spacex_log.destroy()
		end
		storage.finished = true
	elseif clicked_button == "spacex_completion_button" then
		close_all_spacex_completed_gui()
		for _, mod in pairs({ "exotic-industries", "Krastorio2", "248k" }) do
			if script.active_mods[mod] then
				gui_open_space_completed_after()
				return
			end
		end
		if remote.interfaces["better-victory-screen"] and remote.interfaces["better-victory-screen"]["trigger_victory"] then
			remote.call("better-victory-screen", "trigger_victory", player.force)
		else
			game.set_game_state{ game_finished = true, player_won = true, can_continue = true, victorious_force = player.force }
		end
		gui_open_space_completed_after()
	elseif clicked_button == "launch_log" then
		if spacex_log then
			spacex_log.destroy()
			return
		end
		spacex_log = gui.add({
			type = "frame",
			name = "spacex_log",
			direction = "vertical",
			caption = { "gui-log-title" },
			style = mod_gui.frame_style,
		})
		gui_open_log(player)
	elseif clicked_button == "stage_complete_button" then
		gui_open_stage_complete(player, 0)
	elseif clicked_button == "notadmin_button" then
		gui_open_spacex_completed(player)
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	init_gui(game.players[event.player_index])
end)

script.on_event(defines.events.on_research_finished, function(event)
	if event.research.name == "rocket-silo" then
		for _, player in pairs(game.players) do
			init_gui(player)
		end
	end
end)

script.on_init(function()
	init_spacex()
	for _, player in pairs(game.players) do
		init_gui(player)
	end
end)

local function check_stage_completed(stage)
	for _, item in pairs(stage.requirements) do
		if item.launched < item.required then
			return false
		end
	end
	return true
end

script.on_event(defines.events.on_rocket_launched, function(event)
	if storage.finished then
		return
	end
	game.set_game_state({ game_finished = false, player_won = false, can_continue = true })

	local current_stage = storage.stages[storage.current_stage]
	for _, item in pairs(current_stage.requirements) do
		local item_name = item.item_name
		if event.rocket.cargo_pod.get_item_count(item_name) > 0 then
			if item.launched < item.required then
				item.launched = item.launched + 1
			end
		end
	end

	for i = storage.current_stage, #storage.stages, 1 do
		if check_stage_completed(storage.stages[i]) then
			-- Check for spacex completion
			if current_stage.number == #storage.stages then
				storage.finished = true
				storage.completed = storage.completed + 1
				local launch_log = { log = game.ticks_played, detail = "", number = storage.completed }
				table.insert(storage.launch_log, launch_log)

				if storage.completed <= 1 or settings.global["SpaceX-no-chat-msg"].value == false then
					game.print({ "spacex-completion-msg" })
				end
				if storage.completed <= 1 or settings.global["SpaceX-auto-continue"].value == false then
					for _, player in pairs(game.players) do
						gui_open_spacex_completed(player)
					end
				else
					spacex_continue()
				end
			-- Stage completion
			else
				if storage.completed < 1 or settings.global["SpaceX-no-chat-msg"].value == false then
					game.print({ "stage-" .. current_stage.number .. "-completion-msg" })
				end
				if storage.completed < 1 or settings.global["SpaceX-no-popup"].value == false then
					for _, player in pairs(game.players) do
						gui_open_stage_complete(player, current_stage.number)
					end
				end
				storage.current_stage = storage.stages[i].number + 1
			end
		else
			break
		end
	end

	for _, player in pairs(game.players) do
		gui_open_spacex(player)
	end
	update_all_combinators()
end)

commands.add_command("SpaceX_reset", { "resetSpaceX_help" }, function(event)
	local player = game.players[event.player_index]
	if player.admin then
		spacex_continue()
		game.print("SpaceX Progress reset", { r = 0.5, g = 0, b = 0, a = 0.5 })
	else
		player.print("Only an admin can use this command", { r = 0.5, g = 0, b = 0, a = 0.5 })
	end
end)

commands.add_command("SpaceX_write_log_file", { "get log file help" }, function(event)
	helpers.write_file("spacex_log", serpent.block(storage.launch_log))
end)

-- Cheat commands
if __DebugAdapter then
	local function cheat_complete_stage()
		for _, item in pairs(storage.stages[storage.current_stage].requirements) do
			item.launched = item.required
		end
		local stage_req = storage.stages[storage.current_stage].requirements
		stage_req[#stage_req].launched = stage_req[#stage_req].required - 1
		update_all_combinators()
		for _, player in pairs(game.players) do
			gui_open_spacex(player)
		end
	end

	-- For every stage create a complete command
	for i = 1, 4 do
		commands.add_command("SpaceX_complete_stage_" .. i, { "SpaceX_cheat_sat_help" }, function(event)
			storage.current_stage = i
			cheat_complete_stage()
		end)
	end

	commands.add_command("SpaceX_write_combinators", { "get spacex_combinator help" }, function(event)
		helpers.write_file("spacex_combinator", serpent.block(storage.combinators))
	end)
end
