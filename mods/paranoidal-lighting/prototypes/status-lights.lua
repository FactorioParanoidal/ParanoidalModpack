-- Larger status lights (after BIG LIGHT by Ritn): mining drills, power switches and train stops.
local G = "__paranoidal-lighting__/graphics/entity/train-stop/"
local startup = settings.startup
local M = {}

-- Every mining drill that uses the vanilla electric drill status LEDs (vanilla, Bob's and their copies).
local DRILL_LED = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-N-light.png"
function M.drills()
  local scale = startup["ritnmods-bl-01"].value / 2
  for _, drill in pairs(data.raw["mining-drill"]) do
    for _, set in pairs({drill.graphics_set, drill.wet_mining_graphics_set}) do
      for _, visualisation in pairs(set.working_visualisations or {}) do
        local north = visualisation.north_animation
        if north and north.filename == DRILL_LED then
          for _, direction in pairs({"north", "east", "south", "west"}) do
            local animation = visualisation[direction .. "_animation"]
            if animation then animation.scale = scale end
          end
        end
      end
    end
  end
end

-- Green (on) and red (off) glow next to the vanilla power switch LED.
function M.power_switch()
  local switch = data.raw["power-switch"]["power-switch"]
  if not switch then return end
  local scale = startup["ritnmods-bl-04"].value / 4
  local function glow(led, tint, y)
    return {layers = {
      led,
      {filename = G .. "N-light.png", width = 20, height = 20, tint = tint, shift = util.by_pixel(23, y), scale = scale},
    }}
  end
  switch.led_on = glow(switch.led_on, {0, 1, 0, 0.8}, 2)
  switch.led_off = glow(switch.led_off, {1, 0, 0, 0.8}, 6)
end

-- Train stop lights: coloured lamp sprites plus a glow. Index 1/2 = the two lamps of the stop.
-- Directions use the sprites of the opposite side, as the vanilla train stop does.
local STOP_FILES = {north = "north", west = "east", south = "south", east = "west"}
local STOP_LIGHTS = {
  [1] = {
    --          sprite w, h, shift x, y (px/32)   glow file, glow shift (px)
    north = {17, 9, -70.75, -44.25, "N", -70.5, -44.5},
    west = {6, 16, 34.5, 19.5, "E", 34.5, 19.5},
    south = {16, 4, 70, -95, "S", 70, -95},
    east = {6, 16, -30.5, -112, "W", -30.5, -112},
  },
  [2] = {
    north = {16, 9, -57.5, -43.75, "N", -57.5, -43.5},
    west = {6, 16, 34.5, 10, "N", 34.5, 10},
    south = {16, 5, 57, -94.75, "N", 57, -94.5},
    east = {7, 15, -30.75, -102.75, "N", -31, -103},
  },
}

function M.train_stops()
  local green = startup["ritnmods-bl-02"].value
  local folder = green and "green" or "yellow"
  local tint = green and {0, 1, 0, 0.5} or {1, 1, 0, 0.5}
  local glow_scale = startup["ritnmods-bl-03"].value / 2

  local function light(index)
    local picture, red_picture = {}, {}
    for direction, d in pairs(STOP_LIGHTS[index]) do
      local file = "train-stop-" .. STOP_FILES[direction] .. "-light-" .. index .. ".png"
      local function lamp(filename, glow_tint)
        return {layers = {
          {filename = filename, width = d[1], height = d[2], frame_count = 1, shift = {d[3] / 32, d[4] / 32}, scale = 0.5},
          {filename = G .. d[5] .. "-light.png", width = 20, height = 20, tint = glow_tint,
            shift = util.by_pixel(d[6], d[7]), scale = glow_scale},
        }}
      end
      picture[direction] = lamp(G .. folder .. "/" .. file, tint)
      red_picture[direction] = lamp("__base__/graphics/entity/train-stop/" .. file:gsub("%-light%-", "-red-light-"), {1, 0, 0, 0.5})
    end
    return {light = {intensity = 0.5, size = 3, color = {r = 1.0, g = 1.0, b = 1.0}}, picture = picture, red_picture = red_picture}
  end

  -- Cybersyn uses the vanilla stop; other stop mods of the original are not in the pack.
  local stop = data.raw["train-stop"]["train-stop"]
  if stop then
    stop.light1 = light(1)
    stop.light2 = light(2)
  end
end

return M
