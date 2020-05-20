local bulk = require "bulk"
local EntityQueue = require "EntityQueue"
local util = require "util"

local M = {}

local INTERVAL = 60

local allowed_items_setting = settings.global["railloader-allowed-items"].value
local show_configuration_messages_setting = settings.global["railloader-show-configuration-messages"].value

local function display_configuration_message(loader, items)
  if not next(items) then
    return
  end
  local type = "railloader"
  if loader.name == "railunloader-chest" then
    type = "railunloader"
  end
  local msg = {"railloader." .. type .. "-configured-" .. #items}
  for i, item in ipairs(items) do
    msg[i+1] = {"item-name." .. item}
  end
  loader.surface.create_entity{
    name = "flying-text",
    position = loader.position,
    text = msg,
  }
end

local function inserter_configuration_changes(inserter, items)
  local item_set = {}
  for _, v in ipairs(items) do
    item_set[v] = true
  end

  for i=1,5 do
    local filter = inserter.get_filter(i)
    if filter then
      if not item_set[filter] then
        -- existing filter will be removed
        return true
      end
      item_set[filter] = nil
    end
  end

  -- check if new filter(s) will be added
  return next(item_set) ~= nil
end

local function configure_loader_from_inventory(loader, inventory)
  local items = bulk.acceptable_items(inventory, 5)
  if not next(items) then
    return false
  end

  local inserters = util.railloader_filter_inserters(loader)
  if not next(inserters) then
    return true
  end

  if show_configuration_messages_setting and inserter_configuration_changes(inserters[1], items) then
    display_configuration_message(loader, items)
  end

  for _, inserter in ipairs(inserters) do
    for i=1,5 do
      inserter.set_filter(i, items[i])
    end
  end

  return true
end

local function configure_loader(loader)
  local inventory = loader.get_inventory(defines.inventory.chest)
  if loader.name == "railunloader-chest" then
    local wagon = loader.surface.find_entities_filtered{
      type = "cargo-wagon",
      area = util.box_centered_at(loader.position, 0.6),
      force = loader.force,
    }[1]
    if wagon then
      inventory = wagon.get_inventory(defines.inventory.cargo_wagon)
    end
  end
  if inventory then
    return configure_loader_from_inventory(loader, inventory)
  end
  return false
end

local queue = EntityQueue.new("unconfigured_loaders", INTERVAL, configure_loader)

function M.on_train_changed_state(event)
  if allowed_items_setting == "any" then
    return
  end

  local train = event.train
  if train.state ~= defines.train_state.wait_station and
    event.old_state ~= defines.train_state.wait_station then
    return
  end
  for _, wagon in ipairs(train.cargo_wagons) do
    local loader = wagon.surface.find_entities_filtered{
      type = "container",
      area = util.box_centered_at(wagon.position, 0.6),
    }[1]
    if loader then
      if train.state == defines.train_state.wait_station then
        M.configure_or_register_loader(loader)
      else
        queue:unregister(loader)
      end
    end
  end
end

function M.on_init()
  queue:on_init()
end

function M.on_load()
  queue:on_load()
end

function M.configure_or_register_loader(loader)
  if allowed_items_setting == "any" then
    return
  end
  local success = configure_loader(loader)
  if not success then
    queue:register(loader)
  end
end

local function configure_inserter_control_behavior(inserter)
  local behavior = inserter.get_or_create_control_behavior()
  behavior.circuit_condition = {
    condition = {
      comparator = "=",
      first_signal = {type = "virtual", name = "railloader-disable"},
    }
  }
end

function M.connect_and_configure_inserter_control_behavior(inserter, chest)
  for _, wire_type in ipairs{"red", "green"} do
    inserter.connect_neighbour{
      target_entity = chest,
      wire = defines.wire_type[wire_type],
    }
  end
  configure_inserter_control_behavior(inserter)
end

local function replace_all_inserters(universal)
  local from_qualifier = universal and "" or "-universal"
  local to_qualifier = universal and "-universal" or ""

  for _, s in pairs(game.surfaces) do
    for _, type in ipairs{"railloader", "railunloader"} do
      local to_match = type .. from_qualifier .. "-inserter"
      local replace_with = type .. to_qualifier .. "-inserter"
      for _, e in ipairs(s.find_entities_filtered{name=to_match}) do
        local replacement = s.create_entity{
          name = replace_with,
          position = e.position,
          direction = e.direction,
          force = e.force,
        }
        replacement.destructible = false
        replacement.held_stack.swap_stack(e.held_stack)
        for _, ccd in ipairs(e.circuit_connection_definitions) do
          replacement.connect_neighbour(ccd)
        end
        configure_inserter_control_behavior(replacement)

        if not universal then
          local loader = replacement.surface.find_entity(type .. "-chest", e.position)
          if not loader then error("no loader found") end
          queue:register(loader)
        end
        e.destroy()
      end
    end
  end
end

function M.on_setting_changed(event)
  if event.setting == "railloader-allowed-items" then
    local new_value = settings.global["railloader-allowed-items"].value
    if new_value == "any" and allowed_items_setting ~= "any" then
      allowed_items_setting = new_value
      replace_all_inserters(true)
    elseif new_value ~= "any" and allowed_items_setting == "any" then
      allowed_items_setting = new_value
      replace_all_inserters(false)
    end
    bulk.on_setting_changed()
  elseif event.setting == "railloader-show-configuration-messages" then
    show_configuration_messages_setting = settings.global["railloader-show-configuration-messages"].value
  end
end

return M