---@class KuxGuiLib.Storage
local GuiLibStorage = {}

local metatable = {}

function metatable.__index(t,k)
	storage["Kux-GuiLib"] = storage["Kux-GuiLib"] or {}
	storage["Kux-GuiLib"][k] = storage["Kux-GuiLib"][k] or {}
	return storage["Kux-GuiLib"][k]
end

function metatable.__newindex(t,k,v)
	storage["Kux-GuiLib"] = storage["Kux-GuiLib"] or {}
	storage["Kux-GuiLib"][k] = v
end

setmetatable(GuiLibStorage, metatable)


return GuiLibStorage