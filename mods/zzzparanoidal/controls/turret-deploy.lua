-- Развёртывание турелей: только что построенная турель игрока несколько секунд не стреляет
-- (disabled_by_script), её уже можно зарядить и её уже бьют враги. Против «крепости за секунду»
-- в центре гнезда. Действует на постройку руками, роботами, наноботами и скриптами.
-- Нагрузка: обработчик постройки только для турелей; включение — корзины по тикам, раз в STEP
-- тиков читается одна запись. Индикатор — кольцо из дуг, которые по очереди гаснут; их удаляет сам
-- движок по time_to_live (и вместе с турелью), скрипт их не обновляет.
local M = {}

local STEP = 15 -- шаг корзин включения, тиков; 10 и 60 заняты fire-safety и burner-pump-status
local SEGMENTS = 8
local GAP = 0.1 -- радиан между дугами
local START = 1.5 * math.pi -- первая дуга начинается сверху, кольцо гаснет по часовой стрелке
local COLOR = {r = 0.9, g = 0.6, b = 0, a = 0.9}
local SETTING_TURRET = "paranoidal-turret-deploy-delay"
local SETTING_ARTILLERY = "paranoidal-artillery-deploy-delay"
local SETTING_INDICATOR = "paranoidal-turret-deploy-indicator"
local TYPES = {["ammo-turret"] = true, ["electric-turret"] = true, ["fluid-turret"] = true,
	["artillery-turret"] = true}
local STATUS = {diode = defines.entity_status_diode.yellow, label = {"paranoidal-turret-deploy.status"}}

-- Радиус кольца по имени прототипа; false — турель не задерживается (скрытые и служебные части
-- без "player-creation", например bi-arboretum-area). Зависит только от прототипов, поэтому
-- кэш вне storage одинаков у всех участников мультиплеера.
local radius_by_name = {}
local function ring_radius(entity)
	local name = entity.name
	local radius = radius_by_name[name]
	if radius == nil then
		local prototype = entity.prototype
		radius = false
		-- ранги HeroTurretRedux с встроенным боеприпасом скрыты только ради подсказок исследований
		if (not prototype.hidden or name:find("^hero%-turret%-%d+%-for%-")) and prototype.has_flag("player-creation") then
			local box = prototype.selection_box
			local size = math.max(box.right_bottom.x - box.left_top.x, box.right_bottom.y - box.left_top.y)
			radius = math.max(0.35, size * 0.28)
		end
		radius_by_name[name] = radius
	end
	return radius
end

-- HeroTurretRedux меняет ранг, пересоздавая работающую турель: следующая постройка с этим именем
-- в том же вызове не задерживается. Не хранится в storage: ставится и снимается в одном событии.
local skip_name = nil

local function state()
	local s = storage.turret_deploy
	if not s then
		s = {}
		storage.turret_deploy = s
	end
	return s
end

local function draw(entity, ticks, radius)
	local seg = 2 * math.pi / SEGMENTS
	local arc = {color = COLOR, min_radius = radius * 0.72, max_radius = radius, angle = seg - GAP,
		start_angle = 0, target = entity, surface = entity.surface, time_to_live = 1}
	for k = 1, SEGMENTS do
		arc.start_angle = (START + (k - 1) * seg + GAP / 2) % (2 * math.pi)
		arc.time_to_live = math.ceil(ticks * k / SEGMENTS)
		rendering.draw_arc(arc)
	end
end

-- Турель включается на тике due (кратен STEP).
local function hold(entity, due, radius)
	local s = state()
	local bucket = s[due]
	if not bucket then
		bucket = {}
		s[due] = bucket
	end
	bucket[entity.unit_number] = entity
	entity.disabled_by_script = true
	entity.custom_status = STATUS
	if settings.global[SETTING_INDICATOR].value then draw(entity, due - game.tick, radius) end
end

local function activate(entity)
	entity.disabled_by_script = false
	entity.custom_status = nil
end

local function on_built(e)
	local entity = e.entity
	if not (entity and entity.valid and TYPES[entity.type]) then return end
	if skip_name then
		if skip_name == entity.name then
			skip_name = nil
			return
		end
	end
	local radius = ring_radius(entity)
	if not radius then return end
	local setting = entity.type == "artillery-turret" and SETTING_ARTILLERY or SETTING_TURRET
	local ticks = math.floor(settings.global[setting].value * 60 + 0.5)
	if ticks <= 0 then return end
	hold(entity, math.ceil((game.tick + ticks) / STEP) * STEP, radius)
end

-- Скрипты создают и чужие турели (руины, стражи): задержка только для сил с игроками.
local function on_script_built(e)
	local entity = e.entity
	if not (entity and entity.valid and TYPES[entity.type]) then return end
	if not entity.force.players[1] then return end
	on_built(e)
end

-- Копия разворачивающейся турели получает остаток её отсчёта; работающая копируется работающей.
local function on_cloned(e)
	local source, destination = e.source, e.destination
	if not (destination and destination.valid and TYPES[destination.type]) then return end
	if not (source and source.valid and source.disabled_by_script and source.unit_number) then return end
	local radius = ring_radius(destination)
	if not radius then return end
	local unit = source.unit_number
	for due, bucket in pairs(state()) do
		if bucket[unit] then
			hold(destination, due, radius)
			return
		end
	end
end

local function on_step(e)
	local s = storage.turret_deploy
	local bucket = s and s[e.tick]
	if not bucket then return end
	s[e.tick] = nil
	for _, entity in pairs(bucket) do
		if entity.valid then activate(entity) end
	end
end

-- on_init / on_configuration_changed: корзины, которые уже не попадут на шаг (смена STEP в новой
-- версии), включаются сразу — турель не остаётся выключенной навсегда.
function M.sync()
	local s = state()
	local tick = game.tick
	local stale = {}
	for due in pairs(s) do
		if due <= tick or due % STEP ~= 0 then stale[#stale + 1] = due end
	end
	for _, due in ipairs(stale) do
		for _, entity in pairs(s[due]) do
			if entity.valid then activate(entity) end
		end
		s[due] = nil
	end
end

-- Сохранить ранее зарегистрированные обработчики zzz, как в соседних модулях.
local function on(event, callback)
	local previous = script.get_event_handler(event)
	script.on_event(event, function(e)
		if previous then previous(e) end
		callback(e)
	end)
end

function M.install()
	remote.add_interface("paranoidal_turret_deploy", {
		-- HeroTurretRedux: name — турель, которая сейчас заменит работающую; nil — сбросить.
		skip_next = function(name) skip_name = name end,
	})
	on(defines.events.on_built_entity, on_built)
	on(defines.events.on_robot_built_entity, on_built)
	on(defines.events.script_raised_built, on_script_built)
	on(defines.events.script_raised_revive, on_script_built)
	on(defines.events.on_entity_cloned, on_cloned)
	script.on_nth_tick(STEP, on_step)
end

return M
