-- constant definitions
local CONST = {}

CONST.settings = {
  ui = {
    ["ltnt-show-button"] = true,
    ["ltnt-window-height"] = true,
    ["ltnt-refresh-interval"] = true,
    ["ltnt-station-click-behavior"] = true,
  },
  proc = {
    ["ltnt-history-limit"] = true,
    ["ltnt-disable-underload-alert"] = true,
  },
  debug = {
    ["ltnt-debug-level"] = true,
  },
}

CONST.global = {
  mod_name = "LTN_Tracker",
  mod_prefix = "ltnt",
  gui_events = {defines.events.on_gui_click, defines.events.on_gui_checked_state_changed, defines.events.on_gui_text_changed}, -- events handled by on_gui_event
  mod_name_ltn = "LogisticTrainNetwork",
  mod_name_ltnc = "LTN_Combinator",
  minimal_version_ltn = "01.10.07",
  current_version_ltn = "01.10.08",
}

CONST.styles = {
  font_color_black = {40, 39, 40}
}

-- ui_ctrl.lua
CONST.ui_ctrl = {
  refresh_delay = 60, -- shortest time in ticks between consecutive ui refreshes
  marker_circle_color = {r = 1, g = 0, b = 0, a = 0.5}
}

-- data_processing.lua
CONST.proc = {
  fluid_tolerance = 0.1,
  stops_per_tick = 20,
  deliveries_per_tick = 20,
  trains_per_tick = 30,
  items_per_tick = 50,
}

-- UI layout
CONST.main_frame = {
	n_tabs = 5,
  button_width = 185,
  button_sprite_bare = "ltnt_bt_sprite",
  button_sprite_alert = "ltnt_bt_alert_sprite",
  button_highlight_style = "ltnt_tab_button_highlight",
  button_default_style =  "ltnt_tab_button"
}

CONST.depot_tab = {
	tab_index = 1,
  pane_width_left = 355,
	col_width_left = {325, 55, 50, 52, 180},

  pane_width_right = 580,
	col_width_right = {160, 190, 101},
  -- parked / error / on delivery
  color_dict = {{r=0,g=1,b=0}, {r=1,g=0,b=0}, {r=1,g=1,b=1}},
}

CONST.station_tab = {
	tab_index = 2,
  header_col_width = {207, 29, 38*5+27, 38*4+21, 38*6, 1},
  station_col_width = 195,
  item_table_col_count = {5, 4, 6},
  item_table_max_rows = {4, 4, 2},
}

CONST.inventory_tab = {
	tab_index = 3,
  item_table_column_count = 13,
  details_item_tb_col_count = 9,
  details_width = 400,
  details_tb_col_width_stations = {300, 45},
  details_tb_col_width_deliveries = {160, 25, 160}
}

CONST.history_tab = {
	tab_index = 4,
	header_col_width = {175, 175, 175, 35, 55, 152},
	col_width = {175, 175, 175, 40, 45, 145},
	n_columns = 6,
  n_cols_shipment = 5,
}

CONST.alert_tab = {
	tab_index = 5,
  frame_width = 940,
  n_columns = 5,
	col_width = {180, 170, 220, 240},
}

-- LTN definitions, copied from LTN's control.lua
local ltn = {
  ISDEPOT = "ltn-depot",
  NETWORKID = "ltn-network-id",
  MINTRAINLENGTH = "ltn-min-train-length",
  MAXTRAINLENGTH = "ltn-max-train-length",
  MAXTRAINS = "ltn-max-trains",
  REQUESTED_THRESHOLD = "ltn-requester-threshold",
  REQUESTED_STACK_THRESHOLD = "ltn-requester-stack-threshold",
  REQUESTED_PRIORITY = "ltn-requester-priority",
  NOWARN = "ltn-disable-warnings",
  PROVIDED_THRESHOLD = "ltn-provider-threshold",
  PROVIDED_STACK_THRESHOLD = "ltn-provider-stack-threshold",
  PROVIDED_PRIORITY = "ltn-provider-priority",
  LOCKEDSLOTS = "ltn-locked-slots",
}
ltn.is_control_signal = {
  [ltn.ISDEPOT] = true,
  [ltn.NETWORKID] = true,
  [ltn.MINTRAINLENGTH] = true,
  [ltn.MAXTRAINLENGTH] = true,
  [ltn.MAXTRAINS] = true,
  [ltn.REQUESTED_THRESHOLD] = true,
  [ltn.REQUESTED_STACK_THRESHOLD] = true,
  [ltn.REQUESTED_PRIORITY] = true,
  [ltn.NOWARN] = true,
  [ltn.PROVIDED_THRESHOLD] = true,
  [ltn.PROVIDED_STACK_THRESHOLD] = true,
  [ltn.PROVIDED_PRIORITY] = true,
  [ltn.LOCKEDSLOTS] = true,
}
ltn.ctrl_signal_var_name_bool = {
  [ltn.ISDEPOT] = "isDepot",
  [ltn.NOWARN] = "noWarnings",
}
ltn.ctrl_signal_var_name_num = {
  [ltn.NETWORKID] = "network_id",
  [ltn.MINTRAINLENGTH] = "minTraincars",
  [ltn.MAXTRAINLENGTH] = "maxTraincars",
  [ltn.MAXTRAINS] = "trainLimit",
  [ltn.REQUESTED_THRESHOLD] = "requestThreshold",
  [ltn.REQUESTED_STACK_THRESHOLD] = "requestStackThreshold",
  [ltn.REQUESTED_PRIORITY] = "requestPriority",
  [ltn.PROVIDED_THRESHOLD] = "provideThreshold",
  [ltn.PROVIDED_STACK_THRESHOLD] = "provideStackThreshold",
  [ltn.PROVIDED_PRIORITY] = "providePriority",
  [ltn.LOCKEDSLOTS] = "lockedSlots",
}
ltn.error_color_lookup = {
  [-1]= "signal-white",
  [0] = "signal-white", -- this is a modification, used when entity becomes invalid
  [1] = "signal-red",
  [2] = "signal-pink",
}
ltn.error_string_lookup = {
  [-1] = {"error.stop-no-init"},
  [0] = {"error.stop-invalid"},
  [1] = {"error.stop-disabled"},
  [2] = {"error.stop-duplicate"},
}
CONST.ltn = ltn
return CONST