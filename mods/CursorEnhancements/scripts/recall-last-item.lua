local util = require("scripts.util")

--- @param e EventData.CustomInputEvent
local function on_recall_last_item(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  local last_item = storage.last_item[e.player_index]
  if not last_item then
    return
  end

  util.set_cursor(player, last_item)
end

--- @param e EventData.on_player_cursor_stack_changed
local function on_player_cursor_stack_changed(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  local item = util.get_cursor_item(player)
  if not item then
    return
  end

  storage.last_item[e.player_index] = item
end

local recall_last_item = {}

recall_last_item.on_init = function()
  --- @type table<uint, ItemWithQualityID?>
  storage.last_item = {}
end

recall_last_item.events = {
  ["cen-recall-last-item"] = on_recall_last_item,
  [defines.events.on_player_cursor_stack_changed] = on_player_cursor_stack_changed,
}

return recall_last_item
