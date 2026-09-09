require("__zzzparanoidal__.paralib")

local function remove_recipe_unlock(recipe_name)
    for _, technology in pairs(data.raw.technology) do
        if technology.effects then
            for index = #technology.effects, 1, -1 do
                local effect = technology.effects[index]
                if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                    table.remove(technology.effects, index)
                end
            end
        end
    end
end

local function remove_prerequisite(prerequisite_name)
    for _, technology in pairs(data.raw.technology) do
        if technology.prerequisites then
            for index = #technology.prerequisites, 1, -1 do
                if technology.prerequisites[index] == prerequisite_name then
                    table.remove(technology.prerequisites, index)
                end
            end
        end
    end
end

-- Убираем отдельную ступень электрификации Bob's, не заменяя её другой зависимостью.
local electricity = data.raw.technology["bob-electricity"]
if electricity then
    remove_prerequisite("bob-electricity")
    electricity.enabled = false
    electricity.hidden = true
    electricity.effects = {}
end

-- Железоугольный аккумулятор идёт после основ электрификации AAI.
if data.raw.technology["fe-c-accumulator"] and data.raw.technology["electricity"] then
    paralib.bobmods.lib.tech.add_prerequisite("fe-c-accumulator", "electricity")
end

-- Конденсаторы открываются электроникой.
if data.raw.recipe["condensator"] and data.raw.technology["electronics"] then
    remove_recipe_unlock("condensator")
    paralib.bobmods.lib.recipe.enabled("condensator", false)
    paralib.bobmods.lib.tech.add_recipe_unlock("electronics", "condensator")
end

-- Малый столб с лампой открывается только исследованием фонаря.
if data.raw.recipe["lighted-small-electric-pole"] and data.raw.technology["lamp"] then
    remove_recipe_unlock("lighted-small-electric-pole")
    paralib.bobmods.lib.recipe.enabled("lighted-small-electric-pole", false)
    paralib.bobmods.lib.tech.add_recipe_unlock("lamp", "lighted-small-electric-pole")
end
