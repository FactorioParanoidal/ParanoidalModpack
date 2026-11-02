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
-- Splash kind by ground, without reading a tile per splash: every GRID_REFRESH ticks (or after the view moved by a
-- cell) GRID_COLS x GRID_ROWS tiles of the player's view are read (one per cell, its centre) and classed by tile
-- name once per name: water -> ripple, a minable tile (laid by players: concrete, bricks, ...) -> light splash,
-- other ground -> small dark splash. The grid lives in storage (same on every peer).
local GRID_COLS, GRID_ROWS = 10, 6
local GRID_REFRESH = 90
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
        rect.player = player.index
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

local tile_kinds = {} -- tile name -> "ripple" | "splash" | "splash-soil" (from prototypes: same on every peer)
local function tile_kind(name)
  local kind = tile_kinds[name]
  if kind then return kind end
  local proto = prototypes.tile[name]
  kind = "splash-soil"
  if proto then
    local layers = proto.collision_mask and proto.collision_mask.layers
    if layers and layers["water_tile"] then
      kind = "ripple"
    elseif proto.mineable_properties and proto.mineable_properties.minable then
      kind = "splash"
    end
  end
  tile_kinds[name] = kind
  return kind
end

local function grid_of(surface, rect)
  storage.splash_grid = storage.splash_grid or {}
  local g = storage.splash_grid[rect.player]
  local tick = game.tick
  local cw, ch = rect.w / GRID_COLS, rect.h / GRID_ROWS
  if g and g.surface == surface.index and tick < g.next and math.abs(g.x - rect.x) < g.cw
      and math.abs(g.y - rect.y) < g.ch and math.abs(g.cw - cw) < g.cw * 0.25 then
    return g
  end
  g = { surface = surface.index, x = rect.x, y = rect.y, cw = cw, ch = ch, next = tick + GRID_REFRESH, cells = {} }
  local cells = g.cells
  for row = 0, GRID_ROWS - 1 do
    for col = 0, GRID_COLS - 1 do
      local tile = surface.get_tile(rect.x + (col + 0.5) * cw, rect.y + (row + 0.5) * ch)
      cells[row * GRID_COLS + col + 1] = tile.valid and tile_kind(tile.name) or "splash-soil"
    end
  end
  storage.splash_grid[rect.player] = g
  return g
end

local function splash(surface, g, x, y, frame)
  local col, row = floor((x - g.x) / g.cw), floor((y - g.y) / g.ch)
  local kind = "splash-soil"
  if col >= 0 and col < GRID_COLS and row >= 0 and row < GRID_ROWS then
    kind = g.cells[row * GRID_COLS + col + 1] or kind
  end
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
  if storage.splash_grid then storage.splash_grid[player_index] = nil end
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
    local grid = splash_chance > 0 and count > 0 and grid_of(surface, r) or nil
    for _ = 1, count do
      local x = r.x + random() * r.w
      local y = r.y + random() * r.h
      if keep(rects, i, x, y) then
        n = n + 1
        local frame = n % 4 + 1
        local roll = random()
        local layer = roll < 0.38 and "front" or (roll < 0.82 and "mid" or "mist")
        surface.create_entity { name = "prain-drop-" .. layer .. "-" .. frame .. "-" .. wind, position = { x, y } }
        if grid and random() < splash_chance then
          splash(surface, grid, x + random() * 1.4 - 0.7, y + random() * 1.4 - 0.7, frame)
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
