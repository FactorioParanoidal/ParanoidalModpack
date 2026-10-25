require("controls.heroturrets_script") -- скрипт разжалования турелей
require("controls.spilled_items") -- высыпание содержимого сущности при разрушении (настройка item-drop)
local sync_air_filter_beta8 = require("controls.air-filter-beta8")
local burner_pump_status = require("controls.burner-pump-status")
local loader_shells = require("controls.loader-shells")
require("controls.energy-recipe-migration").install() -- Старые чертежи ячеек после JSON/Lua-миграции.
local rail_support_power = require("controls.rail-support-power")
rail_support_power.install() -- Кабель в опорах эстакадных рельсов (только с elevated-rails).
require("controls.battery-locomotive-return").install() -- Аккумулятор BET при разборке MU-и hiend-локомотивов.
require("controls.torch-no-loot") -- Разобранный факел пропадает целиком.
require("controls.spacex-button-force") -- Кнопка SpaceX не остаётся после выхода из Песочницы.
local fire_safety = require("controls.fire-safety")
fire_safety.install() -- Пожарная турель: вода, гасит огонь, защита от Flammable Oils в радиусе.
local turret_deploy = require("controls.turret-deploy")
turret_deploy.install() -- Построенная турель включается через несколько секунд (настройки карты).
-- Install after loader-shells chains the SpilledItems handler; neither consumer
-- handles these inventory/grid-less types. Keep every other type, including modded containers.
if script.get_event_handler(defines.events.on_entity_died) then
	local death_filters = {}
	for _, entity_type in ipairs({"unit", "unit-spawner", "turret", "tree", "fish", "cliff", "simple-entity"}) do
		death_filters[#death_filters + 1] = {filter = "type", type = entity_type, invert = true, mode = "and"}
	end
	script.set_event_filter(defines.events.on_entity_died, death_filters)
end
-- ###############################################################################################
-- from some corpse marker
script.on_event(defines.events.on_pre_player_died, function(event)
	local player = game.players[event.player_index]
	player.force.add_chart_tag(player.surface, {
		position = player.position,
		text = "Corpse: " .. player.name .. "; Time: " .. math.floor(game.tick / 60 / 60 / 60) .. ":" .. (math.floor(
			game.tick / 60 / 60
		) % 60),
		icon = {
			type = "virtual",
			name = "signal-info",
		},
	})
end)

local function off_evo() --удаление эволюции
	game.map_settings.enemy_evolution.enabled = false
end

-- ############################## Все ресурсы х5 на дефолт настройках

-- Список имен ресурсов, которые вы хотите изменить
local resourceNames = {
	"angels-ore1",
	"angels-ore2",
	"coal",
	"angels-ore3",
	"angels-ore4",
	"angels-ore5",
	"angels-ore6",
	"angels-natural-gas",
	"crude-oil",
}

-- Только существующие прототипы: фильтр движка вместо перебора всех сущностей чанка (деревья, декор).
local resourceFilter = {}
for _, name in ipairs(resourceNames) do
	if prototypes.entity[name] then
		resourceFilter[#resourceFilter + 1] = name
	end
end

if settings.startup["newbie_resourse"].value == true and resourceFilter[1] then
	-- Обработчик события on_chunk_generated
	script.on_event(defines.events.on_chunk_generated, function(event)
		-- Проверяем, что это именно генерация ресурсов
		if event.surface.name == "nauvis" then
			-- Изменяем настройки генерации ресурсов в чанках
			for _, entity in
				pairs(event.surface.find_entities_filtered({
					area = event.area,
					type = "resource",
					name = resourceFilter,
				}))
			do
				entity.amount = math.min(entity.amount * 5, 4294967294)
			end
		end
	end)
end

local function evo_and_dolly() --выключаем эволюцию
	if (settings.global["paranoidal-disable-vanilla-evolution"] or {}).value then
		off_evo()
	end
	-- configure_picker_dollies()
end


local function disable_obsolete_basic_logistics()
	if not (script.active_mods["aai-industry"] and script.active_mods["boblogistics"]) then
		return
	end
	for _, force in pairs(game.forces) do
		local basic_logistics = force.technologies["basic-logistics"]
		-- Не отключать восстановленную видимую basic-logistics Beta 8.
		if basic_logistics and basic_logistics.prototype.hidden and force.technologies["logistics-0"] then
			basic_logistics.enabled = false
		end
	end
end

script.on_init(function() --наш любимый init, запрещаем двигать наши насосы
	evo_and_dolly()
	disable_obsolete_basic_logistics()
	sync_air_filter_beta8()
	burner_pump_status.init()
	loader_shells.init()
	rail_support_power.sync()
	fire_safety.sync()
	turret_deploy.sync()
end)

script.on_load(function() --без дропа эволюции потому что game недоступен
	-- configure_picker_dollies()
end)

script.on_configuration_changed(function() --фикс эволюции при загрузке игры, если галочка была убрана и поставлена вновь
	evo_and_dolly()
	disable_obsolete_basic_logistics()
	sync_air_filter_beta8()
	burner_pump_status.init()
	loader_shells.init()
	rail_support_power.sync()
	fire_safety.sync()
	turret_deploy.sync()
end)

script.on_event(defines.events.on_player_joined_game, disable_obsolete_basic_logistics)

-- Стартовое сообщение бортового компьютера (было в Beta 8 через aai-industry). Только в начале новой игры.
script.on_event(defines.events.on_player_created, function(event)
	if game.tick > 1 then return end
	local player = game.get_player(event.player_index)
	if not player then return end
	local name = player.name
	if not name or name == "" then
		name = {"paranoidal.fallback-player-name"}
	end
	player.print({"paranoidal.player-crash-landed", name})
end)

-- Пресет вех Paranoidal для Milestones (remote-интерфейс paranoidal_milestones).
require("controls.milestones-preset").install()
