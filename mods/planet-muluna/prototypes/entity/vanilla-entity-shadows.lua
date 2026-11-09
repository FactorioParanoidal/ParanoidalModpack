if settings.startup["muluna-separate-shadows"].value == true then 
    local rro = Muluna.rro

    if not reskins then --Reskins-library already replaces these assets
        local pipe_ground = table.deepcopy(data.raw["pipe-to-ground"]["pipe-to-ground"])
        local new_pictures = {}
        local send_new_pictures = true
        for key,picture in pairs(pipe_ground.pictures) do
            local old_picture = table.deepcopy(pipe_ground.pictures[key])
            --local new_layers = {old_picture}
            -- old_picture.filename = __base__/graphics/entity/pipe-to-ground/pipe-to-ground-up.png
            --local new_filename_shadow = string.gsub(old_picture.filename or old_picture.layers[1].filename,"__.+__/graphics/entity","__muluna-graphics__/graphics/entities")
            local new_filename = string.gsub(old_picture.filename or old_picture.layers[1].filename,"__.+__/graphics","__muluna-graphics__/graphics")
            local new_filename_shadow = new_filename
            if string.find(new_filename,"__muluna%-graphics__") then
                new_filename_shadow = string.gsub(new_filename,"/pipe%-to%-ground/","/pipe-to-ground-shadow/")
            end
            
            --log(new_filename)
            --log(new_filename_shadow)
            --assert(new_filename ~= old_picture.filename,new_filename)
            --assert(new_filename_shadow ~= new_filename,new_filename_shadow)
            if new_filename ~= old_picture.filename and new_filename_shadow ~= new_filename then
                local new_layers = {
                    {
                        filename = new_filename,
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                {
                    filename = new_filename_shadow,
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    scale = 0.5,
                    draw_as_shadow = true
                }
                }
                
                new_pictures[key] = {layers = new_layers}
            else
                send_new_pictures = false
            end

        end


        if send_new_pictures == true then
            pipe_ground.pictures = new_pictures
        end



        Muluna:extend{pipe_ground}

        local pipe = table.deepcopy(data.raw["pipe"]["pipe"])
        local new_pictures = {}
        local send_new_pictures = true
        for key,picture in pairs(pipe.pictures) do
            local old_picture = table.deepcopy(pipe.pictures[key])
            --local new_layers = {old_picture}
            -- old_picture.filename = __base__/graphics/entity/pipe-to-ground/pipe-to-ground-up.png
            --local new_filename_shadow = string.gsub(old_picture.filename,"__base__/graphics/entity","__muluna-graphics__/graphics/entities")
            local excluded_keys = {
                "horizontal_window_background",
                "vertical_window_background",
                "fluid_background",
                "low_temperature_flow",
                "middle_temperature_flow",
                "high_temperature_flow",
                "gas_flow",

            }
            if rro.contains(excluded_keys,key) or string.find(key,"frozen") or string.find(key,"visualization") then
                new_pictures[key] = old_picture
            else
                local new_filename = string.gsub(old_picture.filename or old_picture.layers[1].filename,"__base__/graphics","__muluna-graphics__/graphics")
                local new_filename_shadow = new_filename 
                if string.find(new_filename_shadow,"__muluna%-graphics__") then
                    new_filename_shadow = string.gsub(new_filename,"/pipe/","/pipe-shadow/")
                end
                
                log(new_filename)
                log(new_filename_shadow)
                --assert(new_filename ~= old_picture.filename,new_filename)
                --assert(new_filename_shadow ~= new_filename,new_filename_shadow)
                if new_filename ~= old_picture.filename and new_filename_shadow ~= new_filename then
                    local new_layers = {
                        {
                            filename = new_filename,
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                        },
                    {
                        filename = new_filename_shadow,
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                    }
                    
                    new_pictures[key] = {layers = new_layers}
                else
                    send_new_pictures = false
                end
            end

        end


        if send_new_pictures == true then
            pipe.pictures = new_pictures
        end



        Muluna:extend{pipe}
    end

--Inserters 

local pictures = {
    hand_base_picture = "hand_base_shadow",
    hand_open_picture = "hand_open_shadow",
    hand_closed_picture = "hand_closed_shadow",
}

for _,inserter in pairs(data.raw["inserter"]) do
    for picture, shadow in pairs(pictures) do
        -- inserter[picture] = {
        --     layers = {
        --         table.deepcopy(inserter[picture]),
        --         Muluna.rro.util_merge{table.deepcopy(inserter[shadow]){draw_as_shadow = true}}
        --     }
        -- }
        if inserter[shadow] then
            inserter[shadow].draw_as_shadow = true
            inserter[shadow].filename = string.gsub(inserter[shadow].filename,"__base__","__muluna-graphics__")
            inserter[shadow].filename = string.gsub(inserter[shadow].filename,"__space%-age__","__muluna-graphics__")
        end
        
        -- if string.find(inserter[shadow].filename,"burner$-inserter$-hand$-")
        -- or string.find(inserter[shadow].filename,"bulk$-inserter$-hand$-")
        -- or string.find(inserter[shadow].filename,"stack$-inserter$-hand$-")
        -- then
            
            
        -- end
    end
    if inserter.platform_picture then
        if inserter.platform_picture.sheet then
            inserter.platform_picture.sheets = {
                table.deepcopy(inserter.platform_picture.sheet),
                table.deepcopy(inserter.platform_picture.sheet),
            }
            inserter.platform_picture.sheet = nil
            inserter.platform_picture.sheets[2].filename = "__muluna-graphics__/graphics/entity/stack-inserter/stack-inserter-platform-shadow.png"
            inserter.platform_picture.sheets[2].size = nil
            inserter.platform_picture.sheets[2].width = 105
            inserter.platform_picture.sheets[2].height = 79
            inserter.platform_picture.sheets[2].draw_as_shadow = true
            inserter.platform_picture.sheets[1].filename = string.gsub(inserter.platform_picture.sheets[1].filename,"__base__","__muluna-graphics__")
            inserter.platform_picture.sheets[1].filename = string.gsub(inserter.platform_picture.sheets[1].filename,"__space%-age__","__muluna-graphics__")
        end
    end
end
end




if settings.startup["muluna-change-planet-shadow-opacity"].value == true then
    local planets = {
        vulcanus = 0.3,
        fulgora = 0.6,
        moshine=0.55,
        corrundum = 0.2,
        aquilo = 0.7,
        frozeta = 0.75,
        maraxsis = 0.2,
        --["space-platform"] = 0.8,
    }
    for planet,opacity in pairs(planets) do
        log(planet .. " " .. opacity)
        local type = "planet"
        if not data.raw["planet"][planet] then
            type = "space-platform-hub"
        end
        if data.raw[type][planet] then
            if data.raw[type][planet].surface_render_parameters == nil then
                data.raw[type][planet].surface_render_parameters = {}
            end
            data.raw[type][planet].surface_render_parameters.shadow_opacity = opacity
        end

    end
end

