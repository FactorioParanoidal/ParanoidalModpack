data:extend({
    {
        type = "int-setting",
        name = "train_loader_inventory_size",
        setting_type = "startup",  
        default_value = 96,  
        minimum_value = 8,  
        maximum_value = 200,
        order = "a"
    }
})

data:extend({
    {
        type = "bool-setting",
        name = "use_loader_stubby_graphic",
        setting_type = "startup", 
        default_value = false,
        order = "b"           
    }
})

data:extend({
    {
      type = "string-setting",
      name = "train_loader_size",
      setting_type = "startup",
      default_value = "4x4",
      allowed_values = {"4x4", "6x6"},
      order = "a"
    }
  })

data:extend({
    {
        type = "bool-setting",
        name = "experimental-balancing",
        setting_type = "startup",
        default_value = false,
        order = "c"
    }
})

data:extend({
    {
        type = "bool-setting",
        name = "train_loader_recipe_enabled",
        setting_type = "startup",
        default_value = false,
        order = "d"
    }
})

data:extend({
    {
        type = "bool-setting",
        name = "load-speed-experimental-limit",
        setting_type = "startup",
        default_value = false,
        order = "d"
    }
})