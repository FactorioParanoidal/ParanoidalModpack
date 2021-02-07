local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

require ("util")


--- Bio Garden
data:extend({
  {
    type = "assembling-machine",
    name = "bi-bio-garden",
    icon = ICONPATH .. "bio_garden_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_garden_icon.png",
        icon_size = 64,
      }
    },
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-bio-garden"},
    fast_replaceable_group = "bi-bio-garden",
    max_health = 150,
    corpse = "medium-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fluid_boxes = {
      {
        production_type = "input",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type = "input", position = {0, -2} }}
      },
      off_when_no_fluid_recipe = true
    },
    animation = {
      filename = "__Bio_Industries__/graphics/entities/biogarden/bio_garden_x.png",
      width = 160,
      height = 160,
      frame_count = 12,
      line_length = 4,
      animation_speed = 0.025,
      shift = {0.45, 0}
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound = {
      sound = { { filename = "__Bio_Industries__/sound/rainforest_ambience.ogg", volume = 0.8 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"clean-air"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 1.0,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -45, -- Negative value: pollution is absorbed!
    },
    energy_usage = "200kW",
    ingredient_count = 1,
    -- Changed for 0.18.34/1.1.4 -- Modules don't make sense for the gardens!
    -- (Efficiency modules are also meant to reduce pollution, but as the base value
    -- is negative, the resulting value is greater than the base value! )
    module_specification = {
      module_slots = 1
    },
    --~ module_specification = {
      --~ module_slots = 0
    --~ },
    -- Changed for 0.18.34/1.1.4 -- We need to use an empty table here, so the gardens
    -- won't be affected by beacons!
    allowed_effects = {"consumption", "speed"},
    --~ allowed_effects = {},
  },
})


--~ -- We only need the hidden pole if the "Easy Gardens" setting is active!
--~ if BI.Settings.BI_Easy_Bio_Gardens then
  --~ local hidden_pole = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"])
  --~ hidden_pole.name = "bi-bio-garden-hidden-pole"
  --~ hidden_pole.icon = "__base__/graphics/icons/small-electric-pole.png"
  --~ hidden_pole.icon_size = 64
  --~ hidden_pole.icons = {
    --~ {
      --~ icon = "__base__/graphics/icons/small-electric-pole.png",
      --~ icon_size = 64,
    --~ }
  --~ }
  --~ hidden_pole.flags = {
    --~ "not-deconstructable",
    --~ "not-on-map",
    --~ "placeable-off-grid",
    --~ "not-repairable",
    --~ "not-blueprintable",
  --~ }
  --~ hidden_pole.selectable_in_game = false
  --~ hidden_pole.draw_copper_wires = BioInd.is_debug
  --~ hidden_pole.max_health = 1
  --~ hidden_pole.minable = nil
  --~ hidden_pole.collision_mask = {}
  --~ hidden_pole.collision_box = {{-0, -0}, {0, 0}}
  --~ hidden_pole.selection_box = {{0, 0}, {0, 0}}
  --~ hidden_pole.maximum_wire_distance = 4
  --~ hidden_pole.supply_area_distance = 1
  --~ hidden_pole.pictures = BioInd.is_debug and hidden_pole.pictures or {
    --~ filename = ICONPATH .. "empty.png",
    --~ priority = "low",
    --~ width = 1,
    --~ height = 1,
    --~ frame_count = 1,
    --~ axially_symmetrical = false,
    --~ direction_count = 1,
  --~ }
  --~ hidden_pole.connection_points = BioInd.is_debug and hidden_pole.connection_points or {
    --~ {
      --~ shadow = {},
      --~ wire = { copper_wire_tweak = {-0, -0} }
    --~ }
  --~ }
  --~ hidden_pole.radius_visualisation_picture = BioInd.is_debug and
                                              --~ hidden_pole.radius_visualisation_picture or {
                                                  --~ filename = ICONPATH .. "empty.png",
                                                  --~ width = 1,
                                                  --~ height = 1,
                                                  --~ priority = "low"
                                                --~ }

  --~ data:extend({hidden_pole})
--~ end
