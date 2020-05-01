--[[

--]]
-- TODO: make TAB key select next input (doesn't work, if intermediate GUIElements are not visible)
-- TODO: high provide threshold does not get applied (if user chooses a request threshold manually via output)

global = global or {}
global.default_visibility = global.default_visibility or {}
global.ltn_version_notice = global.ltn_version_notice or false

MOD_NAME    = "LTN_Combinator" 
MOD_STRING  = "LTN Combinator"
MOD_TOKEN   = "LTNC"
MOD_VERSION = "0.5.0"

LTN_MOD_NAME    = "LogisticTrainNetwork"
LTN_MOD_VERSION = "1.12.0"

print, dlog = require "scripts.logger"()


local config = require "config"
local events = require "scripts.ltnc-events"
local ltnc   = require "scripts.ltnc"
ltnc.gui        = require "scripts.ltnc-gui"

local network_config  = require "scripts.ltnc-networkconfig"

ltnc.event_map(events)
ltnc.gui.event_map(events)
network_config.event_map(events)

--[[ ----------------------------------------------------------------------------------
        MOD HELPER
--]]
local function mod_ltn_check()
  if not game then return end 
  
  -- check ltn availability 
  local ltn_version = game.active_mods[LTN_MOD_NAME]
  
  if not ltn_version or ltn_version == "" then
    print("LogisticTrainNetwork is required to use LTN Combinator.")
    global.vanilla_gui = true
    return false
  end
  
  -- check ltn version
  ltn_version = string.format("%02d.%02d.%02d", string.match(ltn_version, "(%d+).(%d+).(%d+)"))

  if LTN_MOD_VERSION < ltn_version then
    -- check if user wants to suppress custom gui
    if settings.global["suppress-custom-gui"].value == true then
      global.vanilla_gui = true
      return false
    else
      global.vanilla_gui = false
    end
    
    if global.ltn_version_notice == true then return end
    
    global.ltn_version_notice = true
    print("LogisticTrainNetwork has been updated. If you experience any conflicts disable LTN Combinator in \"Mod Settings\" and sit tight while waiting for an update.")    
  else
    global.ltn_version_notice = false
  end
  
  global.vanilla_gui = false
  return true
end

-- register remote interfaces
remote.add_interface("ltn-combinator", {
  -- Usage: result = remote.call("ltn-combinator", "open_ltn_combinator", player_index (integer), entity (LuaEntity), register (boolean))
  --  player_index: (required)
  --  entity: any entity that is in the same green-circuit-network as the wanted ltn-combinator (required)
  --  register: registers the opened window in game.player[i].opened (optional, default true)
  --  returns a boolean, whether a combinator was opened
  open_ltn_combinator = ltnc.open_combinator,
  
  -- Usage: result = remote.call("ltn-combinator", "close_ltn_combinator", player_index (integer))
  --  player_index: (required)
  --
  --  Calling this interface is only required if a ltn-combinator was previously opened with register = false.
  --  Use this method to keep your own window open.
  close_ltn_combinator = ltnc.close_combinator
})

-- debugging tool for remote call testing
local function ltnc_remote_open(event)
  local entity = nil
  if game.players[event.player_index] then
    entity = game.players[event.player_index].selected
  end
  
  if entity == nil or entity.valid ~= true then return end 
  remote.call("ltn-combinator", "open_ltn_combinator", event.player_index, entity, true)
end

local function ltnc_remote_close(event)
  remote.call("ltn-combinator", "close_ltn_combinator", event.player_index)
end

local function ltnc_remote_clear(event)
  game.players[event.player_index].gui.center.clear()
  global.gui[event.player_index].main_frame.destroy()
  global.gui[event.player_index] = nil
end

local function ltnc_open_network(event)
  network_config.open(event)
end

commands.add_command("ltncopen", "Use /ltncopen while hovering an entity to open a near ltn combinator", ltnc_remote_open)
commands.add_command("ltncclose", "Use /ltncclose to close the opened ltn combinator", ltnc_remote_close)
commands.add_command("ltncconfig", "Use /ltncconfig to setup network icons", ltnc_open_network)

--commands.add_command("ltncclear", "Use /ltncclear to refresh uis", ltnc_remote_clear)

--[[ ----------------------------------------------------------------------------------
        MOD INITIALIZATION
--]]
local function mod_init()
  mod_ltn_check()
  ltnc.mod_init()
  network_config.mod_init()
end

local function mod_configuration_changed(data)
  -- check for ltn version
  mod_ltn_check()
  
  -- check if LTN Combinator was updated
  if data and data.mod_changes[MOD_NAME] then
    -- version number not needed yet
    -- data.mod_changes[MOD_NAME].old_version
    -- data.mod_changes[MOD_NAME].new_version
    ltnc.mod_configuration_changed()
  end
end

local function mod_player_joined(event)
  if global.messages ~= nil then
    -- print messages
    for i=1, #global.messages do
      game.print(global.messages[i])
    end
  end
  
  ltnc.on_player_joined(event) 
end

-- update settings called every time and on mod_runtime_setting_changed()
local function update_settings()
  -- default visibility of ltn entries
  global.default_visibility["ltn-network-id"]                = settings.global["show-ltn-network-id"].value
  global.default_visibility["ltn-requester-threshold"]       = settings.global["provide-type"].value == "only-item-count" or settings.global["provide-type"].value == "both-item-stack"
  global.default_visibility["ltn-requester-stack-threshold"] = settings.global["provide-type"].value == "only-stack-count" or settings.global["provide-type"].value == "both-item-stack"
  global.default_visibility["ltn-requester-priority"]        = settings.global["show-ltn-priorities"].value
  global.default_visibility["ltn-provider-threshold"]        = settings.global["provide-type"].value == "only-item-count" or settings.global["provide-type"].value == "both-item-stack"
  global.default_visibility["ltn-provider-stack-threshold"]  = settings.global["provide-type"].value == "only-stack-count" or settings.global["provide-type"].value == "both-item-stack"
  global.default_visibility["ltn-provider-priority"]         = settings.global["show-ltn-priorities"].value
  global.default_visibility["ltn-min-train-length"]          = settings.global["show-ltn-train-length"].value
  global.default_visibility["ltn-max-train-length"]          = settings.global["show-ltn-train-length"].value
  global.default_visibility["ltn-max-trains"]                = settings.global["show-ltn-max-trains"].value
  global.default_visibility["ltn-locked-slots"]              = settings.global["show-ltn-locked-slots"].value
  global.default_visibility["ltn-disable-warnings"]          = settings.global["show-ltn-disable-warnings"].value

  global.high_provide_threshold = settings.global["high-provide-threshold"].value
  
  -- check for version mismatch
  global.suppress_custom_gui = settings.global["suppress-custom-gui"].value
  mod_ltn_check()
  
  -- dirty fix, prevent gui from jumping around
  local entry_count = -1
  for k, v in pairs(global.default_visibility) do
    if v == true then
      entry_count = entry_count + 1
    end
  end
  
  if settings.global["provide-type"].value == "both-item-stack" then
    entry_count = entry_count - 1
  end
  
  if settings.global["show-ltn-priorities"].value == true then
    entry_count = entry_count - 1
  end
  
  if settings.global["show-ltn-locked-slots"].value == true and settings.global["show-ltn-disable-warnings"].value == true then
    entry_count = entry_count - 1
  end
  
  global.default_entry_count = entry_count
  -- end: dirty fix
  
  -- grab default threshold from ltn settings
  if settings.global["ltn-dispatcher-requester-threshold"] then
    local threshold = settings.global["ltn-dispatcher-requester-threshold"].value
    config.ltn_signals["ltn-requester-threshold"].default = threshold
  end
  
  if settings.global["ltn-dispatcher-provider-threshold"] then
    local threshold = settings.global["ltn-dispatcher-provider-threshold"].value
    config.ltn_signals["ltn-provider-threshold"].default = threshold
  end
  
  if settings.global["ltn-stop-default-network"] then
    local default_networkid = settings.global["ltn-stop-default-network"].value
    config.ltn_signals["ltn-network-id"].default = default_networkid
  end
  
  -- populate changes (not needed anymore)
  --ltnc.mod_settings_changed()
end

-- always run
do
  update_settings()
end

--[[ ----------------------------------------------------------------------------------
        HOOK EVENTS 
--]]
script.on_init(mod_init) 
script.on_configuration_changed(mod_configuration_changed)
script.on_event({defines.events.on_runtime_mod_setting_changed}, update_settings) 
script.on_event({defines.events.on_player_created}, mod_player_joined)


--[[ 
        THIS IS THE END  
--]] ----------------------------------------------------------------------------------
