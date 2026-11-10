-- Победа за первую ракету (решение пользователя 2026-11-10: сборка без SpaceX, ракета = победа).
-- «Свободная игра» без Space Age даёт победу за любой запуск ракетной шахты (core/lualib/silo-script.lua).
-- Здесь победу объявляем сами, а сценарию её запрещаем (remote silo_script.set_no_victory), чтобы:
-- не засчитывать шахту баллистических ракет M.I.R.V и запуски в Песочнице проектировщика,
-- и показать в окне победы свой текст (locale [paranoidal-victory]).
-- silo-script сбрасывает запрет при каждом изменении набора модов, поэтому запрет и текст ставятся
-- заново при приказе на запуск, задолго до самого запуска. Сценарий без silo_script (со Space Age
-- победа на краю солнечной системы, другие сценарии) решает о победе сам: модуль ничего не делает.
-- Старые сохранения со SpaceX: он запрещал победу сценарию; первая ракета после обновления даёт победу.
-- Сохраняет ранние обработчики zzz, как остальные модули controls/.

local M = {}

local SKIP_SILOS = { ["ballistic-missile-silo"] = true } -- MIRV2: запуск боеголовки, не ракета в космос
local SANDBOX_SURFACE = "bpsb-lab-" -- blueprint-sandboxes: поверхности песочниц
local SANDBOX_FORCE = "bpsb-sb-" -- и их команды

local function on(event, callback)
	local previous = script.get_event_handler(event)
	script.on_event(event, function(e)
		if previous then previous(e) end
		callback(e)
	end)
end

local function prefixed(name, prefix)
	return name ~= nil and name:sub(1, #prefix) == prefix
end

local function ending_info()
	return {
		image_path = "__base__/script/freeplay/victory.png",
		title = { "gui-game-finished.victory" },
		message = { "paranoidal-victory.message" },
		bullet_points = {
			{ "paranoidal-victory.bullet-1" },
			{ "paranoidal-victory.bullet-2" },
			{ "paranoidal-victory.bullet-3" },
			{ "paranoidal-victory.bullet-4" },
		},
		final_message = { "paranoidal-victory.final" },
	}
end

-- Забирает победу у сценария и ставит свой текст; false, если у сценария нет silo_script.
local function claim()
	local interface = remote.interfaces["silo_script"]
	if not (interface and interface.set_no_victory) then return false end
	remote.call("silo_script", "set_no_victory", true)
	game.set_win_ending_info(ending_info())
	return true
end

local function state()
	storage.rocket_victory = storage.rocket_victory or { won = {} }
	return storage.rocket_victory
end

local function in_sandbox(rocket, silo, force)
	if prefixed(force.name, SANDBOX_FORCE) then return true end
	for _, entity in ipairs({ rocket, silo }) do
		if entity and entity.valid and prefixed(entity.surface.name, SANDBOX_SURFACE) then return true end
	end
	return false
end

local function on_launched(event)
	local rocket, silo = event.rocket, event.rocket_silo
	if silo and silo.valid and SKIP_SILOS[silo.name] then return end
	local force = (rocket and rocket.valid and rocket.force) or (silo and silo.valid and silo.force) or nil
	if not force then return end
	if in_sandbox(rocket, silo, force) then return end
	if not claim() then return end
	local data = state()
	if data.won[force.name] then return end
	data.won[force.name] = true
	-- Сценарий успел объявить победу сам (запрет сброшен между приказом и запуском) или игра уже окончена.
	if game.finished or game.finished_but_continuing then return end
	game.reset_game_state()
	game.set_game_state({
		game_finished = true,
		player_won = true,
		can_continue = true,
		victorious_force = force, -- как в silo-script.lua движка
	})
end

-- on_init / on_configuration_changed (вызывается из control.lua).
function M.sync()
	if script.active_mods["space-age"] then return end
	state()
	claim()
end

function M.install()
	if script.active_mods["space-age"] then return end
	on(defines.events.on_rocket_launch_ordered, function()
		claim()
	end)
	on(defines.events.on_rocket_launched, on_launched)
end

return M
