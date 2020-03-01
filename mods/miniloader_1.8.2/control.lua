local blueprint = require("lualib.blueprint")
local circuit = require("circuit")
local configchange = require("configchange")
local event = require("lualib.event")
local _ = require("gui")
local snapping = require("snapping")
local util = require("lualib.util")

local compat_pickerextended = require("compat.pickerextended")
local compat_upgradeplanner = require("compat.upgradeplanner")

local use_snapping = settings.global["miniloader-snapping"].value

--[[
  loader_type = "input"
  +------------------+
  |                  |
  |        P         |
  |                  |
  |                  |    |
  |                  |    | chest dir
  |                  |    |
  |                  |    v
  |                  |
  +------------------+
     D            D
--
  loader_type = "output"
  +------------------+
  |                  |
  |  D            D  |
  |                  |
  |                  |    |
  |                  |    | chest dir
  |                  |    |
  |                  |    v
  |                  |
  +------------------+
           P
--
  D: drop positions
  P: pickup position
]]

local function register_bobs_blacklist()
  for _, interface_name in ipairs{"bobinserters", "boblogistics"} do
    local interface = remote.interfaces[interface_name]
    if interface and interface["blacklist_inserter"] then
      for entity_name in pairs(game.entity_prototypes) do
        if util.is_miniloader_inserter_name(entity_name) then
          remote.call(interface_name, "blacklist_inserter", entity_name)
        end
      end
    end
  end
end

-- Event Handlers

local function on_init()
  circuit.on_init()
  compat_pickerextended.on_load()
end

local function on_load()
  circuit.on_load()
  compat_pickerextended.on_load()
end

local function on_configuration_changed(configuration_changed_data)
  local mod_change = configuration_changed_data.mod_changes["miniloader"]
  if mod_change and mod_change.old_version and mod_change.old_version ~= mod_change.new_version then
    configchange.on_mod_version_changed(mod_change.old_version)
  end
  register_bobs_blacklist()
  configchange.fix_inserter_counts()
end

local function on_built_miniloader(entity, orientation)
  if not orientation then
    orientation = {direction = util.opposite_direction(entity.direction), type = "input"}
  end

  local surface = entity.surface

  local loader_name = string.gsub(entity.name, "inserter", "loader")
  local loader = surface.create_entity{
    name = loader_name,
    position = entity.position,
    direction = orientation.direction,
    force = entity.force,
    type = orientation.type,
  }

  entity.inserter_stack_size_override = 1
  for _ = 2, util.num_inserters(loader) do
    local inserter = surface.create_entity{
      name = entity.name,
      position = entity.position,
      direction = entity.direction,
      force = entity.force,
    }
    inserter.inserter_stack_size_override = 1
  end

  util.update_inserters(loader)
  circuit.sync_behavior(entity)
  circuit.sync_filters(entity)

  return loader
end

local function on_robot_built(ev)
  local entity = ev.created_entity
  if util.is_miniloader_inserter(entity) then
    on_built_miniloader(entity, util.orientation_from_inserters(entity))
  end
end

local function on_script_built(ev)
  local entity = ev.entity
  if entity and util.is_miniloader_inserter(entity) then
    on_built_miniloader(entity, util.orientation_from_inserters(entity))
  end
end

local function on_script_revive(ev)
  local entity = ev.entity
  if entity and util.is_miniloader_inserter(entity) then
    on_built_miniloader(entity, util.orientation_from_inserters(entity))
  end
end

local miniloader_mined

local function on_player_built(ev)
  local entity = ev.created_entity
  if ev.mod_name then
    -- might be circuit connected or have filter settings
    on_robot_built(ev)
    if ev.mod_name == "upgrade-planner" then
      compat_upgradeplanner.on_built_entity(ev)
    end
    return
  end


  if util.is_miniloader_inserter(entity) then
    local orientation
    if miniloader_mined and
       miniloader_mined.tick == ev.tick and
       miniloader_mined.player_index == ev.player_index then
      orientation = miniloader_mined.orientation
    end

    local loader = on_built_miniloader(entity, orientation)
    if use_snapping and not orientation then
      -- adjusts direction & belt_to_ground_type
      snapping.snap_loader(loader, ev)
    end
  else
    snapping.check_for_loaders(ev)
  end
end

local function on_rotated(ev)
  local entity = ev.entity
  if util.is_miniloader_inserter(entity) then
    local miniloader = util.find_miniloaders{
      surface = entity.surface,
      position = entity.position,
      force = entity.force,
    }[1]
    miniloader.rotate{ by_player = game.players[ev.player_index] }
    util.update_inserters(miniloader)
  elseif util.is_miniloader(entity) then
    util.update_inserters(entity)
  elseif use_snapping then
    snapping.check_for_loaders(ev)
  end
end

local function on_pre_player_mined_item(ev)
  if ev.mod_name == "upgrade-planner" then
    return compat_upgradeplanner.on_pre_player_mined_item(ev)
  end
end

local function on_miniloader_mined(ev)
  local entity = ev.entity
  local inserters = util.get_loader_inserters(entity)
  if ev.buffer and inserters[1] then
    local _, item_to_place = next(inserters[1].prototype.items_to_place_this)
    ev.buffer.insert{count=1, name=item_to_place.name}
  end
  for i=1,#inserters do
    -- return items to player / robot if mined
    if ev.buffer and inserters[i] ~= entity and inserters[i].held_stack.valid_for_read then
      ev.buffer.insert(inserters[i].held_stack)
    end
    inserters[i].destroy()
  end
end

local function on_miniloader_inserter_mined(ev)
  local entity = ev.entity
  local loader = entity.surface.find_entities_filtered{
    position = entity.position,
    type = "loader",
  }[1]
  if loader then
    if ev.buffer then
      for i=1,2 do
        local tl = loader.get_transport_line(i)
        for j=1,#tl do
          ev.buffer.insert(tl[j])
        end
        tl.clear()
      end
    end
    loader.destroy()
  end

  local inserters = util.get_loader_inserters(entity)
  for i=1,#inserters do
    if inserters[i] ~= entity then
      -- return items in inserter hand to player / robot if mined
      if ev.buffer and inserters[i].held_stack.valid_for_read then
        ev.buffer.insert(inserters[i].held_stack)
      end
      inserters[i].destroy()
    end
  end
end

local function on_mined(ev)
  local entity = ev.entity
  if util.is_miniloader(entity) then
    on_miniloader_mined(ev)
  elseif util.is_miniloader_inserter(entity) then
    on_miniloader_inserter_mined(ev)
  end
end

local function on_placed_blueprint(ev, player, bp)
  local surface = player.surface
  local bp_area = blueprint.bounding_box(bp)
  local surface_area = util.move_box(
    util.rotate_box(bp_area, ev.direction),
    ev.position
  )
  event.on_next_tick(function()
    if not surface.valid then return end
    local inserter_entities = surface.find_entities_filtered{
      area = surface_area,
      type = "inserter",
    }
    for _, e in pairs(inserter_entities) do
      if util.is_miniloader_inserter(e) then
        circuit.sync_behavior(e)
        circuit.sync_filters(e)
      end
    end
  end)
end

local function on_put_item(ev)
  local player_index = ev.player_index
  local player = game.players[player_index]
  local cursor_stack = player.cursor_stack
  if cursor_stack and blueprint.is_setup_bp(cursor_stack) then
    return on_placed_blueprint(ev, player, cursor_stack)
  end
  local entities = player.surface.find_entities_filtered{position = ev.position}
  for _, entity in ipairs(entities) do
    if entity.name == "entity-ghost" and util.is_miniloader_inserter_name(entity.ghost_name) then
      -- building over a ghost
      miniloader_mined = {
        tick = ev.tick,
        player_index = player_index,
        orientation = util.orientation_from_inserters(entity),
      }
      return
    end
  end
end

local function on_player_mined_entity(ev)
  local entity = ev.entity
  if util.is_miniloader_inserter(entity) then
    -- might be a fast replace, so store current orientation
    miniloader_mined = {
      tick = ev.tick,
      player_index = ev.player_index,
      orientation = util.orientation_from_inserters(entity),
    }
  end
  on_mined(ev)
end

local function on_robot_pre_mined(ev)
  if ev.instant_deconstruction then
    on_mined(ev)
  end
end

local function on_entity_settings_pasted(ev)
  local src = ev.source
  local dst = ev.destination
  if util.is_miniloader_inserter(src) and util.is_miniloader_inserter(dst)
  or util.is_miniloader(src) and util.is_miniloader(dst) then
    circuit.sync_behavior(dst)
    circuit.sync_filters(dst)
    local src_loader = src.surface.find_entities_filtered{type="loader",position=src.position}[1]
    local dst_loader = dst.surface.find_entities_filtered{type="loader",position=dst.position}[1]
    if src_loader and dst_loader then
      dst_loader.loader_type = src_loader.loader_type
      util.update_inserters(dst_loader)
    end
  end
end

local function on_setup_blueprint(ev)
  local player = game.players[ev.player_index]
  local bp = player.blueprint_to_setup
  if not bp or not bp.valid_for_read then
    bp = player.cursor_stack
  end
  blueprint.filter_miniloaders(bp)
end

local function on_marked_for_deconstruction(ev)
  local entity = ev.entity
  if not (util.is_miniloader(entity) or util.is_miniloader_inserter(entity)) then return end
  for _, ent in ipairs(entity.surface.find_entities_filtered{position=entity.position}) do
    -- order_deconstruction() causes event handlers to be fired which may invalidate entities
    if ent.valid and (util.is_miniloader(ent) or util.is_miniloader_inserter(ent)) then
      if not ent.to_be_deconstructed(ent.force) then
        ent.order_deconstruction(ent.force)
      end
    end
  end
end

local function on_canceled_deconstruction(ev)
  local entity = ev.entity
  for _, ent in ipairs(entity.surface.find_entities_filtered{position=entity.position}) do
    if util.is_miniloader(ent) or util.is_miniloader_inserter(ent) then
      if ent.to_be_deconstructed(ent.force) then
        ent.cancel_deconstruction(ent.force)
      end
    end
  end
end

-- lifecycle events

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)

-- entity events

event.register(defines.events.on_built_entity, on_player_built)
event.register(defines.events.on_robot_built_entity, on_robot_built)
event.register(defines.events.on_player_rotated_entity, on_rotated)

event.register(defines.events.on_pre_player_mined_item, on_pre_player_mined_item)
event.register(defines.events.on_player_mined_entity, on_player_mined_entity)
event.register(defines.events.on_robot_pre_mined, on_robot_pre_mined)
event.register(defines.events.on_robot_mined_entity, on_mined)
event.register(defines.events.on_entity_died, on_mined)
event.register(defines.events.script_raised_built, on_script_built)
event.register(defines.events.script_raised_revive, on_script_revive)
event.register(defines.events.script_raised_destroy, on_mined)

event.register(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)
event.register(defines.events.on_put_item, on_put_item)

event.register(defines.events.on_player_setup_blueprint, on_setup_blueprint)
event.register(defines.events.on_marked_for_deconstruction, on_marked_for_deconstruction)
event.register(defines.events.on_canceled_deconstruction, on_canceled_deconstruction)

event.register(defines.events.on_runtime_mod_setting_changed, function(ev)
  if ev.setting == "miniloader-snapping" then
    use_snapping = settings.global["miniloader-snapping"].value
  end
end)
