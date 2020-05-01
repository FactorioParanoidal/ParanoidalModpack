-- code inspired by Optera's LTN and LTN Content Reader
-- LTN is required to run this mod (obviously, since its a UI to display data collected by LTN)
-- https://mods.factorio.com/mod/LogisticTrainNetwork
-- https://mods.factorio.com/mod/LTN_Content_Reader

-- control.lua only handles initial setup and event registration
-- UI and data processing are kept seperate, to allow the UI to always be responsive
-- data_processor.lua module: receives event data from LTN and processes it for usage by UI
-- gui_ctrl.lua module: handles UI events and displays data provided in global.data

-- constants
MOD_NAME = require("script.constants").global.mod_name
MOD_PREFIX = require("script.constants").global.mod_prefix
GUI_EVENTS = require("script.constants").global.gui_events
local LTN_MOD_NAME = require("script.constants").global.mod_name_ltn
local LTN_MINIMAL_VERSION = require("script.constants").global.minimal_version_ltn
local LTN_CURRENT_VERSION = require("script.constants").global.current_version_ltn

debug_log = settings.global["ltnt-debug-level"].value

-- helper functions
local function format_version(version_string)
  return string.format("%02d.%02d.%02d", string.match(version_string, "(%d+).(%d+).(%d+)"))
end

------------------------------
------- initialization -------
------------------------------
custom_events = {
  on_data_updated = script.generate_event_name(),
  on_train_alert = script.generate_event_name(),
  on_ui_invalid = script.generate_event_name(),
}

-- load modules
log2 = require("__OpteraLib__.script.logger").log
ui = require("script.gui_ctrl")
local prc = require("script.data_processing")

script.on_init(function()
  -- check for LTN
  local ltn_version = nil
  local ltn_version_string = game.active_mods[LTN_MOD_NAME]
  if ltn_version_string then
    ltn_version = format_version(ltn_version_string)
  end
  if not ltn_version or ltn_version < LTN_MINIMAL_VERSION then
    error(log2(MOD_NAME, "requires version", LTN_MINIMAL_VERSION, "later of Logistic Train Network to run."))
  end
  -- also check for LTN interface, just in case
  if not remote.interfaces["logistic-train-network"] then
    error(log2("LTN interface is not registered."))
  end
  if debug_log then
    log2("Starting mod initialization for mod", MOD_NAME .. ". LTN version", ltn_version_string, "has been detected.")
  end

  -- module init
  ui.on_init()
  prc.on_init()

  if debug_log then
    log2("Initialization finished.")
  end
end)

script.on_event(defines.events.on_player_created, function(event) ui.player_init(event.player_index) end)

script.on_load(function()
  ui.on_load()
  prc.on_load()
  if debug_log then
    log2("on_load finished")
  end
end)

-----------------------------------
------- settings and config -------
-----------------------------------

do
  local setting_dict = require("script.constants").settings
  script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    -- notifies modules if one of their settings changed
    if not event then return end
    local pind = event.player_index
    local player = game.players[pind]
    local setting = event.setting
    if debug_log then
      log2("Player", player.name, "changed setting", setting)
    end
    if setting_dict.ui[setting] then
      ui.on_settings_changed(pind, event)
    end
    if setting_dict.proc[setting] then
      prc.on_settings_changed(event)
    end
    if setting_dict.debug[setting] then
      debug_log = settings.global["ltnt-debug-level"].value
    end
  end)
end

do
  local LTNC_MOD_NAME = require("script.constants").global.mod_name_ltnc
  script.on_configuration_changed(function(data)
    if not data then return end
    -- handle changes to LTN
    if data.mod_changes[LTN_MOD_NAME] then
      local ov = data.mod_changes[LTN_MOD_NAME].old_version
      ov = ov and format_version(ov) or "0.0.0 (not present)"
      local nv = data.mod_changes[LTN_MOD_NAME].new_version
      nv = nv and format_version(nv) or "0.0.0 (not present)"
      if nv >= LTN_MINIMAL_VERSION then
        if nv > LTN_CURRENT_VERSION then
          log2("LTN version changed from ", ov, " to ", nv, ". That version is not supported, yet. Depending on the changes to LTN, this could result in issues with LTNT.")
        else
          log2("LTN version changed from ", ov, " to ", nv)
        end
      else
        error(log2("LTN version was changed from ", ov, " to ", nv, ".", MOD_NAME, "requires version",  LTN_MINIMAL_VERSION, " or later of Logistic Train Network to run."))
      end
    end
    -- handle changes to LTN-Combinator
    if data.mod_changes[LTNC_MOD_NAME] then
      global.gui.ltnc_is_active = game.active_mods[LTNC_MOD_NAME] and true or false
      if not data.mod_changes[MOD_NAME] then ui.reset_ui() end
    end
    -- handles changes to LTNT
    if data.mod_changes[MOD_NAME] then
      ui.reset_ui()
      -- migration to 0.10.7
      global.proc.underload_is_alert = not settings.global["ltnt-disable-underload-alert"].value
    end
  end)
end

-----------------------------
------- STATIC EVENTS -------
-----------------------------
-- additional events are (un-)registered dynamically as needed by data_processing.lua

-- gui events
script.on_event(defines.events.on_gui_closed, ui.on_ui_closed)
script.on_event(GUI_EVENTS, ui.ui_event_handler)
script.on_event("ltnt-toggle-hotkey", ui.on_toggle_button_click)
script.on_event(
  defines.events.on_lua_shortcut,
  function(event)
    if event.prototype_name == "ltnt-toggle-shortcut" then
      ui.on_toggle_button_click(event)
    end
  end
)

-- custom events
-- raised when updated data for gui is available
script.on_event(custom_events.on_data_updated, ui.update_ui)
-- raised when a train with an error is detected
script.on_event(custom_events.on_train_alert, ui.on_new_alert)
-- raised when UI element(s) became invalid
script.on_event(custom_events.on_ui_invalid, ui.reset_ui)