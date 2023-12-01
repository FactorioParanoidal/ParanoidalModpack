--- Converts an RGB color value to HSV. Conversion formula
--- adapted from http://en.wikipedia.org/wiki/HSV_color_space.
--- @param input Color
--- @return number, number, number, number
local function rgb_to_hsv(input)
  local r = input.r --[[@as number]]
  local g = input.g --[[@as number]]
  local b = input.b --[[@as number]]
  local a = input.a --[[@as number]]
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then
    s = 0
  else
    s = d / max
  end

  if max == min then
    h = 0 -- achromatic
  else
    if max == r then
      h = (g - b) / d
      if g < b then
        h = h + 6
      end
    elseif max == g then
      h = (b - r) / d + 2
    elseif max == b then
      h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, v, a
end

--- Converts an HSV color value to RGB. Conversion formula
--- adapted from http://en.wikipedia.org/wiki/HSV_color_space.
--- @param h number
--- @param s number
--- @param v number
--- @param a number
--- @return Color
local function hsv_to_rgb(h, s, v, a)
  local r, g, b

  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)

  i = i % 6

  if i == 0 then
    r, g, b = v, t, p
  elseif i == 1 then
    r, g, b = q, v, p
  elseif i == 2 then
    r, g, b = p, v, t
  elseif i == 3 then
    r, g, b = p, q, v
  elseif i == 4 then
    r, g, b = t, p, v
  elseif i == 5 then
    r, g, b = v, p, q
  end

  return { r = r, g = g, b = b, a = a }
end

--- @param e EventData.CustomInputEvent
local function on_color_by_system_changed(e)
  global.color_by_system[e.player_index] = not global.color_by_system[e.player_index]
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  player.create_local_flying_text({
    text = { global.color_by_system[e.player_index] and "message.pv-color-by-system" or "message.pv-color-by-fluid" },
    create_at_cursor = true,
  })
end

local function generate_system_colors()
  --- @type Color[]
  global.system_colors = {}
  for s = 0.8, 0.3, -0.1 do
    for h = 0, 360, 30 do
      global.system_colors[#global.system_colors + 1] = hsv_to_rgb(h / 360, s, 1, 1)
    end
  end
end

local function generate_fluid_colors()
  --- @type table<string, Color>
  local colors = {}
  for name, fluid in pairs(game.fluid_prototypes) do
    local h, s, v, a = rgb_to_hsv(fluid.base_color)
    v = 1
    colors[name] = hsv_to_rgb(h, s, v, a)
  end
  global.fluid_colors = colors
end

local function initialize()
  global.color_by_system = {}
  generate_fluid_colors()
  generate_system_colors()
end

local colors = {}

colors.on_init = initialize
colors.on_configuration_changed = initialize

colors.events = {
  ["pv-color-by-fluid-system"] = on_color_by_system_changed,
}

return colors
