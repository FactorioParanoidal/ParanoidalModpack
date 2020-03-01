local function make_rail(name, icon, mined, ...)
  local rail =
  {
    type = "straight-rail",
    name = name,
    icon = icon,
	icon_size = 32,
    collision_box = {{-0.7, -0.8}, {0.7, 0.8}},
    selection_box = {{-0.7, -0.8}, {0.7, 0.8}},
    flags = {"player-creation"},
    minable = mined and {mining_time = 0.5, result = mined},
    max_health = 100,
    corpse = "straight-rail-remnants",
    collision_mask = {"object-layer"},
    selectable_in_game = false,
    resistances =
    {
      {
        type = "fire",
        percent = 100
      },
      {
        type = "acid",
        percent = 80
      }
    },
    rail_category = "regular",
    pictures = rail_pictures(), -- rail_pictures method from ~\Factorio\data\base\prototypes\entity\entities.lua
  }
  for i = 1, select("#", ...) do
    local image = select(i, ...)
    local picture = rail.pictures["straight_rail_" .. image[1]][image[2]]
    picture.filename = image[3]
    picture.width = image[4];
    picture.height = image[5];
    picture.variation_count = 1; -- base uses 3 variations, we have only 1
    picture.hr_version = nil; -- no HR graphics for now
  end
  return rail
end

local function induction_station_circuit_connector_sprite()
  local dx = 0.71875
  local dy = -0.28125
  local sprite = table.deepcopy(data.raw["accumulator"]["accumulator"]["circuit_connector_sprites"])
  for k, v in pairs(sprite) do
    if(v.shift) then
      v.shift[1] = v.shift[1] + dx
      v.shift[2] = v.shift[2] + dy
    end
  end
  sprite.blue_led_light_offset[1] = sprite.blue_led_light_offset[1] + dx
  sprite.blue_led_light_offset[2] = sprite.blue_led_light_offset[2] + dy
  sprite.red_green_led_light_offset[1] = sprite.red_green_led_light_offset[1] + dx
  sprite.red_green_led_light_offset[2] = sprite.red_green_led_light_offset[2] + dy
  return sprite
end

local function induction_rail_circuit_connector_sprite(orientation)
  local dx, dy
  if(orientation == "horizontal") then
    dx = 0.9375
    dy = 0.75
  else
    dx = 1.0625
    dy = -0.03125
  end
  local sprite = table.deepcopy(data.raw["accumulator"]["accumulator"]["circuit_connector_sprites"])
  for k, v in pairs(sprite) do
    if(v.shift) then
      v.shift[1] = v.shift[1] + dx
      v.shift[2] = v.shift[2] + dy
    end
  end
  sprite.blue_led_light_offset[1] = sprite.blue_led_light_offset[1] + dx
  sprite.blue_led_light_offset[2] = sprite.blue_led_light_offset[2] + dy
  sprite.red_green_led_light_offset[1] = sprite.red_green_led_light_offset[1] + dx
  sprite.red_green_led_light_offset[2] = sprite.red_green_led_light_offset[2] + dy
  return sprite
end

local function make_station(name, icon, max_health, filename)
  return {
    type = "accumulator",
    name = name,
    icon = icon,
	icon_size = 32,
    collision_box = {{-1.3, -0.3}, {1.3, 2.3}},
    selection_box = {{-1.5, -0.5}, {1.5, 2.5}},
    flags = {"player-creation"},
    minable = {hardness = 0.1, mining_time = 0.1, result = name},
    max_health = max_health,
    corpse = "medium-remnants",
    collision_mask = {"object-layer"},
    energy_source =
    {
      type = "electric",
      buffer_capacity = "100J",
      usage_priority = "tertiary",
      input_flow_limit = "0W", -- this accumulator only copies the charge level of the grid it's charging. It is used to export that value over the circuit network
      output_flow_limit = "0W",
      render_no_power_icon = false
    },
    charge_cooldown = 30,
    discharge_cooldown = 60,
    picture =
    {
      filename = filename,
      priority = "low",
      width = 96,
      height = 96,
      shift = {0, 1},
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0.375, -0.21875},
        green = {0.375, -0.21875},
      },
      wire =
      {
        red = {0.375, -0.21875},
        green = {0.375, -0.21875},
      }
    },
    circuit_connector_sprites = induction_station_circuit_connector_sprite(),
    circuit_wire_max_distance = 7.5,
    default_output_signal = {type = "virtual", name = "signal-A"}
  }
end

local function make_rail_accumulator(orientation, name, icon, max_health, filename)
  local circuit_x = orientation == "horizontal" and 0.65625 or 0.6875
  local circuit_y = orientation == "horizontal" and 0.8125 or 0.0625
  return {
    type = "accumulator",
    name = name .. "-" .. orientation,
    icon = icon,
	icon_size = 32,
    localised_name = {"entity-name." .. name},
    collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    selection_box = orientation == "horizontal" and {{-1, -0.9}, {1, 0.9}} or {{-0.9, -1}, {0.9, 1}},
    flags = {"player-creation"},
    minable = {mining_time = 0.5, result = name},
    max_health = max_health,
    corpse = "straight-rail-remnants",
    collision_mask = {},
    energy_source =
    {
      type = "electric",
      buffer_capacity = "100J",
      usage_priority = "tertiary",
      input_flow_limit = "0W", -- this accumulator only copies the charge level of the grid it's charging. It is used to export that value over the circuit network
      output_flow_limit = "0W",
      render_no_power_icon = false
    },
    charge_cooldown = 30,
    discharge_cooldown = 60,
    picture =
    {
      filename = filename,
      priority = "extra-high",
      width = 64,
      height = 64,
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {circuit_x, circuit_y},
        green = {circuit_x, circuit_y},
      },
      wire =
      {
        red = {circuit_x, circuit_y},
        green = {circuit_x, circuit_y},
      }
    },
    circuit_connector_sprites = induction_rail_circuit_connector_sprite(orientation),
    circuit_wire_max_distance = 7.5,
    default_output_signal = {type = "virtual", name = "signal-A"}
  }
end

data:extend
{
  make_rail("wireless-charging-lo-power-induction-rail",
            "__wireless-charging_v17__/graphics/icons/lo-power-induction-rail.png",
            "wireless-charging-lo-power-induction-rail",
            {"horizontal", "backplates", string.format("__wireless-charging_v17__/graphics/entities/%s-power-induction-rail-%s-%s.png", "lo", "horizontal", "backplates"), 64, 64},
            {"vertical",   "backplates", string.format("__wireless-charging_v17__/graphics/entities/%s-power-induction-rail-%s-%s.png", "lo", "vertical", "backplates"), 64, 64},
            {"horizontal", "ties",       "__wireless-charging_v17__/graphics/entities/induction-rail-horizontal-ties.png", 64, 64},
            {"vertical",   "ties",       "__wireless-charging_v17__/graphics/entities/induction-rail-vertical-ties.png", 64, 64}),
  make_rail("wireless-charging-hi-power-induction-rail",
            "__wireless-charging_v17__/graphics/icons/hi-power-induction-rail.png",
            "wireless-charging-hi-power-induction-rail",
            {"horizontal", "backplates", string.format("__wireless-charging_v17__/graphics/entities/%s-power-induction-rail-%s-%s.png", "hi", "horizontal", "backplates"), 64, 64},
            {"vertical",   "backplates", string.format("__wireless-charging_v17__/graphics/entities/%s-power-induction-rail-%s-%s.png", "hi", "vertical", "backplates"), 64, 64},
            {"horizontal", "ties",       "__wireless-charging_v17__/graphics/entities/induction-rail-horizontal-ties.png", 64, 64},
            {"vertical",   "ties",       "__wireless-charging_v17__/graphics/entities/induction-rail-vertical-ties.png", 64, 64}),
  make_station("wireless-charging-lo-power-induction-station",
               "__wireless-charging_v17__/graphics/icons/lo-power-induction-station.png",
               200,
               "__wireless-charging_v17__/graphics/entities/lo-power-induction-station.png"),
  make_station("wireless-charging-hi-power-induction-station",
               "__wireless-charging_v17__/graphics/icons/hi-power-induction-station.png",
               300,
               "__wireless-charging_v17__/graphics/entities/hi-power-induction-station.png"),
  make_rail_accumulator("horizontal",
                        "wireless-charging-lo-power-induction-rail",
                        "__wireless-charging_v17__/graphics/icons/lo-power-induction-rail.png",
                        200,
                        "__wireless-charging_v17__/graphics/entities/empty64.png"),
  make_rail_accumulator("vertical",
                        "wireless-charging-lo-power-induction-rail",
                        "__wireless-charging_v17__/graphics/icons/lo-power-induction-rail.png",
                        200,
                        "__wireless-charging_v17__/graphics/entities/empty64.png"),
  make_rail_accumulator("horizontal",
                        "wireless-charging-hi-power-induction-rail",
                        "__wireless-charging_v17__/graphics/icons/hi-power-induction-rail.png",
                        300,
                        "__wireless-charging_v17__/graphics/entities/empty64.png"),
  make_rail_accumulator("vertical",
                        "wireless-charging-hi-power-induction-rail",
                        "__wireless-charging_v17__/graphics/icons/hi-power-induction-rail.png",
                        300,
                        "__wireless-charging_v17__/graphics/entities/empty64.png"),
  {
    type = "storage-tank",
    name = "wireless-charging-induction-station-indicator",
    icon = ENERGY_PLACEHOLDER_ICON,
	icon_size = 32,
    flags = {"not-blueprintable", "not-deconstructable", "not-on-map", "placeable-off-grid"},
    max_health = 500,
    collision_mask = {},
    window_bounding_box = {{0, 0}, {0.09375, 0.40625}},
    flow_length_in_ticks = 360,
    fluid_box =
    {
      base_area = 10,
      pipe_connections = { },
    },
    pictures =
    {
      picture =
      {
        sheet =
        {
          filename = "__core__/graphics/empty.png",
          priority = "low",
          width = 1,
          height = 1,
          frames = 1,
         },
      },
      window_background =
      {
        filename = "__wireless-charging_v17__/graphics/entities/induction-station-window-background.png",
        priority = "low",
        width = 3,
        height = 11,
      },
      fluid_background =
      {
        filename = "__wireless-charging_v17__/graphics/entities/induction-station-fluid-background.png",
        priority = "low",
        width = 3,
        height = 11,
      },
      flow_sprite =
      {
        filename = "__wireless-charging_v17__/graphics/entities/induction-station-fluid-flow.png",
        priority = "low",
        width = 160,
        height = 3,
      },
	  gas_flow =
	  {
		filename = "__base__/graphics/entity/pipe/steam.png",
		priority = "extra-high",
		line_length = 10,
		width = 24,
		height = 15,
		frame_count = 60,
		axially_symmetrical = false,
		direction_count = 1,
		animation_speed = 0.25,
		hr_version =
		{
			filename = "__base__/graphics/entity/pipe/hr-steam.png",
			priority = "extra-high",
			line_length = 10,
			width = 48,
			height = 30,
			frame_count = 60,
			axially_symmetrical = false,
			animation_speed = 0.25,
			direction_count = 1
		}
	  },

    },
  },
}
