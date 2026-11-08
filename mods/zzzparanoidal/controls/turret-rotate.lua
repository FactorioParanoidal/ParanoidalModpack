-- Поворот стоящей турели с сектором обстрела (баг-репорт 2026-11-08): движок не поворачивает
-- поставленные турели, а снятие обнуляет убийства (звание HeroTurretRedux). R / Shift+R с пустой
-- рукой на своей турели в пределах досягаемости поворачивают её на 1/8 круга. Скрипт движка меняет
-- направление на месте только на 90° (проба 2.1.24: со стороны света на диагональ и обратно
-- запись direction молча не действует), поэтому такой шаг — замена той же турелью через
-- HeroTurretRedux (как при смене ранга: убийства, урон, патроны, провода, приоритеты, без повторного
-- развёртывания); здоровье и заряд восстанавливаются здесь. Огнемётные турели движок поворачивает
-- сам — их не трогаем.
-- Турель, чья клеточная площадь по диагонали другой чётности (корпус 2,4 — 3×3 клетки, повёрнутый
-- на 45° — 4×4), на диагонали стоит по другой сетке и при каждом шаге 1/8 съезжала бы на полклетки: такая
-- поворачивается на 90° на месте. Модульные W93 для этого сужены до 2,1 (tweaks/entity/w93-modular-turrets.lua) и
-- поворачиваются на 1/8; правило остаётся для других таких турелей.
-- Нагрузка: только нажатия R; кэш по имени прототипа (одинаков у всех участников мультиплеера).
local M = {}

local TYPES = {["ammo-turret"] = true, ["electric-turret"] = true}

-- Шаг поворота в defines.direction (16 направлений) по имени прототипа; false — не наша турель.
local step_by_name = {}
local function step_of(entity)
	local name = entity.name
	local step = step_by_name[name]
	if step == nil then
		step = false
		local prototype = entity.prototype
		local attack = prototype.attack_parameters
		if TYPES[prototype.type] and prototype.turret_base_has_direction and attack and attack.turn_range
			and attack.turn_range < 1 then
			local flags = prototype.flags or {}
			step = flags["building-direction-16-way"] and 1 or flags["building-direction-8-way"] and 2 or 4
			local box = prototype.collision_box
			local size = math.max(box.right_bottom.x - box.left_top.x, box.right_bottom.y - box.left_top.y)
			if step < 4 and math.ceil(size) % 2 ~= math.ceil(size * math.sqrt(2)) % 2 then step = 4 end
		end
		step_by_name[name] = step
	end
	return step
end

-- Повёрнутая турель (та же или новая) или nil.
local function rotate(entity, reverse)
	if not (entity and entity.valid) then return nil end
	local step = step_of(entity)
	if not step then return nil end
	local target = (entity.direction + (reverse and -step or step)) % 16
	entity.direction = target
	if entity.direction == target then return entity end
	if not remote.interfaces["HeroTurretRedux"] then return nil end
	local health, energy = entity.health, entity.type == "electric-turret" and entity.energy or nil
	local turned = remote.call("HeroTurretRedux", "turn", entity, target)
	if not (turned and turned.valid) then return nil end
	turned.health = health
	if energy then turned.energy = energy end
	return turned
end

local function on_rotate(event, reverse)
	local player = game.get_player(event.player_index)
	if not player then return end
	local entity = player.selected
	if not (entity and entity.valid and TYPES[entity.type]) then return end
	-- предмет или призрак в руке: R поворачивает то, что ставят
	local cursor = player.cursor_stack
	if (cursor and cursor.valid_for_read) or player.cursor_ghost then return end
	if entity.force ~= player.force or not player.can_reach_entity(entity) then return end
	local opened = player.opened == entity
	local turned = rotate(entity, reverse)
	if turned then
		if opened and player.opened ~= turned then player.opened = turned end
		player.play_sound({path = "utility/rotated_medium", position = turned.position})
	end
end

function M.install()
	script.on_event("paranoidal-turret-rotate", function(event) on_rotate(event, false) end)
	script.on_event("paranoidal-turret-reverse-rotate", function(event) on_rotate(event, true) end)
	remote.add_interface("paranoidal_turret_rotate", {
		-- Поворот без проверок игрока (тесты, другие моды): повёрнутая турель (та же или новая) или nil.
		rotate = rotate,
	})
end

return M
