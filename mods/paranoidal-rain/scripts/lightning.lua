-- Lightning strikes (Dynamic Rain effects). The strike picks the most attractive target within 18 tiles of its point
-- (priorities from data-final-fixes, mod-data "paranoidal-rain".lightning), then:
--   * energy buffers of the target are emptied;
--   * an electric pole browns its network out for 3 s; a radar stops for 20 s;
--   * construction and logistic robots are destroyed;
--   * characters (not in a vehicle, not during the start protection), units, spawners and enemy worms are killed
--     (50 %) or left with 10 % health; trees are scorched; fish are killed and dropped as raw fish;
--   * combustible targets (trees, wooden things, pipes with flammable fluid) catch fire: prain-lightning-fire, which
--     rain does not put out;
--   * storage tanks and ammunition stores get a spark of fire damage: paranoidal-flammable-fluids decides whether the
--     tank overheats or the ammunition cooks off (no second copy of that logic here);
--   * a discharge jumps on through nearby robots, creatures and poles (prain-lightning-chain).
local R = require("scripts.registry")

local M = {}
R.lightning = M

local random, floor, min, sqrt = math.random, math.floor, math.min, math.sqrt

local SEARCH_RADIUS = 18
local BROWNOUT_TICKS = 3 * 60
local RADAR_OUTAGE_TICKS = 20 * 60
local CHAIN_RANGE = 12
local CHAIN_JUMPS = 10
local CHAIN_DELAY = 3
local CHAIN_FORK = 0.3
local BOLT_HEIGHT = 28
local RADAR_STATUS = "prain-gui.radar-struck"

local CHAIN_TYPES = { "construction-robot", "logistic-robot", "character", "unit", "unit-spawner", "turret",
  "electric-pole" }
-- paranoidal-flammable-fluids listens to fire damage of these (tanks overheat, ammunition cooks off)
local HEAT_TYPES = { ["storage-tank"] = true, ["container"] = true, ["logistic-container"] = true,
  ["cargo-wagon"] = true, ["car"] = true, ["spider-vehicle"] = true, ["artillery-wagon"] = true }
local FIRE_OFFSETS = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } }
local FLAMMABLE_FLUIDS = { ["crude-oil"] = true, ["heavy-oil"] = true, ["light-oil"] = true,
  ["petroleum-gas"] = true, ["lubricant"] = true }
local FUEL_WORDS = { oil = true, petroleum = true, fuel = true, gasoline = true, diesel = true, kerosene = true,
  naphtha = true, ethanol = true }
local FLUID_CONTAINERS = { pipe = true, ["pipe-to-ground"] = true, pump = true, ["storage-tank"] = true }

local targets -- mod-data cache (same on every peer)
local function data()
  if not targets then
    local proto = prototypes.mod_data["paranoidal-rain"]
    targets = proto and proto.data.lightning or { ids = {}, types = {}, search_types = {}, tops = {} }
  end
  return targets
end

local function stat(name, count)
  local stats = storage.stats
  if not stats then
    stats = {}
    storage.stats = stats
  end
  stats[name] = (stats[name] or 0) + (count or 1)
end
M.stat = stat

function M.protection_active()
  return game.tick < storage.cfg.protection_ticks
end

local function has_word(name, words)
  for word in string.gmatch(name, "[%a%d]+") do
    if words[word] then return true end
  end
  return false
end

local fluid_cache = {}
local function flammable_fluid(name)
  local known = fluid_cache[name]
  if known ~= nil then return known end
  local result = false
  if not string.find(name, "oxidizer", 1, true) then
    if FLAMMABLE_FLUIDS[name] or has_word(name, FUEL_WORDS) then
      result = true
    else
      local fluid = prototypes.fluid[name]
      result = fluid ~= nil and fluid.fuel_value > 0
    end
  end
  fluid_cache[name] = result
  return result
end

local function combustible(target)
  local kind = target.type
  if kind == "tree" then return true end
  local name = target.name
  if name == "wooden-chest" or name == "small-electric-pole" then return true end
  if FLUID_CONTAINERS[kind] then
    for fluid, amount in pairs(target.get_fluid_contents()) do
      if amount > 0 and flammable_fluid(fluid) then return true end
    end
    return false
  end
  if target.has_flag("not-flammable") then return false end
  return has_word(name, { wood = true, wooden = true, timber = true, lumber = true })
end

local function bonus(entity)
  local d = data()
  return (d.ids[entity.name] or 0) + (d.types[entity.type] or 0)
end

-- The most attractive entity within SEARCH_RADIUS: priority bonus minus 2 per tile of distance.
local function find_target(surface, position)
  local d = data()
  if #d.search_types == 0 then return nil end
  local candidates = surface.find_entities_filtered { position = position, radius = SEARCH_RADIUS,
    type = d.search_types }
  local protect = M.protection_active()
  local best, best_score
  for i = 1, #candidates do
    local entity = candidates[i]
    if entity.valid and not (protect and entity.type == "character") then
      local b = bonus(entity)
      if b > 0 then
        local p = entity.position
        local dx, dy = p.x - position.x, p.y - position.y
        local score = b - 2 * sqrt(dx * dx + dy * dy) + random() * 5
        if not best_score or score > best_score then best, best_score = entity, score end
      end
    end
  end
  return best
end

-- Where the bolt touches the target: the top of tall buildings and poles, the body of others.
local function hit_point(entity)
  local p = entity.position
  local top = data().tops[entity.name]
  if top then return { x = p.x, y = p.y + top } end
  return { x = p.x, y = p.y - 0.5 }
end

local function draw_bolt(surface, ground, hit)
  surface.create_entity { name = "prain-lightning-bolt", position = hit,
    source_position = { x = hit.x + random() * 8 - 4, y = hit.y - BOLT_HEIGHT }, target_position = hit, duration = 10 }
  surface.create_entity { name = "prain-lightning-impact", position = ground }
  surface.create_entity { name = "prain-lightning-streamer-" .. random(1, 4), position = ground }
  if storage.cfg.lightning_flash then
    rendering.draw_light { sprite = "utility/light_medium", surface = surface, target = ground, scale = 30,
      intensity = 1.6, minimum_darkness = 0, color = { r = 0.8, g = 0.9, b = 1, a = 1 }, render_mode = "game",
      time_to_live = 6, blink_interval = 2 }
  end
end

local function brownout(surface, pole)
  local load = surface.create_entity { name = "prain-lightning-load", position = pole.position, force = pole.force,
    create_build_effect_smoke = false }
  if load then
    stat("brownouts")
    R.jobs.after(BROWNOUT_TICKS, { kind = "brownout-end", entity = load, surface_index = surface.index })
  end
end

R.jobs.handler("brownout-end", function(job)
  if job.entity.valid then job.entity.destroy() end
end)

local function radar_outage(radar)
  local status = radar.custom_status
  if status and status.label and status.label[1] == RADAR_STATUS then return end
  local previous = { disabled = radar.disabled_by_script, status = status }
  radar.disabled_by_script = true
  radar.custom_status = { diode = defines.entity_status_diode.yellow, label = { RADAR_STATUS } }
  rendering.draw_sprite { sprite = "virtual-signal/signal-lightning", surface = radar.surface,
    target = { entity = radar, offset = { 0, -2 } }, render_mode = "game", time_to_live = RADAR_OUTAGE_TICKS,
    blink_interval = 15 }
  stat("radar_outages")
  R.jobs.after(RADAR_OUTAGE_TICKS, { kind = "radar-end", entity = radar, previous = previous,
    surface_index = radar.surface_index })
end

R.jobs.handler("radar-end", function(job)
  local radar = job.entity
  if not radar.valid then return end
  local status = radar.custom_status
  if status and status.label and status.label[1] == RADAR_STATUS then
    radar.disabled_by_script = job.previous.disabled
    radar.custom_status = job.previous.status
  end
end)

local function strike_living(target)
  if target.type == "character" then
    storage.last_player_strike = storage.last_player_strike or {}
    local id = target.unit_number
    local last = id and storage.last_player_strike[id]
    if last and game.tick - last < 120 then return end -- no second hit by the discharge of the same strike
    if id then storage.last_player_strike[id] = game.tick end
  end
  if random() < 0.5 then
    stat("kills")
    target.die("neutral")
  else
    target.health = min(target.health, target.max_health * 0.1)
    target.damage(1, "neutral", "electric")
  end
end

local function shock(target, surface_index)
  local kind = target.type
  if kind == "construction-robot" or kind == "logistic-robot" then
    stat("kills")
    target.die("neutral")
  elseif kind == "character" then
    if not target.vehicle and not M.protection_active() then strike_living(target) end
  elseif kind == "unit" or kind == "unit-spawner" or (kind == "turret" and target.force.name == "enemy") then
    strike_living(target)
  end
end

local function strike_fire(surface, position)
  if surface.get_tile(position.x, position.y).collides_with("water_tile") then return end
  local count = 0
  if surface.create_entity { name = "prain-lightning-fire", position = position, force = "neutral" } then
    count = count + 1
  end
  local x, y = floor(position.x), floor(position.y)
  local skipped = random(4)
  for i = 1, 4 do
    if i ~= skipped then
      local offset = FIRE_OFFSETS[i]
      if surface.create_entity { name = "prain-lightning-fire", position = { x + offset[1] + 0.5, y + offset[2] + 0.5 },
          force = "neutral" } then
        count = count + 1
      end
    end
  end
  if count > 0 then stat("fires_lit", count) end
end

local function shock_fish(surface, target)
  local drops = surface.spill_item_stack { position = target.position, stack = { name = "raw-fish", count = 1 },
    max_radius = 2, allow_belts = false }
  if #drops > 0 then target.die("neutral") end
end

local function apply(surface, position, target)
  if not (target and target.valid) then return end
  local kind = target.type
  local ignite = combustible(target)
  if target.energy > 0 then target.energy = 0 end
  if kind == "electric-pole" then
    brownout(surface, target)
  elseif kind == "radar" then
    radar_outage(target)
  elseif kind == "tree" then
    target.damage(10, "neutral", "electric")
  elseif kind == "fish" then
    shock_fish(surface, target)
  else
    shock(target, surface.index)
  end
  if target.valid and HEAT_TYPES[kind] then target.damage(1, "neutral", "fire") end
  if ignite then strike_fire(surface, position) end
end

-- Discharge: a jump to the nearest not yet hit conductor within CHAIN_RANGE, every CHAIN_DELAY ticks, sometimes forking.
local function chain_from(surface, from, left, visited, draw)
  if left <= 0 then return end
  local found = surface.find_entities_filtered { position = from, radius = CHAIN_RANGE, type = CHAIN_TYPES }
  local best, best_d2
  for i = 1, #found do
    local entity = found[i]
    local id = entity.unit_number
    if entity.valid and id and not visited[id] then
      local p = entity.position
      local dx, dy = p.x - from.x, p.y - from.y
      local d2 = dx * dx + dy * dy + random() * 4
      if not best_d2 or d2 < best_d2 then best, best_d2 = entity, d2 end
    end
  end
  if not best then return end
  visited[best.unit_number] = true
  local to = hit_point(best)
  if draw then
    surface.create_entity { name = "prain-lightning-chain", position = from, source_position = from,
      target_position = to, duration = 9 }
  end
  shock(best, surface.index)
  R.jobs.after(CHAIN_DELAY, { kind = "chain", surface_index = surface.index, x = to.x, y = to.y, left = left - 1,
    visited = visited, draw = draw })
  if random() < CHAIN_FORK then
    R.jobs.after(CHAIN_DELAY, { kind = "chain", surface_index = surface.index, x = to.x, y = to.y,
      left = floor((left - 1) / 2), visited = visited, draw = draw })
  end
end

R.jobs.handler("chain", function(job)
  local surface = R.surfaces.get(job.surface_index)
  if surface then chain_from(surface, { x = job.x, y = job.y }, job.left, job.visited, job.draw) end
end)

-- [2.0] A scripted strike. opts.visible: draw it and play it to the players (opts.players); otherwise only effects.
function M.strike(surface, position, opts)
  opts = opts or {}
  local target = find_target(surface, position)
  local ground = position
  local hit = { x = position.x, y = position.y }
  if target then
    ground = target.position
    hit = hit_point(target)
  end
  stat("strikes")
  if opts.visible then
    draw_bolt(surface, ground, hit)
    R.thunder.notify(surface, hit, true, opts.players or R.players.on_surface(surface.index))
  end
  apply(surface, ground, target)
  if target == nil and not surface.get_tile(ground.x, ground.y).collides_with("water_tile") and random() < 0.15 then
    strike_fire(surface, ground) -- dry grass near the point
  end
  if storage.cfg.chain then
    local visited = {}
    if target and target.valid and target.unit_number then visited[target.unit_number] = true end
    chain_from(surface, hit, CHAIN_JUMPS, visited, opts.visible)
  end
end

--[[ [2.1] Engine strike of Dynamic Rain (needs "prain-lightning" from the [2.1] block of data-final-fixes.lua):
function M.strike(surface, position, opts)
  surface.execute_lightning { name = "prain-lightning", position = position }
end
-- control.lua: script.on_event(defines.events.on_script_trigger_effect, R.lightning.on_script_trigger_effect)
function M.on_script_trigger_effect(event)
  if event.effect_id ~= "prain-lightning-strike" then return end
  local surface = game.surfaces[event.surface_index]
  local target = event.target_entity
  local position = event.target_position or (target and target.valid and target.position)
  if not (surface and position) then return end
  stat("strikes")
  R.thunder.notify(surface, position, true, R.players.on_surface(surface.index))
  apply(surface, position, target)
  if storage.cfg.chain then chain_from(surface, position, CHAIN_JUMPS, {}, true) end
end
--]]

return M
