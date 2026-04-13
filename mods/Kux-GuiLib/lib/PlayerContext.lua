require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/init")

---
---@class KuxGuiLib.PlayerContext.static : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.PlayerContext.static
local PlayerContext = {
	__class  = "KuxGuiLib.PlayerContext.static",
	__module = "PlayerContext",
	__guid   = "bf9f034d-edf0-452f-9dde-e1642822511a",
	__origin = "Kux-GuiLib/lib/PlayerContext.lua",
}
 KuxCoreLib.__classUtils.ctor(PlayerContext, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------

local l1_cache = {} ---@type table<any, KuxGuiLib.PlayerContext>
local l2_cache = {} ---@type table<number, KuxGuiLib.PlayerContext>

---@class (exact) KuxGuiLib.PlayerContext
---               ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field __class             string  The unique class name
---@field player              LuaPlayer
---@field ElementSelectorView KuxGuiLib.ElementSelectorView.Data
---@field ContextMenu         KuxGuiLib.ContextMenu.Data
---@field ErrorDialog         KuxGuiLib.ErrorDialog.Data
---@field MessageDialog       KuxGuiLib.MessageDialog.Data
---@field ClipboardDialog     KuxGuiLib.ClipboardDialog.Data
---@field ElementSelectorOptionsView   KuxGuiLib.ElementSelectorOptionsView.Data
---@field __rename table<string, string> Rename {oldname->newname}
---@field __remove table<string>
PlayerContext.template = {
	__class = {["KuxGuiLib.PlayerContext"]=1},

	ErrorDialog = {translations={}},
	MessageDialog = {translations={}},
	---@diagnostic disable: missing-fields
	ElementSelectorView = {},
	ContextMenu = {},
	ClipboardDialog = {},
	ElementSelectorOptionsView = {},
	---@diagnostic enable missing-fields

	__rename = {
	--	["OLDNAME"] = "NEWNAME"
	},
	__remove = { "root","_rename","_remove","gui" }
}

local function mergeTemplate(base, extension, current_path)
	current_path = current_path or ""

	for k, v in pairs(extension) do
		local path = current_path ~= "" and (current_path .. "." .. k) or k
		if k == "__class" then
			if base.__class == nil then error("Missing __class in template.")
			elseif type(base.__class) == "string" then base.__class = { base.__class, v }
			elseif type(base.__class) == "table" then table.insert(base.__class, v)
			else error("invalid type for __class: " .. type(base.__class))
			end
		elseif k == "__rename" then
			for k2, v2 in pairs(v) do base[k][k2] = v2 end
		elseif k == "__remove" then
			for _, v2 in ipairs(v) do table.insert(base[k],v2 ) end
		else
			if base[k] ~= nil then
				error("mergeTemplate: key '" .. path ..
					"' already exists with value: " .. tostring(base[k]))
			end
			base[k] = v
		end
	end
end

function PlayerContext.mergeTemplate(extension)
	mergeTemplate(PlayerContext.template, extension)
end


local function applyTemplate(target, template)
	for oldKey, newKey in pairs(template.__rename or {}) do
		if target[oldKey] ~= nil then
			target[newKey] = target[oldKey]
			target[oldKey] = nil
		end
	end

	for _, removeKey in ipairs(template.__remove or {}) do target[removeKey] = nil end

	for k, v in pairs(template) do
		if k == "__rename" or k == "__remove" then goto next end
		if type(v) == "table" then
			target[k] = target[k] or {}
			applyTemplate(target[k], v)
		elseif target[k] == nil then
			target[k] = v
		end
		::next::
	end
end

local is_template_applied = false


--- gets the PlayerContext for the given player. cached for performance.
---@param player_ident PlayerIdentification|KuxGuiLib.PlayerContext
---@return KuxGuiLib.PlayerContext
function PlayerContext.get(player_ident)
	local l1_value = l1_cache[player_ident]
	if l1_value then return l1_value end
	local player = getPlayer(player_ident--[[@as any]])
	local l2_value = l2_cache[player.index]
	if l2_value then l1_cache[player_ident]=l2_value return l2_value end

	local lib_root_storage = storage["Kux-GuiLib"] or {}; storage["Kux-GuiLib"] = lib_root_storage
	lib_root_storage.PlayerContext = lib_root_storage.PlayerContext or {}
	lib_root_storage.PlayerContext.players = lib_root_storage.PlayerContext.players or {}
	local players = lib_root_storage.PlayerContext.players
	if not is_template_applied then -- one time after load
		for _, value in pairs(players) do
			applyTemplate(value, PlayerContext.template)
		end
		is_template_applied = true
	end
	if not players[player.index] then
		players[player.index] = {} --[[@as any]]
		applyTemplate(players[player.index] , PlayerContext.template)
	end
	local plx = players[player.index] --[[@as KuxGuiLib.PlayerContext]]
	plx.player = player

	l1_cache[player_ident] = plx
	l2_cache[player.index] = plx
	return plx
end


---@param player_ident PlayerIdentification|KuxGuiLib.PlayerContext
---@return KuxGuiLib.PlayerContext
function _G.getPlayerContextBase(player_ident)
	--assert(_G["PlayerContext"], "(global) PlayerContext is not initialized")
	if _G["PlayerContext"] then
		rawset(_G, "getPlayerContextBase", rawget(_G, "PlayerContext").get) --hides from LuaLS
		return _G["PlayerContext"].get(player_ident --[[@as any]]) --[[@as KuxGuiLib.PlayerContext]]
	else
		return KuxGuiLib.PlayerContext.get(player_ident --[[@as any]]) --[[@as KuxGuiLib.PlayerContext]]
	end
end

-----------------------------------------------------------------------------------------------------------------------

return PlayerContext
-----------------------------------------------------------------------------------------------------------------------


---@class KuxGuiLib.GuiStorage --table<string, LuaGuiElement|table<string, LuaGuiElement|LuaGuiElement[]>>
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field ElementSelectorView {[string]: LuaGuiElement}
---@field ContextMenu {[string]: LuaGuiElement}
---@field ClipboardDialog {[string]: LuaGuiElement}
---@field ElementSelectorOptionsView {[string]: LuaGuiElement}
-- @field [string] LuaGuiElement|table<string, LuaGuiElement|LuaGuiElement[]>



---ContextMenu storage data
---@class KuxGuiLib.ContextMenu.Data
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field element LuaGuiElement     The element that opened the context menu
---@field view_name string          The view that recieves the events
---@field close boolean             Set to true if the context menu should be closed at next tick
---@field items table


---ClipboardDialog storage data
---@class KuxGuiLib.ClipboardDialog.Data
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field element LuaGuiElement     The element that opened the context menu
---@field view_name string          The view that recieves the events
---@field location GuiLocation
