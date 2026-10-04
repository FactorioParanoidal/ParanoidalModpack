-- Research goal shared by a force. Only fills free slots at the back of the normal
-- Factorio queue through force.add_research; never grants research or reorders player items.
local G = require("graph")
local M = {}

local function goals()
  storage.ptt_goals = storage.ptt_goals or {}
  return storage.ptt_goals
end

function M.get(force) return goals()[force.index] end

-- Shared graph cache; built lazily per force, rebuilt when the visible set changes.
function M.graph(force)
  storage.native_graphs = storage.native_graphs or {}
  local g = storage.native_graphs[force.index]
  if not g then
    g = G.build(force.technologies, function(item)
      local proto = prototypes.item[item]
      return proto and proto.subgroup and proto.subgroup.name == "science-pack" or false
    end)
    storage.native_graphs[force.index] = g
  end
  return g
end

function M.plan(force, done)
  local goal = M.get(force)
  if not goal then return nil end
  return G.plan(M.graph(force), force, goal.tech, done or G.snapshot(force))
end

local function name_of(force, tech)
  local t = force.technologies[tech]
  return t and t.localised_name or tech
end

function M.clear(force, reason)
  local goal = M.get(force)
  if not goal then return end
  goals()[force.index] = nil
  if reason then force.print({ reason, name_of(force, goal.tech) }) end
end

-- Fill free queue slots with path technologies. Candidates whose path prerequisites are
-- neither researched nor queued are skipped; the engine decides the rest.
function M.fill(force)
  local goal = M.get(force)
  if not goal or goal.paused then return end
  local t = force.technologies[goal.tech]
  if not t then M.clear(force, "ptt.goal-removed"); return end
  if t.researched then M.clear(force, "ptt.goal-reached"); return end
  if not force.research_enabled then return end
  local g = M.graph(force)
  local done = G.snapshot(force)
  local plan = G.plan(g, force, goal.tech, done)
  if not plan then return end
  local _, queued = G.queue(force)
  goal.ours = goal.ours or {}
  for _, n in ipairs(plan.order) do
    if not queued[n] then
      local ready = true
      for _, p in ipairs(g.pre[n] or {}) do
        if not done[p] and not queued[p] then ready = false; break end
      end
      if ready then
        storage.ptt_filling = true
        local ok = force.add_research(n)
        storage.ptt_filling = nil
        if ok then
          local _, now = G.queue(force)
          if now[n] then queued = now; goal.ours[n] = true else ok = false end
        end
        -- A ready candidate rejected by the engine means the queue is full.
        if not ok then break end
      end
    end
  end
end

function M.set(force, tech, player)
  local t = force.technologies[tech]
  if not t or t.researched then return false end
  goals()[force.index] = { tech = tech, by = player and player.name or nil, ours = {} }
  force.print({ "ptt.goal-set", player and player.name or "?", t.localised_name })
  M.fill(force)
  return true
end

function M.pause(force, tech)
  local goal = M.get(force)
  if not goal or goal.paused then return end
  goal.paused = tech
  force.print({ "ptt.goal-paused", name_of(force, goal.tech), name_of(force, tech) })
end

function M.resume(force)
  local goal = M.get(force)
  if not goal then return end
  goal.paused = nil
  M.fill(force)
end

-- Is `tech` still needed for the goal (part of its unresearched closure)?
function M.needed(force, tech)
  local goal = M.get(force)
  if not goal then return false end
  local plan = G.plan(M.graph(force), force, goal.tech, G.snapshot(force))
  return plan and plan.set[tech] or false
end

function M.on_finished(e)
  local force = e.research.force
  local goal = M.get(force)
  if not goal then return end
  if goal.ours then goal.ours[e.research.name] = nil end
  M.fill(force)
end

-- A player removing a technology the goal needs pauses the goal (user decision).
-- Script cancellations (including this mod's queue writes) do not pause.
function M.on_cancelled(e)
  if storage.ptt_filling then return end
  local force = e.force
  local goal = M.get(force)
  if not goal then return end
  local names = {}
  for name in pairs(e.research or {}) do names[#names + 1] = name end
  table.sort(names)
  if e.player_index and not goal.paused then
    local plan = G.plan(M.graph(force), force, goal.tech, G.snapshot(force))
    for _, name in ipairs(names) do
      if plan and plan.set[name] then
        for _, n in ipairs(names) do if goal.ours then goal.ours[n] = nil end end
        M.pause(force, name)
        return
      end
    end
  end
  for _, n in ipairs(names) do if goal.ours then goal.ours[n] = nil end end
  M.fill(force)
end

function M.validate()
  for index, goal in pairs(goals()) do
    local force = game.forces[index]
    if not force then goals()[index] = nil
    elseif not force.technologies[goal.tech] then M.clear(force, "ptt.goal-removed")
    else M.fill(force) end
  end
end

return M
