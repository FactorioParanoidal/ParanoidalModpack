require("__hardcore-mode-for-playing__.prototypes.fuel-category.fuel-categories")
require("__automated-utility-protocol__.util.fuel-energy-util")
local function copy_item(name, new_name)
    return flib.copy_prototype(data.raw["item"][name], new_name)
end
local salvaged_offshore_pump_item
if mods["P-U-M-P-S"] then
    salvaged_offshore_pump_item = copy_item("offshore-pump-0", "salvaged-offshore-pump-0")
else
    salvaged_offshore_pump_item = copy_item("offshore-pump", "salvaged-offshore-pump-0")
end
data:extend(
    {
        copy_item("bi-bio-farm", "coal-bi-bio-farm"),
        copy_item("bi-bio-greenhouse", "coal-bi-bio-greenhouse"),
        copy_item("bi-seed", "coal-tree-seed"),
        copy_item("seedling", "coal-seedling"),
        copy_item("mining-drill-bit-mk0", "salvaged-mining-drill-bit-mk0"),
        salvaged_offshore_pump_item,
        copy_item("burner-mining-drill", "salvaged-mining-drill"),
        copy_item("burner-ore-crusher", "salvaged-ore-crusher")
    }
)

-- поделки из дерева, кроме стружки и чего-то там ещё - не горят, резина не горит
-- электричка - не горит, тем более с лампами!
cleanup_fuel_category_for_Item("small-electric-pole")
cleanup_fuel_category_for_Item("bi-wooden-pole-big")
cleanup_fuel_category_for_Item("lighted-bi-wooden-pole-big")
cleanup_fuel_category_for_Item("bi-wooden-pole-huge")
cleanup_fuel_category_for_Item("lighted-bi-wooden-pole-huge")
-- в сундуках всяких хлам лежит - не горит
cleanup_fuel_category_for_Item("wooden-chest")
-- в трубах остаётся что угодно, они сырые, не горят
cleanup_fuel_category_for_Item("bi-wood-pipe")
cleanup_fuel_category_for_Item("bi-wood-pipe-to-ground")
-- винтовки и туррели - не жечь
cleanup_fuel_category_for_Item("bi-wooden-fence")
cleanup_fuel_category_for_Item("bi-dart-turret")
cleanup_fuel_category_for_Item("bi-woodpulp")
--резину не жечь
cleanup_fuel_category_for_Item("solid-rubber")
if data.raw.item["nuclear-fuel"] then
    data.raw.item["nuclear-fuel"].burnt_result = nil
end
local function change_fuel_value(prototype, multiplier)
    prototype.stack_size = prototype.stack_size * multiplier
end

local function clear_fuel_modifier(prototype)
    prototype.fuel_acceleration_multiplier = nil
    prototype.fuel_top_speed_multiplier = nil
end

if mods["Clowns-AngelBob-Nuclear"] then
    if data.raw.item["hypernuclear-fuel"] then
        change_fuel_value(data.raw.item["hypernuclear-fuel"], 20)
        clear_fuel_modifier(data.raw.item["hypernuclear-fuel"])
    end
    if data.raw.item["turbonuclear-fuel"] then
        change_fuel_value(data.raw.item["turbonuclear-fuel"], 20)
        clear_fuel_modifier(data.raw.item["turbonuclear-fuel"])
    end
    if data.raw.item["radiothermal-fuel"] then
        change_fuel_value(data.raw.item["radiothermal-fuel"], 20)
        clear_fuel_modifier(data.raw.item["radiothermal-fuel"])
    end
    if data.raw.item["superradiothermal-fuel"] then
        change_fuel_value(data.raw.item["superradiothermal-fuel"], 20)
        clear_fuel_modifier(data.raw.item["superradiothermal-fuel"])
    end
    if data.raw.item["ultraradiothermal-fuel"] then
        change_fuel_value(data.raw.item["ultraradiothermal-fuel"], 20)
        clear_fuel_modifier(data.raw.item["ultraradiothermal-fuel"])
    end
end
