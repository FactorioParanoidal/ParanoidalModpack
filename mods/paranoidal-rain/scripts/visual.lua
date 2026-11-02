-- Drops, splashes, post-rain puddles and wind gusts around the players who can see a rain surface.
-- Each drop is one create_entity of an invisible explosion (prototypes/rain.lua). The visible rectangle of every
-- player (Dynamic Rain) gets drops proportional to its area; overlapping rectangles share them; the total per tick is
-- capped by prain-max-drops-per-tick, so zooming far out thins the rain instead of loading the game.
local R = require("scripts.registry")

local M = {}
R.visual = M

local random, floor, min, max = math.random, math.floor, math.min, math.max
local render_game = defines.render_mode.game
local render_zoomed_chart = defines.render_mode.chart_zoomed_in

local SPLASH_CHANCE = 0.05     -- per drop at stage factor 1
local POST_DENSITY = 0.00036   -- puddles per visible tile per tick at the start of the post-rain tail

local function player_rect(player)
  if not player.valid then return nil end
  local mode = player.render_mode
  if mode ~= render_game and mode ~= render_zoomed_chart then return nil end
  local zoom = player.zoom
  if not zoom or zoom < 0.08 then return nil end
  local resolution = player.display_resolution
  if resolution.height <= 0 then return nil end
  local aspect = resolution.width / resolution.height
  local half_h = resolution.height / (2 * player.display_scale * 32 * zoom * player.display_density_scale) + (12 + 3 / zoom)
  local half_w = half_h * aspect
  local pos = player.position
  local w, h = half_w * 2 + 3, half_h * 2
  -- drops start high and fall down-left: the rectangle is shifted up by 10 tiles and widened by 3 to the right
  return { x = pos.x - half_w, y = pos.y - half_h - 10, w = w, h = h, x2 = pos.x - half_w + w, y2 = pos.y + half_h - 10,
    s = w * h }
end

local function rects_of(players)
  local rects, total = {}, 0
  for i = 1, #players do
    local player = players[i]
    if not R.players.hidden(player) then
      local rect = player_rect(player)
      if rect then
        rects[#rects + 1] = rect
        total = total + rect.s
      end
    end
  end
  return rects, total
end

-- Point inside several rectangles: keep it with probability 1/count, so overlaps are not denser.
local function keep(rects, i, x, y)
  local count = #rects
  if count == 1 then return true end
  local hits = 1
  for j = 1, count do
    if j ~= i then
      local r = rects[j]
      if x >= r.x and x < r.x2 and y >= r.y and y < r.y2 then hits = hits + 1 end
    end
  end
  return hits == 1 or random() < 1 / hits
end

local function wind_bucket(index, raining)
  storage.wind = storage.wind or {}
  local st = storage.wind[index]
  if not st then
    st = { bucket = "straight", next = 0 }
    storage.wind[index] = st
  end
  local tick = game.tick
  if tick < st.next then return st.bucket end
  st.next = tick + random(100, 300)
  local strength = storage.cfg.wind_strength
  if strength <= 0.15 then
    st.bucket = "straight"
    return st.bucket
  end
  local r = random()
  if raining and r < min(0.42, 0.08 * strength) then
    st.bucket = "gust"
  elseif r < 0.34 then
    st.bucket = "left"
  elseif r < 0.70 then
    st.bucket = "straight"
  else
    st.bucket = "right"
  end
  return st.bucket
end

local function splash(surface, x, y, frame)
  local tile = surface.get_tile(x, y)
  local kind = tile.collides_with("water_tile") and "ripple" or "splash"
  surface.create_entity { name = "prain-drop-" .. kind .. "-" .. frame, position = { x, y } }
end

local function gust_sound(players)
  storage.gust_next = storage.gust_next or {}
  local tick = game.tick
  local volume = min(1, storage.cfg.rain_volume * 0.55)
  for i = 1, #players do
    local player = players[i]
    local next_tick = storage.gust_next[player.index] or 0
    if tick >= next_tick then
      player.play_sound { path = "prain-wind-gust", volume_modifier = volume }
      storage.gust_next[player.index] = tick + random(900, 1800)
    end
  end
end

function M.forget_player(player_index)
  if storage.gust_next then storage.gust_next[player_index] = nil end
end

-- Budget shared by all surfaces within one tick.
local budget_tick, budget_left = -1, 0
local function take_budget(want)
  local tick = game.tick
  if budget_tick ~= tick then budget_tick, budget_left = tick, storage.cfg.max_drops end
  local got = min(want, budget_left)
  budget_left = budget_left - got
  return got
end

function M.rain(index, surface, players, strength)
  local rects, total = rects_of(players)
  if total <= 0 then return end
  local c = storage.cfg
  local raining = R.weather.is_raining(index)
  local k = c.intensity * R.cfg.DROPS_PER_TILE * R.weather.visual_factor(index) * strength
  local demanded = k * total
  if demanded <= 0 then return end
  local allowed = take_budget(demanded)
  if allowed <= 0 then return end
  k = k * allowed / demanded

  local wind = wind_bucket(index, raining)
  local splash_chance = c.splashes and SPLASH_CHANCE * R.weather.stage_data(index).splash or 0
  local n = storage.drop_index or 0
  for i = 1, #rects do
    local r = rects[i]
    local count = r.s * k
    if count < 1 then
      count = random() < count and 1 or 0
    else
      count = floor(count)
    end
    for _ = 1, count do
      local x = r.x + random() * r.w
      local y = r.y + random() * r.h
      if keep(rects, i, x, y) then
        n = n + 1
        local frame = n % 4 + 1
        local roll = random()
        local layer = roll < 0.38 and "front" or (roll < 0.82 and "mid" or "mist")
        surface.create_entity { name = "prain-drop-" .. layer .. "-" .. frame .. "-" .. wind, position = { x, y } }
        if splash_chance > 0 and random() < splash_chance then
          splash(surface, x + random() * 1.4 - 0.7, y + random() * 1.4 - 0.7, frame)
        end
      end
    end
  end
  storage.drop_index = n % 1000000

  if wind == "gust" and raining and random() < 0.02 then gust_sound(players) end
end

function M.post_rain(index, surface, players, factor)
  if not storage.cfg.post_rain or factor <= 0 then return end
  local rects, total = rects_of(players)
  if total <= 0 then return end
  local k = POST_DENSITY * factor
  local n = storage.drop_index or 0
  for i = 1, #rects do
    local r = rects[i]
    local count = r.s * k
    if count < 1 then
      count = random() < count and 1 or 0
    else
      count = min(3, floor(count))
    end
    for _ = 1, take_budget(count) do
      n = n + 1
      surface.create_entity { name = "prain-drop-puddle-" .. (n % 4 + 1),
        position = { r.x + random() * r.w, r.y + random() * r.h } }
    end
  end
  storage.drop_index = n % 1000000
end

return M
