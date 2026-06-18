local Loader = {
  name_fluid_alert_sprite = "fluid-icon-red",
  minute = 60 * 60,
  ---@type table<string, LoaderConfig>
  configuration = {},
  event_filters = {{filter="type", type="loader-1x1"}},
  is_lubricant_mode = (settings.startup["aai-loaders-mode"].value == "lubricated"),
  belt_stacking_mode = script.feature_flags["space_travel"] and settings.startup["aai-loaders-belt-stacking-mode"].value or "off",
  snap_targets = {
    "container",
    "logistic-container",
    "linked-container",
    "infinity-container",
    "assembling-machine",
    "furnace",
    "rocket-silo",
    "mining-drill",
    "lab",
    "boiler",
    "reactor",
    "fusion-reactor",
    "ammo-turret",
    "artillery-turret",
    "straight-rail",
    "agricultural-tower",
    "asteroid-collector",
  }
}

---@class LoaderConfig
---@field rate integer fluid consumption per minute
---@field interval integer
---@field filter string

if Loader.is_lubricant_mode then
  for name, _ in pairs(prototypes.get_entity_filtered({{filter = "type", type = "loader-1x1"}})) do
    if not Util.string_starts(name, "aai-") then goto continue end

    local pipe_prototype = prototypes.entity[name.."-pipe"]
    assert(pipe_prototype, "Could not find pipe prototype for loader: "..name)

    local rate = pipe_prototype.fluidbox_prototypes[1].volume - 100
    local interval = rate < 1 and math.floor(Loader.minute / rate) or Loader.minute
    local filter = pipe_prototype.fluidbox_prototypes[1].filter.name

    Loader.configuration[name] = {
      rate = math.max(1, rate),
      interval = interval,
      filter = filter
    }

    ::continue::
  end
end

-- Fluid type is set by the pipe filter.
-- Fluid usage is encoded in the pipe capacity.
-- Consume minimum of 1 per check; consume more if check interval would be less than 1 minute.

---Initializes storage tables as appropriate.
function Loader.on_init()
  ---@type boolean Is lubricant-mode active?
  storage.is_lubricant_mode = Loader.is_lubricant_mode

  ---@type string The belt stacking mode when the world was saved
  storage.previous_belt_stacking_mode = Loader.belt_stacking_mode

  ---No need to initalize other tables if lubrican mode is not on
  if not Loader.is_lubricant_mode then return end

  ---@type table<uint, LoaderType> Table of loaders, indexed by `unit_number`
  storage.loaders = {}
  ---@type LoaderType[] Array of "dry" (inactive) loaders, which are polled frequently
  storage.dry_loaders = {}
  ---@type table<uint, LoaderType> Table of "wet" (active) loaders, indexed by game tick
  storage.wet_loaders = {}
end
script.on_init(Loader.on_init)

---@param event ConfigurationChangedData
function Loader.on_configuration_changed(event)
  Migrate.do_migrations(event)

  Loader.on_configuration_changed_for_lubrication(event)
  Loader.on_configuration_changed_for_belt_stacking(event)
end
script.on_configuration_changed(Loader.on_configuration_changed)

---@return LuaEntity[]
function Loader.find_all_aai_loaders()
  local aai_loaders = {}

  for _, surface in pairs(game.surfaces) do
    local all_loaders = surface.find_entities_filtered{type="loader-1x1"}
    for _, loader in pairs(all_loaders) do
      if Util.string_starts(loader.name, "aai-") then
        table.insert(aai_loaders, loader)
      end
    end
  end

  return aai_loaders
end

---@param event ConfigurationChangedData
function Loader.on_configuration_changed_for_lubrication(event)
  -- Exit if no change in lubricant-mode setting
  if not event.mod_startup_settings_changed then return end
  if storage.is_lubricant_mode == Loader.is_lubricant_mode then return end

  if Loader.is_lubricant_mode then
    -- Lubricant-mode is getting turned ON
    storage.loaders = {}
    storage.dry_loaders = {}
    storage.wet_loaders = {}

    for _, aai_loader in ipairs(Loader.find_all_aai_loaders()) do
      Loader.make_lubricated_loader(aai_loader)
    end
  else
    -- Lubricant-mode is getting turned OFF
    -- Activate all loaders before deleting storage tables
    for _, loader in pairs(storage.loaders) do
      if loader.loader.valid then
        loader.loader.active = true
      end

      if loader.alert and loader.alert.valid then
        loader.alert.destroy()
      end
    end

    storage.loaders = nil
    storage.dry_loaders = nil
    storage.wet_loaders = nil
  end

  storage.is_lubricant_mode = Loader.is_lubricant_mode
end

---@param event ConfigurationChangedData
function Loader.on_configuration_changed_for_belt_stacking(event)

  if storage.previous_belt_stacking_mode == "off" and Loader.belt_stacking_mode == "opt-in" then
    for _, aai_loader in ipairs(Loader.find_all_aai_loaders()) do
      if aai_loader.loader_belt_stack_size_override == 0 then
         aai_loader.loader_belt_stack_size_override = 1
      end
    end
  end

  storage.previous_belt_stacking_mode = Loader.belt_stacking_mode
end

---Creates a pipe for the given AAI loader entity.
---@param entity LuaEntity Loader entity, _must_ be an AAI loader
---@return LuaEntity pipe
function Loader.make_pipe(entity)
  local entity_position = entity.position
  local pipe_name = entity.name .. "-pipe"
  local pipe_position = {entity_position.x, entity_position.y + 1/32}
  local pipe = entity.surface.find_entity(pipe_name, pipe_position)

  if not pipe then
    pipe = entity.surface.create_entity({
      name = pipe_name,
      position = pipe_position,
      force = entity.force,
      direction = entity.direction
    }) --[[@as LuaEntity]]
  end

  pipe.destructible = false

  return pipe
end

---Draws a fluid alert sprite for a given `LoaderType`. Loader entity _must_ be valid.
---@param loader LoaderType Loader data
function Loader.draw_alert(loader)
  loader.alert = rendering.draw_sprite{
    surface = loader.loader.surface,
    target = loader.loader,
    forces = {loader.loader.force},
    sprite = Loader.name_fluid_alert_sprite,
    x_scale = 0.33,
    y_scale = 0.33,
  }
end

---Checks a given loader to see if it should be wet or dry.
---@param loader LoaderType Loader data
---@param tick? uint Current game tick
function Loader.check(loader, tick)
  -- Exit if loader entity is no longer valid
  if not loader.loader.valid then
    Loader.cleanup(loader.unit_number)
    return
  end

  -- Create pipe if it has been destroyed
  if not loader.pipe.valid then
    loader.pipe = Loader.make_pipe(loader.loader)
  end

  local wet = false
  local fluid = loader.pipe.get_fluid(1)

  local configuration = Loader.configuration[loader.loader.name]

  if fluid and fluid.name == configuration.filter then

    if fluid.amount > configuration.rate then
      loader.pipe.remove_fluid({name = fluid.name, amount = configuration.rate})
      loader.loader.force.get_fluid_production_statistics(loader.loader.surface).on_flow(
        fluid.name,
        -configuration.rate  --[[@as float]]
      )
      wet = true
    end
  end

  loader.next_wet_check = nil
  if wet then
    loader.loader.active = true
    if not loader.wet then
      -- If loader was previously dry, destroy the alert and remove it from dry loaders table
      if loader.alert and loader.alert.valid then loader.alert.destroy() end
      loader.alert = nil
      Util.remove_from_array(storage.dry_loaders, loader)
    end

    -- Schedule next check for this wet loader
    local next_check = (tick or game.tick) + configuration.interval
    storage.wet_loaders[next_check] = storage.wet_loaders[next_check] or {}
    table.insert(storage.wet_loaders[next_check], loader)
    loader.next_wet_check = next_check
  else

    loader.loader.active = false
    if loader.wet then
      Loader.draw_alert(loader)
      table.insert(storage.dry_loaders, storage.loaders[loader.unit_number])
    end
  end

  -- Update internal `LoaderType` status
  loader.wet = wet
end

---Removes `LoaderType` tables associated with a given `unit_number`.
---@param unit_number uint `unit_number` of loader entity
function Loader.cleanup(unit_number)
  local loader = storage.loaders[unit_number]
  if not loader then return end

  -- Destroy pipe entity if it exists
  if loader.pipe and loader.pipe.valid then
    local is_mined = loader.pipe.mine{raise_destroyed=false, ignore_minable=true}
    if not is_mined then loader.pipe.destroy() end
  end

  -- Clean up storage tables
  storage.loaders[unit_number] = nil

  if not loader.wet then
    Util.remove_from_array(storage.dry_loaders, loader)
  elseif loader.next_wet_check then
    Util.remove_from_array(storage.wet_loaders[loader.next_wet_check] or { }, loader)
  end
end

---Searches for neighbors to determine if loader should be rotated
---@param loader LuaEntity Loader entity
function Loader.attempt_snap(loader)

  local surface = loader.surface
  local force_name = loader.force.name
  local loader_position = loader.position
  local original_direction = loader.direction
  local original_type = loader.loader_type
  local x, y = loader_position.x, loader_position.y
  local from_x, from_y, to_x, to_y
  local snap_targets = Loader.snap_targets
  local is_entity_connected

  if original_direction == defines.direction.north then
    from_x, from_y = x, y + 1
    to_x, to_y = x, y - 1
  elseif original_direction == defines.direction.east then
    from_x, from_y = x - 1, y
    to_x, to_y = x + 1, y
  elseif original_direction == defines.direction.south then
    from_x, from_y = x, y - 1
    to_x, to_y = x, y + 1
  elseif original_direction == defines.direction.west then
    from_x, from_y = x + 1, y
    to_x, to_y = x - 1, y
  else
    error("Bad direction " .. original_direction)
  end

  if original_type == "output" then
    -- If loader outputs onto a belt-connectible entity, then exit
    if next(loader.belt_neighbours.outputs) then return end

    -- Note whether loader would output from an entity in original configuration
    loader.update_connections()
    if loader.loader_container then is_entity_connected = true end

    -- Switch loader type and see if it connects to a belt-connectible entity
    loader.loader_type = "input"
    if next(loader.belt_neighbours.inputs) then return end

    -- Flip loader and see if it connects to a belt connectible entity or container
    loader.direction = original_direction --[[@as defines.direction]]
    if next(loader.belt_neighbours.inputs) then return end

    loader.update_connections()

    -- Determine if original configuration should be restored
    if is_entity_connected or
        surface.count_entities_filtered{ghost_type=snap_targets, position={from_x, from_y}, force=force_name, limit=1} > 0 or
        surface.count_entities_filtered{type="straight-rail", position={from_x, from_y}, force=force_name, limit=1} > 0 or
        (not loader.loader_container and
        surface.count_entities_filtered{ghost_type=snap_targets, position={to_x, to_y}, force=force_name, limit=1} == 0 and
        surface.count_entities_filtered{type="straight-rail", position={to_x, to_y}, force=force_name, limit=1} == 0) then
      loader.loader_type = original_type
      loader.direction = original_direction --[[@as defines.direction]]
    end
  else
    -- If loader takes input from a belt-connectible entity, then exit
    if next(loader.belt_neighbours.inputs) then return end

    -- Note whether loader would input to an entity in original configuration
    loader.update_connections()
    if loader.loader_container then is_entity_connected = true end

    -- Switch loader type and see if it connects to a belt-connectible entity
    loader.loader_type = "output"
    if next(loader.belt_neighbours.outputs) then return end

    -- Flip loader and see if it connects to a belt connectible entity or container
    loader.direction = original_direction --[[@as defines.direction]]
    if next(loader.belt_neighbours.outputs) then return end

    loader.update_connections()

    -- Determine if original configuration should be restored
    if is_entity_connected or
        surface.count_entities_filtered{ghost_type=snap_targets, position={to_x, to_y}, force=force_name, limit=1} > 0 or
        surface.count_entities_filtered{type="straight-rail", position={to_x, to_y}, force=force_name, limit=1} > 0 or
        (not loader.loader_container and
        surface.count_entities_filtered{ghost_type=snap_targets, position={from_x, from_y}, force=force_name, limit=1} == 0 and
        surface.count_entities_filtered{type="straight-rail", position={from_x, from_y}, force=force_name, limit=1} == 0) then
      loader.loader_type = original_type
      loader.direction = original_direction --[[@as defines.direction]]
    end
  end
end

---Makes and returns a `LoaderType` table from a given loader entity.
---@param entity LuaEntity Loader entity
function Loader.make_lubricated_loader(entity)
  entity.active = false

  local unit_number = entity.unit_number --[[@as uint]]

  ---@class LoaderType
  ---@field loader LuaEntity Loader entity
  ---@field pipe LuaEntity Pipe entity
  ---@field unit_number uint Loader unit number
  ---@field wet boolean Whether loader is wet (active) or dry (inactive)
  ---@field alert LuaRenderObject? the alert icon
  ---@field next_wet_check uint? Tick when the loader will be checked again (when wet)
  local loader = {
    unit_number = unit_number,
    surface_index = entity.surface.index,
    loader = entity,
    pipe = Loader.make_pipe(entity),
    wet = false
  }

  Loader.draw_alert(loader)

  storage.loaders[unit_number] = loader
  table.insert(storage.dry_loaders, loader)
end

---Handles cration of a new loader.
---@param event EventData.on_built_entity|EventData.on_robot_built_entity|EventData.on_entity_cloned|EventData.script_raised_built|EventData.script_raised_revive
function Loader.on_entity_created(event)
  local entity = event.entity or event.destination
  if not Util.string_starts(entity.name, "aai-") then return end

  -- Try to snap to neightbor
  Loader.attempt_snap(entity)

  -- Extra processing if in lubricant-mode
  if Loader.is_lubricant_mode then Loader.make_lubricated_loader(entity) end

  if Loader.belt_stacking_mode == "opt-in" then
    if entity.loader_belt_stack_size_override == 0 then
       entity.loader_belt_stack_size_override = 1
    end
  end
end
script.on_event(defines.events.on_entity_cloned, Loader.on_entity_created, Loader.event_filters)
script.on_event(defines.events.on_built_entity, Loader.on_entity_created, Loader.event_filters)
script.on_event(defines.events.on_robot_built_entity, Loader.on_entity_created, Loader.event_filters)
script.on_event(defines.events.script_raised_built, Loader.on_entity_created, Loader.event_filters)
script.on_event(defines.events.script_raised_revive, Loader.on_entity_created, Loader.event_filters)
script.on_event(defines.events.on_space_platform_built_entity, Loader.on_entity_created, Loader.event_filters)

---Handle the removal of a loader in lubricant-mode.
---@param event EventData.on_entity_died|EventData.on_robot_mined_entity|EventData.on_player_mined_entity|EventData.script_raised_destroy
function Loader.on_removed_entity(event)
  -- Exit if _not_ an AAI loader
  if not Util.string_starts(event.entity.name, "aai-") then return end

  Loader.cleanup(event.entity.unit_number)
end
if Loader.is_lubricant_mode then
  script.on_event(defines.events.on_entity_died, Loader.on_removed_entity, Loader.event_filters)
  script.on_event(defines.events.on_robot_mined_entity, Loader.on_removed_entity, Loader.event_filters)
  script.on_event(defines.events.on_player_mined_entity, Loader.on_removed_entity, Loader.event_filters)
  script.on_event(defines.events.script_raised_destroy, Loader.on_removed_entity, Loader.event_filters)
  script.on_event(defines.events.on_space_platform_mined_entity, Loader.on_removed_entity, Loader.event_filters)  
end

---Updates `active` status of loaders in lubricant-mode based on whether there is enough lubricant
---@param event EventData Event data
function Loader.on_tick(event)
  -- Iterate over wet loaders scheduled to be checked in this tick
  if storage.wet_loaders[event.tick] then
    for _, loader in pairs(storage.wet_loaders[event.tick]) do
      Loader.check(loader, event.tick)
    end
  end
  storage.wet_loaders[game.tick] = nil


  -- Iterate over a maximum of 10 dry loaders to see if they can be activated
  for _ = 1, 10 do
    local loader = storage.dry_loaders[storage.dry_loaders_next or 1]
    if loader then Loader.check(loader, event.tick) end

    storage.dry_loaders_next = (storage.dry_loaders_next or 1) + 1
    if storage.dry_loaders_next > #storage.dry_loaders then
      storage.dry_loaders_next = 1
      break
    end
  end
end
if Loader.is_lubricant_mode then
  script.on_event(defines.events.on_tick, Loader.on_tick)
end

return Loader
