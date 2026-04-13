data:extend({
      {
        type = "technology",
        name = "artillery-prototype",
        icon_size = 256, icon_mipmaps = 4,
        icon = "__zzzparanoidal__/graphics/entity/artillery.png",
        effects = 
        {
          {type = "unlock-recipe", recipe = "artillery-turret-prototype"},
          {type = "unlock-recipe", recipe = "artillery-shell-prototype"},  
        },
        prerequisites = {"military-2", "explosives"},
        unit = 
        {
          count = 300,
          ingredients = 
          {
            { "automation-science-pack", 1},
            { "logistic-science-pack", 1},
            { "military-science-pack", 1},
          },
          time = 30,
        }
      }, 
})
