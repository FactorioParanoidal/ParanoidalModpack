if mods["Krastorio2-spaced-out"] or mods["Krastorio2"] then return end

local effects = data.raw.technology["maraxsis-deepsea-research"].effects

data:extend { {
    type = "item-subgroup",
    name = "maraxsis-deepsea-research",
    order = "yy",
    group = "intermediate-products",
} }

local automation_science = table.deepcopy(data.raw.recipe["automation-science-pack"])
local logistic_science = table.deepcopy(data.raw.recipe["logistic-science-pack"])
local military_science = table.deepcopy(data.raw.recipe["military-science-pack"])
local workshop_science  -- optional workshop science placement in slot 4
local chemical_science = table.deepcopy(data.raw.recipe["chemical-science-pack"])
local production_science = table.deepcopy(data.raw.recipe["production-science-pack"])
local utility_science = table.deepcopy(data.raw.recipe["utility-science-pack"])
local science_packs = {automation_science, logistic_science, military_science, chemical_science, production_science, utility_science}
if data.raw.recipe["workshop-science-pack"] then
    -- insert workshop science at index 4
    workshop_science = table.deepcopy(data.raw.recipe["workshop-science-pack"])
    table.insert(science_packs, 4, workshop_science)
end

local function update_recipe_icon(recipe, fluid)
    local science_pack = data.raw.item[recipe.name]
    if not (recipe.icon or science_pack.icon) then return end
    fluid = data.raw.fluid[fluid]
    recipe.icons = {
        { icon = recipe.icon or science_pack.icon, icon_size = recipe.icon_size or science_pack.icon_size },
        { icon = fluid.icon,                       icon_size = fluid.icon_size,                           scale = 0.4, shift = { 6, 6 } },
    }
    recipe.icon = nil
    recipe.icon_size = nil
end

update_recipe_icon(automation_science, "maraxsis-saline-water")
update_recipe_icon(logistic_science, "maraxsis-brackish-water")
update_recipe_icon(military_science, "lava")
update_recipe_icon(chemical_science, "water")
update_recipe_icon(production_science, "oxygen")
update_recipe_icon(utility_science, "hydrogen")

table.insert(automation_science.ingredients, { type = "fluid", name = "maraxsis-saline-water", amount = 50 })
table.insert(logistic_science.ingredients, { type = "fluid", name = "maraxsis-brackish-water", amount = 50 })
table.insert(military_science.ingredients, { type = "fluid", name = "lava", amount = 100 })
table.insert(chemical_science.ingredients, { type = "fluid", name = "water", amount = 100 })
table.insert(production_science.ingredients, { type = "fluid", name = "oxygen", amount = 100 })
table.insert(utility_science.ingredients, { type = "fluid", name = "hydrogen", amount = 200 })

if workshop_science then
    update_recipe_icon(workshop_science, "lava")
    table.insert(workshop_science.ingredients, { type = "fluid", name = "lava", amount = 100 })
end

for _, recipe in ipairs(science_packs) do
    recipe.localised_name = { "item-name." .. recipe.name }
    recipe.name = "maraxsis-deepsea-research-" .. recipe.name
    recipe.categories = { "maraxsis-hydro-plant" }
    recipe.subgroup = "maraxsis-deepsea-research"
    recipe.enabled = false
    recipe.auto_recycle = false
    recipe.surface_conditions = maraxsis.trench_surface_conditions()
    recipe.results[1].amount = recipe.results[1].amount * 2
    if mods["quality"] then -- only apply min quality buff with Quality mod enabled
        recipe.results[1].quality_min = recipe.results[1].quality_min or "uncommon"
    end
    effects[#effects + 1] = { type = "unlock-recipe", recipe = recipe.name }
end

data:extend(science_packs)
