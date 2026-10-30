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
    -- Beta 8 cranes were non-stack inserters with their own capacity: in 2.0 that is bulk = false
    -- (set by the data above); geometry/filters stay 2.0.
end

local prerequisites = data.raw.technology["bob-steam-turbine-1"].prerequisites
local found = false
for _, name in ipairs(prerequisites) do if name == "bob-cobalt-processing" then found = true end end
if not found then prerequisites[#prerequisites + 1] = "bob-cobalt-processing" end

for name, fields in pairs(port.fluids) do
    apply(data.raw.fluid[name], fields)
    for _, barrel_name in ipairs(port.barrels[name] or {}) do
        local barrel = assert(data.raw.item[barrel_name])
        barrel.fuel_category = "chemical"
        barrel.fuel_value = tostring(util.parse_energy(fields.fuel_value) * 100) .. "J"
        barrel.fuel_emissions_multiplier = fields.emissions_multiplier
        -- Keep the 2.0 container lifecycle; burning does not introduce a new return-container rule.
    end
end

-- 2026-10-25 user decision (variant B): close energy-from-nothing at the raw sources by amounts only.
-- Coal cracking ~x1.5 like a ladder step; propene from methanol 80 -> 45.
local amount_fixes = {
    {recipe = "angels-coal-cracking-1", key = "ingredients", name = "coal", amount = 20},
    {recipe = "angels-coal-cracking-2", key = "ingredients", name = "coal", amount = 12},
    {recipe = "angels-gas-propene", key = "results", name = "angels-gas-propene", amount = 45},
}
for _, fix in ipairs(amount_fixes) do
    local found = false
    for _, entry in pairs(assert(data.raw.recipe[fix.recipe], fix.recipe)[fix.key]) do
        if entry.name == fix.name then entry.amount, found = fix.amount, true end
    end
    assert(found, "Energy port: " .. fix.recipe .. " has no " .. fix.name)
end

-- 2026-10-25 user decision (variant A): every fuel barrel equals its fluid. A fill recipe is
-- 1 fluid + 1 container -> 1 item, confirmed by an empty recipe returning that fluid from the item.
-- Energy = fluid fuel_value x fluid per item, emissions = fluid emissions (no clean-burning loophole).
local function list(recipe, key)
    local out = {}
    for _, entry in pairs(recipe[key] or {}) do
        out[#out + 1] = {type = entry.type or "item", name = entry.name or entry[1], amount = entry.amount or entry[2] or 1}
    end
    return out
end
local emptied = {}
for _, recipe in pairs(data.raw.recipe) do
    local ingredients = list(recipe, "ingredients")
    if #ingredients == 1 and ingredients[1].type == "item" then
        for _, result in ipairs(list(recipe, "results")) do
            if result.type == "fluid" then emptied[ingredients[1].name .. "|" .. result.name] = true end
        end
    end
end
for _, recipe in pairs(data.raw.recipe) do
    local ingredients, results = list(recipe, "ingredients"), list(recipe, "results")
    if #ingredients == 2 and #results == 1 and results[1].type == "item" then
        local fluid_in = ingredients[1].type == "fluid" and ingredients[1] or ingredients[2].type == "fluid" and ingredients[2]
        local other = fluid_in == ingredients[1] and ingredients[2] or ingredients[1]
        local fluid = fluid_in and data.raw.fluid[fluid_in.name]
        local barrel = data.raw.item[results[1].name]
        if fluid and fluid.fuel_value and other.type == "item" and barrel
            and emptied[barrel.name .. "|" .. fluid.name] then
            local per_item = fluid_in.amount / results[1].amount
            barrel.fuel_category = barrel.fuel_category or "chemical"
            barrel.fuel_value = tostring(util.parse_energy(fluid.fuel_value) * per_item) .. "J"
            barrel.fuel_emissions_multiplier = fluid.emissions_multiplier or 1
        end
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
