local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ENTITYPATH = BioInd.modRoot .. "/graphics/entities/bio_cannon/"

require "util"

if BI.Settings.Bio_Cannon then

  function preparing_animation()
    return {layers = {{
      priority = "medium",
      width = 341,
      height = 341,
      direction_count = 1, -- folding[1],
      frame_count = 12,  -- folding[2],
      line_length = 6, -- folding[3],
      run_mode = "forward",
      axially_symmetrical = false,
      scale = 1.1261,
      shift = {1.125, -1.625},

      filename = ENTITYPATH .. "bio_cannon.png",
      }}}
  end

  function prepared_animation()
    return {layers = {{
      priority = "medium",
      width = 341,
      height = 341,
      direction_count = 1, -- main [1],
      frame_count = 1, -- -- always 1
      line_length = 1, -- main [3],
      axially_symmetrical = false,
      scale = 1.1261,
      shift = {1.125, -1.625},
      filename = ENTITYPATH .. "bio_cannon_open.png",
      }}}
  end

  --[[
  function attacking_animation()
    return {layers = {{
      priority = "medium",
      width = 341,
      height = 341,
      direction_count = 1, -- main [1],
      frame_count = 12, -- -- can be 2 or 3, when you have attacking animation; 1 for no animated
      line_length = 6, -- main [3],
      run_mode = "forward",
      axially_symmetrical = false,
      scale = 1.1261,
      shift = {1.125, -1.625},
      filename = ENTITYPATH .. "bio_cannon_attack.png",
      }}}
  end
  ]]

  function folding_animation()
    return {layers = {{
      priority = "medium",
      width = 341,
      height = 341,
      direction_count = 1, -- folding[1],
      frame_count = 12, -- folding[2],
      line_length = 6, -- folding[3],
      run_mode = "backward",
      axially_symmetrical = false,
      scale = 1.1261,
      shift = {1.125, -1.625},

      filename = ENTITYPATH .. "bio_cannon.png",
  }}}
  end

  function folded_animation()
    return {layers = {{
      priority = "medium",
      width = 341,
      height = 341,
      direction_count = 1, -- folding[1],
      frame_count = 1, -- idk why, for skipping second sprite
      line_length = 1,
      run_mode = "forward",
      axially_symmetrical = false,
      scale = 1.1261,
      shift = {1.125, -1.625},
      filename = ENTITYPATH .. "bio_cannon.png",
      }}}
  end

  data:extend({
    -- Bio Cannon Artillery Range Overlay
    {
      type = "ammo-turret",
      name = "bi-bio-cannon-area",
      localised_name = {"entity-name.bi-bio-cannon"},
      localised_description = {"entity-description.bi-bio-cannon"},
      icon = ICONPATH .. "biocannon_icon.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "biocannon_icon.png",
          icon_size = 64,
        }
      },
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
      close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
      max_health = 900,
      corpse = "big-remnants",
      dying_explosion = "massive-explosion",
      automated_ammo_count = 10,
      resistances = {},
      collision_box = {{-4.25, -4.25}, {4.25, 4.25}},
      selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
      order = "i[items][Bio_Cannon]",
      inventory_size = 1,
      attack_parameters =
      {
        type = "projectile",
        --~ ammo_category = "artillery-shell",
        ammo_category = "Bio_Cannon_Ammo",
        cooldown = 2,
        range = 90,
        min_range = 20,
        projectile_creation_distance = 1.8,
        action ={}
      },
      folding_speed = 0.08,
      preparing_animation = preparing_animation(),
      prepared_animation = prepared_animation(),
      --attacking_animation = attacking_animation(),
      folding_animation = folding_animation(),
      folded_animation = folded_animation(),
      call_for_help_radius = 40
    },

    -- Bio Cannon Artillery
    {
      type = "ammo-turret",
      name = "bi-bio-cannon",
      icon = ICONPATH .. "biocannon_icon.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "biocannon_icon.png",
          icon_size = 64,
        }
      },
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      -- makes cannon blueprintable
      placeable_by = {item = "bi-bio-cannon-area", count = 1},
      open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
      close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
      minable = {mining_time = 10, result = "bi-bio-cannon-area"},
      max_health = 900,
      corpse = "big-remnants",
      dying_explosion = "massive-explosion",
      automated_ammo_count = 10,
      resistances =
      {
        {
        type = "fire",
        percent = 90
        },
        {
        type = "explosion",
        percent = 30
        },
        {
        type = "impact",
        percent = 30
        }
      },
      collision_box = {{-4.20, -4.20}, {4.20, 4.20}},
      selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
      order = "i[items][Bio_Cannon]",
      inventory_size = 1,
      prepare_range = 90,
      preparing_speed = 0.012,
      attack_parameters =
      {
        type = "projectile",
        --~ ammo_category = "artillery-shell",
        ammo_category = "Bio_Cannon_Ammo",
        cooldown = 2,
        range = 0,
        projectile_creation_distance = 1.8,
        action ={}
      },
      folding_speed = 0.012,

      preparing_animation = preparing_animation(),
      prepared_animation = prepared_animation(),
      --attacking_animation = attacking_animation(),
      folding_animation = folding_animation(),
      folded_animation = folded_animation(),
      call_for_help_radius = 90
    },

    ---- Radar
    {
      type = "radar",
      name = "Bio-Cannon-r",
      localised_name = {"entity-name.bi-bio-cannon"},
      localised_description = {"entity-description.bi-bio-cannon"},
      icon = ICONPATH .. "biocannon_icon.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "biocannon_icon.png",
          icon_size = 64,
        }
      },
      flags = {"not-deconstructable", "not-on-map", "placeable-off-grid", "not-repairable", "not-blueprintable"},
      selectable_in_game = false,
      --minable = {mining_time = 5, result = "bi-bio-cannon-area"},
      max_health = 600,
      corpse = "big-remnants",
      dying_explosion = "massive-explosion",
      resistances = {},
      collision_box = {{-4.0, -4.0}, {4.0, 4.0}},
      selection_box = {{-4.25, -4.25}, {4.25, 4.25}},
      collision_mask = {},
      order = "i[items][Bio_Cannon]",
      energy_per_sector = "22MJ",
      max_distance_of_nearby_sector_revealed = 5,
      max_distance_of_sector_revealed = 5,
      energy_per_nearby_scan = "400kW",
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input"
      },
      energy_usage = "6kW",
      pictures =
      {
        filename = ICONPATH .. "biocannon_icon.png",
        priority = "low",
        width = 1,
        height = 1,
        axially_symmetrical = false,
        apply_projection = false,
        direction_count = 1,
        line_length = 1,
        shift = {0, -0}
      },
    },
  })
end
