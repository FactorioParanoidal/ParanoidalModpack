-- Paranoidal: animation of the "Ports" tip (prototypes/progression.lua). Left: the factory building outside with
-- belts at the ports w3 / e3 (script/layout.lua, factory-1: outside -4.5|4.5, 1.5); right: a piece of its floor
-- with the same ports inside (-15.5|15.5, 5.5), drawn here with the mod's tiles. The scene moves the items through
-- the ports as the mod's belt connections do; the mod's own script is not loaded (it would create a real factory
-- surface the tips camera cannot show). An error is shown as text (key factorissimo-tips-sim.error).
local simulations = {}

simulations.ports = {
    init_update_count = 300,
    init = [=[
local surface = game.surfaces[1]
local force = game.forces.player
local sim = game.simulation
sim.camera_position = {3, -1}
sim.camera_zoom = 0.55
sim.camera_alt_info = true
sim.hide_cursor = true
P = {stats = {moved_in = 0, moved_out = 0}}

local function fail(message)
  if P.err then return end
  P.err = tostring(message)
  pcall(log, "factorissimo tips simulation: " .. P.err)
  pcall(rendering.draw_text, {text = {"factorissimo-tips-sim.error", P.err}, surface = surface, target = {0, -8},
    color = {1, 0.35, 0.35}, scale = 1.5, alignment = "center"})
end

local function create(name, position, extra)
  local spec = {name = name, position = position, force = force, create_build_effect_smoke = false}
  for key, value in pairs(extra or {}) do spec[key] = value end
  local entity = surface.create_entity(spec)
  if not entity then error("cannot create " .. name .. " at " .. position[1] .. "," .. position[2]) end
  return entity
end

local function belt(x1, x2, y)
  local list = {}
  for x = x1, x2 do list[#list + 1] = create("transport-belt", {x, y}, {direction = defines.direction.east}) end
  return list
end

local ok, message = pcall(function()
  surface.build_checkerboard{{-60, -30}, {60, 30}}
  -- Inside: factory-1 floor, inside coordinates (ix, iy) -> (ix + 18, iy - 3)
  local OX, OY = 18, -3
  local tiles = {}
  for ix = -16, 15 do
    for iy = -16, 15 do
      -- the ports w3 / e3 (iy 5.5) are floor in the wall, as the mod's connection_tile
      local wall = (ix == -16 or ix == 15 or iy == -16 or iy == 15) and not ((ix == -16 or ix == 15) and iy == 5)
      tiles[#tiles + 1] = {name = wall and "factory-wall-1" or "factory-floor", position = {ix + OX, iy + OY}}
    end
  end
  surface.set_tiles(tiles)
  local function inside(ix, iy) return {ix + OX, iy + OY} end
  -- Outside: the building and its belts
  create("factory-1", {-18, 0})
  local feed = belt(-30.5, -22.5, 1.5)
  local out_outside = belt(-13.5, -6.5, 1.5)
  -- Inside: plates in from w3, an assembling machine makes gears, gears out at e3
  local in_inside = belt(inside(-15.5, 5.5)[1], inside(-5.5, 5.5)[1], inside(0, 5.5)[2])
  local out_inside = belt(inside(-3.5, 5.5)[1], inside(15.5, 5.5)[1], inside(0, 5.5)[2])
  local machine = create("assembling-machine-2", inside(-4.5, 2.5))
  force.recipes["iron-gear-wheel"].enabled = true
  machine.set_recipe("iron-gear-wheel")
  create("inserter", inside(-5.5, 4.5), {direction = defines.direction.south})
  create("inserter", inside(-3.5, 4.5), {direction = defines.direction.north})
  create("substation", inside(-9, 1))
  create("electric-energy-interface", inside(-11, 1))
  -- Port links: each pair (outside port <-> the same port inside) has its own colour and its own route, so the
  -- lines never overlap: plates in (green) over the top, gears out (orange) under the floor. Rings mark the ports.
  local function path(points, color)
    for i = 1, #points - 1 do
      rendering.draw_line{surface = surface, from = points[i], to = points[i + 1], color = color, width = 4,
        dash_length = 0.6, gap_length = 0.4}
    end
    local a, b = points[#points - 1], points[#points]
    local dx, dy = b[1] - a[1], b[2] - a[2]
    local length = math.sqrt(dx * dx + dy * dy)
    local ux, uy = dx / length, dy / length
    for _, s in ipairs({1, -1}) do
      rendering.draw_line{surface = surface, from = b, to = {b[1] - 1.1 * (ux * 0.87 - s * uy * 0.5), b[2] - 1.1 * (uy * 0.87 + s * ux * 0.5)},
        color = color, width = 4}
    end
    for _, p in ipairs({points[1], b}) do
      rendering.draw_circle{surface = surface, target = p, radius = 0.75, color = color, width = 4, filled = false}
    end
  end
  local w_in, e_in = inside(-15.5, 5.5), inside(15.5, 5.5)
  path({{-22.5, 1.5}, {-22.5, -8.5}, {0, -8.5}, {0, w_in[2]}, {w_in[1], w_in[2]}}, {0.5, 1, 0.4, 0.9})
  path({{e_in[1], e_in[2]}, {36.5, e_in[2]}, {36.5, 15.5}, {-13.5, 15.5}, {-13.5, 1.5}}, {1, 0.65, 0.2, 0.9})
  -- Text of the same size on screen as in the other tips scenes (about 24 px high at zoom 0.55)
  rendering.draw_text{text = {"factorissimo-tips-sim.outside"}, surface = surface, target = {-18, 7}, color = {1, 1, 1},
    scale = 2.9, font = "default-bold", alignment = "center", vertical_alignment = "middle"}
  rendering.draw_text{text = {"factorissimo-tips-sim.inside"}, surface = surface, target = {inside(0, -8)[1], inside(0, -8)[2]},
    color = {1, 1, 1}, scale = 2.9, font = "default-bold", alignment = "center", vertical_alignment = "middle"}

  local function lines(entity)
    return {entity.get_transport_line(1), entity.get_transport_line(2)}
  end
  -- Move one item from the last tile of `from` to the first tile of `to` per lane when it fits.
  local function pass(from, to)
    local moved = 0
    local src, dst = lines(from), lines(to)
    for i = 1, 2 do
      local contents = src[i].get_contents()
      local item = contents[1]
      if item and dst[i].can_insert_at_back() then
        dst[i].insert_at_back({name = item.name, quality = item.quality, count = 1})
        src[i].remove_item({name = item.name, quality = item.quality, count = 1})
        moved = moved + 1
      end
    end
    return moved
  end
  script.on_nth_tick(1, function()
    if P.err then return end
    local fine, problem = pcall(function()
      for _, line in ipairs(lines(feed[1])) do
        if line.can_insert_at_back() then line.insert_at_back({name = "iron-plate", count = 1}) end
      end
      P.stats.moved_in = P.stats.moved_in + pass(feed[#feed], in_inside[1])
      P.stats.moved_out = P.stats.moved_out + pass(out_inside[#out_inside], out_outside[1])
      for _, line in ipairs(lines(out_outside[#out_outside])) do line.clear() end
    end)
    if not fine then fail(problem) end
  end)
end)
if not ok then fail(message) end
]=],
}

return simulations
