local entity_data = require("__PipeVisualizer__/scripts/entity-data")
local iterator = require("__PipeVisualizer__/scripts/iterator")

--- @param e EventData.CustomInputEvent|EventData.on_lua_shortcut
local function on_toggle_mouseover(e)
  if e.prototype_name and e.prototype_name ~= "pv-toggle-mouseover" then
    return
  end

  global.mouseover_enabled[e.player_index] = not global.mouseover_enabled[e.player_index]

  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  player.set_shortcut_toggled("pv-toggle-mouseover", global.mouseover_enabled[e.player_index])
  if e.input_name then
    local text
    if global.mouseover_enabled[e.player_index] then
      text = { "message.pv-mouseover-enabled" }
    else
      text = { "message.pv-mouseover-disabled" }
    end
    player.create_local_flying_text({
      text = text,
      create_at_cursor = true,
    })
  end

  local it = iterator.get(e.player_index)
  if it and it.in_overlay then
    return
  elseif it then
    iterator.clear_hovered(e.player_index)
  end
end

--- @param e EventData.on_selected_entity_changed
local function on_selected_entity_changed(e)
  if not global.mouseover_enabled[e.player_index] then
    return
  end

  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  local it = iterator.get(e.player_index)
  if it and it.in_overlay then
    return
  end

  local selected = player.selected
  if selected and it and entity_data.get(it, selected) then
    return
  end

  if it then
    iterator.clear_hovered(e.player_index)
  end
  if selected then
    iterator.request(selected, e.player_index, false, true)
  end
end

local mouseover = {}

function mouseover.on_init()
  --- @type table<PlayerIndex, boolean>
  global.mouseover_enabled = {}
end

mouseover.events = {
  [defines.events.on_lua_shortcut] = on_toggle_mouseover,
  [defines.events.on_selected_entity_changed] = on_selected_entity_changed,
  ["pv-toggle-mouseover"] = on_toggle_mouseover,
}

return mouseover
