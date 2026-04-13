local modutils = {}

---@alias RecipeComponent data.FluidIngredientPrototype|data.ItemIngredientPrototype|data.FluidProductPrototype|data.ItemProductPrototype

---@param base RecipeComponent[]?
---@param nospace_ingredients RecipeComponent[]?
---@param space_ingredients RecipeComponent[]?
---@return RecipeComponent[]
function modutils.select(base, nospace_ingredients, space_ingredients)
    local adds
    if mods["space-age"] then
        adds = space_ingredients
    else
        adds = nospace_ingredients
    end
    if not adds then return base end
    if not base then return adds end

    for _, ingredient in pairs(adds) do
        table.insert(base, ingredient)
    end
    return base
end

---@param base any[]?
---@param nospace_elements any[]?
---@param space_elements any[]?
---@return any[]
function modutils.select_any(base, nospace_elements, space_elements)
    local adds
    if mods["space-age"] then
        adds = space_elements
    else
        adds = nospace_elements
    end
    if not adds then return base end
    if not base then return adds end

    for _, ingredient in pairs(adds) do
        table.insert(base, ingredient)
    end
    return base
end

---@param recipes string[]
---@return {type:"unlock-recipe", recipe:string}[]
function modutils.unlock_recipes(recipes)
    local result = {}
    for _, recipe in pairs(recipes) do
        table.insert(result,
            {
                type = "unlock-recipe",
                recipe = recipe
            })
    end
    return result
end

modutils.tungsten_carbide = "tungsten-carbide"
modutils.tungsten_plate = "tungsten-plate"
modutils.foundry = "foundry"

modutils.holmium_plate = "holmium-plate"
modutils.superconductor = "superconductor"
modutils.electromagnetic_plant = "electromagnetic-plant"

modutils.biolab = "biolab"
modutils.carbon_fiber = "carbon-fiber"
modutils.biochamber = "biochamber"

modutils.cryogenic_plant = "cryogenic-plant"
modutils.lithium_plate = "lithium-plate"
modutils.quantum_processor = "quantum-processor"
modutils.fusion_power_cell = "fusion-power-cell"

modutils.thruster = "thruster"
modutils.cargo_bay = "cargo-bay"
modutils.asteroid_collector = "asteroid-collector"
modutils.crusher = "crusher"

function modutils.full_science_pack()
    return modutils.select_any(
        {
            { "automation-science-pack", 1 },
            { "logistic-science-pack",   1 },
            { "chemical-science-pack",   1 },
            { "production-science-pack", 1 },
            { "utility-science-pack",    1 },
            { "space-science-pack",      1 }
        }, nil, {
            { "metallurgic-science-pack",     1 },
            { "agricultural-science-pack",    1 },
            { "electromagnetic-science-pack", 1 },
            { "cryogenic-science-pack",       1 },
        })
end

return modutils
