-- Two ways to fire a M.I.R.V:
-- * ballistic missile silo (ported from MIRV 2.1.0, Klonan; Paranoidal decision 2026-11-05): the silo builds one
--   missile; when it is ready an invisible launcher with one shot stands on the silo. The targeting remote fires it:
--   the missile rises out of the silo and, once off screen, the warheads fall on the target;
-- * the old way (MIRV2 1.0.0): a M.I.R.V sent up in an ordinary rocket leaves a launcher with five shots over the
--   rocket silo, each shot strikes at once. Kept so that missiles already built still work.
local shared = require("shared")

local custom_alert = {type = "item", name = "mirv-targeting-remote"}
local alert_message = {"launch-detected"}
local alert_sound = {path = "entity-build/mirv-target"}
local mirv_item = "mirv-rocket"
local mirv_smoke = "mirv-smoke"
local mirv_smoke_2 = "mirv-smoke-2"
local mirv_target = "mirv-target"
local mirv_entity = "mirv-entity"
local launcher = "mirv-launcher"
local insert_param = {name = "mirv-ammo", count = 5}
local mirv_effect_id = "mirv-launch"
local mirv_projectile = "mirv-projectile"
local mirv_pollution_trigger = "mirv-pollute"
local silo_name = shared.silo

local status = defines.rocket_silo_status

-- storage.mirv: silos[silo unit number] = {entity, launcher, loaded, target}, launchers[launcher unit number] =
-- silo unit number, flying[silo unit number] = true while its missile rises
local script_data =
{
  silos = {},
  launchers = {},
  flying = {}
}

-- Once the missile is this far above its silo it is off screen, and gets swapped for the incoming warheads
local rocket_vanish_height = 100

local make_mirv_launcher = function(silo)
  local launcher = silo.surface.create_entity
  {
    name = launcher,
    position = silo.position,
    force = silo.force
  }
  launcher.insert(insert_param)
  launcher.destructible = false

end

-- 2.0: at launch time the cargo sits in the attached cargo-pod, not in the
-- rocket itself (rocket.get_item_count kept as a fallback)
local get_mirv_count = function(rocket)
  local pod = rocket.cargo_pod
  if pod and pod.valid then
    return pod.get_item_count(mirv_item)
  end
  return rocket.get_item_count(mirv_item)
end

local strike = function(surface, position, source_position, force)

  surface.request_to_generate_chunks(position, 4)

  local create_entity = surface.create_entity

  local target = create_entity
  {
    name = mirv_target,
    position = position,
    force = "neutral"
  }

  local offset = ((position.x - source_position.x) / 2)
  offset = math.min(offset, 1000)
  offset = math.max(offset, -1000)

  local projectile = create_entity
  {
    name = mirv_projectile,
    position = {position.x - offset, target.position.y - 1250},
    force = force,
    target = target,
    speed = math.random(500, 650) / 200
  }

  for k, player in pairs (game.connected_players) do
    if player.surface == surface then
      player.add_custom_alert(target, custom_alert, alert_message, true)
    end
  end

  surface.play_sound(alert_sound)

  surface.create_trivial_smoke{name = mirv_smoke, position = position}
  surface.create_trivial_smoke{name = mirv_smoke_2, position = position}

end

local call_nuke = function(surface, position, source)
  strike(surface, position, source.position, source.force)
end

-- Ballistic missile silo -----------------------------------------------------------------------------------------------

local destroy_launcher = function(silo_data)
  local launcher_entity = silo_data.launcher
  silo_data.launcher = nil
  if not (launcher_entity and launcher_entity.valid) then return end
  script_data.launchers[launcher_entity.unit_number] = nil
  launcher_entity.destroy()
end

local create_launcher = function(silo_data)
  local silo = silo_data.entity
  local launcher_entity = silo.surface.create_entity
  {
    name = launcher,
    position = silo.position,
    force = silo.force
  }
  if not launcher_entity then return end

  launcher_entity.insert{name = "mirv-ammo", count = 1}
  launcher_entity.destructible = false
  silo_data.launcher = launcher_entity
  script_data.launchers[launcher_entity.unit_number] = silo.unit_number
end

local register_silo = function(entity)
  if not (entity and entity.valid and entity.name == silo_name) then return end
  if script_data.silos[entity.unit_number] then return end
  script_data.silos[entity.unit_number] = {entity = entity}
  script.register_on_object_destroyed(entity)
end

local update_silo = function(silo_data)
  if silo_data.loaded then return end
  if silo_data.entity.rocket_silo_status ~= status.rocket_ready then return end
  silo_data.loaded = true
  create_launcher(silo_data)
end

local update_silos = function()
  for unit_number, silo_data in pairs (script_data.silos) do
    if silo_data.entity.valid then
      update_silo(silo_data)
    else
      destroy_launcher(silo_data)
      script_data.silos[unit_number] = nil
    end
  end
end

local launch_missile = function(silo_data, surface, position)
  silo_data.target =
  {
    surface_index = surface.index,
    position = {x = position.x, y = position.y}
  }

  -- LuaEntity::launch_rocket(character?, destination?) is positional and 2.1.24 rejects nil for the character
  -- ("Expected LuaEntity"), so it is called without arguments; the silo cannot launch to space platforms
  if not silo_data.entity.launch_rocket() then
    silo_data.target = nil
    return false
  end

  silo_data.loaded = nil
  script_data.flying[silo_data.entity.unit_number] = true
  return true
end

local missile_arrived = function(silo_data)
  local target = silo_data.target
  silo_data.target = nil
  if not target then return end

  local surface = game.get_surface(target.surface_index)
  if not surface then return end

  local silo = silo_data.entity
  local source_position = silo.surface == surface and silo.position or target.position
  strike(surface, target.position, source_position, silo.force)
end

-- The rocket is removed before it reaches orbit: a missile is not an orbital launch, so it does not count for the
-- rocket launch statistics or the victory
local update_flying = function()
  for unit_number in pairs (script_data.flying) do
    local silo_data = script_data.silos[unit_number]
    local silo = silo_data and silo_data.entity
    if not (silo and silo.valid) then
      script_data.flying[unit_number] = nil
    else
      local rocket = silo.rocket
      if not (rocket and rocket.valid) then
        script_data.flying[unit_number] = nil
        silo_data.target = nil
      elseif rocket.position.y < silo.position.y - rocket_vanish_height then
        script_data.flying[unit_number] = nil
        local pod = rocket.attached_cargo_pod
        if pod and pod.valid then
          pod.destroy()
        end
        rocket.destroy()
        missile_arrived(silo_data)
      end
    end
  end
end

local on_tick = function(event)
  if next(script_data.flying) then
    update_flying()
  end
end

local on_rocket_launch_ordered = function(event)
  local silo = event.rocket_silo
  if not (silo and silo.valid) then return end
  local silo_data = script_data.silos[silo.unit_number]
  if not silo_data then return end
  if silo_data.target then return end

  -- Launched from the silo window without a target, the missile is wasted
  destroy_launcher(silo_data)
  silo_data.loaded = nil
  script_data.flying[silo.unit_number] = true
end

local on_cargo_pod_finished_ascending = function(event)
  local pod = event.cargo_pod
  if not (pod and pod.valid) then return end
  if pod.name ~= shared.cargo_pod then return end
  pod.destroy()
end

local on_built = function(event)
  register_silo(event.entity or event.destination)
end

local on_object_destroyed = function(event)
  local silo_data = script_data.silos[event.useful_id]
  if not silo_data then return end
  destroy_launcher(silo_data)
  script_data.silos[event.useful_id] = nil
  script_data.flying[event.useful_id] = nil
end

local register_existing_silos = function()
  for k, surface in pairs (game.surfaces) do
    for j, entity in pairs (surface.find_entities_filtered{name = silo_name}) do
      register_silo(entity)
    end
  end
end

-- A technology researched before it got a new unlock does not enable the new recipe in an old save
local enable_silo_recipe = function()
  for k, force in pairs (game.forces) do
    local technology = force.technologies["mirv-technology"]
    local recipe = force.recipes[silo_name]
    if technology and recipe and technology.researched then
      recipe.enabled = true
    end
  end
end

-- Both ways -----------------------------------------------------------------------------------------------------------

local on_rocket_launched = function(event)
  local silo = event.rocket_silo
  if not (silo and silo.valid) then return end

  -- A ballistic missile is normally removed on the way up; only reached if it was not
  local silo_data = script_data.silos[silo.unit_number]
  if silo_data then
    script_data.flying[silo.unit_number] = nil
    missile_arrived(silo_data)
    return
  end

  local rocket = event.rocket
  if not (rocket and rocket.valid) then return end

  local item_count = get_mirv_count(rocket)
  if item_count == 0 then return end

  make_mirv_launcher(silo)

end

local mirv_script_trigger = function(event)

  local source = event.source_entity
  if not (source and source.valid) then
    return
  end

  local position = event.target_position
  if not position then return end

  local surface = source.surface

  local flares = surface.find_entities_filtered{name = "mirv-flare", position = position}
  for k, flare in pairs (flares) do
    flare.destroy()
  end

  local silo_unit_number = script_data.launchers[source.unit_number]
  if silo_unit_number then
    local silo_data = script_data.silos[silo_unit_number]
    if not (silo_data and silo_data.entity.valid) then
      script_data.launchers[source.unit_number] = nil
      source.destroy()
      return
    end

    destroy_launcher(silo_data)

    if not launch_missile(silo_data, surface, position) then
      -- Not ready after all (no power, etc.), put the launcher back so it can be fired again
      create_launcher(silo_data)
    end
    return
  end

  -- A launcher left by a rocket with a M.I.R.V strikes at once
  call_nuke(surface, position, source)

  local item_count = source.get_item_count("mirv-ammo")
  if item_count == 1 then

    source.destructible = false
    source.destroy()

  end

end

local offsets =
{
  {8, 8},
  {-8, -8},
  {-8, 8},
  {8, -8}
}

local mirv_pollute_trigger = function(event)
  local position = event.target_position
  if not position then return end
  local surface = game.get_surface(event.surface_index)
  if not surface then return end

  for k, offset in pairs (offsets) do
    surface.pollute({position.x + offset[1], position.y + offset[2]}, 666/#offsets)
  end
  -- 2.0: pollution statistics are per-surface, game.pollution_statistics is gone
  game.get_pollution_statistics(surface).on_flow(launcher, 666)
end

local on_script_trigger_effect = function(event)
  if event.effect_id == mirv_effect_id then
    mirv_script_trigger(event)
    return
  end

  if event.effect_id == mirv_pollution_trigger then
    mirv_pollute_trigger(event)
    return
  end

end

remote.add_interface("mirv",
{
  call_nuke = call_nuke
})

local lib = {}

lib.events =
{
  [defines.events.on_tick] = on_tick,
  [defines.events.on_rocket_launched] = on_rocket_launched,
  [defines.events.on_rocket_launch_ordered] = on_rocket_launch_ordered,
  [defines.events.on_cargo_pod_finished_ascending] = on_cargo_pod_finished_ascending,
  [defines.events.on_script_trigger_effect] = on_script_trigger_effect,
  [defines.events.on_object_destroyed] = on_object_destroyed,
  [defines.events.on_built_entity] = on_built,
  [defines.events.on_robot_built_entity] = on_built,
  [defines.events.script_raised_built] = on_built,
  [defines.events.script_raised_revive] = on_built,
  [defines.events.on_entity_cloned] = on_built,
}

lib.on_nth_tick =
{
  [30] = update_silos
}

lib.on_init = function()
  storage.mirv = storage.mirv or script_data
  script_data = storage.mirv
  register_existing_silos()
end

lib.on_load = function()
  script_data = storage.mirv or script_data
end

lib.on_configuration_changed = function()
  storage.mirv = storage.mirv or script_data
  script_data = storage.mirv
  script_data.silos = script_data.silos or {}
  script_data.launchers = script_data.launchers or {}
  script_data.flying = script_data.flying or {}
  register_existing_silos()
  enable_silo_recipe()
end

local handler = require("event_handler")

handler.add_lib(lib)
