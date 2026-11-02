-- Rain puts ordinary fires out slowly, the fire shrinking from its edges.
-- Every fire prototype creates a marker (data-final-fixes.lua); while it rains on the surface the new flame is
-- registered, and when the rain starts all flames of the surface are registered once.
--   * Flames are grouped in 8x8-tile cells. 5 s after the first flame of a cell the fire is sized up: a big fire
--     (20+ flames) lasts prain-fire-quench-seconds (30 s), a smaller one proportionally less, at least 10 s. It goes out
--     in waves 5-10 s apart (about 6 s for a big one); every wave puts out the outer part (farthest from the centre)
--     with a puff of steam and a hiss, so the fire visibly shrinks. The last flame leaves a steam cloud.
--   * Enemy acid on the ground is washed away within 0.5-2 s.
--   * Not put out: lightning fires and burning flammable fluids of paranoidal-flammable-fluids (mod-data
--     fire_exempt); fire safety turrets deal with those, rain only slows the hazards down.
-- When the rain ends the remaining flames burn on as usual.
local R = require("scripts.registry")

local M = {}
R.fire = M

local random, floor, ceil, min, max = math.random, math.floor, math.ceil, math.min, math.max

local CELL = 8
local BIG_FIRE = 20
local LOOK = 300                    -- ticks between the first flame of a cell and sizing the fire up
local WAVE_MIN, WAVE_MAX = 300, 600 -- ticks between waves
local WAVE_MEAN = 450
local MAX_STEAM = 14

local classes -- mod-data cache: exempt and acid fire names
local function class_of(name)
  if not classes then
    classes = { exempt = {}, acid = {} }
    local proto = prototypes.mod_data["paranoidal-rain"]
    local d = proto and proto.data or {}
    for _, n in ipairs(d.fire_exempt or {}) do classes.exempt[n] = true end
    for _, n in ipairs(d.fire_acid or {}) do classes.acid[n] = true end
  end
  if classes.exempt[name] then return "exempt" end
  if classes.acid[name] then return "acid" end
  return "fire"
end

local function st()
  local s = storage.fire
  if not s then
    s = { cells = {} }
    storage.fire = s
  end
  return s
end

local function quench_enabled(index)
  local option = R.weather.option(index, "fire_quench")
  if option ~= nil then return option ~= false end
  return storage.cfg.fire_quench
end

function M.register(fire)
  if not (fire and fire.valid) or fire.type ~= "fire" then return end
  local index = fire.surface_index
  if not R.weather.is_raining(index) or not quench_enabled(index) then return end
  local class = class_of(fire.name)
  if class == "exempt" then return end
  if class == "acid" then
    R.jobs.after(random(30, 120), { kind = "wash", entity = fire, surface_index = index })
    return
  end
  local p = fire.position
  local cx, cy = floor(p.x / CELL), floor(p.y / CELL)
  local key = cx .. ":" .. cy
  local cells = st().cells
  local by_surface = cells[index]
  if not by_surface then
    by_surface = {}
    cells[index] = by_surface
  end
  local cell = by_surface[key]
  if not cell then
    cell = { fires = {}, total = 0 }
    by_surface[key] = cell
    R.jobs.after(LOOK, { kind = "quench", surface_index = index, key = key })
  end
  cell.fires[#cell.fires + 1] = fire
  cell.total = cell.total + 1
end

R.jobs.handler("wash", function(job)
  local fire = job.entity
  if fire.valid and R.weather.is_raining(job.surface_index) then fire.destroy { raise_destroy = true } end
end)

local function steam(surface, position, count, name)
  for _ = 1, count do
    surface.create_trivial_smoke { name = name,
      position = { position.x + random() * 1.2 - 0.6, position.y + random() * 1.2 - 0.6 } }
  end
end

local function drop_cell(index, key)
  local by_surface = st().cells[index]
  if not by_surface then return end
  by_surface[key] = nil
  if next(by_surface) == nil then st().cells[index] = nil end
end

R.jobs.handler("quench", function(job)
  local index, key = job.surface_index, job.key
  local by_surface = st().cells[index]
  local cell = by_surface and by_surface[key]
  if not cell then return end
  local surface = R.surfaces.get(index)
  if not surface or not R.weather.is_raining(index) or not quench_enabled(index) then
    drop_cell(index, key) -- the rain stopped: the fire burns on
    return
  end

  local fires, n, sx, sy = {}, 0, 0, 0
  for _, fire in ipairs(cell.fires) do
    if fire.valid then
      n = n + 1
      fires[n] = fire
      local p = fire.position
      sx, sy = sx + p.x, sy + p.y
    end
  end
  if n == 0 then
    drop_cell(index, key)
    return
  end
  local centre = { x = sx / n, y = sy / n }

  if not cell.waves then
    -- size the fire up: total time from the first flame, number of waves and the pause between them
    local duration = max(LOOK + WAVE_MIN, storage.cfg.fire_quench_ticks * min(1, cell.total / BIG_FIRE))
    cell.waves = max(1, floor((duration - LOOK) / WAVE_MEAN + 0.5))
    cell.interval = max(WAVE_MIN, min(WAVE_MAX, floor((duration - LOOK) / cell.waves)))
    R.jobs.after(cell.interval, job)
    return
  end
  local k = ceil(n / cell.waves)
  -- outer flames first
  local d2 = {}
  for i = 1, n do
    local p = fires[i].position
    local dx, dy = p.x - centre.x, p.y - centre.y
    d2[fires[i]] = dx * dx + dy * dy
  end
  table.sort(fires, function(a, b) return d2[a] > d2[b] end)

  local puffs = 0
  for i = 1, k do
    local fire = fires[i]
    if puffs < MAX_STEAM then
      steam(surface, fire.position, 2, "prain-steam-small")
      puffs = puffs + 2
    end
    fire.destroy { raise_destroy = true }
  end
  R.lightning.stat("fires_quenched", k)
  surface.play_sound { path = "prain-hiss", position = centre, volume_modifier = 0.45 }

  local left = {}
  for i = k + 1, n do left[#left + 1] = fires[i] end
  if #left == 0 then
    steam(surface, centre, min(MAX_STEAM, 2 + floor(cell.total / 3)), "prain-steam")
    drop_cell(index, key)
    return
  end
  cell.fires = left
  cell.waves = max(1, cell.waves - 1) -- flames that joined late go out with the last wave
  R.jobs.after(cell.interval, { kind = "quench", surface_index = index, key = key })
end)

-- The rain started: register every flame burning on the surface now.
function M.on_rain_start(index)
  local surface = R.surfaces.get(index)
  if not surface or not quench_enabled(index) then return end
  for _, fire in pairs(surface.find_entities_filtered { type = "fire" }) do M.register(fire) end
end

function M.forget(index)
  if storage.fire then storage.fire.cells[index] = nil end
end

-- on_trigger_created_entity: the marker of a new flame.
function M.on_marker(event)
  local marker = event.entity
  if not (marker and marker.valid) or marker.name ~= "prain-fire-marker" then return end
  local fire = event.source
  if storage.cfg.enabled and R.weather.is_raining(marker.surface_index) then
    if not (fire and fire.valid and fire.type == "fire") then
      -- not confirmed for 2.0 that source is the fire (Dynamic Rain relied on it in 2.1): look at the marker spot
      fire = marker.surface.find_entities_filtered { position = marker.position, radius = 0.5, type = "fire",
        limit = 1 }[1]
    end
    M.register(fire)
  end
  marker.destroy()
end

return M
