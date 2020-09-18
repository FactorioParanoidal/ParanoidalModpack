local target = {}
local min_time = settings.startup["paranoidal-flowfix-min-time"].value
local pack = 1

for k,v in pairs(data.raw.module) do
    if v.effect.productivity then
        log("use limitation from "..v.name)
        for i,r in pairs(v.limitation) do
            -- Простые рецепты
            if not data.raw.recipe[r].normal and not data.raw.recipe[r].energy_required then
                data.raw.recipe[r].energy_required = 0.5
            end
            if data.raw.recipe[r].energy_required and data.raw.recipe[r].energy_required < min_time then
                t = data.raw.recipe[r].energy_required
                pack = 1 + (min_time - math.fmod(min_time, t))/t
                log("fix simple "..data.raw.recipe[r].name .. " scale x"..pack)
                data.raw.recipe[r].energy_required = data.raw.recipe[r].energy_required * pack
                if data.raw.recipe[r].ingredients then
                    for j,item in pairs(data.raw.recipe[r].ingredients) do
                        if data.raw.recipe[r].ingredients[j].amount then
                            data.raw.recipe[r].ingredients[j].amount = data.raw.recipe[r].ingredients[j].amount*pack
                        else
                            if type(data.raw.recipe[r].ingredients[j][2]) == 'number' then
                                data.raw.recipe[r].ingredients[j][2] = data.raw.recipe[r].ingredients[j][2]*pack
                            else
                                log("WARRRING!!! not found ingredients")
                            end
                        end
                    end
                else 
                    log("no ingridients in "..data.raw.recipe[r].name)
                end
                if type(data.raw.recipe[r].result_count)== 'number' then
                    data.raw.recipe[r].result_count = data.raw.recipe[r].result_count*pack
                else
                    if data.raw.recipe[r].results then
                        for j,item in pairs(data.raw.recipe[r].results) do
                            if data.raw.recipe[r].results[j].amount then
                                data.raw.recipe[r].results[j].amount = data.raw.recipe[r].results[j].amount*pack
                            else
                                if type(data.raw.recipe[r].results[j][2]) == 'number' then
                                    data.raw.recipe[r].results[j][2] = data.raw.recipe[r].results[j][2]*pack
                                else
                                    log("WARRRING!!! not found result")
                                end
                            end
                        end
                    end
                end
            end

            -- Нормальные рецепты
            if data.raw.recipe[r].normal then
                if not data.raw.recipe[r].normal.energy_required then
                    data.raw.recipe[r].normal.energy_required = 0.5
                end
                if data.raw.recipe[r].normal.energy_required and data.raw.recipe[r].normal.energy_required < min_time then
                    log("fix normal "..data.raw.recipe[r].name .. " scale x"..pack)
                    t = data.raw.recipe[r].normal.energy_required
                    pack = 1 + (min_time - math.fmod(min_time, t))/t
                    data.raw.recipe[r].normal.energy_required = data.raw.recipe[r].normal.energy_required * pack
                    if data.raw.recipe[r].normal.ingredients then
                        for j,item in pairs(data.raw.recipe[r].normal.ingredients) do
                            if data.raw.recipe[r].normal.ingredients[j].amount then
                                data.raw.recipe[r].normal.ingredients[j].amount = data.raw.recipe[r].normal.ingredients[j].amount*pack
                            else
                                if type(data.raw.recipe[r].normal.ingredients[j][2]) == 'number' then
                                    data.raw.recipe[r].normal.ingredients[j][2] = data.raw.recipe[r].normal.ingredients[j][2]*pack
                                else
                                    log("WARRRING!!! not found ingredients")
                                end
                            end
                        end
                    else
                        log("no ingridients in "..data.raw.recipe[r].name)
                    end
                    if type(data.raw.recipe[r].normal.result_count)== 'number' then
                        data.raw.recipe[r].normal.result_count = data.raw.recipe[r].normal.result_count*pack
                    else
                        if data.raw.recipe[r].normal.results then
                            for j,item in pairs(data.raw.recipe[r].normal.results) do
                                if data.raw.recipe[r].normal.results[j].amount then
                                    data.raw.recipe[r].normal.results[j].amount = data.raw.recipe[r].normal.results[j].amount*pack
                                else
                                    if type(data.raw.recipe[r].normal.results[j][2]) == 'number' then
                                        data.raw.recipe[r].normal.results[j][2] = data.raw.recipe[r].normal.results[j][2]*pack
                                    else
                                        log("WARRRING!!! not found result")
                                    end
                                end
                            end
                        end
                    end
                end

            -- Дорогие рецепты
            if data.raw.recipe[r].expensive then
                if not data.raw.recipe[r].expensive.energy_required then
                    data.raw.recipe[r].expensive.energy_required = 0.5
                end
                if data.raw.recipe[r].expensive.energy_required and data.raw.recipe[r].expensive.energy_required < min_time then
                    log("fix expensive "..data.raw.recipe[r].name .. " scale x"..pack)
                    t = data.raw.recipe[r].expensive.energy_required
                    pack = 1 + (min_time - math.fmod(min_time, t))/t
                    data.raw.recipe[r].expensive.energy_required = data.raw.recipe[r].expensive.energy_required * pack
                    if data.raw.recipe[r].expensive.ingredients then
                        for j,item in pairs(data.raw.recipe[r].expensive.ingredients) do
                            if data.raw.recipe[r].expensive.ingredients[j].amount then
                                data.raw.recipe[r].expensive.ingredients[j].amount = data.raw.recipe[r].expensive.ingredients[j].amount*pack
                            else
                                if type(data.raw.recipe[r].expensive.ingredients[j][2]) == 'number' then
                                    data.raw.recipe[r].expensive.ingredients[j][2] = data.raw.recipe[r].expensive.ingredients[j][2]*pack
                                else
                                    log("WARRRING!!! not found ingredients")
                                end
                            end
                        end
                    else 
                        log("no ingridients in "..data.raw.recipe[r].name)
                    end
                    if type(data.raw.recipe[r].expensive.result_count)== 'number' then
                        data.raw.recipe[r].expensive.result_count = data.raw.recipe[r].expensive.result_count*pack
                    else
                        if data.raw.recipe[r].expensive.results then
                            for j,item in pairs(data.raw.recipe[r].expensive.results) do
                                if data.raw.recipe[r].expensive.results[j].amount then
                                    data.raw.recipe[r].expensive.results[j].amount = data.raw.recipe[r].expensive.results[j].amount*pack
                                else
                                    if type(data.raw.recipe[r].expensive.results[j][2]) == 'number' then
                                        data.raw.recipe[r].expensive.results[j][2] = data.raw.recipe[r].expensive.results[j][2]*pack
                                    else
                                        log("WARRRING!!! not found result")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
end
