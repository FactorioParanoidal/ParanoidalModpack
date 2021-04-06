local event = require("__flib__.event")
local gui = require("__flib__.gui-beta")
local migration = require("__flib__.migration")
local translation = require("__flib__.translation")

local global_data = require("scripts.global-data")
local infinity_filter = require("scripts.infinity-filter")
local migrations = require("scripts.migrations")
local player_data = require("scripts.player-data")
local logistic_request = require("scripts.logistic-request")
local search = require("scripts.search")
local shared = require("scripts.shared")

local infinity_filter_gui = require("scripts.gui.infinity-filter")
local logistic_request_gui = require("scripts.gui.logistic-request")
local search_gui = require("scripts.gui.search")

-- -----------------------------------------------------------------------------
-- COMMANDS

commands.add_command("QuickItemSearch", {"command-help.QuickItemSearch"}, function(e)
  if e.parameter == "refresh-player-data" then
    local player = game.get_player(e.player_index)
    player.print{"message.qis-refreshing-player-data"}
    player_data.refresh(player, global.players[e.player_index])
  else
    game.get_player(e.player_index).print{"message.qis-invalid-parameter"}
  end
end)

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- BOOTSTRAP

event.on_init(function()
  translation.init()

  global_data.init()
  global_data.build_strings()

  for i in pairs(game.players) do
    player_data.init(i)
    player_data.refresh(game.get_player(i), global.players[i])
  end
end)

event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations) then
    -- reset running translations
    translation.init()

    global_data.build_strings()

    for i, player_table in pairs(global.players) do
      player_data.refresh(game.get_player(i), player_table)
    end
  end
end)

-- CUSTOM INPUT

event.register({"qis-confirm", "qis-shift-confirm", "qis-control-confirm"}, function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]

  local is_shift = e.input_name == "qis-shift-confirm"
  local is_control = e.input_name == "qis-control-confirm"

  local opened = player.opened
  if opened and player.opened_gui_type == defines.gui_type.custom then
    if opened.name == "qis_search_window" then
      search_gui.select_item(player, player_table, {shift = is_shift, control = is_control})
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

event.register("qis-cycle-infinity-filter-mode", function(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.guis.infinity_filter
  if gui_data then
    local state = gui_data.state
    if state.visible then
      infinity_filter_gui.cycle_filter_mode(gui_data)
    end
  end
end)

event.register("qis-search", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  if player_table.flags.can_open_gui then
    search_gui.toggle(player, player_table)
  else
    player_table.flags.show_message_after_translation = true
    player.print{"message.qis-cannot-open-gui"}
  end
end)

event.register({"qis-nav-up", "qis-nav-down"}, function(e)
  local player_table = global.players[e.player_index]
  if player_table.flags.can_open_gui then
    local gui_data = player_table.guis.search
    if gui_data.state.visible then
      local offset = string.find(e.input_name, "down") and 1 or -1
      search_gui.handle_action({player_index = e.player_index}, {action = "update_selected_index", offset = offset})
    end
  end
end)

event.register("qis-quick-trash-all", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  if player.controller_type == defines.controllers.character and player.force.character_logistic_requests then
    logistic_request.quick_trash_all(player, player_table)
  elseif player.controller_type == defines.controllers.editor then
    infinity_filter.quick_trash_all(player, player_table)
  end
end)

-- ENTITY

event.on_entity_logistic_slot_changed(function(e)
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

-- PLAYER

event.on_player_created(function(e)
  player_data.init(e.player_index)
  player_data.refresh(game.get_player(e.player_index), global.players[e.player_index])
end)

event.on_player_joined_game(function(e)
  local player_table = global.players[e.player_index]
  if player_table.flags.translate_on_join then
    player_table.flags.translate_on_join = false
    player_data.start_translations(e.player_index)
  end
end)

event.on_player_left_game(function(e)
  local player_table = global.players[e.player_index]
  if translation.is_translating(e.player_index) then
    translation.cancel(e.player_index)
    player_table.flags.translate_on_join = true
  end
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)

event.register(
  {
    defines.events.on_player_display_resolution_changed,
    defines.events.on_player_display_scale_changed
  },
  function(e)
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    logistic_request_gui.update_focus_frame_size(player, player_table)
  end
)

event.register(
  {
    defines.events.on_player_ammo_inventory_changed,
    defines.events.on_player_armor_inventory_changed,
    defines.events.on_player_gun_inventory_changed,
    defines.events.on_player_main_inventory_changed
  },
  function(e)
    local player = game.get_player(e.player_index)
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
  end
)

-- SETTINGS

event.on_runtime_mod_setting_changed(function(e)
  if string.sub(e.setting, 1, 4) == "qis-" and e.setting_type == "runtime-per-user" then
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    player_data.update_settings(player, player_table)
  end
end)

-- SHORTCUT

event.on_lua_shortcut(function(e)
  if e.prototype_name == "qis-search" then
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    if player_table.flags.can_open_gui then
      search_gui.toggle(player, player_table)
    end
  end
end)

-- TICK

local function on_tick(e)
  local deregister = true

  if translation.translating_players_count() > 0 then
    deregister = false
    translation.iterate_batch(e)
  end

  if next(global.update_search_results) then
    deregister = false
    search_gui.update_for_active_players()
  end

  if deregister then
    event.on_tick(nil)
  end
end

shared.register_on_tick = function()
  if
    translation.translating_players_count() > 0
    or next(global.update_search_results)
  then
    event.on_tick(on_tick)
  end
end

-- TRANSLATIONS

event.on_string_translated(function(e)
  local names, finished = translation.process_result(e)
  if names then
    local player_table = global.players[e.player_index]
    local translations = player_table.translations
    local internal_names = names.items
    for i = 1, #internal_names do
      local internal_name = internal_names[i]
      translations[internal_name] = e.translated and e.result or internal_name
    end
  end
  if finished then
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    -- show message if needed
    if player_table.flags.show_message_after_translation then
      player.print{"message.qis-can-open-gui"}
    end
    -- update flags
    player_table.flags.can_open_gui = true
    player_table.flags.translate_on_join = false
    player_table.flags.show_message_after_translation = false
    -- create GUIs
    infinity_filter_gui.build(player, player_table)
    logistic_request_gui.build(player, player_table)
    search_gui.build(player, player_table)
    -- enable shortcut
    player.set_shortcut_available("qis-search", true)
  end
end)
