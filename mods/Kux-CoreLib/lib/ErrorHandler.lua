require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---DRAFT Provides ErrorHandler functions
---@class KuxCoreLib.ErrorHandler : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.ErrorHandler
local ErrorHandler = {
	__class  = "ErrorHandler",
	__guid   = "236d7a73-2be3-4cc8-81a4-c5c08e91bff9",
	__origin = "Kux-CoreLib/lib/ErrorHandler.lua",

	__isInitialized = false,
	__on_initialized = {}
}
if not KuxCoreLib.__classUtils.ctor(ErrorHandler) then return self end
---------------------------------------------------------------------------------------------------
local Events = KuxCoreLib.Events
local EventDistributor = KuxCoreLib.EventDistributor
local ModInfo = KuxCoreLib.ModInfo
local loc = "KuxCoreLib.ErrorHandler."

---@class KuxCoreLib.ErrorHandler.Storage
---@field events {[string]:boolean} Dictionary of event name -> is registered

---Returns the persistent storage for the ErrorHandler
---@return KuxCoreLib.ErrorHandler.Storage
local function thisStorage()
	if(ModInfo.current_stage == "control-on-load") then
		--we must not change 'storage' (formerly 'global')!
		local temp = table.deepcopy(storage.ErrorHandler) or {}
		temp.events = temp.events or {}
		return temp
	end
	storage.ErrorHandler = storage.ErrorHandler or {}
	storage.ErrorHandler.events = storage.ErrorHandler.events or {}
	return storage.ErrorHandler
end

local function on_error_report_close_clicked(e)
	if(not e.element or e.element.name~="KuxCoreLib.ErrorHandler.error-report.close") then return end
	local player = game.players[e.player_index]
	player.gui.screen.KuxCoreLib_error_report_messagebox.destroy()
	EventDistributor.unregister(defines.events.on_gui_click, on_error_report_close_clicked)
	storage.ErrorHandler.events.on_error_report_close_clicked = nil

	game.show_message_dialog{text={loc.."player-message-error-report-closed"}}
end

local function showErrorReport(player, message, url)
	--TODO: not for multiplayer
	--game.show_message_dialog{text=message,
	-- style?=…, wrapper_frame_style?=
	local g = player.gui.screen.KuxCoreLib_error_report_messagebox
	if(g) then g.destroy() end

	local frame = player.gui.screen.add {
		type = "frame",
		name = "KuxCoreLib_error_report_messagebox",
		caption =  {loc.."error-report-caption"},
		direction = "vertical"
	}

	local textbox = frame.add {
		type = "text-box",
		text = message,
		style = "textbox"
	}
	textbox.style.width = 500
	textbox.style.height = 400

	local prompt = frame.add {
		type = "label",
		caption = {loc.."error-report-prompt"},
	}
	prompt.style.single_line = false
	prompt.style.width = 500

	local textbox = frame.add {
		type = "text-box",
		text = url,
		style = "textbox"
	}
	textbox.style.width = 500

	local confirm_button = frame.add {
		type = "button",
		name="KuxCoreLib.ErrorHandler.error-report.close",
		caption = {loc.."error-report-close"}
	}
	confirm_button.style.minimal_width = 100

	Events.on_event(defines.events.on_gui_click, on_error_report_close_clicked)
	thisStorage().events.on_error_report_close_clicked = true
end

---@class ErrorHandler.createReport.args
---@field player_index uint?
---@field mod string? The current mod name
---@field point_to MapPosition?

---Creates a report for the given error
---@param evt EventData|CustomInputEvent|nil
---@param err any
---@param args ErrorHandler.createReport.args?
function ErrorHandler.createReport(evt, err, args)
	local traceback = debug.traceback(err,2)
	xpcall(function ()
		args = args or {}
		if(not args.mod) then args.mod = ModInfo.entryMod end
		local player_index = args.player_index or evt and evt["player_index"]
		local player = game.players[player_index or 1] --TODO: find active admin
		if(player.gui.screen.KuxCoreLib_error_report_messagebox) then return end --dialog is already open
		if(not game.is_multiplayer()) then
			game.show_message_dialog{text={loc.."player-message-error"}, point_to = args.point_to}
		end
		if(player) then
			showErrorReport(player,
				traceback .. "\n" ..
				"----------------------------------------\n" ..
				args.mod.." v".. mods[args.mod].."\n" ..
				"Kux-CoreLib".." v".. mods["Kux-CoreLib"] .."\n" ..
				"----------------------------------------\n" ..
				"Steps to repoduce:\n" ..
				"...describe which steps you have done before...",
				"https://mods.factorio.com/mod/"..args.mod.."/discussion"
			)
		end
	end,function(err2)
		log(err2)
	end)
end

local function on_load()
	if(thisStorage().events.on_error_report_close_clicked) then
		Events.on_event(defines.events.on_gui_click, on_error_report_close_clicked)
	end
end

local function on_loaded()
	--test
	-- xpcall(
	-- 	function ()
	-- 		error("only a test")
	-- 	end,
	-- 	function(err)
	-- 		log("ERROR:"..err.."\n"..debug.traceback(err, 2))
	-- 		ErrorHandler.createReport(nil,err, {mod=mod.name})
	-- 	end
	-- )
end

local function on_events_initialized()
	if(ModInfo.current_stage ~= "control") then return end
	Events.on_load(on_load)
	Events.on_loaded(on_loaded)
end

if(Events.__isInitialized) then on_events_initialized()
else table.insert(Events.__on_initialized, on_events_initialized)
end
---------------------------------------------------------------------------------------------------

---Provides ErrorHandler in the global namespace
---@return KuxCoreLib.ErrorHandler
function ErrorHandler.asGlobal() return KuxCoreLib.__classUtils.asGlobal(ErrorHandler) end

ErrorHandler.__isInitialized = true
for _, fnc in ipairs(ErrorHandler.__on_initialized) do fnc() end

return ErrorHandler