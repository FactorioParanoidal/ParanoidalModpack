-- Storage layout, per-force and per-player data, research levels.
local S = require("shared")

local M = {}
local HALF_WIDTH = settings.startup["ppd-zone-half-width"].value / 100
local BONUS_MULT = settings.startup["ppd-bonus-multiplier"].value

function M.init()
  storage.tr = storage.tr or {}          -- transformers by unit_number
  storage.lb = storage.lb or {}          -- load banks by unit_number
  storage.alt = storage.alt or {}        -- alt surface by main surface index
  storage.forces = storage.forces or {}
  storage.players = storage.players or {}
  storage.nets = storage.nets or {}      -- automation state by upstream network id
  storage.conv = storage.conv or {}      -- electricity -> heat/steam converters by unit_number
  storage.dist = storage.dist or {}      -- district summaries by district id
  storage.queue = storage.queue or {}
  storage.qi = storage.qi or 1
  storage.slice = storage.slice or 1
  storage.next_plan = storage.next_plan or 0
  storage.period = settings.global["ppd-update-period"].value
  storage.did_counter = storage.did_counter or 0
  storage.guarded = storage.guarded or 0
  storage.emap_players = storage.emap_players or {}
  storage.emap = storage.emap or {}      -- energy map render objects by district id
  storage.show = storage.show or {}      -- temporary highlight render objects
  storage.meters = storage.meters or {}  -- power meters by unit_number (0.2.0)
  storage.pending = storage.pending or {} -- blueprint bushing wires waiting for their pole (0.2.0)
  storage.dead = storage.dead or {}      -- settings of transformers that died, for their ghosts (0.2.0)
end

function M.force(index)
  local f = storage.forces[index]
  if not f then
    f = {
      counter = 0,
      auto = { shed = true, restore = true, threshold = settings.global["ppd-shed-threshold"].value / 100,
        pause = 15 * 60, queue = {} },
      journal = {}, jn = 0,
      saved = 0, saved_now = 0,
      eff = 0, reg = 0, has_auto = false, has_bank = false,
    }
    storage.forces[index] = f
    M.refresh_research(index)
  end
  return f
end

function M.player(index)
  local p = storage.players[index]
  if not p then
    p = { tab = 1, sort = "load", sort_desc = true, jfilter = "all", hist = 1, map_did = nil, emap = false }
    storage.players[index] = p
  end
  return p
end

function M.refresh_research(index)
  local force = game.forces[index]
  local f = storage.forces[index]
  if not (force and f) then return end
  local techs = force.technologies
  local eff = 0
  for i = 1, S.EFFICIENCY_LEVELS do
    local t = techs[S.TECH.efficiency .. i]
    if t and t.researched then eff = i end
  end
  local reg = 0
  for i = 1, S.REGULATION_LEVELS do
    local t = techs[S.TECH.regulation .. i]
    if t and t.researched then reg = i end
  end
  f.eff = eff
  f.reg = reg
  f.hw = HALF_WIDTH + 0.05 * reg
  f.mult = (1 + 0.1 * eff) * BONUS_MULT
  local function done(name)
    local x = techs[name]
    return x and x.researched or false
  end
  f.has_auto = done(S.TECH.automation)
  f.has_bank = done(S.TECH.load_bank)
  local taps = 0
  for i = 1, S.TAP_LEVELS do
    if done(S.TECH.taps .. i) then taps = i end
  end
  f.taps = taps
  f.auto_taps = done(S.TECH.auto_taps)
  f.amorphous = done(S.TECH.amorphous)
  f.boost = done(S.TECH.boost)
end

-- zone half width as a share
function M.half_width(f)
  return f.hw or (HALF_WIDTH + 0.05 * (f.reg or 0))
end

function M.bonus_mult(f)
  return f.mult or ((1 + 0.1 * (f.eff or 0)) * BONUS_MULT)
end

function M.new_did(force_index)
  storage.did_counter = storage.did_counter + 1
  local f = M.force(force_index)
  f.counter = f.counter + 1
  return storage.did_counter, f.counter
end

return M
