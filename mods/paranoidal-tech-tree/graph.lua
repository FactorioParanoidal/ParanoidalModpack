-- Pure deterministic graph model. No GUI, surfaces, mutable prototype data or research writes.
local M = {}
function M.build(source)
  local g = { nodes = {}, names = {}, layers = {}, max_depth = 0, cycles = {} }
  for name, t in pairs(source) do
    if not t.prototype.hidden and (t.enabled or t.visible_when_disabled) then
      g.names[#g.names + 1] = name
      g.nodes[name] = { name = name, parents = {}, children = {} }
    end
  end
  table.sort(g.names)
  for _, name in ipairs(g.names) do
    local n = g.nodes[name]
    for pname in pairs(source[name].prerequisites) do
      if g.nodes[pname] then
        n.parents[#n.parents + 1] = pname
        table.insert(g.nodes[pname].children, name)
      end
    end
    table.sort(n.parents)
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
  return g
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
function M.status(force, name)
  local t = force.technologies[name]
  if not t then return "disabled" end
  if t.researched then return "done" end
  if not t.enabled or not force.research_enabled then return "disabled" end
  for i, q in ipairs(force.research_queue or {}) do
    if q.name == name then return i == 1 and "current" or "queued" end
  end
  if t.prototype.research_trigger then return "trigger" end
  for _, p in pairs(t.prerequisites) do if not p.researched then return "locked" end end
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
