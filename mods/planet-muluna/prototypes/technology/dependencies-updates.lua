local rro=Muluna.rro




--replace_object(data.raw["technology"]["space-science-pack"].prerequisites,"space-platform-thruster","space-platform")
-- Paranoidal fork: the space science technology keeps the build's prerequisites and unlock (space science is made
-- on a space platform, ПР-079 item 6); upstream moved it behind Muluna.
--table.insert(data.raw["technology"]["space-science-pack"].prerequisites,"muluna-oxide-asteroid-processing")
-- table.insert(data.raw["technology"]["space-platform-thruster"].effects,{
--     type="unlock-space-location",
--     space_location="muluna"
-- })
-- Paranoidal fork: the space platform thruster technology keeps the build's unlocks, cost and prerequisites.


-- if false or mods["aai-signal-transmission"] then
--     rro.replace(data.raw["technology"]["space-platform-thruster"].prerequisites,"space-science-pack","aai-signal-transmission")
--     data.raw["technology"]["space-platform-thruster"].research_trigger = {
--         type="build-entity",
--         entity="aai-signal-receiver"
--     }
--     rro.replace(data.raw["technology"]["aai-signal-transmission"].prerequisites,"space-science-pack","space-platform")
--     rro.remove(data.raw["technology"]["aai-signal-transmission"].unit.ingredients,{"space-science-pack",1})
-- else
-- end

--rro.remove(data.raw["technology"]["space-platform-thruster"].unit.ingredients,{"space-science-pack",1})








--Removing asteroid collector,crusher, and asteroid crushing from space platform tech
local space_platform=data.raw["technology"]["space-platform"]
-- rro.remove(space_platform.effects,{type="unlock-recipe",recipe="asteroid-collector"})
-- rro.remove(space_platform.effects,{type="unlock-recipe",recipe="crusher"})
-- rro.remove(space_platform.effects,{type="unlock-recipe",recipe="metallic-asteroid-crushing"})
-- rro.remove(space_platform.effects,{type="unlock-recipe",recipe="carbonic-asteroid-crushing"})
-- rro.remove(space_platform.effects,{type="unlock-recipe",recipe="oxide-asteroid-crushing"})

-- if mods["aai-signal-transmission"] then
--     space_platform.effects = table.deepcopy(data.raw["technology"]["aai-signal-transmission"].effects)
--     rro.remove(space_platform.effects,{type="unlock-recipe",recipe="aai-signal-receiver"})
--     rro.remove(data.raw["technology"]["aai-signal-transmission"].effects,{type="unlock-recipe",recipe="aai-signal-sender"})
--     data.raw["technology"]["aai-signal-transmission"].unit=nil
--     data.raw["technology"]["aai-signal-transmission"].research_trigger = {
--         --type="send-item-to-orbit",
--         type="build-entity",
--         --item="aai-signal-sender"
--         entity="aai-signal-sender"
--     }
-- else

if settings.startup["muluna-easy-revert-changes-to-space-platform-technology"].value == true then

else
    for _,recipe in pairs({"asteroid-collector","crusher","metallic-asteroid-crushing","oxide-asteroid-crushing","carbonic-asteroid-crushing"}) do
        rro.remove(space_platform.effects,{type = "unlock-recipe",recipe = recipe})
    end
    
    --space_platform.effects = {}
end
-- end

-- Paranoidal fork: nothing before the rocket changes (ПР-078 rule 1): upstream turned the rocket silo technology
-- into a trigger (100 logistic robots), added 200 units to five home technologies, moved the logistic system
-- technology and changed the space science technology and recipe.



table.insert(data.raw["technology"]["rocket-part-productivity"].prerequisites,"production-science-pack")

--table.insert(data.raw["technology"]["advanced-asteroid-processing"].prerequisites,"muluna-advanced-stone-processing")
--table.insert(data.raw["technology"]["asteroid-reprocessing"].prerequisites,"muluna-advanced-stone-processing")

table.insert(data.raw["technology"]["wood-gas-processing"].prerequisites,"muluna-greenhouses")
rro.replace(data.raw["recipe"]["wood-gasification"].ingredients, {type = "item", name = "wood", amount = 10}, {type = "item", name = "cellulose", amount = 15})
--rro.replace(data.raw["recipe"]["advanced-wood-gasification"].ingredients, {type = "item", name = "wood", amount = 20}, {type = "item", name = "cellulose", amount = 20})
data.raw["recipe"]["wood-gasification"].allow_productivity = true
data.raw["recipe"]["advanced-wood-gasification"].allow_productivity = true
data.raw["technology"]["wood-gas-processing"].unit = nil
data.raw["technology"]["wood-gas-processing"].research_trigger = {
    type="mine-entity",
    entities={"lunar-rock"}
}
data.raw["technology"]["advanced-wood-gas-processing"].unit = {
    count = 500,
    time = 60,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        --{"interstellar-science-pack",1},
    }
}

rro.soft_insert(data.raw["technology"]["advanced-wood-gas-processing"].prerequisites,"production-science-pack")
rro.soft_insert(data.raw["technology"]["wood-gas-processing-to-crude-oil"].prerequisites,"production-science-pack")
rro.soft_insert(data.raw["technology"]["advanced-wood-gas-processing"].prerequisites,"space-science-pack")
rro.soft_insert(data.raw["technology"]["wood-gas-processing-to-crude-oil"].prerequisites,"space-science-pack")
rro.soft_insert(data.raw["technology"]["advanced-wood-gas-processing"].prerequisites,"utility-science-pack")

data.raw["technology"]["wood-gas-processing-to-crude-oil"].unit = {
    count = 500,
    time = 60,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        --{"utility-science-pack", 1},
        {"space-science-pack", 1},
        --{"interstellar-science-pack",1},
    }
}

table.insert(data.raw["technology"]["wood-gas-processing"].effects, {
    type = "unlock-recipe",
    recipe="plastic-from-wood"
})
if settings.startup["muluna-hardcore-classic-wood-gasification"].value == true then
    table.insert(data.raw["technology"]["wood-gas-processing"].effects, {
        type = "unlock-recipe",
        recipe="woodchips"
    })
end

    

table.insert(data.raw["technology"]["wood-gas-processing"].effects, {
    type = "unlock-recipe",
    recipe="cellulose"
})
-- table.insert(data.raw["technology"]["wood-gas-processing"].effects, {
--     type = "unlock-recipe",
--     recipe="cellulose"
-- })

--table.insert(data.raw["technology"]["advanced-wood-gas-processing"].prerequisites,"interstellar-science-pack")
--table.insert(data.raw["technology"]["wood-gas-processing-to-crude-oil"].prerequisites,"interstellar-science-pack")

-- data.raw["recipe"]["wood-greenhouse"].energy_required=10*60
-- data.raw["recipe"]["wood-seed-greenhouse"].energy_required=10*60
-- data.raw["recipe"]["wood-greenhouse"].surface_conditions={{property = "oxygen",min=1}}
-- data.raw["recipe"]["jellynut-seed-greenhouse"].energy_required=5*60
-- data.raw["recipe"]["yumako-seed-greenhouse"].energy_required=5*60
rro.remove(data.raw["technology"]["wood-gas-processing"].effects,{type = "unlock-recipe", recipe = "greenhouse"})
rro.remove(data.raw["technology"]["agriculture"].effects,{type = "unlock-recipe", recipe = "greenhouse"})
-- data.raw["recipe"]["greenhouse"] = nil
-- data.raw["item"]["I-greenhouse"] = nil
-- if data.raw["assembling-machine"]["E-greenhouse"] then
--     data.raw["assembling-machine"]["E-greenhouse"].minable = {mining_time = 0.5}
--     data.raw["assembling-machine"]["E-greenhouse"].localised_name = {"entity-name.n-deprecated",{"entity-name.E-greenhouse"}}
-- end

-- table.insert(data.raw["technology"]["heating-tower"].effects,
    
--         {
--             type = "unlock-recipe",
--             recipe = "advanced-water-boiling-high-temperature",
--         }
    
-- )
-- local seed_recipes = {"jellynut","yumako"}

-- for _,seed in pairs(seed_recipes) do
--     data.raw["recipe"][seed.."-seed-greenhouse"].surface_conditions = {{property = "oxygen",min=1}}--,{property = "pressure", min = 2000, max = 2000}}
-- end


--data.raw["item"]["E-greenhouse"]=nil
-- data.raw["recipe"]["greenhouse"].enabled = false

-- table.insert(data.raw["technology"]["tree-seeding"].effects, {
--     type = "unlock-recipe",
--     recipe="greenhouse"
-- })
-- Paranoidal fork: home items keep their import location and name, the home coal liquefaction technology its
-- unlocks (upstream: carbon, ice and space science imported from Muluna, own copper cable name, coal synthesis).

if settings.startup["muluna-hardcore-restrict-crusher"].value == true then
    data.raw["recipe"]["crusher"].surface_conditions = {{property = "oxygen", max = 0, min = 0},{property = "gravity", max = 2, min = 2}}
    table.insert(data.raw["recipe"]["crusher"].ingredients, {type = "item", name = "aluminum-plate", amount = 10})
    data.raw["item"]["crusher"].default_import_location = "muluna"
end


if settings.startup["muluna-hardcore-restrict-asteroid-collector"].value == true then
    data.raw["recipe"]["asteroid-collector"].surface_conditions = {{property = "oxygen", max = 0, min = 0},{property = "gravity", max = 2, min = 2}}
    table.insert(data.raw["recipe"]["asteroid-collector"].ingredients, {type = "item", name = "aluminum-plate", amount = 10})
    data.raw["item"]["asteroid-collector"].default_import_location = "muluna"
end

