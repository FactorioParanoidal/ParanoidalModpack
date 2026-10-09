-- Selected energy decisions, not a blanket rollback. Must run after OV, flowfix and menu/icon patches.
local util = require("util")
local port = require("tweaks.custom.energy-port-data")
local function apply(prototype, fields)
    assert(prototype, "Energy port: missing prototype")
    for key, value in pairs(fields) do prototype[key] = table.deepcopy(value) end
end
-- JSON recipe rename directly to the new recipe discards incompatible buffered ingredients
-- before Lua can recover them. Preserve the old layouts until the one-time Lua migration.
for name, fields in pairs(port.migration_recipes) do
    local recipe = table.deepcopy(assert(data.raw.recipe[name]))
    apply(recipe, fields)
    recipe.name = "paranoidal-energy-migration-" .. name
    recipe.hidden, recipe.enabled = true, false
    recipe.hide_from_player_crafting, recipe.hide_from_signal_gui = true, true
    recipe.localised_name = {"item-name.uranium-fuel-cell"}
    data:extend({recipe})
end
for name, fields in pairs(port.items) do apply(data.raw.item[name], fields) end
for name, fields in pairs(port.recipes) do apply(data.raw.recipe[name], fields) end
for _, entry in ipairs(port.entities) do apply(data.raw[entry.type][entry.name], entry.fields) end
data.raw.boiler["bi-bio-boiler"].energy_source.effectivity = port.bio_effectivity

for name, fields in pairs(port.cranes) do
    local crane = assert(data.raw.inserter[name])
    for key, value in pairs(fields) do
        if key == "drain" then crane.energy_source.drain = value else crane[key] = value end
    end
    -- Beta 8 deliberately made cranes non-stack inserters, with their own capacity.
    -- In 2.0 bulk is the corresponding research-bonus flag; geometry/filters stay 2.0.
    crane.stack = nil
end

local prerequisites = data.raw.technology["bob-steam-turbine-1"].prerequisites
local found = false
for _, name in ipairs(prerequisites) do if name == "bob-cobalt-processing" then found = true end end
if not found then prerequisites[#prerequisites + 1] = "bob-cobalt-processing" end

for name, fields in pairs(port.fluids) do
    apply(data.raw.fluid[name], fields)
    for _, barrel_name in ipairs(port.barrels[name]) do
        local barrel = assert(data.raw.item[barrel_name])
        barrel.fuel_category = "chemical"
        barrel.fuel_value = tostring(util.parse_energy(fields.fuel_value) * 100) .. "J"
        barrel.fuel_emissions_multiplier = fields.emissions_multiplier
        -- Keep the 2.0 container lifecycle; burning does not introduce a new return-container rule.
    end
end

-- Clone one existing recipe per building: same batch/time/emissions as that building's recipes.
local templates = {
    ["angels-chemical-void"] = "angels-chemical-void-angels-gas-compressed-air",
    ["angels-water-void"] = "angels-water-void-clowns-water-radioactive-waste",
}
for category, names in pairs(port.voids) do
    for _, name in ipairs(names) do
        local exists = false
        for _, recipe in pairs(data.raw.recipe) do
            if recipe.category == category then
                for _, ingredient in pairs(recipe.ingredients or {}) do
                    if ingredient.type == "fluid" and ingredient.name == name then exists = true end
                end
            end
        end
        if not exists then
            local recipe = table.deepcopy(assert(data.raw.recipe[templates[category]]))
            local fluid = assert(data.raw.fluid[name])
            recipe.name = category .. "-" .. name
            recipe.ingredients[1].name = name
            recipe.localised_name = {"recipe-name." .. category, {"fluid-name." .. name}}
            recipe.icons = table.deepcopy(fluid.icons)
            recipe.icon, recipe.icon_size = fluid.icon, fluid.icon_size
            recipe.crafting_machine_tint = {primary = fluid.base_color, secondary = fluid.flow_color}
            recipe.order = fluid.order
            data:extend({recipe})
        end
    end
end

local merged = {
    ["wood-bricks"] = "angels-wood-bricks",
    ["pellet-coke"] = "angels-pellet-coke",
    ["wood-charcoal"] = "angels-wood-charcoal",
    ["angels-uranium-fuel-cell"] = "uranium-fuel-cell",
}
local function replace_products(products)
    for _, product in pairs(products or {}) do
        if (product.type or "item") == "item" then
            if merged[product.name] then product.name = merged[product.name] end
            if merged[product[1]] then product[1] = merged[product[1]] end
        end
    end
end
for _, recipe in pairs(data.raw.recipe) do
    replace_products(recipe.ingredients)
    replace_products(recipe.results)
    if merged[recipe.result] then recipe.result = merged[recipe.result] end
    if merged[recipe.main_product] then recipe.main_product = merged[recipe.main_product] end
end
for _, prototypes in pairs(data.raw) do
    for _, prototype in pairs(prototypes) do
        if prototype.minable then
            replace_products(prototype.minable.results)
            if merged[prototype.minable.result] then prototype.minable.result = merged[prototype.minable.result] end
        end
        for _, loot in pairs(prototype.loot or {}) do
            if merged[loot.item] then loot.item = merged[loot.item] end
        end
        if merged[prototype.burnt_result] then prototype.burnt_result = merged[prototype.burnt_result] end
    end
end
-- Recipe IDs for the nine solid-fuel methods are retained: machines keep their chosen method.
-- The obsolete 100-cell recipe is hidden; JSON + Lua migration safely moves machine recipes.
local obsolete = data.raw.recipe["angels-uranium-fuel-cell"]
obsolete.hidden, obsolete.enabled = true, false
obsolete.hide_from_player_crafting, obsolete.hide_from_signal_gui = true, true
for _, technology in pairs(data.raw.technology) do
    for i = #(technology.effects or {}), 1, -1 do
        local effect = technology.effects[i]
        if effect.type == "unlock-recipe" and effect.recipe == obsolete.name then table.remove(technology.effects, i) end
    end
end
for old in pairs(merged) do data.raw.item[old] = nil end

-- Existing three black cylinders, identical for the common item and all four methods.
local icon = "__zzzparanoidal__/graphics/petrochem-fluid-menu-beta8/db864c41bc72dc20dbf6.png"
for _, name in ipairs({"angels-pellet-coke", "bi-pellet-coke", "bi-coke-coal", "bi-pellet-coke-2"}) do
    local recipe = data.raw.recipe[name]
    recipe.icons, recipe.icon, recipe.icon_size = nil, icon, 64
    recipe.localised_name = {"item-name.angels-pellet-coke"}
end
local pellet = data.raw.item["angels-pellet-coke"]
pellet.icons, pellet.icon, pellet.icon_size = nil, icon, 64
pellet.pictures = {filename = icon, size = 64, scale = 0.5, mipmap_count = 4}
