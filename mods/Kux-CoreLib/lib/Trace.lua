require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides trace functions
---@class KuxCoreLib.Trace : KuxCoreLib.Class
---@field public prefix_sign string
---@field public sign_color Color
---@field public text_color Color
---@field public background_color Color
---@field asGlobal fun():KuxCoreLib.Trace Provides Trace in the global namespace
--[[
	Usage: <br>
	  `Trace.write(...)` or short `Trace(...)` <br>
	  `Trace.append(...)` <br><br>
	Format Usage: <br>
	  ```
	  _G.trace = KuxCoreLib.Trace
	  trace.sign_color = trace.colors.blue
	  trace.text_color = trace.colors.lightblue
	  trace.background_color = trace.colors.gray_32
	  ```
--]]
local Trace = {
	__class  = "Trace",
	__guid   = "d37816ef-cba2-46af-8c46-56be0fd02322",
	__origin = "Kux-CoreLib/lib/Trace.lua",

	prefix_sign = "○",
	sign_color = {192,192,192},--lightgray
	text_color= {192,192,192},--lightgray
	background_color = {0,0,0},--black
	isEnabled = false,

	---@type KuxCoreLib.Trace.Colors
	colors = {
		black = {0,0,0},
		red = {255,0,0},
		green = {0,255,0},
		blue = {0,0,255},
		yellow = {255,255,0},
		white = {255,255,255},
		gray = {128,128,128},
		orange = {255,128,0},
		purple = {128,0,255},
		brown = {128,64,0},
		pink = {255,0,255},
		cyan = {0,255,255},
		olive = {128,128,0},
		teal = {0,128,128},
		navy = {0,0,128},
		darkred = {128,0,0},
		darkgreen = {0,128,0},
		darkblue = {0,0,128}, --same as navy
		darkyellow = {128,128,0},
		darkgray = {64,64,64},
		darkorange = {128,64,0}, -- same as brown
		darkpurple = {64,0,128},
		darkbrown = {64,32,0},
		darkpink = {128,0,128},
		darkcyan = {0,128,128},
		darkolive = {64,64,0},
		darkteal = {0,64,64},
		darknavy = {0,0,64},
		lightgray = {192,192,192},
		lightred = {255,192,192},
		lightgreen = {192,255,192},
		lightblue = {192,192,255},
		lightyellow = {255,255,192},
		lightorange = {255,224,192},
		lightpurple = {192,192,255},
		lightbrown = {192,160,128},
		lightpink = {255,192,255},
		lightcyan = {192,255,255},
		lightolive = {192,192,128},
		lightteal = {192,255,255},
		lightnavy = {192,192,255},
		gray_16 ={16,16,16},
		gray_32 ={32,32,32},
	},
	signs = {
		"●", -- error
		"○",
		"■",
		"□",
		"▲", -- warning
		"△",
		"▼",
		"▽",
		"◆",
		"◇",
		"◈",
		"◉",
		"◊",
		"○",
		"◌",
		"◍",
		"◎",
		"●",
		"◐",
		"◑",
		"◒",
		"◓",
		"◔",
		"◕",
		"◖",
		"◗",
		"◘",
		"◙",
		"◚",
		"◛",
		"◜",
		"◝",
		"◞",
		"◟",
		"◠",
		"◡",
		"◢",
		"◣",
		"◤",
		"◥",
		"◦",
		"◧",
		"◨",
		"◩",
		"◪",
		"◫",
		"◬",
		"◭",
		"◮",
		"◯",
		"◰",
		"◱",
		"◲",
		"◳",
		"◴",
		"◵",
		"◶",
		"◷",
		"◸",
		"◹",
		"◺",
		"◻",
		"◼",
		"◽",
		"◾",
		"◿",
		"☀",
		"☁",
		"☂",
		"☃",
		"☄",
		"★",
		"☆",
		"☇",
		"☈",
		"☉",
		"☊",
		"☋",
		"☌",
		"☍",
		"☎",
		"☏",
		"☐",
		"☑",
		"🛠️",
	},
}
if not KuxCoreLib.__classUtils.ctor(Trace) then return self end
---------------------------------------------------------------------------------------------------
local Table = KuxCoreLib.Table

function Trace.__setGlobals()
	_G.trace = Trace
	_G.__trace = Trace
end

local function setMetatable()
	setmetatable(Trace, {
		__call = function(_, ...) return Trace.write(...) end,
		__index = function(self, key)
			if KuxCoreLib.__classUtils.isReadable(self, key) then return nil end
			error("Invalid Operation. '"..(key or "<nil>").."' is not a member of 'Trace'")
			end,
		__newindex = function(self, key, value)
			if KuxCoreLib.__classUtils.isWritable(self, key) then rawset(Trace, key, value) return end
			error("Invalid Operation. 'Trace' is protected. Member: "..tostring(key).." does not exist.")
			end,
		__metatable = "protected"
	})
end

---------------------------------------------------------------------------------------------------

local function timestamp()
	local ticks = (game or {}).tick or 0
    local ticks_per_second = 60 -- Ticks pro Sekunde
    local total_seconds = ticks / ticks_per_second
    local days = math.floor(total_seconds / 86400) -- Eine Sekunde pro Tag
    local hours = math.floor((total_seconds % 86400) / 3600) -- Eine Stunde pro Tag
    local minutes = math.floor((total_seconds % 3600) / 60)
    local seconds = math.floor(total_seconds % 60)
    local milliseconds = math.floor((total_seconds * 1000) % 1000)
    return string.format("%d,%02d:%02d:%02d.%03d", days, hours, minutes, seconds, milliseconds)
end

local function set_text_color(color)
	local rot, gruen, blau = color.r or color[1], color.g or color[2], color.b or color[3]

	-- Prüfen, ob die Farben gültig si
	if type(rot) ~= "number" or rot < 0 or rot > 255 then
	  print("Ungültige Farbe: " .. rot)
	  return
	end

	if type(gruen) ~= "number" or gruen < 0 or gruen > 255 then
	  print("Ungültige Farbe: " .. gruen)
	  return
	end

	if type(blau) ~= "number" or blau < 0 or blau > 255 then
	  print("Ungültige Farbe: " .. blau)
	  return
	end

	--normalize 0..1 to 0..255
	--0,0,1 ist not very dark blue, but blue 0,0,255
	--1,1,1 ist not very dark gray, but white 255,255,255
	if(rot<=1 and gruen<=1 and blau<=1) then
		rot   = rot   * 255
		gruen = gruen * 255
		blau  = blau  * 255
	end

	-- Escape-Sequenz für die Vordergrundfarbe generieren
	--local farbe_code = string.format("\033[38;2;%d;%d;%dm", math.floor(rot / 255 * 5), math.floor(gruen / 255 * 5), math.floor(blau / 255 * 5))
  	local farbe_code = string.format("\27[38;2;%d;%d;%dm", math.floor(rot), math.floor(gruen), math.floor(blau))

	-- Text ausgeben
	--print(farbe_code .. "Hallo Welt!" .. "\033[0m")
	return farbe_code
end

local function set_background_color(color) return set_text_color(color):gsub("\27%[38;2","\27[48;2") end

local function reset_color()
	return "\27[0m"
end
local function reset_background_color()
	return "\27[49m"
end

local function reset_foregound_color()
	return "\27[39m"
end

local function colortext(text, color) return set_text_color(color)..text..reset_foregound_color() end

local function colorbackground(text, color) return set_background_color(color)..text..reset_background_color() end

Trace.colortext = colortext

local function write(append, ...)
	if(not Trace.isEnabled) then return end
	local args = {...}
	local prefix_sign = Trace.prefix_sign and (Trace.prefix_sign.." ") or ""
	local str = colortext(prefix_sign, Trace.sign_color)..timestamp()..": "
	if(append) then
		local str0 = str:gsub("\27%[[%d;]*m", "")
		str = str0:gsub(".", " ")
	end
	for i, arg in ipairs(args) do
		if(type(arg)=="function") then pcall(function() arg = tostring(arg()) end) end
		if(type(arg)=="string") then
			--str = str .. "'"..tostring(arg) .. "' "
			str = str .. colortext(tostring(arg), Trace.text_color) .. " "
		--elseif(type(arg)=="table") then
		--	str = str .. serpent.block(arg, {comment=false}) .. " "
		else
			str = str .. colortext(tostring(arg), Trace.text_color) .. " "
		end
	end
	--background_color
	print(colorbackground(str, Trace.background_color))
end

---DRAFT
function Trace.warning(...)
	local str = colortext(Trace.prefix_sign.." ", Trace.sign_color)..timestamp()..": "
	write(str ..colortext("⚠ WARNING: ", Trace.colors.orange), ...)
end
---DRAFT
function Trace.error(...)
	local str = colortext(Trace.prefix_sign.." ", Trace.sign_color)..timestamp()..": "
	write(str ..colortext("🛑 ERROR: ", Trace.colors.red), ...)
end

---DRAFT
function Trace.exit(msg)
	Trace.append("  >> "..tostring(msg))
end


---@param ... any
function Trace.write(...) write(false, ...) end

---@param ... any
function Trace.append(...) write(true, ...) end

function Trace.on() local last = Trace.isEnabled; Trace.isEnabled = true; return last end
function Trace.off() local last = Trace.isEnabled; Trace.isEnabled = false; return last end

function Trace.pause(fnc)
	local was_on = Trace.off()
	fnc()
	if was_on then Trace.on() end
end

---Same as serpent.block but with better support for factorio objects
---@param value any
---@param options? table
---@return string
function Trace.block(value, options)
	if(is_obj(value) and value.object_name) then
		value = {
			object_name = value.object_name,
			type = ({pcall(function() return value.type end)})[2],
			name = ({pcall(function() return value.name end)})[2],
		}
	end
	return serpent.block(value,options)
end

---Same as serpent.line but with better support for factorio objects
---@param value any
---@param options table?
---@return string
function Trace.line(value, options)
	if(is_obj(value) and value.object_name) then
		value = {
			object_name = value.object_name,
			type = ({pcall(function() return value.type end)})[2],
			name = ({pcall(function() return value.name end)})[2],
		}
	end
	return serpent.line(value,options)
end

if(KuxCoreLib.ModInfo.current_stage~="control") then
	setMetatable()
	KuxCoreLib.__classUtils.finalize(Trace)
	return Trace
end

---[control stage only]----------------------------------------------------------------------------

local EventDistributor = KuxCoreLib.EventDistributor
local Events = KuxCoreLib.Events
local Player = KuxCoreLib.Player --[[@as KuxCoreLib.Player]]

local function on_close_clicked(e)
	if(not e.element or e.element.name~="KuxCoreLib_trace_messagebox_close") then return end
	local player = game.players[e.player_index]
	player.gui.screen.KuxCoreLib_trace_messagebox.destroy()
	EventDistributor.unregister(defines.events.on_gui_click, on_close_clicked)
	storage.events.Trace.on_close_clicked = nil
end

---shows the trace message box
---@param player LuaPlayer|number
---@param message string
function Trace.showMessage(player, message)
	--TODO: not for multiplayer
	local player = player~=nil and Player.toLuaPlayer(player) or nil --[[@as LuaPlayer?]]
	if(game.is_multiplayer() or not player) then
		log(message)
		return
	end

	--game.show_message_dialog{text=message,
	-- style?=…, wrapper_frame_style?=
	local g = player.gui.screen.KuxCoreLib_trace_messagebox
	if(g) then g.destroy() end

	local frame = player.gui.screen.add {
		type = "frame",
		name = "KuxCoreLib_trace_messagebox",
		caption = "Trace Notice",
		direction = "vertical"
	}
    -- local screen_width = player.display_resolution.width
    -- local screen_height = player.display_resolution.height
    -- frame.location = {screen_width - frame.style.minimal_width, screen_height - frame.style.minimal_height}

	local textbox = frame.add {
		type = "text-box",
		text = message,
		style = "textbox"
	}
	textbox.style.width = 500
	textbox.style.height = 400

	local confirm_button = frame.add {
		type = "button",
		name="KuxCoreLib_trace_messagebox_close",
		caption = "Close"
	}
	confirm_button.style.minimal_width = 100

	Events.on_event(defines.events.on_gui_click, on_close_clicked)
	storage.events = storage.events or {}
	storage.events.Trace = storage.events.Trace or {}
	storage.events.Trace.on_close_clicked = true
end

function Trace.formatEntityEvent(e)
	local entity = e.entity or e.created_entity or e.last_entity
	if(not entity) then return "???" end
	local sb = ""
	if(entity.name=="entity-ghost") then
		sb=sb.."entity-ghost ("..(entity.ghost_name)..")"
	else
		sb=sb..entity.name.. " (#"..(entity.unit_number or "-")..")"
	end
	sb=sb.." ["..EventDistributor.getDisplayName(e.name).."]"
	return sb
end

---Gets the name of the constant
---@param list table|string A defines table or a string with the name of the defines table
---@param value any
---@return string
---@return boolean #true if the value was found in the list; else false
function Trace.defines_name(list, value)
	if type(list)=="string" then
		--TODO: support complete path string
		if list:match("%.") then error("Invalid Argument. 'list' must not contain a dot.") end
		list = defines[list]
	end
	if type(list)~="table" then error("Invalid Argument. 'list' must be a table or a string.") end
	if not list then return tostring(value),false end

	--TODO: optimize
	for name,v in pairs(list) do
		if v==value then return name,true end
	end
	return tostring(value),false
end

---Gets the display name of the constant
---@param list table|string A defines table or a string with the name of the defines table
---@param value any
---@return string
function Trace.defines_displayname(list, value)
	local name, success = Trace.defines_name(list, value)
	if success then return name.."("..tostring(value)..")" end
	return tostring(name)
end

function Trace.getIdentifier(o)
	local t = type(o)
	if(t~="table" and t~="userdata") then return t end
	local p = {}
	if(o.object_name) then
		pcall(function() p.type = o.type end)
		pcall(function() p.name = o.name end)
		pcall(function() p.unit_number = o.unit_number end)
	else
		p.type = o.type
		p.name = o.name
		p.unit_number = o.unit_number
		p.__class = o.__class
	end
	return serpent.line(p)
end

local function on_events_initialized()
	Events.on_load(function()
		if(safeget("storage.events.Trace.on_close_clicked")) then
			Events.on_event(defines.events.on_gui_click, on_close_clicked)
		end
	end)
end

---@type KuxCoreLib.Trace
Trace.mock = setmetatable({
	isMock = true,
	append = function (...) end,
	exit = function (...) end
	},
	{
		---@deprecated Trace disabled
		__call = function(self, ...) end,
		__index = function(_, key) return Trace[key] end,
	}
)

if(Events.__isInitialized) then on_events_initialized()
else table.insert(Events.__on_initialized, on_events_initialized)
end
---------------------------------------------------------------------------------------------------

setMetatable()
KuxCoreLib.__classUtils.finalize(Trace)
return Trace

---@class (exact) KuxCoreLib.Trace.Colors -- : {[string]:Color}
---@field black Color
---@field red Color
---@field green Color
---@field blue Color
---@field yellow Color
---@field white Color
---@field gray Color
---@field orange Color
---@field purple Color
---@field brown Color
---@field pink Color
---@field cyan Color
---@field olive Color
---@field teal Color
---@field navy Color
---@field darkred Color
---@field darkgreen Color
---@field darkblue Color
---@field darkyellow Color
---@field darkgray Color
---@field darkorange Color
---@field darkpurple Color
---@field darkbrown Color
---@field darkpink Color
---@field darkcyan Color
---@field darkolive Color
---@field darkteal Color
---@field darknavy Color
---@field lightgray Color
---@field lightred Color
---@field lightgreen Color
---@field lightblue Color
---@field lightyellow Color
---@field lightorange Color
---@field lightpurple Color
---@field lightbrown Color
---@field lightpink Color
---@field lightcyan Color
---@field lightolive Color
---@field lightteal Color
---@field lightnavy Color
---@field gray_16 Color
---@field gray_32 Color
