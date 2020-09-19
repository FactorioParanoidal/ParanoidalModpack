local target = {}
local min_time = settings.startup["paranoidal-flowfix-min-time"].value
local pack = 1

function scaleTable(t, pack)
    for j,item in pairs(t) do
        if t[j].amount then
            t[j].amount = t[j].amount*pack
        else
            if type(t[j][2]) == 'number' then
                t[j][2] = t[j][2]*pack
            else
                log("WARRRING!!! not found ingredients count")
            end
        end
    end
end


function scaleRecipe(recipe, pack)
    --log("fix "..recipe.name .. " scale x"..pack)
    recipe.energy_required = recipe.energy_required * pack
    if recipe.ingredients then
        scaleTable(recipe.ingredients, pack)
    else
        log("no ingridients in "..recipe.name)
    end
    if recipe.result then
        if not recipe.result_count then
            recipe.result_count = 1
        end
        recipe.result_count = recipe.result_count*pack
    end
    if recipe.results then
        scaleTable(recipe.results, pack)
    end
end


for k,v in pairs(data.raw.module) do
    if v.effect.productivity and v.limitation then
        --log("use limitation from "..v.name)
        for i,r in pairs(v.limitation) do
            -- Простые рецепты
            if not data.raw.recipe[r].normal and not data.raw.recipe[r].energy_required then
                data.raw.recipe[r].energy_required = 0.5
            end
            if data.raw.recipe[r].energy_required and data.raw.recipe[r].energy_required < min_time then
                pack = 1 + (min_time - math.fmod(min_time, data.raw.recipe[r].energy_required))/data.raw.recipe[r].energy_required
                scaleRecipe(data.raw.recipe[r], pack)
            end

            -- Нормальные рецепты
            if data.raw.recipe[r].normal then
                if not data.raw.recipe[r].normal.energy_required then
                    data.raw.recipe[r].normal.energy_required = 0.5
                end
                if data.raw.recipe[r].normal.energy_required and data.raw.recipe[r].normal.energy_required < min_time then
                    pack = 1 + (min_time - math.fmod(min_time, data.raw.recipe[r].normal.energy_required))/data.raw.recipe[r].normal.energy_required
                    scaleRecipe(data.raw.recipe[r].normal, pack)
                end
            end

            -- Дорогие рецепты
            if data.raw.recipe[r].expensive then
                if not data.raw.recipe[r].expensive.energy_required then
                    data.raw.recipe[r].expensive.energy_required = 0.5
                end
                if data.raw.recipe[r].expensive.energy_required and data.raw.recipe[r].expensive.energy_required < min_time then
                    pack = 1 + (min_time - math.fmod(min_time, data.raw.recipe[r].expensive.energy_required))/data.raw.recipe[r].expensive.energy_required
                    scaleRecipe(data.raw.recipe[r].expensive, pack)
                end
            end
        end
    end
end
