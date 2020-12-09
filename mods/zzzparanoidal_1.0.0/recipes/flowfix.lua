local target = {}
local min_time = settings.startup["paranoidal-flowfix-min-time"].value
--local pack = 1

local function scaleTable(t, pack)
    for j,item in pairs(t) do
        if t[j].amount then
            t[j].amount = t[j].amount*pack
            local catalyst_amount = t[j].catalyst_amount
            if catalyst_amount then 
                t[j].catalyst_amount = catalyst_amount*pack 
            end
        else
            if type(t[j][2]) == 'number' then
                t[j][2] = t[j][2]*pack
            else
                log("WARRRING!!! not found ingredients count")
            end
        end
    end
end

local function pack_trim(pack, item_name, result_count)
    local item = data.raw.item[item_name]
    if item and item.stack_size then
        return math.min(pack, math.max(1, math.floor(item.stack_size)/result_count))
    else
        return pack
    end    
end      

local function scaleRecipe(recipe)
    if recipe.energy_required and recipe.energy_required < min_time then
        local pack = math.max(1, math.ceil(min_time/recipe.energy_required))
        pack = pack_trim(pack, recipe.result, recipe.result_count or 1)
        if recipe.results then
            for j,item in pairs(recipe.results) do
                if item.amount then
                   pack = pack_trim(pack, item.name, item.amount)
                else
                    if type(item[2])=='number' then
                        pack = pack_trim(pack, item[1], item[2])
                    end
                end
            end
        end    
        
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
end


for k,v in pairs(data.raw.module) do
    if v.effect.productivity and v.limitation then
        --log("use limitation from "..v.name)
        for i,r in pairs(v.limitation) do
            local recipe = data.raw.recipe[r]
            if recipe.name ~= "rocket-part"  then
                -- Простые рецепты
                if not recipe.normal and not recipe.energy_required then
                    recipe.energy_required = 0.5
                end
                scaleRecipe(recipe)

                -- Нормальные рецепты
                if recipe.normal then
                    if not recipe.normal.energy_required then
                        recipe.normal.energy_required = 0.5
                    end
                    scaleRecipe(recipe.normal)
                end

                -- Дорогие рецепты
                if recipe.expensive then
                    if not recipe.expensive.energy_required then
                        recipe.expensive.energy_required = 0.5
                    end
                    scaleRecipe(recipe.expensive)
                end
            end
        end
    end
end
