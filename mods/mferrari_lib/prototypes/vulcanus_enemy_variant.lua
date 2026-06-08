
if mods["space-age"] then
local sounds = require("__base__.prototypes.entity.sounds")

local rock_name = mf_demolisher_corpse_rock_name or "huge-rock"

local dying_particles = {
          {
            type = "create-particle",
            repeat_count = 7,
            repeat_count_deviation = 0,
            probability = 1,
            affects_target = false,
            show_in_tooltip = false,
            particle_name = "blood-particle",
            offsets = {
              { 0.02344, -0.6016 }
            },
            offset_deviation = {
              left_top = { -0.5, -0.5 },
              right_bottom = { 0.5, 0.5 }
            },
            initial_height = 0.2,
            initial_height_deviation = 0.05,
            initial_vertical_speed = 0.062,
            initial_vertical_speed_deviation = 0.01,
            speed_from_center = 0.1,
            speed_from_center_deviation = 0.047,
            frame_speed = 1,
            frame_speed_deviation = 0,
            tail_length = 25,
            tail_length_deviation = 0,
            tail_width = 1,
            rotate_offsets = false
          },
          {
            type = "create-particle",
            repeat_count = 11,
            repeat_count_deviation = 0,
            probability = 1,
            affects_target = false,
            show_in_tooltip = false,
            particle_name = "blood-particle-carpet",
            offsets = {
              { 0, -0.3594 }
            },
            offset_deviation = {
              left_top = { -1, -1 },
              right_bottom = { 1, 1 }
            },
            initial_height = 0.1,
            initial_height_deviation = 0.05,
            initial_vertical_speed = 0.09,
            initial_vertical_speed_deviation = 0.05,
            speed_from_center = 0.04,
            speed_from_center_deviation = 0,
            frame_speed = 1,
            frame_speed_deviation = 0,
            tail_length = 21,
            tail_length_deviation = 3,
            tail_width = 1,
            rotate_offsets = false
          },
          {
            type = "create-particle",
            repeat_count = 13,
            repeat_count_deviation = 1,
            probability = 1,
            affects_target = false,
            show_in_tooltip = false,
            particle_name = "blood-particle-carpet",
            offsets = {
              { 0, 0 }
            },
            offset_deviation = {
              left_top = { -1, -1 },
              right_bottom = { 1, 1 }
            },
            initial_height = 0.1,
            initial_height_deviation = 0.01,
            initial_vertical_speed = 0.018,
            initial_vertical_speed_deviation = 0.005,
            speed_from_center = 0.19,
            speed_from_center_deviation = 0.041,
            frame_speed = 1,
            frame_speed_deviation = 0,
            tail_length = 11,
            tail_length_deviation = 7,
            tail_width = 1,
            rotate_offsets = false
          },
          {
            type = "create-particle",
            repeat_count = 20,
            repeat_count_deviation = 5,
            probability = 1,
            affects_target = false,
            show_in_tooltip = false,
            particle_name = "internal-fluids-particle",
            offsets = {
              { 0.0, -0.3125 }
            },
            offset_deviation = {
              left_top = { -1, -1 },
              right_bottom = { 1, 1 }
            },
            initial_height = 0.3,
            initial_height_deviation = 0.5,
            initial_vertical_speed = 0.055,
            initial_vertical_speed_deviation = 0.003,
            speed_from_center = 0.05,
            speed_from_center_deviation = 0.042,
            frame_speed = 1,
            frame_speed_deviation = 0,
            tail_length = 10,
            tail_length_deviation = 12,
            tail_width = 1,
            rotate_offsets = false
          },

          {
            type = "create-particle",
            repeat_count = 4,
            repeat_count_deviation = 2,
            probability = 1,
            affects_target = false,
            show_in_tooltip = false,
            particle_name = "guts-entrails-particle-small-medium",
            offsets = {
              { 0.0, -0.3281 }
            },
            offset_deviation = {
              left_top = { -0.5, -0.5 },
              right_bottom = { 0.5, 0.5 }
            },
            initial_height = 1,
            initial_height_deviation = 0.52,
            initial_vertical_speed = 0.078,
            initial_vertical_speed_deviation = 0.05,
            speed_from_center = 0.07,
            speed_from_center_deviation = 0,
            frame_speed = 1,
            frame_speed_deviation = 0,
            rotate_offsets = false
          },
          {
            type = "create-particle",
            repeat_count = 4,
            repeat_count_deviation = 2,
            probability = 1,
            affects_target = false,
            show_in_tooltip = false,
            particle_name = "guts-entrails-particle-big",
            offsets = {
              { -0.01563, -0.3438 }
            },
            offset_deviation = {
              left_top = { -0.5, -0.5 },
              right_bottom = { 0.5, 0.5 }
            },
            initial_height = 1,
            initial_height_deviation = 0.52,
            initial_vertical_speed = 0.078,
            initial_vertical_speed_deviation = 0.05,
            speed_from_center = 0.07,
            speed_from_center_deviation = 0,
            frame_speed = 1,
            frame_speed_deviation = 0,
            rotate_offsets = false
          },
          {
            type = "play-sound",
            sound = sounds.spawner_gore
          }
		}


function change_demo_stone(effect)
for k,e in pairs(effect.effect) do
	if string.find(e.particle_name,"vulcanus") then 
		e.particle_name = "huge-rock-"..string.sub(e.particle_name, 10)
		e.repeat_count=math.ceil(e.repeat_count/4)
		end
	end
end

function create_mf_nauvis_demolisher(base_name)
local demolisher  = table.deepcopy(data.raw["segmented-unit"][base_name])
demolisher.localised_name = {"entity-name."..demolisher.name}
demolisher.name="mf_" ..demolisher.name
-- max_health = health,
--resistances = demolisher_resistances,
demolisher.healing_per_tick = 0.01
--territory_radius = 4
demolisher.update_effects_while_enraged=nil
demolisher.revenge_attack_parameters=nil

change_demo_stone(demolisher.update_effects[9])
change_demo_stone(demolisher.update_effects[10])


local remove_effect = {8,4,3,2,1}
for _,k in pairs(remove_effect) do table.remove(demolisher.update_effects,k) end
local remove_effect = {8,7,6,5,4,3}
for _,k in pairs(remove_effect) do table.remove(demolisher.dying_trigger_effect,k) end
--add blood 
for _,b in pairs(dying_particles) do table.insert(demolisher.dying_trigger_effect,b) end
demolisher.dying_trigger_effect[1] = {type = "create-entity",entity_name = rock_name}

--segments
local remove_effect = {8,7,6,5,4,3}
for k,segment in pairs(demolisher.segment_engine.segments) do
	local name = segment.segment
	local raw = table.deepcopy( data.raw.segment[name])
	name="mf_" .. name
	segment.segment=name
	raw.name=name
	if raw.update_effects then 
		change_demo_stone(raw.update_effects[2])
		table.remove(raw.update_effects,1) 
		end
	if raw.dying_trigger_effect then 
		for _,b in pairs(dying_particles) do table.insert(raw.dying_trigger_effect,b) end
		raw.dying_trigger_effect[1]={type = "create-entity",entity_name = rock_name}
		for _,k in pairs(remove_effect) do table.remove(raw.dying_trigger_effect,k) end
		end
	data:extend({raw})
	end

data:extend({demolisher})
end



create_mf_nauvis_demolisher("small-demolisher")
create_mf_nauvis_demolisher("medium-demolisher")
create_mf_nauvis_demolisher("big-demolisher")
end