-- Возврат аккумулятора BatteryElectricTrain при разборке локомотивов, которые сам BET не знает.
-- BET (control.lua) возвращает недоразряженный аккумулятор только для "bet-locomotive". У других
-- локомотивов на топливе "bet-fuel-battery" (bet-locomotive-mu от MultipleUnitTrainControl,
-- hiend_loco и его MU-копия) горящий аккумулятор исчезал целиком. Здесь вместо него
-- возвращается пустой аккумулятор (остаток заряда не сохраняется — как в BET).
-- Подробности — tweaks/entity/BATTERY-ELECTRIC-TRAIN-FIXES.md.
local M = {}

local FUEL_CATEGORY = "bet-fuel-battery"
local OWN_LOCOMOTIVE = "bet-locomotive" -- обрабатывает сам BET
local RETURN_SETTING = "bet-return-partial-batteries" -- runtime-настройка BET

-- Вычисляется из прототипов, одинаково у всех участников мультиплеера.
local handled_names
local function is_handled(name)
	if not handled_names then
		handled_names = {}
		for proto_name, proto in pairs(prototypes.get_entity_filtered({ { filter = "type", type = "locomotive" } })) do
			local burner = proto.burner_prototype
			if proto_name ~= OWN_LOCOMOTIVE and burner and burner.fuel_categories[FUEL_CATEGORY] then
				handled_names[proto_name] = true
			end
		end
	end
	return handled_names[name] == true
end

local function return_enabled()
	local setting = settings.global[RETURN_SETTING]
	return setting == nil or setting.value == true
end

local function return_battery(entity, player)
	if not (entity and entity.valid and entity.type == "locomotive" and is_handled(entity.name)) then return end
	if not return_enabled() then return end
	local burner = entity.burner
	local burning = burner and burner.currently_burning
	if not burning then return end

	local base = burning.name.name:match("^(.+)-full$")
	local empty = base and prototypes.item[base .. "-empty"]
	if not empty then return end

	local stack = { name = empty.name, count = 1, quality = burning.quality and burning.quality.name or nil }
	burner.currently_burning = nil
	if burner.burnt_result_inventory.insert(stack) > 0 then return end
	if player and player.valid and player.insert(stack) > 0 then return end
	entity.surface.spill_item_stack({
		position = entity.position,
		stack = stack,
		enable_looted = true,
		force = entity.force,
		allow_belts = false,
	})
end

local function on_player_pre_mined(event)
	return_battery(event.entity, game.get_player(event.player_index))
end

local function on_robot_pre_mined(event)
	return_battery(event.entity, nil)
end

-- Сохраняем возможные ранние обработчики zzz, как остальные модули controls/.
local function on(event, callback)
	local previous = script.get_event_handler(event)
	script.on_event(event, function(e)
		if previous then previous(e) end
		callback(e)
	end)
	if not previous then
		script.set_event_filter(event, { { filter = "type", type = "locomotive" } })
	end
end

function M.install()
	if not script.active_mods["BatteryElectricTrain"] then return end
	on(defines.events.on_pre_player_mined_item, on_player_pre_mined)
	on(defines.events.on_robot_pre_mined, on_robot_pre_mined)
end

return M
