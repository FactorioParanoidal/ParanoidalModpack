---Krastorio2-spaced-out compatibility
if mods["Krastorio2-spaced-out"] then
    


    local rro = Muluna.rro

    rro.replace_field(data.raw["technology"]["kr-singularity-lab"].effects,"recipe","biolab","cryolab")
    rro.soft_insert(data.raw["technology"]["kr-singularity-lab"].prerequisites,"cryolab")

    data.raw["recipe"]["muluna-regolith-digging"].results[2].shared_probability.max = 0.975
    table.insert(data.raw["recipe"]["muluna-regolith-digging"].results,{type = "item", name = "kr-rare-metal-ore",amount = 1,shared_probability = {min = 0.975,max = 1}})


    data.raw["technology"]["muluna-silicon-processing"].localised_name = {"technology-name.muluna-silicon-processing-alt"}

    local advanced_anorthite = data.raw["recipe"]["advanced-anorthite-crushing"]
    local silicon = data.raw["item"]["kr-silicon"]
    if silicon then
        advanced_anorthite.icons[3].icon = silicon.icon
        advanced_anorthite.icons[4].icon = silicon.icon
        advanced_anorthite.icons[3].icon_size = silicon.icon_size
        advanced_anorthite.icons[4].icon_size = silicon.icon_size
    end
    rro.remove(data.raw["technology"]["muluna-oxygen"].effects,{
                type = "unlock-recipe",
                recipe = "muluna-oxygen-from-oxidizer"
            })
    data.raw["technology"]["muluna-wood-cultivation"].research_trigger.amount = 10

    -- Krastorio 2's flare stack can burn any fluid, which makes Muluna's gas venting
    -- technology and its recipes redundant and more expensive. Remove them.
    -- https://github.com/nicholasgower/planet-muluna/issues/474
    local gas_venting = data.raw["technology"]["muluna-gas-venting"]
    if gas_venting then
        local venting_recipes = {
            ["oxygen-venting"] = true,
            ["carbon-dioxide-venting"] = true,
            ["hydrogen-venting"] = true,
        }
        --Also collect any other recipe the technology happens to unlock.
        for _,effect in pairs(gas_venting.effects or {}) do
            if effect.type == "unlock-recipe" then
                venting_recipes[effect.recipe] = true
            end
        end

        data.raw["technology"]["muluna-gas-venting"] = nil
        for recipe_name in pairs(venting_recipes) do
            if data.raw["recipe"][recipe_name] then
                data.raw["recipe"][recipe_name] = nil
            end
        end

        --Remove any references to the removed technology and recipes left by other mods.
        for _,technology in pairs(data.raw["technology"]) do
            if technology.prerequisites and rro.contains(technology.prerequisites,"muluna-gas-venting") then
                rro.remove(technology.prerequisites,"muluna-gas-venting")
                if #technology.prerequisites == 0 then
                    technology.prerequisites = nil
                end
            end
            if technology.effects then
                for recipe_name in pairs(venting_recipes) do
                    rro.remove(technology.effects,{type = "unlock-recipe", recipe = recipe_name})
                end
            end
        end
    end

    table.insert(Muluna.constants.cargo_drop_spawn_imports,"__planet-muluna__.scripts.cargo-drop-spawns.kr-electrolysis-plant")
end