if not NE_Enemies then
    NE_Enemies = {}
end
if not NE_Enemies.Settings then
    NE_Enemies.Settings = {}
end

local ENTITYPATH = NE_Common.alt_graphicspath .. "spawner/"
local ICONPATH = NE_Common.iconpath


spawner_corpse_tint = {r=0.92, g=0.54, b=0, a=0.5}



function ne_new_spawner_idle_animation(variation, tint)
    return
      {
        layers =
        {
          {
            filename = ENTITYPATH .. "spawner-idle.png",
            line_length = 8,
            width = 243,
            height = 181,
            frame_count = 8,
            animation_speed = 0.18,
            direction_count = 1,
            run_mode = "forward-then-backward",
            shift = {0.140625 - 0.65, -0.234375},
            y = variation * 181
          },
          {
            filename = ENTITYPATH .. "spawner-idle-mask.png",
            flags = { "mask" },
            width = 166,
            height = 148,
            frame_count = 8,
            animation_speed = 0.18,
            run_mode = "forward-then-backward",
            shift = {-0.34375 - 0.65, -0.375},
            line_length = 8,
            tint = tint,
            y = variation * 148
          }
        }
      }
    end
    


function ne_new_spawner_die_animation(variation, tint)
    return
      {
        layers =
        {
          {
            width = 255,
            height = 184,
            frame_count = 20,
            direction_count = 1,
            shift = {-0.015625 - 0.65, -0.28125},
            stripes =
            {
             {
              filename = ENTITYPATH .. "spawner-die-01.png",
              width_in_frames = 7,
              height_in_frames = 4,
              y = variation * 184
             },
             {
              filename = ENTITYPATH .. "spawner-die-02.png",
              width_in_frames = 7,
              height_in_frames = 4,
              y = variation * 184
             },
             {
              filename = ENTITYPATH .. "spawner-die-03.png",
              width_in_frames = 6,
              height_in_frames = 4,
              y = variation * 184
             }
            }
          },
          {
            flags = { "mask" },
            width = 166,
            height = 148,
            frame_count = 20,
            direction_count = 1,
            shift = {-0.34375 - 0.65, -0.375},
            tint = tint,
            stripes =
            {
             {
              filename = ENTITYPATH .. "spawner-die-mask-01.png",
              width_in_frames = 10,
              height_in_frames = 4,
              y = variation * 148
             },
             {
              filename = ENTITYPATH .. "spawner-die-mask-02.png",
              width_in_frames = 10,
              height_in_frames = 4,
              y = variation * 148
             }
            }
          }
        }
      }
    end
    



    data:extend({
    {
        type = "corpse",
        name = "ne-new-spawner-corpse",
        flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
        icon = ICONPATH .."biter-spawner-corpse.png",
        icon_size = 32,
        collision_box = {{-2, -2}, {2, 2}},
        selection_box = {{-2, -2}, {2, 2}},
        selectable_in_game = false,
        dying_speed = 0.04,
        time_before_removed = 15 * 60 * 60,
        subgroup="corpses",
        order = "c[corpse]-b[biter-spawner]",
        final_render_layer = "remnants",
        animation =
        {
            ne_new_spawner_die_animation(0, spawner_corpse_tint),
            ne_new_spawner_die_animation(1, spawner_corpse_tint),
            ne_new_spawner_die_animation(2, spawner_corpse_tint),
            ne_new_spawner_die_animation(3, spawner_corpse_tint)
          }

      }
})