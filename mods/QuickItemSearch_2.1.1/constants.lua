local constants = {}

local default_orange_color = { r = 0.98, g = 0.66, b = 0.22 }

constants.colors = {
  hovered = {
    r = 0.5 * (1 + default_orange_color.r),
    g = 0.5 * (1 + default_orange_color.g),
    b = 0.5 * (1 + default_orange_color.b),
  },
  inbound = { 255, 240, 69 },
  logistic_str = "128, 206, 240",
  normal = { 255, 255, 255 },
  outbound = { 69, 255, 69 },
  unsatisfied = { 255, 69, 69 },
}

constants.ignored_item_types = {
  ["blueprint-book"] = true,
  ["blueprint"] = true,
  ["copy-paste-tool"] = true,
  ["deconstruction-item"] = true,
  ["selection-tool"] = true,
  ["upgrade-item"] = true,
}

constants.infinity_filter_mode_to_index = {
  ["at-least"] = 1,
  ["at-most"] = 2,
  ["exactly"] = 3,
}

constants.infinity_filter_mode_to_symbol = {
  ["at-least"] = "≥",
  ["at-most"] = "≤",
  ["exactly"] = "=",
}

constants.infinity_filter_modes = {
  ["at-least"] = "at-least",
  ["at-most"] = "at-most",
  ["exactly"] = "exactly",
}

constants.infinity_filter_modes_by_index = {
  "at-least",
  "at-most",
  "exactly",
}

constants.infinity_rep = "inf."

constants.input_sanitizers = {
  ["%("] = "%%(",
  ["%)"] = "%%)",
  ["%.^[%*]"] = "%%.",
  ["%+"] = "%%+",
  ["%-"] = "%%-",
  ["^[%.]%*"] = "%%*",
  ["%?"] = "%%?",
  ["%["] = "%%[",
  ["%]"] = "%%]",
  ["%^"] = "%%^",
  ["%$"] = "%%$",
}

constants.logistic_point_data = {
  {
    deliveries_table = "outbound",
    logistic_point = defines.logistic_member_index.character_provider,
    point_name = "provider",
    source_table = "targeted_items_pickup",
  },
  {
    deliveries_table = "inbound",
    logistic_point = defines.logistic_member_index.character_requester,
    point_name = "requester",
    source_table = "targeted_items_deliver",
  },
}

constants.results_limit = 50

constants.settings = {
  auto_close = "qis-auto-close-window",
  fuzzy_search = "qis-fuzzy-search",
  show_hidden = "qis-show-hidden",
  spawn_items_when_cheating = "qis-spawn-items-when-cheating",
}

return constants
