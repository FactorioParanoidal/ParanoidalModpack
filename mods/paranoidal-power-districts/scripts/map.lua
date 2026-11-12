-- Highlighting a district, finding the bypass wire, the energy map on the game map.
local S = require("shared")
local engine = require("scripts.engine")
local U = require("scripts.util")

local M = {}
local copper = defines.wire_connector_id.pole_copper
local LIMIT_POLES = 2000

-- poles of the network reachable from `start` on the same surface
local function walk(start, limit, want_parent, goal)
  local surface = start.surface
  local seen = { [start.unit_number] = true }
  local queue = { start }
  local parent = want_parent and {} or nil
  local head = 1
  while queue[head] and #queue < limit do
    local p = queue[head]
    head = head + 1
    if goal and p == goal then break end
    local con = p.get_wire_connector(copper, false)
    if con then
      for _, c in pairs(con.real_connections) do
        local o = c.target.owner
        if o.surface == surface and not seen[o.unit_number] then
          seen[o.unit_number] = true
          queue[#queue + 1] = o
          if parent then parent[o.unit_number] = p end
        end
      end
    end
  end
  return queue, parent
end

local function area_of(pole)
  local d = pole.prototype.get_supply_area_distance(pole.quality) or 0
  local p = pole.position
  return { x = p.x - d, y = p.y - d }, { x = p.x + d, y = p.y + d }
end

function M.show_district(player, m)
  if not (m.pout and m.pout.valid) then return end
  local poles = walk(m.pout, LIMIT_POLES)
  local c = S.COLORS[m.color or 1]
  local fill = { r = c.r * 0.25, g = c.g * 0.25, b = c.b * 0.25, a = 0.25 }
  local n = 0
  for _, p in ipairs(poles) do
    local lt, rb = area_of(p)
    if rb.x > lt.x then
      rendering.draw_rectangle({ color = fill, filled = true, left_top = lt, right_bottom = rb, surface = p.surface,
        time_to_live = 600, players = { player }, draw_on_ground = true })
      rendering.draw_rectangle({ color = c, width = 2, filled = false, left_top = lt, right_bottom = rb, surface = p.surface,
        time_to_live = 600, players = { player } })
      n = n + 1
    end
  end
  player.create_local_flying_text({ text = { "ppd-flying.district", engine.name_of(m), n }, position = m.e.position, surface = m.e.surface })
end

-- the copper path from the input bushing to the output bushing
function M.find_wire(player, m)
  if not (m.pin and m.pin.valid and m.pout and m.pout.valid) then return end
  local _, parent = walk(m.pin, LIMIT_POLES * 5, true, m.pout)
  local node = m.pout
  local steps = 0
  if not parent[node.unit_number] then
    player.create_local_flying_text({ text = { "ppd-flying.no-path" }, position = m.e.position, surface = m.e.surface })
    return
  end
  while node and node ~= m.pin and steps < 5000 do
    local prev = parent[node.unit_number]
    if not prev then break end
    rendering.draw_line({ color = { 1, 0.3, 0.2 }, width = 4, from = prev, to = node, surface = node.surface,
      time_to_live = 900, players = { player } })
    node = prev
    steps = steps + 1
  end
  player.create_local_flying_text({ text = { "ppd-flying.path", steps }, position = m.e.position, surface = m.e.surface })
end

---------------------------------------------------------------- energy map (chart layer)

local function players_list()
  local list = {}
  for pi in pairs(storage.emap_players) do
    local p = game.get_player(pi)
    if p then list[#list + 1] = p end
  end
  return list
end

local function destroy_objs(objs)
  if not objs then return end
  for _, o in pairs(objs) do
    if o and o.valid then o.destroy() end
  end
end

function M.clear_all()
  for did, objs in pairs(storage.emap) do
    destroy_objs(objs)
    storage.emap[did] = nil
  end
end

local function draw_district(ds, plist)
  local lead = storage.tr[ds.lead]
  if not (lead and lead.e.valid and lead.pout and lead.pout.valid) then return nil end
  local poles = walk(lead.pout, LIMIT_POLES)
  local x1, y1, x2, y2 = math.huge, math.huge, -math.huge, -math.huge
  for _, p in ipairs(poles) do
    local lt, rb = area_of(p)
    if rb.x > lt.x then
      if lt.x < x1 then x1 = lt.x end
      if lt.y < y1 then y1 = lt.y end
      if rb.x > x2 then x2 = rb.x end
      if rb.y > y2 then y2 = rb.y end
    end
  end
  local surface = lead.e.surface
  local objs = {}
  local st = engine.STATUS[ds.status] or engine.STATUS.idle
  local c = S.COLORS[lead.color or 1]
  if x1 < x2 then
    objs[#objs + 1] = rendering.draw_rectangle({ color = { r = c.r * 0.3, g = c.g * 0.3, b = c.b * 0.3, a = 0.3 }, filled = true,
      left_top = { x1, y1 }, right_bottom = { x2, y2 }, surface = surface, players = plist, render_mode = "chart" })
    objs[#objs + 1] = rendering.draw_rectangle({ color = st.color, width = 3, filled = false,
      left_top = { x1, y1 }, right_bottom = { x2, y2 }, surface = surface, players = plist, render_mode = "chart" })
  end
  local b = math.floor((ds.bonus or 0) * 1000 + 0.5)
  local text = { "", engine.name_of(lead), " · ", math.floor((ds.r or 0) * 100 + 0.5), " %" }
  if b > 0 then text[#text + 1] = { "", " · +", U.num(b / 10, 1), " %" } end
  objs[#objs + 1] = rendering.draw_text({ text = text, surface = surface, target = lead.e.position, color = st.color,
    scale = 1.4, alignment = "center", players = plist, render_mode = "chart", scale_with_zoom = true })
  for _, u in ipairs(ds.units or {}) do
    local m = storage.tr[u]
    if m and m.e.valid then
      objs[#objs + 1] = rendering.draw_sprite({ sprite = "item/" .. m.e.name, target = { type = "entity", entity = m.e, offset = { 0, 1.2 } },
        surface = surface, x_scale = 1, y_scale = 1, players = plist, render_mode = "chart" })
    end
  end
  return objs
end

function M.toggle(player)
  local pi = player.index
  if storage.emap_players[pi] then storage.emap_players[pi] = nil else storage.emap_players[pi] = true end
  M.redraw_all()
  return storage.emap_players[pi] ~= nil
end

function M.redraw_all()
  M.clear_all()
  local plist = players_list()
  if #plist == 0 then return end
  for did, ds in pairs(storage.dist) do
    storage.emap[did] = draw_district(ds, plist)
  end
end

-- called every 60 ticks: redraw one district (round robin) while somebody has the map on
function M.tick()
  if next(storage.emap_players) == nil then return end
  local plist = players_list()
  if #plist == 0 then return end
  local key = storage.emap_cursor
  if key ~= nil and storage.dist[key] == nil then key = nil end
  key = next(storage.dist, key)
  storage.emap_cursor = key
  for did, objs in pairs(storage.emap) do
    if not storage.dist[did] then
      destroy_objs(objs)
      storage.emap[did] = nil
    end
  end
  if key == nil then return end
  destroy_objs(storage.emap[key])
  storage.emap[key] = draw_district(storage.dist[key], plist)
end

return M
