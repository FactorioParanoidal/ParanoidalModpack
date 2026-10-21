-- MultipleUnitTrainControl создаёт копии локомотивов «<имя>-mu» в своём data-updates, то есть
-- до балансных правок (tweaks/entity/trains.lua) и рескина поездов (graphics/train/train_reskin.lua)
-- в data-final-fixes. Без пересборки локомотив в MU-составе терял баланс и графику Paranoidal.
-- Копия заново берётся из итогового локомотива; поля, которые MU задаёт сам, сохраняются,
-- мощность умножается на 2, как в MU (power_multiplier по умолчанию).
-- Подключать после всех правок локомотивов. Подробности — BATTERY-ELECTRIC-TRAIN-FIXES.md рядом.
if not mods["MultipleUnitTrainControl"] then return end

local util = require("util")

local MU_POWER_MULTIPLIER = 2
local MU_OWN_FIELDS = {
	"name", "hidden", "factoriopedia_alternative", "placeable_by", "localised_name", "localised_description",
}

local locomotives = data.raw.locomotive
local mu_pairs = {}
for name in pairs(locomotives) do
	local base_name = name:match("^(.+)%-mu$")
	if base_name and locomotives[base_name] then
		mu_pairs[#mu_pairs + 1] = { base = base_name, mu = name }
	end
end

for _, pair in ipairs(mu_pairs) do
	local base, mu = locomotives[pair.base], locomotives[pair.mu]
	local copy = table.deepcopy(base)
	for _, field in ipairs(MU_OWN_FIELDS) do
		copy[field] = mu[field]
	end
	-- util.parse_energy возвращает для ватт энергию за тик.
	copy.max_power = math.floor(util.parse_energy(base.max_power) * 60 * MU_POWER_MULTIPLIER + 0.5) .. "W"
	locomotives[pair.mu] = copy
end
