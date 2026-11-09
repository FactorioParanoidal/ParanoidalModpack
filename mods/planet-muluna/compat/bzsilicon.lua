local rro = Muluna.rro
-- if mods["bzsilicon"] or mods["bztitanium"] or mods["bztin"] or mods["bzlead"] or mods["bzzirconium"] or mods["bzsilicon"] then
--     

--     for _,crusher in pairs(crushers) do
--         table.insert(data.raw["assembling-machine"][crusher].crafting_categories,"basic-crushing")
--     end

--     local recipes_original = {"electronic-circuit","advanced-circuit","electric-engine-unit","low-density-structure"}
--     local recipes = {"electronic-circuit-aluminum","advanced-circuit-aluminum","electric-engine-unit-from-carbon"}
--     for i,recipe_name in ipairs(recipes) do
--         local recipe = data.raw["recipe"][recipe_name]
--         recipe.ingrdients=table.deepcopy(data.raw["recipe"][recipes_original[i]].ingredients)
--         for _,ingredient in pairs(recipe.ingredients) do
--             if ingredient.name=="copper-cable" then
--                 ingredient.name="aluminum-cable"
--             end
--             if ingredient.name=="carbon" then
--                 ingredient.name="graphite"
--             end
--         end
--     end
-- end

if data.raw["furnace"]["basic-crusher"] and not mods["crushing-industry"] then
    local crushers = {"crusher", "muluna-crusher-2"}
    for _,crusher in pairs(crushers) do
            table.insert(data.raw["assembling-machine"][crusher].crafting_categories,"basic-crushing")
        end
    for _,recipe in pairs(data.raw["recipe"]) do
        if rro.contains(recipe.categories,"basic-crushing") then
            if recipe.energy_required then
                recipe.energy_required = recipe.energy_required / 8
            else
                recipe.energy_required = 0.5 / 8
            end
        end
    end
    data.raw["furnace"]["basic-crusher"].crafting_speed = data.raw["furnace"]["basic-crusher"].crafting_speed / 8
    if data.raw["furnace"]["bioluminescent-basic-crusher"] then
        data.raw["furnace"]["bioluminescent-basic-crusher"].crafting_speed = data.raw["furnace"]["bioluminescent-basic-crusher"].crafting_speed / 8
    end
end

if mods["bztitanium"] then
    table.insert(data.raw["recipe"]["muluna-regolith-digging"].results,{type = "item", name = "titanium-ore",amount = 1,independent_probability = 0.025})
    -- data.raw["planet"]["muluna"].map_gen_settings.autoplace_controls["titanium-ore"] = {}
    -- data.raw["planet"]["muluna"].map_gen_settings.autoplace_settings["entity"]["settings"]["titanium-ore"] = {}
    rro.remove(data.raw["technology"]["wood-gas-processing-to-crude-oil"].unit.ingredients,{"space-science-pack",1})
    rro.remove(data.raw["technology"]["wood-gas-processing-to-crude-oil"].unit.ingredients,{"production-science-pack",1})
end
if mods["bzzirconium"] then
    table.insert(data.raw["recipe"]["muluna-regolith-digging"].results,{type = "item", name = "zircon",amount = 1,independent_probability = 0.05})
end

if mods["bzsilicon"] then
    data.raw["technology"]["muluna-silicon-processing"].localised_name = {"technology-name.muluna-silicon-processing-alt"}
end

local function move_recipe(recipe,tech,tech_new) 
    rro.remove(data.raw.technology[tech].effects,{type = "unlock-recipe", recipe = recipe})
    table.insert(data.raw.technology[tech_new].effects,{type = "unlock-recipe", recipe = recipe})
end

if data.raw["recipe"]["alternative-metallic-asteroid-crushing"] then
    move_recipe("alternative-metallic-asteroid-crushing","space-platform-thruster","metallic-asteroid-crushing")
end
if data.raw["recipe"]["alternative-carbonic-asteroid-crushing"] then
    move_recipe("alternative-carbonic-asteroid-crushing","space-platform-thruster","carbonic-asteroid-crushing")
end
if data.raw["recipe"]["metallic-asteroid-crushing-tin"] then
    move_recipe("metallic-asteroid-crushing-tin","space-platform-thruster","metallic-asteroid-crushing")
end

