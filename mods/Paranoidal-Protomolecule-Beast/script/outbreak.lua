-- The outbreak, one per map. It lands weak at an outpost and takes what it can there without a fight, withdraws to a lair
-- further out, founds its core there and builds up, then raids the base (and unclaimed ruins) for what it needs and
-- carries it home. Power comes first: whatever makes or stores it is carried home before anything else, and then what it
-- attacks with: artillery, vehicles and trains.
--
-- The lair runs on power: the core's own, slow, which gives one research stage per research-minutes, and that of every
-- stolen power building set down there, which speeds research up and fills the energy store. Each stage opens new kinds
-- of buildings it can take (forms), new ways to spread (vectors) and a stronger, faster body. It can only ever make what it
-- has carried home and analysed (the samples in its catalogue): from those it clones buildings for mass and energy, in the
-- lair and, as turrets, beside its raids. Mass comes from the core itself, from stolen drills in the lair and from spare
-- copies taken apart. Its own track to the player's railway, its trains and raids by train (lair_rails.lua) and its
-- artillery and spidertrons (lair_arms.lua) are separate libraries on top of this one, hooked in here.
--
-- Elsewhere the infection only spreads inside a zone: the landing site while it lands, a raid's target while the raid
-- lasts, and where a spore shell lands. What's left infected outside one lies dormant until a zone covers it again. When
-- the core dies, everything it took or made is put back with a random Paranoidal defect, and the protomolecule is gone.
--
-- Until a carrier reaches the lair's site it lives as a seed in what it infected (seed.lua, on_every_update): it never
-- dies there of itself, only when the player cures the last of it (the user's decision of 2026-11-05).
--
-- 2.1: nothing here needs changing as far as the 2.1.24 API goes (see AGENT-NOTES.md, "Porting to 2.1").
local shared = require("shared")
local config = require("script.config")
local infection = require("script.infection")
local contents = require("script.contents")

local outbreak = {}

local force_name = "the-beast"
local target_force = "player"
local core_name = "beast-lair-core"
local minute = 60 * 60
local update_interval = 60
local heal_interval = 120
local home_radius = 30
local found_radius = 24
-- How long its carriers have to get to the lair's site before it's founded wherever the nearest of them got to.
local found_timeout = 20 * minute
local landing_zone_extra = 16
local raid_travel_timeout = 15 * minute
local raid_arrive_extra = 8
local raid_retry = 2 * minute
local raid_bite = 3
local raid_bite_radius = 8
local raid_search_step = 48
local raid_search_radius = 64
local raid_search_steps = 40
-- At most this many buildings are weighed for one raid, however big the base.
local raid_candidates = 240
local raid_party = 4
local raid_party_per_tier = 2
local raid_pick_radius = 80
-- When it could raid by train or on foot, by train if that's worth more, and otherwise this often anyway.
local ride_share = 0.5
-- What guards a target. Artillery doesn't: it can't fire at anything close.
local turret_types = {"ammo-turret", "electric-turret", "fluid-turret"}
local turret_sight = 24
local heal_radius = 40
local heal_share = 0.01
local core_heal_share = 0.0025
local flee_ratio = 0.4
local flee_ticks = 2 * minute
local analysis_ticks = 60 * 60
local analysis_per_machine = 0.25
local analysis_machines = 8
local site_turns = {0, 0.35, -0.35, 0.7, -0.7}
local site_ore = 50
-- Every so often the lair's sums are counted again from scratch, in case an event was missed.
local recount_interval = 5 * minute
-- What it learns from wherever it opens a zone: rails, to lay its own track, and a train stop, for its lure.
local rail_types = {"straight-rail", "curved-rail-a", "curved-rail-b", "half-diagonal-rail", "legacy-straight-rail", "legacy-curved-rail"}
outbreak.rail_sample = "straight-rail"
outbreak.stop_sample = "train-stop"
local zone_samples = {[outbreak.rail_sample] = rail_types, [outbreak.stop_sample] = {"train-stop"}}
-- Where a spore shell lands: a zone this big for this long, and this many buildings infected at once.
local spore_radius = 10
local spore_ticks = 2 * minute
local spore_infections = 3

-- Power, in watts and joules. The core's own power gives one research stage per research-minutes; stolen power speeds it
-- up, halfway to the fastest at half_power and never beyond max_research_speed.
local base_power = 1e6
local half_power = 20e6
local max_research_speed = 6
local base_capacity = 600e6
-- A stolen accumulator holds this many times its own buffer for the lair, as it rewrites how it works.
local accumulator_factor = 100

-- Mass, in tiles of building: from the core itself and from each stolen drill in the lair, per second; beyond keep_copies
-- of the same building, further ones carried home are taken apart for theirs. Power buildings are never taken apart.
local base_mass = 1 / 30
local drill_mass = 1 / 10
local keep_copies = 2

-- Cloning: once every clone_interval, if there's the mass (a tile's worth per tile) and the energy for it. Turrets first,
-- while the lair has fewer than guards_base + guards_per_tier of them, and then half the time.
local clone_interval = 10 * 60
local clone_energy_per_tile = 20e6
local clone_ring = {min = 8, max = 30}
local turret_ring = {min = 10, max = 20}
local raid_clone_ring = {min = 4, max = 9}
local guards_base = 4
local guards_per_tier = 2
local turret_share = 0.5
-- Beyond this many turrets of its own the lair clones other buildings, and beyond this many artillery turrets no more of
-- those: idle turrets by the hundred cost the game time for nothing.
local guards_cap = 60
local artillery_cap = 8
local ammo_per_load = 10
-- Turrets are fed this many at a time each time it clones, so that a lair of hundreds costs no more per tick.
local arm_batch = 60
local armed_types = {["ammo-turret"] = true, ["electric-turret"] = true}
-- Not cloned: rolling stock needs rails under it, a flamethrower turret something to burn, vehicles fuel and a driver,
-- and artillery is only fired by its script (lair_arms.lua), which clones of it would need too.
local not_cloned =
{
  ["locomotive"] = true, ["cargo-wagon"] = true, ["fluid-wagon"] = true, ["artillery-wagon"] = true, ["fluid-turret"] = true,
  ["car"] = true, ["spider-vehicle"] = true
}

-- Raid targets: power counts most, a reactor most of all, then what it attacks with. Ruins are near its lair and
-- undefended, so early on, before it will fight, they're what it goes for, unless there's power to be had.
local energy_score = 40
local reactor_score = 80
local assault_score = 30
local ruin_score_early = 25
local ruin_score = 5
local ruin_search_radius = 300
-- A raid that has infected power stays, and calls everyone at home over, until that's carried off, but only this many
-- times its duration.
local energy_hold = 3
-- How far a building of a legendary ruin can be from that ruin's own guardians and structure.
local legend_radius = 128

-- What each stage of its research gives it, in order. Speed rises evenly over all of them, from the start setting to the
-- end one. unlock: the types of building it can take from then on; armor: the share of damage it shrugs off; regen: how
-- much faster the lair heals; fight: it no longer keeps out of fights on a raid; artillery: its artillery fires shells at
-- the player's turrets and radars; lure: its station takes the name of one of the player's; vector "wires": it passes
-- along copper wires between poles; party: more creatures on each raid; spores: its artillery fires spore shells at any
-- building instead. Power, artillery, vehicles, trains and ruins it can take from the start.
outbreak.tiers =
{
  {unlock = {"assembling-machine", "furnace"}},
  {fight = true},
  {armor = 0.15},
  {unlock = {"ammo-turret", "electric-turret"}, artillery = true},
  {unlock = {"pipe", "pipe-to-ground", "storage-tank", "pump", "fluid-turret"}},
  {armor = 0.3, regen = 2},
  {lure = true},
  {vector = "wires"},
  {unlock = {"roboport"}},
  {armor = 0.45, party = 4, spores = true}
}

-- The stage at which each type can first be taken. What isn't listed it can take from the start.
local type_tier = {}
for tier, stage in ipairs(outbreak.tiers) do
  for _, type in pairs(stage.unlock or {}) do type_tier[type] = tier end
end

local function data()
  return storage.outbreak
end
outbreak.state = data

local function effects_of(tier)
  local effects = {armor = 0, regen = 1, fight = false, wires = false, party = 0, artillery = false, lure = false, spores = false}
  for i = 1, tier do
    local stage = outbreak.tiers[i]
    if stage.armor then effects.armor = stage.armor end
    if stage.regen then effects.regen = stage.regen end
    if stage.fight then effects.fight = true end
    if stage.artillery then effects.artillery = true end
    if stage.lure then effects.lure = true end
    if stage.spores then effects.spores = true end
    if stage.vector == "wires" then effects.wires = true end
    if stage.party then effects.party = effects.party + stage.party end
  end
  return effects
end

local function ordered(a, b)
  if a > b then return b, a end
  return a, b
end

local function distance_squared(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  return dx * dx + dy * dy
end
outbreak.distance_squared = distance_squared

-- Whether there's an outbreak going on now, as opposed to none yet or one that's over.
function outbreak.active()
  local state = data()
  return state ~= nil and state.phase ~= nil and state.phase ~= "over"
end

function outbreak.surface()
  local state = data()
  return state and game.get_surface(state.surface)
end

-- Where it's going back to: its core, or until there is one, the site it picked for it.
function outbreak.home()
  local state = data()
  if not state then return nil end
  if state.core and state.core.valid then return state.core.position end
  return state.site
end

-- 1 without an outbreak, which is the creatures' own pace.
function outbreak.speed()
  if not outbreak.active() then return 1 end
  local start, finish = config.get("start-speed") / 100, config.get("end-speed") / 100
  return start + (finish - start) * data().tier / #outbreak.tiers
end

function outbreak.has_core()
  local state = data()
  return outbreak.active() and state.core ~= nil and state.core.valid
end

function outbreak.tier()
  local state = data()
  return state and state.tier or #outbreak.tiers
end

-- What its research has given it so far (effects_of), or nil without an outbreak.
function outbreak.effects()
  local state = data()
  return outbreak.active() and state.effects or nil
end

function outbreak.may_fight()
  local state = data()
  return not outbreak.active() or state.effects.fight
end

-- Only once its research has got that far. Without an outbreak poles never pass it on, as they never did.
infection.wire_filter = function()
  return outbreak.active() and data().effects.wires
end

-- The ruins' forces there are in this game.
local function ruin_forces()
  local forces = {}
  for _, name in pairs(shared.ruin_forces) do
    if game.forces[name] then forces[#forces + 1] = name end
  end
  return forces
end

local function ruins_on()
  return outbreak.active() and config.get("capture-ruins")
end

-- A building of a ruin that nobody has claimed yet, or what's left of one: not one of a legendary ruin, whose buildings
-- are kept from harm or from being taken, or stand near its guardians and structure. Decided once per building.
infection.ruin_filter = function(entity)
  if not ruins_on() then return false end
  local force = entity.force.name
  if force ~= shared.ruin_forces[1] and force ~= shared.ruin_forces[2] then return false end
  if not (entity.destructible and entity.minable) then return false end
  local state = data()
  local known = state.ruin_ok[entity.unit_number]
  if known == nil then
    known = not (game.forces[shared.legendary_force] and entity.surface.count_entities_filtered{position = entity.position, radius = legend_radius, force = shared.legendary_force, limit = 1} > 0)
    state.ruin_ok[entity.unit_number] = known
  end
  return known
end

infection.extra_forces = function()
  if ruins_on() then return ruin_forces() end
end

local function in_zone(state, surface_index, position)
  for _, zone in pairs(state.zones) do
    if zone.surface == surface_index and game.tick < zone.until_tick and distance_squared(zone, position) <= zone.radius * zone.radius then return true end
  end
  return false
end

-- Without an outbreak (a building infected by another mod's script, say), it spreads as it always did.
infection.zone_filter = function(entity)
  local state = data()
  if not (state and state.phase) then return true end
  if state.phase == "over" then return false end
  return in_zone(state, entity.surface.index, entity.position)
end

infection.type_filter = function(type)
  local state = data()
  if not (state and state.phase) then return true end
  return (type_tier[type] or 0) <= state.tier
end

-- Where a creature should be heading now, and what for: a raid's target, or home. Nothing means it acts where it is, as
-- it's in a zone; "idle" that it's at home with nothing to do.
function outbreak.goal(record, entity)
  local state = data()
  if not outbreak.active() or entity.surface.index ~= state.surface then return nil end
  local position = entity.position
  local home = outbreak.home()
  local fleeing = record.flee_until and game.tick < record.flee_until
  -- Aboard its train at a raid by train, with what it's lifted, or to go home with the rest (lair_rails.lua).
  if not fleeing and outbreak.ride then
    local train_at = outbreak.ride(record, entity)
    if train_at then return train_at, "ride" end
  end
  if not fleeing and not record.cargo then
    if record.raid then
      local raid = state.raid
      if raid and raid.id == record.raid then
        if not raid.arrived or not in_zone(state, state.surface, position) then return raid.position, "raid" end
        return nil
      end
      record.raid = nil
    end
    if in_zone(state, state.surface, position) then return nil end
  end
  if distance_squared(position, home) <= home_radius * home_radius then return nil, "idle" end
  return home, "home"
end

local function area_of(name)
  local prototype = prototypes.entity[name]
  return prototype and math.max(1, prototype.tile_width * prototype.tile_height) or 1
end

local function quality_or_nil(name)
  return name and prototypes.quality[name] and name or nil
end

-- Taken apart and understood, one at a time, the bigger the slower. Only then can it make one of its own.
function outbreak.add_samples(cargo)
  local state = data()
  if not state then return end
  for _, name in pairs(cargo.samples or {cargo.place}) do
    if not state.catalogue[name] and prototypes.entity[name] then
      state.catalogue[name] = {tick = game.tick, quality = cargo.quality}
      state.queue[#state.queue + 1] = name
    end
  end
end

function outbreak.analysed(name)
  local state = data()
  local entry = state and state.catalogue[name]
  return entry ~= nil and entry.analysed ~= nil
end

local function message(key, ...)
  local force = game.forces[target_force]
  if force then force.print({key, ...}, {color = {r = 1, g = 0.2, b = 0.3}}) end
end
outbreak.message = message

-- Rails in a zone give it a sample of them, which is how it learns to lay its own, and a train stop one of those, for its
-- lure (lair_rails.lua).
local function learn_from(state, surface, position, radius)
  for sample, types in pairs(zone_samples) do
    if not state.catalogue[sample] and prototypes.entity[sample]
      and surface.count_entities_filtered{position = position, radius = radius, type = types, limit = 1} > 0 then
      outbreak.add_samples{place = sample}
    end
  end
end

-- A zone where the infection spreads for a while. key: one that's kept up from one update to the next (the seed's,
-- seed.lua) rather than opened anew.
local function open_zone(state, surface, position, radius, ticks, key)
  local zones = {}
  for _, zone in pairs(state.zones) do
    if game.tick < zone.until_tick then zones[#zones + 1] = zone end
  end
  zones[#zones + 1] = {surface = surface.index, x = position.x, y = position.y, radius = radius, until_tick = game.tick + ticks, key = key, learned = radius}
  state.zones = zones
  learn_from(state, surface, position, radius)
end

function outbreak.open_zone(surface, position, radius, ticks)
  local state = data()
  if outbreak.active() then open_zone(state, surface, position, radius, ticks) end
end

-- The zone by this key moved, grown or kept open, or opened. What's in it is looked at again for samples only when it has
-- moved or grown by a few tiles.
function outbreak.keep_zone(key, surface, position, radius, ticks)
  local state = data()
  if not outbreak.active() then return end
  for _, zone in pairs(state.zones) do
    if zone.key == key and game.tick < zone.until_tick then
      local moved = zone.surface ~= surface.index or distance_squared(zone, position) > 16
      zone.surface, zone.x, zone.y, zone.radius, zone.until_tick = surface.index, position.x, position.y, radius, game.tick + ticks
      if moved or radius >= (zone.learned or 0) + 4 then
        zone.learned = radius
        learn_from(state, surface, position, radius)
      end
      return
    end
  end
  open_zone(state, surface, position, radius, ticks, key)
end

function outbreak.close_zone(key)
  local state = data()
  if not state then return end
  local zones = {}
  for _, zone in pairs(state.zones or {}) do
    if zone.key ~= key then zones[#zones + 1] = zone end
  end
  state.zones = zones
end

local function analyse(state)
  local current = state.analysing
  if current and game.tick >= current.done then
    local entry = state.catalogue[current.name]
    if entry then entry.analysed = game.tick end
    state.analysing = nil
    state.templates = nil
    current = nil
  end
  if current or #state.queue == 0 then return end
  local name = table.remove(state.queue, 1)
  local prototype = prototypes.entity[name]
  local size = prototype and math.max(prototype.tile_width, prototype.tile_height, 1) or 1
  -- Its stolen machines help take things apart.
  local speed = 1 + 0.1 * state.tier + analysis_per_machine * math.min(state.machines or 0, analysis_machines)
  state.analysing = {name = name, done = game.tick + math.floor(analysis_ticks * size / speed)}
end

-- What a stolen building gives the lair: its power (W) and the energy it lets the lair hold (J). By its prototype's
-- theoretical maximum, as the lair runs it without fuel, wind or sun: boilers and reactors by what they'd consume, the rest
-- by what they'd produce. Kept per name and quality for the session only, as it's all from prototypes.
-- 2.1: get_max_energy_production, get_max_energy_usage and electric_energy_source_prototype.buffer_capacity are in 2.1.24.
local ratings = {}
local function rating(entity)
  local key = entity.name .. "/" .. entity.quality.name
  local found = ratings[key]
  if found then return found end
  found = {power = 0, capacity = 0}
  if shared.is_energy_type[entity.type] then
    local prototype, quality = entity.prototype, entity.quality
    local consumes = entity.type == "boiler" or entity.type == "reactor"
    local ok, value = pcall(function()
      if consumes then return prototype.get_max_energy_usage(quality) end
      return prototype.get_max_energy_production(quality)
    end)
    if ok and type(value) == "number" then found.power = value * 60 end
    if entity.type == "accumulator" then
      local ok_capacity, capacity = pcall(function()
        local source = prototype.electric_energy_source_prototype
        return source and source.buffer_capacity
      end)
      if ok_capacity and type(capacity) == "number" then found.capacity = capacity * accumulator_factor end
    end
  end
  ratings[key] = found
  return found
end

-- The lair's buildings are kept by unit number, with their sums kept up as they come and go, so that a lair of hundreds
-- costs nothing per tick (lair-max-buildings). on_object_destroyed takes them off again.
local function add_to_sums(state, building, sign)
  local entity = building.entity
  local given = building.rating
  state.power = state.power + sign * given.power
  state.capacity = state.capacity + sign * given.capacity
  state.count = state.count + sign
  local type = building.type
  if type == "mining-drill" then state.drills = state.drills + sign end
  if type == "assembling-machine" or type == "furnace" then state.machines = state.machines + sign end
  if armed_types[type] then
    state.guards = state.guards + sign
    state.armed[building.unit_number] = sign > 0 or nil
  end
  if not building.clone then state.copies[building.name] = (state.copies[building.name] or 0) + sign end
  if outbreak.on_building and entity.valid then outbreak.on_building(building, sign) end
end

-- Its buildings in the lair stand idle, all but the turrets that guard it: what they give it (power, mass, analysis) is
-- reckoned, not run. So a stolen reactor with fuel in it doesn't heat up, furnaces don't smelt and radars don't chart,
-- and a lair of hundreds costs the game next to nothing.
local function idle(entity)
  if not entity.valid then return end
  if not armed_types[entity.type] then entity.disabled_by_script = true end
  entity.custom_status = {diode = defines.entity_status_diode.red, label = {"the-beast.assimilated"}}
end

local function add_building(state, entity, owner, clone)
  idle(entity)
  local building = {entity = entity, owner = owner, clone = clone or nil, unit_number = entity.unit_number, name = entity.name, type = entity.type, rating = rating(entity)}
  state.buildings[entity.unit_number] = building
  script.register_on_object_destroyed(entity)
  add_to_sums(state, building, 1)
  return building
end

local function remove_building(state, unit_number)
  local building = state.buildings[unit_number]
  if not building then return end
  state.buildings[unit_number] = nil
  add_to_sums(state, building, -1)
end

-- From scratch: at load, after a configuration change, and now and then.
local function recount(state)
  state.power, state.capacity, state.count, state.drills, state.machines, state.guards = base_power, base_capacity, 0, 0, 0, 0
  state.armed, state.copies = {}, {}
  local buildings = state.buildings
  state.buildings = {}
  for _, building in pairs(buildings) do
    local entity = building.entity
    if entity and entity.valid then
      idle(entity)
      building.unit_number, building.name, building.type, building.rating = entity.unit_number, entity.name, entity.type, rating(entity)
      state.buildings[entity.unit_number] = building
      add_to_sums(state, building, 1)
    end
  end
  state.next_recount = game.tick + recount_interval
end

function outbreak.spend_mass(amount)
  local state = data()
  if not (outbreak.active() and state.mass >= amount) then return false end
  state.mass = state.mass - amount
  return true
end

function outbreak.spend_energy(amount)
  local state = data()
  if not (outbreak.active() and state.energy >= amount) then return false end
  state.energy = state.energy - amount
  return true
end

-- What it draws from the player's network (seed.lua, leech_power) counts as stolen power too.
local function research_speed(state)
  local extra = math.max(0, (state.power or base_power) - base_power) + (state.leech_power or 0)
  return 1 + (max_research_speed - 1) * extra / (extra + half_power)
end

-- Unpacked beside its core, as the outbreak's own, with who it was taken from and what was in it. Not raised as built, so
-- no other mod's script takes it on. Beyond a couple of each it's taken apart for its mass instead, unless it's power, and
-- what was in it is left on the ground there.
function outbreak.place_cargo(surface, cargo, near)
  local state = data()
  local prototype = prototypes.entity[cargo.place]
  if not (state and state.core and state.core.valid) or not prototype then return false end
  if not shared.is_energy_type[prototype.type] and (state.copies[cargo.place] or 0) >= keep_copies then
    state.mass = (state.mass or 0) + area_of(cargo.place)
    surface.create_trivial_smoke{name = "beast-spores", position = near}
    contents.spill(surface, near, cargo.contents)
    cargo.contents = nil
    return true
  end
  local spot = surface.find_non_colliding_position(cargo.place, near, 16, 1)
  if not spot then return false end
  local building = surface.create_entity{name = cargo.place, position = spot, force = force_name, quality = quality_or_nil(cargo.quality), create_build_effect_smoke = false}
  if not building then return false end
  contents.restore(building, cargo.contents)
  cargo.contents = nil
  add_building(state, building, cargo.owner or target_force)
  surface.create_trivial_smoke{name = "beast-spores", position = spot}
  return true
end

-- The ammunition a turret or vehicle of this kind takes, cheapest by item order, or false. Its categories are its own
-- attack's or its guns'. Once per name for the session.
local ammo_for = {}
function outbreak.ammo_of(entity)
  local name = entity.name
  if ammo_for[name] ~= nil then return ammo_for[name] end
  local categories = {}
  local prototype = entity.prototype
  local function take(parameters)
    for _, category in pairs(parameters and parameters.ammo_categories or {}) do categories[category] = true end
  end
  take(prototype.attack_parameters)
  local ok, guns = pcall(function() return prototype.indexed_guns end)
  for _, gun in pairs(ok and guns or {}) do take(gun.attack_parameters) end
  local best
  for _, item in pairs(prototypes.get_item_filtered{{filter = "type", type = "ammo"}}) do
    local category = item.ammo_category
    category = category and (type(category) == "string" and category or category.name)
    if category and categories[category] and not item.hidden and (not best or item.order < best.order) then best = item end
  end
  ammo_for[name] = best and best.name or false
  return ammo_for[name]
end

-- Its turrets are fed by the lair: ammunition for mass, a full buffer for energy. free: for one just cloned.
-- 2.1: LuaEntity.energy is writable in both; an electric turret off any network firing from it is a hypothesis.
local function arm(state, entity, free)
  if not entity.valid then return end
  if entity.type == "ammo-turret" then
    local ammo = outbreak.ammo_of(entity)
    local inventory = ammo and entity.get_inventory(defines.inventory.turret_ammo)
    if inventory and inventory.get_item_count() < ammo_per_load and (free or state.mass >= 1) then
      if not free then state.mass = state.mass - 1 end
      entity.insert{name = ammo, count = ammo_per_load}
    end
  elseif entity.type == "electric-turret" then
    local size = entity.electric_buffer_size
    if size and entity.energy < size then
      local need = size - entity.energy
      if free or state.energy >= need then
        if not free then state.energy = state.energy - need end
        entity.energy = size
      end
    end
  end
end

-- A batch at a time, carrying on from where the last one stopped.
local function arm_some(state)
  local key = state.arm_cursor
  if key ~= nil and not state.armed[key] then key = nil end
  for _ = 1, arm_batch do
    key = next(state.armed, key)
    if key == nil then break end
    local building = state.buildings[key]
    if building then arm(state, building.entity) end
  end
  state.arm_cursor = key
  for _, clone in pairs(state.raid and state.raid.clones or {}) do arm(state, clone) end
end

-- What it can clone: analysed samples of the kinds of building it can take by now. kind "turrets": only those it can arm;
-- "other": all but those. Kept until a sample is analysed or a stage is reached.
local function templates(state, kind)
  local key = kind or "all"
  state.templates = state.templates or {}
  if state.templates[key] then return state.templates[key] end
  local list = {}
  for name, entry in pairs(state.catalogue) do
    local prototype = entry.analysed and prototypes.entity[name]
    local armed = prototype and armed_types[prototype.type]
    if prototype and not not_cloned[prototype.type] and shared.source_info(name)
      and (kind ~= "turrets" or armed) and (kind ~= "other" or not armed)
      and (type_tier[prototype.type] or 0) <= state.tier then
      list[#list + 1] = name
    end
  end
  table.sort(list)
  state.templates[key] = list
  return list
end

-- A clone of a sample somewhere in a ring round a centre, if there's room and it can pay for it. free: for admins and tests.
local function clone_at(state, surface, name, center, ring, free)
  local angle, reach = math.random() * 2 * math.pi, ring.min + math.random() * (ring.max - ring.min)
  local spot = surface.find_non_colliding_position(name, {x = center.x + math.cos(angle) * reach, y = center.y + math.sin(angle) * reach}, 8, 1)
  if not spot then return nil end
  local area = area_of(name)
  if not free then
    if state.mass < area or state.energy < area * clone_energy_per_tile then return nil end
    state.mass = state.mass - area
    state.energy = state.energy - area * clone_energy_per_tile
  end
  local clone = surface.create_entity{name = name, position = spot, force = force_name, quality = quality_or_nil(state.catalogue[name].quality), create_build_effect_smoke = false}
  if not clone then return nil end
  surface.create_trivial_smoke{name = "beast-spores", position = spot}
  arm(state, clone, true)
  return clone
end

local function clone_in_lair(state, free)
  if not free and not (config.get("lair-clones") and state.count < config.get("lair-max-buildings")) then return false end
  local turrets = state.guards < guards_cap and templates(state, "turrets") or {}
  local others = templates(state, "other")
  local name, ring
  if #turrets > 0 and (#others == 0 or state.guards < guards_base + guards_per_tier * state.tier or math.random() < turret_share) then
    name, ring = turrets[math.random(#turrets)], turret_ring
  elseif #others > 0 then
    name, ring = others[math.random(#others)], clone_ring
  else
    return false
  end
  if prototypes.entity[name].type == "artillery-turret" and table_size(state.artillery or {}) >= artillery_cap then return false end
  local clone = clone_at(state, state.core.surface, name, state.core.position, ring, free)
  if not clone then return false end
  add_building(state, clone, target_force, true)
  state.clones_made = (state.clones_made or 0) + 1
  return true
end

-- Turrets cloned beside a raid, to cover it while it's there. They break down when it goes.
local function clone_at_raid(state, raid, surface)
  local turrets = templates(state, "turrets")
  if #turrets == 0 then return end
  raid.clones = raid.clones or {}
  for _ = 1, config.get("raid-clones") do
    local clone = clone_at(state, surface, turrets[math.random(#turrets)], raid.position, raid_clone_ring)
    if clone then
      raid.clones[#raid.clones + 1] = clone
      state.clones_made = (state.clones_made or 0) + 1
    end
  end
end

local function dissolve(entity)
  if not entity.valid then return end
  entity.surface.create_trivial_smoke{name = "beast-spores", position = entity.position}
  entity.destroy{raise_destroy = true}
end

-- Ahead of any creature getting there, so that the way there and the lair itself can be walked.
local function generate_way(surface, from, to)
  local dx, dy = to.x - from.x, to.y - from.y
  local steps = math.max(1, math.floor(math.sqrt(dx * dx + dy * dy) / 32))
  for i = 0, steps do
    surface.request_to_generate_chunks({x = from.x + dx * i / steps, y = from.y + dy * i / steps}, 0)
  end
end

-- Further out from the base than where it landed, on dry land well clear of the player's buildings, and on ore if any
-- of the tries finds some. away: which way the replicators are from the base, if they're there, as the lair stays on the
-- far side from them too.
local function pick_site(surface, landing, away)
  local spawn = game.forces[target_force].get_spawn_position(surface)
  local dx, dy = landing.x - spawn.x, landing.y - spawn.y
  local length = math.sqrt(dx * dx + dy * dy)
  if length < 1 then dx, dy, length = 1, 0, 1 end
  dx, dy = dx / length, dy / length
  local near, far = ordered(config.get("lair-min-distance"), config.get("lair-max-distance"))
  local tries, far_side = {}, {}
  for _, turn in pairs(site_turns) do
    local c, s = math.cos(turn), math.sin(turn)
    local distance = near + math.random() * (far - near)
    local at = {x = landing.x + (dx * c - dy * s) * distance, y = landing.y + (dx * s + dy * c) * distance}
    tries[#tries + 1] = at
    if not away or (at.x - spawn.x) * away.x + (at.y - spawn.y) * away.y < 0 then far_side[#far_side + 1] = at end
  end
  if #far_side > 0 then tries = far_side end
  for _, at in pairs(tries) do surface.request_to_generate_chunks(at, 1) end
  surface.force_generate_chunk_requests()
  local best, best_ore
  for _, at in pairs(tries) do
    local spot = surface.find_non_colliding_position(core_name, at, 24, 1)
    if spot and surface.count_entities_filtered{position = spot, radius = 48, force = target_force, limit = 1} == 0 then
      local ore = surface.count_entities_filtered{position = spot, radius = 40, type = "resource"}
      if not best or ore > best_ore then best, best_ore = spot, ore end
      if ore >= site_ore then break end
    end
  end
  best = best or {x = landing.x + dx * near, y = landing.y + dy * near}
  generate_way(surface, landing, best)
  return best
end

local function new_sums(state)
  state.energy, state.mass = 0, 0
  state.power, state.capacity, state.count, state.drills, state.machines, state.guards = base_power, base_capacity, 0, 0, 0, 0
  state.armed, state.copies = {}, {}
end

-- Called by the arrival as it lands, before anything is infected.
function outbreak.begin(surface, position, away)
  local state =
  {
    phase = "landing", surface = surface.index, landing = position, zones = {}, tier = 0, progress = 0,
    catalogue = {}, queue = {}, buildings = {}, raids = 0, landed = game.tick, ruin_ok = {},
    landing_until = game.tick + config.get("landing-minutes") * minute
  }
  new_sums(state)
  storage.outbreak = state
  state.effects = effects_of(0)
  open_zone(state, surface, position, config.get("outpost-radius") + landing_zone_extra, config.get("landing-minutes") * minute)
  state.site = pick_site(surface, position, away)
end

function outbreak.creatures(state)
  local result = {}
  local units = storage.units
  if not units then return result end
  for _, record in pairs(units.list) do
    if record.entity.valid and record.entity.surface.index == state.surface and units.by_unit_number[record.unit_number] == record then
      result[#result + 1] = record
    end
  end
  return result
end
local creatures = outbreak.creatures

local function draw_lair(core)
  local surface = core.surface
  for i = 0, 5 do
    local angle = i / 6 * 2 * math.pi
    local reach = i == 0 and 0 or 6
    rendering.draw_sprite
    {
      sprite = "beast-creep-patch", surface = surface, tint = shared.creep_tint, render_layer = "decals",
      target = {entity = core, offset = {math.cos(angle) * reach, math.sin(angle) * reach}},
      x_scale = i == 0 and 14 or 8, y_scale = i == 0 and 14 or 8
    }
  end
  rendering.draw_light{sprite = "utility/light_medium", target = core, surface = surface, color = {r = 1, g = 0.05, b = 0.3}, intensity = 0.8, scale = 6}
end

local function found(state, position)
  local surface = game.get_surface(state.surface)
  local spot = surface.find_non_colliding_position(core_name, position, 24, 1) or position
  local core = surface.create_entity{name = core_name, position = spot, force = force_name}
  if not core then return false end
  state.core = core
  state.phase = "lair"
  state.founded = game.tick
  state.next_clone = game.tick + clone_interval
  state.next_recount = game.tick + recount_interval
  local least, most = ordered(config.get("buildup-min-minutes"), config.get("buildup-max-minutes"))
  state.next_raid = game.tick + math.random(least * minute, most * minute)
  draw_lair(core)
  return true
end

-- Back to who it was taken from, or to the player for what it made itself, with a random defect where the quality mod
-- allows it (the user's decision of 2026-11-03). A building set down by the outbreak was never raised as built, so it's
-- raised now if it isn't replaced by one with a defect (which is).
local function give_back(entity, owner)
  if not entity.valid then return end
  entity.disabled_by_script = false
  entity.custom_status = nil
  -- A force that has gone since (ruins' forces come and go) gives it to the player.
  local force = owner
  if type(force) == "string" then force = game.forces[force] end
  if not (force and force.valid) then force = target_force end
  entity.force = force
  local replaced = infection.degrade(entity)
  if replaced == entity and entity.valid then script.raise_script_built{entity = entity} end
end

-- Libraries on top of this one clean up after themselves here: function(state), before anything is given back.
outbreak.on_end = {}

-- The core is gone, or it never formed: everything it took or made is set down and given back with a random defect, its
-- creatures break down and it is gone.
local function end_outbreak(state, key)
  state.phase = "over"
  state.ended = key
  for _, hook in pairs(outbreak.on_end) do hook(state) end
  for _, clone in pairs(state.raid and state.raid.clones or {}) do give_back(clone, target_force) end
  state.raid = nil
  state.zones = {}
  for _, record in pairs(creatures(state)) do
    local entity = record.entity
    if outbreak.put_down then outbreak.put_down(record) end
    if entity.valid then
      entity.surface.create_trivial_smoke{name = "beast-spores", position = entity.position}
      storage.units.by_unit_number[record.unit_number] = nil
      entity.destroy{raise_destroy = true}
    end
  end
  local buildings = state.buildings
  state.buildings = {}
  new_sums(state)
  for _, building in pairs(buildings) do
    give_back(building.entity, building.clone and target_force or building.owner or target_force)
  end
  infection.release_all()
  message(key)
end

-- Once a carrier gets to the site. Without one it lives on as a seed (seed.lua) in what it infected, however long that
-- takes, and a carrier it grows later has its own time to get there.
local function update_founding(state)
  local home = state.site
  local nearest, nearest_distance
  for _, record in pairs(creatures(state)) do
    local distance = distance_squared(record.entity.position, home)
    if not nearest or distance < nearest_distance then nearest, nearest_distance = record, distance end
  end
  if not nearest then
    state.carriers_since = nil
    return
  end
  state.carriers_since = state.carriers_since or game.tick
  if nearest_distance <= found_radius * found_radius then
    found(state, home)
  elseif game.tick >= math.max(state.landing_until, state.carriers_since) + found_timeout then
    -- Wherever the nearest of them got to.
    found(state, nearest.entity.position)
  end
end

-- One stage per research-minutes at the core's own power, faster with stolen power.
local function research(state)
  if state.tier >= #outbreak.tiers then return end
  local duration = config.get("research-minutes") * minute
  state.progress = state.progress + research_speed(state) * update_interval / duration
  if state.progress < 1 then return end
  state.progress = 0
  state.tier = state.tier + 1
  state.effects = effects_of(state.tier)
  state.templates = nil
  if outbreak.on_tier then outbreak.on_tier() end
  message("the-beast.tier", state.tier, #outbreak.tiers, {"the-beast.tier-" .. state.tier}, math.floor(outbreak.speed() * 100 + 0.5))
end

local function liftable_types()
  local types = {}
  for _, type in pairs(shared.source_types) do
    if (type_tier[type] or 0) <= data().tier then types[#types + 1] = type end
  end
  -- A spidertron isn't lifted but driven off (lair_arms.lua).
  if config.get("infect-vehicles") then types[#types + 1] = "spider-vehicle" end
  return types
end
outbreak.liftable_types = liftable_types

-- What it would take of a building, or nil: lifted, or a spidertron driven off.
local function takeable(entity)
  return shared.source_info(entity.name) ~= nil or entity.type == "spider-vehicle"
end

-- How much it wants this, or nil if it can't take it. turret_forces: whose turrets guard it.
local function score(state, surface, entity, turret_forces)
  if not (takeable(entity) and infection.can_infect(entity, true)) then return nil end
  local turrets = #turret_forces > 0 and surface.count_entities_filtered{position = entity.position, radius = turret_sight, type = turret_types, force = turret_forces} or 0
  if turrets > 0 and not state.effects.fight then return nil end
  local value = 1 - turrets * 2
  local info = shared.source_info(entity.name)
  if not state.catalogue[info and info.as or entity.name] then value = value + 10 end
  if shared.is_energy_type[entity.type] then value = value + (entity.type == "reactor" and reactor_score or energy_score) end
  if shared.is_assault_type[entity.type] then value = value + assault_score end
  return value + math.random()
end
outbreak.score = score

-- The edge of the base nearest the lair: out from the lair towards the player's spawn until it finds something it can
-- take, then the best of what's there. A little off to one side, so it doesn't always come the same way, and straight at
-- it as well, as a way off to the side can miss the base altogether.
local function base_target(state, surface, home, types)
  local spawn = game.forces[target_force].get_spawn_position(surface)
  local dx, dy = spawn.x - home.x, spawn.y - home.y
  local length = math.max(math.sqrt(dx * dx + dy * dy), 1)
  local side = (math.random() * 2 - 1) * 0.5
  local weighed = 0
  for step = 1, math.min(raid_search_steps, math.ceil(length / raid_search_step) + 1) do
    local reach = step * raid_search_step
    local best, best_score
    for _, turn in ipairs{side, 0} do
      local center = {x = home.x + (dx - dy * turn) / length * reach, y = home.y + (dy + dx * turn) / length * reach}
      for _, entity in pairs(surface.find_entities_filtered{position = center, radius = raid_search_radius, type = types, force = target_force, limit = 60}) do
        weighed = weighed + 1
        local value = score(state, surface, entity, {target_force})
        if value and (not best or value > best_score) then best, best_score = entity, value end
      end
    end
    if best then return best, best_score end
    if weighed >= raid_candidates then return nil end
  end
end

-- A ruin's building around the lair that it can take, the nearer the better.
local function ruin_target(state, surface, home, types)
  if not ruins_on() then return nil end
  local forces = ruin_forces()
  if #forces == 0 then return nil end
  local guards = {}
  if game.forces[shared.ruin_forces[2]] then guards[1] = shared.ruin_forces[2] end
  local bonus = state.effects.fight and ruin_score or ruin_score_early
  local best, best_score
  for _, entity in pairs(surface.find_entities_filtered{position = home, radius = ruin_search_radius, type = types, force = forces, limit = 200}) do
    local value = score(state, surface, entity, guards)
    if value then
      value = value + bonus - math.sqrt(distance_squared(entity.position, home)) / 50
      if not best or value > best_score then best, best_score = entity, value end
    end
  end
  return best, best_score
end

local function pick_target(state)
  local surface = game.get_surface(state.surface)
  local home = outbreak.home()
  local types = liftable_types()
  local base, base_score = base_target(state, surface, home, types)
  local ruin, ruin_value = ruin_target(state, surface, home, types)
  if ruin and (not base or ruin_value > base_score) then return ruin, true, ruin_value end
  return base, false, base_score
end

-- On foot, or by train (lair_rails.lua: plan_ride, board_ride) if it has one and that's worth it. ride: a raid by train
-- planned already, for admins and tests.
local function start_raid(state, ride)
  local target, ruin, value = pick_target(state)
  local planned = ride ~= nil
  ride = ride or (outbreak.plan_ride and outbreak.plan_ride(state)) or nil
  if ride and not planned and target and ride.score < value and math.random() >= ride_share then ride = nil end
  local walk_to, walk_ruin = target, ruin
  if ride then target, ruin = ride.target, false end
  if not target then
    state.next_raid = game.tick + raid_retry
    return "no-target"
  end
  local home = outbreak.home()
  local wanted = raid_party + raid_party_per_tier * state.tier + state.effects.party
  local function pick_party()
    local party = {}
    for _, record in pairs(creatures(state)) do
      if #party >= wanted then break end
      if record.attack ~= "robot" and not record.gathering and not record.cargo and not record.raid
        and (not ride or outbreak.can_board(record))
        and distance_squared(record.entity.position, home) <= raid_pick_radius * raid_pick_radius then
        party[#party + 1] = record
      end
    end
    return party
  end
  local party = pick_party()
  if #party == 0 and ride and walk_to then
    ride, target, ruin = nil, walk_to, walk_ruin
    party = pick_party()
  end
  if #party == 0 then
    state.next_raid = game.tick + raid_retry
    return "no-party"
  end
  -- No train could be grown after all: on foot, where it would have gone on foot.
  if ride and not outbreak.board_ride then ride = nil end
  local by_train = ride
  state.raids = state.raids + 1
  state.raid =
  {
    id = state.raids, target = target, position = target.position, started = game.tick, members = {}, ruin = ruin,
    forces = ruin and ruin_forces() or {target_force}, energy = shared.is_energy_type[target.type] or false
  }
  if ruin then state.ruin_raids = (state.ruin_raids or 0) + 1 end
  for _, record in pairs(party) do
    record.raid = state.raids
    state.raid.members[#state.raid.members + 1] = record.unit_number
  end
  if by_train and not outbreak.board_ride(state, state.raid, party, ride) then
    if walk_to and walk_to.valid then
      local raid = state.raid
      raid.target, raid.position, raid.ruin = walk_to, walk_to.position, walk_ruin
      raid.forces = walk_ruin and ruin_forces() or {target_force}
      raid.energy = shared.is_energy_type[walk_to.type] or false
      if walk_ruin then state.ruin_raids = (state.ruin_raids or 0) + 1 end
    end
  end
  return true
end
outbreak.start_raid = start_raid

-- Libraries on top of this one hear of a raid ending here: function(state, raid), before its members are let go.
outbreak.on_raid_end = {}

local function end_raid(state)
  for _, hook in pairs(outbreak.on_raid_end) do hook(state, state.raid) end
  local units = storage.units
  for _, unit_number in pairs(state.raid.members) do
    local record = units and units.by_unit_number[unit_number]
    if record and record.raid == state.raid.id then record.raid = nil end
  end
  for _, clone in pairs(state.raid.clones or {}) do dissolve(clone) end
  state.raid = nil
  local interval = config.get("raid-interval-minutes") * minute
  state.next_raid = game.tick + math.floor(interval * (0.7 + math.random() * 0.6))
end

-- Power is worth everything: whoever's at home and free comes over to carry it off.
local function recruit(state, raid)
  for _, record in pairs(creatures(state)) do
    if record.attack ~= "robot" and not record.gathering and not record.cargo and not record.raid then
      record.raid = raid.id
      raid.members[#raid.members + 1] = record.unit_number
    end
  end
end

local function power_left(state, raid)
  local surface = game.get_surface(state.surface)
  return surface.count_entities_filtered{position = raid.position, radius = config.get("raid-radius"), type = shared.energy_types, force = force_name, limit = 1} > 0
end

local function update_raid(state)
  local raid = state.raid
  -- Aboard a train on the way: nobody to count until they get out (lair_rails.lua).
  if raid.ride and not raid.ride.landed then
    if game.tick >= raid.started + raid_travel_timeout then return end_raid(state) end
    return
  end
  local units = storage.units
  local alive = {}
  for _, unit_number in pairs(raid.members) do
    local record = units and units.by_unit_number[unit_number]
    if record and record.entity.valid and record.raid == raid.id then alive[#alive + 1] = record end
  end
  if #alive == 0 then return end_raid(state) end
  local duration = config.get("raid-duration-minutes") * minute
  if raid.arrived then
    if game.tick < raid.arrived + duration then return end
    if raid.energy and game.tick < raid.arrived + duration * energy_hold and power_left(state, raid) then return end
    return end_raid(state)
  end
  if game.tick >= raid.started + raid_travel_timeout then return end_raid(state) end
  local reach = config.get("raid-radius") + raid_arrive_extra
  for _, record in pairs(alive) do
    if distance_squared(record.entity.position, raid.position) <= reach * reach then
      local surface = record.entity.surface
      raid.arrived = game.tick
      local hold = raid.energy and duration * energy_hold or duration
      open_zone(state, surface, raid.position, config.get("raid-radius"), hold)
      -- The bite: what it came for, and a little of what's right by it, power first, then what it attacks with.
      local bitten = 0
      if raid.target.valid and infection.infect(raid.target, true) then bitten = 1 end
      local nearby = surface.find_entities_filtered{position = raid.position, radius = raid_bite_radius, type = liftable_types(), force = raid.forces, limit = 12}
      local function rank(entity) return shared.is_energy_type[entity.type] and 2 or shared.is_assault_type[entity.type] and 1 or 0 end
      table.sort(nearby, function(a, b) return rank(a) > rank(b) end)
      for _, entity in pairs(nearby) do
        if bitten >= raid_bite then break end
        if takeable(entity) and infection.infect(entity, true) then
          bitten = bitten + 1
          if shared.is_energy_type[entity.type] then raid.energy = true end
        end
      end
      if raid.energy then recruit(state, raid) end
      if not raid.ruin and config.get("raid-clones") > 0 then clone_at_raid(state, raid, surface) end
      return
    end
  end
end

-- Near its core everything of its own heals, and the core itself.
local function heal(state)
  local core = state.core
  if not (core and core.valid) then return end
  local share = heal_share * state.effects.regen
  for _, entity in pairs(core.surface.find_entities_filtered{position = core.position, radius = heal_radius, type = "spider-unit", force = force_name}) do
    entity.health = entity.health + entity.max_health * share
  end
  core.health = core.health + core.max_health * core_heal_share * state.effects.regen
end

-- Called every update in the lair phase by the libraries on top of this one: function(state).
outbreak.on_update = {}
-- And these every update of an outbreak in any phase, before the phase's own (seed.lua): function(state).
outbreak.on_every_update = {}

local function update()
  local state = data()
  if not outbreak.active() then return end
  if not game.get_surface(state.surface) then
    state.phase = "over"
    return
  end
  if state.phase == "landing" and game.tick >= state.landing_until then state.phase = "founding" end
  -- Nothing of it is left before a core formed: no creature and no infected building (the player's turrets shot off every
  -- infection at the outpost, or the player cured or destroyed the last of it). It ends at once; a building cured with
  -- nothing infected next to it is never infected again, so this is final. Repelled if it never had a creature,
  -- otherwise it didn't take hold. That is the only way it ends before a core: with something infected left and no
  -- carrier, it lives on as a seed in it (seed.lua) and grows one of its own.
  if state.phase == "landing" or state.phase == "founding" then
    local alive = #creatures(state)
    if alive > 0 then state.had_creatures = true end
    if alive == 0 and not infection.any() then
      return end_outbreak(state, state.had_creatures and "the-beast.extinct" or "the-beast.repelled")
    end
  end
  for _, hook in pairs(outbreak.on_every_update) do
    if outbreak.active() then hook(state) end
  end
  if not outbreak.active() then return end
  if state.phase == "founding" then update_founding(state) end
  if state.phase ~= "lair" then return end
  if not (state.core and state.core.valid) then return end_outbreak(state, "the-beast.core-destroyed") end
  if game.tick >= (state.next_recount or 0) then recount(state) end
  local seconds = update_interval / 60
  state.energy = math.min(state.capacity, (state.energy or 0) + state.power * seconds)
  state.mass = (state.mass or 0) + (base_mass + drill_mass * state.drills) * seconds
  research(state)
  analyse(state)
  if game.tick >= (state.next_clone or 0) then
    state.next_clone = game.tick + clone_interval
    clone_in_lair(state)
    arm_some(state)
  end
  if state.raid then
    update_raid(state)
  elseif game.tick >= state.next_raid then
    start_raid(state)
  end
  for _, hook in pairs(outbreak.on_update) do
    if outbreak.active() then hook(state) end
  end
end

local function on_heal_tick()
  local state = data()
  if outbreak.active() and state.phase == "lair" then heal(state) end
end

-- Armour takes back a share of every hit. Early on, a creature that's badly hurt gives up whatever it was doing and
-- goes home.
local function on_entity_damaged(event)
  local entity = event.entity
  if not (entity.valid and entity.force.name == force_name and outbreak.active()) then return end
  local state = data()
  if entity.health > 0 and state.effects.armor > 0 then entity.health = entity.health + event.final_damage_amount * state.effects.armor end
  if entity.type ~= "spider-unit" or state.effects.fight then return end
  local record = storage.units and storage.units.by_unit_number[entity.unit_number]
  if record and entity.get_health_ratio() < flee_ratio then
    record.raid = nil
    record.flee_until = game.tick + flee_ticks
  end
end

local function on_entity_died(event)
  local state = data()
  if event.entity.name == core_name and outbreak.active() and state.core == event.entity then
    state.core = nil
    end_outbreak(state, "the-beast.core-destroyed")
  end
end

local function on_object_destroyed(event)
  if event.type ~= defines.target_type.entity then return end
  local state = data()
  if state and state.buildings and state.buildings[event.useful_id] then remove_building(state, event.useful_id) end
end

-- A spore shell has landed: a zone opens there, and the nearest few of the player's buildings are infected at once.
local function on_script_trigger_effect(event)
  if event.effect_id ~= "beast-spore-hit" or not outbreak.active() then return end
  local surface = game.get_surface(event.surface_index)
  local position = event.target_position or (event.target_entity and event.target_entity.valid and event.target_entity.position)
  if not (surface and position) then return end
  local state = data()
  open_zone(state, surface, position, spore_radius, spore_ticks)
  local infected = 0
  local found_entities = surface.find_entities_filtered{position = position, radius = spore_radius / 2, type = infection.infectable_types, force = infection.target_forces(), limit = 12}
  for _, entity in pairs(found_entities) do
    if infected >= spore_infections then break end
    if infection.infect(entity, true) then infected = infected + 1 end
  end
  state.spore_hits = (state.spore_hits or 0) + 1
end

-- Status pieces of the libraries on top of this one: function(state, status).
outbreak.status_hooks = {}

-- For the remote interface: what it's up to, and ways for tests and admins to move it along.
function outbreak.status()
  local state = data()
  if not state then return nil end
  local analysed, catalogued = 0, 0
  for _, entry in pairs(state.catalogue) do
    catalogued = catalogued + 1
    if entry.analysed then analysed = analysed + 1 end
  end
  local zones = 0
  for _, zone in pairs(state.zones) do
    if game.tick < zone.until_tick then zones = zones + 1 end
  end
  local clones = 0
  for _, building in pairs(state.buildings) do
    if building.clone and building.entity.valid then clones = clones + 1 end
  end
  local status =
  {
    phase = state.phase, tier = state.tier, progress = state.progress, speed = outbreak.speed(), site = state.site, landing = state.landing,
    core = state.core and state.core.valid and state.core.position or nil, next_raid = state.next_raid,
    raid = state.raid and {id = state.raid.id, position = state.raid.position, arrived = state.raid.arrived, members = #state.raid.members, ruin = state.raid.ruin, energy = state.raid.energy, clones = #(state.raid.clones or {}), ride = state.raid.ride and state.raid.ride.stop or nil, landed = state.raid.ride and state.raid.ride.landed or nil} or nil,
    raids = state.raids, ruin_raids = state.ruin_raids or 0, catalogued = catalogued, analysed = analysed, queued = #state.queue, zones = zones,
    buildings = state.count or 0, clones = clones, clones_made = state.clones_made or 0, creatures = #creatures(state),
    power = state.power, energy = state.energy, capacity = state.capacity, mass = state.mass, research_speed = research_speed(state),
    spore_hits = state.spore_hits or 0, ended = state.ended
  }
  for _, hook in pairs(outbreak.status_hooks) do hook(state, status) end
  return status
end

function outbreak.set_tier(tier)
  local state = data()
  if not state then return end
  state.tier = math.max(0, math.min(#outbreak.tiers, tier))
  state.progress = 0
  state.effects = effects_of(state.tier)
  state.templates = nil
  if outbreak.on_tier then outbreak.on_tier() end
end

-- Hurrying of the libraries on top of this one: [what] = function(state), returning true or why not.
outbreak.hurry_hooks = {}

-- true, or why not. "landing" ends the landing, "found" founds the core at the site, "raid" starts one ("no-target",
-- "no-party"), "analyse" finishes every queued sample, "clone" clones one at the lair without paying for it. The
-- libraries add theirs: "rails" and "ride" (lair_rails.lua), "fire" (lair_arms.lua).
function outbreak.hurry(what)
  local state = data()
  if not outbreak.active() then return false end
  if outbreak.hurry_hooks[what] then return outbreak.hurry_hooks[what](state) end
  if what == "landing" then state.landing_until = game.tick end
  if what == "found" and state.phase ~= "lair" then return found(state, state.site) end
  if what == "raid" and state.phase == "lair" and not state.raid then return start_raid(state) end
  if what == "analyse" then
    if state.analysing then state.queue[#state.queue + 1] = state.analysing.name end
    state.analysing = nil
    for _, name in pairs(state.queue) do
      if state.catalogue[name] then state.catalogue[name].analysed = game.tick end
    end
    state.queue = {}
    state.templates = nil
  end
  if what == "clone" then return state.phase == "lair" and state.core and state.core.valid and clone_in_lair(state, true) or false end
  return true
end

-- For admins and tests: a building set down at the lair as if it had been carried home (lair-place in the remote).
function outbreak.place_at_lair(name, quality)
  local state = data()
  if not outbreak.has_core() then return false end
  local cargo = {place = name, quality = quality, owner = target_force}
  outbreak.add_samples(cargo)
  return outbreak.place_cargo(state.core.surface, cargo, state.core.position)
end

local function setup()
  local state = data()
  if not (state and state.phase) then return end
  state.effects = effects_of(state.tier)
  state.ruin_ok = state.ruin_ok or {}
  -- From before the seed (2026-11-05): an outbreak with nothing that could give a carrier ended a minute after landing.
  state.barren_since = nil
  state.mass = state.mass or 0
  state.energy = state.energy or 0
  state.templates = nil
  -- Lair buildings were a plain list before 2026-11-03, and then a list of tables.
  local buildings = {}
  for _, building in pairs(state.buildings or {}) do
    if building.object_name then building = {entity = building, owner = target_force} end
    if building.entity and building.entity.valid then
      buildings[building.entity.unit_number] = building
      script.register_on_object_destroyed(building.entity)
    end
  end
  state.buildings = buildings
  recount(state)
end

outbreak.on_init = setup
outbreak.on_configuration_changed = setup

outbreak.on_nth_tick =
{
  [update_interval] = update,
  [heal_interval] = on_heal_tick
}

outbreak.events =
{
  [defines.events.on_entity_damaged] = on_entity_damaged,
  [defines.events.on_entity_died] = on_entity_died,
  [defines.events.on_object_destroyed] = on_object_destroyed,
  [defines.events.on_script_trigger_effect] = on_script_trigger_effect
}

return outbreak
