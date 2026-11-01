-- Fire safety turrets (prototypes/fire-safety-turret.lua, created from zzzparanoidal/data-final-fixes.lua).
-- Turret parameters and target lists come from mod-data "pd-fire-safety".
-- Every turret is serviced once per 2 s (spread over 12 slots: storage.fire_safety.slots[id % 12 + 1]).
-- No targets in the zone: standby water use (idle); if the water sufficed, the turret is active and
-- nothing in its zone catches fire, explodes or cooks off (M.covers, asked directly by the other modules).
-- Targets: combat water use, up to MAX_SHOTS water jets. Fire (incl. acid on the ground) and enemy clouds
-- go out when a jet lands within HIT_RADIUS; harmful stickers on friends are removed at planning time.
-- With a full water charge, targets beyond the jet limit or inside the barrel's dead zone are put out
-- at once without a jet; with too little water there are fewer jets.
--
-- The barrel is drawn here with rendering (the entity's own barrel is empty: the engine never gives the
-- turret a target), following the vanilla flamethrower turret cycle: folded -> preparing (target within
-- prepare_range) -> turning over 64 orientations at rotation_speed -> a jet from the muzzle, the barrel
-- holds aim while it flows -> folding when nothing is within prepare_range or the water ran out.
-- Only moving turrets are processed every tick (storage.fire_safety.moving); that on_nth_tick(1) handler
-- is registered only while the list is not empty (restored in on_load).
--
-- Active turrets are indexed by surface and 32x32 cell (storage.fire_safety.grid), so a protection check
-- looks only at the cells within the largest turret range. Removal is caught by on_object_destroyed.
local FO = require("scripts.registry")

local M = {}
FO.safety = M

local DATA = "pd-fire-safety"
local PERIOD = 120 -- ticks between two services of one turret
local SLOTS = 12
local STEP = PERIOD / SLOTS
local CELL = 32
local MAX_SHOTS = 4 -- jets per turret per cycle
local HIT_RADIUS = 2.5 -- one jet puts out everything within this radius of its landing point
local MAX_EFFECTS = 12 -- steam puffs per hit / per instant extinguishing
local STREAM = "pd-fire-safety-stream"
local HIT = "pd-fire-safety-hit"
local STEAM = "pd-fire-safety-steam"
local SPLASH = "water-splash" -- base game splash
local ACTIVATE = "pd-fire-safety-activate"
local DEACTIVATE = "pd-fire-safety-deactivate"
local TARGET_TYPES = { "fire", "smoke-with-trigger", "sticker" }
local HIT_TYPES = { "fire", "smoke-with-trigger" }
local RENDER_LAYER = "object" -- like gun_animation_render_layer of the flamethrower turret
local GUN_FRAMES = 64

local floor = math.floor

-- Flamethrower turret barrel geometry (base/prototypes/entity/fire.lua, fireutil).
-- Barrel axis offset from the entity centre by body direction (turret_gun_shift).
local GUN_SHIFT = {
  north = { 0, -6 / 32 },
  east = { 18.5 / 32, 9.5 / 32 },
  south = { 0, 19 / 32 },
  west = { -12 / 32, 5.5 / 32 },
}
-- Raised barrel tip relative to the axis: turret_model_info.gun_tip_raised (4 model units per tile),
-- projected as in math3d.project_vec3.
local TIP_REACH = 2.2515 / 4
local TIP_HEIGHT = 7.10942 / 4
local PROJECTION = 0.7071067811865

local DIRECTIONS = {
  [defines.direction.north] = "north",
  [defines.direction.east] = "east",
  [defines.direction.south] = "south",
  [defines.direction.west] = "west",
}

-- mod-data cache: prototypes do not change within a session.
local config
local function cfg()
  if config then return config end
  local mod_data = prototypes.mod_data[DATA]
  local d = mod_data and mod_data.data or {}
  local gun = d.gun or {}
  config = {
    tiers = {}, names = {}, max_range = 0, stickers = d.stickers or {}, clouds = d.clouds or {},
    splash = prototypes.entity[SPLASH] ~= nil,
    gun = {
      rotation_speed = gun.rotation_speed or 0.015, preparing_speed = gun.preparing_speed or 0.08,
      folding_speed = gun.folding_speed or 0.08, hold = gun.hold or 40,
      extension_frames = gun.extension_frames or 15,
    },
  }
  for name, tier in pairs(d.tiers or {}) do
    -- The barrel animations are created in the same file as the mod-data (control cannot check them).
    if prototypes.entity[name] and tier.gun and tier.extension then
      config.tiers[name] = {
        range = tier.range, turn_range = tier.turn_range,
        min_range = tier.min_range or 0, prepare_range = tier.prepare_range or tier.range,
        idle = tier.idle * PERIOD / 60, combat = tier.combat * PERIOD / 60,
        gun = tier.gun, extension = tier.extension,
      }
      config.names[#config.names + 1] = name
      config.max_range = math.max(config.max_range, tier.range)
    end
  end
  table.sort(config.names)
  return config
end

function M.names()
  return cfg().names
end

-- "Forward" vector of an entity direction (16 directions, 0 = north).
local function forward(direction)
  local angle = (direction or 0) / 16 * 2 * math.pi
  return math.sin(angle), -math.cos(angle)
end

-- A point in the turret zone: within range and within the turn_range sector around the direction.
local function in_zone(turret, tier, position)
  local tp = turret.position
  local dx, dy = position.x - tp.x, position.y - tp.y
  local distance = math.sqrt(dx * dx + dy * dy)
  if distance > tier.range then return false end
  if tier.turn_range >= 1 or distance < 0.5 then return true end
  local fx, fy = forward(turret.direction)
  return (dx * fx + dy * fy) / distance >= math.cos(tier.turn_range * math.pi)
end

local function state()
  local s = storage.fire_safety
  if not s then
    s = { turrets = {}, moving = {}, grid = {}, active_count = 0 }
    storage.fire_safety = s
  end
  return s
end

local function slots(s)
  local b = s.slots
  if not b then
    b = {}
    for i = 1, SLOTS do b[i] = {} end
    for id in pairs(s.turrets) do b[id % SLOTS + 1][id] = true end
    s.slots = b
  end
  return b
end

-- Barrel motion tick: registered only while some turret moves.
local ticking = false
local on_tick

local function tick_sync()
  local s = storage.fire_safety
  local want = s ~= nil and next(s.moving) ~= nil
  if want == ticking then return end
  ticking = want
  script.on_nth_tick(1, want and on_tick or nil)
end

local function set_moving(s, id, rec)
  s.moving[id] = rec
  tick_sync()
end

-- Spatial index of active turrets ---------------------------------------------------------------------

local function place(rec)
  local entity = rec.entity
  local p = entity.position
  rec.surface = entity.surface.index
  rec.cx, rec.cy = floor(p.x / CELL), floor(p.y / CELL)
end

local function set_active(s, id, rec, on)
  if (rec.active == true) == on then return end
  local grid = s.grid
  if on then
    local by_surface = grid[rec.surface]
    if not by_surface then
      by_surface = {}
      grid[rec.surface] = by_surface
    end
    local column = by_surface[rec.cx]
    if not column then
      column = {}
      by_surface[rec.cx] = column
    end
    local cell = column[rec.cy]
    if not cell then
      cell = {}
      column[rec.cy] = cell
    end
    cell[id] = true
    rec.active = true
    s.active_count = s.active_count + 1
  else
    local by_surface = grid[rec.surface]
    local column = by_surface and by_surface[rec.cx]
    local cell = column and column[rec.cy]
    if cell then
      cell[id] = nil
      if next(cell) == nil then column[rec.cy] = nil end
      if next(column) == nil then by_surface[rec.cx] = nil end
      if next(by_surface) == nil then grid[rec.surface] = nil end
    end
    rec.active = nil
    s.active_count = s.active_count - 1
  end
end

---Is a position inside the zone of an active turret? Called right before an ignition, detonation
---or explosion would start.
function M.covers(surface, position)
  local s = storage.fire_safety
  if not (s and s.active_count > 0) then return false end
  local by_surface = s.grid[surface.index]
  if not by_surface then return false end
  local c = cfg()
  local reach = c.max_range
  local x, y = position.x, position.y
  local turrets, tiers = s.turrets, c.tiers
  for cx = floor((x - reach) / CELL), floor((x + reach) / CELL) do
    local column = by_surface[cx]
    if column then
      for cy = floor((y - reach) / CELL), floor((y + reach) / CELL) do
        local cell = column[cy]
        if cell then
          for id in pairs(cell) do
            local rec = turrets[id]
            local entity = rec and rec.entity
            if entity and entity.valid then
              local tier = tiers[entity.name]
              if tier and in_zone(entity, tier, position) then return true end
            end
          end
        end
      end
    end
  end
  return false
end

-- Barrel -----------------------------------------------------------------------------------------------

local function direction_name(entity)
  return DIRECTIONS[entity.direction] or "north"
end

-- Barrel axis in the world.
local function gun_pivot(entity)
  local p = entity.position
  local shift = GUN_SHIFT[direction_name(entity)]
  return p.x + shift[1], p.y + shift[2]
end

-- Frame of the barrel sheet: 64 orientations counterclockwise from north (counterclockwise = true).
local function gun_frame(orientation)
  return (GUN_FRAMES - floor(orientation * GUN_FRAMES + 0.5)) % GUN_FRAMES
end

local function extension_frame(progress, c)
  return floor(progress * (c.gun.extension_frames - 1) + 0.5)
end

-- Show the current barrel state in the existing render object.
local function show(rec, tier, c)
  local render = rec.render
  if not (render and render.valid) then return end
  if rec.state == "prepared" then
    if render.animation ~= tier.gun then render.animation = tier.gun end
    render.animation_offset = gun_frame(rec.orientation)
  else
    local name = tier.extension[direction_name(rec.entity)]
    if render.animation ~= name then render.animation = name end
    render.animation_offset = extension_frame(rec.progress, c)
  end
end

-- (Re)create the barrel object: on build, body rotation and after a configuration change.
local function draw(rec, tier, c)
  local entity = rec.entity
  if rec.render and rec.render.valid then rec.render.destroy() end
  local shift = GUN_SHIFT[direction_name(entity)]
  rec.dir = entity.direction
  rec.render = rendering.draw_animation({
    animation = tier.extension[direction_name(entity)],
    animation_speed = 0,
    target = { entity = entity, offset = shift },
    surface = entity.surface,
    render_layer = RENDER_LAYER,
  })
  show(rec, tier, c)
end

local function ensure_drawn(rec, tier, c)
  if not (rec.render and rec.render.valid) or rec.dir ~= rec.entity.direction then draw(rec, tier, c) end
end

local function play(entity, path)
  entity.surface.play_sound({ path = path, position = entity.position })
end

-- Unfold the barrel (targets within prepare_range).
local function wake(s, id, rec)
  if rec.state == "folded" or rec.state == "folding" then
    play(rec.entity, ACTIVATE)
    rec.state = "preparing"
    set_moving(s, id, rec)
  end
end

-- No targets or no water: fold the barrel.
local function sleep(s, id, rec)
  rec.queue = {}
  rec.hold = 0
  if rec.state == "prepared" or rec.state == "preparing" then
    play(rec.entity, DEACTIVATE)
    rec.state = "folding"
    set_moving(s, id, rec)
  end
end

local function forget(s, id)
  local rec = s.turrets[id]
  if not rec then return end
  if rec.render and rec.render.valid then rec.render.destroy() end
  if rec.active then set_active(s, id, rec, false) end
  s.turrets[id] = nil
  slots(s)[id % SLOTS + 1][id] = nil
  if s.moving[id] then
    s.moving[id] = nil
    tick_sync()
  end
end

local function add(entity)
  local c = cfg()
  local tier = entity and entity.valid and c.tiers[entity.name]
  if not (tier and entity.unit_number) then return end
  local s = state()
  local id = entity.unit_number
  local rec = s.turrets[id]
  if not rec then
    rec = { entity = entity, state = "folded", progress = 0, orientation = (entity.direction or 0) / 16,
      queue = {}, hold = 0 }
    s.turrets[id] = rec
    script.register_on_object_destroyed(entity)
  end
  local active = rec.active
  if active then set_active(s, id, rec, false) end
  place(rec)
  if active then set_active(s, id, rec, true) end
  slots(s)[id % SLOTS + 1][id] = true
  draw(rec, tier, c)
end

-- on_init / on_configuration_changed: pick up turrets built before, redraw barrels, rebuild the indexes.
function M.sync()
  local c = cfg()
  if #c.names == 0 then
    storage.fire_safety = nil
    tick_sync()
    return
  end
  local s = state()
  for id, rec in pairs(s.turrets) do
    if not (rec.entity.valid and c.tiers[rec.entity.name]) then forget(s, id) end
  end
  s.slots = nil
  slots(s)
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({ name = c.names })) do add(entity) end
  end
  tick_sync()
end

-- on_load: restore the barrel tick registration from storage (storage is only read).
function M.on_load()
  tick_sync()
end

-- Extinguishing -----------------------------------------------------------------------------------------

-- Turret target: any fire, an enemy cloud, a harmful sticker on an own or allied entity.
local function is_target(entity, force, c)
  local kind = entity.type
  if kind == "fire" then return true end
  if kind == "smoke-with-trigger" then return c.clouds[entity.name] == true end
  if not c.stickers[entity.name] then return false end
  local host = entity.sticked_to
  if not (host and host.valid) then return false end
  local host_force = host.force
  return host_force == force or force.is_friend(host_force)
end

-- Remove a fire/cloud with steam; effects = puffs already made in this pass.
local function neutralize(surface, entity, effects)
  local position = entity.position
  entity.destroy()
  if effects < MAX_EFFECTS then
    surface.create_trivial_smoke({ name = STEAM,
      position = { position.x + math.random() - 0.5, position.y + math.random() - 0.5 } })
  end
  return effects + 1
end

-- A jet from the muzzle at the current barrel orientation.
local function shoot(rec, position)
  local entity = rec.entity
  local px, py = gun_pivot(entity)
  local phi = (rec.orientation - 0.25) * 2 * math.pi
  local from = { x = px + math.cos(phi) * TIP_REACH, y = py + (math.sin(phi) * TIP_REACH - TIP_HEIGHT) * PROJECTION }
  entity.surface.create_entity({ name = STREAM, position = from, source_position = from, target_position = position })
end

-- Shot queue of one cycle; budget = share of the extinguishing water received this cycle (0..1].
-- Targets closer than min_range are out of the barrel's reach: with a full charge they go out at once,
-- like targets beyond the jet limit.
local function plan(turret, tier, targets, budget)
  local shots = budget >= 1 and MAX_SHOTS or math.max(1, floor(MAX_SHOTS * budget))
  local surface = turret.surface
  local tp = turret.position
  local min2 = tier.min_range * tier.min_range
  local r2 = HIT_RADIUS * HIT_RADIUS
  local covered, queue, effects = {}, {}, 0
  for i, target in ipairs(targets) do
    if not covered[i] and target.valid then
      local p = target.position
      local sticker = target.type == "sticker"
      local dx, dy = p.x - tp.x, p.y - tp.y
      if #queue < shots and dx * dx + dy * dy >= min2 then
        -- Neighbours within the hit radius: fire and clouds go out from the same jet, stickers now.
        for j = i + 1, #targets do
          local other = targets[j]
          if not covered[j] and other.valid then
            local q = other.position
            local ox, oy = q.x - p.x, q.y - p.y
            if ox * ox + oy * oy <= r2 then
              covered[j] = true
              if other.type == "sticker" then other.destroy() end
            end
          end
        end
        queue[#queue + 1] = { x = p.x, y = p.y, entity = not sticker and target or nil }
        if sticker then target.destroy() end
      elseif budget >= 1 then
        if sticker then
          target.destroy()
        else
          effects = neutralize(surface, target, effects)
        end
      end
    end
  end
  return queue
end

local function service(id, rec, tier, s, c)
  local turret = rec.entity
  ensure_drawn(rec, tier, c)
  if turret.get_fluid_count("water") < tier.idle then
    set_active(s, id, rec, false)
    sleep(s, id, rec)
    return
  end
  set_active(s, id, rec, true)
  local targets, near = {}, false
  local force = turret.force
  local tp = turret.position
  for _, entity in pairs(turret.surface.find_entities_filtered({ type = TARGET_TYPES, position = tp,
    radius = tier.prepare_range })) do
    if is_target(entity, force, c) then
      if in_zone(turret, tier, entity.position) then
        targets[#targets + 1] = entity
      else
        near = true
      end
    end
  end
  if #targets == 0 then
    turret.remove_fluid({ name = "water", amount = tier.idle })
    if near then
      wake(s, id, rec)
      rec.queue = {}
    else
      sleep(s, id, rec)
    end
    return
  end
  wake(s, id, rec)
  local used = turret.remove_fluid({ name = "water", amount = tier.combat })
  rec.queue = plan(turret, tier, targets, used / tier.combat)
  if #rec.queue > 0 then set_moving(s, id, rec) end
end

local function update(event)
  local s = storage.fire_safety
  if not s then return end
  local c = cfg()
  local slot = slots(s)[floor(event.tick / STEP) % SLOTS + 1]
  -- forget() clears entries of this slot during the traversal: assigning nil to an existing key is allowed.
  for id in pairs(slot) do
    local rec = s.turrets[id]
    if not rec then
      slot[id] = nil
    else
      local tier = rec.entity.valid and c.tiers[rec.entity.name]
      if tier then
        service(id, rec, tier, s, c)
      else
        forget(s, id)
      end
    end
  end
end

-- One barrel motion tick; false = the turret no longer needs per-tick processing.
local function step(rec, tier, c)
  local g = c.gun
  if rec.state == "preparing" then
    rec.progress = math.min(1, rec.progress + g.preparing_speed)
    if rec.progress >= 1 then rec.state = "prepared" end
    show(rec, tier, c)
    return true
  end
  if rec.state == "folding" then
    rec.progress = math.max(0, rec.progress - g.folding_speed)
    if rec.progress <= 0 then rec.state = "folded" end
    show(rec, tier, c)
    return rec.state == "folding"
  end
  if rec.state ~= "prepared" then return false end
  if rec.hold > 0 then -- the jet still flows: the barrel holds aim
    rec.hold = rec.hold - 1
    return true
  end
  local queue = rec.queue
  local target = queue[1]
  while target and target.entity and not target.entity.valid do -- already out from a neighbouring jet
    table.remove(queue, 1)
    target = queue[1]
  end
  if not target then return false end
  local px, py = gun_pivot(rec.entity)
  local desired = (math.atan2(target.x - px, py - target.y) / (2 * math.pi)) % 1
  local diff = (desired - rec.orientation + 0.5) % 1 - 0.5
  if math.abs(diff) <= g.rotation_speed then
    rec.orientation = desired
    show(rec, tier, c)
    shoot(rec, target)
    table.remove(queue, 1)
    rec.hold = g.hold
  else
    rec.orientation = (rec.orientation + (diff > 0 and g.rotation_speed or -g.rotation_speed)) % 1
    show(rec, tier, c)
  end
  return true
end

on_tick = function()
  local s = storage.fire_safety
  if s then
    local c = cfg()
    for id, rec in pairs(s.moving) do
      local entity = rec.entity
      local tier = entity.valid and c.tiers[entity.name]
      if not tier then
        forget(s, id)
      else
        ensure_drawn(rec, tier, c)
        if not step(rec, tier, c) then s.moving[id] = nil end
      end
    end
  end
  tick_sync()
end

-- Events (registered by control.lua) --------------------------------------------------------------------

function M.on_built(event)
  add(event.entity or event.destination)
end

-- Body rotated/flipped: the barrel moves with it. Teleported (dollies): also re-index the cell.
function M.on_reoriented(event)
  local entity = event.entity
  if not (entity and entity.valid and entity.unit_number and storage.fire_safety) then return end
  if not cfg().tiers[entity.name] then return end
  if storage.fire_safety.turrets[entity.unit_number] then add(entity) end
end

function M.on_object_destroyed(event)
  local s = storage.fire_safety
  if s and event.type == defines.target_type.entity and s.turrets[event.useful_id] then
    forget(s, event.useful_id)
  end
end

-- The first drop of a jet landed: splash; fire and enemy clouds within the radius go out.
function M.on_hit(event)
  if event.effect_id ~= HIT then return end
  local surface = game.surfaces[event.surface_index]
  local position = event.target_position
  if not (surface and position) then return end
  local c = cfg()
  if c.splash then surface.create_entity({ name = SPLASH, position = position }) end
  local effects = 0
  for _, entity in pairs(surface.find_entities_filtered({ type = HIT_TYPES, position = position,
    radius = HIT_RADIUS })) do
    if entity.valid and (entity.type == "fire" or c.clouds[entity.name]) then
      effects = neutralize(surface, entity, effects)
    end
  end
end

M.update = update
M.STEP = STEP

return M
