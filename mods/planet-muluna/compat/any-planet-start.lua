local rro = Muluna.rro
local dual_icon = require("lib.dual-item-icon").dual_icon
local function technology_icon_constant_recipe_productivity(technology_icon,new_icon_size)
    local icon_size = new_icon_size or 256
    local icons =
    {
      {
        icon = technology_icon,
        icon_size = icon_size
      },
      {
        icon = "__core__/graphics/icons/technology/constants/constant-recipe-productivity.png",
        icon_size = 128,
        scale = 0.5,
        shift = {50, 50},
        floating = true
      }
    }
    return icons
  end

local function delete_tech(deleted_tech,new_tech)
    for _,effect in pairs(data.raw["technology"][deleted_tech].effects) do
        if effect.type == "unlock-recipe" then
            if new_tech then
                rro.soft_insert(data.raw["technology"][new_tech].effects, 
                {
                    type = "unlock-recipe",
                    recipe = data.raw["recipe"][effect.recipe].name,
                }
            )
            else
                data.raw["recipe"][effect.recipe].enabled = true
            end
        end
    end
    data.raw["technology"][deleted_tech] = nil
    
    for _,technology in pairs(data.raw["technology"]) do
        rro.replace(technology.prerequisites,deleted_tech,new_tech)
    end
end


if settings.startup["aps-planet"] and settings.startup["aps-planet"].value == "muluna" then
    for control_name,control in pairs(data.raw["autoplace-control"]) do
        if not rro.contains(table.keys(data.raw["planet"]["muluna"].map_gen_settings.autoplace_controls),control_name) then
            if not control.order then control.order = "" end
            control.order = "ab" .. control.order
        end
    end
    -- for control_name,settings in pairs(data.raw["planet"]["nauvis"].map_gen_settings.autoplace_controls) do
    --     local control = data.raw["autoplace-control"][control_name]
        
    -- end

    -- if mods["aai-industry"] then
    --     error("\n\nAAI Industry is incompatible with Muluna start.\n")
    -- end
    --assert(settings.startup["muluna-hardcore-remove-starting-cargo-pods"].value == false,{"console.muluna-incompatible-aps-setting"})
    if data.raw["technology"]["electronics"].research_trigger then
        data.raw["technology"]["electronics"].research_trigger.item="aluminum-plate"
    end

    local red_science = table.deepcopy(data.raw["recipe"]["automation-science-pack"])
    rro.replace_name(red_science.ingredients,"copper-plate","aluminum-plate")
    red_science.name="automation-science-pack-muluna"
    red_science.icons=dual_icon("automation-science-pack","aluminum-plate")
    Muluna:extend{red_science}
    
    rro.soft_insert(data.raw["technology"]["automation-science-pack"].effects,
    {
        type = "unlock-recipe",
        recipe = "automation-science-pack-muluna",
    })
    if mods["aai-industry"] then
        local burner_lab = table.deepcopy(data.raw["recipe"]["burner-lab"])
        burner_lab.name = "burner-lab-muluna"
        rro.deep_replace(burner_lab,"copper-plate","aluminum-plate")
        burner_lab.localised_name = {"recipe-name.x-from-aluminum",{"item-name.burner-lab"}}
        burner_lab.icons=dual_icon("burner-lab","aluminum-plate")
        Muluna:extend{burner_lab}
        rro.soft_insert(data.raw["technology"]["electric-lab"].effects,
        {
            type = "unlock-recipe",
            recipe = burner_lab.name,
        })
    end

    --rro.replace_name(data.raw["recipe"]["electric-furnace"].ingredients,"advanced-circuit","electronic-circuit")
    --data.raw["recipe"]["electric-furnace"].enabled = true
    --data.raw["recipe"]["electric-mining-drill"].enabled = true
    --data.raw["recipe"]["steel"].enabled = true
    
    rro.remove(data.raw["technology"]["wood-gas-processing-to-crude-oil"].unit.ingredients,{"production-science-pack","_any"})
    rro.remove(data.raw["technology"]["wood-gas-processing-to-crude-oil"].unit.ingredients,{"chemical-science-pack","_any"})
    rro.remove(data.raw["technology"]["wood-gas-processing-to-crude-oil"].prerequisites,"production-science-pack","chemical-science-pack")
    --rro.remove(data.raw["technology"]["wood-gas-processing-to-crude-oil"].prerequisites,"chemical-science-pack","logistic-science-pack")
    --rro.soft_insert(data.raw["technology"]["steam-power"].prerequisites,"metallic-asteroid-crushing")
    table.insert(data.raw["technology"]["muluna-greenhouses"].prerequisites,"lamp")
    if data.raw["technology"]["steam-power"].prerequisites == nil then
        data.raw["technology"]["steam-power"].prerequisites = {"metallic-asteroid-crushing"}
    end
    
    table.insert(data.raw["technology"]["muluna-advanced-boiler"].prerequisites, "steam-power")
    
    if data.raw["technology"]["steel-axe"].prerequisites == nil or #data.raw["technology"]["steel-axe"].prerequisites == 0 then
        data.raw["technology"]["steel-axe"].prerequisites = {"metallic-asteroid-crushing"}
    end
    
    if data.raw["technology"]["electronics"].prerequisites == nil then
        data.raw["technology"]["electronics"].prerequisites = {"muluna-aluminum-processing"}
    end
    

    --rro.replace(data.raw["technology"]["advanced-oil-processing"].unit.ingredients,{"chemical-science-pack",1},{"space-science-pack",1})
    --data.raw["technology"]["advanced-oil-processing"].unit.count = 500
    --rro.replace(data.raw["technology"]["rocket-fuel"].unit.ingredients,{"chemical-science-pack",1},{"space-science-pack",1})
    rro.remove(data.raw["technology"]["rocket-silo"].prerequisites,"logistic-robotics")
    rro.remove(data.raw["technology"]["rocket-silo"].prerequisites,"cargo-planes")
    rro.remove(data.raw["technology"]["space-platform-thruster"].prerequisites,"afterburner")
    data.raw["technology"]["rocket-silo"].research_trigger.item =  "rocket-fuel"
    delete_tech("advanced-wood-gas-processing","advanced-oil-processing")
    delete_tech("muluna-burner-roboport","robotics")
    table.insert(data.raw["technology"]["automobilism"].effects, {
        type = "unlock-recipe",
        recipe = "muluna-roboport-propellant",
    })
    data.raw["research-achievement"]["eco-unfriendly"] = nil
    rro.remove(data.raw["technology"]["wood-gas-processing"].prerequisites,"oil-processing")
    
    --delete_tech("processing-unit","electronics")
    -- data.raw["recipe"]["advanced-circuit"].enabled = false
    -- rro.soft_insert(data.raw["technology"]["electronics"].effects,
    -- {
    --     type = "unlock-recipe",
    --     recipe = "advanced-circuit",
    -- })
    rro.soft_insert(data.raw["technology"]["oxide-asteroid-crushing"].effects,
    {
        type = "unlock-recipe",
        recipe = "chemical-plant",
    })
    rro.soft_insert(data.raw["technology"]["muluna-oxygen"].effects,
    {
        type = "unlock-recipe",
        recipe = "thruster-oxidizer",
    })
    -- rro.remove(data.raw["technology"]["muluna-silicon-processing"].unit.ingredients,{"production-science-pack",  1})
    -- rro.remove(data.raw["technology"]["muluna-silicon-processing"].unit.ingredients,{"chemical-science-pack",  1})
    rro.soft_insert(data.raw["technology"]["solar-energy"].prerequisites,"muluna-anorthite-processing")
    -- rro.remove(data.raw["technology"]["muluna-silicon-processing"].prerequisites,"production-science-pack")

    

    
    for _,tech in pairs(data.raw["technology"]) do
        if tech.unit then 
           if rro.contains(tech.unit.ingredients ,{"logistic-science-pack" , 1}) then
            rro.soft_insert(tech.prerequisites,"logistic-science-pack")
           end
        end
            
    end
    if mods["Krastorio2-spaced-out"] then
        delete_tech("kr-advanced-chemistry","muluna-oxygen")
        --Gas venting is removed when Krastorio 2 is loaded, so only gate the flare
        --stack behind it if it still exists.
        if data.raw["technology"]["muluna-gas-venting"] then
            data.raw["technology"]["kr-fluid-excess-handling"].prerequisites = {"muluna-gas-venting"}
        else
            data.raw["technology"]["kr-fluid-excess-handling"].prerequisites = nil
        end
        data.raw["technology"]["kr-fluid-excess-handling"].research_trigger = {type = "craft-item",item="iron-plate"}
        data.raw["technology"]["kr-fluid-excess-handling"].unit = nil
    end
end