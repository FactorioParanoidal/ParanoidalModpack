-- The periodic check: for every busy logistic network of a force with players, draw the number of crashes of this
-- check from a Poisson distribution with the expected value of scripts/model.lua × interval.
-- No state per network: merging/splitting networks loses nothing.
local shared = require("shared")
local hooks = require("scripts.hooks")
local model = require("scripts.model")
local crash = require("scripts.crash")

local M = {}

local random, exp, log, sqrt, cos, floor, ceil, min = math.random, math.exp, math.log, math.sqrt, math.cos,
  math.floor, math.ceil, math.min
local two_pi = 2 * math.pi
local cargo_inventory = defines.inventory.robot_cargo

local min_busy, interval = shared.min_busy, shared.interval
local risk_start, risk_weight, carried_self = shared.risk_start, shared.risk_weight, shared.carried_self
local max_share, max_speed = shared.max_share, shared.max_speed

-- Number of events of a Poisson process with the expected value lambda.
local function poisson(lambda)
  if lambda <= 0 then return 0 end
  if lambda < 30 then
    local limit, k, p = exp(-lambda), 0, random()
    while p > limit do
      k = k + 1
      p = p * random()
    end
    return k
  end
  local k = floor(lambda + sqrt(lambda) * sqrt(-2 * log(1 - random())) * cos(two_pi * random()) + 0.5)
  return k > 0 and k or 0
end
M.poisson = poisson

-- Prototype data, identical on every peer.
local speeds = {}
local function speed_of(name)
  local s = speeds[name]
  if not s then
    local prototype = prototypes.entity[name]
    s = {min(prototype.speed, max_speed), prototype.speed_multiplier_when_out_of_energy or 1}
    speeds[name] = s
  end
  return s
end

-- Risk sample of one robot: speed × (carried items + carried_self).
local function sample(robot, force)
  local s = speed_of(robot.name)
  local speed = s[1] * (1 + force.worker_robots_speed_modifier)
  if robot.energy <= 0 then speed = speed * s[2] end
  local cargo = robot.get_inventory(cargo_inventory)
  return speed * ((cargo and cargo.get_item_count() or 0) + carried_self)
end
M.sample = sample

local ctx = model.new_context()

local function check_network(risks, surface_index, lambda)
  local count = poisson(lambda)
  if count == 0 then return end
  count = min(count, ceil(ctx.busy * max_share))
  local force = ctx.force
  local picked = hooks.select(ctx, count)
  local spare = hooks.spare
  for i = 1, #picked do
    local robot = picked[i]
    if robot.valid then
      risks[surface_index] = risks[surface_index] * (1 - risk_weight) + risk_weight * sample(robot, force)
      local spared = false
      for j = 1, #spare do
        if spare[j](robot, ctx) then spared = true break end
      end
      if not spared then crash.run(robot, ctx) end
    end
  end
end

function M.scan()
  local factor = settings.global[shared.setting].value
  if factor <= 0 then return end
  local all_risks, overrides, wind = storage.risk, storage.force_enabled, nil
  for _, force in pairs(game.forces) do
    -- Forces with players, unless a script decided otherwise (remote set_force_enabled).
    local enabled = overrides[force.index]
    if enabled == nil then enabled = #force.players > 0 end
    if enabled then
      local risks, dispatch
      for surface_name, networks in pairs(force.logistic_networks) do
        local surface
        for i = 1, #networks do
          local network = networks[i]
          -- A crash can invalidate other networks of the list (a network splits or merges).
          if network.valid then
            local busy = network.all_logistic_robots - network.available_logistic_robots
            if busy > min_busy then
              surface = surface or game.surfaces[surface_name]
              local surface_index = surface.index
              local surface_multiplier = model.surface_multiplier(surface_index)
              if surface_multiplier > 0 then
                if not risks then
                  risks = all_risks[force.index]
                  if not risks then
                    risks = {}
                    all_risks[force.index] = risks
                  end
                end
                if not risks[surface_index] then risks[surface_index] = risk_start end
                dispatch = dispatch or model.dispatch_multiplier(force)
                wind = wind or model.wind_multiplier()
                ctx.force, ctx.surface, ctx.network, ctx.busy = force, surface, network, busy
                ctx.risk, ctx.multiplier = risks[surface_index], surface_multiplier * dispatch * wind
                model.queues(ctx)
                check_network(risks, surface_index, model.per_tick(ctx, factor) * interval)
              end
            end
          end
        end
      end
    end
  end
  ctx.force, ctx.surface, ctx.network, ctx.wreck = nil, nil, nil, nil
end

return M
