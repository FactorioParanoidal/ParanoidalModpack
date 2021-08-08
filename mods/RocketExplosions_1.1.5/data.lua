-- changed: darkfrei 2021-07-20

require('prototypes.technologies')


local mod_name = "__RocketExplosions__"
data:extend({
  {
    type = "sound",
    name = "rocket-win",
    filename = mod_name .."/sounds/rocket-win.ogg",
    category = "environment",
    audible_distance_modifier = 9999999,
    volume = 1
  }
})