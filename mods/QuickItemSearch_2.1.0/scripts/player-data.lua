local translation = require("__flib__.translation")

local constants = require("constants")
local infinity_filter = require("scripts.infinity-filter")
local logistic_request = require("scripts.logistic-request")

local infinity_filter_gui = require("scripts.gui.infinity-filter")
local logistic_request_gui = require("scripts.gui.logistic-request")
local search_gui = require("scripts.gui.search")

local player_data = {}

function player_data.init(player_index)
  global.players[player_index] = {
    flags = {
      can_open_gui = false,
      show_message_after_translation = false,
      translate_on_join = false,
    },
    guis = {},
    infinity_filters = {by_index = {}, by_name = {}, temporary = {}},
    logistic_requests = {by_index = {}, by_name = {}, temporary = {}},
    settings = {}
  }
end

function player_data.refresh(player, player_table)
  -- destroy GUIs
  if player_table.guis.infinity_filter then
    infinity_filter_gui.destroy(player_table)
  end
  if player_table.guis.request then
    logistic_request_gui.destroy(player_table)
  end
  if player_table.guis.search then
    search_gui.destroy(player_table)
  end

  player_table.flags.can_open_gui = false

  -- set shortcut state
  player.set_shortcut_toggled("qis-search", false)
  player.set_shortcut_available("qis-search", false)

  -- update settings
  player_data.update_settings(player, player_table)

  -- refresh requests or infinity filters
  if player.controller_type == defines.controllers.editor then
    infinity_filter.refresh(player, player_table)
  elseif player.controller_type == defines.controllers.character then
    logistic_request.refresh(player, player_table)
  end

  -- run translations
  player_table.translations = {}
  if player.connected then
    player_data.start_translations(player.index)
  else
    player_table.flags.translate_on_join = true
  end
end

function player_data.start_translations(player_index)
  translation.add_requests(player_index, global.strings)
end

function player_data.update_settings(player, player_table)
  local player_settings = player.mod_settings
  local settings = {}

  for internal, prototype in pairs(constants.settings) do
    settings[internal] = player_settings[prototype].value
  end

  player_table.settings = settings
end

return player_data
