require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/init")

---Provides GUI helper functions
---@class KuxGuiLib.GuiHelper : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.GuiHelper
local GuiHelper = {
	__class  = "GuiHelper",
	__guid   = "490ea051-dc17-465b-9234-ccf654eb3e10",
	__origin = "Kux-GuiLib/GuiHelper.lua",
}
KuxCoreLib.__classUtils.ctor(GuiHelper, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------


---
---@param parent LuaGuiElement|LuaGui
---@param name string
---@param prefix string?
---@return LuaGuiElement?
function GuiHelper.findElementRecursive(parent, name, prefix)
	assert(parent, "Invalid Argument. 'parent' must not be nil.")
	--assert(is_obj(parent,"LuaGuiElement"), "Invalid Argument. 'parent' must be a LuaGuiElement. object_name: "..tostring(parent.object_name))
	assert(name, "Invalid Argument. 'name' must not be nil.")
	--[[TRACE]]trace("GuiHelper.findElementRecursive "..tostring(parent.object_name=="LuaGui" and "LuaGui" or parent.name).." "..name)
	local full_name = name
	local short_name = name
	if(prefix) then
		if string.sub(name, 1, #prefix) ~= prefix then
			full_name = prefix..name
		else
			short_name = string.sub(name, #prefix+1)
		end
	end

	local function R(parent, level)
		--[[TRACE]]trace.append("  "..string.rep("  ",level)..tostring(parent.object_name=="LuaGui" and "LuaGui" or parent.name).."..")
		for _,element in pairs(parent.children or {}) do
			if(element.name == full_name) then trace.exit("found full name "..element.name); return element end
			if(element.name == short_name) then trace.exit("found partial name "..element.name); return element end
		end
		for _,element in pairs(parent.children or {}) do
			local result = R(element, level+1)
			if(result) then return result end
		end
		return nil
	end
	return R(parent,0)
end

---@param el LuaGuiElement
---@return string|integer key
function GuiHelper.getElementKey(el)
	if el.name then return el.name end

	if el.parent == nil then
		for name, child in pairs(game.players[el.player_index].gui) do
			if child == el then return name end
		end
		error("get_element_key: element not found at GUI root")
	end
	return el.get_index_in_parent()
end

-- player_index -> LuaGuiElement -> path
local cache = {} ---@type {[number]: {[LuaGuiElement]: table<string|number>}}
setmetatable(cache, { __index = function(t, k) local v = {}; t[k] = v; return v end })

---@param el LuaGuiElement
---@return (number|string)[] path
function GuiHelper.getPath(el)
	assert(el, "getPath: element is nil")
	assert(el.valid, "getPath: element is not valid")

	local player_index = el.player_index
	local cache = cache[player_index]
	local cached = cache[el]; if cached then return cached end

	local parent = el.parent
	if not parent then
		cached = {player_index, GuiHelper.getElementKey(el)}
		cache[el] = cached
		return cached
	end
	local parent_path = GuiHelper.getPath(parent)
	local path = {} ---@type (number|string)[]
	for i = 1, #parent_path, 1 do path[i] = parent_path[i] end
	path[#path+1] = GuiHelper.getElementKey(el)
	cache[el] = path
	return path
end

-----------------------------------------------------------------------------------------------------------------------
return GuiHelper