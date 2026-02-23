require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Events : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.Events
-- replaces script (LuaBootstrap) for all event actions
local Events = {
	__class  = "Events",
	__guid   = "92a52084-19c4-4577-a8c7-714efb79644f",
	__origin = "Kux-CoreLib/lib/Events.lua",
	__writableMembers={"getDisplayName","registerName"}
}
if not KuxCoreLib.__classUtils.ctor(Events) then return self end
---------------------------------------------------------------------------------------------------
if(not script) -- events are only available in control stage
	then KuxCoreLib.__classUtils.finalize(Events) return Events end
---------------------------------------------------------------------------------------------------
--- control stage only ----------------------------------------------------------------------------

local EventDistributor = KuxCoreLib.require.EventDistributor

local function register_names()
	Events.getDisplayName = EventDistributor.getDisplayName or error("Invalid state.")
	Events.registerName   = EventDistributor.registerName or error("Invalid state.")
	KuxCoreLib.__classUtils.finalize(Events)
end

---@param fnc function
---@return boolean
function Events.on_load(fnc) return EventDistributor.register("on_load", fnc) end

---[FOR DEVELOPMENT ONLY] It fires at the first tick after the game was loaded
---@param fnc function
---@return boolean
function Events.on_loaded(fnc) return EventDistributor.register("on_loaded", fnc) end

---@param fnc fun()
---@return boolean
function Events.on_init(fnc) return EventDistributor.register("on_init", fnc) end

---Registers a function to be called on next tick
---@param state object? a custom state object for the event
---@param fnc fun(KuxCoreLib.NextTickEventData)
---@return true
function Events.on_next_tick(state, fnc) return EventDistributor.register_on_next_tick(state, fnc) end

---@param fnc fun(e: ConfigurationChangedData)
---@return boolean
function Events.on_configuration_changed(fnc) return EventDistributor.register("on_configuration_changed", fnc) end

---@param fnc fun(e: EventData.on_runtime_mod_setting_changed)
---@return boolean
function Events.on_runtime_mod_setting_changed(fnc) return EventDistributor.register("on_runtime_mod_setting_changed", fnc) end

---@param event integer|string|defines.events|table event
---@param fnc function
---@param filters EventFilter?
---@return boolean
function Events.on_event(event, fnc, filters) return EventDistributor.register(event, fnc, filters) end

---@param fnc fun(e: EventData.on_tick)
---@return boolean
function Events.on_tick(fnc) return EventDistributor.register(defines.events.on_tick, fnc) end

---@param tick uint
---@param fnc fun(e: NthTickEventData)
---@return boolean
function Events.on_nth_tick(tick, fnc) return EventDistributor.register_nth_tick(tick, fnc) end

---Called when player builds something. see also `Events.on_built`
---@param fnc fun(e: EventData.on_built_entity)
---@return boolean
---@seealso Events.on_built
function Events.on_built_entity(fnc) return EventDistributor.register(defines.events.on_built_entity, fnc) end

---@param fnc fun(e: EventData.on_player_cursor_stack_changed)
---@return boolean
function Events.on_player_cursor_stack_changed(fnc) return EventDistributor.register(defines.events.on_player_cursor_stack_changed, fnc) end

---[EXPERIMENTAL]
---@param tick uint
---@param fnc function
---@return boolean
function Events.on_timer(tick, fnc) return EventDistributor.register_on_timer(tick, fnc) end

---[EXPERIMENTAL] on_built_entity, on_robot_built_entity, script_raised_built, script_raised_revive
---@param fnc function
---@param filters EventFilter?
---@return boolean
function Events.on_built(fnc, filters) return EventDistributor.register("on_built", fnc, filters) end

---[EXPERIMENTAL] on_pre_player_mined_item, on_robot_pre_mined, on_entity_died, script_raised_destroy
---@param fnc function
---@param filters EventFilter?
---@return boolean
function Events.on_destroy(fnc, filters) return EventDistributor.register("on_destroy", fnc, filters) end

---[EXPERIMENTAL] on_entity_moved (using PickerDollies)
---@param fnc fun(e: KuxCoreLib.on_entity_moved)
---@param filters EventFilter? [Not Implemented]
---@return boolean
function Events.on_entity_moved(fnc, filters) return EventDistributor.register("on_entity_moved", fnc, filters) end

---Registeres an custom event
---@param input_name string
---@param fnc fun(e: EventData.CustomInputEvent)
---@return unknown
function Events.on_custom_input(input_name, fnc) return EventDistributor.register(input_name, fnc) end

---------------------------------------------------------------------------------------------------
-- wait für dependencies initialialized
EventDistributor.__on_initialized(register_names) -- will also finalize this class
---------------------------------------------------------------------------------------------------
--wo are not yet done! (X) KuxCoreLib.__classUtils.finalize(Events)
return Events