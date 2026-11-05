-- Infected entities in one array, worked through a few at a time. Each spreads to what it's physically connected to.
local shared = require("shared")
local config = require("script.config")

local infection = {}

local check_interval = 11
local active_checks = 80
local dormant_checks = 5
local spread_delay = {min = 1 * 60, max = 3 * 60}
-- Steady, so that it creeps along a belt a tile at a time.
local belt_spread_delay = {min = 1 * 60, max = 2 * 60}
-- Much slower than a belt, and one thing at a time, or it runs on ahead of the creep on the belts it touches.
local drill_spread_delay = {min = 6 * 60, max = 10 * 60}
local creep_growth_time = 3 * 60
local reinfect_delay = {min = 5 * 60, max = 10 * 60}
-- These move, so the infection on them has nothing to sit on and can't be shot off.
-- And a spidertron, which walks off. Nothing to sit a marker on, and never dormant, as it keeps moving.
local rolling_stock = {["locomotive"] = true, ["cargo-wagon"] = true, ["fluid-wagon"] = true, ["artillery-wagon"] = true, ["spider-vehicle"] = true}
local fruitless_spreads = 2
-- Only the player's own buildings, and not those of a blueprint sandbox or anyone else.
local target_force = "player"
-- A stopped train infects whatever's this close to it. One passing by doesn't stay long enough to.
local train_reach = 2

local belt_types = {"transport-belt", "underground-belt", "splitter"}
local infectable =
{
  ["mining-drill"] = true,
  ["transport-belt"] = true,
  ["underground-belt"] = true,
  ["splitter"] = true,
  ["inserter"] = true,
  ["ammo-turret"] = true,
  ["electric-turret"] = true,
  ["roboport"] = true,
  ["wall"] = true,
  ["electric-pole"] = true,
  ["lamp"] = true,
  ["radar"] = true,
  ["container"] = true,
  ["logistic-container"] = true,
  ["furnace"] = true,
  ["assembling-machine"] = true,
  ["locomotive"] = true,
  ["cargo-wagon"] = true,
  ["fluid-wagon"] = true,
  ["pipe"] = true,
  ["pipe-to-ground"] = true,
  ["storage-tank"] = true,
  ["pump"] = true,
  ["fluid-turret"] = true,
  -- Power (shared.energy_types), which an outbreak carries home first.
  ["generator"] = true,
  ["boiler"] = true,
  ["burner-generator"] = true,
  ["reactor"] = true,
  ["accumulator"] = true,
  ["solar-panel"] = true,
  ["electric-energy-interface"] = true,
  -- To attack with (shared.assault_types).
  ["artillery-turret"] = true,
  ["artillery-wagon"] = true,
  ["car"] = true,
  ["spider-vehicle"] = true
}

-- These don't come alive, they just stop working and pass it on: switched off, and drained of what's in them.
local piping = {["pipe"] = true, ["pipe-to-ground"] = true, ["storage-tank"] = true, ["pump"] = true, ["fluid-turret"] = true}
local seized = piping
local belts = {["transport-belt"] = true, ["underground-belt"] = true, ["splitter"] = true}

-- Which map setting allows each kind of thing to be infected at all. Belts, drills, inserters, containers and machines
-- always can, as they're what the Beast is.
local category_setting =
{
  ["wall"] = "infect-walls",
  ["pipe"] = "infect-pipes", ["pipe-to-ground"] = "infect-pipes", ["storage-tank"] = "infect-pipes", ["pump"] = "infect-pipes", ["fluid-turret"] = "infect-pipes",
  ["electric-pole"] = "infect-poles", ["lamp"] = "infect-poles",
  ["ammo-turret"] = "infect-turrets", ["electric-turret"] = "infect-turrets",
  ["roboport"] = "infect-roboports",
  ["locomotive"] = "infect-trains", ["cargo-wagon"] = "infect-trains", ["fluid-wagon"] = "infect-trains"
}
for _, type in pairs(shared.energy_types) do category_setting[type] = "infect-energy" end
category_setting["artillery-turret"] = "infect-artillery"
category_setting["artillery-wagon"] = "infect-artillery"
category_setting["car"] = "infect-vehicles"
category_setting["spider-vehicle"] = "infect-vehicles"

-- Whether a kind of entity can ever be infected, by name. Only buildings the player places: hidden parts of other mods'
-- buildings (lamps on lighted poles, the poles and radars inside Bio Industries farms, Factorissimo's connections) have
-- no item and are left alone rather than removed, as removing them would break what they belong to. So are the buildings
-- other mods' scripts look after (shared.is_excluded). Decided once per name, so the check is a single table lookup.
local eligible_names = {}
local function eligible(entity)
  local name = entity.name
  local result = eligible_names[name]
  if result == nil then
    local prototype = entity.prototype
    -- nil, not an empty list, when no item places it.
    local items = prototype.items_to_place_this
    result = (infectable[prototype.type] and prototype.selectable_in_game and items and #items > 0
      and not shared.is_excluded(name)) and true or false
    eligible_names[name] = result
  end
  return result
end

local function set_active(entity, active)
  entity.disabled_by_script = not active
end

-- 2.1: clear_fluid_inside is still there (LuaEntity.fluidbox is gone in 2.1, but nothing here uses it).
local function drain(entity)
  entity.clear_fluid_inside()
end

infection.infectable_types = {}
for type in pairs(infectable) do infection.infectable_types[#infection.infectable_types + 1] = type end
table.sort(infection.infectable_types)

-- By entity type: {delay = {min, max}, convert = function(entity)}, for what doesn't stay infected forever.
infection.conversions = {}
-- By entity type: function(entity), called when one gets infected.
infection.on_infected = {}

local function data()
  return storage.infection
end

local function next_spread_tick(entity)
  local delay = spread_delay
  if belts[entity.type] or entity.type == "wall" then delay = belt_spread_delay end
  if entity.type == "mining-drill" then delay = drill_spread_delay end
  return game.tick + config.spread_ticks(math.random(delay.min, delay.max))
end

local function add_marker(record)
  local entity = record.entity
  if rolling_stock[entity.type] then return end
  local marker = entity.surface.create_entity{name = "beast-infection", position = entity.position, force = "the-beast"}
  if not marker then return end
  record.marker = marker
  data().markers[marker.unit_number] = record
end

local creep_tint = shared.creep_tint
-- See through, so what's underneath still looks like what it is.
local creep_on_top_tint = {r = 0.3, g = 0.03, b = 0.1, a = 0.5}
-- Walls are pale and all alike, so they get coated, or you can't tell which have gone.
local wall_coat_tint = {r = 0.5, g = 0.04, b = 0.15, a = 0.85}

-- Pushed along the belt as it grows, from the back of the tile to where its fingers reach into the next one.
local function streak_target(entity, growth)
  local angle = entity.direction / 16 * 2 * math.pi
  local along = -0.75 * (1 - growth) + 0.3 * growth
  return {entity = entity, offset = {math.sin(angle) * along, -math.cos(angle) * along}}
end

local function draw_streak(entity, width)
  local streak = rendering.draw_sprite
  {
    sprite = "beast-creep-streak",
    target = streak_target(entity, 0),
    surface = entity.surface,
    tint = creep_on_top_tint,
    orientation = entity.direction / 16,
    x_scale = width,
    y_scale = 0.01,
    render_layer = "transport-belt-circuit-connector"
  }
  local state = data()
  state.growing[#state.growing + 1] = {streak = streak, entity = entity, started = game.tick}
  return {streak}
end

local function grow_streaks(state)
  for i = #state.growing, 1, -1 do
    local entry = state.growing[i]
    local growth = (game.tick - entry.started) / creep_growth_time
    if not (entry.streak.valid and entry.entity.valid) or growth >= 1 then
      if entry.streak.valid and entry.entity.valid then
        entry.streak.y_scale = 1
        entry.streak.target = streak_target(entry.entity, 1)
      end
      table.remove(state.growing, i)
    else
      entry.streak.y_scale = growth
      entry.streak.target = streak_target(entry.entity, growth)
    end
  end
end

-- Over the ground around it, and a smaller patch on top so that it shows on the thing itself.
local function draw_patches(entity)
  local box = entity.prototype.selection_box
  local width, length = box.right_bottom.x - box.left_top.x, box.right_bottom.y - box.left_top.y
  local turns = rolling_stock[entity.type]
  local size = 2 * entity.get_radius()
  local function patch(x_scale, y_scale, tint, render_layer)
    return rendering.draw_sprite
    {
      sprite = "beast-creep-patch", target = entity, surface = entity.surface, tint = tint, x_scale = x_scale, y_scale = y_scale,
      render_layer = render_layer, orientation_target = turns and entity or nil, use_target_orientation = turns or nil
    }
  end
  if turns then
    return {patch(width + 1, length + 1, creep_tint, "decals"), patch(width * 0.5, length * 0.3, creep_on_top_tint, "higher-object-under")}
  end
  if entity.type == "wall" then
    return {patch(size + 1, size + 1, creep_tint, "decals"), patch(size * 1.1, size * 1.1, wall_coat_tint, "higher-object-under")}
  end
  return {patch(size + 1, size + 1, creep_tint, "decals"), patch(size * 0.3, size * 0.3, creep_on_top_tint, "higher-object-under")}
end

local function draw_creep(entity)
  if entity.type == "splitter" then return draw_streak(entity, 2) end
  if entity.type == "transport-belt" or entity.type == "underground-belt" then return draw_streak(entity, 1) end
  return draw_patches(entity)
end

local function remove_visuals(record)
  if record.light.valid then record.light.destroy() end
  for _, creep in pairs(record.creep or {}) do
    if creep.valid then creep.destroy() end
  end
  if record.growth and record.growth.valid then record.growth.destroy() end
  local marker = record.marker
  if marker and marker.valid then
    data().markers[marker.unit_number] = nil
    marker.destroy()
  end
  record.marker = nil
end

-- The poles a pole is wired to, read before it changes hands, in case changing force cuts the wires.
local function copper_neighbours(entity, result)
  local connector = entity.get_wire_connector(defines.wire_connector_id.pole_copper, false)
  if not connector then return result end
  for _, connection in pairs(connector.connections) do
    local owner = connection.target.owner
    if owner.valid and owner.type == "electric-pole" then result[#result + 1] = owner end
  end
  return result
end

function infection.is_infected(entity)
  return data().by_unit_number[entity.unit_number] ~= nil
end

function infection.infected_tick(entity)
  return data().by_unit_number[entity.unit_number].infected_tick
end

-- Set by the outbreak (outbreak.lua): which types it can take by now, and where it can spread to. forced: it's put there
-- on purpose (the landing, a raid's bite, a remote call) rather than spreading, so the zones don't count.
infection.type_filter = nil
infection.zone_filter = nil
-- Whether infected poles pass it along their copper wires, which they otherwise don't.
infection.wire_filter = nil
-- Set by the outbreak too: whether a building of another force than the player's can be taken (ruins), and which forces
-- those are, for the searches that look for something to take.
infection.ruin_filter = nil
infection.extra_forces = nil

local player_only = {target_force}
function infection.target_forces()
  local extra = infection.extra_forces and infection.extra_forces()
  if not extra then return player_only end
  local forces = {target_force}
  for _, name in pairs(extra) do forces[#forces + 1] = name end
  return forces
end

local function takeable_force(entity)
  local name = entity.force.name
  if name == target_force then return true end
  return infection.ruin_filter ~= nil and infection.ruin_filter(entity)
end

function infection.can_infect(entity, forced)
  if not (entity.valid and infectable[entity.type] and entity.unit_number and takeable_force(entity)) then return false end
  local setting = category_setting[entity.type]
  if setting and not config.get(setting) then return false end
  if infection.type_filter and not infection.type_filter(entity.type) then return false end
  if not (eligible(entity) and not infection.is_infected(entity)) then return false end
  return forced or not infection.zone_filter or infection.zone_filter(entity)
end

function infection.infect(entity, forced)
  if not infection.can_infect(entity, forced) then return false end
  local conversion = infection.conversions[entity.type]
  local record =
  {
    entity = entity,
    unit_number = entity.unit_number,
    infected_tick = game.tick,
    next_spread = next_spread_tick(entity),
    convert_tick = conversion and (not conversion.enabled or conversion.enabled()) and game.tick + config.spread_ticks(math.random(conversion.delay.min, conversion.delay.max)),
    light = rendering.draw_light
    {
      sprite = "utility/light_small",
      target = entity,
      surface = entity.surface,
      color = {r = 1, g = 0.05, b = 0.3},
      intensity = 0.6,
      scale = 1.5
    },
    creep = draw_creep(entity)
  }
  if entity.type == "electric-pole" then record.wired = copper_neighbours(entity, {}) end
  local state = data()
  state.list[#state.list + 1] = record
  state.by_unit_number[entity.unit_number] = record
  add_marker(record)
  script.register_on_object_destroyed(entity)
  -- It's the Beast's now, so nothing of the Beast's will attack it, until the infection's shot off and it goes back.
  record.previous_force = entity.force
  entity.force = "the-beast"
  entity.custom_status = {diode = defines.entity_status_diode.red, label = {"the-beast.infected"}}
  if seized[entity.type] then set_active(entity, false) end
  if piping[entity.type] then drain(entity) end
  entity.surface.create_trivial_smoke{name = "beast-spores", position = entity.position}
  local on_infected = infection.on_infected[entity.type]
  if on_infected then on_infected(entity) end
  return true
end

-- Who it goes back to: whoever it was taken from, or the player if that force has gone since (ruins' forces).
local function owner_of(record)
  local force = record.previous_force
  return force and force.valid and force or game.forces[target_force]
end

function infection.cure(entity)
  local state = data()
  local record = state.by_unit_number[entity.unit_number]
  if not record then return end
  state.by_unit_number[entity.unit_number] = nil
  record.cured = true
  remove_visuals(record)
  entity.custom_status = nil
  if seized[entity.type] then set_active(entity, true) end
  entity.force = owner_of(record)
end

-- The force it belonged to before it was infected, or nil if it isn't.
function infection.previous_force(entity)
  local record = data().by_unit_number[entity.unit_number]
  return record and record.previous_force and record.previous_force.valid and record.previous_force or nil
end

-- These move on rails, so there's nothing to put a new one in their place with.
local no_degrade = {["locomotive"] = true, ["cargo-wagon"] = true, ["fluid-wagon"] = true, ["artillery-wagon"] = true}

-- The same building again in its place, with a random Paranoidal defect (shared.random_defect), by a fast replace,
-- which keeps what's inside it and its connections. Raised as built, as it's its owner's again and their mods should know
-- of it. If it can't be done (no defect for it, or the engine won't replace it) it's left as it is.
-- 2.1: create_entity takes the same parameters; check that a fast replace with only the quality changed still works.
function infection.degrade(entity)
  if not (entity.valid and entity.unit_number) or no_degrade[entity.type] then return entity end
  local quality = shared.random_defect(entity.name)
  if not quality or quality == entity.quality.name then return entity end
  local health = entity.is_entity_with_health and entity.get_health_ratio() or nil
  local spec =
  {
    name = entity.name, position = entity.position, direction = entity.direction, quality = quality, force = entity.force,
    fast_replace = true, spill = false, raise_built = true, create_build_effect_smoke = false
  }
  if entity.type == "underground-belt" then spec.type = entity.belt_to_ground_type end
  local replaced = entity.surface.create_entity(spec)
  if not (replaced and replaced.valid) then return entity end
  -- create_entity doesn't check what's there: if the old one is still standing it wasn't a replacement but a second
  -- building on top of it, which goes again (raised, as it was raised as built).
  if entity.valid then
    replaced.destroy{raise_destroy = true}
    return entity
  end
  if health and replaced.is_entity_with_health then replaced.health = replaced.max_health * health end
  return replaced
end

-- When the outbreak is over, everything it holds is put back: each building to the force it was taken from, working
-- again, with a random defect (the user's decision of 2026-11-03).
function infection.release_all()
  local state = data()
  local records = state.by_unit_number
  state.by_unit_number = {}
  state.list = {}
  state.cursor = 1
  state.dormant = {}
  state.dormant_cursor = 1
  state.recovering = {}
  for _, record in pairs(records) do
    record.cured = true
    remove_visuals(record)
    local entity = record.entity
    if entity.valid then
      entity.custom_status = nil
      if seized[entity.type] then set_active(entity, true) end
      entity.force = owner_of(record)
      infection.degrade(entity)
    end
  end
end

-- Whether anything at all is infected now (the outbreak ends at once when nothing is left before a core formed).
function infection.any()
  for _, record in pairs(data().by_unit_number) do
    if record.entity.valid then return true end
  end
  return false
end

-- What's infected on a surface, at most limit of them, for the seed (seed.lua), which lives in them.
function infection.infected_on(surface_index, limit)
  local result = {}
  for _, record in pairs(data().by_unit_number) do
    local entity = record.entity
    if entity.valid and entity.surface.index == surface_index then
      result[#result + 1] = entity
      if #result >= limit then break end
    end
  end
  return result
end

function infection.stats()
  local counts = {}
  for _, record in pairs(data().by_unit_number) do
    if record.entity.valid then counts[record.entity.type] = (counts[record.entity.type] or 0) + 1 end
  end
  return counts, #data().list
end

local function add_neighbours(result, neighbours)
  if not neighbours then return end
  if neighbours.object_name then
    result[#result + 1] = neighbours
    return
  end
  for _, neighbour in pairs(neighbours) do
    add_neighbours(result, neighbour)
  end
end

-- By position rather than by what's connected, as these don't change when the force does.
local function is_over(position, entity)
  local box = entity.bounding_box
  local margin = 0.3
  return position.x >= box.left_top.x - margin and position.x <= box.right_bottom.x + margin
    and position.y >= box.left_top.y - margin and position.y <= box.right_bottom.y + margin
end

local function connected_inserters(entity, result)
  local inserters = entity.surface.find_entities_filtered{position = entity.position, radius = 4 + entity.get_radius(), type = "inserter"}
  for _, inserter in pairs(inserters) do
    if is_over(inserter.pickup_position, entity) or is_over(inserter.drop_position, entity) then
      result[#result + 1] = inserter
    end
  end
end

local function things_at(entity, position, result)
  for _, found in pairs(entity.surface.find_entities_filtered{position = position, radius = 0.3, type = infection.infectable_types}) do
    if found ~= entity then result[#result + 1] = found end
  end
end

local function spread_targets(entity)
  local result = {}
  local type = entity.type
  if type == "mining-drill" then
    things_at(entity, entity.drop_position, result)
    add_neighbours(result, entity.surface.find_entities_filtered{position = entity.position, radius = 6, type = "mining-drill"})
    add_neighbours(result, entity.surface.find_entities_filtered{position = entity.position, radius = entity.get_radius() + 2, type = belt_types})
  elseif type == "transport-belt" or type == "underground-belt" or type == "splitter" then
    add_neighbours(result, entity.belt_neighbours)
    -- The other end of an underground (2.1: underground_belt_neighbour; LuaEntity.neighbours is gone).
    if type == "underground-belt" then add_neighbours(result, entity.underground_belt_neighbour) end
    connected_inserters(entity, result)
  elseif type == "inserter" then
    things_at(entity, entity.pickup_position, result)
    things_at(entity, entity.drop_position, result)
  elseif piping[type] then
    -- For anything with pipe connections, what each of its fluidboxes is connected to
    -- (2.1: fluidbox_neighbours, an array per fluidbox; LuaEntity.neighbours is gone).
    add_neighbours(result, entity.fluidbox_neighbours)
    connected_inserters(entity, result)
  elseif type == "electric-pole" then
    if infection.wire_filter and infection.wire_filter() then
      local record = data().by_unit_number[entity.unit_number]
      for _, pole in pairs(record and record.wired or {}) do
        if pole.valid then result[#result + 1] = pole end
      end
      copper_neighbours(entity, result)
    end
    return result
  elseif type == "wall" then
    add_neighbours(result, entity.surface.find_entities_filtered{position = entity.position, radius = 1.5, type = "wall"})
  elseif type == "spider-vehicle" then
    -- Whatever it walks past.
    add_neighbours(result, entity.surface.find_entities_filtered{position = entity.position, radius = entity.get_radius() + train_reach, type = infection.infectable_types})
  elseif entity.train then
    add_neighbours(result, entity.train.carriages)
    connected_inserters(entity, result)
    if entity.train.speed == 0 then
      add_neighbours(result, entity.surface.find_entities_filtered{position = entity.position, radius = entity.get_radius() + train_reach, type = infection.infectable_types})
    end
  else
    connected_inserters(entity, result)
  end
  return result
end

-- Belts and pipes on different forces don't count as connected, so it has to be looking from the side of whatever it's
-- looking for. Everything else is found by where it is, which the force makes no difference to, so it's left as it is.
local function targets_seen_as(entity, force)
  local own_force = entity.force
  if own_force == force or not (belts[entity.type] or piping[entity.type]) then return spread_targets(entity) end
  entity.force = force
  local targets = spread_targets(entity)
  entity.force = own_force
  return targets
end

-- The poles on its own network whose supply area it stands in.
local pole_reach = 20
local function powering_poles(entity, network, result)
  local box = entity.bounding_box
  for _, pole in pairs(entity.surface.find_entities_filtered{position = entity.position, radius = entity.get_radius() + pole_reach, type = "electric-pole"}) do
    if pole.electric_network_id == network then
      local reach, at = pole.prototype.get_supply_area_distance(pole.quality), pole.position
      if reach and reach > 0 and at.x + reach > box.left_top.x and at.x - reach < box.right_bottom.x
        and at.y + reach > box.left_top.y and at.y - reach < box.right_bottom.y then
        result[#result + 1] = pole
      end
    end
  end
end

-- What an infected entity is in contact with, for the seed (seed.lua), which picks for itself where it creeps next rather
-- than spreading inside a zone: whatever it would spread to, and through the current, which is contact too: for a pole,
-- the poles it's wired to and whatever on its network stands in its supply area; for anything else on a network, the
-- poles that power it.
function infection.contacts(entity)
  local record = data().by_unit_number[entity.unit_number]
  local result = targets_seen_as(entity, record and owner_of(record) or game.forces[target_force])
  if entity.type ~= "electric-pole" then
    local network = entity.electric_network_id
    if network then powering_poles(entity, network, result) end
    return result
  end
  copper_neighbours(entity, result)
  local reach = entity.prototype.get_supply_area_distance(entity.quality)
  local network = entity.electric_network_id
  if not (reach and reach > 0 and network) then return result end
  local at = entity.position
  for _, found in pairs(entity.surface.find_entities_filtered{area = {{at.x - reach, at.y - reach}, {at.x + reach, at.y + reach}}, type = infection.infectable_types, force = infection.target_forces()}) do
    if found.type ~= "electric-pole" and found.electric_network_id == network then result[#result + 1] = found end
  end
  return result
end

local function spread(entity)
  local record = data().by_unit_number[entity.unit_number]
  local targets = targets_seen_as(entity, owner_of(record))
  if entity.type == "mining-drill" then
    local choices = {}
    for _, target in pairs(targets) do
      if infection.can_infect(target) then choices[#choices + 1] = target end
    end
    if #choices == 0 then return 0 end
    infection.infect(choices[math.random(#choices)])
    return 1
  end
  if piping[entity.type] then drain(entity) end
  local infected = 0
  for _, target in pairs(targets) do
    if infection.infect(target) then infected = infected + 1 end
  end
  return infected
end

local function remove_at(list, index)
  list[index] = list[#list]
  list[#list] = nil
end

local function forget(state, record)
  if state.by_unit_number[record.unit_number] == record then state.by_unit_number[record.unit_number] = nil end
end

-- The front of the infection: spreads quickly, and drops out once there's nothing left around it to infect, so a huge
-- infection is no slower at the edges than a small one.
local function check_active(state)
  local list = state.list
  for _ = 1, math.min(active_checks, #list) do
    local index = state.cursor
    if index > #list then index = 1 end
    local record = list[index]
    if record.cured or not record.entity.valid then
      forget(state, record)
      remove_at(list, index)
      if #list == 0 then break end
      state.cursor = index
    else
      local entity = record.entity
      local dormant = false
      if game.tick >= record.next_spread then
        record.next_spread = next_spread_tick(entity)
        record.fruitless = spread(entity) > 0 and 0 or (record.fruitless or 0) + 1
        -- A train that's found nothing yet is only between stops.
        dormant = record.fruitless >= fruitless_spreads and not record.convert_tick and not rolling_stock[entity.type] and not piping[entity.type]
      end
      if record.convert_tick and game.tick >= record.convert_tick then
        record.convert_tick = nil
        infection.conversions[entity.type].convert(entity)
      end
      if dormant and entity.valid then
        state.dormant[#state.dormant + 1] = record
        remove_at(list, index)
        if #list == 0 then break end
        state.cursor = index
      else
        state.cursor = index + 1
      end
    end
  end
end

-- Everything behind the front, looked at now and then for whatever has been built next to it since.
local function check_dormant(state)
  local list = state.dormant
  for _ = 1, math.min(dormant_checks, #list) do
    local index = state.dormant_cursor
    if index > #list then index = 1 end
    local record = list[index]
    if record.cured or not record.entity.valid then
      forget(state, record)
      remove_at(list, index)
      if #list == 0 then break end
      state.dormant_cursor = index
    elseif spread(record.entity) > 0 then
      record.fruitless = 0
      record.next_spread = next_spread_tick(record.entity)
      state.list[#state.list + 1] = record
      remove_at(list, index)
      if #list == 0 then break end
      state.dormant_cursor = index
    else
      state.dormant_cursor = index + 1
    end
  end
end

-- Something that got its infection shot off goes straight back if what's next to it still has it, so turrets have to keep
-- holding it off for as long as it's there, until their ammo runs out.
local function check_recovering(state)
  local list = state.recovering
  for i = #list, 1, -1 do
    local entry = list[i]
    if not entry.entity.valid then
      table.remove(list, i)
    elseif game.tick >= entry.tick then
      table.remove(list, i)
      for _, target in pairs(targets_seen_as(entry.entity, game.forces["the-beast"])) do
        if target.valid and target.unit_number and state.by_unit_number[target.unit_number] then
          infection.infect(entry.entity)
          break
        end
      end
    end
  end
end

local function on_tick_check()
  local state = data()
  check_active(state)
  check_dormant(state)
  check_recovering(state)
  grow_streaks(state)
end

local function on_entity_died(event)
  local state = data()
  local record = state.markers[event.entity.unit_number]
  if not record then return end
  state.markers[event.entity.unit_number] = nil
  record.marker = nil
  local entity = record.entity
  if not entity.valid then return end
  entity.surface.create_trivial_smoke{name = "beast-spores", position = entity.position}
  infection.cure(entity)
  state.recovering[#state.recovering + 1] = {entity = entity, tick = game.tick + math.random(reinfect_delay.min, reinfect_delay.max)}
end

-- It's gone however that happened, so nothing of its infection should be left behind floating in the air.
local function on_object_destroyed(event)
  if event.type ~= defines.target_type.entity then return end
  local state = data()
  local record = state.by_unit_number[event.useful_id]
  if not record or record.entity.valid then return end
  state.by_unit_number[event.useful_id] = nil
  record.cured = true
  remove_visuals(record)
end

local function setup()
  storage.infection = storage.infection or {list = {}, by_unit_number = {}, cursor = 1}
  local state = storage.infection
  state.dormant = state.dormant or {}
  state.dormant_cursor = state.dormant_cursor or 1
  state.recovering = state.recovering or {}
  state.growing = state.growing or {}
  if not state.markers then
    state.markers = {}
    for _, record in pairs(state.by_unit_number) do
      if record.entity.valid then
        add_marker(record)
        script.register_on_object_destroyed(record.entity)
      end
    end
  end
  for _, record in pairs(state.by_unit_number) do
    if record.entity.valid and not record.previous_force then
      record.previous_force = record.entity.force
      record.entity.force = "the-beast"
    end
  end
end

infection.on_init = setup
infection.on_configuration_changed = setup

infection.events =
{
  [defines.events.on_entity_died] = on_entity_died,
  [defines.events.on_object_destroyed] = on_object_destroyed
}

infection.on_nth_tick =
{
  [check_interval] = on_tick_check
}

return infection
