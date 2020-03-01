local configchange = require "configchange"
local delaydestroy = require "delaydestroy"
local ghostconnections = require "ghostconnections"
local inserter_config = require "inserterconfig"
local util = require "util"

-- constants

local num_inserters = 2

local allowed_items_setting = settings.global["railloader-allowed-items"].value

local function on_init()
  delaydestroy.on_init()
  ghostconnections.on_init()
  inserter_config.on_init()
end

local function on_load()
  delaydestroy.on_load()
  inserter_config.on_load()
end

local function on_configuration_changed(configuration_changed_data)
  local mod_change = configuration_changed_data.mod_changes["railloader"]
  if mod_change and mod_change.old_version and mod_change.old_version ~= mod_change.new_version then
    configchange.on_mod_version_changed(mod_change.old_version)
  end
end

local function show_error(entity)
  entity.surface.create_entity{
    name = "flying-text",
    position = entity.position,
    text = {"railloader.invalid-position"},
  }
end

local function abort_build(event)
  local entity = event.created_entity
  show_error(entity)
  if event.player_index then
    local player = game.players[event.player_index]
    player.mine_entity(entity, true)
  else
    entity.order_deconstruction(entity.force)
  end
end

local function sync_interface_inserters(loader)
  local type = util.railloader_type(loader.name)
  local interface_chests = util.find_chests_from_railloader(loader)
  for _, interface_chest in ipairs(interface_chests) do
    local inserter = util.find_inserter_for_interface(loader, interface_chest)
    if not inserter then
      local main_chest_position = util.loader_position_for_interface(loader, interface_chest)
      inserter = loader.surface.create_entity{
        name = util.interface_inserter_name_for_loader(loader),
        position = loader.position,
        force = loader.force,
      }
      inserter.destructible = false
      inserter.pickup_position = type == "loader" and interface_chest.position or main_chest_position
      inserter.drop_position = type == "unloader" and interface_chest.position or main_chest_position
      inserter.direction = inserter.direction
      inserter_config.connect_and_configure_inserter_control_behavior(inserter, loader)
    end
  end
end

local function remove_interface_inserter(loader, chest, buffer)
  local inserter = util.find_inserter_for_interface(loader, chest)
  if inserter then
    util.insert_or_spill(loader, inserter.held_stack, {loader.get_inventory(defines.inventory.chest), buffer})
    inserter.destroy()
  end
end

local function rail_positions(proxy)
  local direction = proxy.direction
  local position = proxy.position

  if direction == defines.direction.north or direction == defines.direction.south then
    if position.x % 2 ~= 1 then
      return nil
    end
    if position.y % 2 == 1 then
      return {
        util.moveposition(position, {x = 0, y = -2}),
        position,
        util.moveposition(position, {x = 0, y =  2}),
      }
    else
      return {
        util.moveposition(position, {x = 0, y = -1}),
        util.moveposition(position, {x = 0, y =  1}),
      }
    end
  else
    if position.y % 2 ~= 1 then
      return nil
    end
    if position.x % 2 == 1 then
      return {
        util.moveposition(position, {x = -2, y = 0}),
        position,
        util.moveposition(position, {x =  2, y = 0}),
      }
    else
      return {
        util.moveposition(position, {x = -1, y = 0}),
        util.moveposition(position, {x =  1, y = 0}),
      }
    end
  end
end

local function create_entities(proxy, rail_poss)
  local type = util.railloader_type(proxy.name)
  local surface = proxy.surface
  local direction = proxy.direction
  if direction > 4 then
    direction = direction - 4
  end
  local position = proxy.position
  local force = proxy.force
  local last_user = proxy.last_user

  -- place rails
  for _, rail_position in ipairs(rail_poss) do
    local rail = surface.create_entity{
      name = "railloader-rail",
      position = rail_position,
      direction = direction,
      force = force,
    }
    rail.destructible = false
    rail.minable = false
  end

  -- place chest
  local chest = surface.create_entity{
    name = "rail" .. type .. "-chest",
    position = position,
    force = force,
  }
  chest.last_user = last_user

  -- recreate circuit connections
  for _, ccd in ipairs(proxy.circuit_connection_definitions) do
    chest.connect_neighbour(ccd)
  end
  for _, ccd in ipairs(ghostconnections.get_connections(proxy)) do
    chest.connect_neighbour(ccd)
  end
  ghostconnections.remove_ghost(proxy)

  -- place cargo wagon inserters
  local inserter_name =
    "rail" .. type .. (allowed_items_setting == "any" and "-universal" or "") .. "-inserter"
  for i=1,num_inserters do
    local inserter = surface.create_entity{
      name = inserter_name,
      position = position,
      direction = direction,
      force = force,
    }
    inserter.destructible = false
    inserter_config.connect_and_configure_inserter_control_behavior(inserter, chest)
  end

  inserter_config.configure_or_register_loader(chest)

  -- place structure
  local structure_name = "rail" .. type .. "-structure-vertical"
  if direction == defines.direction.east or direction == defines.direction.west then
    structure_name = "rail" .. type .. "-structure-horizontal"
  end
  local placed = surface.create_entity{
    name = structure_name,
    position = position,
    force = force,
  }
  placed.destructible = false

  -- place interface inserters for pre-existing chests
  sync_interface_inserters(chest)
end

local function on_railloader_proxy_built(event)
  local proxy = event.created_entity
  local rail_pos = rail_positions(proxy)
  if not rail_pos then
    return abort_build(event)
  end
  create_entities(proxy, rail_pos)
  proxy.destroy()
end

local function on_ghost_built(ghost)
  local rail_pos = rail_positions(ghost)
  if not rail_pos then
    show_error(ghost)
    ghost.destroy()
  end
end

local function on_container_built(entity)
  for _, loader in ipairs(util.find_railloaders_from_chest(entity)) do
    sync_interface_inserters(loader)
  end
end

local function on_built(event)
  local entity = event.created_entity
  local type = util.railloader_type(entity.name)
  if type then
    return on_railloader_proxy_built(event)
  elseif entity.type == "entity-ghost" then
    type = util.railloader_type(entity.ghost_name)
    if type then
      return on_ghost_built(entity)
    end
  elseif string.find(entity.type, "container$") then
    return on_container_built(entity)
  end
end

local function on_railloader_mined(entity, buffer)
  local entities = entity.surface.find_entities_filtered{
    area = entity.bounding_box,
  }
  for _, ent in ipairs(entities) do
    if ent.type == "inserter" then
      if buffer and ent.held_stack.valid_for_read then
        buffer.insert(ent.held_stack)
      end
      ent.destroy()
    elseif string.find(ent.name, "^railu?n?loader%-structure") then
      ent.destroy()
    elseif ent.type == "straight-rail" then
      local success = ent.destroy()
      if not success then
        delaydestroy.register_to_destroy(ent)
      end
    end
  end
end

local function on_container_mined(entity, buffer)
  for _, loader in ipairs(util.find_railloaders_from_chest(entity)) do
    remove_interface_inserter(loader, entity, buffer)
  end
end

local function on_mined(event)
  local entity = event.entity
  local type = util.railloader_type(entity.name)
  if type then
    return on_railloader_mined(entity, event.buffer)
  elseif string.find(entity.type, "container$") then
    return on_container_mined(entity, event.buffer)
  end
end

local function on_robot_pre_mined(event)
  if event.instant_deconstruction then
    on_mined(event)
  end
end

local function on_blueprint(event)
  local player = game.players[event.player_index]
  local bp = player.blueprint_to_setup
  if not bp or not bp.valid_for_read then
    bp = player.cursor_stack
  end
  if not bp or not bp.valid_for_read then
    return
  end
  local entities = bp.get_blueprint_entities()
  if not entities then
    return
  end

  -- find (un)loaders and their directions
  local containers
  if util.is_empty_box(event.area) then
    containers = player.surface.find_entities_filtered{
      position = event.area.top_left,
      type = "container",
    }
  else
    containers = player.surface.find_entities_filtered{
      area = event.area,
      type = "container",
    }
  end

  local found_railloader = false
  local directions = {}
  for _, container in ipairs(containers) do
    if container.name == "railloader-chest" or container.name == "railunloader-chest" then
      found_railloader = true
      local rail = player.surface.find_entities_filtered{
        type = "straight-rail",
        area = container.bounding_box,
      }[1]
      if rail then
        directions[#directions+1] = rail.direction
      end
    end
  end

  -- don't call set_blueprint_entities() if there are no BRLs, because that discards cargo-wagon filters
  if not found_railloader then return end

  local loader_index = 1
  for _, e in ipairs(entities) do
    if e.name == "railloader-chest" then
      e.name = "railloader-placement-proxy"
      e.direction = directions[loader_index]
      loader_index = loader_index + 1
    elseif e.name == "railunloader-chest" then
      e.name = "railunloader-placement-proxy"
      e.direction = directions[loader_index]
      loader_index = loader_index + 1
    end
  end

  bp.set_blueprint_entities(entities)
end

local function on_setting_changed(event)
  allowed_items_setting = settings.global["railloader-allowed-items"].value
  inserter_config.on_setting_changed(event)
end

-- setup event handlers

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, on_built)
script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, on_mined)
script.on_event(defines.events.on_robot_pre_mined, on_robot_pre_mined)
script.on_event(defines.events.on_entity_died, on_mined)
script.on_event(defines.events.on_player_setup_blueprint, on_blueprint)
script.on_event(defines.events.on_train_changed_state, inserter_config.on_train_changed_state)

script.on_event(defines.events.on_runtime_mod_setting_changed, on_setting_changed)
