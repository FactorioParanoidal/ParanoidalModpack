local assembler_pictures = require("__base__.prototypes.entity.assembler-pictures")
local assembler2pipepictures = assembler_pictures.assembler3pipepictures

if true then
    for _,name in pairs({"steel-furnace","stone-furnace","crusher"}) do

    local original  = data.raw["furnace"][name]
    if not original  
        then original = data.raw["assembling-machine"][name] 
    --elseif settings.startup["muluna-hardcore-remove-steam-furnaces"].value == false then
    --    break 
    end
    if original.type == "assembling-machine" or settings.startup["muluna-hardcore-remove-steam-furnaces"].value == false then
        

        local steam_furnace = table.deepcopy(original)
        steam_furnace = Muluna.rro.util_merge{steam_furnace ,
            {
                name = "muluna-steam-".. name,
            }




        }

        steam_furnace.minable.result = "muluna-steam-".. name
        steam_furnace.surface_conditions = nil
        -- Muluna:extend{
        --     type = "fuel-category",
        --     name = "steam",

        -- }
        local old_smoke = steam_furnace.energy_source.smoke and steam_furnace.energy_source.smoke[1] or {}
        local smoke_position
        if name == "stone-furnace" then
            smoke_position = {0.05, -0.9}
        elseif name == "steel-furnace" then
            smoke_position = {0.7, -1.0}
        elseif name == "crusher" then

        end
        local new_smoke = {
            {
                    name = "light-smoke",
                    north_position = smoke_position,
                    south_position = smoke_position,
                    east_position = smoke_position,
                    west_position = smoke_position,
                    --east_position = old_smoke.east_position or {-2.0, -2.0},
                    frequency = old_smoke.frequency or 20,
                    starting_vertical_speed = 0.08,
                    starting_frame_deviation = 60
            }
        }

        steam_furnace.energy_source = {
            type = 'fluid',
            --fuel_categories = { fluid_name },
            maximum_temperature = 500,
            --burns_fluid = burns,
            scale_fluid_usage = true,
            effectivity = 0.35,
            fluid_box = {
                production_type = "input",
                filter = "steam",
                volume = 50,
                base_area = 1,
                height = 2,
                base_level = -1,
                pipe_connections = {
                    { flow_direction = "input-output", direction = defines.direction.east, position = {0.59, -0.5}},
                    { flow_direction = "input-output", direction = defines.direction.west, position = {-0.59, -0.5}}
                },
                pipe_picture = assembler2pipepictures,
                pipe_covers = pipecoverspictures(),
            },
            smoke = new_smoke
        }
        if name == "crusher" then
            steam_furnace.energy_source.effectivity = 0.50
            steam_furnace.energy_source.fluid_box.pipe_connections = {
                { flow_direction = "input-output", direction = defines.direction.north, position = {0.59, -1}},
                { flow_direction = "input-output", direction = defines.direction.south, position = {0.59, 1}}
            }
            steam_furnace.next_upgrade = "crusher"
            steam_furnace.module_slots = 0
            local new_smoke_position = {0, 0}
            local new_smoke_position_left = {-0.5, 0}
            local new_smoke_position_right = {0.5, 0}
            local new_smoke_position_up = {0, -0.5}
            local new_smoke_position_down = {0, 0.5}
            steam_furnace.energy_source.smoke = {
                {
                    name = "light-smoke",
                    north_position = new_smoke_position,
                    south_position = new_smoke_position,
                    east_position = new_smoke_position,
                    west_position = new_smoke_position,
                    frequency = old_smoke.frequency or 6,
                    starting_vertical_speed = 0.08,
                    starting_frame_deviation = 60
                },
                {
                    name = "light-smoke",
                    north_position = new_smoke_position_left,
                    south_position = new_smoke_position_left,
                    east_position = new_smoke_position_up,
                    west_position = new_smoke_position_up,
                    --east_position = old_smoke.east_position or {-2.0, -2.0},
                    frequency = old_smoke.frequency or 6,
                    starting_vertical_speed = 0.08,
                    starting_frame_deviation = 60
                },
                {
                    name = "light-smoke",
                    north_position = new_smoke_position_right,
                    south_position = new_smoke_position_right,
                    east_position = new_smoke_position_down,
                    west_position = new_smoke_position_down,
                    --east_position = old_smoke.east_position or {-2.0, -2.0},
                    frequency = old_smoke.frequency or 6,
                    starting_vertical_speed = 0.08,
                    starting_frame_deviation = 60
                },
                -- {
                --     name = "light-smoke",
                --     north_position = old_smoke.north_position or {0.9, 0.5},
                --     --east_position = old_smoke.east_position or {-2.0, -2.0},
                --     frequency = old_smoke.frequency or 10,
                --     starting_vertical_speed = 0.08,
                --     starting_frame_deviation = 60
                -- }
            }
            
            --steam_furnace.energy_source.fluid_box.pipe_picture = images.pipe_picture
            --steam_furnace.energy_source.fluid_box.pipe_covers = images.pipe_covers
        end

        local recipe = table.deepcopy(data.raw["recipe"][name])
        recipe.name = "muluna-steam-".. name
        recipe.ingredients = {
            {type = "item", name = name, amount = 1},
            {type = "item", name = "pipe", amount = 4},
        }
        if name == "crusher" then
            recipe.ingredients = {
                {type = "item", name = "steel-plate", amount = 10},
                {type = "item", name = "pipe", amount = 6},
                {type = "item", name = "engine-unit", amount = 10}
            }
        end
        recipe.results = {{type = "item", name = "muluna-steam-".. name, amount = 1}}
        -- if name == "stone-furnace" then recipe.enabled = true


        -- elseif name == "steel-furnace" then
        --     table.insert(data.raw["technology"]["advanced-material-processing"].effects,
        --     {
        --         type = "unlock-recipe",
        --         recipe = "muluna-steam-".. name
        --     }
        -- )
        -- elseif name == "crusher" then 
            
        -- end



        local item = table.deepcopy(data.raw["item"][name])
        local steam_icon = {
            icon = data.raw["fluid"]["steam"].icon,
            icon_size = data.raw["fluid"]["steam"].icon_size or 64, -- Paranoidal: explicit, the build fills a missing layer size from the prototype
            scale = 0.25,
            shift = {10,-10},
            draw_background = true,
        }
        if item.icons then
            table.insert(item.icons,steam_icon)
        else
            item.icons = {
                {
                    icons = data.raw["item"][name].icons,
                    icon = data.raw["item"][name].icon,
                    icon_size = 64,
                },
                steam_icon
            }
        end
        steam_furnace.icons = item.icons
        recipe.enabled = false
        item.name = "muluna-steam-".. name
        item.place_result = "muluna-steam-".. name
        -- Paranoidal fork: the home furnace keeps its order (crafting menu before the rocket); the steam variant sorts
        -- after it (upstream appended "a" to the home item's order).
        item.order = (item.order or "") .. (name ~= "crusher" and "b" or "a")
        

        Muluna:extend{steam_furnace,recipe,item}

    end
    end

    if mods["crushing-industry"] then
        if data.raw["assembling-machine"]["muluna-steam-crusher"].effect_receiver then
            data.raw["assembling-machine"]["muluna-steam-crusher"].effect_receiver.base_effect = nil
        end
        
        data.raw["assembling-machine"]["muluna-steam-crusher"].localised_name = nil
    end


    -- Muluna:extend{
    --     Muluna.rro.util_merge{),
    --     {
    --         name = "muluna-steam-".. name,
    --         ingredients = {
    --             {}
    --         }
    --     }
    --     }
    -- }
end