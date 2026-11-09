local flib_bounding_box = Muluna.flib_bounding_box
local rocket_silo= data.raw["rocket-silo"]["rocket-silo"]
local rocket = data.raw["rocket-silo-rocket"]["rocket-silo-rocket"]
local cargo_pod = data.raw["cargo-pod"]["cargo-pod"]
local rocket_shadow = data.raw["rocket-silo-rocket-shadow"]["rocket-silo-rocket-shadow"]
local rro = Muluna.rro

local big_silo = table.deepcopy(rocket_silo)
local big_rocket = table.deepcopy(rocket)
local big_pod = table.deepcopy(cargo_pod)
local big_shadow = table.deepcopy(rocket_shadow)

big_silo.name = "muluna-big-rocket-silo"
big_silo.minable.result= "muluna-big-rocket-silo"
big_rocket.name= "muluna-big-rocket-silo-rocket"
big_pod.name = "muluna-big-cargo-pod"
big_shadow.name = "muluna-big-rocket-silo-rocket-shadow"
big_silo.icon="__space-exploration-graphics__/graphics/icons/rocket-launch-pad.png"

big_silo.lift_weight = (rocket_silo.lift_weight or 1000000) * 5
big_silo.rocket_parts_required= rocket_silo.rocket_parts_required * 3
big_silo.crafting_speed = big_silo.crafting_speed * 3
big_silo.perceived_performance = {performance_to_activity_rate=1/3}
big_silo.active_energy_usage = Muluna.multiply_energy(big_silo.active_energy_usage,5)
big_silo.lamp_energy_usage = Muluna.multiply_energy(big_silo.lamp_energy_usage,3)

big_rocket.tall = true
big_silo.selection_box=flib_bounding_box.resize(rocket_silo.selection_box,3) 
big_silo.collision_box=flib_bounding_box.resize(rocket_silo.collision_box,3) 

big_silo.fluidboxes=nil

local objects = {big_silo,big_rocket,big_pod,rocket_shadow}
big_silo.shadow_sprite =
    {
        layers = {
            {
      filename = "__space-exploration-graphics-5__/graphics/entity/rocket-launch-pad/00-rocket-silo-shadow.png",
      priority = "medium",
      width = 410,
      height = 510,
      draw_as_shadow = true,
      dice = 1,
      shift = util.by_pixel(180.0, 16.0),
      scale = 0.55*0.9,
      tint = {1,1,1,1}
    }
        }
    }
    
big_silo.base_front_sprite = rro.merge(big_silo.base_front_sprite, {
    filename = "__space-exploration-graphics-5__/graphics/entity/rocket-launch-pad/14-rocket-silo-front.png",
    width = 704,
    height = 448,
    shift = util.by_pixel(1.0, 68.0),
    scale = function(old_scale) return old_scale * 0.9 end
})
big_silo.base_day_sprite =
    {
      filename = "__space-exploration-graphics-5__/graphics/entity/rocket-launch-pad/06-rocket-silo.png",
      dice_y = 3,
      width = 704,
      height = 736,
      shift = util.by_pixel(  2.0, 3.5),
      scale = 0.5*0.9

    }
big_silo.hole_clipping_box = {
     {-2.75, -1.45}, {2.75, 2.25} 
}
big_silo.graphics_set = require("__planet-muluna__.prototypes.entity.big-rocket-silo-crafting-pictures").graphics_set

big_silo.satellite_animation =
    {
      filename = "__space-exploration-graphics-5__/graphics/entity/rocket-launch-pad/15-rocket-silo-turbine.png",
      priority = "medium",
      width = 98,
      height = 36,
      frame_count = 4,
      line_length = 4,
      animation_speed = 0.4,
      shift = util.by_pixel(-102.5, 6.5),
      scale = 0.5*0.9
    }

Muluna.machine_scaling.scale_entity(objects,15/9)
-- Muluna.rro.deep_replace_field(objects,"flags",function(old_flags) 
--     local new_flags=table.deepcopy(old_flags)
--     rro.soft_insert(new_flags,"not-compressed")
--     return new_flags end)

big_silo.rocket_entity=big_rocket.name
big_rocket.cargo_pod_entity=big_pod.name
big_rocket.shadow_slave_entity = rocket_shadow.name

big_silo.module_slots = 8

big_silo.alarm_sound = {filename = "__muluna-graphics__/sound/entity/muluna-big-rocket-silo/big-silo-alarm.ogg",max_volume=2,min_volume=2}
big_silo.quick_alarm_sound = {filename = "__muluna-graphics__/sound/entity/muluna-big-rocket-silo/big-silo-alarm-short.ogg",max_volume=2,min_volume=2}

Muluna:extend{big_silo,big_rocket,big_pod}

table.insert(PlanetsLib.constants.space_platform_hub_receiving_cargo_units,big_pod.name)
