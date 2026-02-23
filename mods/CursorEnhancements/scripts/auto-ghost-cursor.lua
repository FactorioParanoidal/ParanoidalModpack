local util = require("scripts.util")

local vehicles = {
  ["car"] = true,
  ["locomotive"] = true,
  ["spidertron"] = true,
}

--- @class BuiltItemData
--- @field item ItemWithQualityID
--- @field tick uint

--- @param e EventData.on_built_entity
local function on_built_entity(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  if not player.mod_settings["cen-auto-ghost-cursor"].value then
    return
  end

  local built_item = storage.built_item[e.player_index]
  if not built_item then
    return
  end
  storage.built_item[e.player_index] = nil
  if built_item.tick ~= game.tick then
    return
  end
  if script.active_mods["folk-justgo"] and vehicles[e.entity.type] then
    return
  end

  -- Don't do anything if the cursor stack is not empty
  local cursor_stack = player.cursor_stack
  if not cursor_stack or cursor_stack.valid_for_read then
    return
  end

  util.set_cursor(player, built_item.item)
end

--- @param e EventData.on_pre_build
local function on_pre_build(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  if not player.mod_settings["cen-auto-ghost-cursor"].value then
    return
  end

  local cursor_stack = player.cursor_stack
  if not cursor_stack or not cursor_stack.valid_for_read then
    return
  end

  storage.built_item[e.player_index] =
    { item = { name = cursor_stack.prototype, quality = cursor_stack.quality }, tick = game.tick }
end

--- @param e EventData.on_player_main_inventory_changed
local function on_player_main_inventory_changed(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  if not player.mod_settings["cen-auto-ghost-cursor"].value then
    return
  end

  local cursor_ghost = player.cursor_ghost
  if not cursor_ghost then
    return
  end

  local main_inventory = player.get_main_inventory()
  if not main_inventory then
    return
  end

  local count = main_inventory.get_item_count(cursor_ghost)
  if count == 0 then
    return
  end
  util.set_cursor(player, cursor_ghost)
end

local auto_ghost_cursor = {}

auto_ghost_cursor.on_init = function()
  --- @type table<uint, BuiltItemData?>
  storage.built_item = {}
end

auto_ghost_cursor.on_configuration_changed = function()
  storage.built_item = {}
end

auto_ghost_cursor.events = {
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_player_main_inventory_changed] = on_player_main_inventory_changed,
  [defines.events.on_pre_build] = on_pre_build,
}

return auto_ghost_cursor
