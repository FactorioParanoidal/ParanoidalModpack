----------------------
------ pre init ------
----------------------

-- localize helper functions
local s2n = tonumber
local match = string.match
local mod_gui = require("mod-gui")
local lib_utils = require("__OpteraLib__.script.train")

-- load / set constants
local N_TABS = 0
local gc_pathes = {   -- list of GUIComposition objects to load
  "ui.toggle_button",
  "ui.outer_frame",
  "ui.depot_tab",
  "ui.history_tab",
  "ui.inventory_tab",
  "ui.station_tab",
  "ui.alert_tab",
}
-- load and store GuiComposition objects
local GC = {}
local tab_list = {}
for _,path in pairs(gc_pathes) do
  local gc = require(path)
  if GC[gc.name] then
    error(log2("GuiComposition object with name", gc.name, "does already exist."))
  end
  GC[gc.name] = gc
  for _,sub_gc in pairs(gc.sub_gc) do
    if GC[sub_gc.name] then
      error(log2("GuiComposition object with name", sub_gc.name, "does already exist."))
    end
    GC[sub_gc.name] = sub_gc
  end
  if gc.tab_index then
    if tab_list[gc.tab_index] then
      error(log2("Tab index", gc.tab_index, "is already registerd by another GC object.\ntab_list:", tab_list))
    end
    tab_list[gc.tab_index] = gc
    N_TABS = N_TABS + 1
  end
end

-----------------------------
------ initialization  ------
-----------------------------
-- do not change any of the variables defined above from this point onward
-- enforced by desync
local function on_load()
  for _,gc in pairs(GC) do
    -- restore local references to objects' global storage tables
    gc:on_load(global.gui)
  end
end

local function player_init(pind)
  local player = game.players[pind]
  local frame_flow = mod_gui.get_frame_flow(player)
  local button_flow = mod_gui.get_button_flow(player)
  if debug_log then
    log2("Building UI for player", player.name)
  end

  -- set UI state globals
  global.gui.active_tab[pind] = 1 -- even if ui is closed, active tab persists and is restored when UI opens
  global.gui.is_gui_open[pind] = false
  global.gui.last_refresh_tick[pind] = 0
  global.gui.refresh_interval[pind] = settings.get_player_settings(player)["ltnt-refresh-interval"].value * 60
  global.gui.station_select_mode[pind] = tonumber(settings.get_player_settings(player)["ltnt-station-click-behavior"].value)

  -- build UI
  GC.toggle_button:build(button_flow, pind)
  if not settings.get_player_settings(player)["ltnt-show-button"].value then
    GC.toggle_button:hide(pind)
  end
  GC.outer_frame:build(frame_flow, pind)
  GC.outer_frame:hide(pind) -- UI is always closed on init

  -- add tabs to outer_frame
  local outer_frame = GC.outer_frame:get(pind)
  GC.depot_tab:build(outer_frame, pind)
  GC.stop_tab:build(outer_frame, pind)
  GC.inv_tab:build(outer_frame, pind)
  GC.hist_tab:build(outer_frame, pind)
  GC.alert_tab:build(outer_frame, pind)
end

local LTNC_MOD_NAME = require("script.constants").global.mod_name_ltnc
local function on_init()
  -- global storage for UI state
  global.gui = {
    is_gui_open = {},
    active_tab = {},
    last_refresh_tick = {},
    refresh_interval = {},
    ltnc_is_active = game.active_mods[LTNC_MOD_NAME] and true or false,
    is_ltnc_open = {},
    station_select_mode = {},
  }

  global.last_sort = {}
  for _,gc in pairs(GC) do
    -- creates and populates global.gui[gc.name]
    gc:on_init(global.gui)
  end
  -- initialize present players, they dont trigger on_player_created event
  for pind,_ in pairs(game.players) do
    player_init(pind)
  end
end

local function reset_ui()
  -- wipe existing UIs and clear global UI storage...
  log2("Resetting UI.")
  for pind in pairs(game.players) do
    for _, gc in pairs(GC) do
      gc:destroy(pind)
    end
  end
  global.gui = nil
  -- ... and rebuild
  on_init()
end

local function clear_station_filter()
  -- hacky way to force reset of cached filter results
  GC.stop_tab.mystorage.last_filter = {}
end
------------------------------
--- RUNTIME EVENT HANDLERS ---
------------------------------
local function on_settings_changed(pind, event)
  local player = game.players[pind]
  local setting = event.setting
  if setting == "ltnt-window-height" then
    player_init(pind) -- rebuild entire ui for player
  elseif setting == "ltnt-show-button" then
    -- show or hide toggle button
    if settings.get_player_settings(player)[setting].value then
      GC.toggle_button:show(pind)
    else
      GC.toggle_button:hide(pind)
    end
  end
  if setting == "ltnt-refresh-interval" then
    global.gui.refresh_interval[pind] = settings.get_player_settings(player)[setting].value * 60 -- convert seconds to ticks
  end
  if setting == "ltnt-station-click-behavior" then
    global.gui.station_select_mode[pind] = tonumber(settings.get_player_settings(player)["ltnt-station-click-behavior"].value)
  end
end

-- basic UI functions
local function update_tab(pind)
  -- updates the currently selected tab for one player, if that player has the UI open
  local tab_index = global.gui.is_gui_open[pind] and global.gui.active_tab[pind]
  if tab_index then
    for i = 1,N_TABS do
      tab_list[i]:update(pind, tab_index)
    end
  end
end

local function on_toggle_button_click(event)
  local pind = event.player_index
  if GC.outer_frame:toggle(pind) then
    game.players[pind].set_shortcut_toggled("ltnt-toggle-shortcut", true)
    GC.toggle_button:clear_alert(event.player_index)
    update_tab(event.player_index)
  else
    game.players[pind].set_shortcut_toggled("ltnt-toggle-shortcut", false)
  end
end

local function close_gui(pind)
  game.players[pind].opened = nil
  GC.outer_frame:hide(pind)
  if debug_log then
    log2("Closing UI for player", pind)
  end
end

-- handler for all events defined in global constant GUI_EVENTS
-- calls the appropriate handler for the given event
-- available handlers are stored in handlers table
local match_string = MOD_PREFIX.."_([%a_]+)(%d+)_?(.*)"
--local match_ui_name function(element_name) return match(element_name, ms) end
local handlers = {on_toggle_button_click = on_toggle_button_click}

local function ui_event_handler(event)
  -- check element name; pattern used by all GuiComposition objects is
  -- "ltnt_<name of GC object>_<index of element in the GC object>_<[optional]any string>"
  local gc_name, elem_index, data_string = match(event.element.name, match_string)
  if gc_name then -- this element belongs to ltnt, so continue (or some other mod with the same prefix xX)
    if GC[gc_name] then -- should not be necessary, but let's be extra safe in case another mod uses exactly the same naming pattern
      local handler, data = GC[gc_name]:get_event_handler(event, s2n(elem_index), data_string)
      if debug_log then
        log2("Gui event received.\nEvent:", event, "\ngc_name:", gc_name, "\nelem_index:", elem_index, "\ndata_string:", data_string, "\nhandler:", handler, "\ndata:", data)
      end
      if type(handler) == "string" then
        if data then
          handlers[handler](event, data)
        else
          handlers[handler](event, data_string)
        end
      end
    else
      log2("Gui event registerd for UI element with name", event.element.name, ", but corresponding GC object was not found.\nCurrent state of GC:\n", GC, "\nTriggering event:", event)
    end
  end
end

-- handler for on_data_updated event
local function update_ui(event)
  local tick = game.tick
  local interval = global.gui.refresh_interval
  for pind in pairs(game.players) do
    if interval[pind] > 0 and tick - global.gui.last_refresh_tick[pind] > interval[pind]  then
      global.gui.last_refresh_tick[pind] = tick
      update_tab(pind)
    end
  end
end

-- handler for on_gui_closed event
local function on_ui_closed(event)
  -- event triggers whenever any UI element is closed, so check if it is actually the ltnt UI that is supposed to close
  local pind = event.player_index
	if event.element and event.element.valid and event.element.index == GC.outer_frame:get(pind).index then
    if global.gui.ltnc_is_active and global.gui.is_ltnc_open and global.gui.is_ltnc_open[pind] then
      global.gui.is_ltnc_open[pind] = nil
      remote.call("ltn-combinator", "close_ltn_combinator", pind)
      game.players[pind].opened = GC.outer_frame:get(pind)
      update_tab(pind)
    else
      close_gui(event.player_index)
    end
	end
end

-- handler for on_new_alert custom event
local function on_new_alert(event)
  if event and event.type then
    for pind in pairs(game.players) do
      GC.toggle_button:set_alert(pind)
      GC.outer_frame:set_alert(pind)
    end
  end
end

-- event handlers called by ctrl.gui_event_handler
function handlers.on_tab_changed(event, data_string)
  -- data string is index of clicked tab button
  GC.outer_frame:update_buttons(event.player_index, s2n(data_string))
  update_tab(event.player_index)
end

function handlers.clear_history(event, data_string)
  global.data.delivery_hist = {}
  global.data.newest_history_index = 1
  update_tab(event.player_index)
end

function handlers.clear_train_alerts(event, data_string)
  global.data.trains_error = {}
  global.data.trains_error_count = 1
  update_tab(event.player_index)
end

function handlers.on_refresh_bt_click(event, data_string)
  local pind = event.player_index
  if global.gui.last_refresh_tick[pind] + global.gui.refresh_interval[pind] < game.tick then
    global.gui.last_refresh_tick[pind] = game.tick
    update_tab(event.player_index)
  end
end

do -- handle button/label clicks that are supposed to select a train/station/cc
  local select_train
  do
    select_train = require("__OpteraLib__.script.train").open_train_gui
  end
  local function select_entity(pind, entity)
    if entity and entity.valid and game.players[pind] then
      game.players[pind].opened = entity
      return true
    end
  end
  local function select_combinator(pind, stop_entity, input_lamp)
    if global.gui.ltnc_is_active then
      if remote.call("ltn-combinator", "open_ltn_combinator", pind, input_lamp, false) then
        global.gui.is_ltnc_open = {[pind] = true}
        return true
      end
      local player = game.players[pind]
      player.surface.create_entity{
        name="flying-text",
        position=player.position,
        text={"ltnt.no-ltnc-found-msg"},
        color={r=1,g=0,b=0}
      }
      return false
    end
    return false
  end

-- data_string should be stop ID as a string
  local draw_circle = rendering.draw_circle
  local get_player_settings = settings.get_player_settings
  local marker_color = require("script.constants").ui_ctrl.marker_circle_color
  function handlers.on_stop_name_clicked(event, data_string)
    local stop = global.data.stops[s2n(data_string)]
    local pind = event.player_index
    if stop and stop.entity and stop.entity.valid then
      close_gui(pind)
      if global.gui.station_select_mode[pind] < 3  then
        select_entity(pind, stop.entity)
      end

      if global.gui.station_select_mode[pind] > 1 then
        game.players[pind].zoom_to_world({stop.entity.position.x+40, stop.entity.position.y+0}, 0.4)
        local render_id = rendering.draw_circle({
          color = marker_color,
          radius = 3,
          width = 10,
          surface = "nauvis",
          filled = false,
          target = stop.entity,
          target_offset  = {-1, -1},
          time_to_live = 300,
          players = {pind},
        })
      end
    end
  end

  function handlers.on_cc_button_clicked(event, data_string)
    local stop =  global.data.stops[s2n(match(data_string, "cc_(.*)"))]
    if stop and stop.entity and stop.entity.valid then
      select_combinator(event.player_index, stop.entity, stop.input)
    end
  end

  function handlers.on_entity_clicked(event, entity)
    if entity and entity.valid then
      close_gui(event.player_index)
      select_entity(event.player_index, entity)
    end
  end

  function handlers.on_train_clicked(event, train)
    if train and train.valid then
      close_gui(event.player_index)
      select_train(event.player_index, train)
    end
  end
end --do

function handlers.on_item_clicked(event, data_string)
  -- item name and amount is encoded in data_string
  GC.inv_tab:on_item_clicked(event.player_index, data_string)
end

-- for debugging
commands.add_command("kill_ui", "",
  function()
    GC.outer_frame:get(1).destroy()
  end
)
return {
  on_init = on_init,
  on_load = on_load,
  on_toggle_button_click = on_toggle_button_click,
  on_settings_changed = on_settings_changed,
  player_init = player_init,
  ui_event_handler = ui_event_handler,
  on_ui_closed = on_ui_closed,
  on_new_alert = on_new_alert,
  update_ui = update_ui,
  reset_ui = reset_ui,
  clear_station_filter = clear_station_filter,
  }