
local chests = { 
    { 
        name = 'steel-chest',
        technology = {'steel-processing'},
        entity_type = 'container',
        order = "a",
        ingredients = {
            {type="item", name="steel-plate", amount=2},
        },
        copy_from = 'steel-chest'
    },
    { 
        name = 'logistic-chest-passive-provider',
        technology = {'construction-robotics', 'logistic-robotics'},
        entity_type = 'logistic-container',
        order = "b",
        ingredients = {
            {type="item", name="mini-steel-chest", amount=1},
            {type="item", name="electronic-circuit", amount=3},
            {type="item", name="advanced-circuit", amount=1}
        },
        copy_from = 'passive-provider-chest'
    },
    { 
        name = 'logistic-chest-storage',
        technology = {'construction-robotics', 'logistic-robotics'}, 
        entity_type = 'logistic-container',
        order = "d",
        ingredients = {
            {type="item", name="mini-steel-chest", amount=1},
            {type="item", name="electronic-circuit", amount=3},
            {type="item", name="advanced-circuit", amount=1}
        },
        copy_from = 'storage-chest'
    },
    { 
        name = 'logistic-chest-active-provider',
        technology = {'logistic-system'},
        entity_type = 'logistic-container',
        order = "c",
        ingredients = {
            {type="item", name="mini-steel-chest", amount=1},
            {type="item", name="electronic-circuit", amount=3},
            {type="item", name="advanced-circuit", amount=1}
        },
        copy_from = 'active-provider-chest'
    },
    {   
        name = 'logistic-chest-buffer',
        technology = {'logistic-system'},
        entity_type = 'logistic-container',
        order = "e",
        ingredients = {
            {type="item", name="mini-steel-chest", amount=1},
            {type="item", name="electronic-circuit", amount=3},
            {type="item", name="advanced-circuit", amount=1}
        },
        copy_from = 'buffer-chest'
    },
    { 
        name = 'logistic-chest-requester',
        technology = {'logistic-system'},
        entity_type = 'logistic-container',
        order = "f",
        ingredients = {
            {type="item", name="mini-steel-chest", amount=1},
            {type="item", name="electronic-circuit", amount=3},
            {type="item", name="advanced-circuit", amount=1}
        },
        copy_from = 'requester-chest'
    }
}

data:extend({
    {
    type = "item-subgroup",
    name = "mini-containers",
    group = "logistics",
    order = "a9[container-1]"
  },
});

for _, chest in pairs(chests) do
    local newChestItem   = table.deepcopy(data.raw.item[chest.copy_from])
    local newChestEntity = table.deepcopy(data.raw[chest.entity_type][chest.copy_from])
    local newRecipe      = table.deepcopy(data.raw.recipe[chest.copy_from])

    newChestItem.name             = "mini-" .. chest.name
    newChestItem.subgroup         = "mini-containers"
    newChestItem.place_result     = "mini-" .. chest.name
    newChestItem.order            = "a[storage]-" .. chest.order .. "[" .. newChestItem.name .. "]"
    newChestItem.icon             = "__osha_mini_containers__/graphics/icons/" .. newChestItem.name .. ".png"
    newChestItem.icon_size        = 64
    newChestItem.icon_mipmaps     = 4
    newChestItem.icons            = nil
    newRecipe.name                = "mini-" .. chest.name
    newRecipe.results = {
        { type="item", name="mini-" .. chest.name, amount=1 }
    }
    
    newRecipe.ingredients         = chest.ingredients
    newRecipe.icon                = "__osha_mini_containers__/graphics/icons/" .. newChestItem.name .. ".png"
    newRecipe.icon_size           = 64
    newRecipe.icon_mipmaps        = 4
    newChestEntity.name           = "mini-" .. chest.name
    newChestEntity.inventory_size = 1
    newChestEntity.minable.result = newChestItem.name
    newChestEntity.icon             = "__osha_mini_containers__/graphics/icons/" .. newChestItem.name .. ".png"
    newChestEntity.icon_size        = 64
    newChestEntity.icon_mipmaps     = 4

    for _, t in pairs(chest.technology) do
        table.insert(data.raw.technology[t].effects,{type = "unlock-recipe", recipe = newRecipe.name})    
    end
    
    data:extend({newChestItem});
    data:extend({newChestEntity});
    data:extend({newRecipe});
end
