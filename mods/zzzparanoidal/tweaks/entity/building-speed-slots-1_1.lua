-- Итоговые скорости и слоты соответствующих тиров из дампа Paranoidal Beta 8 (1.1).
-- Только параметры зданий: рецепты, питание и геометрия здесь не меняются.
local machines = data.raw["assembling-machine"]
local crafting_speeds = {
    ["bi-bio-garden-large"] = 8,
    ["bi-bio-garden-huge"] = 64,
    ["angels-oil-refinery-2"] = 1.75,
    ["angels-oil-refinery-3"] = 2.5,
    ["angels-oil-refinery-4"] = 3.5,
    ["angels-electro-whinning-cell"] = 0.75,
    ["angels-electro-whinning-cell-2"] = 1,
    ["clowns-sluicer-2"] = 1.5,
    -- Согласованная замена центрифуг Clowns MK2/MK3 центрифугами Bob 2/3.
    ["bob-centrifuge-2"] = 1.25,
    ["bob-centrifuge-3"] = 2,
}
for name, speed in pairs(crafting_speeds) do
    local machine = machines[name]
    if machine then machine.crafting_speed = speed end
end

local slots = {
    ["angels-electro-whinning-cell"] = 1,
    ["angels-electro-whinning-cell-2"] = 2,
}
for name, count in pairs(slots) do
    local machine = machines[name]
    if machine then machine.module_slots = count end
end

-- pumping_speed хранится в единицах жидкости за тик в обеих версиях.
local pumping_speeds = {
    ["pump"] = 80,
    ["bob-pump-2"] = 120,
    ["bob-pump-3"] = 160,
    ["bob-pump-4"] = 200,
}
for name, speed in pairs(pumping_speeds) do
    local pump = data.raw["pump"][name]
    if pump then pump.pumping_speed = speed end
end
