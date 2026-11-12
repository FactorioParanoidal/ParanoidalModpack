-- Transformers (visible part: a constant combinator, so it has circuit wires and outputs signals),
-- their hidden wire poles, the alt-surface poles and energy interfaces, the load bank.
local S = require("shared")

local substation = data.raw["electric-pole"]["substation"]
local open_sound = substation and substation.open_sound or nil
local close_sound = substation and substation.close_sound or nil
local empty_mask = { layers = {} }

local HIDDEN_FLAGS = { "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable",
  "hide-alt-info", "not-flammable", "not-repairable", "not-upgradable", "no-copy-paste" }

-- One view for every transformer, it does not rotate: the tall brown bushing (input) on the left, the short grey one
-- (output) on the right. 0.2.1 art and shadow from tools/make_graphics.py, which also prints these shifts: the front
-- edge of the base plate is the front of the 4x2 footprint.
local function transformer_sprite(key)
  return { layers = {
    { filename = S.GFX .. "entity/transformer-" .. key .. ".png", width = 259, height = 211,
      shift = { 0, -0.6219 }, scale = 0.5, priority = "high" },
    { filename = S.GFX .. "entity/transformer-shadow.png", width = 345, height = 74,
      shift = { 0.6639, 0.4584 }, scale = 0.5, priority = "high", draw_as_shadow = true },
  } }
end

local function wcp(x, y)
  return { wire = { red = { x - 0.1, y }, green = { x + 0.1, y } },
    shadow = { red = { x + 0.3, y + 0.4 }, green = { x + 0.5, y + 0.4 } } }
end
-- circuit wires attach at the green lamp on the right of the front face (the transformer does not rotate)
local CP = { wire = { red = { 1.42, 0.23 }, green = { 1.62, 0.23 } },
  shadow = { red = { 2.34, 1.0 }, green = { 2.54, 1.0 } } }
local CIRCUIT_POINTS = { CP, CP, CP, CP }

local function mw(n)
  return { "", n, " ", { "ppd-unit.mw" } }
end
local function num(whole, frac)
  if not frac then return tostring(whole) end
  return { "", tostring(whole), { "ppd-unit.dec" }, tostring(frac) }
end

local function tooltip_fields(t)
  local n = t.nominal / 1e6
  local idle = n * S.IDLE
  local idle_whole = math.floor(idle)
  local idle_frac = math.floor((idle - idle_whole) * 10 + 0.5)
  return {
    { name = { "ppd-tooltip.nominal" }, value = mw(tostring(n)) },
    { name = { "ppd-tooltip.zone" }, value = { "", tostring(math.floor(n * 0.9 + 0.5)), "–", tostring(math.floor(n * 1.1 + 0.5)), " ", { "ppd-unit.mw" } } },
    { name = { "ppd-tooltip.bonus" }, value = { "", "+", tostring(math.floor(t.bonus * 100 + 0.5)), " %" } },
    { name = { "ppd-tooltip.limit" }, value = mw(tostring(math.floor(n * S.LIMIT + 0.5))) },
    { name = { "ppd-tooltip.idle" }, value = { "", num(idle_whole, idle_frac ~= 0 and idle_frac or nil), " ", { "ppd-unit.mw" } } },
  }
end

local protos = {}

for _, t in ipairs(S.TIERS) do
  local icon = { { icon = S.GFX .. "icons/transformer-" .. t.key .. ".png", icon_size = 64, mipmap_count = 4 } }
  -- the engine does not let the script raise a flow limit above the prototype's: the prototype allows the most a
  -- force can reach (top tap x boost), the script sets the working limit (125 % of the tapped nominal) at once
  local limit_w = string.format("%.0fW", t.nominal * (1 + S.TAP_STEP * S.TAP_LEVELS) * S.BOOST)
  protos[#protos + 1] = {
    type = "constant-combinator",
    name = t.name,
    icons = icon,
    flags = { "placeable-neutral", "player-creation", "not-rotatable" },
    minable = { mining_time = 0.5, result = t.name },
    max_health = 350,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    collision_box = { { -1.9, -0.9 }, { 1.9, 0.9 } },
    selection_box = { { -2, -1 }, { 2, 1 } },
    open_sound = open_sound,
    close_sound = close_sound,
    sprites = transformer_sprite(t.key),
    activity_led_light_offsets = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } },
    circuit_wire_connection_points = CIRCUIT_POINTS,
    circuit_wire_max_distance = 9,
    custom_tooltip_fields = tooltip_fields(t),
    resistances = { { type = "fire", percent = 80 } },
    -- the hum of the vanilla substation
    working_sound = substation and substation.working_sound and table.deepcopy(substation.working_sound) or nil,
  }
  -- hidden energy interfaces on the alt surface: the input takes from the upstream network,
  -- the output feeds the district; the script moves energy between their buffers
  protos[#protos + 1] = {
    type = "electric-energy-interface",
    name = t.eei_in,
    localised_name = { "entity-name.ppd-transformer-input" },
    icons = icon,
    hidden = true,
    hidden_in_factoriopedia = true,
    flags = HIDDEN_FLAGS,
    selectable_in_game = false,
    collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
    collision_mask = empty_mask,
    gui_mode = "none",
    allow_copy_paste = false,
    energy_source = {
      type = "electric",
      buffer_capacity = "1MJ",
      usage_priority = "dynamic", -- the script sets primary/secondary/tertiary input by the district priority
      input_flow_limit = limit_w,
      output_flow_limit = "0W",
      render_no_network_icon = false,
      render_no_power_icon = false,
    },
  }
  protos[#protos + 1] = {
    type = "electric-energy-interface",
    name = t.eei_out,
    localised_name = { "entity-name.ppd-transformer-output" },
    icons = icon,
    hidden = true,
    hidden_in_factoriopedia = true,
    flags = HIDDEN_FLAGS,
    selectable_in_game = false,
    collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
    collision_mask = empty_mask,
    gui_mode = "none",
    allow_copy_paste = false,
    energy_source = {
      type = "electric",
      buffer_capacity = "1MJ",
      -- dynamic + mode secondary_output set by the script: only then does the engine use the output limit the
      -- script writes (2.1.24: a fixed "secondary-output" keeps the prototype limit, probe ppd-test13)
      usage_priority = "dynamic",
      input_flow_limit = "0W",
      output_flow_limit = limit_w,
      render_no_network_icon = false,
      render_no_power_icon = false,
    },
  }
end

local function hidden_pole(name, wire_offset, shadow_offset)
  return {
    type = "electric-pole",
    name = name,
    icons = { { icon = S.GFX .. "icons/transformer-80.png", icon_size = 64, mipmap_count = 4 } },
    hidden = true,
    hidden_in_factoriopedia = true,
    flags = HIDDEN_FLAGS,
    max_health = 100,
    collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
    collision_mask = empty_mask,
    selection_box = { { -0.45, -0.45 }, { 0.45, 0.45 } },
    selection_priority = 60,
    maximum_wire_distance = 12,
    supply_area_distance = 0,
    auto_connect_up_to_n_wires = 0,
    open_sound = open_sound,
    close_sound = close_sound,
    connection_points = { { wire = { copper = wire_offset }, shadow = { copper = shadow_offset } } },
  }
end

-- the poles stand at the bushing tips; the wire shadow lands where the bushing shadow ends (height h over the ground
-- casts 1.2 h to the right, as the vanilla poles; numbers from tools/make_graphics.py)
protos[#protos + 1] = hidden_pole(S.POLE_IN, { 0, 0 }, { 2.9, 2.42 })
protos[#protos + 1] = hidden_pole(S.POLE_OUT, { 0, 0 }, { 1.98, 1.65 })

local alt = hidden_pole(S.POLE_ALT, { 0, 0 }, { 0, 0 })
alt.selectable_in_game = false
alt.selection_box = nil
alt.selection_priority = nil
alt.maximum_wire_distance = 1
alt.supply_area_distance = 0.25
alt.open_sound = nil
alt.close_sound = nil
protos[#protos + 1] = alt

-- load bank: visible constant combinator (signal W, own window) + a hidden consumer at the same spot
local tint = { r = 1, g = 0.55, b = 0.32, a = 1 }
local bank_icon = { { icon = "__base__/graphics/icons/accumulator.png", icon_size = 64, tint = tint } }
local bank_picture = accumulator_picture and accumulator_picture(tint) or {
  filename = "__base__/graphics/entity/accumulator/accumulator.png", width = 130, height = 189,
  shift = util.by_pixel(0, -11), tint = tint, scale = 0.5 }
protos[#protos + 1] = {
  type = "constant-combinator",
  name = S.LOAD_BANK,
  icons = bank_icon,
  flags = { "placeable-neutral", "player-creation" },
  minable = { mining_time = 0.3, result = S.LOAD_BANK },
  max_health = 200,
  corpse = "accumulator-remnants",
  dying_explosion = "accumulator-explosion",
  collision_box = { { -0.9, -0.9 }, { 0.9, 0.9 } },
  selection_box = { { -1, -1 }, { 1, 1 } },
  open_sound = open_sound,
  close_sound = close_sound,
  sprites = { north = bank_picture, east = bank_picture, south = bank_picture, west = bank_picture },
  activity_led_light_offsets = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } },
  circuit_wire_connection_points = { wcp(0.6, 0.6), wcp(0.6, 0.6), wcp(0.6, 0.6), wcp(0.6, 0.6) },
  circuit_wire_max_distance = 9,
  custom_tooltip_fields = { { name = { "ppd-tooltip.max-power" }, value = mw("10") } },
}
-- power meter (0.2.0): the vanilla display panel look; a zero-power consumer at the same spot tells the network
local panel = data.raw["display-panel"] and data.raw["display-panel"]["display-panel"]
local meter_points = {}
for i = 1, 4 do
  local cc = panel and panel.circuit_connector and panel.circuit_connector[i]
  meter_points[i] = cc and table.deepcopy(cc.points) or wcp(0, -0.3)
end
local meter_icons = {
  { icon = "__base__/graphics/icons/display-panel.png", icon_size = 64 },
  { icon = "__base__/graphics/icons/signal/signal-lightning.png", icon_size = 64, scale = 0.25, shift = { 8, 8 } },
}
protos[#protos + 1] = {
  type = "constant-combinator",
  name = S.METER,
  icons = meter_icons,
  flags = { "placeable-neutral", "player-creation" },
  minable = { mining_time = 0.2, result = S.METER },
  max_health = 50,
  corpse = panel and panel.corpse or "small-remnants",
  dying_explosion = panel and panel.dying_explosion or nil,
  collision_box = panel and table.deepcopy(panel.collision_box) or { { -0.29, -0.29 }, { 0.29, 0.29 } },
  selection_box = panel and table.deepcopy(panel.selection_box) or { { -0.5, -0.5 }, { 0.5, 0.5 } },
  open_sound = panel and panel.open_sound or nil,
  close_sound = panel and panel.close_sound or nil,
  sprites = panel and table.deepcopy(panel.sprites) or table.deepcopy(data.raw["constant-combinator"]["constant-combinator"].sprites),
  activity_led_light_offsets = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } },
  circuit_wire_connection_points = meter_points,
  circuit_wire_max_distance = 9,
}
protos[#protos + 1] = {
  type = "electric-energy-interface",
  name = S.METER_EEI,
  localised_name = { "entity-name." .. S.METER },
  icons = meter_icons,
  hidden = true,
  hidden_in_factoriopedia = true,
  flags = HIDDEN_FLAGS,
  selectable_in_game = false,
  collision_box = { { -0.25, -0.25 }, { 0.25, 0.25 } },
  collision_mask = empty_mask,
  gui_mode = "none",
  allow_copy_paste = false,
  energy_source = {
    type = "electric",
    buffer_capacity = "1J",
    usage_priority = "secondary-input",
    input_flow_limit = "0W",
    output_flow_limit = "0W",
    render_no_network_icon = false,
    render_no_power_icon = false,
  },
}

protos[#protos + 1] = {
  type = "electric-energy-interface",
  name = S.LOAD_BANK_EEI,
  localised_name = { "entity-name.ppd-load-bank" },
  icons = bank_icon,
  hidden = true,
  hidden_in_factoriopedia = true,
  flags = HIDDEN_FLAGS,
  selectable_in_game = false,
  collision_box = { { -0.8, -0.8 }, { 0.8, 0.8 } },
  collision_mask = empty_mask,
  gui_mode = "none",
  allow_copy_paste = false,
  energy_source = {
    type = "electric",
    buffer_capacity = "1kJ",
    usage_priority = "secondary-input",
    input_flow_limit = "10500kW",
    output_flow_limit = "0W",
  },
}

-- status lamp of the transformer (0.2.1): a white lens with the glass shading, tinted by the script in the status
-- colour over the unlit glass of the body, and a soft additive halo around it
protos[#protos + 1] = { type = "sprite", name = "ppd-lamp-lens", filename = S.GFX .. "entity/transformer-lamp.png",
  size = 48, scale = S.LENS_SCALE, priority = "high" }
protos[#protos + 1] = { type = "sprite", name = "ppd-lamp-halo", filename = S.GFX .. "entity/transformer-lamp-halo.png",
  size = 64, scale = 0.3, priority = "high", blend_mode = "additive" }

data:extend(protos)
