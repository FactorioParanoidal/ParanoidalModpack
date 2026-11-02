-- Darker sky in the rain and the white flash of a close lightning.
-- Every player on a rain surface gets one filled black rectangle drawn only for him (rendering, not on the ground,
-- so above the entities), tied to his character with offsets (it follows him by itself) or, without a character, to
-- a position that is moved when he goes far. Its alpha follows the weather stage (DARKNESS) and the fade of the rain;
-- updated every UPDATE ticks, and only when it changes. Always on (decision of the build).
-- A close thunder or a strike adds a short white rectangle (premultiplied colour, FLASH_HOLD ticks at the peak, then
-- fading over FLASH_FADE ticks), unless the player turned "prain-screen-flash" off (storage.no_flash).
local R = require("scripts.registry")

local M = {}
R.dark = M

M.UPDATE = 30
local HALF_W, HALF_H = 260, 160 -- tiles around the player: more than the view at the farthest game zoom
local MOVE = 90 -- a position-bound rectangle is moved after the player went this far
local DARKNESS = { clear = 0, drizzle = 0.03, rain = 0.07, heavy = 0.13, storm = 0.22, monsoon = 0.28 }
function R.dark_level(stage)
  return DARKNESS[stage] or 0
end

local FLASH_HOLD = 3
local FLASH_FADE = 10

local function object(id)
  return id and rendering.get_object_by_id(id)
end

local function drop(list, player_index)
  local d = list[player_index]
  if not d then return end
  local obj = object(d.id)
  if obj and obj.valid then obj.destroy() end
  list[player_index] = nil
end

local function corners(player)
  local character = player.character
  if character and character.valid and character.surface_index == player.surface_index then
    return { entity = character, offset = { -HALF_W, -HALF_H } }, { entity = character, offset = { HALF_W, HALF_H } },
        "entity"
  end
  local p = player.position
  return { p.x - HALF_W, p.y - HALF_H }, { p.x + HALF_W, p.y + HALF_H }, "position"
end

local function draw(player, color, ttl)
  local left_top, right_bottom, mode = corners(player)
  local obj = rendering.draw_rectangle { color = color, filled = true, left_top = left_top,
    right_bottom = right_bottom, surface = player.surface, players = { player.index }, render_mode = "game",
    time_to_live = ttl }
  local p = player.position
  return obj, mode, p.x, p.y
end

-- Darkness of a rain surface for its players (on_tick every UPDATE ticks).
function M.update(index, players, alpha)
  local list = storage.dark
  if alpha <= 0.003 and not list then return end
  if not list then
    list = {}
    storage.dark = list
  end
  for i = 1, #players do
    local player = players[i]
    local d = list[player.index]
    if alpha <= 0.003 then
      if d then drop(list, player.index) end
    else
      local obj = d and object(d.id)
      local character = player.character
      local wants = (character and character.valid) and "entity" or "position"
      local moved = false
      if d and d.mode == "position" then
        local p = player.position
        local dx, dy = p.x - d.x, p.y - d.y
        moved = dx * dx + dy * dy > MOVE * MOVE
      end
      if not (obj and obj.valid) or d.surface ~= index or d.mode ~= wants or moved then
        if d then drop(list, player.index) end
        local new, mode, x, y = draw(player, { 0, 0, 0, alpha })
        list[player.index] = { id = new.id, surface = index, mode = mode, x = x, y = y, alpha = alpha }
      elseif math.abs(d.alpha - alpha) > 0.003 then
        obj.color = { 0, 0, 0, alpha }
        d.alpha = alpha
      end
    end
  end
  if next(list) == nil then storage.dark = nil end
end

-- Players who left the surface, the game or the rain lose their rectangle (every UPDATE ticks).
function M.cleanup()
  local list = storage.dark
  if not list then return end
  for player_index, d in pairs(list) do
    local player = game.get_player(player_index)
    if not (player and player.connected and player.surface_index == d.surface and R.surfaces.is_rain(d.surface)) then
      drop(list, player_index)
    end
  end
  if next(list) == nil then storage.dark = nil end
end

function M.clear_all()
  local list = storage.dark
  if list then
    for player_index in pairs(list) do drop(list, player_index) end
  end
  storage.dark = nil
end

-- A white flash for one player; strength 0..1 (peak alpha).
function M.flash(player, strength)
  if strength <= 0.02 then return end
  if storage.no_flash and storage.no_flash[player.index] then return end
  storage.flashes = storage.flashes or {}
  local list = storage.flashes
  local old = list[player.index]
  if old and old.peak >= strength and game.tick - old.start < FLASH_HOLD then return end
  if old then
    local obj = object(old.id)
    if obj and obj.valid then obj.destroy() end
  end
  local obj = draw(player, { strength, strength, strength, strength }, FLASH_HOLD + FLASH_FADE + 1)
  list[player.index] = { id = obj.id, start = game.tick, peak = strength }
end

-- Every tick while a flash is on.
function M.process_flashes(tick)
  local list = storage.flashes
  if not list then return end
  for player_index, f in pairs(list) do
    local age = tick - f.start
    local obj = object(f.id)
    if not (obj and obj.valid) or age > FLASH_HOLD + FLASH_FADE then
      if obj and obj.valid then obj.destroy() end
      list[player_index] = nil
    elseif age >= FLASH_HOLD then
      local a = f.peak * (1 - (age - FLASH_HOLD) / FLASH_FADE)
      obj.color = { a, a, a, a }
    end
  end
  if next(list) == nil then storage.flashes = nil end
end

return M
