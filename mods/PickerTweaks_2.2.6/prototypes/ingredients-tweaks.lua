--[[
    "name": "Dont_lose_in_progress_ingredients",
    "title": "Don't lose in progress ingredients",
    "author": "Bilka",
    "description": "Fixes that ingredients of in-process crafting would be lost when changing recipe/mining the machine.",
--]] --
if settings.startup['picker-return-ingredients'].value then
    for _, category in pairs{'furnace', 'assembling-machine', 'rocket-silo'} do
        for _, machine in pairs(data.raw[category]) do machine.return_ingredients_on_change = true end
    end
end
