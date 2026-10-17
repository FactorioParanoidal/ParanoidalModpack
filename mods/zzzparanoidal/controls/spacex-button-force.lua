-- Кнопка SpaceX (SpaceModFeorasFork) после выхода из Песочницы проектировщика.
-- SpaceX создаёт кнопку, когда у текущей команды игрока изучена «Ракетная шахта», и проверяет это
-- только при событиях исследования. Опция Песочницы «Разблокировать все технологии» изучает шахту
-- в команде Песочницы; после возврата игрока в основную команду кнопка оставалась.
-- Здесь при смене команды кнопка и окна SpaceX убираются, если у новой команды шахта не изучена.
-- Сохраняет ранние обработчики zzz, как остальные модули controls/.
local mod_gui = require("mod-gui")

local SILO = "rocket-silo"
local BUTTONS = { "space_toggle_button" }
local FRAMES = { "space_progress_frame", "spacex_log" } -- окна прогресса и журнала запусков

local function on(event, callback)
	local previous = script.get_event_handler(event)
	script.on_event(event, function(e)
		if previous then previous(e) end
		callback(e)
	end)
end

local function silo_researched(force)
	local tech = force and force.technologies[SILO]
	return tech ~= nil and tech.researched
end

local function destroy(flow, names)
	if not (flow and flow.valid) then return end
	for _, name in ipairs(names) do
		local element = flow[name]
		if element and element.valid then element.destroy() end
	end
end

local function sync(player)
	if not (player and player.valid) then return end
	if silo_researched(player.force) then return end
	destroy(mod_gui.get_button_flow(player), BUTTONS)
	destroy(mod_gui.get_frame_flow(player), FRAMES)
end

if script.active_mods["SpaceModFeorasFork"] then
	on(defines.events.on_player_changed_force, function(event)
		sync(game.get_player(event.player_index))
	end)
end
