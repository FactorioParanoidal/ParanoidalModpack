local heating
local heatingTower = util.table.deepcopy(data.raw["reactor"]["heating-tower"])
heatingTower.name = "heating-tower-selfpowered"
heatingTower.energy_source = {type = "void"}
heatingTower.consumption = "5MW"
heatingTower.heating_radius = 10
heatingTower.picture =
    {
      layers =
      {
        util.sprite_load("__RampantFixed__/graphics/entities/heating-tower/heating-tower-main", {
         scale = 0.5
        }),
        util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-shadow", {
          scale = 0.5,
          draw_as_shadow = true
        })
      }
    }

log("heatingTower")
data:extend({heatingTower})