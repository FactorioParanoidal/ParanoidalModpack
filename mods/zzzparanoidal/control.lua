require("prototypes.mod_compatibility.heroturrets_script") -- скрипт разжалования турелей
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

-- Функция для проверки, является ли имя сущности ресурсом
---@param name string
---@param array table (of strings)
---@return boolean
local isInArray = function(name, array)
	for _, item in ipairs(array) do
		if name == item then
			return true
		end
	end
	return false
end

if settings.startup["newbie_resourse"].value == true then
	-- Обработчик события on_chunk_generated
	script.on_event(defines.events.on_chunk_generated, function(event)
		-- Проверяем, что это именно генерация ресурсов
		if event.surface.name == "nauvis" then
			-- Изменяем настройки генерации ресурсов в чанках
			for _, entity in
				pairs(event.surface.find_entities_filtered({
					area = event.area,
				}))
			do
				-- Проверяем, является ли сущность ресурсом
				if isInArray(entity.name, resourceNames) then
					entity.amount = math.min(entity.amount * 5, 4294967294)
				end
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


script.on_init(function() --наш любимый init, запрещаем двигать наши насосы
	evo_and_dolly()
end)

script.on_load(function() --без дропа эволюции потому что game недоступен
	-- configure_picker_dollies()
end)

script.on_configuration_changed(
	function() --фикс эволюции при загрузке игры, если галочка была убрана и поставлена вновь
		evo_and_dolly()
	end
)
