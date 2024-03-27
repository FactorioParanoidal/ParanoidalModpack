local function copy_entity(_type, name, new_name)
	return flib.copy_prototype(data.raw[_type][name], new_name)
end

local coal_bi_bio_farm_entity = copy_entity("assembling-machine", "bi-bio-farm", "coal-bi-bio-farm")
coal_bi_bio_farm_entity.energy_source = {
	type = "burner",
	fuel_inventory_size = 5,
	effectivity = 0.2,
}
coal_bi_bio_farm_entity.crafting_speed = 0.1

local coal_bi_bio_greenhouse_entity = copy_entity("assembling-machine", "bi-bio-greenhouse", "coal-bi-bio-greenhouse")
coal_bi_bio_greenhouse_entity.energy_source = {
	type = "burner",
	fuel_inventory_size = 20,
	effectivity = 0.15,
}
coal_bi_bio_greenhouse_entity.crafting_speed = 0.1

local salvaged_ofshore_pump_0_entity = copy_entity("offshore-pump", "offshore-pump", "salvaged-offshore-pump-0")
salvaged_ofshore_pump_0_entity.energy_source = {
	type = "burner",
	fuel_inventory_size = 20,
	effectivity = 0.15,
}
salvaged_ofshore_pump_0_entity.pumping_speed = 50

coal_bi_bio_greenhouse_entity.energy_source = {
	type = "burner",
	fuel_inventory_size = 20,
	effectivity = 0.15,
}

local coal_seedling_entity = flib.copy_prototype(data.raw["simple-entity-with-force"]["seedling"], "coal-seedling")

local salvaged_mining_drill_entity = copy_entity("mining-drill", "burner-mining-drill", "salvaged-mining-drill")
coal_bi_bio_greenhouse_entity.energy_source = {
	type = "burner",
	fuel_inventory_size = 20,
	effectivity = 0.15,
}

salvaged_mining_drill_entity.mining_speed = 0.1
local salvaged_ore_crusher_entity = copy_entity("assembling-machine", "burner-ore-crusher", "salvaged-ore-crusher")
salvaged_ore_crusher_entity.energy_source = {
	type = "burner",
	fuel_inventory_size = 20,
	effectivity = 0.15,
}
salvaged_ore_crusher_entity.crafting_speed = 0.1

data:extend({
	coal_bi_bio_farm_entity,
	coal_bi_bio_greenhouse_entity,
	coal_seedling_entity,
	salvaged_ofshore_pump_0_entity,
	salvaged_mining_drill_entity,
	salvaged_ore_crusher_entity,
})
-- для последних уровней бойлера ставим эффективностьв 0.9, вместо 1.15 и 1.25...
data.raw["boiler"]["boiler-4"].energy_source.effectivity = 0.9
data.raw["boiler"]["boiler-5"].energy_source.effectivity = 0.9
