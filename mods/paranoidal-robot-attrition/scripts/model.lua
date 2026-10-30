-- Everything that sets the expected crash rate of a network. Used by the scan and by the roboport panel, so
-- the panel shows exactly what the scan uses.
local shared = require("shared")
local hooks = require("scripts.hooks")

local M = {}

local busy_weight, queue_weight, rate_scale = shared.busy_weight, shared.queue_weight, shared.rate_scale

-- Completed levels of Swarm safety.
function M.safety_level(force)
  local tech = force.technologies[shared.technology]
  if not tech then return 0 end
  return tech.researched and tech.level or tech.level - 1
end

-- Highest researched Swarm dispatch level (the chain is researched in order).
function M.dispatch_level(force)
  local technologies, level = force.technologies, 0
  for i = 1, shared.dispatch_levels do
    local tech = technologies[shared.dispatch_prefix .. i]
    if not (tech and tech.researched) then break end
    level = i
  end
  return level
end

function M.dispatch_multiplier(force)
  return shared.dispatch_multiplier ^ M.dispatch_level(force)
end

-- Storm multiplier from the one wind of Wind-Turbines-Reforged; 1 without the mod.
function M.wind_multiplier()
  local api = remote.interfaces["Wind-Turbines-Reforged"]
  if not (api and api.get_wind) then return 1 end
  local ok, wind = pcall(remote.call, "Wind-Turbines-Reforged", "get_wind")
  if not (ok and type(wind) == "table") then return 1 end
  local output = math.min(tonumber(wind.output or wind.share) or 0, shared.storm_cap)
  if output <= shared.storm_start then return 1 end
  return 1 + (output - shared.storm_start) / shared.storm_span
end

function M.surface_multiplier(surface_index)
  return storage.surface_multiplier[surface_index] or 1
end

function M.risk(force_index, surface_index)
  local risks = storage.risk[force_index]
  return risks and risks[surface_index] or shared.risk_start
end

-- Fills ctx.waiting, ctx.queued, ctx.cells, ctx.counts, ctx.load from the charging queues of the network.
function M.queues(ctx)
  local cells, queued, counts, waiting, n = ctx.network.cells, ctx.cells, ctx.counts, 0, 0
  for i = 1, #cells do
    local cell = cells[i]
    local count = cell.to_charge_robot_count
    if count > 0 then
      n = n + 1
      queued[n], counts[n] = cell, count
      waiting = waiting + count
    end
  end
  for i = n + 1, #queued do queued[i], counts[i] = nil, nil end
  ctx.waiting, ctx.queued = waiting, n
  ctx.load = ctx.busy * busy_weight + waiting * queue_weight
end

-- Expected crashes per tick of ctx.network with ctx.risk, ctx.multiplier and the factor of the map setting.
function M.per_tick(ctx, factor)
  local multiplier = ctx.multiplier
  local rate = hooks.rate
  for i = 1, #rate do multiplier = multiplier * rate[i](ctx) end
  return ctx.load * ctx.risk * factor * multiplier * rate_scale
end

-- A context table with its own reusable queue arrays.
function M.new_context()
  return {cells = {}, counts = {}}
end

return M
