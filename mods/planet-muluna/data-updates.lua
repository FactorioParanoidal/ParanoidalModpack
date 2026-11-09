require("prototypes.recipe.vanilla-alternate-recipes")
require("prototypes.planet.planet-position-update")
local rro = Muluna.rro
local dual_icon = require("lib.dual-item-icon").dual_icon

local rocket_prod=data.raw["technology"]["rocket-part-productivity"]

if data.raw.technology["rocket-part-productivity"] then
    data.raw.technology["rocket-part-productivity"].muluna_recipe_productivity_effects = {
        purge_other_effects = true,
        effects = {
            {
                type = "item",
                name = "rocket-part",
                change = 0.1
            }
        }
    }
    table.insert(data.raw.technology["rocket-part-productivity"].effects, {
        type = "change-recipe-productivity",
        recipe = "rocket-part-muluna",
        change = 0.1,
        hidden = true
    })
    -- if data.raw.recipe["nano-rocket-part"] then
    --     rro.soft_insert(rocket_prod.effects,
    --         {
    --             type = "change-recipe-productivity",
    --             recipe = "nano-rocket-part",
    --             change = 0.1,
    --             hidden = true
    --         }
    --     )
    -- end
    -- if data.raw.recipe["nano-rocket-part"] then
    --     rro.soft_insert(rocket_prod.effects,
    --         {
    --             type = "change-recipe-productivity",
    --             recipe = "anomalous-rocket-part",
    --             change = 0.1,
    --             hidden = true
    --         }
    --     )
    -- end
      
end

if settings.startup["muluna-change-quality-science-pack-drain"].value == true then
    for _,quality in pairs(data.raw["quality"]) do
        quality.science_pack_drain_multiplier = 1 /(1+ 0.3*quality.level)
        
        if quality.science_pack_drain_multiplier < 0.1 then
            quality.science_pack_drain_multiplier = 0.1
        end
        if quality.science_pack_drain_multiplier >= 1 then
            quality.science_pack_drain_multiplier = 1
        end
    end

end
local rocket_prod_aquilo=table.deepcopy(rocket_prod)
if settings.startup["muluna-easy-vanilla-rocket-part-costs"].value == false then
    

    rocket_prod.max_level=nil
    rro.remove(rocket_prod.unit.ingredients,{"cryogenic-science-pack","_any"})
    if mods["Age-of-Production"] then
        rro.remove(rocket_prod.unit.ingredients,{"aop-thermal-science-pack","_any"})
    end
    if mods["Krastorio2-spaced-out"] then
        rro.remove(rocket_prod.unit.ingredients,{"kr-advanced-tech-card","_any"})
    end
    rro.soft_insert(rocket_prod.unit.ingredients,{"space-science-pack",1})
    rro.replace(rocket_prod.prerequisites,"cryogenic-science-pack","space-science-pack")
    rocket_prod.unit.count=250
    rocket_prod.unit.count_formula=nil
    --rocket_prod.localised_name={"technology-name.rocket-part-productivity-muluna"}
    rocket_prod.localised_name={"",{"technology-name.rocket-part-productivity-muluna"}," ",tostring(1)}


    local science_pack = {
        "metallurgic-science-pack",
        "agricultural-science-pack",
        "electromagnetic-science-pack",
    }
    -- local science_pack_aop = {
    --     "aop-thermal-science-pack",
    --     "aop-forestry-science-pack",
    --     "aop-petrochemical-science-pack",
    -- }
    local planet_name = {
        "vulcanus",
        "gleba",
        "fulgora"
    }

    --Rocket productivity technologies
    --Levels 1-2 available on Muluna
    --After Level 2, rocket productivity technology becomes non-linear, 
    --two more levels remain on muluna and the first three vanilla planets
    --After 10 levels, remaining rocket prod comes from Aquilo, as normal.

    for i = 2,4,1 do --Lunar rocket prod 2-4
        local tech = table.deepcopy(rocket_prod)
        tech.name=rocket_prod.name .. "-" .. tostring(i)
        tech.unit.count=i*rocket_prod.unit.count
        tech.localised_name={"",{"technology-name.rocket-part-productivity-muluna"}," ",tostring(i)}
        if i ~=2 then
            tech.prerequisites={rocket_prod.name .. "-" .. tostring(i-1)}
        else 
            tech.prerequisites={rocket_prod.name}
        end
        if i==4 then
            table.insert(rocket_prod_aquilo.prerequisites,tech.name)
        end
        Muluna:extend{tech}
    end

    --local t2_planet_rocket_prod={}

    for i,pack in ipairs(science_pack) do --T1 Planet rocket prod 1-2
        local tech= table.deepcopy(rocket_prod)
        tech.name=rocket_prod.name .. "-".. planet_name[i]
        tech.localised_name={"",{"technology-name.rocket-part-productivity-"..planet_name[i]}," ",tostring(1)}
        rro.replace(tech.prerequisites,"space-science-pack",science_pack[i])
        --table.insert(tech.prerequisites,pack)
        table.insert(tech.unit.ingredients,{science_pack[i],1})
        if mods["Krastorio2-spaced-out"] then
            rro.soft_insert(tech.unit.ingredients,{"kr-advanced-tech-card",1})
        end
        tech.prerequisites={"rocket-part-productivity-4",science_pack[i]}
        tech.unit.count=1000

        local tech_2=table.deepcopy(tech)
        tech_2.name=tech_2.name .. "-2"
        tech_2.unit.count=1500
        rro.soft_insert(tech_2.unit.ingredients,{"interstellar-science-pack",1})
        tech_2.prerequisites={tech.name,"interstellar-science-pack"}
        tech_2.localised_name={"",{"technology-name.rocket-part-productivity-"..planet_name[i]}," ",tostring(2)}
        --table.insert(t2_planet_rocket_prod,tech_2.name)
        table.insert(rocket_prod_aquilo.prerequisites,tech_2.name)
        Muluna:extend{tech,tech_2}
    end

else
    PlanetsLib.set_special_properties("muluna", {rocket_lift_multiplier=2}) 
end

rocket_prod_aquilo.name="rocket-part-productivity-aquilo"

rro.soft_insert(data.raw["recipe"]["cryogenic-plant"].surface_conditions,{property = "is-muluna",min=0,max=0})
    
rocket_prod_aquilo.localised_name={"technology-name.rocket-part-productivity"}
if settings.startup["muluna-easy-vanilla-rocket-part-costs"].value == false then
    rro.soft_insert(rocket_prod_aquilo.unit.ingredients,{"space-science-pack",1})
    rro.soft_insert(rocket_prod_aquilo.unit.ingredients,{"interstellar-science-pack",1})
end
-- for entry in ipairs(t2_planet_rocket_prod) do
--     table.insert(rocket_prod_aquilo.prerequisites,entry)
-- end

Muluna:extend{rocket_prod_aquilo}
if settings.startup["muluna-easy-vanilla-rocket-part-costs"].value == true then
    data.raw["technology"]["rocket-part-productivity"] = nil
end

-- rro.replace(data.raw["cargo-landing-pad"]["cargo-landing-pad"].surface_conditions,
--     {
--         property = "gravity",
--         min = 1,
--     },
--     {
--         property = "gravity",
--         min = 0.1,
--     }
-- )







for k, type in ipairs({"furnace"}) do
    for i,entity in ipairs(data.raw[type]) do
        if entity.surface_conditions then
            for j,property in ipairs(entity.surface_conditions) do
                if property.property == "pressure" and property.min == 10 then
                    property.min = 55
                end
            end 
        end
        
    end
end

local ten_pressure_condition =
{
  {
    property = "oxygen",
    min = 1
  }
}


data.raw["recipe"]["thruster-fuel"].surface_conditions = nil
data.raw["recipe"]["thruster-oxidizer"].surface_conditions = nil
data.raw["recipe"]["advanced-thruster-fuel"].surface_conditions = nil
data.raw["recipe"]["advanced-thruster-oxidizer"].surface_conditions = nil

-- Paranoidal fork: the home flamethrower turret keeps its surface conditions (nothing before the rocket changes).

data.raw["mod-data"]["Planetslib-planet-rocket-part-recipe"].data["muluna"] = nil
data.raw["mod-data"]["Planetslib-planet-rocket-part-recipe"].data["muluna"] = nil

-- data.raw["reactor"]["heating-tower"].surface_conditions = ten_pressure_condition
-- if data.raw["furnace"]["stone-furnace"] then
--     data.raw["furnace"]["stone-furnace"].surface_conditions = ten_pressure_condition
-- elseif data.raw["assembling-machine"]["stone-furnace"] then
--     data.raw["assembling-machine"]["stone-furnace"].surface_conditions = ten_pressure_condition
-- end

-- data.raw["mining-drill"]["burner-mining-drill"].surface_conditions = ten_pressure_condition
-- if data.raw["furnace"]["steel-furnace"] then
--     data.raw["furnace"]["steel-furnace"].surface_conditions = ten_pressure_condition
-- elseif data.raw["assembling-machine"]["steel-furnace"] then
--     data.raw["assembling-machine"]["steel-furnace"].surface_conditions = ten_pressure_condition
-- end

-- data.raw["boiler"]["boiler"].surface_conditions = ten_pressure_condition
-- --data.raw["roboport"]["roboport"].surface_conditions = ten_pressure_condition
-- data.raw["inserter"]["burner-inserter"].surface_conditions = ten_pressure_condition


--data.raw["asteroid-collector"]["asteroid-collector"].surface_conditions = nil
if not mods["crushing-industry"] then
    data.raw["assembling-machine"]["crusher"].surface_conditions = nil
    if data.raw["assembling-machine"]["muluna-crusher-2"] then
        data.raw["assembling-machine"]["muluna-crusher-2"].surface_conditions = nil
    end

else 
    local muluna_restriction = {

        {
            property = "gravity",
            max = 0.1,
        }
    }
    data.raw["assembling-machine"]["crusher"].surface_conditions = muluna_restriction
    if data.raw["assembling-machine"]["muluna-crusher-2"] then
        data.raw["assembling-machine"]["muluna-crusher-2"].surface_conditions = muluna_restriction
    end
end



local function scalar_recipe_multiply(list,factor)
    for _,item in pairs(list) do
        item.amount=item.amount*factor
    end
end
if settings.startup["muluna-easy-vanilla-rocket-part-costs"].value == false then
    local function process_rocket_part(recipe) 
        scalar_recipe_multiply(recipe.ingredients,2)
        recipe.maximum_productivity = 7
    end
    --scalar_recipe_multiply(data.raw.recipe["rocket-part"].ingredients,2)
    -- if data.raw.planet["maraxsis"] then
    --     scalar_recipe_multiply(data.raw.recipe["maraxsis-rocket-part"].ingredients,2)
    --     data.raw["recipe"]["maraxsis-rocket-part"].maximum_productivity = 7
    -- end
    for _,recipe in pairs(data.raw["recipe"]) do
        if recipe.name == "rocket-part" or (recipe.results and recipe.results[1] and recipe.results[1].name == "rocket-part") then
            process_rocket_part(recipe)
        end
    end
end

-- data.raw.recipe["rocket-part"].ingredients =
-- {
--   {type = "item", name = "processing-unit", amount = 2},
--   {type = "item", name = "low-density-structure", amount = 2},
--   {type = "item", name = "rocket-fuel", amount = 2}
-- }
-- if data.raw.planet["maraxsis"] then
--     data.raw.recipe["rocket-part"].ingredients =
--     {
--     {type = "item", name = "processing-unit", amount = 2},
--     {type = "item", name = "low-density-structure", amount = 2},
--     {type = "item", name = "rocket-fuel", amount = 2}
--     }
-- end





-- Paranoidal fork: the home rocket silo keeps its fixed recipe (one Paranoidal rocket everywhere, ПР-078/079) and
-- the space science pack stays made on a space platform (ПР-079 item 6): upstream moved it to Muluna. Only Muluna's
-- interstellar science pack is made on Muluna.
data.raw.recipe["interstellar-science-pack"].surface_conditions = {
    {property = "gravity", min = 2, max = 2},
    {property = "oxygen", min = 0, max = 0},
    PlanetsLib.surface_conditions.restrict_to_surface("muluna")
}

-- rro.replace(data.raw["technology"]["planet-discovery-vulcanus"].prerequisites,"space-science-pack","asteroid-collector")
-- rro.replace(data.raw["technology"]["planet-discovery-gleba"].prerequisites,"space-science-pack","asteroid-collector")
-- rro.replace(data.raw["technology"]["planet-discovery-fulgora"].prerequisites,"space-science-pack","asteroid-collector")




-- Paranoidal fork: the space science recipe keeps the build's amounts (upstream set them from a setting).


for _,pack in pairs(data.raw["item"]) do
    local recipe = data.raw["recipe"][pack.name]
    if recipe then
        if recipe.surface_conditions == nil then
            -- recipe.surface_conditions = {
            --     {property = "oxygen",
            --         min = 1,
            --     },
            -- }
        end
    end
end
local img = Muluna.img
local function copy_icons(to,from)
    to.icon = from.icon
    to.icons = table.deepcopy(from.icons)
    if to.icons then to.icons = img.blur_technology_icon(to.icons,16) end
    to.icon_size = from.icon_size
end

for _,tech in pairs(data.raw["technology"]) do --Adds placeholder icon to technologies without icon
    if tech.icon == nil and tech.icons == nil then
        local effects = tech.effects
        if effects then
            for _,effect in pairs(effects) do
                if effect.type == "unlock-recipe" then
                    local recipe = effect.recipe
                    if data.raw["recipe"][recipe] then
                        if data.raw["recipe"][recipe].icon or data.raw["recipe"][recipe].icons  then
                            copy_icons(tech,data.raw["recipe"][recipe])
                            break
                        elseif recipe.main_product then 
                            if data.raw["item"][recipe.main_product].icon or data.raw["item"][recipe.main_product].icons then
                                copy_icons(tech,data.raw["item"][recipe.main_product])
                                break
                            elseif data.raw["fluid"][recipe.main_product].icon or data.raw["fluid"][recipe.main_product].icons then
                                copy_icons(tech,data.raw["fluid"][recipe.main_product])
                                break 
                                
                            end
                        elseif recipe.results then 
                            local result = recipe.results[1] 
                            if result then
                                copy_icons(tech,data.raw[result.type][recipe.name])
                            end
                            break
                            -- if data.raw["item"][recipe.results[1].name].icon or data.raw["item"][recipe.results[1].name].icons then
                            --     copy_icons(tech,data.raw["item"][recipe.results[1].name])
                            --     break
                            -- elseif data.raw["fluid"][recipe.results[1].name].icon or data.raw["fluid"][recipe.results[1].name].icons then
                            --     copy_icons(tech,data.raw["fluid"][recipe.results[1].name])
                            -- break end
                        end
                        break
                    end
                    break 
                end
            end
        end
        -- if tech.icon == nil and tech.icons == nil then
        --     tech.icon = data.raw["technology"]["space-science-pack"].icon
        -- end
        
    end
end

if not(mods["maraxsis"]) then
    Muluna:extend {{
        type = "item-subgroup",
        name = "maraxsis-atmosphere-barreling",
        order = "ff",
        group = "intermediate-products",
    }}
    
    for recipe, category in pairs {
        ["empty-maraxsis-atmosphere-barrel"] = "chemistry",
        ["maraxsis-atmosphere-barrel"] = "chemistry",
        --["empty-maraxsis-liquid-atmosphere-barrel"] = "cryogenics",
        --["maraxsis-liquid-atmosphere-barrel"] = "cryogenics",
    } do
        local recipe = data.raw.recipe[recipe]
        recipe.hidden_in_factoriopedia = false
        recipe.categories = {category}
        recipe.subgroup = "maraxsis-atmosphere-barreling"
    end
    data.raw.recipe["empty-maraxsis-atmosphere-barrel"].results[1].temperature = 25
    
end

-- local planets = {
--     "arrakis",
--     "tiber",
--     "nauvis",
--     "char",
--     "aiur",
--     "janus",
-- }

-- for _,planet in pairs(planets) do
--     if data.raw["technology"]["planet-discovery-"..planet] then
--         rro.replace(data.raw["technology"]["planet-discovery-"..planet].prerequisites,"space-science-pack","asteroid-collector")
--         rro.replace(data.raw["technology"]["planet-discovery-"..planet].prerequisites,"space-platform-thruster","asteroid-collector")
--     end
    
-- end

-- Paranoidal fork: planet discoveries keep their prerequisites (the asteroid collector is unlocked by the space
-- platform technology of the build, see the end of this file).
    
    


rro.soft_insert(data.raw["technology"]["planet-discovery-aquilo"].prerequisites,"interstellar-science-pack")
--table.insert(data.raw["technology"]["promethium-science-pack"].prerequisites,"interstellar-science-pack")
--data.raw["item"]["space-science-pack"].localised_name = {"item-name."}
--data.raw["technology"]["space-science-pack"].localised_name = {"item-name.lunar-science-pack"}
--data.raw["technology"]["space-science-pack"].localised_description = {"technology-description.lunar-science-pack"}


-- Paranoidal fork: the space science pack keeps the build's icon.



local nauvis = data.raw["planet"]["nauvis"]
if mods["Tiered-Solar-System"] then
    data.raw["planet"]["muluna"].orientation = nauvis.orientation-0.01
    data.raw["planet"]["muluna"].distance = nauvis.distance*0.90
-- else
--     data.raw["planet"]["muluna"].orbit.orientation = nauvis.orientation-0.02
--     data.raw["planet"]["muluna"].orbit.distance = nauvis.distance*1.0
end

-- The Hopping Buccaneers sail the oceans with a swing
-- The Hopping Buccaneers think of just one thing:
-- Whether winter wind or rain,
-- Even if dough’s soon to drain,
-- The Hopping Buccaneers sail on.

-- The Hopping Buccaneers, many stories without par,
-- Such as when we sank six ships from the river Saar
-- So much sharper than the rest,
-- None should hope to strike the best,
-- The Hopping Buccaneers sail on.

-- The Hopping Buccaneers celebrate by night their day
-- A medallion from the captain keeps ghosts at bay
-- We stash memories for life,
-- Laughing over our shared strife,
-- The Hopping Buccaneers sail on.

-- ***

-- I, Hopping Buccaneer know the captain all too well
-- Her comfort from the storms tempts my heart to swell,
-- But I feel a rift has bred,
-- And too much has gone unsaid,
-- I watch as she and crew sail on.

-- I, Hopping Buccaneer feel some fears I can’t flatten
-- For a demon from the depths hides in my cabin
-- He whispers with eyes aglow,
-- Tempting me with what’s below,
-- Alone through this storm I sail on.

-- I, Hopping Buccaneer see our ship has broken sides
-- I watch cracks along the walls where my demon hides
-- I would tell the captain this, 
-- but her bucket’s full as is,
-- I wonder if we will sail on.

-- ***

-- The Hopping Buccaneers see a chance to prove their might
-- A ship of Spanish stock is now in our sight
-- As we craft our battle plans,
-- Sweat condenses on my hands,
-- The Hopping Buccaneers march out.

-- The Hopping Buccaneers hear a pep talk from the coach
-- To remind us where to aim as we make approach
-- She says “Let us shock and stun,
-- as old Manning would have done,”
-- The Hopping Buccaneers raise black.

-- The Hopping Buccaneers sing a shanty to the beat
-- Of the great blue ocean waves, for the foe we meet
-- And a cannon joins the crew,
-- Cracking cavities right through,
-- The Hopping Buccaneers freak out.

-- ***

-- The Hopping Buccaneers see the puddles flood the hull
-- The buckets which we trust are already full
-- We talk trash and hop and shout,
-- as the demon rockets out,
-- The Hopping Buccaneers sink down.

-- I, Hopping Buccaneer on the bottom of the seas
-- No company but sand, I’ll forever freeze
-- A medallion from the past,
-- Brings my mind back, but alas,
-- Down in the depths I must sail on.

--I just want to say that this mod is basically the only part of my life that I'm happy with at the moment. I appreciate every one of you that has thanked me for making this and my other mods. Sometimes it's the only thing that keeps me going. A healthy mind does not devote as much time to a project like this as I have. I used to have a healthy in person social circle, the ability to trust people I haven't met before, general optimism for the future. All I have now is Muluna.

--I'm losing hope that I will ever feel happy, or that I will ever regain the trust I once had in other people. Why do I write this stuff in code comments? Because I feel that the chance of anyone reading this is low, but the chance that these words end up on thousands of people's computers is quite high. Feels less scary.

if data.raw.planet["maraxsis"] and data.raw.recipe["maraxsis-rocket-part"] then -- Paranoidal fork: no own Maraxsis rocket part
    for _,tech in pairs(data.raw["technology"]) do
        if string.find(tech.name,"rocket-part-productivity-",0,true) and tech.name ~= "rocket-part-productivity-aquilo" then
            rro.soft_insert(tech.effects,{
                type = "change-recipe-productivity",
                recipe = "maraxsis-rocket-part",
                change = 0.1,
                --hidden = true
            })
        end
    end 
    
    -- for _,ingredient in pairs(data.raw["recipe"]["maraxsis-rocket-part"].ingredients) do
    --     ingredient.amount = ingredient.amount*2
    -- end
    
end




if data.raw["technology"]["rocket-fuel-productivity"] then
    -- table.insert(data.raw["technology"]["rocket-fuel-productivity"].effects,{
    --     type = "change-recipe-productivity",
    --     recipe = "rocket-fuel-aluminum",
    --     change = 0.1,
    --     hidden = false
    -- })
end


if data.raw["technology"]["asteroid-productivity"] then
    table.insert(data.raw["technology"]["asteroid-productivity"].effects,{
        type = "change-recipe-productivity",
        recipe = "anorthite-crushing",
        change = 0.1,
        hidden = false
    })
    table.insert(data.raw["technology"]["asteroid-productivity"].effects,{
        type = "change-recipe-productivity",
        recipe = "advanced-anorthite-crushing",
        change = 0.1,
        hidden = false
    })
end

for i = 1,10,1 do --For compatibility with Roc's hardcore tech tree.
    if data.raw["technology"]["asteroid-productivity-"..tostring(i)] then
        table.insert(data.raw["technology"]["asteroid-productivity-"..tostring(i)].effects,{
            type = "change-recipe-productivity",
            recipe = "anorthite-crushing",
            change = 0.1,
            hidden = false
        })
        table.insert(data.raw["technology"]["asteroid-productivity-"..tostring(i)].effects,{
            type = "change-recipe-productivity",
            recipe = "advanced-anorthite-crushing",
            change = 0.1,
            hidden = false
        })
    end
    if data.raw["technology"]["rocket-fuel-productivity-"..tostring(i)] then
        table.insert(data.raw["technology"]["rocket-fuel-productivity-"..tostring(i)].effects,{
            type = "change-recipe-productivity",
            recipe = "rocket-fuel-aluminum",
            change = 0.1,
            hidden = false
        })   
    end
end

if data.raw["technology"]["space-platform"].effects then
    rro.soft_insert(data.raw["technology"]["space-platform"].effects,{
        type = "unlock-recipe",
        recipe = "cargo-bay"
    })
else
    data.raw["technology"]["space-platform"].effects = {{
        type = "unlock-recipe",
        recipe = "cargo-bay"
    }}
end

require("compat.orbital-ion-cannon")
require("compat.lignumis")


-- local one_gravity_condition =
-- {
--   {
--     property = "gravity",
--     min = 0.1
--   }
-- }

if not (settings.startup["muluna-easy-revert-changes-to-space-platform-technology"].value == true) then
    rro.remove(data.raw["technology"]["space-platform-thruster"].effects,
        {
            type = "unlock-recipe",
            recipe = "thruster-oxidizer",
        }
    )
    rro.remove(data.raw["technology"]["space-platform-thruster"].effects,
        {
            type = "unlock-recipe",
            recipe = "thruster-fuel",
        }
    )
end

--data.raw["spider-vehicle"]["spidertron"].surface_conditions = one_gravity_condition


require("prototypes.mod-data.interstellar-science-pack")

if data.raw["item"]["alien-science-pack"] then
    data.raw["item"]["alien-science-pack"].order="fa[alien-science-pack]"
end

if data.raw["item"]["electrochemical-science-pack"] then
    data.raw["item"]["electrochemical-science-pack"].order="iz[electrochemical-science-pack]"
end

-- Paranoidal fork: the Nauvis description stays as in the build (visible before the rocket).

require("prototypes.entity.cryolab")

for _,lab in pairs(data.raw["lab"]) do
    if lab.name ~= "cerys-lab" then
        rro.soft_insert(lab.inputs,"interstellar-science-pack")
    end
end

local gases = {"oxygen","hydrogen","carbon-dioxide","maraxsis-atmosphere"}


    

local function multiply_ingredients(recipe,ingredient,multiplier)
    if recipe.ingredients then
        for _,item in pairs(recipe.ingredients) do
            if item.name == ingredient and item.amount then
                item.amount = item.amount*multiplier
            end
        end
    end
    if recipe.results then
        for _,item in pairs(recipe.results) do
            if item.name == ingredient and item.amount then
                item.amount = item.amount*multiplier
            end
        end
    end
    

end

-- local recipes_to_change = {
--     "maraxsis-liquid-atmosphere",
--     "maraxsis-liquid-atmosphere-decompression",
-- }

local recipe_blacklist = {
    -- "helium-separation",
    -- "kovarex-helium-enrichment"
    "molten-aluminum",
    "atmosphere-oxygen-separation",
    "maraxsis-atmosphere",
    "interstellar-science-pack",
    "cryolab",
}

local category_blacklist = {
    "double-boiler",
    "muluna-greenhouse",
    "muluna-vacuum-heating-tower",
}

local subgroup_blacklist = {
    "muluna-products"
}

if false and not mods["Krastorio2-spaced-out"] then
    --Modifies values of gas fluids in Maraxsis entities to follow Factorio 2.0's convention of gas fluid units having 1/10 the matter of liquid fluid units(As in water vs. steam)
    if data.raw.planet["maraxsis"] then
        data.raw["fluid"]["hydrogen"].fuel_value="225kJ"
        
    end
    if data.raw.planet["maraxsis"] then
        for _,quality in pairs(data.raw["quality"]) do
            if quality.hidden then goto continue end
            local regulator = data.raw["assembling-machine"]["maraxsis-regulator-fluidbox-" .. quality.name]
            regulator.energy_source.fluid_box.volume = regulator.energy_source.fluid_box.volume*10
            ::continue::
        end
    end
    for _,gas in pairs(gases) do
        for _,recipe in pairs(data.raw["recipe"]) do --pairs(recipes_to_change) do
            if not (rro.contains(recipe_blacklist,recipe.name) or rro.contains_any(category_blacklist,recipe.categories) or rro.contains(subgroup_blacklist,recipe.subgroup)) then
                multiply_ingredients(recipe,gas,10)
            end
            
        end
        
    end
else
    for _,gas in pairs(gases) do
        for _,recipe in pairs(data.raw["recipe"]) do --pairs(recipes_to_change) do
            if not (not (rro.contains(recipe_blacklist,recipe.name) or rro.contains_any(category_blacklist,recipe.categories) or rro.contains(subgroup_blacklist,recipe.subgroup))) then
                multiply_ingredients(recipe,gas,0.10)
            end
            
        end
        
    end
end



require("compat.modules-t4")
require("compat.corrundum")
require("compat.maraxsis")
require("compat.tenebris")
require("compat.space-age-galore")
require("compat.space-trains")
require("compat.schall-mods")
require("compat.bob-mods")
require("compat.transplutonic")
require("prototypes.technology.technology-updates")
require("prototypes.entity.data-assembler") -- Paranoidal fork: own machine with the data ports
require("prototypes.overrides.data-cells")
require("prototypes.overrides.gleba-greenhouse-recipes")
require("prototypes.overrides.telescope-data")
require("compat.Age-of-Production")

local parent_planet = "nauvis"
if mods["any-planet-start"] then 
    local parent_planet = settings.startup["aps-planet"].value
end

PlanetsLib:update
    {
        type = "planet",
        name = "muluna",
        asteroid_spawn_definitions = data.raw["planet"][parent_planet].asteroid_spawn_definitions,
        
    }





require("prototypes.technology.interstellar-technologies")


-- Paranoidal fork: no second space science recipe on Muluna and no change of the platform recipe (ПР-079 item 6).

if mods["Krastorio2-spaced-out"] then
    local space_science_pack_advanced = table.deepcopy(data.raw["recipe"]["kr-space-research-data"])

    space_science_pack_advanced.surface_conditions = {
        {
            property = "gravity",
            min = 0,
            max = 0,
        },
        -- {
        --     property = "oxygen",
        --     min = 0,
        --     max = 0,
        -- },
    }
    space_science_pack_advanced.name = "kr-space-research-data-advanced"
    --space_science_pack_advanced.icons = dual_icon("space-science-pack","asteroid-collector")
    Muluna:extend{space_science_pack_advanced}
    rro.soft_insert(data.raw["technology"]["advanced-space-science-pack"].effects ,  {
        type = "unlock-recipe",
        recipe = space_science_pack_advanced.name
    })
    
end



--data.raw["recipe"]["interstellar-science-pack-helium-4"].icons = dual_icon("interstellar-science-pack","asteroid-collector")

-- data.raw["recipe"]["wood-greenhouse"].enabled = false

if settings.startup["muluna-easy-vanilla-advanced-thruster-fuel-costs"].value == false then
    data.raw["recipe"]["advanced-thruster-fuel"].results[1].amount = 1000
    data.raw["recipe"]["advanced-thruster-oxidizer"].results[1].amount = 1000
end

data.raw["recipe"]["tree-seed"].surface_conditions = nil
data.raw["recipe"]["tree-seed"].categories = {"crafting"}

require("compat.orbital-transfer")
require("compat.visible-planets")
require("compat.dyson-sphere")
require("compat.bzsilicon")
require("compat.Krastorio2-spaced-out")
require("prototypes.planet.planet-asteroids")

if mods["cupric-asteroids"] then
    local cupric_crushing = table.deepcopy(data.raw["technology"]["metallic-asteroid-crushing"])
    cupric_crushing.name = "cupric-asteroid-crushing"
    cupric_crushing.effects[1].recipe = "cupric-asteroid-crushing"
    cupric_crushing.localised_name = {"recipe-name.cupric-asteroid-crushing"}
    cupric_crushing.research_trigger = {
            type = "mine-entity",
            entity = "cupric-asteroid-chunk"
        }
    cupric_crushing.icons[2].icon = data.raw["item"]["cupric-asteroid-chunk"].icon
    cupric_crushing.icons[2].icon_size = data.raw["item"]["cupric-asteroid-chunk"].icon_size
    Muluna:extend{cupric_crushing}
    rro.remove(data.raw["technology"]["space-platform"].effects,{type = "unlock-recipe",recipe = "cupric-asteroid-crushing"})
end

if settings.startup["muluna-easy-simple-wood-gasification"]["value"] == true then
    local recipe_names = {
        "cellulose",
        "wood-gasification",
        "advanced-wood-gasification",

    }
    for _,recipe_name in pairs(recipe_names) do
        local recipe = data.raw["recipe"][recipe_name]
        for _,result in pairs(recipe.results) do
            if rro.deep_equals({type = "_any",name = function(name) return not rro.contains({"carbon-dioxide","oxygen"},name) end, amount = "_any"},result) then
                result.amount = result.amount * 2
            end
        end
        recipe.allow_productivity = false
    end
end

if settings.startup["muluna-hardcore-remove-space-casino"] and settings.startup["muluna-hardcore-remove-space-casino"].value == true then
    for _,recipe in pairs(data.raw["recipe"]) do
        if string.find(recipe.name,"asteroid%-reprocessing") then
            recipe.allow_quality = false
        end
    end
end
local propellant_barrel = data.raw["item"]["muluna-roboport-propellant-barrel"]
propellant_barrel.fuel_value = Muluna.multiply_energy(data.raw["fluid"]["muluna-roboport-propellant"].fuel_value, 50)
propellant_barrel.fuel_categories = {"muluna-oxygenated-fuel"}
propellant_barrel.burnt_result = "barrel" --No automatic way to remove barrels, so I will disable this for now
--data.raw["recipe"]["muluna-roboport-propellant-barrel"].hide_from_player_crafting = false




--Remove asteroids from ignored_by_stats while preserving ignored_by_productivity behavior
local asteroid_chunks = {
    "metallic-asteroid-chunk",
    "carbonic-asteroid-chunk",
    "oxide-asteroid-chunk",
}

local function check_productingredient(productingredient) --Invented a new word for this funciton :)
    if rro.contains(asteroid_chunks,productingredient.name) and productingredient.ignored_by_stats then
        if productingredient.ignored_by_productivity == nil then
            productingredient.ignored_by_productivity = productingredient.ignored_by_stats
        end
        productingredient.ignored_by_stats = nil
        
        
    end

end

for _,recipe in pairs(data.raw.recipe) do
    if rro.contains(recipe.categories,"crushing") then
        for _,result in pairs(recipe.results) do
            check_productingredient(result)
        end
        for _,ingredient in pairs(recipe.ingredients) do
            check_productingredient(ingredient)
        end
    end
end

local pressure_adjusted_entity_types = {
    "generator"
}
for _,type in pairs(pressure_adjusted_entity_types) do
    for _,prototype in pairs(data.raw[type]) do
        if rro.contains(prototype.surface_conditions,{property="pressure",min = 10}) then
            PlanetsLib.relax_surface_conditions(prototype,{property="pressure",min = 3})
        end
    end
end

-- Paranoidal fork: the build keeps the platform set of Space Age: the space platform technology unlocks the asteroid
-- collector, the crusher and the asteroid crushing recipes, the space platform thruster technology the thruster fuel
-- and oxidizer (setting muluna-easy-revert-changes-to-space-platform-technology). These Muluna technologies only
-- repeated those unlocks: they are removed, and technologies that needed one of them need its predecessor instead.
local paranoidal_repeated_technologies = {
    ["asteroid-collector"] = "space-platform",
    ["crusher"] = "space-platform",
    ["thruster-oxidizer"] = "space-platform-thruster",
    ["metallic-asteroid-crushing"] = "planet-discovery-muluna",
    ["oxide-asteroid-crushing"] = "planet-discovery-muluna",
    ["carbonic-asteroid-crushing"] = "planet-discovery-muluna",
}
for name, predecessor in pairs(paranoidal_repeated_technologies) do
    if data.raw["technology"][name] and data.raw["technology"][predecessor] then
        data.raw["technology"][name] = nil
        for _, technology in pairs(data.raw["technology"]) do
            if technology.prerequisites and rro.contains(technology.prerequisites, name) then
                rro.remove(technology.prerequisites, name)
                if technology.name ~= predecessor then
                    rro.soft_insert(technology.prerequisites, predecessor)
                end
            end
        end
    end
end
