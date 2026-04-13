---Provides common GUI functions
---@class KuxGuiLib.Gui : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.Gui
local Gui = {
	__class  = "Gui",
	__guid   = "6d2348b0-7c4a-463d-b63c-6ccf51c2af56",
	__origin = "Kux-GuiLib/Gui.lua",
}
KuxCoreLib.__classUtils.ctor(Gui, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------

local Dictionary = KuxCoreLib.require.Dictionary

---@type table<integer,table<string,LuaGuiElement>>
local getElement_cache = Dictionary.create_byPlayerAndString()


---@param rootOrPlayer LuaGuiElement|LuaPlayer
---@param path string
---@return LuaGuiElement? element The element or nil
---@return string? error An error message
---@overload fun(root, path):LuaGuiElement?,string?
---@overload fun(path):LuaGuiElement?,string?
---<p>Usage: <br>
---1: <code>getElement(player,"screen/path/element")</code> <br>
---2: <code>getElement(element,"path/element")</code> <br>
---3: <code>getElement("screen/path/element")</code> <br>
function Gui.getElement(rootOrPlayer, path)
	local root ---@type LuaGuiElement|LuaGui
	local player
	local fullpath
	if type(rootOrPlayer)=="string" and path==nil then
		path = rootOrPlayer --[[@as string]]
		root = _G.player.gui
		fullpath = path
		player = _G.player or error("no (global) player")
	else
		if not path then return nil,"no path" end                               --EXIT ❌ no path!
		if is_obj(rootOrPlayer, "LuaPlayer") then
			player = rootOrPlayer --[[@as LuaPlayer]]
			root = player.gui
			fullpath = path
		elseif is_obj(rootOrPlayer, "LuaGuiElement") then
			root = rootOrPlayer --[[@as LuaGuiElement]]
			player = game.players[root.player_index]
			fullpath = root.tags.path.."/"..path
		else
			error("invalid arguments")
		end
	end
	local cached = getElement_cache[player.index][fullpath]
	if cached and cached.valid then return cached end                           --EXIT ✅ cached

	local fragments = path:gmatch("[^/]+")
	local current = root --[[@as LuaGui|LuaGuiElement|nil]]
	local current_path = ""
	for part in fragments do
		current_path = #current_path>0 and current_path.."/"..part or part
		if not current or not current.valid then break end                      --BREAK
		if not current.children then return nil, "not found" end                --EXIT ❌ not found
		local nextEl = current[part]
		if not nextEl then
			local index = tonumber(part)
			if index then
				nextEl = current.children[index]
			end
		end
		current = nextEl
	end
	if not current then return nil, "not found" end                             --EXIT ❌ not found
	if not current.valid then return nil, "not valid" end                       --EXIT ❌ not valid
	getElement_cache[current.player_index][fullpath]=current
	return current                                                              --EXIT ✅ found
end


---@type table<integer,table<string,LuaGuiElement>>
local getElementByPath_cache = Dictionary.create_byPlayerAndString()

---@param rootOrPlayer LuaGuiElement|LuaPlayer
---@param path string
---@return LuaGuiElement?
function Gui.getElementByPath(rootOrPlayer, path)
	if not path then return nil end

	local byPlayerAndPath
	local root
	if rootOrPlayer.object_name=="LuaPlayer" then
		local player = rootOrPlayer --[[@as LuaPlayer]]
		local el = getElementByPath_cache[player.index][path]
		if el and el.valid then return el end
		byPlayerAndPath = true
		root = player.gui
	elseif rootOrPlayer.object_name=="LuaGuiElement" then
		root=rootOrPlayer --[[@as LuaGuiElement]]
	end

	local fragments = path:gmatch("[^/]+")
	local current = root --[[@as LuaGui|LuaGuiElement|nil]]
	for part in fragments do
		if not current or not current.valid or not current.children then return nil end
		local nextEl = nil
		local index = tonumber(part)
		if index then
			nextEl = current.children[index]
		else
			for _, child in pairs(current.children) do
				if child.name == part then
					nextEl = child
					break
				end
			end
		end
		current = nextEl
	end
	if not current or not current.valid then return end
	if byPlayerAndPath then getElementByPath_cache[current.player_index][path]=current end
	return current
end


---
---@param container LuaGuiElement
---@return boolean
function Gui.isToplevel(container)
	return container.parent==nil
end


-----------------------------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(Gui)
return Gui
