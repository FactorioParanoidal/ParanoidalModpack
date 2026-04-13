local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({{
    type = "item",
    name = "w93-scattergun-turret",
    icon = "__scattergun_turret__/graphics/icons/scattergun-turret.png",
    icon_size = 32,
    subgroup = "turret",
    order = "b[turret]-aa[scattergun-turret]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-scattergun-turret",

    stack_size = 50
,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-hmg-turret",
    icon = "__scattergun_turret__/graphics/icons/hmg-turret.png",
    icon_size = 64,
    subgroup = "modular-turrets-combat",
    order = "j[modular-turrets-combat]-a[w93-hmg-turret]",
    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-hmg-turret",

    stack_size = 50

,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-hmg-turret2",
    icon = "__scattergun_turret__/graphics/icons/hmg-turret2.png",
    icon_size = 64,
    subgroup = "modular-turrets2-combat",
    order = "k[modular-turrets2-combat]-a[w93-hmg-turret2]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-hmg-turret2",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-gatling-turret",
    icon = "__scattergun_turret__/graphics/icons/gatling-turret.png",
    icon_size = 64,
    subgroup = "modular-turrets-combat",
    order = "j[modular-turrets-combat]-b[w93-gatling-turret]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-gatling-turret",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-gatling-turret2",
    icon = "__scattergun_turret__/graphics/icons/gatling-turret2.png",
    icon_size = 64,
    subgroup = "modular-turrets2-combat",
    order = "k[modular-turrets2-combat]-b[w93-gatling-turret2]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-gatling-turret2",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-lcannon-turret",
    icon = "__scattergun_turret__/graphics/icons/lcannon-turret.png",
    icon_size = 64,
    subgroup = "modular-turrets-combat",
    order = "j[modular-turrets-combat]-c[w93-lcannon-turret]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-lcannon-turret",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-lcannon-turret2",
    icon = "__scattergun_turret__/graphics/icons/lcannon-turret2.png",
    icon_size = 64,
    subgroup = "modular-turrets2-combat",
    order = "k[modular-turrets2-combat]-c[w93-lcannon-turret2]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-lcannon-turret2",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-dcannon-turret",
    icon = "__scattergun_turret__/graphics/icons/dcannon-turret.png",
    icon_size = 64,
    subgroup = "modular-turrets-combat",
    order = "j[modular-turrets-combat]-d[w93-dcannon-turret]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-dcannon-turret",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-dcannon-turret2",
    icon = "__scattergun_turret__/graphics/icons/dcannon-turret2.png",
    icon_size = 64,
    subgroup = "modular-turrets2-combat",
    order = "k[modular-turrets2-combat]-d[w93-dcannon-turret2]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-dcannon-turret2",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-hcannon-turret",
    icon = "__scattergun_turret__/graphics/icons/hcannon-turret.png",
    icon_size = 64,
    subgroup = "modular-turrets-combat",
    order = "j[modular-turrets-combat]-e[w93-hcannon-turret]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-hcannon-turret",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-hcannon-turret2",
    icon = "__scattergun_turret__/graphics/icons/hcannon-turret2.png",
    icon_size = 64,
    subgroup = "modular-turrets2-combat",
    order = "k[modular-turrets2-combat]-e[w93-hcannon-turret2]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-hcannon-turret2",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-rocket-turret",
    icon = "__scattergun_turret__/graphics/icons/rocket-turret.png",
    icon_size = 64,
    subgroup = "modular-turrets-combat",
    order = "j[modular-turrets-combat]-f[w93-rocket-turret]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-rocket-turret",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-rocket-turret2",
    icon = "__scattergun_turret__/graphics/icons/rocket-turret2.png",
    icon_size = 64,
    subgroup = "modular-turrets2-combat",
    order = "k[modular-turrets2-combat]-f[w93-rocket-turret2]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-rocket-turret2",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-plaser-turret",
    icon = "__scattergun_turret__/graphics/icons/plaser-turret.png",
    icon_size = 64,
    subgroup = "modular-turrets-combat",
    order = "j[modular-turrets-combat]-g[w93-plaser-turret]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-plaser-turret",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-plaser-turret2",
    icon = "__scattergun_turret__/graphics/icons/plaser-turret2.png",
    icon_size = 64,
    subgroup = "modular-turrets2-combat",
    order = "k[modular-turrets2-combat]-g[w93-plaser-turret2]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-plaser-turret2",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-tlaser-turret",
    icon = "__scattergun_turret__/graphics/icons/tlaser-turret.png",
    icon_size = 64,
    subgroup = "modular-turrets-combat",
    order = "j[modular-turrets-combat]-h[w93-tlaser-turret]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-tlaser-turret",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-tlaser-turret2",
    icon = "__scattergun_turret__/graphics/icons/tlaser-turret2.png",
    icon_size = 64,
    subgroup = "modular-turrets2-combat",
    order = "k[modular-turrets2-combat]-h[w93-tlaser-turret2]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-tlaser-turret2",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-beam-turret",
    icon = "__scattergun_turret__/graphics/icons/beam-turret.png",
    icon_size = 64,
    subgroup = "modular-turrets-combat",
    order = "j[modular-turrets-combat]-i[w93-beam-turret]",

    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-beam-turret",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-beam-turret2",
    icon = "__scattergun_turret__/graphics/icons/beam-turret2.png",
    icon_size = 64,
    subgroup = "modular-turrets2-combat",
    order = "k[modular-turrets2-combat]-i[w93-beam-turret2]",
    inventory_move_sound = item_sounds.turret_inventory_move,

    pick_sound = item_sounds.turret_inventory_pickup,

    drop_sound = item_sounds.turret_inventory_move,
    place_result = "w93-beam-turret2",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-radar-turret",
    icon = "__scattergun_turret__/graphics/icons/radar-turret.png",
    icon_size = 64,
    subgroup = "defensive-structure",
    order = "d[radar]-b[w93-radar-turret]",

    inventory_move_sound = item_sounds.metal_large_inventory_move,

    pick_sound = item_sounds.metal_large_inventory_pickup,

    drop_sound = item_sounds.metal_large_inventory_move,
    place_result = "w93-radar-turret",

    stack_size = 50
,
    weight = 40*kg
},
{
    type = "item",
    name = "w93-radar-turret2",
    icon = "__scattergun_turret__/graphics/icons/radar-turret2.png",
    icon_size = 64,
    subgroup = "defensive-structure",
    order = "d[radar]-c[w93-radar-turret2]",
    inventory_move_sound = item_sounds.metal_large_inventory_move,

    pick_sound = item_sounds.metal_large_inventory_pickup,

    drop_sound = item_sounds.metal_large_inventory_move,
    place_result = "w93-radar-turret2",

    stack_size = 50
,
    weight = 40*kg
},

{
    type = "item",
    name = "w93-modular-turret-base",
    icon = "__scattergun_turret__/graphics/icons/modular-turret-base.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-a[w93-modular-turret-base]",
    inventory_move_sound = item_sounds.metal_large_inventory_move,

    pick_sound = item_sounds.metal_large_inventory_pickup,

    drop_sound = item_sounds.metal_large_inventory_move,
    stack_size = 50
,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-turret2-base",
    icon = "__scattergun_turret__/graphics/icons/modular-turret2-base.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-b[w93-modular-turret2-base]",
    inventory_move_sound = item_sounds.metal_large_inventory_move,

    pick_sound = item_sounds.metal_large_inventory_pickup,

    drop_sound = item_sounds.metal_large_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "gun",
    name = "w93-modular-gun-hmg",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-hmg.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-c[w93-modular-gun-hmg]",
    inventory_move_sound = item_sounds.metal_small_inventory_move,

    pick_sound = item_sounds.metal_small_inventory_pickup,

    drop_sound = item_sounds.metal_small_inventory_move,
    attack_parameters =

    {

      type = "projectile",

      ammo_category = "bullet",

      cooldown = 10,
      movement_slow_down_factor = 0.75,

      damage_modifier = 2,
      shell_particle =

      {

        name = "shell-particle",

        direction_deviation = 0.1,

        speed = 0.1,

        speed_deviation = 0.03,

        center = {0, 0.1},

        creation_distance = -0.5,

        starting_frame_speed = 0.4,

        starting_frame_speed_deviation = 0.1

      },
      projectile_creation_distance = 1.125,

      range = 30,

      sound =
      {
         filename = "__scattergun_turret__/sound/hmg-turret-fire.ogg",
	 volume = 0.8,
      },
    },
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-gun-gatling",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-gatling.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-d[w93-modular-gun-gatling]",
    inventory_move_sound = item_sounds.metal_small_inventory_move,

    pick_sound = item_sounds.metal_small_inventory_pickup,

    drop_sound = item_sounds.metal_small_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-gun-lcannon",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-lcannon.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-e[w93-modular-gun-lcannon]",
    inventory_move_sound = item_sounds.metal_small_inventory_move,

    pick_sound = item_sounds.metal_small_inventory_pickup,

    drop_sound = item_sounds.metal_small_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-gun-dcannon",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-dcannon.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-f[w93-modular-gun-dcannon]",
    inventory_move_sound = item_sounds.metal_small_inventory_move,

    pick_sound = item_sounds.metal_small_inventory_pickup,

    drop_sound = item_sounds.metal_small_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-gun-hcannon",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-hcannon.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-g[w93-modular-gun-hcannon]",
    inventory_move_sound = item_sounds.metal_small_inventory_move,

    pick_sound = item_sounds.metal_small_inventory_pickup,

    drop_sound = item_sounds.metal_small_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-gun-rocket",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-rocket.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-h[w93-modular-gun-rocket]",
    inventory_move_sound = item_sounds.metal_small_inventory_move,

    pick_sound = item_sounds.metal_small_inventory_pickup,

    drop_sound = item_sounds.metal_small_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-gun-plaser",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-plaser.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-i[w93-modular-gun-plaser]",
    inventory_move_sound = item_sounds.electric_small_inventory_move,

    pick_sound = item_sounds.electric_small_inventory_pickup,

    drop_sound = item_sounds.electric_small_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-gun-tlaser",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-tlaser.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-j[w93-modular-gun-tlaser]",
    placed_as_equipment_result = "w93-modular-gun-tlaser",
    inventory_move_sound = item_sounds.electric_small_inventory_move,

    pick_sound = item_sounds.electric_small_inventory_pickup,

    drop_sound = item_sounds.electric_small_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-gun-beam",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-beam.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-k[w93-modular-gun-beam]",
    inventory_move_sound = item_sounds.electric_small_inventory_move,

    pick_sound = item_sounds.electric_small_inventory_pickup,

    drop_sound = item_sounds.electric_small_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-gun-radar",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-radar.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-l[w93-modular-gun-radar]",
    inventory_move_sound = item_sounds.electric_small_inventory_move,

    pick_sound = item_sounds.electric_small_inventory_pickup,

    drop_sound = item_sounds.electric_small_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-modular-gun-radar2",
    icon = "__scattergun_turret__/graphics/icons/modular-gun-radar2.png",
    icon_size = 64,
    subgroup = "modular-turrets",
    order = "h[modular-turrets]-m[w93-modular-gun-radar2]",
    inventory_move_sound = item_sounds.electric_small_inventory_move,

    pick_sound = item_sounds.electric_small_inventory_pickup,

    drop_sound = item_sounds.electric_small_inventory_move,
    stack_size = 50

,
    weight = 20*kg
},
{
    type = "item",
    name = "w93-hardened-inserter",

    icon = "__scattergun_turret__/graphics/icons/hardened-inserter.png",

    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "inserter",
    order = "c[long-handed-inserter]-a[w93-hardened-inserter]",

    inventory_move_sound = item_sounds.inserter_inventory_move,

    pick_sound = item_sounds.inserter_inventory_pickup,

    drop_sound = item_sounds.inserter_inventory_move,
    place_result = "w93-hardened-inserter",
    stack_size = 50

,
    weight = 20*kg
},

{
    type = "item-subgroup",

     name = "modular-turrets",

     group = "intermediate-products",
 
    order = "h"

},
{
    type = "item-subgroup",

     name = "modular-turrets-combat",

     group = "combat",
 
    order = "j"

},
{
    type = "item-subgroup",

     name = "modular-turrets2-combat",

     group = "combat",
 
    order = "k"

}})