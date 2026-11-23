local M = {}

local NAME = "pd_lab_productivity"
local REFRESH_TICKS = 12
local events = defines.events

local function opened_lab(player)
	if player.opened_gui_type ~= defines.gui_type.entity then return end
	local entity = player.opened
	if entity and entity.valid and entity.type == "lab" then return entity end
end

local function stop(index, player)
	local viewers = storage.pd_lab_productivity_viewers
	if not viewers or viewers[index] == nil then return end
	viewers[index] = nil
	local panel = player and player.gui.relative[NAME]
	if panel then panel.destroy() end
end

local function update(player, lab, viewers)
	local bonus = lab.productivity_bonus
	local panel = player.gui.relative[NAME]
	if bonus == 0 then
		if panel then panel.destroy() end
	elseif not panel or viewers[player.index] ~= bonus then
		if not panel then
			panel = player.gui.relative.add{
				type = "flow", name = NAME,
				anchor = {gui = defines.relative_gui_type.lab_gui, position = defines.relative_gui_position.bottom},
			}
			panel.style.horizontally_stretchable = true
			panel.style.horizontal_align = "right"
			local frame = panel.add{type = "frame", name = "bonus", direction = "horizontal"}
			frame.style.padding = {4, 8}
			frame.add{type = "label", name = "bonus_text"}
		end
		local percent = bonus * 100
		local text = math.abs(percent) < 0.01 and string.format("%+.3g", percent)
			or string.format("%+.2f", percent):gsub("0+$", ""):gsub("%.$", "")
		panel.bonus.bonus_text.caption = {"", {"description.productivity-bonus"}, ": ", text .. "%"}
	end
	viewers[player.index] = bonus
end

local function track(player, lab)
	if not player then return end
	if not lab then
		stop(player.index, player)
		return
	end
	storage.pd_lab_productivity_viewers = storage.pd_lab_productivity_viewers or {}
	update(player, lab, storage.pd_lab_productivity_viewers)
end

local function sync_player(player)
	if player then track(player, opened_lab(player)) end
end

function M.sync()
	for _, player in pairs(game.connected_players) do sync_player(player) end
end

local function refresh()
	-- No player or entity scans: only recheck players who opened a lab, including at 0%.
	local viewers = storage.pd_lab_productivity_viewers
	if not viewers then return end
	for index in pairs(viewers) do
		local player = game.get_player(index)
		local lab = player and player.connected and opened_lab(player)
		if lab then update(player, lab, viewers) else stop(index, player) end
	end
end

local function on(event, handler)
	local previous = script.get_event_handler(event)
	script.on_event(event, function(e)
		if previous then previous(e) end
		handler(e)
	end)
end

function M.install()
	on(events.on_gui_opened, function(e)
		local lab = e.entity
		if e.gui_type == defines.gui_type.entity and lab and lab.valid and lab.type == "lab" then
			track(game.get_player(e.player_index), lab)
		end
	end)
	on(events.on_gui_closed, function(e)
		if e.gui_type == defines.gui_type.entity then stop(e.player_index, game.get_player(e.player_index)) end
	end)
	on(events.on_player_joined_game, function(e) sync_player(game.get_player(e.player_index)) end)
	on(events.on_player_left_game, function(e) stop(e.player_index, game.get_player(e.player_index)) end)
	on(events.on_player_removed, function(e) stop(e.player_index) end)
	script.on_nth_tick(REFRESH_TICKS, refresh)
end

return M
