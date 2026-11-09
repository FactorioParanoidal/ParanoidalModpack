local table = require("lib.table")

for _, lab in pairs(data.raw.lab) do
    for _, input in pairs(lab.inputs or {}) do
        if input == "cryogenic-science-pack" then
            lab.inputs = lab.inputs or {}
            if not table.find(lab.inputs, "hydraulic-science-pack") then
                table.insert(lab.inputs, "hydraulic-science-pack")
            end
            -- Paranoidal fork: no sorting, the home labs keep the order of their slots.
            break
        end
    end
end

if settings.startup["maraxsis-add-hydraulic-science"].value then
    local function add_hydraulic_pack(tech_name)
        local tech = data.raw.technology[tech_name]
        if not tech then return end

        if tech.unit and tech.unit.ingredients then table.insert(tech.unit.ingredients, {"hydraulic-science-pack", 1}) end
    end

    add_hydraulic_pack("stellar-discovery-solar-system-edge")
    add_hydraulic_pack("promethium-science-pack")
    add_hydraulic_pack("research-productivity")

    table.insert(data.raw["technology"]["stellar-discovery-solar-system-edge"].prerequisites, "maraxsis-project-seadragon")
end

local function insert_hydro_plant(recipe)
    if not recipe then
        return
    end
    local categories = recipe.categories or {"crafting"}
    table.insert(categories,"maraxsis-hydro-plant")
    recipe.categories = categories
end

insert_hydro_plant(data.raw.recipe["pump"])
insert_hydro_plant(data.raw.recipe["pipe"])
insert_hydro_plant(data.raw.recipe["pipe-to-ground"])
insert_hydro_plant(data.raw.recipe["storage-tank"])
insert_hydro_plant(data.raw.recipe["coal-synthesis"])
insert_hydro_plant(data.raw.recipe["engine-unit"])
insert_hydro_plant(data.raw.recipe["electric-engine-unit"])

-- Paranoidal fork: no own rocket part, so no productivity effect for it (rocket part productivity covers the rocket part).

if data.raw.technology["rocket-fuel-productivity"] then
    table.insert(data.raw.technology["rocket-fuel-productivity"].effects, {
        type = "change-recipe-productivity",
        recipe = "maraxsis-hydrolox-rocket-fuel",
        change = 0.1,
    })
end

if data.raw.technology["plastic-bar-productivity"] then
    table.insert(data.raw.technology["plastic-bar-productivity"].effects, 2, {
        type = "change-recipe-productivity",
        recipe = "maraxsis-smelt-microplastics",
        change = 0.1,
    })
end

local new_spidertron_effects = {}
for _, effect in pairs(data.raw.technology["spidertron"].effects) do
    if effect.recipe ~= "maraxsis-regulator" then
        table.insert(new_spidertron_effects, effect)
    end
end
data.raw.technology["spidertron"].effects = new_spidertron_effects

insert_hydro_plant(data.raw.recipe["ice-melting"])
insert_hydro_plant(data.raw.recipe["advanced-thruster-fuel"])
insert_hydro_plant(data.raw.recipe["advanced-thruster-oxidizer"])

-- Paranoidal fork: the home tank keeps its equipment grid (upstream gave it an own copy of the medium grid, so that the
-- abyssal diving gear category of the armor grids does not reach it).

for _, armor in pairs(data.raw.armor) do
    if type(armor) ~= "table" then goto continue end
    if not armor.equipment_grid then goto continue end
    local grid = data.raw["equipment-grid"][armor.equipment_grid]
    if not grid then goto continue end
    if not grid.equipment_categories then goto continue end
    if type(grid.equipment_categories) ~= "table" then goto continue end

    for _, category in pairs(grid.equipment_categories) do
        if category == "armor" then
            table.insert(grid.equipment_categories, "maraxsis-armor-category")
            break
        end
    end
    ::continue::
end

for _, module in pairs(data.raw.module) do
    if module.name:find("quality%-module") and not module.beacon_tint then
        module.beacon_tint = {
            primary = {1, 0, 0},
            secondary = {1, 0.37, 0.37},
        }
    end
end

-- Paranoidal fork: uranium fuel cells keep their properties (upstream gave them vehicle bonuses for the nuclear
-- submarine).

data.raw["assembling-machine"]["crusher"].surface_conditions = nil

--Factorio 2.1.24 removed the crusher's heating energy and pollution emission.
--Restore the 2.1.23 values so the crusher behaves the same on the stable and
--experimental releases. crusher-2 copies this prototype, so the values have to
--be restored before prototypes/entity/crusher-2.lua runs.
local vanilla_crusher = data.raw["assembling-machine"]["crusher"]
if vanilla_crusher then
    vanilla_crusher.heating_energy = vanilla_crusher.heating_energy or "200kW"
    vanilla_crusher.energy_source.emissions_per_minute =
        vanilla_crusher.energy_source.emissions_per_minute or {}
    vanilla_crusher.energy_source.emissions_per_minute["pollution"] =
        vanilla_crusher.energy_source.emissions_per_minute["pollution"] or 1
end