local rro = Muluna.rro
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
        if new_tech then
            rro.replace(technology.prerequisites,deleted_tech,new_tech)
        else
            rro.remove(technology.prerequisites,deleted_tech)
        end
        
    end
end

for _,tech in pairs(data.raw["technology"]) do
        if tech.unit and rro.contains(tech.unit.ingredients,{"automation-science-pack","_any"}) then
            rro.soft_insert(tech.prerequisites,"automation-science-pack")
        end
    end

delete_tech("electric-mining-drill","metallic-asteroid-crushing")
delete_tech("advanced-material-processing","muluna-advanced-boiler")
delete_tech("advanced-material-processing-2",mods["aai-industry"] and "concrete" or "muluna-advanced-boiler")
delete_tech("steel-processing","metallic-asteroid-crushing")
delete_tech("advanced-circuit","electronics")
delete_tech("oil-processing","oil-gathering")
delete_tech("fluid-handling","oxide-asteroid-crushing")
delete_tech("thruster-fuel","space-platform-thruster")
delete_tech("thruster-oxidizer","space-platform-thruster")
delete_tech("landfill","muluna-greenhouses")
delete_tech("muluna-silicon-processing","solar-energy")
delete_tech("electric-energy-distribution-1","oxide-asteroid-crushing")
delete_tech("sulfur-processing","wood-gas-processing")
delete_tech("engine","steam-power") 
rro.soft_insert(data.raw["technology"]["steel-axe"].prerequisites,"metallic-asteroid-crushing")

if mods["aai-industry"] then
    local sand = data.raw["technology"]["sand-processing"]
    local glass = data.raw["technology"]["glass-processing"]
    local electric_lab = data.raw["technology"]["electric-lab"]
    local automation_pack = data.raw["technology"]["automation-science-pack"]
    Muluna:extend{rro.merge(sand,
        {
            prerequisites = "_nil",
            research_trigger = {type = "mine-entity", entity = "lunar-rock"},
            unit = "_nil",
        }
    ),
        rro.merge(glass,
            {
                prerequisites = {sand.name},
                research_trigger = {type = "craft-item", item = "sand"},
                unit = "_nil",
            }
        ),
        rro.merge(electric_lab,
            {
                prerequisites = {glass.name,"muluna-advanced-boiler"},
                research_trigger = {type = "craft-item", item = "glass"},
                unit = "_nil",
            }
        ),
        rro.merge(automation_pack,
            {
                prerequisites = {electric_lab.name},
                research_trigger = {type = "build-entity", entity = "lab"},
                unit = "_nil",
            }
        )
    }
    rro.soft_insert(data.raw["technology"]["oxide-asteroid-crushing"].prerequisites,"sand-processing")
    delete_tech("burner-mechanics","metallic-asteroid-crushing")
    delete_tech("basic-fluid-handling","oxide-asteroid-crushing")
    delete_tech("steam-power","muluna-advanced-boiler")
    delete_tech("electronics","muluna-aluminum-processing")
    rro.deep_replace(data.raw["shortcut"]["give-copper-wire"],"electronics","muluna-aluminum-processing")
    rro.soft_insert(data.raw["technology"]["automation-science-pack"].prerequisites,"electric-lab")
    
    delete_tech("automation","electricity")
    data.raw["tips-and-tricks-item"]["long-handed-inserters"] = nil --Causes crash when automation tech is remove. No one will miss it.
    delete_tech("electricity","muluna-advanced-boiler")
end