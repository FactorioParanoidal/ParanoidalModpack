local util = require("data-util")

data.raw.wall["stone-wall"].icon = "__aai-industry__/graphics/icons/stone-wall.png"
data.raw.wall["stone-wall"].icon_size = 64
util.replace_filenames_recursive(data.raw.wall["stone-wall"].pictures, "__base__", "__aai-industry__")
util.replace_filenames_recursive(data.raw.wall["stone-wall"].pictures, "entity/wall", "entity/stone-wall")
data.raw.wall["stone-wall"].fast_replaceable_group = data.raw.wall["stone-wall"].fast_replaceable_group or "wall"
data.raw.wall["stone-wall"].max_health = 350
data.raw.wall["stone-wall"].next_upgrade = "concrete-wall"
data.raw.wall["stone-wall"].hide_resistances = false
data.raw.wall["stone-wall"].resistances = {
 {
   percent = 20,
   type = "physical"
 },
 {
   decrease = 45,
   percent = 60,
   type = "impact"
 },
 {
   percent = 30,
   type = "explosion"
 },
 {
   percent = 100,
   type = "fire"
 },
 {
   percent = 70,
   type = "acid"
 },
 {
   percent = 70,
   type = "laser"
 },
 {
   percent = 70,
   type = "poison"
 }
}

local concrete = table.deepcopy(data.raw.wall["stone-wall"])
concrete.name = "concrete-wall"
concrete.minable.result = "concrete-wall"
concrete.icon = data.raw.item["concrete-wall"].icon
concrete.icon_size = data.raw.item["concrete-wall"].icon_size
util.replace_filenames_recursive(concrete.pictures, "stone-wall", "concrete-wall")
concrete.max_health = 800
concrete.next_upgrade = "steel-wall"
concrete.resistances = {
 {
   percent = 50,
   type = "physical"
 },
 {
   decrease = 50,
   percent = 70,
   type = "impact"
 },
 {
   percent = 50,
   type = "explosion"
 },
 {
   percent = 100,
   type = "fire"
 },
 {
   percent = 80,
   type = "acid"
 },
 {
   percent = 80,
   type = "laser"
 },
 {
   percent = 80,
   type = "poison"
 }
}
data:extend({concrete})

local steel = table.deepcopy(data.raw.wall["concrete-wall"])
steel.name = "steel-wall"
steel.minable.result = "steel-wall"
steel.icon = data.raw.item["steel-wall"].icon
steel.icon_size = data.raw.item["steel-wall"].icon_size
util.replace_filenames_recursive(steel.pictures, "concrete-wall", "steel-wall")
steel.pictures.corner_right_down.layers[1].shift[2] = steel.pictures.corner_right_down.layers[1].shift[2] - 2/32
steel.pictures.straight_horizontal.layers[1].shift[2] = steel.pictures.straight_horizontal.layers[1].shift[2] - 2/32
steel.pictures.ending_left.layers[1].shift[2] = steel.pictures.ending_left.layers[1].shift[2] - 1/32
steel.pictures.ending_right.layers[1].shift[2] = steel.pictures.ending_right.layers[1].shift[2] - 1/32
steel.max_health = 1000
steel.next_upgrade = nil
steel.resistances = {
 {
   percent = 90,
   type = "physical"
 },
 {
   decrease = 100,
   percent = 90,
   type = "impact"
 },
 {
   decrease = 10,
   percent = 70,
   type = "explosion"
 },
 {
   percent = 100,
   type = "fire"
 },
 {
   percent = 90,
   type = "acid"
 },
 {
   percent = 90,
   type = "laser"
 },
 {
   percent = 90,
   type = "poison"
 }
}


-- this kind of code can be used for having walls mirror the effect
-- there can be multiple reaction items
steel.attack_reaction =
{
  {
    ---- how far the mirroring works
    range = 2,
    ---- what kind of damage triggers the mirroring
    ---- if not present then anything triggers the mirroring
    damage_type = "physical",
    ---- caused damage will be multiplied by this and added to the subsequent damages
    reaction_modifier = 0.1,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "damage",
          ---- always use at least 0.1 damage
          damage = {amount = 0.1, type = "physical"}
        }
      }
    },
  }
}
steel.mined_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 }
steel.vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 1.0 }
data:extend({steel})
