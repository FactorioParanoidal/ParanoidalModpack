-- Убираем дополнительный MK5: лестница Beta 8 заканчивается на MK4.
local name = "angels-ore-sorting-facility-5"
local fourth = data.raw["assembling-machine"]["angels-ore-sorting-facility-4"]
if fourth then
    if fourth.next_upgrade == name then fourth.next_upgrade = nil end
    -- В 1.1 три рецепта чистых руд выполнялись в MK4. В Angels 2.0 они
    -- вынесены в отдельную категорию; возвращаем доступ, не меняя рецепты.
    local category = "angels-ore-sorting-5"
    local found = false
    for _, current in ipairs(fourth.crafting_categories) do
        if current == category then found = true end
    end
    if not found then fourth.crafting_categories[#fourth.crafting_categories + 1] = category end
end

for _, technology in pairs(data.raw.technology) do
    local effects = technology.effects or {}
    for index = #effects, 1, -1 do
        if effects[index].type == "unlock-recipe" and effects[index].recipe == name then
            table.remove(effects, index)
        end
    end
end
data.raw["assembling-machine"][name] = nil
data.raw.item[name] = nil
data.raw.recipe[name] = nil
