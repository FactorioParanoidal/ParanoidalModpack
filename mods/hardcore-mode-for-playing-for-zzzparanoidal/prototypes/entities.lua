local function copy_entity(_type, name, new_name)
    return flib.copy_prototype(data.raw[_type][name], new_name)
end

local coal_bi_bio_farm_entity = copy_entity("assembling-machine", "bi-bio-farm", "coal-bi-bio-farm")
coal_bi_bio_farm_entity.energy_source = {
    type = "burner",
    fuel_inventory_size = 5,
    effectivity = 0.2
}
coal_bi_bio_farm_entity.crafting_speed = 0.1

local coal_bi_bio_greenhouse_entity = copy_entity("assembling-machine", "bi-bio-greenhouse", "coal-bi-bio-greenhouse")
coal_bi_bio_greenhouse_entity.energy_source = {
    type = "burner",
    fuel_inventory_size = 20,
    effectivity = 0.15
}
coal_bi_bio_greenhouse_entity.crafting_speed = 0.1

local salvaged_offshore_pump_0_entity
if mods["P-U-M-P-S"] then
    salvaged_offshore_pump_0_entity = copy_entity("offshore-pump", "offshore-pump", "salvaged-offshore-pump-0")
else
    salvaged_offshore_pump_0_entity = copy_entity("offshore-pump", "offshore-pump", "salvaged-offshore-pump-0")
end
salvaged_offshore_pump_0_entity.energy_source = {
    type = "void"
}
salvaged_offshore_pump_0_entity.pumping_speed = 100

coal_bi_bio_greenhouse_entity.energy_source = {
    type = "burner",
    fuel_inventory_size = 20,
    effectivity = 0.15
}

local coal_seedling_entity = flib.copy_prototype(data.raw["simple-entity-with-force"]["seedling"], "coal-seedling")

local salvaged_mining_drill_entity = copy_entity("mining-drill", "burner-mining-drill", "salvaged-mining-drill")
coal_bi_bio_greenhouse_entity.energy_source = {
    type = "burner",
    fuel_inventory_size = 20,
    effectivity = 0.15
}

salvaged_mining_drill_entity.mining_speed = 0.1
local salvaged_ore_crusher_entity = copy_entity("assembling-machine", "burner-ore-crusher", "salvaged-ore-crusher")
salvaged_ore_crusher_entity.energy_source = {
    type = "burner",
    fuel_inventory_size = 20,
    effectivity = 0.15
}
salvaged_ore_crusher_entity.crafting_speed = 0.1

data:extend(
    {
        coal_bi_bio_farm_entity,
        coal_bi_bio_greenhouse_entity,
        coal_seedling_entity,
        salvaged_offshore_pump_0_entity,
        salvaged_mining_drill_entity,
        salvaged_ore_crusher_entity
    }
)
-- для последних уровней бойлера ставим эффективностьв 0.9, вместо 1.15 и 1.25...
data.raw["boiler"]["boiler-4"].energy_source.effectivity = 0.9
data.raw["boiler"]["boiler-5"].energy_source.effectivity = 0.9
-- разрешаем ядерным печам выпускать 2 продукта для плавки рецептов вида (1,0)->(2,0)
if data.raw["furnace"]["nuclear-furnace"] then
    data.raw["furnace"]["nuclear-furnace"].result_inventory_size = 2
end
-- добавление категорий рецептов в химические заводы
if data.raw["assembling-machine"]["angels-chemical-plant"] then
    data.raw["assembling-machine"]["angels-chemical-plant"].crafting_categories =
        data.raw["assembling-machine"]["angels-chemical-plant"].crafting_categories or {}
    table.insert(data.raw["assembling-machine"]["angels-chemical-plant"].crafting_categories, "liquifying")
end
if data.raw["assembling-machine"]["angels-chemical-plant-2"] then
    data.raw["assembling-machine"]["angels-chemical-plant-2"].crafting_categories =
        data.raw["assembling-machine"]["angels-chemical-plant-2"].crafting_categories or {}
    table.insert(data.raw["assembling-machine"]["angels-chemical-plant-2"].crafting_categories, "liquifying")
end
if data.raw["assembling-machine"]["angels-chemical-plant-3"] then
    data.raw["assembling-machine"]["angels-chemical-plant-3"].crafting_categories =
        data.raw["assembling-machine"]["angels-chemical-plant-3"].crafting_categories or {}
    table.insert(data.raw["assembling-machine"]["angels-chemical-plant-3"].crafting_categories, "petrochem-boiler")
end

--Химический завод теперь имеет третий вход(сбоку, начиная с уровня 2 для производства рецептов с трёмя жидкостями на входе)
if data.raw.item["angels-chemical-plant"] then
    for i = 2, 4 do
        _table.insert(
            data.raw["assembling-machine"]["angels-chemical-plant-" .. i].fluid_boxes,
            {
                production_type = "input",
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = -1,
                pipe_connections = { { type = "input", position = { -2, 0 } } }
            }
        )
    end
end

if data.raw["locomotive"]["JunkTrain"] then
    if _table.get_item_index(data.raw["locomotive"]["JunkTrain"].flags, "not-on-map") then
        _table.remove_item(data.raw["locomotive"]["JunkTrain"].flags, "not-on-map")
    end
    data.raw["locomotive"]["JunkTrain"].minimap_representation =
    {
        filename = "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-minimap-representation.png",
        flags = { "icon" },
        size = { 20, 40 },
        scale = 0.5
    }
    data.raw["locomotive"]["JunkTrain"].selected_minimap_representation =
    {
        filename = "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-selected-minimap-representation.png",
        flags = { "icon" },
        size = { 20, 40 },
        scale = 0.5
    }
end

if data.raw["cargo-wagon"]["ScrapTrailer"] then
    if data.raw["cargo-wagon"]["ScrapTrailer"].flags and _table.get_item_index(data.raw["cargo-wagon"]["ScrapTrailer"].flags, "not-on-map") then
        _table.remove_item(data.raw["cargo-wagon"]["ScrapTrailer"].flags, "not-on-map")
    end
    data.raw["cargo-wagon"]["ScrapTrailer"].minimap_representation =
    {
        filename = "__base__/graphics/entity/cargo-wagon/cargo-wagon-minimap-representation.png",
        flags = { "icon" },
        size = { 20, 40 },
        scale = 0.5
    }
    data.raw["cargo-wagon"]["ScrapTrailer"].selected_minimap_representation =
    {
        filename = "__base__/graphics/entity/cargo-wagon/cargo-wagon-selected-minimap-representation.png",
        flags = { "icon" },
        size = { 20, 40 },
        scale = 0.5
    }
end
