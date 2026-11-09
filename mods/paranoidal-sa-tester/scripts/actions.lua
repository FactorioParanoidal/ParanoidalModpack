-- Everything the panel can do. Each action: function(player, args) -> ok (boolean), message (LocalisedString).
-- Missing args are taken from the player's choices in the window (pdata), so the remote interface and the GUI
-- run the same code.
local common = require("scripts.common")
local catalog = require("scripts.catalog")

local A = {}
-- Actions that change shared state; their result goes to every player.
A.global = {}
-- Actions that need a second click.
A.confirm = {}

local function arg(player, args, key)
  if args and args[key] ~= nil then return args[key] end
  return common.pdata(player)[key]
end

local function tech_name(tech)
  return {"", "[technology=" .. tech.name .. "]"}
end

-------------------------------------------------------------------------------- research

-- Research `name` with every missing prerequisite (or only the prerequisites).
local function research_chain(force, name, include_self)
  local list = catalog.missing(force, name)
  local count = 0
  for _, tech in ipairs(list) do
    if not tech.researched then
      tech.researched = true
      count = count + 1
    end
  end
  local tech = force.technologies[name]
  if include_self and tech and not tech.researched then
    tech.researched = true
    count = count + 1
  end
  return count
end

A.global["research"] = true
function A.research(player, args)
  local name = arg(player, args, "tech")
  local force = player.force
  local tech = name and force.technologies[name]
  if not tech then return false, {"pst.need-tech"} end
  local mode = args and args.mode or "with"
  if mode == "with" and tech.researched then return false, {"pst.already-researched", tech_name(tech)} end
  local count = research_chain(force, name, mode == "with")
  if mode == "with" then
    return true, {"pst.researched-with", tech_name(tech), count}
  end
  return true, {"pst.researched-before", tech_name(tech), count}
end

A.global["unresearch"] = true
A.confirm["unresearch"] = true
function A.unresearch(player, args)
  local name = arg(player, args, "tech")
  local force = player.force
  local tech = name and force.technologies[name]
  if not tech then return false, {"pst.need-tech"} end
  if not tech.researched then return false, {"pst.not-researched", tech_name(tech)} end
  local dependents = catalog.researched_dependents(force, name)
  for _, t in ipairs(dependents) do t.researched = false end
  tech.researched = false
  return true, {"pst.unresearched", tech_name(tech), #dependents}
end

A.global["finish-research"] = true
function A.finish_research(player)
  local force = player.force
  local tech = force.current_research
  if not tech then return false, {"pst.no-current-research"} end
  local proto = tech.prototype
  if proto.max_level > proto.level and tech.level < proto.max_level then
    -- Level-based technology: writing the level researches the previous one.
    tech.level = tech.level + 1
  else
    tech.researched = true
  end
  return true, {"pst.finished-research", tech_name(tech)}
end

A.global["research-all"] = true
A.confirm["research-all"] = true
function A.research_all(player)
  player.force.research_all_technologies()
  return true, {"pst.researched-all"}
end

A.global["lab-speed"] = true
function A.lab_speed(player)
  local force = player.force
  local fd = common.fdata(force)
  if fd.lab_bonus then
    force.laboratory_speed_modifier = force.laboratory_speed_modifier - fd.lab_bonus
    fd.lab_bonus = nil
    return true, {"pst.lab-speed-off"}
  end
  fd.lab_bonus = 100
  force.laboratory_speed_modifier = force.laboratory_speed_modifier + fd.lab_bonus
  return true, {"pst.lab-speed-on"}
end

function A.unlock_recipe(player, args)
  local name = arg(player, args, "recipe")
  local recipe = name and player.force.recipes[name]
  if not recipe then return false, {"pst.need-recipe"} end
  recipe.enabled = true
  return true, {"pst.recipe-unlocked", "[recipe=" .. name .. "]"}
end

-------------------------------------------------------------------------------- places

local function location_text(name)
  return {"", "[space-location=" .. name .. "] ", prototypes.space_location[name].localised_name}
end

A.global["toggle-location"] = true
function A.toggle_location(player, args)
  local name = args and args.location
  if not (name and prototypes.space_location[name]) then return false, {"pst.need-location"} end
  local force = player.force
  if force.is_space_location_unlocked(name) then
    force.lock_space_location(name)
    return true, {"pst.location-locked", location_text(name)}
  end
  force.unlock_space_location(name)
  return true, {"pst.location-unlocked", location_text(name)}
end

-- Surface of a planet, created and with generated chunks around the centre.
local function planet_surface(name, radius)
  local planet = game.planets[name]
  if not planet then return nil end
  local surface = planet.surface or planet.create_surface()
  surface.request_to_generate_chunks({0, 0}, radius or 3)
  surface.force_generate_chunk_requests()
  return surface
end

-- Put the player's body (or the player without a body) on a surface near a position.
local function move_body(player, surface, position)
  if player.surface.platform and player.physical_surface and player.physical_surface.platform then
    player.leave_space_platform()
  end
  if player.controller_type == defines.controllers.remote then player.exit_remote_view() end
  local body = player.character
  local probe = body and body.name or "character"
  local spot = common.free_spot(surface, probe, position, 64)
  if not spot then
    -- Water, lava or empty space everywhere around: lay a small landfill pad and stand on it.
    local tiles = {}
    local tile = prototypes.tile["landfill"] and "landfill" or "refined-concrete"
    for x = -3, 3 do
      for y = -3, 3 do tiles[#tiles + 1] = {name = tile, position = {position.x + x, position.y + y}} end
    end
    surface.set_tiles(tiles, true, false, true, true)
    spot = common.free_spot(surface, probe, position, 8) or position
  end
  local ok
  if body then
    ok = body.teleport(spot, surface)
  else
    ok = player.teleport(spot, surface)
  end
  return ok
end

function A.go(player, args)
  local name = args and args.location
  if not (name and prototypes.space_location[name]) then return false, {"pst.need-location"} end
  if not game.planets[name] then return false, {"pst.no-surface", location_text(name)} end
  local surface = planet_surface(name, 3)
  if not surface then return false, {"pst.no-surface", location_text(name)} end
  local position = player.force.get_spawn_position(surface)
  if not move_body(player, surface, {x = position.x, y = position.y}) then
    return false, {"pst.teleport-failed", location_text(name)}
  end
  player.force.chart(surface, {{position.x - 160, position.y - 160}, {position.x + 160, position.y + 160}})
  return true, {"pst.arrived", location_text(name)}
end

function A.go_home(player)
  return A.go(player, {location = "nauvis"})
end

function A.view(player, args)
  local name = args and args.location
  if not (name and game.planets[name]) then return false, {"pst.need-location"} end
  local surface = planet_surface(name, 4)
  if not surface then return false, {"pst.no-surface", location_text(name)} end
  local position = player.force.get_spawn_position(surface)
  player.force.chart(surface, {{position.x - 256, position.y - 256}, {position.x + 256, position.y + 256}})
  player.set_controller({type = defines.controllers.remote, surface = surface, position = position})
  return true, {"pst.viewing", location_text(name)}
end

-------------------------------------------------------------------------------- platforms

local function selected_platform(player, args)
  local index = args and args.platform or common.pdata(player).platform
  local platform = index and player.force.platforms[index]
  if platform and platform.valid and platform.scheduled_for_deletion == 0 then return platform end
  -- Fallback: the platform the player is on.
  platform = player.surface.platform
  if platform and platform.valid and platform.force == player.force then return platform end
  return nil
end
A.selected_platform = selected_platform

local function platform_text(platform)
  return {"", "[img=utility/starmap_platform_stopped] ", platform.name}
end

local function current_planet_name(player)
  local planet = player.physical_surface and player.physical_surface.planet
  if planet then return planet.name end
  local platform = player.surface.platform
  local loc = platform and platform.space_location
  if loc and game.planets[loc.name] then return loc.name end
  return "nauvis"
end

A.global["platform-create"] = true
function A.platform_create(player, args)
  if not script.feature_flags.space_travel then return false, {"pst.no-space-travel"} end
  local location = args and args.location or current_planet_name(player)
  if not game.planets[location] then location = "nauvis" end
  local pack = "space-platform-starter-pack"
  if not prototypes.item[pack] then return false, {"pst.no-starter-pack"} end
  local platform = player.force.create_space_platform({planet = location, starter_pack = pack})
  if not platform then return false, {"pst.platform-failed"} end
  platform.apply_starter_pack()
  common.pdata(player).platform = platform.index
  return true, {"pst.platform-created", platform_text(platform), location_text(location)}
end

function A.platform_enter(player, args)
  local platform = selected_platform(player, args)
  if not platform then return false, {"pst.need-platform"} end
  if not platform.hub then platform.apply_starter_pack() end
  if player.enter_space_platform(platform) then
    return true, {"pst.platform-entered", platform_text(platform)}
  end
  -- A player enters only from the planet below: move the platform there first.
  local here = current_planet_name(player)
  if platform.space_location == nil or platform.space_location.name ~= here then
    platform.space_location = here
    if player.enter_space_platform(platform) then
      return true, {"pst.platform-entered-moved", platform_text(platform), location_text(here)}
    end
  end
  return false, {"pst.platform-enter-failed", platform_text(platform)}
end

function A.platform_leave(player)
  if not player.surface.platform then return false, {"pst.not-on-platform"} end
  player.leave_space_platform()
  return true, {"pst.platform-left"}
end

A.global["platform-move"] = true
function A.platform_move(player, args)
  local platform = selected_platform(player, args)
  if not platform then return false, {"pst.need-platform"} end
  local name = args and args.location
  if not (name and prototypes.space_location[name]) then return false, {"pst.need-location"} end
  platform.space_location = name
  return true, {"pst.platform-moved", platform_text(platform), location_text(name)}
end

A.global["platform-pause"] = true
function A.platform_pause(player, args)
  local platform = selected_platform(player, args)
  if not platform then return false, {"pst.need-platform"} end
  platform.paused = not platform.paused
  return true, {platform.paused and "pst.platform-paused" or "pst.platform-resumed", platform_text(platform)}
end

function A.platform_kit(player, args)
  local platform = selected_platform(player, args)
  if not platform then return false, {"pst.need-platform"} end
  if not platform.hub then platform.apply_starter_pack() end
  local hub = platform.hub
  if not (hub and hub.valid) then return false, {"pst.no-hub"} end
  local quality = common.quality_name(common.pdata(player).quality)
  local lost = 0
  for _, entry in ipairs(catalog.platform_kit()) do
    local done = hub.insert({name = entry.name, quality = quality, count = entry.count})
    lost = lost + (entry.count - done)
  end
  if lost > 0 then return true, {"pst.platform-kit-partly", platform_text(platform), lost} end
  return true, {"pst.platform-kit-done", platform_text(platform)}
end

A.global["platform-delete"] = true
A.confirm["platform-delete"] = true
function A.platform_delete(player, args)
  local platform = selected_platform(player, args)
  if not platform then return false, {"pst.need-platform"} end
  local name = platform.name
  if player.surface.platform == platform then player.leave_space_platform() end
  platform.destroy(1)
  common.pdata(player).platform = nil
  return true, {"pst.platform-deleted", name}
end

-- A cloud of asteroid chunks drifting past the hub: tests asteroid collectors.
function A.platform_chunks(player, args)
  local platform = selected_platform(player, args)
  if not (platform and platform.hub and platform.hub.valid) then return false, {"pst.need-platform"} end
  local names = catalog.asteroid_chunks()
  if #names == 0 then return false, {"pst.no-chunks"} end
  local hub = platform.hub.position
  local chunks = {}
  for i = 1, 40 do
    local name = names[(i - 1) % #names + 1]
    chunks[#chunks + 1] = {name = name, position = {hub.x - 30 + (i % 10) * 6, hub.y - 40 - math.floor(i / 10) * 4},
      movement = {0, 0.03}}
  end
  platform.create_asteroid_chunks(chunks)
  return true, {"pst.chunks-sent", platform_text(platform), #chunks}
end

-- A wave of medium asteroids heading for the hub: tests turrets and repairs.
function A.platform_asteroids(player, args)
  local platform = selected_platform(player, args)
  if not (platform and platform.hub and platform.hub.valid) then return false, {"pst.need-platform"} end
  local names = catalog.asteroids()
  if #names == 0 then return false, {"pst.no-asteroids"} end
  local hub = platform.hub.position
  local surface = platform.surface
  local made = 0
  for i = 1, 8 do
    local entity = surface.create_entity({name = names[(i - 1) % #names + 1],
      position = {hub.x - 28 + i * 7, hub.y - 60}, velocity = {0, 0.08}})
    if entity then made = made + 1 end
  end
  return true, {"pst.asteroids-sent", platform_text(platform), made}
end

-------------------------------------------------------------------------------- items

function A.give(player, args)
  local name = arg(player, args, "item")
  if not (name and prototypes.item[name]) then return false, {"pst.need-item"} end
  local quality = common.quality_name(arg(player, args, "quality"))
  local count = args and args.count or common.amount_for(player, name)
  local done = common.give(player, name, quality, count)
  if done == 0 then return false, {"pst.inventory-full"} end
  if done < count then
    return true, {"pst.given-partly", "[item=" .. name .. ",quality=" .. quality .. "]", done, count}
  end
  return true, {"pst.given", "[item=" .. name .. ",quality=" .. quality .. "]", done}
end

-- Infinity chests near the player, each filter keeps a full stack of one item.
local function infinity_chests(player, names, quality)
  if not prototypes.entity["infinity-chest"] then return 0, 0 end
  local surface = player.surface
  local base = common.view_position(player)
  local slots = prototypes.entity["infinity-chest"].get_inventory_size(defines.inventory.chest) or 48
  local chests, placed = 0, 0
  local i = 1
  while i <= #names do
    local spot = common.free_spot(surface, "infinity-chest", {base.x + 2 + chests, base.y + 2}, 24)
    if not spot then break end
    local chest = surface.create_entity({name = "infinity-chest", position = spot, force = player.force})
    if not chest then break end
    chests = chests + 1
    local slot = 1
    while slot <= slots and i <= #names do
      local item = prototypes.item[names[i]]
      chest.set_infinity_container_filter(slot, {name = names[i], quality = quality, count = item.stack_size,
        mode = "at-least"})
      slot = slot + 1
      placed = placed + 1
      i = i + 1
    end
  end
  return chests, placed
end

function A.infinite(player, args)
  local name = arg(player, args, "item")
  if not (name and prototypes.item[name]) then return false, {"pst.need-item"} end
  local quality = common.quality_name(arg(player, args, "quality"))
  local chests = infinity_chests(player, {name}, quality)
  if chests == 0 then return false, {"pst.no-room"} end
  return true, {"pst.infinite-chest", "[item=" .. name .. ",quality=" .. quality .. "]"}
end

-- Infinity pipes near the player, one per fluid.
local function infinity_pipes(player, fluids, temperature)
  if not prototypes.entity["infinity-pipe"] then return 0 end
  local surface = player.surface
  local base = common.view_position(player)
  local made = 0
  for i, name in ipairs(fluids) do
    local spot = common.free_spot(surface, "infinity-pipe", {base.x - 2 - (i - 1) * 2, base.y + 3}, 24)
    if not spot then break end
    local pipe = surface.create_entity({name = "infinity-pipe", position = spot, force = player.force})
    if pipe then
      local fluid = prototypes.fluid[name]
      local t = temperature
      if t then t = math.max(fluid.default_temperature, math.min(fluid.max_temperature, t)) end
      pipe.set_infinity_pipe_filter({name = name, percentage = 1, temperature = t or fluid.default_temperature,
        mode = "at-least"})
      made = made + 1
    end
  end
  return made
end

function A.fluid_pipe(player, args)
  local name = arg(player, args, "fluid")
  if not (name and prototypes.fluid[name]) then return false, {"pst.need-fluid"} end
  local temperature = tonumber(arg(player, args, "fluid_temperature"))
  local made = infinity_pipes(player, {name}, temperature)
  if made == 0 then return false, {"pst.no-room"} end
  return true, {"pst.infinite-pipe", "[fluid=" .. name .. "]"}
end

local function kit_of(args)
  local discovery = args and args.discovery
  if not (discovery and prototypes.technology[discovery]) then return nil end
  return catalog.kit(discovery), discovery
end

function A.kit_buildings(player, args)
  local kit, discovery = kit_of(args)
  if not kit then return false, {"pst.need-kit"} end
  if #kit.buildings == 0 then return false, {"pst.kit-empty"} end
  local quality = common.quality_name(common.pdata(player).quality)
  local given, wanted = 0, 0
  for _, name in ipairs(kit.buildings) do
    local count = math.min(10, prototypes.item[name].stack_size)
    wanted = wanted + count
    given = given + common.give(player, name, quality, count)
  end
  local where = {"", "[technology=" .. discovery .. "]"}
  if given < wanted then return true, {"pst.kit-buildings-partly", where, given, wanted} end
  return true, {"pst.kit-buildings", where, #kit.buildings}
end

function A.kit_materials(player, args)
  local kit, discovery = kit_of(args)
  if not kit then return false, {"pst.need-kit"} end
  local names = {}
  for _, n in ipairs(kit.materials) do names[#names + 1] = n end
  for _, n in ipairs(kit.packs) do names[#names + 1] = n end
  if #names == 0 then return false, {"pst.kit-empty"} end
  local chests, placed = infinity_chests(player, names, common.quality_name(common.pdata(player).quality))
  if chests == 0 then return false, {"pst.no-room"} end
  return true, {"pst.kit-materials", "[technology=" .. discovery .. "]", placed, chests}
end

function A.kit_fluids(player, args)
  local kit, discovery = kit_of(args)
  if not kit then return false, {"pst.need-kit"} end
  if #kit.fluids == 0 then return false, {"pst.kit-empty"} end
  local made = infinity_pipes(player, kit.fluids, nil)
  if made == 0 then return false, {"pst.no-room"} end
  return true, {"pst.kit-fluids", "[technology=" .. discovery .. "]", made}
end

function A.kit_packs(player, args)
  local kit, discovery = kit_of(args)
  if not kit then return false, {"pst.need-kit"} end
  if #kit.packs == 0 then return false, {"pst.kit-empty"} end
  local quality = common.quality_name(common.pdata(player).quality)
  local given = 0
  for _, name in ipairs(kit.packs) do
    given = given + common.give(player, name, quality, common.amount_for(player, name))
  end
  if given == 0 then return false, {"pst.inventory-full"} end
  return true, {"pst.kit-packs", "[technology=" .. discovery .. "]", given}
end

function A.kit_platform(player)
  local quality = common.quality_name(common.pdata(player).quality)
  local given, wanted = 0, 0
  for _, entry in ipairs(catalog.platform_kit()) do
    wanted = wanted + entry.count
    given = given + common.give(player, entry.name, quality, entry.count)
  end
  if given == 0 then return false, {"pst.inventory-full"} end
  if given < wanted then return true, {"pst.platform-kit-inventory-partly", given, wanted} end
  return true, {"pst.platform-kit-inventory"}
end

function A.test_tools(player)
  local given = 0
  for _, entry in ipairs(catalog.test_tools()) do
    given = given + common.give(player, entry.name, "normal", entry.count)
  end
  if given == 0 then return false, {"pst.inventory-full"} end
  return true, {"pst.test-tools-given"}
end

function A.duplicate_cursor(player)
  local stack = player.cursor_stack
  if not (stack and stack.valid_for_read) then return false, {"pst.cursor-empty"} end
  local name, quality = stack.name, stack.quality.name
  local done = common.give(player, name, quality, prototypes.item[name].stack_size)
  if done == 0 then return false, {"pst.inventory-full"} end
  return true, {"pst.given", "[item=" .. name .. ",quality=" .. quality .. "]", done}
end

A.confirm["clear-inventory"] = true
function A.clear_inventory(player)
  local inv = player.get_main_inventory()
  if not inv then return false, {"pst.no-inventory"} end
  inv.clear()
  return true, {"pst.inventory-cleared"}
end

-------------------------------------------------------------------------------- modes

-- Character modes add a bonus and take exactly it back, so bonuses of other mods (RPG levels) stay.
local CHARACTER_MODES = {
  run = {{"character_running_speed_modifier", 2}},
  reach = {{"character_reach_distance_bonus", 100}, {"character_build_distance_bonus", 100},
    {"character_resource_reach_distance_bonus", 50}, {"character_item_pickup_distance_bonus", 5}},
  mine = {{"character_mining_speed_modifier", 20}},
}
A.CHARACTER_MODES = CHARACTER_MODES

local function apply_character_mode(player, mode, on)
  local character = player.character
  if not character then return false end
  if mode == "immortal" then
    character.destructible = not on
    return true
  end
  for _, entry in ipairs(CHARACTER_MODES[mode]) do
    local value = character[entry[1]] + (on and entry[2] or -entry[2])
    if value < 0 then value = 0 end
    character[entry[1]] = value
  end
  return true
end

function A.mode(player, args)
  local mode = args and args.mode
  local d = common.pdata(player)
  if mode == "cheat" then
    player.cheat_mode = not player.cheat_mode
    d.modes.cheat = player.cheat_mode
    return true, {player.cheat_mode and "pst.mode-on" or "pst.mode-off", {"pst.mode-cheat"}}
  end
  if not (mode == "immortal" or CHARACTER_MODES[mode]) then return false, {"pst.need-mode"} end
  if not player.character then return false, {"pst.no-character"} end
  local on = not d.modes[mode]
  apply_character_mode(player, mode, on)
  d.modes[mode] = on or nil
  -- Remember which character got the bonus: a new body after death gets it again, an old one gives it back once.
  d.mode_body = player.character.unit_number
  return true, {on and "pst.mode-on" or "pst.mode-off", {"pst.mode-" .. mode}}
end

-- New body (respawn, editor exit): put the active character modes on it.
function A.reapply_modes(player)
  local d = common.pdata(player)
  local character = player.character
  if not character or d.mode_body == character.unit_number then return end
  for mode, on in pairs(d.modes) do
    if on and mode ~= "cheat" then apply_character_mode(player, mode, true) end
  end
  d.mode_body = character.unit_number
end

A.global["speed"] = true
function A.speed(player, args)
  local value = tonumber(args and args.value)
  if value == 0 then
    game.tick_paused = not game.tick_paused
    return true, {game.tick_paused and "pst.paused" or "pst.unpaused"}
  end
  if not value or value < 0.01 then return false, {"pst.need-speed"} end
  game.tick_paused = false
  game.speed = value
  return true, {"pst.speed-set", value}
end

A.global["always-day"] = true
function A.always_day(player)
  local surface = player.surface
  surface.always_day = not surface.always_day
  return true, {surface.always_day and "pst.always-day-on" or "pst.always-day-off"}
end

A.global["peaceful"] = true
function A.peaceful(player)
  local surface = player.surface
  surface.peaceful_mode = not surface.peaceful_mode
  return true, {surface.peaceful_mode and "pst.peaceful-on" or "pst.peaceful-off"}
end

-- Power without wires: the surface's global electric network fed by one energy interface.
A.global["free-power"] = true
function A.free_power(player)
  local surface = player.surface
  common.init_storage()
  local entry = storage.power[surface.index]
  if entry then
    if entry.interface and entry.interface.valid then entry.interface.destroy() end
    if surface.has_global_electric_network then surface.destroy_global_electric_network() end
    storage.power[surface.index] = nil
    return true, {"pst.free-power-off"}
  end
  if not prototypes.entity["electric-energy-interface"] then return false, {"pst.no-energy-interface"} end
  surface.create_global_electric_network()
  local spot = common.free_spot(surface, "electric-energy-interface", common.view_position(player), 32)
  local interface = spot and surface.create_entity({name = "electric-energy-interface", position = spot,
    force = player.force})
  if interface then
    interface.electric_buffer_size = 1e12
    interface.power_production = 1e10
    interface.energy = 1e12
  end
  storage.power[surface.index] = {interface = interface}
  return true, {"pst.free-power-on"}
end

A.global["evolution"] = true
function A.evolution(player)
  local settings = game.map_settings.enemy_evolution
  settings.enabled = not settings.enabled
  return true, {settings.enabled and "pst.evolution-on" or "pst.evolution-off"}
end

A.global["evolution-reset"] = true
function A.evolution_reset(player)
  local enemy = game.forces["enemy"]
  if not enemy then return false, {"pst.no-enemies"} end
  enemy.set_evolution_factor(0, player.surface)
  return true, {"pst.evolution-reset-done"}
end

A.global["kill-enemies"] = true
function A.kill_enemies(player, args)
  local radius = tonumber(args and args.radius) or 200
  local surface = player.surface
  local position = common.view_position(player)
  local count = 0
  for _, force in pairs(game.forces) do
    if force ~= player.force and player.force.is_enemy(force) then
      for _, entity in pairs(surface.find_entities_filtered({position = position, radius = radius, force = force})) do
        if entity.valid and entity.destroy({raise_destroy = true}) then count = count + 1 end
      end
    end
  end
  return true, {"pst.enemies-removed", count, radius}
end

function A.chart(player, args)
  local radius = tonumber(args and args.radius) or 512
  local p = common.view_position(player)
  player.force.chart(player.surface, {{p.x - radius, p.y - radius}, {p.x + radius, p.y + radius}})
  return true, {"pst.charted", radius}
end

function A.chart_all(player)
  player.force.chart_all(player.surface)
  return true, {"pst.charted-all"}
end

function A.generate(player, args)
  local radius = tonumber(args and args.radius) or 8
  local surface = player.surface
  surface.request_to_generate_chunks(common.view_position(player), radius)
  surface.force_generate_chunk_requests()
  return true, {"pst.generated", radius * 2 + 1}
end

local function area_around(player, half)
  local p = common.view_position(player)
  local x, y = math.floor(p.x), math.floor(p.y)
  return {{x - half, y - half}, {x + half, y + half}}, x, y
end

function A.clear_area(player)
  local surface = player.surface
  local area = area_around(player, 24)
  local count = 0
  for _, entity in pairs(surface.find_entities_filtered({area = area, type = {"tree", "simple-entity", "cliff",
      "fish", "plant"}})) do
    if entity.valid then
      local ok
      if entity.type == "cliff" then
        ok = entity.destroy({do_cliff_correction = true})
      else
        ok = entity.destroy()
      end
      if ok then count = count + 1 end
    end
  end
  surface.destroy_decoratives({area = area})
  return true, {"pst.area-cleared", count}
end

function A.pave(player, args)
  local surface = player.surface
  local tile = arg(player, args, "tile")
  if not (tile and prototypes.tile[tile]) then
    if surface.platform and prototypes.tile["space-platform-foundation"] then
      tile = "space-platform-foundation"
    elseif prototypes.tile["landfill"] then
      tile = "landfill"
    else
      tile = "refined-concrete"
    end
  end
  local _, x, y = area_around(player, 16)
  local tiles = {}
  for dx = -16, 15 do
    for dy = -16, 15 do tiles[#tiles + 1] = {name = tile, position = {x + dx, y + dy}} end
  end
  surface.set_tiles(tiles, true, false, true, true)
  return true, {"pst.paved", "[tile=" .. tile .. "]"}
end

function A.heal(player)
  local count = 0
  if player.character then
    player.character.health = player.character.max_health
  end
  local surface = player.surface
  local area = area_around(player, 48)
  for _, entity in pairs(surface.find_entities_filtered({area = area, force = player.force})) do
    if entity.valid and entity.health and entity.max_health and entity.health < entity.max_health then
      entity.health = entity.max_health
      count = count + 1
    end
  end
  return true, {"pst.healed", count}
end

function A.editor(player)
  if not player.admin then return false, {"pst.editor-admin"} end
  player.toggle_map_editor()
  return true, {"pst.editor-toggled"}
end

-------------------------------------------------------------------------------- inspect

local function selected_entity(player)
  local entity = player.selected
  if entity and entity.valid then return entity end
  return nil
end

function A.repair_selected(player)
  local entity = selected_entity(player)
  if not (entity and entity.health and entity.max_health) then return false, {"pst.need-selected"} end
  entity.health = entity.max_health
  return true, {"pst.repaired", entity.localised_name}
end

A.confirm["remove-selected"] = true
function A.remove_selected(player)
  local entity = selected_entity(player)
  if not entity or entity.type == "character" then return false, {"pst.need-selected"} end
  local name = entity.localised_name
  if not entity.destroy({raise_destroy = true}) then return false, {"pst.cannot-remove", name} end
  return true, {"pst.removed", name}
end

-- Rocket silo under the cursor (or the nearest one) gets all rocket parts at once.
function A.silo_ready(player)
  local entity = selected_entity(player)
  if not (entity and entity.type == "rocket-silo") then
    local found = player.surface.find_entities_filtered({position = common.view_position(player), radius = 64,
      type = "rocket-silo", force = player.force, limit = 1})
    entity = found[1]
  end
  if not entity then return false, {"pst.need-silo"} end
  entity.rocket_parts = entity.prototype.rocket_parts_required
  return true, {"pst.silo-ready-done", entity.localised_name}
end

-- Text file with what a developer needs to reproduce a problem.
function A.report(player)
  local lines = {}
  local function add(text) lines[#lines + 1] = text end
  local surface = player.surface
  local p = player.position
  add("Paranoidal SA tester report")
  add("tick " .. game.tick .. ", speed " .. game.speed .. (game.tick_paused and " (paused)" or ""))
  add("player " .. player.name .. ", controller " .. tostring(player.controller_type) .. ", surface " .. surface.name ..
    string.format(" at %.1f, %.1f", p.x, p.y))
  if player.physical_surface and player.physical_surface ~= surface then
    add("body on " .. player.physical_surface.name)
  end
  local platform = surface.platform
  if platform then
    add("platform " .. platform.name .. ", location " .. (platform.space_location and platform.space_location.name or
      "in flight") .. ", state " .. tostring(platform.state))
  end
  local entity = selected_entity(player)
  if entity then
    local recipe = entity.type == "assembling-machine" and entity.get_recipe()
    add("selected " .. entity.name .. " (" .. entity.type .. "), quality " .. entity.quality.name ..
      string.format(", at %.1f, %.1f", entity.position.x, entity.position.y) ..
      (entity.status and (", status " .. tostring(entity.status)) or "") ..
      (recipe and (", recipe " .. recipe.name) or ""))
  end
  add("")
  add("properties of " .. surface.name .. ":")
  for _, prop in ipairs(catalog.surface_properties()) do
    local ok, value = pcall(surface.get_property, prop.name)
    add("  " .. prop.name .. " = " .. (ok and tostring(value) or "?"))
  end
  add("")
  add("discoveries:")
  for _, entry in ipairs(catalog.discoveries()) do
    local tech = player.force.technologies[entry.tech]
    add("  " .. entry.tech .. " " .. ((tech and tech.researched) and "researched" or "-") .. ", " .. entry.location ..
      " " .. (player.force.is_space_location_unlocked(entry.location) and "unlocked" or "locked"))
  end
  local current = player.force.current_research
  add("current research: " .. (current and current.name or "none"))
  add("")
  add("platforms:")
  for _, pl in pairs(player.force.platforms) do
    if pl.valid then
      add("  " .. pl.name .. " at " .. (pl.space_location and pl.space_location.name or "in flight") .. ", state " ..
        tostring(pl.state))
    end
  end
  add("")
  add("tester modes: " .. serpent.line(common.pdata(player).modes))
  add("")
  add("mods:")
  local names = {}
  for name in pairs(script.active_mods) do names[#names + 1] = name end
  table.sort(names)
  for _, name in ipairs(names) do add("  " .. name .. " " .. script.active_mods[name]) end
  local file = "paranoidal-sa-tester/report-" .. game.tick .. ".txt"
  helpers.write_file(file, table.concat(lines, "\n") .. "\n", false, player.index)
  return true, {"pst.report-written", "script-output/" .. file}
end

-------------------------------------------------------------------------------- registry

-- GUI/remote names -> functions.
A.by_name = {
  ["research"] = A.research, ["unresearch"] = A.unresearch, ["finish-research"] = A.finish_research,
  ["research-all"] = A.research_all, ["lab-speed"] = A.lab_speed, ["unlock-recipe"] = A.unlock_recipe,
  ["toggle-location"] = A.toggle_location, ["go"] = A.go, ["go-home"] = A.go_home, ["view"] = A.view,
  ["platform-create"] = A.platform_create, ["platform-enter"] = A.platform_enter, ["platform-leave"] = A.platform_leave,
  ["platform-move"] = A.platform_move, ["platform-pause"] = A.platform_pause, ["platform-kit"] = A.platform_kit,
  ["platform-delete"] = A.platform_delete, ["platform-chunks"] = A.platform_chunks,
  ["platform-asteroids"] = A.platform_asteroids,
  ["give"] = A.give, ["infinite"] = A.infinite, ["fluid-pipe"] = A.fluid_pipe, ["kit-buildings"] = A.kit_buildings,
  ["kit-materials"] = A.kit_materials, ["kit-fluids"] = A.kit_fluids, ["kit-packs"] = A.kit_packs,
  ["kit-platform"] = A.kit_platform, ["test-tools"] = A.test_tools, ["duplicate-cursor"] = A.duplicate_cursor,
  ["clear-inventory"] = A.clear_inventory,
  ["mode"] = A.mode, ["speed"] = A.speed, ["always-day"] = A.always_day, ["peaceful"] = A.peaceful,
  ["free-power"] = A.free_power, ["evolution"] = A.evolution, ["evolution-reset"] = A.evolution_reset,
  ["kill-enemies"] = A.kill_enemies, ["chart"] = A.chart, ["chart-all"] = A.chart_all, ["generate"] = A.generate,
  ["clear-area"] = A.clear_area, ["pave"] = A.pave, ["heal"] = A.heal, ["editor"] = A.editor,
  ["repair-selected"] = A.repair_selected, ["remove-selected"] = A.remove_selected, ["silo-ready"] = A.silo_ready,
  ["report"] = A.report,
}

-- Run an action by name; errors become a message instead of a crash of the game.
function A.run(player, name, args)
  local fn = A.by_name[name]
  if not fn then return false, {"pst.unknown-action", name} end
  local ok, result, message = pcall(fn, player, args)
  if not ok then
    log("paranoidal-sa-tester: action " .. name .. " failed: " .. tostring(result))
    return false, {"pst.action-error", tostring(result)}
  end
  return result, message
end

return A
