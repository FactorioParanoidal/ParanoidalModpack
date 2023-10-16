local dictionary = require("__flib__.dictionary-lite")
local gui = require("__flib__.gui")
local migration = require("__flib__.migration")
local on_tick_n = require("__flib__.on-tick-n")
local table = require("__flib__.table")

local constants = require("constants")
local database = require("scripts.database")
local formatter = require("scripts.formatter")
local global_data = require("scripts.global-data")
local migrations = require("scripts.migrations")
local player_data = require("scripts.player-data")
local remote_interface = require("scripts.remote-interface")
local util = require("scripts.util")

-- -----------------------------------------------------------------------------
-- GLOBALS

INFO_GUI = require("scripts.gui.info.index")
QUICK_REF_GUI = require("scripts.gui.quick-ref.index")
SEARCH_GUI = require("scripts.gui.search.index")
SETTINGS_GUI = require("scripts.gui.settings.index")

--- Open the given page.
--- @param player LuaPlayer
--- @param player_table PlayerTable
--- @param context Context
--- @param options table?
function OPEN_PAGE(player, player_table, context, options)
  options = options or {}

  --- @type InfoGui?
  local Gui
  if options.id then
    Gui = util.get_gui(player.index, "info", options.id)
  else
    _, Gui = next(INFO_GUI.find_open_context(player_table, context))
  end

  if Gui and Gui.refs.root.visible then
    Gui:update_contents({ new_context = context })
  else
    INFO_GUI.build(player, player_table, context, options)
  end
end

--- Refresh the contents of all Recipe Book GUIs.
--- @param player LuaPlayer
--- @param player_table PlayerTable
--- @param skip_memoizer_purge boolean?
function REFRESH_CONTENTS(player, player_table, skip_memoizer_purge)
  if not skip_memoizer_purge then
    formatter.create_cache(player.index)
  end
  --- @type table<number|string, InfoGui>
  local info_guis = player_table.guis.info
  for id, InfoGui in pairs(info_guis) do
    if not constants.ignored_info_ids[id] and InfoGui.refs.window.valid then
      InfoGui:update_contents({ refresh = true })
    end
  end
  --- @type table<string, QuickRefGui>
  local quick_ref_guis = player_table.guis.quick_ref
  for _, QuickRefGui in pairs(quick_ref_guis) do
    if QuickRefGui.refs.window.valid then
      QuickRefGui:update_contents()
    end
  end

  --- @type SearchGui?
  local SearchGui = util.get_gui(player.index, "search")
  if SearchGui then
    SearchGui:dispatch("update_favorites")
    SearchGui:dispatch("update_history")

    if SearchGui.state.search_type == "textual" then
      SearchGui:dispatch("update_search_results")
    elseif SearchGui.state.search_type == "visual" then
      if SearchGui.refs.window.visible then
        SearchGui:update_visual_contents()
      else
        SearchGui.state.needs_visual_update = true
      end
    end
  end
end

-- -----------------------------------------------------------------------------
-- COMMANDS

-- User commands

commands.add_command("rb-refresh-all", { "command-help.rb-refresh-all" }, function(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if not player.admin then
    player.print({ "cant-run-command-not-admin", "rb-refresh-all" })
    return
  end

  game.print("[color=red]REFRESHING RECIPE BOOK[/color]")
  game.print("Get comfortable, this could take a while!")
  on_tick_n.add(game.tick + 1, { action = "refresh_all" })
end)

-- Debug commands

commands.add_command("rb-print-object", nil, function(e)
  if not e.parameter then
    return
  end
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if not player.admin then
    player.print({ "cant-run-command-not-admin", "rb-dump-data" })
    return
  end
  local class, name = string.match(e.parameter, "^(.+) (.+)$")
  if not class or not name then
    player.print("Invalid arguments format")
    return
  end
  local obj = database[class] and database[class][name]
  if not obj then
    player.print("Not a valid object")
    return
  end
  if __DebugAdapter then
    __DebugAdapter.print(obj)
    player.print("Object data has been printed to the debug console.")
  else
    log(game.table_to_json(obj))
    player.print("Object data has been printed to the log file.")
  end
end)

commands.add_command("rb-count-objects", nil, function(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if not player.admin then
    player.print({ "cant-run-command-not-admin", "rb-dump-data" })
    return
  end
  for name, tbl in pairs(database) do
    if type(tbl) == "table" then
      local output = name .. ": " .. table_size(tbl)
      player.print(output)
      log(output)
    end
  end
end)

commands.add_command("rb-dump-database", nil, function(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if not player.admin then
    player.print({ "cant-run-command-not-admin", "rb-dump-data" })
    return
  end
  if __DebugAdapter and (not e.parameter or #e.parameter == 0) then
    __DebugAdapter.print(database)
    game.print("Database has been dumped to the debug console.")
  else
    game.print("[color=red]DUMPING RECIPE BOOK DATABASE[/color]")
    game.print("Get comfortable, this could take a while!")
    on_tick_n.add(
      game.tick + 1,
      { action = "dump_database", player_index = e.player_index, raw = e.parameter == "raw" }
    )
  end
end)

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- BOOTSTRAP

script.on_init(function()
  dictionary.on_init()
  on_tick_n.init()

  global_data.init()
  global_data.update_sync_data()
  global_data.build_prototypes()

  database.build()
  database.check_forces()

  for i, player in pairs(game.players) do
    player_data.init(i)
    player_data.refresh(player, global.players[i])
  end
end)

script.on_load(function()
  formatter.create_all_caches()

  -- When mod configuration changes, don't bother to build anything because it'll have to be built again anyway
  if global_data.check_should_load() then
    database.build()
    database.check_forces()
  end

  -- Load GUIs
  for _, player_table in pairs(global.players) do
    local guis = player_table.guis
    if guis then
      for _, Gui in pairs(guis.quick_ref or {}) do
        QUICK_REF_GUI.load(Gui)
      end
      for id, Gui in pairs(guis.info or {}) do
        if not constants.ignored_info_ids[id] then
          INFO_GUI.load(Gui)
        end
      end
      if guis.search then
        SEARCH_GUI.load(guis.search)
      end
      if guis.settings then
        SETTINGS_GUI.load(guis.settings)
      end
    end
  end
end)

migration.handle_on_configuration_changed(migrations, function()
  dictionary.on_configuration_changed()

  global_data.update_sync_data()
  global_data.build_prototypes()

  database.build()
  database.check_forces()

  for i, player in pairs(game.players) do
    player_data.refresh(player, global.players[i])
  end
end)

-- DICTIONARIES

dictionary.handle_events()

script.on_event(dictionary.on_player_dictionaries_ready, function(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]] --[[@as LuaPlayer]]
  local player_table = global.players[e.player_index]

  player_table.translations = dictionary.get_all(e.player_index)
  if player_table.flags.can_open_gui then
    REFRESH_CONTENTS(player, player_table)
  else
    -- Show message if needed
    if player_table.flags.show_message_after_translation then
      player.print({ "message.rb-can-open-gui" })
      player_table.flags.show_message_after_translation = false
    end

    -- Create GUI
    SEARCH_GUI.build(player, player_table)
    -- Update flags
    player_table.flags.can_open_gui = true
    -- Enable shortcut
    player.set_shortcut_available("rb-search", true)
  end
end)

-- FORCE

script.on_event(defines.events.on_force_created, function(e)
  if not global.forces or not database.generated then
    return
  end
  global_data.add_force(e.force)
  database.check_force(e.force)
end)

script.on_event({ defines.events.on_research_finished, defines.events.on_research_reversed }, function(e)
  -- This can be called by other mods before we get a chance to load
  if not global.players or not database.generated then
    return
  end
  if not database[constants.classes[1]] then
    return
  end

  database.handle_research_updated(e.research, e.name == defines.events.on_research_finished and true or nil)

  -- Refresh all GUIs to reflect finished research
  for _, player in pairs(e.research.force.players) do
    local player_table = global.players[player.index]
    if player_table and player_table.flags.can_open_gui then
      REFRESH_CONTENTS(player, player_table, true)
    end
  end
end)

-- GUI

local function handle_gui_action(msg, e)
  local Gui = util.get_gui(e.player_index, msg.gui, msg.id)
  if Gui then
    Gui:dispatch(msg, e)
  end
end

local function read_gui_action(e)
  local msg = gui.read_action(e)
  if msg then
    handle_gui_action(msg, e)
    return true
  end
  return false
end

gui.hook_events(read_gui_action)

script.on_event(defines.events.on_gui_click, function(e)
  -- If clicking on the Factory Planner dimmer frame
  if not read_gui_action(e) and e.element.style.name == "fp_frame_semitransparent" then
    -- Bring all GUIs to the front
    local player_table = global.players[e.player_index]
    if player_table.flags.can_open_gui then
      util.dispatch_all(e.player_index, "info", "bring_to_front")
      util.dispatch_all(e.player_index, "quick_ref", "bring_to_front")
      --- @type SearchGui?
      local SearchGui = util.get_gui(e.player_index, "search")
      if SearchGui and SearchGui.refs.window.visible then
        SearchGui:bring_to_front()
      end
    end
  end
end)

script.on_event(defines.events.on_gui_closed, function(e)
  if not read_gui_action(e) then
    local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
    local player_table = global.players[e.player_index]
    if player_table.flags.technology_gui_open then
      player_table.flags.technology_gui_open = false
      local gui_data = player_table.guis.search
      if not gui_data.state.pinned then
        player.opened = gui_data.refs.window
      end
    elseif player_table.guis.info._relative_id then
      --- @type InfoGui?
      local InfoGui = util.get_gui(e.player_index, "info", player_table.guis.info._relative_id)
      if InfoGui then
        InfoGui:dispatch("close")
      end
    end
  end
end)

-- INTERACTION

script.on_event(defines.events.on_lua_shortcut, function(e)
  if e.prototype_name == "rb-search" then
    local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
    local player_table = global.players[e.player_index]

    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid_for_read then
      local data = database.item[cursor_stack.name]
      if data then
        OPEN_PAGE(player, player_table, { class = "item", name = cursor_stack.name })
      else
        -- If we're here, the selected object has no page in RB
        player.create_local_flying_text({
          text = { "message.rb-object-has-no-page" },
          create_at_cursor = true,
        })
        player.play_sound({ path = "utility/cannot_build" })
      end
      return
    end

    -- Open search GUI
    --- @type SearchGui?
    local SearchGui = util.get_gui(e.player_index, "search")
    if SearchGui then
      SearchGui:toggle()
    end
  end
end)

local entity_type_to_gui_type = {
  ["infinity-container"] = defines.relative_gui_type.container_gui,
  ["linked-container"] = defines.relative_gui_type.container_gui,
  ["logistic-container"] = defines.relative_gui_type.container_gui,
}

local function get_opened_relative_gui_type(player)
  local gui_type = player.opened_gui_type
  local opened = player.opened

  -- Attempt 1: Some GUIs can be converted straight from their gui_type
  local straight_conversion = defines.relative_gui_type[table.find(defines.gui_type, gui_type) .. "_gui"]
  if straight_conversion then
    return { gui = straight_conversion }
  end

  -- Attempt 2: Specific logic
  if gui_type == defines.gui_type.entity and opened.valid then
    local gui = defines.relative_gui_type[string.gsub(opened.type or "", "%-", "_") .. "_gui"]
      or entity_type_to_gui_type[opened.type]
    if gui then
      return { gui = gui, type = opened.type, name = opened.name }
    end
  end
  if gui_type == defines.gui_type.item and opened and opened.valid then -- Sometimes items don't show up!?
    if opened.object_name == "LuaEquipmentGrid" then
      return { gui = defines.relative_gui_type.equipment_grid_gui }
    else
      local gui = defines.relative_gui_type[string.gsub(opened.type, "%-", "_") .. "_gui"]
        or defines.relative_gui_type.item_with_inventory_gui
      if gui then
        return { gui = gui, type = opened.type, name = opened.name }
      end
    end
  end
end

script.on_event({ "rb-search", "rb-open-selected" }, function(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  local player_table = global.players[e.player_index]

  if player_table.flags.can_open_gui then
    if e.input_name == "rb-open-selected" then
      -- Open the selected prototype
      local selected_prototype = e.selected_prototype
      if selected_prototype then
        -- Special case: Don't open selection tools if we're holding them
        if
          constants.ignored_cursor_inspection_types[selected_prototype.derived_type]
          and player.cursor_stack
          and player.cursor_stack.valid_for_read
          and player.cursor_stack.name == selected_prototype.name
        then
          return
        end
        local class = constants.type_to_class[selected_prototype.derived_type]
          or constants.type_to_class[selected_prototype.base_type]
        -- Not everything will have a Recipe Book entry
        if class then
          local name = selected_prototype.name
          local obj_data = database[class][name]
          if obj_data then
            local options
            if player_table.settings.general.interface.open_info_relative_to_gui then
              local id = player_table.guis.info._relative_id
              if id then
                options = { id = id }
              else
                -- Get the context of the current opened GUI
                local anchor = get_opened_relative_gui_type(player)
                if anchor then
                  anchor.position = defines.relative_gui_position.right
                  options = { parent = player.gui.relative, anchor = anchor }
                end
              end
            end
            local context = { class = class, name = name }
            OPEN_PAGE(player, player_table, context, options)
            return
          end
        end

        -- If we're here, the selected object has no page in RB
        player.create_local_flying_text({
          text = { "message.rb-object-has-no-page" },
          create_at_cursor = true,
        })
        player.play_sound({ path = "utility/cannot_build" })
        return
      end
    else
      --- @type SearchGui?
      local SearchGui = util.get_gui(e.player_index, "search")
      if SearchGui then
        SearchGui:toggle()
      end
    end
  else
    player.print({ "message.rb-cannot-open-gui" })
    player_table.flags.show_message_after_translation = true
  end
end)

script.on_event(
  { "rb-navigate-backward", "rb-navigate-forward", "rb-return-to-home", "rb-jump-to-front", "rb-linked-focus-search" },
  function(e)
    local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
    local player_table = global.players[e.player_index]
    local opened = player.opened
    if
      player_table.flags.can_open_gui
      and player.opened_gui_type == defines.gui_type.custom
      and (not opened or (opened.valid and player.opened.name == "rb_search_window"))
    then
      local active_id = player_table.guis.info._active_id
      if active_id then
        --- @type InfoGui?
        local InfoGui = util.get_gui(e.player_index, "info", active_id)
        if InfoGui then
          if e.input_name == "rb-linked-focus-search" then
            InfoGui:dispatch({ action = "toggle_search" })
          else
            local event_properties = constants.nav_event_properties[e.input_name]
            InfoGui:dispatch(
              { action = "navigate", delta = event_properties.delta },
              { player_index = e.player_index, shift = event_properties.shift }
            )
          end
        end
      end
    end
  end
)

-- PLAYER

script.on_event(defines.events.on_player_created, function(e)
  player_data.init(e.player_index)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  local player_table = global.players[e.player_index]
  player_data.refresh(player, player_table)
  formatter.create_cache(e.player_index)
end)

script.on_event(defines.events.on_player_removed, function(e)
  player_data.remove(e.player_index)
end)

-- TICK

script.on_event(defines.events.on_tick, function(e)
  dictionary.on_tick()

  local actions = on_tick_n.retrieve(e.tick)
  if actions then
    for _, msg in pairs(actions) do
      if msg.gui then
        handle_gui_action(msg, { player_index = msg.player_index })
      elseif msg.action == "dump_database" then
        -- game.table_to_json() does not like functions
        local output = {}
        for key, value in pairs(database) do
          if type(value) ~= "function" then
            output[key] = value
          end
        end
        local func = msg.raw and serpent.dump or game.table_to_json
        game.write_file("rb-dump", func(output), false, msg.player_index)
        game.print("[color=green]Dumped database to script-output/rb-dump[/color]")
      elseif msg.action == "refresh_all" then
        dictionary.on_init()
        database.build()
        database.check_forces()
        for player_index, player in pairs(game.players) do
          local player_table = global.players[player_index]
          player_data.refresh(player, player_table)
          player_table.flags.show_message_after_translation = true
        end
        game.print("[color=green]Database refresh complete, retranslating dictionaries...[/color]")
      end
    end
  end
end)

-- -----------------------------------------------------------------------------
-- REMOTE INTERFACE

remote.add_interface("RecipeBook", remote_interface)
