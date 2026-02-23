require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

--[[
	Usage:
	[control.lua]
	require "ModulA"

	[ModuleA.lua]
	local EventDistributor = require("__Kux-CoreLib__/lib/EventDistributor")
	local function handler(evt) ... end
	EventDistributor.register(80, handler)
	EventDistributor.register("on_init", handler)
]]
---@class KuxCoreLib.EventDistributor : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.EventDistributor Provides EventDistributor in the global namespace
local EventDistributor = {
	__class  = "KuxCoreLib.EventDistributor",
	__guid   = "{ADD81DB1-53B9-4D61-9279-401AD277DBEE}",
	__origin = "Kux-CoreLib/lib/EventDistributor.lua",
}
if not KuxCoreLib.__classUtils.ctor(EventDistributor) then return self end
---------------------------------------------------------------------------------------------------

local util = {}


if(KuxCoreLib.ModInfo.current_stage ~= "control") then
	KuxCoreLib.__classUtils.finalize(EventDistributor)
	return EventDistributor
end -- events are only available in control stage

-- to avoid circular references, the class MUST be defined before require other modules
KuxCoreLib.lua.asGlobal()
local Table         = KuxCoreLib.require.Table
local List          = KuxCoreLib.require.List
local ModInfo       = KuxCoreLib.require.ModInfo
local StringBuilder = KuxCoreLib.require.StringBuilder
local Storage       = KuxCoreLib.require.Storage
local PickerDollies = KuxCoreLib.require.PickerDollies ---@see KuxCoreLib.PickerDollies

---Dictionary of EventId|EventName, table of function
local events={}

local isOnLoadedRaised = false

---Gets the LuaPlayer for the current event. Managed by KuxCoreLib.EventDistributor. Can be `nil`.
---@type LuaPlayer
_G.player = _G.player

local mapEventNumberToName = {}
for name, value in pairs(defines.events) do mapEventNumberToName[value] = name end

---Get name and id of an event
---@param eventIdentifier any
---@return string
---@return uint
local function eventPair (eventIdentifier)
	::start::
	local eventName = nil
	local eventId = nil --[[@as defines.events?]]
	local eventType = type(eventIdentifier)
	if eventType == "number" then
		eventName = mapEventNumberToName[eventIdentifier]
		eventId = eventIdentifier
	elseif eventType == "string" then
		eventName = eventIdentifier
		eventId = defines.events[eventIdentifier] --[[@as defines.events]]
		--if eventId==nil then eventId = 0 end -- "on_init" "on_load" "on_configuration_changed", o.a.
	elseif eventType == "table" then
		eventIdentifier = eventIdentifier.name
		eventType = type(eventIdentifier)
		if eventType == "number" then
			eventName = mapEventNumberToName[eventIdentifier]
			eventId = eventIdentifier
		elseif eventType == "string" then
			eventName = eventIdentifier
			eventId = defines.events[eventIdentifier]--[[@as defines.events]]
		end
	end
	return eventName, eventId
end

---Registers an custom event name with its id
---@param id integer number of the custom event
---@param name string name of the custom event
function EventDistributor.registerName(id,name)
	mapEventNumberToName[id]=name
end

local function getDisplayName(event)
	local eventName, eventId = eventPair(event)
	if(not eventId or eventId<0) then
		return eventName or "unknown"
	else
		return (eventName or "custom").."(ID "..tostring(eventId)..")"
	end
end

EventDistributor.getDisplayName=getDisplayName

--#region event handlers

local function on_init()
	--print("EventDistributor.on_init")
	local handlers = events["on_init"]
	for _,fnc in pairs(handlers or {}) do fnc() end

	 -- we set the state in advance, the state is valid on next tick
	ModInfo.isModLoaded = true
	ModInfo.current_stage = "control-on-loaded"
	Storage.canRead = true
	Storage.canWrite = true
end

local function on_load()
	--print("EventDistributor.on_load")
	local handlers = events["on_load"]
	for _,fnc in pairs(handlers or {}) do fnc() end

	if(settings.global["Kux-CoreLib_".."on_load_LogEvents_Summary"].value) then
		util.log_summary()
	end

	 -- we set the state in advance, the state is valid on next tick
	 ModInfo.isModLoaded = true
	 ModInfo.current_stage = "control-on-loaded"
	 Storage.canRead = true
	 Storage.canWrite = true
end

local function on_configuration_changed(e)
	ModInfo.current_stage = "control-on-configuration-changed"

	--print("EventDistributor.on_configuration_changed")
	local handlers = events["on_configuration_changed"]
	for _,fnc in pairs(handlers or {}) do fnc(e) end

	 -- we set the state in advance, the state is valid on next tick
	 ModInfo.current_stage = "control-on-loaded"
end

---
local function on_nth_tick(e)
	--print("EventDistributor.on_nth_tick "..e.nth_tick)
	local handlers = events["on_nth_tick"][e.nth_tick]
	for _,fnc in pairs(handlers or {}) do fnc(e) end
end


---
local function on_event(e)
	--log("on_event "..getDisplayName(e))
	local restore = _G.player
	_G.player = EventDistributor.getPlayerFnc(e) or _G.player
	local safe = _G.player
	if e.player_index~=nil and not _G.player then error("invalid state") end
	local eventName, eventId = eventPair(e.name)
	local key = eventId or eventName
	local handlers = events[key]
	for _,fnc in pairs(handlers or {}) do
		fnc(e)
		if _G.player ~= safe then
			local i = debug.getinfo(fnc, "Sl")
			error("invalid (global) player change detetcted.\n\tin "..i.short_src..":"..i.linedefined)
		end
	end
	_G.player = restore
end

---
local function on_event_customInput(e)
	--log("on_event_customInput "..getDisplayName(e))
	local restore = _G.player
	_G.player = EventDistributor.getPlayerFnc(e)
	local name, number = eventPair(e)
	local handlers = events[name]
	for _,fnc in pairs(handlers or {}) do fnc(e) end
	_G.player = restore
end

---
local function on_loaded(e)
	--print("on_loaded")
	if(isOnLoadedRaised) then return end

	EventDistributor.unregister_on_nth_tick(e.nth_tick, on_loaded)

	local handlers = events.on_loaded
	if(handlers) then
		for _,fnc in pairs(handlers) do fnc(e) end
	end

	--print("set isLoadRaised=true")
	isOnLoadedRaised = true
	events["on_loaded"] = {}
end

---
local function on_built(e)
	--print("EventDistributor.on_built")
	local restore = _G.player
	_G.player = EventDistributor.getPlayerFnc(e) or _G.player
	local handlers = events["on_built"]
	if(not handlers) then return end
	for _,fnc in pairs(handlers) do fnc(e) end
	_G.player = restore
end

---
local function on_destroy(e)
	--print("EventDistributor.on_destroy")
	local restore = _G.player
	_G.player = EventDistributor.getPlayerFnc(e) or _G.player
	if     e.name == defines.events.on_robot_pre_mined then return
	elseif e.name == defines.events.on_pre_player_mined_item then return
	elseif e.name == defines.events.on_space_platform_pre_mined then return
	end

	local handlers = events["on_destroy"]
	if(not handlers) then return end
	for _,fnc in pairs(handlers) do fnc(e) end
	_G.player = restore
end

---@param e NthTickEventData
local function on_timer(e)
	local handlers = events["on_timer"][e.tick]
	if(handlers) then
		for _,fnc in pairs(handlers) do fnc(e) end
		events["on_timer"][e.tick] = nil
		if(Table.count(events["on_timer"]) == 0) then
			EventDistributor.unregister_on_nth_tick(1, on_timer)
		end
	end
end

---@class KuxCoreLib.on_entity_moved : PickerDollies.dolly_moved_entity
---@field name string name of the event "on_entity_moved"
---@field tick uint the tick the event was raised
---@field entity LuaEntity the entity that was moved
---@field start_postion MapPosition the position the entity was moved from

---@param e PickerDollies.dolly_moved_entity
local function on_entity_moved(e)
	local restore = _G.player
	_G.player = EventDistributor.getPlayerFnc(e) or _G.player
	local handlers = events["on_entity_moved"]
	if not handlers then return end
	local e1 = e ---@cast e1 KuxCoreLib.on_entity_moved
	-- we leave the dolly_moved_entity fields intact and add the on_entity_moved fields
	e1.name = "on_entity_moved"
	e1.entity = e.moved_entity
	e1.start_postion = e.start_pos

	for _,fnc in pairs(handlers) do fnc(e1) end
	_G.player = restore
end

--#endregion event handlers

local function check_customInput(name)
	if(prototypes.custom_input[name]) then return end
	error("CustomInput does not exist. Name:'"..tostring(name).."'")
end

---Registers an event in script
---@param eventIdentifier integer|uint|string|defines.events
---@param param any ticks | filter
local function script_register(eventIdentifier, param)
	--log("register: "..getDisplayName(eventIdentifier))
	local eventName, eventId = eventPair(eventIdentifier)
	if    (eventName=="on_init"                 ) then script[eventName](on_init)
	elseif(eventName=="on_load"                 ) then script[eventName](on_load)
	elseif(eventName=="on_configuration_changed") then script[eventName](on_configuration_changed)
	elseif(eventName=="on_nth_tick"             ) then script.on_nth_tick(param,  on_nth_tick)
	elseif(eventId and eventId >= 0             ) then script.on_event(eventId,   on_event, param)
	else   --[[check_customInput(eventName); ]]        script.on_event(eventName, on_event_customInput)
	end
	-- can't use check_customInput, because 'game' is not yet available
end

---Unregisters an event in script
---@param eventIdentifier uint|string
---@param ticks uint|nil only required for on_nth_tick
local function unregister(eventIdentifier, ticks)
	if(game.is_multiplayer()) then return end
	--log("unregister: "..getDisplayName(eventIdentifier)..iif(ticks~=nil," ticks="..ticks,""))
	local eventName, eventId = eventPair(eventIdentifier)
	if    (eventName=="on_init"                 ) then script[eventName](nil)
	elseif(eventName=="on_load"                 ) then script[eventName](nil)
	elseif(eventName=="on_configuration_changed") then script[eventName](nil)
	elseif(eventName=="on_nth_tick"             ) then script.on_nth_tick(ticks, nil)
	elseif(eventId and eventId >= 0             ) then script.on_event(eventId, nil)
	else error("Unknown event: "..getDisplayName(eventIdentifier))
	end
end

---Unregisters an event
---@param eventIdentifier integer|uint|string|defines.events
---@param fnc function
function EventDistributor.unregister(eventIdentifier, fnc)
	assert(fnc~=nil, "Invalid Argument. 'fnc' must not be nil!")
	local eventName, eventId = eventPair(eventIdentifier)
	local key = eventId or eventName
	Table.remove(events[key], fnc)
	if(not events[key] or #events[key]>0) then return end
	if(eventName=="on_built") then
		EventDistributor.unregister(defines.events.on_built_entity,                 on_built)
		EventDistributor.unregister(defines.events.on_robot_built_entity,           on_built)
		EventDistributor.unregister(defines.events.script_raised_built,             on_built)
		EventDistributor.unregister(defines.events.script_raised_revive,            on_built)
		EventDistributor.unregister(defines.events.on_space_platform_built_entity,  on_built)
	elseif(eventName=="on_destroy") then
		EventDistributor.unregister(defines.events.on_pre_player_mined_item,        on_destroy)
		EventDistributor.unregister(defines.events.on_robot_pre_mined,              on_destroy)
		EventDistributor.unregister(defines.events.on_entity_died,                  on_destroy)
		EventDistributor.unregister(defines.events.script_raised_destroy,           on_destroy)
		EventDistributor.unregister(defines.events.on_space_platform_mined_entity,  on_destroy)
	elseif(eventName=="on_entity_moved") then
		error("Not implemented")
		--TODO PickerDollies.unregister()
	else
		unregister(key)
	end
end

local function register_artifical_event(key, fnc)
	if(List.isNilOrEmpty(events[key])) then
		events[key] = {fnc}
		--if(eventName ~= "on_loaded") then register(eventIdentifier, param) end
	else
		if(Table.contains(events[key], fnc)) then
			error("Multiple registration of same event is not supported. name: '"..key.."'")
			--TODO: allow reregister the event
			return false
		end
		table.insert(events[key], fnc)
	end
end

---Registers an event
---@param eventIdentifier integer|uint|string|defines.events|table
---@param fnc function
---@param arg any Optional parameter, depends on eventIdentifier (filter)
---@return boolean #true if succesfully registered else false
function EventDistributor.register (eventIdentifier, fnc, arg)
	assert(eventIdentifier~=nil,  "Invalid Argument. 'eventIdentifier' must not be nil.")
	assert(fnc~=nil,              "Invalid Argument. 'fnc' must not be nil.")
	assert(type(fnc)=="function", "Invalid Argument. 'fnc' must be a function.")

	if(type(eventIdentifier)=="table") then
		for _, ei in ipairs(eventIdentifier) do
			EventDistributor.register(ei, fnc, arg)
		end
		return true
	end
	--print("EventDistributor.register "..getDisplayName(eventIdentifier))

	local eventName, eventId = eventPair(eventIdentifier)
	local key = eventId or eventName
	if    (eventName=="nth_tick"  ) then error("Argument out of range. name: eventIdentifier, value: "..eventIdentifier)
	elseif(eventName=="on_loaded" ) then EventDistributor.register_nth_tick(1, on_loaded)
	elseif(eventName=="on_next_tick" ) then EventDistributor.register_on_next_tick(arg, fnc)
	elseif(eventName=="on_timer"  ) then error("Argument out of range. name: eventIdentifier, value: "..eventIdentifier)
	elseif(eventName=="on_built"  ) then EventDistributor.register_on_built(arg, fnc); return true
	elseif(eventName=="on_destroy") then EventDistributor.register_on_destroy(arg, fnc); return true
	elseif(eventName=="on_entity_moved") then EventDistributor.register_on_entity_moved(fnc, arg) return true
	end
	if(List.isNilOrEmpty(events[key])) then
		events[key] = {fnc}
		if(eventName ~= "on_loaded") then script_register(eventIdentifier, arg) end
	else
		if(Table.contains(events[key], fnc)) then return false end
		table.insert(events[key], fnc)
	end
	return true
end

---Registers an on_nth_tick event
---@param ticks uint
---@param fnc function
---@return boolean #true if succesfully registered else false
function EventDistributor.register_nth_tick(ticks, fnc)
	--print("EventDistributor.register "..getDisplayName("on_nth_tick"))
	assert(type(fnc)=="function", "Invalid Argument. 'fnc' must be a function.")
	if not events["on_nth_tick"] then events["on_nth_tick"] = {} end
	if (List.isNilOrEmpty(events["on_nth_tick"][ticks])) then
		events["on_nth_tick"][ticks] = {fnc}
		script_register("on_nth_tick",ticks)
	else
		if(Table.contains(events["on_nth_tick"][ticks], fnc))  then return false end
		table.insert(events["on_nth_tick"][ticks], fnc)
	end
	return true
end

---Registers an on_nth_tick event
---@param ticks uint
---@param fnc function
function EventDistributor.unregister_on_nth_tick(ticks, fnc)
	--print("EventDistributor.unregister_on_nth_tick "..tick)
	assert(type(fnc)=="function", "Invalid Argument. 'fnc' must be a function.")
	Table.remove(events["on_nth_tick"][ticks], fnc)
	if(#events["on_nth_tick"][ticks]>0) then return end
	unregister("on_nth_tick",ticks)
end

---Registers an on_timer
---@param tick uint the number of ticks after the event is raised.
---@param fnc function
---@return boolean #true if succesfully registered else false
function EventDistributor.register_on_timer(tick, fnc)
	assert(type(tick)=="number", "Invalid Argument. 'tick' must be a integer.")
	assert(type(fnc)=="function", "Invalid Argument. 'fnc' must be a function.")
	tick = tick + game.tick
	if not events["on_timer"] then events["on_timer"] = {} end
	if (List.isNilOrEmpty(events["on_timer"][tick])) then
		events["on_timer"][tick] = {fnc}
		EventDistributor.register_nth_tick(1, on_timer)
	else
		if(Table.contains(events["on_timer"][tick], fnc)) then return false end
		table.insert(events["on_timer"][tick], fnc)
	end
	return true
end

---@type {[uint]:{fnc:function,state:any}[]}
local next_tick_registrations = {}


---@class KuxCoreLib.NextTickEventData
---@field tick uint 32 bit unsigned integer. Ranges from 0 to 4 294 967 295, or [0, 2^32-1] <br/>The tick during which the event happened.
---@field name "on_next_tick"
---@field state object? custom event data

---distributes the on_next_tick events
---@param e NthTickEventData
local function on_next_tick(e)
	local reg = next_tick_registrations[e.tick]
	if not reg then return end
	for _, d in ipairs(reg) do
		local arg = {
			tick = e.tick,
			name = "on_next_tick",
			state = d.state
		}
		d.fnc(arg) -- raise --TODO use pcal?
	end
	next_tick_registrations[e.tick] = nil
end

---Registers a function to be called on next tick
---@param state object? a custom state object for the event
---@param fnc fun(KuxCoreLib.NextTickEventData)
---@return true
function EventDistributor.register_on_next_tick(state, fnc)
	next_tick_registrations[game.tick+1] = next_tick_registrations[game.tick+1] or {}
	table.insert(next_tick_registrations[game.tick+1],{fnc=fnc,state=state})
	EventDistributor.register_nth_tick(1, on_next_tick)
	return true
end

function EventDistributor.register_on_built(item_filter, fnc)
	register_artifical_event("on_built", fnc)

	--TODO: join item_filter. at the moment only the first resgistration works!

	--on_pre_build
    EventDistributor.register(defines.events.on_built_entity,       on_built, item_filter)
    EventDistributor.register(defines.events.on_robot_built_entity, on_built, item_filter)
    EventDistributor.register(defines.events.script_raised_built,   on_built, item_filter)
    EventDistributor.register(defines.events.script_raised_revive,  on_built, item_filter)
	EventDistributor.register(defines.events.on_space_platform_built_entity,  on_built, item_filter) -- new in Factorio 2.0
end

function EventDistributor.register_on_destroy(item_filter, fnc)
	register_artifical_event("on_destroy", fnc)

	--TODO: join item_filter. at the moment only the first resgistration works!

	--internal only, not distributed:
	EventDistributor.register(defines.events.on_pre_player_mined_item,       on_destroy, item_filter)
	EventDistributor.register(defines.events.on_robot_pre_mined,             on_destroy, item_filter)
	EventDistributor.register(defines.events.on_space_platform_pre_mined,    on_destroy, item_filter) -- new in Factorio 2.0
	--EventDistributor.register(defines.events.on_robot_mined,                 on_destroy, nil)

	--distributed: (this are all event where the entity is yet valid)
	EventDistributor.register(defines.events.on_player_mined_entity,         on_destroy, item_filter)
	EventDistributor.register(defines.events.on_robot_mined_entity,          on_destroy, item_filter)
	EventDistributor.register(defines.events.on_entity_died,                 on_destroy, item_filter)
	EventDistributor.register(defines.events.script_raised_destroy,          on_destroy, item_filter)
	EventDistributor.register(defines.events.on_space_platform_mined_entity, on_destroy, item_filter) -- new in Factorio 2.0

	--on_post_entity_died?
end

function EventDistributor.unregister_on_built(fnc)
	EventDistributor.unregister("on_built", fnc)
end

function EventDistributor.unregister_on_destroy(fnc)
	EventDistributor.unregister("on_destroy", fnc)
end

---DRAFT ONLY
function EventDistributor.register_with_filter(eventIdentifier, filter, fnc)
	local eventName, eventId = eventPair(eventIdentifier)
	if(eventId ~= nil and eventId>0) then
		local currentFilters = script.get_event_filter(eventId) --[[@as table]]
		if(currentFilters==nil) then
			EventDistributor.register(eventIdentifier,fnc,filter)
			return
		elseif(#filter>0) then
			for _,f in ipairs(filter) do
				table.insert(currentFilters,f)
			end
		else
			table.insert(currentFilters,filter)
		end
		script.set_event_filter(eventId, currentFilters)
	end
end

function EventDistributor.register_on_entity_moved(fnc, filter)
	--[[TRACE]]trace("EventDistributor.register_on_entity_moved")
	register_artifical_event("on_entity_moved", fnc)
	PickerDollies.initialize(on_entity_moved, filter)
	if(ModInfo.current_stage=="control") then
		--we can not register the event yet, because we need the event Id from PickerDollies and this can only be retrieved when an event occurs.
		EventDistributor.register("on_load", PickerDollies.initialize)
		EventDistributor.register("on_init", PickerDollies.initialize)
	end
end

---@type fun(event:table):LuaPlayer?
EventDistributor.getPlayerFnc = function(e)
	if not e then return nil end
	if(e.player_index) then return game.players[e.player_index] end
	return nil
end

function util.log_summary()
	local sb = StringBuilder:new()
	sb:appendLine(ModInfo.name.." registered events:")
	for key, v1 in pairs(events) do
		if(Table.isNilOrEmpty(v1)) then goto next end
		if(key=="on_nth_tick") then
			sb:appendLine("  " .. getDisplayName(key))
			for k2, v2 in pairs(v1) do
				if(not Table.isNilOrEmpty(v2)) then sb:appendLine("    " ..k2) end
				for _, v3 in ipairs(v2) do
					sb:appendLine("      " .. debug.getinfo(v3,"S").short_src)
				end
			end
		else
			sb:appendLine("  " .. getDisplayName(key))
			for _, v3 in ipairs(v1) do
				sb:appendLine("      " .. debug.getinfo(v3,"S").short_src)
			end
		end
		::next::
	end
	log(sb:toString())
end

local function internal_on_init()
	ModInfo.current_stage="control-on-init"
end

local function internal_on_load()
	ModInfo.current_stage="control-on-load"
end

local function internal_on_configuration_changed()
	ModInfo.current_stage="control-on-configuration-changed"
end

local function internal_on_loaded(e)
	ModInfo.current_stage="control-on-loaded"

	-- if(game.players[e.player_index].mod_settings["Kux-CoreLib_".."on_loaded_LogEvents_StartUpSummary"].value) then
	-- end
end

EventDistributor.register("on_init", internal_on_init)
EventDistributor.register("on_load", internal_on_load)
EventDistributor.register("on_loaded", internal_on_loaded)
EventDistributor.register("on_configuration_changed", internal_on_configuration_changed)

---------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(EventDistributor)
return EventDistributor