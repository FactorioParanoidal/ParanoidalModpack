-- Turret Circuit Connectors

circuit_connector_definitions["w93-turret-base"] = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    { variation = 0, main_offset = util.by_pixel( 6 , 24), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 7, main_offset = util.by_pixel(-20, 20), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 6, main_offset = util.by_pixel(-34, 0 ), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 5, main_offset = util.by_pixel(-37,-8 ), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 4, main_offset = util.by_pixel(-37,-8 ), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 3, main_offset = util.by_pixel( 34,-12 ), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 2, main_offset = util.by_pixel( 37,-8 ), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 1, main_offset = util.by_pixel( 30, 16), shadow_offset = util.by_pixel(0,0), show_shadow = false }
  }
)
 
circuit_connector_definitions["w93-turret-base2"] = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    { variation = 0, main_offset = util.by_pixel( 6 , 24), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 7, main_offset = util.by_pixel(-20, 20), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 6, main_offset = util.by_pixel(-34, 0 ), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 5, main_offset = util.by_pixel(-24,-24), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 4, main_offset = util.by_pixel( -5 ,-30), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 3, main_offset = util.by_pixel( 24,-24), shadow_offset = util.by_pixel(0,0), show_shadow = false },   
    { variation = 2, main_offset = util.by_pixel( 37,-8 ), shadow_offset = util.by_pixel(0,0), show_shadow = false },
    { variation = 1, main_offset = util.by_pixel( 30, 16), shadow_offset = util.by_pixel(0,0), show_shadow = false }
  }
)

-- Base Modular Turrets
require("prototypes.entities.w93-scattergun-turret")
require("prototypes.entities.w93-hmg-turret")
require("prototypes.entities.w93-gatling-turret")
require("prototypes.entities.w93-lcannon-turret")
require("prototypes.entities.w93-dcannon-turret")
require("prototypes.entities.w93-hcannon-turret")
require("prototypes.entities.w93-rocket-turret")
require("prototypes.entities.w93-plaser-turret")
require("prototypes.entities.w93-tlaser-turret")
require("prototypes.entities.w93-beam-turret")
require("prototypes.entities.w93-radar-turret")
require("prototypes.entities.w93-hardened-inserter")

require("prototypes.projectiles.projectiles")
require("prototypes.projectiles.projectiles-ammo")

require("prototypes.items.items-ammo")
require("prototypes.items.equipment")
require("prototypes.items.items")

require("prototypes.recipes.recipes-ammo")
require("prototypes.recipes.recipes-entity")

require("prototypes.technology.technology")

-- Compatibility
require("prototypes.recipes.recipes-krastorio2")
require("prototypes.technology.technology-krastorio2")

require("prototypes.recipes.recipes-ir3")
require("prototypes.items.items-ir3")
require("prototypes.technology.technology-ir3")