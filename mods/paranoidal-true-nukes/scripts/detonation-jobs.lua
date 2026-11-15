-- Fireball, crater and fires of a normal (not chunk-queued) atomic detonation over several ticks
-- (Paranoidal 9.0.0). True Nukes did all of it in the detonation tick: every death in the fireball with
-- the death handlers of the whole build, every crater tile and every fire. The heat and blast waves are
-- separate and start at once (thermal-system, blast-system).
-- Stages: kill (fireball, nearest chunk first) -> sweep (True Nukes' second fireball pass) -> crater (plan,
-- rows, ground noise, finalize) -> fires -> scattered fires -> done (achievement check).
-- Small fireballs (radius below IMMEDIATE_R) run all stages at once, as before, so that a volley of small
-- shells does not queue up. Jobs live in storage.detonationJobs and survive save/load.
local fireball_system = require("fireball-system")
local crater_system = require("crater-system")
local water = require("water-system")
local achievement_system = require("achievement-system")

local M = {}

M.IMMEDIATE_R = 15
local DEATHS_PER_TICK = 300     -- killed or destroyed entities per tick in the fireball
local CELLS_PER_TICK = 24       -- chunk cells searched per tick
local TILES_PER_TICK = 6000     -- crater tiles computed and set per tick
local FIRES_PER_TICK = 1000     -- fire entities created per tick
local FIRE_SHARE = 0.25         -- share of True Nukes' fire density on the crater (fires burn up to a minute)
local SCATTERED_SHARE = 0.1     -- share of True Nukes' scattered fires around the crater
local SCATTERED_MAX = 4000      -- at most this many scattered fires (True Nukes: up to 63 thousand for 1 kt)

local function cells_of(surface, position, radius)
  local cells = {}
  for cx = math.floor((position.x - radius) / 32), math.floor((position.x + radius) / 32) do
    for cy = math.floor((position.y - radius) / 32), math.floor((position.y + radius) / 32) do
      local x0, y0 = cx * 32, cy * 32
      local nx = math.max(x0, math.min(position.x, x0 + 32)) - position.x
      local ny = math.max(y0, math.min(position.y, y0 + 32)) - position.y
      local d2 = nx * nx + ny * ny
      if d2 <= radius * radius and surface.is_chunk_generated({cx, cy}) then
        cells[#cells + 1] = {x0, y0, d2}
      end
    end
  end
  table.sort(cells, function(a, b) return a[3] < b[3] end)
  return cells
end

local function area_of(cell)
  return {left_top = {x = cell[1], y = cell[2]}, right_bottom = {x = cell[1] + 32, y = cell[2] + 32}}
end

local function stats_flags(fireball_r)
  local trees = settings.global["retain-death-statistics-for-trees"].value or (fireball_r < 80 and settings.global["retain-death-statistics-for-trees-small"].value)
  local other = settings.global["retain-death-statistics"].value or (fireball_r < 80 and settings.global["retain-death-statistics-small"].value)
  return trees, other
end

-- job: surface_index, position, crater_internal_r, crater_external_r, fireball_r, fire_outer_r,
-- small_fire_max_r, flame_proportion, create_small_fires, force, cause, building_count
function M.create(job, corpseMap)
  local surface = game.surfaces[job.surface_index]
  job.cells = cells_of(surface, job.position, math.max(job.fireball_r, job.crater_external_r * 1.1 + 4))
  job.stage, job.i = "kill", 1
  if job.fireball_r < M.IMMEDIATE_R then
    M.run(job, corpseMap, math.huge)
    return
  end
  storage.detonationJobs = storage.detonationJobs or {}
  storage.detonationJobNext = (storage.detonationJobNext or 0) + 1
  storage.detonationJobs[storage.detonationJobNext] = job
end

local function fire_name(tile)
  local depth = water.waterInCraterGoingOutDepths[tile.name]
  if depth ~= nil and depth > -10 then return "thermobaric-wave-fire" end
  return "nuclear-fire"
end

-- Runs stages of one job within budget (units: entities, tiles or fires). Returns the unused budget and
-- whether the job is finished.
function M.run(job, corpseMap, budget)
  local surface = game.surfaces[job.surface_index]
  if not surface then return budget, true end
  local position = job.position
  while budget > 0 do
    local stage = job.stage
    if stage == "kill" or stage == "sweep" then
      local trees, other = stats_flags(job.fireball_r)
      local cells, n = job.cells, 0
      local spent = 0
      while job.i <= #cells and spent < math.min(budget, DEATHS_PER_TICK) and n < CELLS_PER_TICK do
        spent = spent + fireball_system.fireball_cell(surface, area_of(cells[job.i]), position.x, position.y, job.fireball_r,
          job.crater_external_r * 1.1 + 4, stage, job.force, job.cause, corpseMap, trees, other)
        job.i, n = job.i + 1, n + 1
      end
      budget = budget - math.max(spent, n * 16)
      if job.i > #cells then
        job.stage, job.i = (stage == "kill") and "sweep" or "crater", 1
      end
      -- at most one fireball step per tick: deaths are the most expensive part
      if budget ~= math.huge then return 0, false end
    elseif stage == "crater" then
      if settings.global["actually-generate-crater"].value then
        if job.crater_external_r > 150 then
          crater_system.nukeTileChangesHeightAwareHuge(position, true, job.surface_index, job.crater_internal_r, job.crater_external_r, job.fireball_r)
          job.stage = "fires"
        else
          job.plan = crater_system.plan(position, job.surface_index, job.crater_internal_r, job.crater_external_r, job.fireball_r)
          surface.set_tiles(job.plan.first)
          budget = budget - #job.plan.first
          job.plan.first = nil
          job.y = math.floor(position.y - job.fireball_r - 1)
          job.y_end = math.ceil(position.y + job.fireball_r + 2)
          job.stage = "rows"
        end
      else
        job.stage = "fires"
      end
    elseif stage == "rows" then
      local width = 2 * job.fireball_r + 3
      while job.y < job.y_end and budget > 0 do
        local n = math.max(2, math.floor(math.min(budget, TILES_PER_TICK) / width))
        local tiles = crater_system.rows(job.plan, job.y, math.min(job.y + n, job.y_end))
        surface.set_tiles(tiles)
        job.y = job.y + n
        budget = budget - math.max(#tiles, width * n)
        if budget ~= math.huge then break end
      end
      if job.y >= job.y_end then
        surface.set_tiles(crater_system.ground_noise(job.plan))
        crater_system.finalize(position, job.surface_index, job.fireball_r)
        job.plan = nil
        job.stage = "fires"
      elseif budget ~= math.huge then
        return 0, false
      end
    elseif stage == "fires" then
      -- fires on the crater: True Nukes' rule with FIRE_SHARE of its density, a few rows per tick
      local r = job.fire_outer_r
      local last = position.y + r + 1
      if job.flame_proportion > 0 then
        job.fire_y = job.fire_y or math.floor(position.y - r)
        local created, scanned = 0, 0
        while job.fire_y < last and created < FIRES_PER_TICK and scanned < TILES_PER_TICK do
          for _, v in pairs(surface.find_tiles_filtered{area = {{position.x - r - 1, job.fire_y}, {position.x + r + 1, job.fire_y + 1}}}) do
            local dx, dy = v.position.x - position.x, v.position.y - position.y
            local d2 = dx * dx + dy * dy
            if d2 <= r * r then
              local rand = math.random(0, math.floor(r))
              if math.random(0, 1) + job.flame_proportion / 8 > 1 and rand * rand > d2 and math.random() < FIRE_SHARE then
                surface.create_entity{name = fire_name(v), position = v.position}
                created = created + 1
              end
            end
          end
          scanned = scanned + 2 * r + 3
          job.fire_y = job.fire_y + 1
        end
        budget = budget - math.max(created, scanned / 4)
      end
      if job.flame_proportion <= 0 or job.fire_y >= last then
        job.stage = "scattered"
      elseif budget ~= math.huge then
        return 0, false
      end
    elseif stage == "scattered" then
      if job.scattered == nil then
        job.scattered = 0
        if settings.global["nuke-random-fires"].value and job.create_small_fires and job.small_fire_max_r > job.fire_outer_r then
          local full = (job.small_fire_max_r ^ 2 - job.fire_outer_r ^ 2) / 10
          job.scattered = math.min(SCATTERED_MAX, math.floor(full * SCATTERED_SHARE))
        end
      end
      local n = 0
      while job.scattered > 0 and n < math.min(budget, FIRES_PER_TICK) do
        local outer, small = math.floor(job.fire_outer_r), math.floor(job.small_fire_max_r)
        local dist = math.random(outer, math.random(outer, small))
        local angle = math.random() * 3.1416 * 2
        surface.create_entity{name = "thermobaric-wave-fire", position = {position.x + dist * math.cos(angle), position.y + dist * math.sin(angle)}}
        job.scattered, n = job.scattered - 1, n + 1
      end
      budget = budget - math.max(n, 1)
      if job.scattered > 0 then
        if budget ~= math.huge then return 0, false end
      else
        job.stage = "done"
      end
    else
      local force = job.force
      if type(force) ~= "string" and force.valid and job.building_count >= 200
        and surface.count_entities_filtered{force = force, type = {"furnace", "assembling-machine"}} < 20 then
        achievement_system.nukedEverything(force)
      end
      return budget, true
    end
  end
  return 0, false
end

-- One tick of the queued jobs, oldest first, sharing one budget.
function M.tick(corpseMap)
  local jobs = storage.detonationJobs
  if not jobs or next(jobs) == nil then return end
  local budget = TILES_PER_TICK
  for id, job in pairs(jobs) do
    local finished
    budget, finished = M.run(job, corpseMap, budget)
    if finished then jobs[id] = nil end
    if budget <= 0 then break end
  end
end

return M
