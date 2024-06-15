
local hit_effects = require ("__base__/prototypes/entity/hit-effects")
local sounds = require("__base__/prototypes/entity/sounds")
local text_animation = settings.startup["hs-opt-text-animation"].value

if mods['shield-projector'] then 
data:extend({
{
	type = "animation",
	name = "hs_hologram_animated",
	filename = "__shield-projector__/graphics/entity/shield-projector/hr/shield/wall-south.png",
    scale = 0.5,
    animation_speed = 0.3,
    frame_count = 24,
    width = 2816/4,
    height = 3456/6,
    shift = {0,0},
	line_length = 4
},
})
end


local wrapper_flow_style = "compilatron_speech_bubble_wrapper"
if text_animation == 'No animation' then
	wrapper_flow_style = "hs_speech_bubble_wrapper"
	data.raw["gui-style"]["default"][wrapper_flow_style] ={type = "flow_style",effect = nil}
	end

local fade_in_out_ticks = data.raw['speech-bubble'].fade_in_out_ticks
if text_animation == 'Fast animation' then fade_in_out_ticks=5 end

data:extend({

{
    type = "speech-bubble",
    name = "hs-speech-bubble",
    style = "compilatron_speech_bubble",
    wrapper_flow_style = wrapper_flow_style,
    fade_in_out_ticks = fade_in_out_ticks,
    flags = {"not-on-map", "placeable-off-grid"}
},



   {
      type = "sprite",
      name = "hs_hologram",
      filename = path.."graphics/hologram.png",
      priority = "extra-high",
      width = 200,
      height = 186,
   },



  {
    type = "container", 
	--logistic_mode = "passive-provider",
    name = "hs_holo_sign",
    icon = path.."graphics/hologram_ico.png",
    icon_size = 64, --icon_mipmaps = 4,
    flags = {"placeable-player", "player-creation", "not-rotatable", "hide-alt-info"},  --"not-blueprintable"
    minable = {mining_time = 0.2, result = "hs_holo_sign"},
    max_health = 100,
    corpse = "lamp-remnants",
    dying_explosion = "lamp-explosion",
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    damaged_trigger_effect = hit_effects.entity(),
    vehicle_impact_sound = sounds.generic_impact,
    inventory_size = 0,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    resistances =
    {
      {
        type = "fire",
        percent = 80
      },
      {
        type = "impact",
        percent = 30
      }
    },	
    --circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
	circuit_wire_connection_point = data.raw.lamp['small-lamp'].circuit_wire_connection_point,
    circuit_connector_sprites = data.raw.lamp['small-lamp'].circuit_connector_sprites,
    circuit_wire_max_distance = data.raw.lamp['small-lamp'].circuit_wire_max_distance,
    picture =
    {
      layers =
      {
        {
          filename = path.."graphics/holobase.png",
          priority = "extra-high",
          width = 42,
          height = 36,
          frame_count = 1,
          axially_symmetrical = false,
          direction_count = 1,
          shift = util.by_pixel(0,3),		  
          hr_version =
          {
            filename = path.."graphics/hr-holobase.png",
            priority = "high",
            width = 83,
            height = 70,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            shift = util.by_pixel(0.25,3),
            scale = 0.5
          }
        },
      }
    },
  },


  {
    type = "item",
    name = "hs_holo_sign",
    icon = path.."graphics/hologram_ico.png",
    icon_size = 64, --icon_mipmaps = 4,
    subgroup = "circuit-network",
    order = "a[items]-h[holo_sign]",
    place_result = "hs_holo_sign",
    stack_size= 100
  },

  {
    type = "recipe",
    name = "hs_holo_sign",
	energy_required = 2,
	enabled = true,
    ingredients = {{"iron-plate", 4}, {"electronic-circuit", 1}, {"small-lamp", 1}},
    result = "hs_holo_sign"
  },
})
