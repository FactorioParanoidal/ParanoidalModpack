local DLL = require("prototypes.globals")

local function config_refresh(event)
    if event.mod_changes["DeadlockLargerLamp"] then
        for _, force in pairs(game.forces) do
            local technology = game.technology_prototypes["lamp"]
            local recipe = game.recipe_prototypes[DLL.name]
            local floor_recipe = game.recipe_prototypes[DLL.floor_name]
            local electric_copper_recipe = game.recipe_prototypes[DLL.electric_copper_name]

            -- Ensure technology and recipes are valid
            if technology and recipe and floor_recipe then
                -- Check if the technology is enabled
                if technology.enabled then
                    -- Enable the recipes if technology is researched and visible
                    if force.technologies["lamp"].researched then
                        force.recipes[DLL.name].enabled = true
                        force.recipes[DLL.floor_name].enabled = true
                        log("Enabled recipes for " .. DLL.name .. " and " .. DLL.floor_name)
                    else
                        force.recipes[DLL.name].enabled = false
                        force.recipes[DLL.floor_name].enabled = false
                        log("Disabled recipes for " .. DLL.name .. " and " .. DLL.floor_name)
                    end
                else
                    log("Technology 'lamp' is disabled")
                end

                -- Check if prerequisites are researched before enabling recipes
                if technology.prerequisites then
                    local prerequisites_researched = true
                    for _, prereq in pairs(technology.prerequisites) do
                        if not force.technologies[prereq.name].researched then
                            prerequisites_researched = false
                            break
                        end
                    end
                    -- Enable recipes only if all prerequisites are researched
                    if prerequisites_researched then
                        force.recipes[DLL.name].enabled = true
                        force.recipes[DLL.floor_name].enabled = true
                        log("Enabled recipes after researching prerequisites")
                    else
                        force.recipes[DLL.name].enabled = false
                        force.recipes[DLL.floor_name].enabled = false
                        log("Prerequisites not yet researched")
                    end
                end
            end

            -- Enable Electric Copper Lamp Recipe when technology is researched
            if electric_copper_recipe then
                -- Check if the technology has been researched and if it is allowed
                if force.technologies["lamp"].researched then
                    force.recipes[DLL.electric_copper_name].enabled = true
                    log("Enabled recipe for " .. DLL.electric_copper_name)
                else
                    force.recipes[DLL.electric_copper_name].enabled = false
                    log("Disabled recipe for " .. DLL.electric_copper_name)
                end
            end
        end
    end
end

script.on_configuration_changed(config_refresh)