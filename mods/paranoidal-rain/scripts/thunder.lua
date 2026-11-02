-- Thunderstorm events (Dynamic Rain thunderstorm.lua): a hazard accumulator per surface fires events at a rate
-- proportional to the generated chunks, a slow three-sine "storm activity" wave, darkness and the weather stage.
-- An event lands on a random chunk:
--   * near a player (120 tiles), not too close while the start protection lasts: a real strike with
--     prain-lightning-strike-chance (scripts/lightning.lua), otherwise thunder only;
--   * far from players: a simulated strike (effects without visuals) with a tenth of that chance, else nothing seen.
-- Players within 400 tiles get a flash and thunder delayed by the speed of sound; close thunder may roll on
-- (Real Rain layering).
local R = require("scripts.registry")

local M = {}
R.thunder = M

local random, floor, min, max, sqrt, sin, pi = math.random, math.floor, math.min, math.max, math.sqrt, math.sin, math.pi

local REFERENCE_CHUNKS = 25000
local REFERENCE_INTERVAL = 600
local MAX_SOUND_RADIUS = 400
local CLOSE_SOUND_RADIUS = 260
local STRIKE_VIEW_RADIUS = 120
local CRACK_RADIUS = 100
local SOUND_SOURCE_OFFSET = 30
local SOUND_SPEED = 243 / 60 -- tiles per tick
local QUIET_NOT_STRIKE = 0.8

local function st()
  local s = storage.thunder
  if not s then
    s = { surfaces = {}, sounds = {} }
    storage.thunder = s
  end
  return s
end

function M.activity(darkness)
  local c = storage.cfg
  local t = 0.000034 * game.tick
  local wave = (sin(t * pi * 1.5123456 + 1) + sin(t * pi * 2.212321 + 1) + sin(t * pi * 4.15617 + 3)) / 3
  return c.min_thunder + (c.max_thunder - c.min_thunder) * max(0, wave) * min(1, 0.25 + darkness * 1.5)
end

local function flash(surface, position, close)
  if not storage.cfg.lightning_flash then return end
  rendering.draw_light {
    sprite = "utility/light_medium", surface = surface, target = position, scale = close and 64 or 48,
    intensity = close and 1.2 or 0.9, minimum_darkness = 0, color = { r = 0.55, g = 0.6, b = 1, a = 1 },
    render_mode = "game", time_to_live = close and 12 or 9, blink_interval = floor(max(4, random() * 8)),
  }
end

local function schedule(player, surface_index, x, y, kind, volume, delay)
  local sounds = st().sounds
  local tick = game.tick + max(1, floor(delay))
  local list = sounds[tick]
  if not list then
    list = {}
    sounds[tick] = list
  end
  list[#list + 1] = { player = player.index, surface_index = surface_index, x = x, y = y, kind = kind, volume = volume }
end

-- Flash and thunder for the players of a surface. strike: a bolt hit the ground (loud crack up close).
function M.notify(surface, position, strike, players)
  local c = storage.cfg

  local surface_index = surface.index
  local light = false
  for i = 1, #players do
    local player = players[i]
    if player.valid and player.connected and player.surface_index == surface_index then
      local p = player.position
      local dx, dy = p.x - position.x, p.y - position.y
      local d2 = dx * dx + dy * dy
      if d2 < CLOSE_SOUND_RADIUS * CLOSE_SOUND_RADIUS then
        light = true
        -- the screen whitens (scripts/dark.lua): a strike close by strongly, a close thunder slightly
        local ratio = sqrt(d2) / CLOSE_SOUND_RADIUS
        if strike and d2 < CRACK_RADIUS * CRACK_RADIUS then
          R.dark.flash(player, 0.2 + 0.55 * (1 - sqrt(d2) / CRACK_RADIUS))
        else
          R.dark.flash(player, 0.18 * (1 - ratio))
        end
      end
      if c.thunder_sound and d2 < MAX_SOUND_RADIUS * MAX_SOUND_RADIUS then
        local distance = sqrt(d2)
        local close = distance <= CLOSE_SOUND_RADIUS
        local sx, sy = position.x, position.y
        if close and distance > 0 then
          -- the sound comes from a point 30 tiles from the player towards the strike
          local ratio = SOUND_SOURCE_OFFSET / CLOSE_SOUND_RADIUS
          sx, sy = p.x - dx * ratio, p.y - dy * ratio
        end
        if strike and distance <= CRACK_RADIUS then
          local ratio = distance / CRACK_RADIUS
          player.play_sound { path = "prain-lightning-crack",
            volume_modifier = min(1, (1 - ratio) * 2 + 0.25) * c.thunder_volume }
          if ratio > 0.1 then
            player.play_sound { path = "prain-thunder-close", position = { sx, sy },
              volume_modifier = sqrt(ratio) * QUIET_NOT_STRIKE * c.thunder_volume }
          end
          if c.thunder_layering then schedule(player, surface_index, sx, sy, "roll", 0.8, random(90, 210)) end
        else
          local volume = 1
          if not close then
            volume = 1 - (distance - CLOSE_SOUND_RADIUS) / (MAX_SOUND_RADIUS - CLOSE_SOUND_RADIUS) + 0.2
          elseif strike and distance >= STRIKE_VIEW_RADIUS / 2 then
            volume = QUIET_NOT_STRIKE
          end
          volume = min(1, max(0, volume))
          local delay = distance / SOUND_SPEED
          schedule(player, surface_index, sx, sy, close and "close" or "far", volume, delay)
          if close and c.thunder_layering then
            schedule(player, surface_index, sx, sy, "roll", volume * 0.8, delay + random(90, 210))
          end
        end
      end
    end
  end
  if light then flash(surface, position, false) end
end

local PATHS = { far = "prain-thunder-far", close = "prain-thunder-close", roll = "prain-thunder-roll" }

function M.process_sounds(tick)
  local sounds = st().sounds
  local list = sounds[tick]
  if not list then return end
  sounds[tick] = nil
  local c = storage.cfg
  if not c.thunder_sound then return end
  for i = 1, #list do
    local e = list[i]
    local player = game.get_player(e.player)
    if player and player.connected and player.surface_index == e.surface_index
        and R.weather.thunder_factor(e.surface_index) > 0 then
      local volume = min(1, max(0, e.volume)) * c.thunder_volume
      if e.kind == "far" then
        player.play_sound { path = PATHS.far, volume_modifier = volume }
      else
        player.play_sound { path = PATHS[e.kind] or PATHS.close, position = { e.x, e.y }, volume_modifier = volume }
      end
    end
  end
end

function M.clear_sounds(surface_index)
  local sounds = st().sounds
  for tick, list in pairs(sounds) do
    if surface_index then
      for i = #list, 1, -1 do
        if list[i].surface_index == surface_index then table.remove(list, i) end
      end
      if #list == 0 then sounds[tick] = nil end
    elseif tick < game.tick then
      sounds[tick] = nil
    end
  end
end

function M.forget(surface_index)
  M.clear_sounds(surface_index)
  st().surfaces[surface_index] = nil
end

local function protected_near(position, players)
  if not R.lightning.protection_active() then return false end
  for i = 1, #players do
    local p = players[i].position
    local dx, dy = p.x - position.x, p.y - position.y
    if dx * dx + dy * dy <= 18 * 18 then return true end
  end
  return false
end

local function visible(position, players)
  for i = 1, #players do
    local p = players[i].position
    local dx, dy = p.x - position.x, p.y - position.y
    if dx * dx + dy * dy <= STRIKE_VIEW_RADIUS * STRIKE_VIEW_RADIUS then return true end
  end
  return false
end

local function event(surface, players)
  local chunk = surface.get_random_chunk()
  if not chunk then return end
  local position = { x = chunk.x * 32 + random() * 32, y = chunk.y * 32 + random() * 32 }
  local chance = storage.cfg.strike_chance
  if visible(position, players) then
    if chance > 0 and not protected_near(position, players) and random() < chance then
      R.lightning.strike(surface, position, { visible = true, players = players })
      return
    end
    M.notify(surface, position, false, players)
  else
    if chance > 0 and random() < chance / 10 then
      R.lightning.strike(surface, position, { visible = false, players = players })
      return
    end
    M.notify(surface, position, false, players)
  end
end

function M.update(index, surface, players)
  local factor = R.weather.thunder_factor(index)
  if factor <= 0 then return end
  local chunk_count = R.chunks.count(index)
  if chunk_count == 0 then return end
  local rate = chunk_count / REFERENCE_CHUNKS * M.activity(surface.darkness) * 10000 / REFERENCE_INTERVAL * factor
  local surfaces = st().surfaces
  local s = surfaces[index]
  if not s then
    s = { hazard = 0, threshold = -math.log(1 - random()) }
    surfaces[index] = s
  end
  s.hazard = s.hazard + rate
  if s.hazard >= s.threshold then
    s.hazard = s.hazard - s.threshold
    s.threshold = -math.log(1 - random())
    event(surface, players)
  end
end

return M
