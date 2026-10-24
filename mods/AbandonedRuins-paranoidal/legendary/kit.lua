-- Shared runtime helpers of legendary ruins: positions, players, effects, entities, messages.
local C = require("legendary.config")

local K = {}

-- Positions ------------------------------------------------------------------------------

function K.abs(site, rx, ry) return { x = site.x + rx, y = site.y + ry } end

function K.rel(site, pos) return pos.x - site.x, pos.y - site.y end

function K.surface(site) return game.get_surface(site.surface) end

function K.area(site, margin)
  margin = margin or 0
  return {
    { site.x - site.half - margin, site.y - site.half - margin },
    { site.x + site.half + margin, site.y + site.half + margin },
  }
end

function K.inside(site, pos, margin)
  margin = margin or 0
  return math.abs(pos.x - site.x) <= site.half + margin and math.abs(pos.y - site.y) <= site.half + margin
end

---Relative point inside an inclusive tile rectangle {x1, y1, x2, y2} (relative coordinates).
function K.in_rect(rx, ry, r)
  return rx >= r[1] and ry >= r[2] and rx < r[3] + 1 and ry < r[4] + 1
end

function K.dist(a, b) return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) end

---Only the names that exist as entity prototypes (search filters reject unknown names).
function K.names(list)
  local out = {}
  for _, name in ipairs(list) do
    if prototypes.entity[name] then out[#out + 1] = name end
  end
  return out
end

-- Players --------------------------------------------------------------------------------

---Players with a character near the site: {player, char, pos, rx, ry, inside, vehicle}.
function K.players(site, margin)
  local out = {}
  for _, player in pairs(game.connected_players) do
    local char = player.character
    if char and char.valid and player.surface_index == site.surface then
      local pos = char.position
      if K.inside(site, pos, margin or C.AWAKE_MARGIN) then
        local rx, ry = pos.x - site.x, pos.y - site.y
        out[#out + 1] = {
          player = player, char = char, pos = pos, rx = rx, ry = ry,
          inside = K.inside(site, pos, 0), vehicle = player.vehicle,
        }
      end
    end
  end
  return out
end

function K.say(site, message, margin)
  for _, p in ipairs(K.players(site, margin or (C.AWAKE_MARGIN + 64))) do p.player.print(message) end
end

function K.float(site, pos, text, color)
  for _, p in ipairs(K.players(site, C.AWAKE_MARGIN)) do
    p.player.create_local_flying_text({ text = text, position = pos, color = color, time_to_live = 120 })
  end
end

-- Damage and effects ---------------------------------------------------------------------

---Scripted damage to an entity of a player force, scaled by the ferocity setting.
function K.damage(entity, amount, kind)
  if not (entity and entity.valid and entity.health) then return end
  local scaled = amount * C.ferocity().damage
  if scaled <= 0 then return end
  entity.damage(scaled, C.FORCE, kind or "physical")
end

local PLAYER_TARGETS = { "character", "car", "spider-vehicle" }

---Damages characters and vehicles of player forces in a radius.
function K.hurt(site, pos, radius, amount, kind)
  local surface = K.surface(site)
  if not surface then return end
  local legend = game.forces[C.FORCE]
  for _, e in pairs(surface.find_entities_filtered({ position = pos, radius = radius, type = PLAYER_TARGETS })) do
    if e.valid and legend and legend.is_enemy(e.force) then K.damage(e, amount, kind) end
  end
end

function K.effect(site, name, pos)
  local surface = K.surface(site)
  if surface and prototypes.entity[name] then
    surface.create_entity({ name = name, position = pos, force = C.FORCE })
  end
end

function K.explode(site, pos, radius, amount, name)
  K.effect(site, name or "big-explosion", pos)
  if amount and amount > 0 then K.hurt(site, pos, radius or 3, amount, "explosion") end
end

---A blocked-by-walls projectile of the guardians.
function K.bolt(site, from, to, speed)
  local name = C.ferocity().bolt
  local surface = K.surface(site)
  if not (name and surface and prototypes.entity[name]) then return end
  surface.create_entity({
    name = name, position = from, target = to, speed = speed or 0.7, max_range = 64, force = C.FORCE,
  })
end

function K.flame(site, pos)
  if C.ferocity().truce then return end
  K.effect(site, "fire-flame", pos)
end

function K.cloud(site, pos, name)
  if C.ferocity().truce then return end
  K.effect(site, name or "poison-cloud", pos)
end

---Sticker (slowdown, stun, burning) on a character.
function K.stick(site, entity, name)
  if C.ferocity().truce or not (entity and entity.valid) then return end
  local surface = K.surface(site)
  if surface and prototypes.entity[name] then
    surface.create_entity({ name = name, position = entity.position, target = entity, force = C.FORCE })
  end
end

function K.sound(site, path, pos)
  local surface = K.surface(site)
  if surface and helpers.is_valid_sound_path(path) then
    surface.play_sound({ path = path, position = pos })
  end
end

-- Rendering ------------------------------------------------------------------------------

local function keep(site, object, persistent)
  if persistent and object then
    site.renders = site.renders or {}
    site.renders[#site.renders + 1] = object
  end
  return object
end

function K.line(site, from, to, color, ttl, width, dash)
  return rendering.draw_line({
    surface = site.surface, from = from, to = to, color = color or { 1, 0.1, 0.1, 0.7 },
    width = width or 2, time_to_live = ttl, dash_length = dash, gap_length = dash,
  })
end

function K.circle(site, pos, radius, color, ttl, filled, persistent)
  return keep(site, rendering.draw_circle({
    surface = site.surface, target = pos, radius = radius, color = color or { 1, 0.2, 0.1, 0.35 },
    filled = filled ~= false, width = 3, time_to_live = ttl, draw_on_ground = true,
  }), persistent)
end

function K.text(site, pos, text, color, scale, ttl, persistent)
  return keep(site, rendering.draw_text({
    surface = site.surface, target = pos, text = text, color = color or { 1, 0.85, 0.3 },
    scale = scale or 1.5, time_to_live = ttl, alignment = "center", vertical_alignment = "middle",
    use_rich_text = true,
  }), persistent)
end

function K.ground_text(site, pos, text, color, scale, persistent)
  return keep(site, rendering.draw_text({
    surface = site.surface, target = pos, text = text, color = color or { 1, 1, 1 },
    scale = scale or 1, alignment = "center", vertical_alignment = "middle", draw_on_ground = true,
  }), persistent)
end

function K.arc(site, pos, r, start, angle, color, ttl)
  return rendering.draw_arc({
    surface = site.surface, target = pos, min_radius = 0.5, max_radius = r, start_angle = start,
    angle = angle, color = color or { 1, 1, 0.6, 0.25 }, time_to_live = ttl, draw_on_ground = true,
  })
end

---Cone (sector) as a triangle-strip polygon in map coordinates; angle 0 = east, y grows south.
function K.cone_vertices(pos, r, a, half, steps)
  steps = steps or 4
  local v = {}
  for i = 0, steps do
    local t = a - half + 2 * half * i / steps
    if i > 0 then v[#v + 1] = { x = pos.x, y = pos.y } end
    v[#v + 1] = { x = pos.x + math.cos(t) * r, y = pos.y + math.sin(t) * r }
  end
  return v
end

function K.cone(site, pos, r, a, half, color)
  return rendering.draw_polygon({
    surface = site.surface, vertices = K.cone_vertices(pos, r, a, half), color = color or { 1, 1, 0.55, 0.2 },
    draw_on_ground = true,
  })
end

function K.light(site, pos, scale, color, persistent)
  return keep(site, rendering.draw_light({
    surface = site.surface, target = pos, sprite = "utility/light_medium", scale = scale or 2,
    intensity = 0.8, color = color or { 1, 0.8, 0.4 },
  }), persistent)
end

function K.clear_renders(site)
  for _, object in pairs(site.renders or {}) do
    if object.valid then object.destroy() end
  end
  site.renders = nil
end

-- Entities -------------------------------------------------------------------------------

---Applies plan flags to a created entity.
function K.flags(entity, entry)
  if not entity.valid then return end
  if entry.invincible then entity.destructible = false end
  if entry.locked then entity.minable_flag = false end
  if entry.sealed then entity.operable = false end
  if entry.fixed and entity.rotatable then entity.rotatable = false end
  if entry.health and entity.health then entity.health = entity.max_health * entry.health end
end

local FORCES = { legend = C.FORCE, neutral = "neutral", enemy = "enemy" }

function K.force_name(entry)
  return FORCES[entry.force or "legend"] or entry.force
end

---Creates an entity from a plan entry (relative position) and records keys. Returns the entity.
function K.create(site, surface, entry)
  if not prototypes.entity[entry.name] then return nil end
  local quality = entry.quality
  if quality and not prototypes.quality[quality] then quality = nil end
  local params = {
    name = entry.name, position = { site.x + entry.x, site.y + entry.y },
    direction = entry.dir and defines.direction[entry.dir] or nil,
    force = K.force_name(entry), quality = quality, raise_built = false,
    create_build_effect_smoke = false, move_stuck_players = true,
  }
  if entry.recipe then params.recipe = entry.recipe end
  if entry.amount then params.amount = entry.amount end
  local entity = surface.create_entity(params)
  if not entity then return nil end
  K.flags(entity, entry)
  if entry.items then
    for name, count in pairs(entry.items) do
      if prototypes.item[name] and count > 0 then entity.insert({ name = name, count = count }) end
    end
  end
  if entry.fluids then
    for name, amount in pairs(entry.fluids) do
      if prototypes.fluid[name] then entity.insert_fluid({ name = name, amount = amount }) end
    end
  end
  if entry.key then
    site.ents = site.ents or {}
    site.ents[entry.key] = entity
    if entry.name == "pd-legend-lever" then
      -- where the lever really stands (the layout may have moved it): it comes back there
      site.lever_pos = site.lever_pos or {}
      site.lever_pos[entry.key] = { entry.x, entry.y }
    end
  end
  if entry.list then
    site.lists = site.lists or {}
    local list = site.lists[entry.list] or {}
    list[#list + 1] = entity
    site.lists[entry.list] = list
  end
  if entry.label then K.text(site, { x = entity.position.x, y = entity.position.y - 1.6 }, entry.label, nil, 1, nil, true) end
  return entity
end

---Creates an entity at runtime at a relative position with plan-like options.
function K.place(site, name, rx, ry, opts)
  local surface = K.surface(site)
  if not surface then return nil end
  local entry = { name = name, x = rx, y = ry }
  for k, v in pairs(opts or {}) do entry[k] = v end
  return K.create(site, surface, entry)
end

---Re-creates a lever after it was mined (next tick: the mined one is still there during the event).
function K.relever(site, key, rx, ry, delay)
  local L = storage.legend
  L.respawns = L.respawns or {}
  L.respawns[#L.respawns + 1] = { site = site.id, key = key, x = rx, y = ry, at = game.tick + (delay or 1) }
end

function K.process_relevers(L, tick)
  local list = L.respawns
  if not list or #list == 0 then return end
  for i = #list, 1, -1 do
    local r = list[i]
    if tick >= r.at then
      table.remove(list, i)
      local site = L.sites[r.site]
      if site and site.state == "dormant" and not K.get(site, r.key) then
        local at = site.lever_pos and site.lever_pos[r.key]
        K.place(site, "pd-legend-lever", at and at[1] or r.x, at and at[2] or r.y, { force = "neutral", key = r.key, invincible = true })
      end
    end
  end
end

function K.get(site, key)
  local e = site.ents and site.ents[key]
  if e and e.valid then return e end
  return nil
end

---Valid entities of a list (invalid ones are dropped).
function K.list(site, key)
  local list = site.lists and site.lists[key]
  if not list then return {} end
  local out = {}
  for _, e in ipairs(list) do if e.valid then out[#out + 1] = e end end
  site.lists[key] = out
  return out
end

function K.destroy_list(site, key)
  for _, e in ipairs(K.list(site, key)) do e.destroy() end
  if site.lists then site.lists[key] = nil end
end

---Guardian unit; quality raises its health (+30% per quality level).
function K.spawn(site, name, pos, quality, force)
  local surface = K.surface(site)
  if not (surface and prototypes.entity[name]) then return nil end
  local at = surface.find_non_colliding_position(name, pos, 6, 0.5) or pos
  if quality and not prototypes.quality[quality] then quality = nil end
  return surface.create_entity({ name = name, position = at, force = force or C.FORCE, quality = quality })
end

function K.command(unit, command)
  if unit and unit.valid and unit.commandable then
    unit.commandable.set_command(command)
  end
end

function K.attack(unit, target, distraction)
  K.command(unit, { type = defines.command.attack, target = target, distraction = distraction or defines.distraction.by_enemy })
end

function K.go(unit, pos, distraction)
  K.command(unit, { type = defines.command.go_to_location, destination = pos, radius = 2,
    distraction = distraction or defines.distraction.none })
end

function K.wander(unit, radius)
  K.command(unit, { type = defines.command.wander, radius = radius or 8, distraction = defines.distraction.by_enemy })
end

---Line of sight on the site's wall grid (site.data.walls: set of "x,y" relative tiles).
function K.blocked(site, rx1, ry1, rx2, ry2)
  local walls = site.data and site.data.walls
  if not walls then return false end
  local sx, sy = math.floor(rx1), math.floor(ry1)
  local ex, ey = math.floor(rx2), math.floor(ry2)
  local steps = math.ceil(math.max(math.abs(rx2 - rx1), math.abs(ry2 - ry1)) * 3)
  for i = 1, steps - 1 do
    local t = i / steps
    local x = math.floor(rx1 + (rx2 - rx1) * t)
    local y = math.floor(ry1 + (ry2 - ry1) * t)
    if not (x == sx and y == sy) and not (x == ex and y == ey) and walls[x .. "," .. y] then return true end
  end
  return false
end

-- Timers ---------------------------------------------------------------------------------

---Ticks scaled by the ferocity (harsh/truce give more time).
function K.ticks(seconds) return math.floor(seconds * 60 * C.ferocity().time) end

function K.clock(ticks)
  local s = math.max(0, math.ceil(ticks / 60))
  return string.format("%d:%02d", math.floor(s / 60), s % 60)
end

return K
