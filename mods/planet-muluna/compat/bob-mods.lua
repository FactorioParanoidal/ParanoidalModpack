local rro = Muluna.rro
local advanced_boiler_tiers = 5

if false and mods["bobpower"] then
    local function temperature(tier)
        return 15 + 150*tier
    end
    local function multiplier(tier) return 1+tier/2 end
    local function power_consumption(tier)
        return tostring(3.6*multiplier(tier)) .. "MW"
    end
    local advanced_boiler ={
        entity = table.deepcopy(data.raw["assembling-machine"]["muluna-advanced-boiler"]),
        item = table.deepcopy(data.raw["item"]["muluna-advanced-boiler"]),
        tech = table.deepcopy(data.raw["technology"]["muluna-advanced-boiler"]),
        recipe = table.deepcopy(data.raw["recipe"]["muluna-advanced-boiler"]),
    }
    local function science_packs(tier)
        local science_packs = {
            "automation-science-pack",
            "logistic-science-pack",
            "chemical-science-pack",
        }
        local science_packs_to_add = {
            "space-science-pack",
            "production-science-pack",
            "utility-science-pack",
            "metallurgic-science-pack"
        }
        for i = 1,tier-1 do
            table.insert(science_packs,science_packs_to_add[i])
        end
        local science_packs_formatted = {}
        for _,pack in pairs(science_packs) do
            table.insert(science_packs_formatted,{pack,1})
        end
        return science_packs_formatted

    end
    
    
    for tier = 2,advanced_boiler_tiers do
        local new_advanced_boiler = table.deepcopy(advanced_boiler)
        local old_name = "muluna-advanced-boiler"
        local previous_name = "muluna-advanced-boiler-" .. tier-1
        if tier == 2 then
            previous_name = "muluna-advanced-boiler"
        end
        local new_name = "muluna-advanced-boiler-" .. tier
        for key,object in pairs(new_advanced_boiler) do
            assert(object ~= nil,object)
            object.name = new_name
            object.localised_name = {"",{"entity-name.muluna-advanced-boiler"}," ", tostring(tier)}
        end
         --{"",new_advanced_boiler.entity.localised_name, " " , tier}
        new_advanced_boiler.tech.effects = {{type = "unlock-recipe", recipe = new_name}}
        new_advanced_boiler.entity.energy_consumption = power_consumption(tier)
        new_advanced_boiler.entity.crafting_speed = advanced_boiler.entity.crafting_speed*multiplier(tier)

        rro.replace_name(new_advanced_boiler.recipe.results,old_name,new_name)
        rro.replace_name(new_advanced_boiler.recipe.ingredients,"boiler",previous_name)
        rro.soft_insert(new_advanced_boiler.tech.prerequisites,previous_name)
        new_advanced_boiler.tech.research_trigger = nil
        new_advanced_boiler.tech.unit = {
            count = 100,
            time = 30,
            ingredients = science_packs(tier)
        }

        for key,object in pairs(new_advanced_boiler) do
            Muluna:extend{object}
        end
    end
end