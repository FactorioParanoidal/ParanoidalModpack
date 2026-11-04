local cargo = data.raw["cargo-wagon"].yir_us_cargo
local wagon = table.deepcopy(data.raw["fluid-wagon"]["fluid-wagon"])
wagon.name = "yir_us_fluid"
wagon.icon = "__JunkTrain3__/graphics/train/t0/usfw_icon.png"
wagon.icons = nil
wagon.icon_size = 64
wagon.minable = {mining_time = 1, result = "ScrapFluidTrailer"}
wagon.capacity = 5000
wagon.tank_count = 1
wagon.quality_affects_capacity = false
for _, key in ipairs({
  "flags", "max_health", "corpse", "dying_explosion", "collision_box", "selection_box",
  "vertical_selection_shift", "weight", "max_speed", "braking_force", "friction_force",
  "air_resistance", "connection_distance", "joint_distance", "energy_per_hit_point",
  "tie_distance", "resistances", "wheels", "drive_over_tie_trigger", "working_sound",
  "vehicle_impact_sound", "allow_manual_color",
}) do
  wagon[key] = table.deepcopy(cargo[key])
end
wagon.localised_description = {"entity-description.yir_us_fluid"}
wagon.factoriopedia_simulation = nil
-- The single hatch is centred on the short tank, 1.56 tiles above the rail.
wagon.base_valve_xy_offset_when_horizontal = {0, 0}
wagon.base_valve_xy_offset_when_vertical = {0, 0}
wagon.base_valve_z_offset_projected_when_horizontal = -1.25
wagon.base_valve_z_offset_projected_when_vertical = -1.25
wagon.pictures = {
  rotated = {
    priority = "very-low",
    width = 256,
    height = 256,
    direction_count = 128,
    line_length = 8,
    lines_per_file = 8,
    filenames = {
      "__JunkTrain3__/graphics/train/t0/usfw_sheet-0.png",
      "__JunkTrain3__/graphics/train/t0/usfw_sheet-1.png",
    },
    shift = {0, -0.625},
    usage = "train",
  },
}

local tint = {r = 0.62, g = 0.39, b = 0.25, a = 1}
local pump = table.deepcopy(data.raw.pump.pump)
pump.name = "scrap-fluid-pump"
pump.minable = {mining_time = 0.2, result = "scrap-fluid-pump"}
pump.pumping_speed = 5
pump.localised_description = {"entity-description.scrap-fluid-pump"}
pump.icon = nil
pump.icons = {{icon = "__base__/graphics/icons/pump.png", icon_size = 64, tint = tint}}
pump.factoriopedia_simulation = nil
pump.next_upgrade = nil
local function tint_sprites(value)
  if type(value) ~= "table" then return end
  if (value.filename or value.filenames or value.stripes) and not value.draw_as_shadow then
    value.tint = table.deepcopy(tint)
  end
  for _, child in pairs(value) do
    if type(child) == "table" then tint_sprites(child) end
  end
end
tint_sprites(pump.animations)
tint_sprites(pump.wagon_connection_graphics)

data:extend({wagon, pump,
  {
    type = "item", name = "ScrapFluidTrailer",
    icon = "__JunkTrain3__/graphics/train/t0/usfw_icon.png", icon_size = 64,
    subgroup = "bob-fluid-wagon", order = "a0", stack_size = 5,
    place_result = "yir_us_fluid", localised_description = {"item-description.ScrapFluidTrailer"},
  },
  {
    type = "item", name = "scrap-fluid-pump", icons = table.deepcopy(pump.icons),
    subgroup = data.raw.item.pump.subgroup, order = "b[pipe]-c[pump]-0", stack_size = 50,
    place_result = "scrap-fluid-pump", localised_description = {"item-description.scrap-fluid-pump"},
  },
  {
    type = "recipe", name = "ScrapFluidTrailer",
    localised_description = {"recipe-description.ScrapFluidTrailer"}, enabled = false, energy_required = 10,
    subgroup = "bob-fluid-wagon", order = "a0",
    ingredients = {
      {type = "item", name = "bob-small-inline-storage-tank", amount = 1},
      {type = "item", name = "iron-plate", amount = 10},
      {type = "item", name = "iron-stick", amount = 4},
      {type = "item", name = "wood", amount = 20},
    },
    results = {{type = "item", name = "ScrapFluidTrailer", amount = 1}},
  },
  {
    type = "recipe", name = "scrap-fluid-pump",
    localised_description = {"recipe-description.scrap-fluid-pump"}, enabled = false, energy_required = 2,
    ingredients = {
      {type = "item", name = "electric-motor", amount = 1},
      {type = "item", name = "iron-plate", amount = 4},
      {type = "item", name = "pipe", amount = 2},
    },
    results = {{type = "item", name = "scrap-fluid-pump", amount = 1}},
  },
  {
    type = "technology", name = "scrap-fluid-handling",
    icon = "__JunkTrain3__/graphics/technology/scrap-fluid-handling.png", icon_size = 256,
    prerequisites = {"JunkTrain_tech", "basic-fluid-handling"},
    effects = {
      {type = "unlock-recipe", recipe = "ScrapFluidTrailer"},
      {type = "unlock-recipe", recipe = "scrap-fluid-pump"},
    },
    unit = {count = 50, ingredients = {{"automation-science-pack", 1}}, time = 20},
    order = "c-g-b-a-a",
  },
})
