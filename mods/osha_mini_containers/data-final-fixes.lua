local chests = { 
    'mini-steel-chest', 
    'mini-logistic-chest-passive-provider', 
    'mini-logistic-chest-storage', 
    'mini-logistic-chest-active-provider', 
    'mini-logistic-chest-buffer', 
    'mini-logistic-chest-requester'
}
-- make sure the item in our inventory has the proper icon
for _, chest in pairs(chests) do
    data.raw.item[chest].icon = "__osha_mini_containers__/graphics/icons/" .. chest .. ".png"
    data.raw.recipe[chest].icon = "__osha_mini_containers__/graphics/icons/" .. chest .. ".png"
end