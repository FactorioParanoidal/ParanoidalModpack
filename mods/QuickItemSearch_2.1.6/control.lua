local dictionary = require("__flib__/dictionary-lite")
local gui = require("__flib__/gui")
local migration = require("__flib__/migration")

local global_data = require("__QuickItemSearch__/scripts/global-data")
local infinity_filter = require("__QuickItemSearch__/scripts/infinity-filter")
local migrations = require("__QuickItemSearch__/scripts/migrations")
local player_data = require("__QuickItemSearch__/scripts/player-data")
local logistic_request = require("__QuickItemSearch__/scripts/logistic-request")
local search = require("__QuickItemSearch__/scripts/search")

local infinity_filter_gui = require("__QuickItemSearch__/scripts/gui/infinity-filter")
local logistic_request_gui = require("__QuickItemSearch__/scripts/gui/logistic-request")
local search_gui = require("__QuickItemSearch__/scripts/gui/search")

-- Bootstrap

script.on_init(function()
  dictionary.on_init()

  global_data.init()
  global_data.build_dictionary()

  for i in pairs(game.players) do
    player_data.init(i)
    player_data.refresh(game.get_player(i), global.players[i])
  end
end)

migration.handle_on_configuration_changed(migrations, function()
  dictionary.on_configuration_changed()

  global_data.build_dictionary()

  for i, player_table in pairs(global.players) do
    player_data.refresh(game.get_player(i), player_table)
  end
end)

-- Custom input

script.on_event({ "qis-confirm", "qis-shift-confirm", "qis-control-confirm" }, function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local player_table = global.players[e.player_index]

  -- HACK: This makes it easy to check if we should close the search GUI or not
  player_table.confirmed_tick = game.ticks_played

  local is_shift = e.input_name == "qis-shift-confirm"
  local is_control = e.input_name == "qis-control-confirm"

  local opened = player.opened
  if opened and player.opened_gui_type == defines.gui_type.custom then
    if opened.name == "qis_search_window" then
      search_gui.select_item(player, player_table, { shift = is_shift, control = is_control })
    elseif opened.name == "qis_request_window" then
      if is_control then
        logistic_request_gui.clear_request(player, player_table)
      else
        logistic_request_gui.set_request(player, player_table, is_shift)
      end
    elseif opened.name == "qis_infinity_filter_window" then
      if is_control then
        infinity_filter_gui.clear_filter(player, player_table)
      else
        infinity_filter_gui.set_filter(player, player_table, is_shift)
      end
    end
  end
end)

script.on_event("qis-cycle-infinity-filter-mode", function(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.guis.infinity_filter
  if gui_data then
    local state = gui_data.state
    if state.visible then
      infinity_filter_gui.cycle_filter_mode(gui_data)
    end
  end
end)

script.on_event("qis-search", function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local player_table = global.players[e.player_index]
  if player_table.flags.can_open_gui then
    search_gui.toggle(player, player_table, false)
  else
    player_table.flags.show_message_after_translation = true
    player.print({ "message.qis-cannot-open-gui" })
  end
end)

script.on_event({ "qis-nav-up", "qis-nav-down" }, function(e)
  local player_table = global.players[e.player_index]
  if player_table.flags.can_open_gui then
    local gui_data = player_table.guis.search
    if gui_data.state.visible then
      local offset = string.find(e.input_name, "down") and 1 or -1
      search_gui.handle_action({ player_index = e.player_index }, { action = "update_selected_index", offset = offset })
    end
  end
end)

script.on_event("qis-quick-trash-all", function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local player_table = global.players[e.player_index]
  if player.controller_type == defines.controllers.character and player.force.character_logistic_requests then
    logistic_request.quick_trash_all(player, player_table)
  elseif player.controller_type == defines.controllers.editor then
    infinity_filter.quick_trash_all(player, player_table)
  end
end)

-- Dictionaries

dictionary.handle_events()

script.on_event(dictionary.on_player_dictionaries_ready, function(e)
    local player = game.get_player(e.player_index)
    if not player then
      return
    end
    if not player then
      return
    end
    local player_table = global.players[e.player_index]
    -- show message if needed
    if player_table.flags.show_message_after_translation then
      player.print({ "message.qis-can-open-gui" })
    end
    -- update flags
    player_table.flags.can_open_gui = true
    player_table.flags.show_message_after_translation = false
    -- create GUIs
    infinity_filter_gui.build(player, player_table)
    logistic_request_gui.build(player, player_table)
    search_gui.build(player, player_table)
    -- enable shortcut
    player.set_shortcut_available("qis-search", true)
end)

-- Entity

script.on_event(defines.events.on_entity_logistic_slot_changed, function(e)
  local entity = e.entity
  if entity and entity.valid and entity.type == "character" then
    local player = entity.player -- event does not provide player_index every time
    -- sometimes the player won't exist because it's in a cutscene
    if player then
      local player_table = global.players[player.index]
      if player_table then
        logistic_request.update(player, player_table, e.slot_index)
      end
    end
  end
end)

-- GUI

gui.hook_events(function(e)
  local msg = gui.read_action(e)
  if msg then
    if msg.gui == "infinity_filter" then
      infinity_filter_gui.handle_action(e, msg)
    elseif msg.gui == "request" then
      logistic_request_gui.handle_action(e, msg)
    elseif msg.gui == "search" then
      search_gui.handle_action(e, msg)
    end

    if msg.reopen_after_subwindow then
      search_gui.reopen_after_subwindow(e)
    end
  end
end)

-- Player

script.on_event(defines.events.on_player_created, function(e)
  player_data.init(e.player_index)
  player_data.refresh(game.get_player(e.player_index), global.players[e.player_index])
end)

script.on_event(defines.events.on_player_removed, function(e)
  global.players[e.player_index] = nil
end)

script.on_event({
  defines.events.on_player_display_resolution_changed,
  defines.events.on_player_display_scale_changed,
}, function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local player_table = global.players[e.player_index]
  logistic_request_gui.update_focus_frame_size(player, player_table)
end)

script.on_event({
  defines.events.on_player_ammo_inventory_changed,
  defines.events.on_player_armor_inventory_changed,
  defines.events.on_player_gun_inventory_changed,
  defines.events.on_player_main_inventory_changed,
}, function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local player_table = global.players[e.player_index]

  local main_inventory = player.get_main_inventory()
  if main_inventory and main_inventory.valid then
    -- avoid getting the contents until they're actually needed
    local combined_contents
    local function get_combined_contents()
      if not combined_contents then
        combined_contents = search.get_combined_inventory_contents(player, main_inventory)
      end
      return combined_contents
    end

    if player.controller_type == defines.controllers.editor then
      if next(player_table.infinity_filters.temporary) then
        infinity_filter.update_temporaries(player, player_table)
      end
      infinity_filter.update(player, player_table)
    elseif player.controller_type == defines.controllers.character then
      if next(player_table.logistic_requests.temporary) then
        logistic_request.update_temporaries(player, player_table, get_combined_contents())
      end
    end

    local gui_data = player_table.guis.search
    if gui_data then
      local state = gui_data.state
      if state.visible and not state.subwindow_open then
        search_gui.perform_search(player, player_table, false, get_combined_contents())
      end
    end
  end
end)

-- Settings

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if string.sub(e.setting, 1, 4) == "qis-" and e.setting_type == "runtime-per-user" then
    local player = game.get_player(e.player_index)
    if not player then
      return
    end
    local player_table = global.players[e.player_index]
    player_data.update_settings(player, player_table)
  end
end)

-- Shortcut

script.on_event(defines.events.on_lua_shortcut, function(e)
  if e.prototype_name == "qis-search" then
    local player = game.get_player(e.player_index)
    if not player then
      return
    end
    local player_table = global.players[e.player_index]
    if player_table.flags.can_open_gui then
      search_gui.toggle(player, player_table, true)
    end
  end
end)

-- Tick

script.on_event(defines.events.on_tick, function()
  dictionary.on_tick()

  if next(global.update_search_results) then
    search_gui.update_for_active_players()
  end
end)
