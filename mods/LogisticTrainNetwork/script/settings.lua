--[[ Copyright (c) 2017 Optera
 * Part of Logistics Train Network
 * localizes and converts global runtime settings
 *
 * See LICENSE.md in the project directory for license information.
--]]

local tools = require('script.tools')

---@enum ltn.DepotTrainLimit
ltn_depot_train_limit = {
    reset = 0,
    set_one = 1,
    unchanged = 2,
}

---@class ltn.Settings
---@field message_level integer
---@field debug_log number
---@field message_include_gps boolean
---@field delivery_timeout integer
---@field depot_inactivity integer
---@field dispatcher_enabled boolean
---@field finish_loading boolean
---@field dispatcher_nth_tick integer
---@field min_provided integer
---@field requester_delivery_reset boolean
---@field min_requested integer
---@field schedule_cc boolean
---@field stop_timeout integer
---@field dispatcher_updates_per_tick integer
---@field depot_reset_filters boolean
---@field depot_fluid_cleaning integer
---@field default_network integer
---@field provider_show_existing_cargo boolean
---@field requester_ignores_trains boolean
---@field enable_fuel_stations boolean
---@field use_fuel_station_interrupt boolean
---@field reset_interrupts boolean
---@field reselect_depot boolean
---@field advanced_cross_surface_delivery boolean
---@field depot_fudge_factor integer
---@field depot_limit_trains ltn.DepotTrainLimit
---@diagnostic disable-next-line: missing-fields
LtnSettings = LtnSettings or {}

---@type table<string, fun(settings: ltn.Settings, name: string): boolean?>
local change_settings = {
    ['ltn-interface-console-level'] = function(ltn_settings, name)
        ltn_settings.message_level = tonumber(settings.global[name].value)
        message_level = ltn_settings.message_level -- legacy
    end,
    ['ltn-interface-message-gps'] = function(ltn_settings, name) ltn_settings.message_include_gps = settings.global[name].value end,
    ['ltn-interface-debug-logfile'] = function(ltn_settings, name) ltn_settings.debug_log = settings.global[name].value > 0 and settings.global[name].value or nil end,
    ['ltn-dispatcher-requester-threshold'] = function(ltn_settings, name) ltn_settings.min_requested = settings.global[name].value end,
    ['ltn-dispatcher-provider-threshold'] = function(ltn_settings, name) ltn_settings.min_provided = settings.global[name].value end,
    ['ltn-dispatcher-schedule-circuit-control'] = function(ltn_settings, name) ltn_settings.schedule_cc = settings.global[name].value end,
    ['ltn-dispatcher-depot-inactivity'] = function(ltn_settings, name) ltn_settings.depot_inactivity = settings.global[name].value * 60 end,
    ['ltn-dispatcher-stop-timeout'] = function(ltn_settings, name) ltn_settings.stop_timeout = settings.global[name].value * 60 end,
    ['ltn-dispatcher-delivery-timeout'] = function(ltn_settings, name) ltn_settings.delivery_timeout = settings.global[name].value * 60 end,
    ['ltn-dispatcher-finish-loading'] = function(ltn_settings, name) ltn_settings.finish_loading = settings.global[name].value end,
    ['ltn-dispatcher-requester-delivery-reset'] = function(ltn_settings, name) ltn_settings.requester_delivery_reset = settings.global[name].value end,
    ['ltn-dispatcher-enabled'] = function(ltn_settings, name) ltn_settings.dispatcher_enabled = settings.global[name].value end,
    ['ltn-dispatcher-nth_tick'] = function(ltn_settings, name)
        ltn_settings.dispatcher_nth_tick = settings.global[name].value
        return true
    end,
    ['ltn-dispatcher-updates-per-tick'] = function(ltn_settings, name) ltn_settings.dispatcher_updates_per_tick = settings.global[name].value end,
    ['ltn-depot-reset-filters'] = function(ltn_settings, name) ltn_settings.depot_reset_filters = settings.global[name].value end,
    ['ltn-depot-fluid-cleaning'] = function(ltn_settings, name) ltn_settings.depot_fluid_cleaning = settings.global[name].value end,
    ['ltn-stop-default-network'] = function(ltn_settings, name) ltn_settings.default_network = settings.global[name].value end,
    ['ltn-provider-show-existing-cargo'] = function(ltn_settings, name) ltn_settings.provider_show_existing_cargo = settings.global[name].value end,
    ['ltn-provider-ignore-stopped-train'] = function(ltn_settings, name) ltn_settings.requester_ignores_trains = settings.global[name].value end,

    ['ltn-schedule-fuel-station'] = function(ltn_settings, name) ltn_settings.enable_fuel_stations = settings.global[name].value end,
    ['ltn-fuel-station-interrupt'] = function(ltn_settings, name) ltn_settings.use_fuel_station_interrupt = settings.global[name].value end,
    ['ltn-schedule-reset-interrupts'] = function(ltn_settings, name) ltn_settings.reset_interrupts = settings.global[name].value end,
    ['ltn-schedule-reselect-depot'] = function(ltn_settings, name) ltn_settings.reselect_depot = settings.global[name].value end,
    ['ltn-advanced-cross-surface-delivery'] = function(ltn_settings, name) ltn_settings.advanced_cross_surface_delivery = settings.global[name].value end,
    ['ltn-depot-fudge-factor'] = function(ltn_settings, name) ltn_settings.depot_fudge_factor = settings.global[name].value end,
    ['ltn-depot-stop-limit-trains'] = function(ltn_settings, name) ltn_settings.depot_limit_trains = tonumber(settings.startup[name].value) end,
}

function LtnSettings:init()
    for name in pairs(change_settings) do
        change_settings[name](self, name)
    end
end

function LtnSettings:getUpdatesPerTick()
    return (self.dispatcher_nth_tick == 1) and self.dispatcher_updates_per_tick or 1
end

---@param event EventData.on_runtime_mod_setting_changed
function LtnSettings.on_config_changed(event)
    local name = event.setting
    if event and change_settings[name] then
        local tick_update = change_settings[name](LtnSettings, name) or false
        if tick_update then
            tools.updateDispatchTicker()
        end
    end
end

return LtnSettings
