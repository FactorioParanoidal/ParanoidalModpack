---
---@class KuxGuiLib.Designer.static : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.Designer
local Designer = {
	__class  = "KuxGuiLib.Designer.static",
	__guid   = "c016cdc1-2d2c-4f2c-a983-ba001ce16986",
	__origin = "Kux-GuiLib/lib/Designer.lua",
}
KuxCoreLib.__classUtils.ctor(Designer, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------

---Base class for all designer
---@class KuxGuiLib.Designer
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field mod_name string
---@field view_name string
---@field open fun(plx: KuxGuiLib.PlayerContext)
---@field element KuxGuiLib.ElementAccessor
---@field [string] LuaGuiElement


local metatable = {
	__index = function(t,k) return t.element[k] end,
}
local metatable_protected = {
	__index = function(t,k) return t.element[k] end,
	__newindex = function () error("Designer is readonly") end,
	__metatable = setmetatable({protected="protected by KuxGuiLib.Designer"},{
		__index = function(t,k) error(t.protected) end,
		__newindex = function(t,k,v) error(t.protected) end
	})
}

---
---@param self any
---@return KuxGuiLib.Designer
function Designer.ctor(self)
	self.mod_name = self.mod_name or script.mod_name
	assert(self.view_name, "view_name not spezified.")
	self.root_name = self.root_name and self.root_name or (self.mod_name .."-"..self.view_name)

	setmetatable(self,table.deepcopy(metatable))
	return self
end

---
---@param self any
---@return KuxGuiLib.Designer
function Designer.finalize(self)
	self.mod_name = self.mod_name or script.mod_name
	assert(self.view_name, "view_name not spezified.")
	self.element = ElementBuilder.loadElementAccessor(self.mod_name, self.view_name)
	setmetatable(self,table.deepcopy(metatable_protected))
	return self
end


--[ finalize ] --------------------------------------------------------------------------------------------------------

KuxCoreLib.__classUtils.finalize(Designer)
return Designer