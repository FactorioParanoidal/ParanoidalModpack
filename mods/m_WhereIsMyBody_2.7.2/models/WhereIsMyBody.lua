
---@class WhereIsMyBody : module
local M = {}


--#region Global data
---@type table<integer, any[]> # [render id, corpse entity, tag number?]
local players_bodies
---@type table<integer, any[]> # [render id, corpse entity, tag number?]
local inactive_players_bodies
---@type table<integer, table> # {render id, corpse entity, tag number?}
local important_players_body
---@type table<integer, table> # {render id, corpse entity, tag number?}
local inactive_important_players_body
---@type table<integer, LuaEntity>
local corpses_queue
--#endregion


--#region Constants
local draw_line = rendering.draw_line
local set_color = rendering.set_color
local rendering_destroy = rendering.destroy
local is_render_valid = rendering.is_valid
local remove = table.remove
--#endregion


--#region Settings
local update_tick = settings.global["WHMB_update_tick"].value
--#endregion


--#region Utils

local function remove_lines_event(event)
	local player_index = event.player_index
	local player_bodies = players_bodies[player_index]
	if player_bodies ~= nil then
		for i=1, #player_bodies do
			local body_data = player_bodies[i]
			rendering_destroy(body_data[1])
			local chart_tag = body_data[3]
			if chart_tag and chart_tag.valid then
				chart_tag.destroy()
			end
		end
	end
	players_bodies[player_index] = nil

	player_bodies = inactive_players_bodies[player_index]
	if player_bodies ~= nil then
		for i=1, #player_bodies do
			local body_data = player_bodies[i]
			rendering_destroy(body_data[1])
			local chart_tag = body_data[3]
			if chart_tag and chart_tag.valid then
				chart_tag.destroy()
			end
		end
	end
	inactive_players_bodies[player_index] = nil

	local body_data = important_players_body[player_index]
	if body_data then
		rendering_destroy(body_data[1])
		important_players_body[player_index] = nil
		local chart_tag = body_data[3]
		if chart_tag and chart_tag.valid then
			chart_tag.destroy()
		end
	end
	body_data = inactive_important_players_body[player_index]
	if body_data then
		rendering_destroy(body_data[1])
		inactive_important_players_body[player_index] = nil
		local chart_tag = body_data[3]
		if chart_tag and chart_tag.valid then
			chart_tag.destroy()
		end
	end
end

local color_data = {0, 0, 0, 0} -- orange
local min_color_data = {0.19, 0.8 * 0.19, 0, 0.19} -- orange
local max_color_data = {0.9, 0.8 * 0.9, 0, 0.9} -- orange
---@param character table #LuaEntity
---@param id integer
---@param corpse table #LuaEntity
local function update_color(character, id, corpse)
	local start = character.position
	local stop = corpse.position
	local xdiff = start.x - stop.x
	local ydiff = start.y - stop.y
	local distance = (xdiff * xdiff + ydiff * ydiff)^0.5

	if distance > 450 then
		set_color(id, min_color_data)
	elseif distance < 95 then
		set_color(id, max_color_data)
	else
		local r = 1 - distance / 500
		color_data[1] = r
		color_data[2] = 0.8 * r
		color_data[4] = r
		set_color(id, color_data)
	end
end

-- Perhaps, I should change it
local purple_color_data = {171 / 255, 64 / 255, 1, 0.8}
local max_purple_color_data = {171 / 255, 64 / 255, 1, 0.8}
local min_purple_color_data = {(171 / 255) * 0.15, (64 / 255) * 0.15, 0.15, 0.8}
---@param character table #LuaEntity
---@param id integer
---@param corpse table #LuaEntity
local function update_purple_color(character, id, corpse)
	local start = character.position
	local stop = corpse.position
	local xdiff = start.x - stop.x
	local ydiff = start.y - stop.y
	local distance = (xdiff * xdiff + ydiff * ydiff)^0.5

	if distance > 450 then
		set_color(id, min_purple_color_data)
	elseif distance < 166 then
		set_color(id, max_purple_color_data)
	else
		local r = (1 - distance / 500) * 1.5
		r = (r > 1 and 1) or r
		purple_color_data[1] = (171 / 255) * r
		purple_color_data[2] = (64 / 255) * r
		purple_color_data[3] = r
		set_color(id, purple_color_data)
	end
end

local orange_color = {1, 0.8, 0, 0.9}
local purple_color = {171 / 255, 64 / 255, 1, 0.8}
local line_data = {
	color = orange_color,
	width = 0.2,
	from = nil,
	surface = nil,
	players = {},
	draw_on_ground = true,
	only_in_alt_mode = true
} -- It's a bit messy, so be careful about desyncs
---@param player LuaEntity
---@param player_index number
local function draw_all_lines(player, player_index, event)
	local character = player.character
	if not (character and character.valid) then
		remove_lines_event(event)
		return
	end

	local player_bodies
	local important_body
	local is_entity_info_visible = player.game_view_settings.show_entity_info
	if is_entity_info_visible then
		player_bodies = players_bodies[player_index]
		important_body = important_players_body[player_index]
	else
		player_bodies = inactive_players_bodies[player_index]
		important_body = inactive_important_players_body[player_index]
	end

	line_data.surface = character.surface
	line_data.from = character
	line_data.width = player.mod_settings["WHMB_line_width"].value
	line_data.players = {player_index}
	if player_bodies then
		-- There's a chance that some lines still exist due to LuaPlayer.ticks_to_respawn
		for i=1, #player_bodies do
			-- is it really safe?
			rendering_destroy(player_bodies[i][1])
		end

		line_data.color = orange_color
		for i=#player_bodies, 1, -1 do
			local body_data = player_bodies[i]
			local entity = body_data[2]
			if entity.valid then
				line_data.to = entity
				body_data[1] = draw_line(line_data)
			else
				remove(player_bodies, i)
			end
		end
	end

	if important_body then
		rendering_destroy(important_body[1])
		line_data.color = purple_color
		local entity = important_body[2]
		if entity.valid then
			line_data.to = entity
			important_body[1] = draw_line(line_data)
		else
			if is_entity_info_visible then
				important_players_body[player_index] = nil
			else
				inactive_important_players_body[player_index] = nil
			end
		end
	end
end

---@param player table #LuaPlayer
---@param corpse table #LuaEntity
---@param player_index number
---@param is_forced? boolean
local function draw_new_line_to_body(player, corpse, player_index, is_forced)
	local character = player.character
	if not (character and character.valid) then return end
	if not (corpse and corpse.valid) then return end
	local surface = character.surface
	if surface ~= corpse.surface then return end
	if not is_forced then
		local items_count = table_size(corpse.get_inventory(defines.inventory.character_corpse).get_contents())
		if items_count <= player.mod_settings["WHMB_ignore_if_less_n_items"].value then return end
	end

	line_data.surface = surface
	line_data.from = character
	line_data.to = corpse
	line_data.width = player.mod_settings["WHMB_line_width"].value
	line_data.players = {player_index}

	local chart_tag
	if player.mod_settings["WHMB_create_chart_tags_after_death"].value then
		local icon = {type="virtual", name="signal-info"}
		chart_tag = player.force.add_chart_tag(
			surface,
			{position=corpse.position, text='[entity=character-corpse]' .. player.name, icon=icon}
		)
	end

	corpses_queue[player_index] = nil -- maybe it can be buggy

	local player_bodies
	local is_entity_info_visible = player.game_view_settings.show_entity_info
	if is_entity_info_visible then
		player_bodies = players_bodies[player_index]
		if player_bodies == nil then
			if important_players_body[player_index] then
				players_bodies[player_index] = players_bodies[player_index] or {}
				player_bodies = players_bodies[player_index]
			else
				line_data.color = purple_color
				local id = draw_line(line_data)
				important_players_body[player_index] = {id, corpse, chart_tag}
				return
			end
		end
	else
		player_bodies = inactive_players_bodies[player_index]
		if player_bodies == nil then
			if inactive_important_players_body[player_index] then
				inactive_players_bodies[player_index] = inactive_players_bodies[player_index] or {}
				player_bodies = inactive_players_bodies[player_index]
			else
				line_data.color = purple_color
				local id = draw_line(line_data)
				inactive_important_players_body[player_index] = {id, corpse, chart_tag}
				return
			end
		end
	end

	line_data.color = orange_color
	local id = draw_line(line_data)
	player_bodies[#player_bodies+1] = {id, corpse, chart_tag}
end

---@param player table #LuaPlayer
---@param corpse table #LuaEntity
---@param player_index number
---@param is_forced? boolean
local function draw_important_line_to_body(player, corpse, player_index, is_forced)
	local character = player.character
	if not (character and character.valid) then return end
	if not (corpse and corpse.valid) then return end
	local surface = character.surface
	if surface ~= corpse.surface then return end
	if not is_forced then
		local items_count = table_size(corpse.get_inventory(defines.inventory.character_corpse).get_contents())
		if items_count <= player.mod_settings["WHMB_ignore_if_less_n_items"].value then return end
	end

	line_data.surface = surface
	line_data.from = character
	line_data.to = corpse
	line_data.width = player.mod_settings["WHMB_line_width"].value
	line_data.players = {player_index}

	corpses_queue[player_index] = nil -- maybe it can be buggy

	line_data.color = purple_color
	local id = draw_line(line_data)
	local is_entity_info_visible = player.game_view_settings.show_entity_info
	if is_entity_info_visible then
		important_players_body[player_index] = {id, corpse}
	else
		inactive_important_players_body[player_index] = {id, corpse}
	end
end

--#endregion

--#region Functions of events

local function check_render()
	local get_player = game.get_player
	for player_index, all_bodies_data in pairs(players_bodies) do
		local player = get_player(player_index)
		if player and player.valid then
			local character = player.character
			if character and character.valid then
				for i=#all_bodies_data, 1, -1 do
					local body_data = all_bodies_data[i]
					local corpse = body_data[2]
					if corpse.valid then
						local id = body_data[1]
						if is_render_valid(id) then
							update_color(character, id, corpse)
						else
							local chart_tag = body_data[3]
							if chart_tag and chart_tag.valid then
								chart_tag.destroy()
							end
							remove(all_bodies_data, i)
							draw_new_line_to_body(player, corpse, player_index, true)
						end
					else
						local chart_tag = body_data[3]
						if chart_tag and chart_tag.valid then
							chart_tag.destroy()
						end
						remove(all_bodies_data, i)
					end
				end
				if #all_bodies_data == 0 then
					players_bodies[player_index] = nil
				end
			end
		end
	end

	for player_index, body_data in pairs(important_players_body) do
		local player = get_player(player_index)
		if player and player.valid then
			local character = player.character
			if character and character.valid then
				local corpse = body_data[2]
				if corpse.valid then
					local id = body_data[1]
					if is_render_valid(id) then
						update_purple_color(character, id, corpse)
					else
						local chart_tag = body_data[3]
						if chart_tag and chart_tag.valid then
							chart_tag.destroy()
						end
						important_players_body[player_index] = nil
						draw_important_line_to_body(player, corpse, player_index, true)
					end
				else
					local chart_tag = body_data[3]
					if chart_tag and chart_tag.valid then
						chart_tag.destroy()
					end
					important_players_body[player_index] = nil
				end
			end
		end
	end
end

local function on_player_toggled_alt_mode(event)
	local player_index = event.player_index
	if event.alt_mode then
		players_bodies[player_index] = inactive_players_bodies[player_index]
		inactive_players_bodies[player_index] = nil
		important_players_body[player_index] = inactive_important_players_body[player_index]
		inactive_important_players_body[player_index] = nil
	else
		inactive_players_bodies[player_index] = players_bodies[player_index]
		players_bodies[player_index] = nil
		inactive_important_players_body[player_index] = important_players_body[player_index]
		important_players_body[player_index] = nil
	end
end

local function on_pre_player_removed(event)
	local player_index = event.player_index
	players_bodies[player_index] = nil
	inactive_players_bodies[player_index] = nil
	important_players_body[player_index] = nil
	inactive_important_players_body[player_index] = nil
	corpses_queue[player_index] = nil
end

local function on_console_command(event)
	if event.command ~= "editor" then return end
	remove_lines_event(event)
end

local function on_player_clicked_gps_tag(event)
	local player_index = event.player_index
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end
	local character = player.character
	if not (character and character.valid) then return end
	local is_entity_info_visible = player.game_view_settings.show_entity_info
	if is_entity_info_visible == false then return end
	local surface = game.get_surface(event.surface)
	if not (surface and surface.valid) then return end

	local player_bodies = players_bodies[player_index]
	local important_player_body = important_players_body[player_index]
	local pos = event.position
	if important_player_body then
		local x = pos.x
		local y = pos.y
		local corpse = important_player_body[2]
		if corpse.valid then
			if corpse.surface == surface then
				local pos2 = corpse.position
				local xdiff = x - pos2.x
				local ydiff = y - pos2.y
				local distance = (xdiff * xdiff + ydiff * ydiff)^0.5
				if distance <= 2 then
					return
				end
			end
		else
			important_players_body[player_index] = nil
		end
	end

	if player_bodies then
		local x = pos.x
		local y = pos.y
		for i=#player_bodies, 1, -1 do
			local body_data = player_bodies[i]
			local corpse = body_data[2]
			if corpse.valid then
				if corpse.surface == surface then
					local pos2 = corpse.position
					local xdiff = x - pos2.x
					local ydiff = y - pos2.y
					local distance = (xdiff * xdiff + ydiff * ydiff)^0.5
					if distance <= 2 then
						rendering_destroy(body_data[1])
						remove(player_bodies, i)
						local important_body_data = important_player_body
						draw_important_line_to_body(player, corpse, player_index, true)
						if important_body_data then
							rendering_destroy(important_body_data[1])
							local entity = important_body_data[2]
							if entity.valid then
								draw_new_line_to_body(player, entity, player_index, true)
							end
						end
						return
					end
				end
			else
				remove(player_bodies, i)
			end
		end
	end

	if player.cheat_mode then return end

	local filter = {type="character-corpse", position=pos, radius=2}
	local corpses = surface.find_entities_filtered(filter)
	for i=1, #corpses do
		local corpse = corpses[i]
		if corpse.valid then
			local items_count = table_size(corpse.get_inventory(defines.inventory.character_corpse).get_contents())
			if items_count > 0 then
				draw_new_line_to_body(player, corpse, player_index, true)
				return
			end
		end
	end
end

local function on_player_respawned(event)
	local player_index = event.player_index
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end
	if player.cheat_mode then return end

	draw_all_lines(player, player_index, event)

	local corpse = corpses_queue[player_index]
	corpses_queue[player_index] = nil
	if not (corpse and corpse.valid) then return end
	if settings.global["WHMB_delete_empty_bodies"].value then
		local items_count = table_size(corpse.get_inventory(defines.inventory.character_corpse).get_contents())
		if items_count == 0 then
			corpse.destroy({raise_destroy=true})
			return
		end
	end
	draw_new_line_to_body(player, corpse, player_index)
end

local function on_player_died(event)
	local player_index = event.player_index
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end
	if player.cheat_mode then return end
	if player.mod_settings["WHMB_create_lines"].value == false then return end
	local surface = player.surface
	local position = player.position
	local corpse = surface.find_entity("character-corpse", position)
	if not (corpse and corpse.valid) then return end

	corpses_queue[player_index] = corpse
end

--TODO: check tag content, prohibit deletion of chart tags if the ones belongs to another player
local function on_chart_tag_removed(event)
	local player_index = event.player_index
	if player_index == nil then return end
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end
	local tag = event.tag
	if tag.valid == false then return end

	local player_bodies
	local important_body
	local is_entity_info_visible = player.game_view_settings.show_entity_info
	if is_entity_info_visible then
		player_bodies = players_bodies[player_index]
		important_body = important_players_body[player_index]
	else
		player_bodies = inactive_players_bodies[player_index]
		important_body = inactive_important_players_body[player_index]
	end

	local tag_number = tag.tag_number
	local filter = {type="character-corpse", position=tag.position, radius=2}
	local corpses = player.surface.find_entities_filtered(filter)
	for i=1, #corpses do
		local corpse = corpses[i]
		if corpse.valid then
			if player_bodies ~= nil then
				for j=1, #player_bodies do
					local body_data = player_bodies[j]
					local chart_tag = body_data[3]
					if chart_tag and chart_tag.valid and chart_tag.tag_number == tag_number then
						rendering_destroy(body_data[1])
						remove(player_bodies, j)
						if #player_bodies == 0 then
							if is_entity_info_visible then
								players_bodies[player_index] = nil
							else
								inactive_players_bodies[player_index] = nil
							end
						end
						return
					end
				end
			end
			if important_body then
				local chart_tag = important_body[3]
				if chart_tag and chart_tag.valid and chart_tag.tag_number == tag_number then
					rendering_destroy(important_body[1])
					if is_entity_info_visible then
						important_players_body[player_index] = nil
					else
						inactive_important_players_body[player_index] = nil
					end
					return
				end
			end
		end
	end
end

local function on_runtime_mod_setting_changed(event)
	if event.setting == "WHMB_update_tick" then
		local value = settings.global[event.setting].value
		script.on_nth_tick(update_tick, nil)
		update_tick = value
		script.on_nth_tick(value, check_render)
	end
end

--#endregion


--#region Pre-game stage

local function link_data()
	players_bodies = global.players_bodies
	inactive_players_bodies = global.inactive_players_bodies
	important_players_body = global.important_players_body
	inactive_important_players_body = global.inactive_important_players_body
	corpses_queue = global.corpses_queue
end

local function update_global_data()
	global.players_bodies = {}
	global.inactive_players_bodies = {}
	global.important_players_body = {}
	global.inactive_important_players_body = {}
	global.corpses_queue = global.corpses_queue or {}

	link_data()

	for player_index, corpse in pairs(corpses_queue) do
		if corpse.valid == false then
			corpses_queue[player_index] = nil
		end
	end
end


M.on_init = update_global_data
M.on_configuration_changed = function(event)
	local mod_changes = event.mod_changes["m_WhereIsMyBody"]
	if not (mod_changes and mod_changes.old_version) then return end

	update_global_data()
	global.inactive_players_data = nil -- old data
	global.players = nil -- old data
end
M.on_load = link_data

--#endregion


M.events = {
	-- [defines.events.on_game_created_from_scenario] = on_game_created_from_scenario,
	-- [defines.events.on_pre_player_mined_item] = on_pre_player_mined_item,
	-- [defines.events.on_character_corpse_expired] = on_character_corpse_expired,
	-- [defines.events.on_pre_surface_cleared] = on_pre_surface_cleared,
	-- [defines.events.on_pre_surface_deleted] = on_pre_surface_deleted,
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed,
	[defines.events.on_player_respawned] = on_player_respawned,
	[defines.events.on_pre_player_removed] = on_pre_player_removed,
	[defines.events.on_player_died] = on_player_died,
	[defines.events.on_player_left_game] = remove_lines_event,
	[defines.events.on_player_changed_surface] = remove_lines_event,
	[defines.events.on_player_toggled_alt_mode] = on_player_toggled_alt_mode,
	[defines.events.on_console_command] = on_console_command, -- on_player_toggled_map_editor event seems doesn't work
	[defines.events.on_player_clicked_gps_tag] = on_player_clicked_gps_tag,
	-- [defines.events.on_chart_tag_modified] = on_chart_tag_modified,
	[defines.events.on_chart_tag_removed] = on_chart_tag_removed
}

M.on_nth_tick = {
	[update_tick] = check_render,
}

return M
