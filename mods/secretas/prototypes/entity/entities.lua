require ("sound-util")
require ("circuit-connector-sprites")
require ("util")
require ("__space-age__.prototypes.entity.circuit-network")
require ("__space-age__.prototypes.entity.space-platform-hub-cockpit")

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local space_age_sounds = require ("__space-age__.prototypes.entity.sounds")
local meld = require("meld")
--local simulations = require("__space-age__.prototypes.factoriopedia-simulations")
--local procession_graphic_catalogue_types = require("__base__/prototypes/planet/procession-graphic-catalogue-types")
--local biochamber_pictures = require("__space-age__.prototypes.entity.biochamber-pictures")

function make_rotated_animation_variations_from_sheet(variation_count, sheet) --makes remnants work with more than 1 variation
  local result = {}

  local function set_y_offset(variation, i)
    local frame_count = variation.frame_count or 1
    local line_length = variation.line_length or frame_count
    if (line_length < 1) then
      line_length = frame_count
    end

    local height_in_frames = math.floor((frame_count * variation.direction_count + line_length - 1) / line_length)
    -- if (height_in_frames ~= 1) then
    --   log("maybe broken sheet: h=" .. height_in_frames .. ", vc=" .. variation_count .. ", " .. variation.filename)
    -- end
    variation.y = variation.height * (i - 1) * height_in_frames
  end

  for i = 1,variation_count do
    local variation = util.table.deepcopy(sheet)

    if variation.layers then
      for _, layer in pairs(variation.layers) do
        set_y_offset(layer, i)
      end
    else
      set_y_offset(variation, i)
    end

    table.insert(result, variation)
  end
 return result
end

function make_heat_pipe_pictures(path, name_prefix, data, draw_as_glow)
  local all_pictures = {}
  local func = draw_as_glow and apply_heat_pipe_glow or function(t) return t end
  for key, t in pairs(data) do
    if t.empty then
      all_pictures[key] = { priority = "extra-high", filename = "__core__/graphics/empty.png", width = 1, height = 1 }
    else
      local tile_pictures = {}
      for i = 1, (t.variations or 1) do
        local sprite = func
        {
          priority = "extra-high",
          filename = path .. name_prefix .. "-" .. (t.name or string.gsub(key, "_", "-")) .. (t.ommit_number and ".png" or ("-" .. tostring(i) .. ".png")),
          width = (t.width or 32) * 2,
          height = (t.height or 32) * 2,
          scale = 0.5,
          shift = t.shift
        }
        table.insert(tile_pictures, sprite)
      end
      all_pictures[key] = tile_pictures
    end
  end
  return all_pictures
end

data:extend({ 
    {
        type = "inserter",
        name = "hyper-inserter",
        icon = "__secretas__/graphics/icons/hyper-inserter.png",
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = { mining_time = 0.1, result = "hyper-inserter" },
        max_health = 170,
        corpse = "hyper-inserter-remnants",
        dying_explosion = "fast-inserter-explosion",
        max_belt_stack_size = 5,
        stack_size_bonus = 8,
        bulk = true,
        resistances =
        {
          {
            type = "fire",
            percent = 90
          }
        },
        collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
        selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
        damaged_trigger_effect = hit_effects.entity(),
        pickup_position = {0, -1},
        insert_position = {0, 1.2},
        energy_per_movement = "70kJ",
        energy_per_rotation = "70kJ",
        heating_energy = "0kW",
        energy_source =
        {
          type = "electric",
          usage_priority = "secondary-input",
          drain = "0.5kW"
        },
        extension_speed = 0.2,
        rotation_speed = 0.06,
        filter_count = 5,
        icon_draw_specification = {scale = 0.5},
        fast_replaceable_group = "inserter",
        --next_upgrade = "bulk-inserter",
        impact_category = "metal",
        open_sound = sounds.inserter_open,
        close_sound = sounds.inserter_close,
        working_sound = sounds.inserter_fast,
        hand_base_picture =
        {
          filename = "__secretas__/graphics/entity/hyper-inserter/hyper-inserter-hand-base.png",
          priority = "extra-high",
          width = 32,
          height = 136,
          scale = 0.25
        },
        hand_closed_picture =
        {
          filename = "__secretas__/graphics/entity/hyper-inserter/hyper-inserter-hand-closed.png",
          priority = "extra-high",
          width = 72,
          height = 164,
          scale = 0.25
        },
        hand_open_picture =
        {
          filename = "__secretas__/graphics/entity/hyper-inserter/hyper-inserter-hand-open.png",
          priority = "extra-high",
          width = 72,
          height = 164,
          scale = 0.25
        },
        hand_base_shadow =
        {
          filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png",
          priority = "extra-high",
          width = 32,
          height = 132,
          scale = 0.25
        },
        hand_closed_shadow =
        {
          filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-closed-shadow.png",
          priority = "extra-high",
          width = 72,
          height = 164,
          scale = 0.25
        },
        hand_open_shadow =
        {
          filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-open-shadow.png",
          priority = "extra-high",
          width = 72,
          height = 164,
          scale = 0.25
        },
        platform_picture =
        {
          sheet =
          {
            filename = "__secretas__/graphics/entity/hyper-inserter/hyper-inserter-platform.png",
            priority = "extra-high",
            width = 105,
            height = 79,
            shift = util.by_pixel(1.5, 7.5-1),
            scale = 0.5
          }
        },
        platform_frozen =
        {
          sheet =
          {
            filename = "__space-age__/graphics/entity/frozen/inserter/inserter-platform.png",
            priority = "extra-high",
            width = 105,
            height = 79,
            shift = util.by_pixel(1.5, 7.5-1),
            scale = 0.5
          }
        },
        hand_base_frozen =
        {
          filename = "__space-age__/graphics/entity/frozen/inserter/inserter-hand.png",
          priority = "extra-high",
          x = 130 * 4,
          width = 130,
          height = 136,
          scale = 0.25
        },
        hand_closed_frozen =
        {
        filename = "__space-age__/graphics/entity/frozen/inserter/inserter-hand.png",
          priority = "extra-high",
          x = 250 + 130,
          width = 130,
          height = 164,
          scale = 0.25
        },
        hand_open_frozen =
        {
        filename = "__space-age__/graphics/entity/frozen/inserter/inserter-hand.png",
          priority = "extra-high",
          width = 130,
          height = 164,
          scale = 0.25
        },


        circuit_connector = circuit_connector_definitions["inserter"],
        circuit_wire_max_distance = inserter_circuit_wire_max_distance,
        default_stack_control_input_signal = inserter_default_stack_control_input_signal
    },
    {
      type = "furnace",
      name = "steam-recycler",
      icon = "__secretas__/graphics/icons/steam-recycler.png",
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      fast_transfer_modules_into_module_slots_only = true,
      minable = {mining_time = 0.2, result = "steam-recycler"},
      max_health = 300,
      fast_replaceable_group = "recycler",
      vector_to_place_result = {-0.5, -2.3},
      dying_explosion = "recycler-explosion",
      corpse = "steam-recycler-remnants",
      impact_category = "metal",
      working_sound =
      {
        sound = { filename = "__recycler__/sound/recycler/recycler-loop.ogg", volume = 0.7 },
        sound_accents =
        {
          { sound = { variations = sound_variations("__recycler__/sound/recycler/recycler-jaw-move", 5, 0.45 )}, frame = 14, audible_distance_modifier = 0.2 },
          { sound = { variations = sound_variations("__recycler__/sound/recycler/recycler-vox", 5, 0.2 )}, frame = 20, audible_distance_modifier = 0.3 },
          { sound = { variations = sound_variations("__recycler__/sound/recycler/recycler-mechanic", 3, 0.3 )}, frame = 45, audible_distance_modifier = 0.3 },
          { sound = { variations = sound_variations("__recycler__/sound/recycler/recycler-jaw-move", 5, 0.45 )}, frame = 60, audible_distance_modifier = 0.2 },
          { sound = { variations = sound_variations("__recycler__/sound/recycler/recycler-trash", 5, 0.6 )}, frame = 61, audible_distance_modifier = 0.3 },
          { sound = { variations = sound_variations("__recycler__/sound/recycler/recycler-jaw-shut", 6, 0.3 )}, frame = 63, audible_distance_modifier = 0.6 },
        },
        max_sounds_per_type = 2,
        fade_in_ticks = 4,
        fade_out_ticks = 20
      },
      resistances =
      {
        {
          type = "fire",
          percent = 80
        }
      },
      collision_box = {{-0.7, -1.7}, {0.7, 1.7}},
      selection_box = {{-0.9, -1.85}, {0.9, 1.85}},
      crafting_categories = {"recycling", "hand-crafting"},
      result_inventory_size = 40,
      energy_usage = "600kW",
      crafting_speed = 1.3,
      source_inventory_size = 1,
      custom_input_slot_tooltip_key = "recycler-input-slot-tooltip",
      heating_energy = "0W",
      energy_source =
      {
        type = "fluid",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 8 },
        burns_fluid = false,
        fluid_box = 
        {
          production_type = "input",
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections =
          {
              {
              flow_direction="output", 
              direction = defines.direction.west,
              position = {-0.5, 0.5}, 
              },
              {
                flow_direction="input", 
                direction = defines.direction.east,
                position = {0.5, 0.5},
              },
              {
                flow_direction="input", 
                direction = defines.direction.west,
                position = {-0.5, -0.5}, 
              },
              {
                flow_direction="output", 
                direction = defines.direction.east,
                position = {0.5, -0.5},
              },

          },
        },
        scale_fluid_usage = true

      },
      module_slots = 5,
      icon_draw_specification = {shift = {0, -0.55}},
      icons_positioning =
      {
        --{inventory_index = defines.inventory.furnace_modules, shift = {0, 0.2}} --doesn't exist in 2.1
        {inventory_index = defines.inventory.crafter_modules, shift = {0, 0.2}} -- update for 2.1
      },
      allowed_effects = {"consumption", "speed", "pollution", "quality"},
      perceived_performance = { minimum = 0.0, performance_to_activity_rate = 2.0, maximum = 4 },
      graphics_set          = require("__secretas__.prototypes.entity.recycler-pictures").graphics_set,
      graphics_set_flipped  = require("__secretas__.prototypes.entity.recycler-pictures").graphics_set_flipped,
      cant_insert_at_source_message_key = "inventory-restriction.cant-be-recycled"
    },
    {
      type = "corpse",
      name = "gold-heat-pipe-remnants",
      icon = "__secretas__/graphics/icons/gold-heat-pipe.png",
      flags = {"placeable-neutral", "not-on-map"},
      hidden_in_factoriopedia = true,
      subgroup = "energy-remnants",
      order = "a-f-a",
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      tile_width = 1,
      tile_height = 1,
      selectable_in_game = false,
      time_before_removed = 60 * 60 * 15, -- 15 minutes
      expires = false,
      final_render_layer = "remnants",
      remove_on_tile_placement = false,
      animation = make_rotated_animation_variations_from_sheet (6,
      {
        filename = "__secretas__/graphics/entity/heat-pipe/remnants/heat-pipe-remnants.png",
        line_length = 1,
        width = 122,
        height = 100,
        direction_count = 2,
        shift = util.by_pixel(0.5, -1.5),
        scale = 0.5
      })
    },
    {
      type = "heat-pipe",
      name = "gold-heat-pipe",
      icon = "__secretas__/graphics/icons/gold-heat-pipe.png",
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 0.1, result = "gold-heat-pipe"},
      fast_replaceable_group = "heat-pipe",
      max_health = 200,
      corpse = "gold-heat-pipe-remnants",
      dying_explosion = "heat-pipe-explosion",
      random_corpse_variation = true,
      heating_radius = 2,
      working_sound =
      {
        sound = { filename = "__base__/sound/heat-pipe.ogg", volume = 0.4 },
        match_volume_to_activity = true,
        max_sounds_per_prototype = 3,
        fade_in_ticks = 4,
        fade_out_ticks = 20
      },
      impact_category = "metal",
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
      collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      damaged_trigger_effect = hit_effects.entity(),
      heat_buffer =
      {
        max_temperature = 1000,
        specific_heat = "0.6MJ",
        max_transfer = "0.9GW",
        minimum_glow_temperature = 350,
        connections =
        {
          {
            position = {0, 0},
            direction = defines.direction.north
          },
          {
            position = {0, 0},
            direction = defines.direction.east
          },
          {
            position = {0, 0},
            direction = defines.direction.south
          },
          {
            position = {0, 0},
            direction = defines.direction.west
          }
        }
      },
  
      connection_sprites = make_heat_pipe_pictures("__secretas__/graphics/entity/heat-pipe/", "heat-pipe",
      {
        single = { name = "straight-vertical-single", ommit_number = true },
        straight_vertical = { variations = 6 },
        straight_horizontal = { variations = 6 },
        corner_right_up = { name = "corner-up-right", variations = 6 },
        corner_left_up = { name = "corner-up-left", variations = 6 },
        corner_right_down = { name = "corner-down-right", variations = 6 },
        corner_left_down = { name = "corner-down-left", variations = 6 },
        t_up = {},
        t_down = {},
        t_right = {},
        t_left = {},
        cross = { name = "t" },
        ending_up = {},
        ending_down = {},
        ending_right = {},
        ending_left = {}
      }),
  
      heat_glow_sprites = make_heat_pipe_pictures("__secretas__/graphics/entity/heat-pipe/", "heated",
      {
        single = { empty = true },
        straight_vertical = { variations = 6 },
        straight_horizontal = { variations = 6 },
        corner_right_up = { name = "corner-up-right", variations = 6 },
        corner_left_up = { name = "corner-up-left", variations = 6 },
        corner_right_down = { name = "corner-down-right", variations = 6 },
        corner_left_down = { name = "corner-down-left", variations = 6 },
        t_up = {},
        t_down = {},
        t_right = {},
        t_left = {},
        cross = { name = "t" },
        ending_up = {},
        ending_down = {},
        ending_right = {},
        ending_left = {}
      }, true)
    },
    {
      type = "corpse",
      name = "gold-railgun-turret-remnants",
      icon = "__secretas__/graphics/icons/gold-railgun-turret.png",
      flags = {"placeable-neutral", "not-on-map"},
      hidden_in_factoriopedia = true,
      subgroup = "defensive-structure-remnants",
      order = "a-c-a",
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      tile_width = 3,
      tile_height = 3,
      selectable_in_game = false,
      time_before_removed = 60 * 60 * 15, -- 15 minutes
      expires = false,
      final_render_layer = "remnants",
      remove_on_tile_placement = false,
      animation = make_rotated_animation_variations_from_sheet (3,
      {
        layers =
        {
          util.sprite_load("__secretas__/graphics/entity/railgun-turret/railgun-turret-remnants",
          {
            line_length = 1,
            direction_count = 1,
            shift = util.by_pixel(0, 0),
            scale = 0.5
          }),
          util.sprite_load("__space-age__/graphics/entity/railgun-turret/remnants/railgun-turret-remnants-mask",
          {
            priority = "low",
            line_length = 1,
            apply_runtime_tint = true,
            direction_count = 1,
            shift = util.by_pixel(0, 0),
            scale = 0.5
          })
        }
      })
    },
    {
      type = "ammo-turret",
      name = "gold-railgun-turret",
      icon = "__secretas__/graphics/icons/gold-railgun-turret.png",
      flags = {"placeable-player", "player-creation", "building-direction-8-way"},
      minable = {mining_time = 0.5, result = "gold-railgun-turret"},
      max_health = 4000,
      corpse = "gold-railgun-turret-remnants",
      dying_explosion = "gun-turret-explosion",
      collision_box = {{-1.41, -1.9 }, {1.41, 2.1}},
      selection_box = {{-1.5, -2.5 }, {1.5, 2.5}},
      energy_source =
      {
        type = "electric",
        buffer_capacity = "21MJ",
        input_flow_limit = "7MW",
        usage_priority = "primary-input"
      },
      energy_per_shot = "10MJ",
      tile_height = 5,
      turret_base_has_direction = true,
      allow_turning_when_starting_attack = true,
      prepare_with_no_ammo = false,
      damaged_trigger_effect = hit_effects.entity(),
      heating_energy = "65kW",
      rotation_speed = 0.003,
      preparing_speed = 0.03,
      preparing_sound = space_age_sounds.railgun_turret_activate,
      folding_sound = space_age_sounds.railgun_turret_deactivate,
      rotating_sound = space_age_sounds.railgun_turret_rotate,
      automated_ammo_count = 21,
      inventory_size = 1,
      folding_speed = 0.035,
      attacking_speed = 0.32,
      starting_attack_speed = 0.015,
      ending_attack_speed = 0.04,
      alert_when_attacking = true,
      can_retarget_while_starting_attack = true,
      circuit_connector = circuit_connector_definitions["railgun-turret"],
      circuit_wire_max_distance = default_circuit_wire_max_distance,
      open_sound = sounds.turret_open,
      close_sound = sounds.turret_close,
      graphics_set =
      {
        base_visualisation =
        {
          animation = require("__secretas__.prototypes.entity.railgun-turret-pictures").base_picture
        }
      },
      preparing_animation = require("__secretas__.prototypes.entity.railgun-turret-pictures").neutral_animation,
      prepared_animation = require("__secretas__.prototypes.entity.railgun-turret-pictures").aiming_animation,
      starting_attack_animation = require("__secretas__.prototypes.entity.railgun-turret-pictures").warmup_animation,
      attacking_animation = require("__secretas__.prototypes.entity.railgun-turret-pictures").shooting_animation,
      ending_attack_animation = require("__secretas__.prototypes.entity.railgun-turret-pictures").cooldown_animation,
      folding_animation = require("__secretas__.prototypes.entity.railgun-turret-pictures").neutral_animation,
      folded_animation = require("__secretas__.prototypes.entity.railgun-turret-pictures").neutral_animation,
      resource_indicator_animation = require("__secretas__.prototypes.entity.railgun-turret-pictures").resource_indicator_animation,
      special_effect =
      {
        type = "mask-by-circle",
        center =
        {
          default = {0, 0},
          south = {0.06, -0.65},
          south_east = {0.33, -1.06},
          south_west = {-0.27, -0.87},
          north = {-0.06, -1.22},
          north_east = {0.22, -1.51},
          north_west = {-0.22, -1.34},
          west = {-0.33, -1.1},
          east = {0.45, -1.17}
        },
        min_radius = 0,
        max_radius = 2.00,
        falloff = 0.25,
        attacking_min_radius = 0,  -- negative values mask out inside of the circle (positive values mask out outside)
        attacking_max_radius = -2.00,
        attacking_falloff = 0.75,
      },
  
      attack_parameters =
      {
        type = "projectile",
        ammo_category = "railgun",--railgun ammo prototype details the damage.
        health_penalty = -1,
        cooldown = 120,
        projectile_creation_distance = 3.6,
        projectile_center = {0, 0},
        apply_projection_to_projectile_creation_position = false,
        shell_particle =
        {
          name = "railgun-shell-particle",
          direction_deviation = 0.1,
          speed = 0.1,
          speed_deviation = 0.03,
          center = {0, 0},
          creation_distance = -6,
          starting_frame_speed = 0.2,
          starting_frame_speed_deviation = 0.1
        },
        min_range = 1.5,
        range = 30,
        turn_range = 0.20,
        sound = space_age_sounds.railgun_turret_gunshot,
        true_collinear_ejection = true
      },
  
      call_for_help_radius = 40,
      water_reflection =
      {
        pictures =
        {
          filename = "__base__/graphics/entity/gun-turret/gun-turret-reflection.png",
          priority = "extra-high",
          width = 20,
          height = 32,
          shift = util.by_pixel(0, 40),
          variation_count = 1,
          scale = 5
        },
        rotate = false,
        orientation_to_variation = false
      }
    },
})