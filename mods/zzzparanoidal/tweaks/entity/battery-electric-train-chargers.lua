-- Зарядники BatteryElectricTrain: иконки и графика тиров 1–3.
-- BET отдаёт всем шести зарядникам одну таблицу working_visualisations: правка одного тира
-- меняла все, а BottleneckLite (data-final-fixes) добавлял в общую таблицу по лампочке
-- статуса за каждый зарядник. Поэтому файл подключён в data-updates (до BottleneckLite)
-- и сначала даёт каждому зарядику собственный graphics_set.
-- Подробности — BATTERY-ELECTRIC-TRAIN-FIXES.md рядом.
if not mods["BatteryElectricTrain"] then return end

local furnaces = data.raw.furnace
local path = "__zzzparanoidal__/graphics/train/electric/"

for _, name in ipairs({
	"bet-charger-1", "bet-charger-2", "bet-charger-3",
	"bet-charger-tertiary-1", "bet-charger-tertiary-2", "bet-charger-tertiary-3",
}) do
	local charger = furnaces[name]
	if charger and charger.graphics_set then
		charger.graphics_set = table.deepcopy(charger.graphics_set)
	end
end

local tiers = {
	["bet-charger-1"] = {
		icon = "factory_var_1_icon.png",
		animation = { filename = path .. "av1_sheet.png", width = 320, height = 320, shift = { 1.0, -1.0 },
			frame_count = 16, line_length = 4, animation_speed = 0.3, scale = 0.5 },
	},
	["bet-charger-2"] = {
		icon = "factory_var_2_icon.png",
		tech_icon = "bet-charger-2_tech.png",
		animation = { filename = path .. "av2_sheet.png", width = 256, height = 256, shift = { 0.5, -0.5 },
			frame_count = 36, line_length = 6, animation_speed = 0.1, scale = 0.5 },
	},
	["bet-charger-3"] = {
		icon = "factory_var_3_icon.png",
		tech_icon = "bet-charger-3_tech.png",
		animation = { filename = path .. "av3_sheet.png", width = 256, height = 256, shift = { 0.4, -0.5 },
			frame_count = 25, line_length = 5, animation_speed = 0.05, scale = 0.5 },
	},
}

for name, tier in pairs(tiers) do
	local icon = path .. tier.icon
	furnaces[name].icon = icon
	data.raw.item[name].icon = icon
	data.raw.recipe[name].icon = icon
	data.raw.recipe[name].icon_size = 32
	if tier.tech_icon then
		data.raw.technology[name].icon = path .. tier.tech_icon
		data.raw.technology[name].icon_size = 256
	end

	-- Скин целиком заменяет спрайт BET; свечение аккумулятора BET рассчитано на старый
	-- спрайт, поэтому оверлей убран, как у super_charger. Лампочку статуса BottleneckLite добавит сам.
	furnaces[name].graphics_set.animation = tier.animation
	furnaces[name].graphics_set.working_visualisations = nil
end
