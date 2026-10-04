-- Pure deterministic graph model. No GUI, surfaces, mutable prototype data or research writes.
local M = {}

local function visible(t)
  return not t.prototype.hidden and (t.enabled or t.visible_when_disabled)
end
M.visible = visible

-- is_pack(item): true for real science packs; other research ingredients (module parts, data)
-- only define an era when a technology has no science pack at all.
function M.build(source, is_pack)
  is_pack = is_pack or function() return true end
  local g = { nodes = {}, names = {}, layers = {}, max_depth = 0, cycles = {},
    pre = {}, post = {}, eras = {}, era_of = {}, pack_rank = {}, trigger = {} }
  -- Full prerequisite map, including hidden/disabled technologies: the engine
  -- requires them for research even when the browser does not show them.
  local all = {}
  for name in pairs(source) do all[#all + 1] = name end
  table.sort(all)
  for _, name in ipairs(all) do g.post[name] = {} end
  for _, name in ipairs(all) do
    local list = {}
    for pname in pairs(source[name].prerequisites) do list[#list + 1] = pname end
    table.sort(list)
    g.pre[name] = list
    for _, pname in ipairs(list) do
      if g.post[pname] then table.insert(g.post[pname], name) end
    end
  end
  for _, name in ipairs(all) do
    if source[name].prototype.research_trigger then g.trigger[name] = true end
    if visible(source[name]) then
      g.names[#g.names + 1] = name
      g.nodes[name] = { name = name, parents = {}, children = {} }
    end
  end
  for _, name in ipairs(g.names) do
    local n = g.nodes[name]
    for _, pname in ipairs(g.pre[name]) do
      if g.nodes[pname] then
        n.parents[#n.parents + 1] = pname
        table.insert(g.nodes[pname].children, name)
      end
    end
  end
  local active = {}
  local function depth(name)
    local n = g.nodes[name]
    if n.depth then return n.depth end
    if active[name] then g.cycles[name] = true; return 0 end
    active[name] = true
    local d = 1
    for _, p in ipairs(n.parents) do d = math.max(d, depth(p) + 1) end
    active[name] = nil
    n.depth = d
    return d
  end
  for _, name in ipairs(g.names) do
    local d = depth(name)
    g.max_depth = math.max(d, g.max_depth)
    g.layers[d] = g.layers[d] or {}
    table.insert(g.layers[d], name)
    table.sort(g.nodes[name].children)
  end
  -- Stable ordering minimizes avoidable shuffling without pretending edges don't cross.
  local rank = {}
  for d = 1, g.max_depth do
    local list = g.layers[d] or {}
    local scores = {}
    for i, name in ipairs(list) do
      local sum, count = 0, 0
      for _, p in ipairs(g.nodes[name].parents) do sum = sum + (rank[p] or 0); count = count + 1 end
      scores[name] = count > 0 and sum / count or i
    end
    table.sort(list, function(a,b) return scores[a] == scores[b] and a < b or scores[a] < scores[b] end)
    for i,name in ipairs(list) do rank[name] = i; g.nodes[name].rank = i end
  end
  -- Science-pack eras. A pack ranks by the earliest dependency layer that uses it;
  -- a technology belongs to the era of its latest pack. No hand-written pack list.
  local first = {}
  for _, name in ipairs(g.names) do
    local d = g.nodes[name].depth
    for _, i in ipairs(source[name].research_unit_ingredients or {}) do
      if not first[i.name] or d < first[i.name] then first[i.name] = d end
    end
  end
  local packs = {}
  for item in pairs(first) do packs[#packs + 1] = item end
  table.sort(packs, function(a, b)
    if first[a] ~= first[b] then return first[a] < first[b] end
    return a < b
  end)
  for i, item in ipairs(packs) do g.pack_rank[item] = i end
  local by_key = {}
  local function era(key, item, order)
    if not by_key[key] then
      by_key[key] = { key = key, item = item, order = order, layers = {}, depths = {}, names = {} }
      g.eras[#g.eras + 1] = by_key[key]
    end
    return by_key[key]
  end
  for d = 1, g.max_depth do
    for _, name in ipairs(g.layers[d] or {}) do
      local best, fallback
      for _, i in ipairs(source[name].research_unit_ingredients or {}) do
        if is_pack(i.name) then
          if not best or g.pack_rank[i.name] > g.pack_rank[best] then best = i.name end
        elseif not fallback or g.pack_rank[i.name] > g.pack_rank[fallback] then fallback = i.name end
      end
      best = best or fallback
      local e = best and era(best, best, g.pack_rank[best])
      if not e then
        -- No research cost (trigger technologies): follow the latest era of the prerequisites.
        for _, p in ipairs(g.nodes[name].parents) do
          local pe = by_key[g.era_of[p]]
          if pe and (not e or pe.order > e.order) then e = pe end
        end
        e = e or era("_none", nil, 0)
      end
      g.era_of[name] = e.key
      e.names[#e.names + 1] = name
      if not e.layers[d] then e.layers[d] = {}; e.depths[#e.depths + 1] = d end
      table.insert(e.layers[d], name)
    end
  end
  table.sort(g.eras, function(a, b) return a.order < b.order end)
  return g
end

-- Cheap exact check that the visible set still matches the force (scripts may enable/disable technologies).
function M.stale(g, source)
  local count = 0
  for name, t in pairs(source) do
    local shown = visible(t)
    if shown then count = count + 1 end
    if shown ~= (g.nodes[name] ~= nil) then return true end
  end
  return count ~= #g.names
end

function M.chain(g, selected)
  local seen = {}
  local function visit(name)
    if seen[name] or not g.nodes[name] then return end
    seen[name] = true
    for _, p in ipairs(g.nodes[name].parents) do visit(p) end
  end
  if selected then
    visit(selected)
    for _, c in ipairs(g.nodes[selected] and g.nodes[selected].children or {}) do seen[c] = true end
  end
  return seen
end

-- Researched set, read once per refresh so later graph walks touch only Lua tables.
function M.snapshot(force)
  local done = {}
  for name, t in pairs(force.technologies) do if t.researched then done[name] = true end end
  return done
end

function M.queue(force)
  local list, index = {}, {}
  for i, t in ipairs(force.research_queue or {}) do list[i] = t.name; index[t.name] = i end
  return list, index
end

-- Number of unresearched technologies needed for `name`, including itself.
function M.remaining(g, done, name, mark)
  if done[name] then return 0 end
  mark.stamp = (mark.stamp or 0) + 1
  local stamp, seen, count = mark.stamp, mark.seen, 0
  local stack = { name }
  seen[name] = stamp
  while #stack > 0 do
    local n = table.remove(stack)
    count = count + 1
    for _, p in ipairs(g.pre[n] or {}) do
      if not done[p] and seen[p] ~= stamp then seen[p] = stamp; stack[#stack + 1] = p end
    end
  end
  return count
end

function M.marker() return { seen = {}, stamp = 0 } end

-- Plan to research `target`: unresearched closure split into waves.
-- Wave 1 = everything whose prerequisites are researched now.
function M.plan(g, force, target, done)
  local techs = force.technologies
  if not techs[target] or done[target] then return nil end
  local set, order = {}, {}
  local stack = { target }
  set[target] = true
  while #stack > 0 do
    local n = table.remove(stack)
    order[#order + 1] = n
    for _, p in ipairs(g.pre[n] or {}) do
      if not done[p] and not set[p] then set[p] = true; stack[#stack + 1] = p end
    end
  end
  local wave = {}
  local active = {}
  local function w(n)
    if wave[n] then return wave[n] end
    if active[n] then return 1 end
    active[n] = true
    local v = 1
    for _, p in ipairs(g.pre[n] or {}) do if set[p] then v = math.max(v, w(p) + 1) end end
    active[n] = nil
    wave[n] = v
    return v
  end
  local plan = { target = target, set = set, count = #order, waves = {}, ready = {},
    triggers = {}, blocked = {}, cost = {}, score = {}, wave = wave }
  local cost = {}
  for _, n in ipairs(order) do
    local k = w(n)
    plan.waves[k] = plan.waves[k] or {}
    table.insert(plan.waves[k], n)
    local t = techs[n]
    if not t.enabled then plan.blocked[#plan.blocked + 1] = n
    elseif t.prototype.research_trigger then
      if k == 1 then plan.triggers[#plan.triggers + 1] = n end
    else
      for _, i in ipairs(t.research_unit_ingredients or {}) do
        cost[i.name] = (cost[i.name] or 0) + i.amount * t.research_unit_count
      end
    end
  end
  -- Score: how many path technologies depend on this one (transitively).
  for _, n in ipairs(order) do
    local seen, count, s = { [n] = true }, 0, { n }
    while #s > 0 do
      local c = table.remove(s)
      for _, child in ipairs(g.post[c] or {}) do
        if set[child] and not seen[child] then seen[child] = true; count = count + 1; s[#s + 1] = child end
      end
    end
    plan.score[n] = count
  end
  local function better(a, b)
    if wave[a] ~= wave[b] then return wave[a] < wave[b] end
    if plan.score[a] ~= plan.score[b] then return plan.score[a] > plan.score[b] end
    return a < b
  end
  for _, list in pairs(plan.waves) do table.sort(list, better) end
  for _, n in ipairs(plan.waves[1] or {}) do
    local t = techs[n]
    if t.enabled and not t.prototype.research_trigger then plan.ready[#plan.ready + 1] = n end
  end
  -- Queue candidates in topological order: earlier waves first, then by score.
  plan.order = {}
  for _, n in ipairs(order) do
    local t = techs[n]
    if t.enabled and not t.prototype.research_trigger then plan.order[#plan.order + 1] = n end
  end
  table.sort(plan.order, better)
  for item, amount in pairs(cost) do plan.cost[#plan.cost + 1] = { name = item, amount = amount } end
  table.sort(plan.cost, function(a, b)
    local ra, rb = g.pack_rank[a.name] or 999, g.pack_rank[b.name] or 999
    if ra ~= rb then return ra < rb end
    return a.name < b.name
  end)
  table.sort(plan.blocked); table.sort(plan.triggers)
  return plan
end

-- ctx (optional) = { g = graph, done = snapshot }: avoids per-call API tables on large refreshes.
function M.status(force, name, queue_index, ctx)
  local t = force.technologies[name]
  if not t then return "disabled" end
  if ctx then
    if ctx.done[name] then return "done" end
  elseif t.researched then return "done" end
  if not t.enabled or not force.research_enabled then return "disabled" end
  local i = queue_index and queue_index[name]
  if not queue_index then
    for k, q in ipairs(force.research_queue or {}) do if q.name == name then i = k; break end end
  end
  if i then return i == 1 and "current" or "queued" end
  if ctx then
    for _, p in ipairs(ctx.g.pre[name] or {}) do if not ctx.done[p] then return "locked" end end
    if ctx.g.trigger[name] then return "trigger" end
  else
    for _, p in pairs(t.prerequisites) do if not p.researched then return "locked" end end
    if t.prototype.research_trigger then return "trigger" end
  end
  return "available"
end

-- Lua string.lower is ASCII-only. Explicit Russian case folding for localised search.
function M.lower(s)
  s = string.lower(s)
  s = s:gsub("\208([\144-\175])", function(b)
    local v = b:byte()
    return v < 160 and ("\208" .. string.char(v + 32)) or ("\209" .. string.char(v - 32))
  end)
  return s:gsub("Ё", "ё")
end
return M
