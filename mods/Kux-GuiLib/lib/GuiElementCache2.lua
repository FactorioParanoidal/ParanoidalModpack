require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/init")

---Provides GUI helper functions
---@class KuxGuiLib.GuiElementCache2 : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.GuiElementCache2
local GuiElementCache2 = {
	__class  = "GuiElementCache2",
	__guid   = "8f571be7-b9b1-4510-9725-8c59c5b4b51f",
	__origin = "Kux-GuiLib/lib/GuiElementCache2.lua",
}
KuxCoreLib.__classUtils.ctor(GuiElementCache2, KuxGuiLib)
---------------------------------------------------------------------------------------------------

---@param elements table<string, LuaGuiElement|LuaGuiElement[]>
---@param el LuaGuiElement
function GuiElementCache2.add_cache_element(elements, el)
	local t = elements[el.name]
	if not t then elements[el.name] = el
	elseif type(t) == "table" then _G.table.insert(t, el)
	else elements[el.name] = { t, el }
	end
end
local add_cache_element = GuiElementCache2.add_cache_element

---@param all_elements table<string, LuaGuiElement|LuaGuiElement[]>
---@param root LuaGuiElement
function GuiElementCache2.build_cache(all_elements, root)
	Table.clear(all_elements)

	local private = {}

	---@param el LuaGuiElement
	function private.enum_children(el)
		for _, child in ipairs(el.children) do
			private.handle_element(child)
			if child.children then private.enum_children(child) end
			--TODO handle other types of children
		end
	end

	---@param el LuaGuiElement
	function private.handle_element(el)
		local view_name = el.tags.view_name
		if view_name then
			all_elements[view_name] = all_elements[view_name] or {}
			local view_elements = all_elements[view_name]
			add_cache_element(view_elements, el)
		end
		add_cache_element(all_elements, el)
		private.enum_children(root)
	end

	private.handle_element(root)
end

---@param elements table<string, LuaGuiElement|LuaGuiElement[]>
---@param el LuaGuiElement
function GuiElementCache2.remove_cache_element(elements, el)
	if not el then return end
	t = elements[el.name]
	if type(t) == "table" then
		Table.remove(t, el)
		if     #t == 0 then elements[el.name] = nil
		elseif #t == 1 then elements[el.name] = t[1]
		end
	else
		elements[el.name] = nil
	end
end
local remove_cache_element = GuiElementCache2.remove_cache_element

---removes all view_elements from all_elements
---@param all_elements table<string, LuaGuiElement|LuaGuiElement[]>
---@param view_elements table<string, LuaGuiElement|LuaGuiElement[]>
function GuiElementCache2.remove_cache_elements(all_elements, view_elements)
	if view_elements == nil then return end
	for k, v in pairs(view_elements) do
		if type(v) == "table" then
			for _, el in ipairs(v) do
				remove_cache_element(all_elements, el)
			end
		else
			remove_cache_element(all_elements, v)
		end
	end
end
local remove_cache_elements = GuiElementCache2.remove_cache_elements

---------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(GuiElementCache2)
return GuiElementCache2
