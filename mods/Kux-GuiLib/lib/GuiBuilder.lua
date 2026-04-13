require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/init")

---@class KuxGuiLib.GuiBuilder : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.GuiBuilder
local GuiBuilder = {
	__class  = "GuiBuilder",
	__guid   = "5aa42fc3-2d53-47ab-9834-18170d832b9c",
	__origin = "Kux-GuiLib/lib/GuiBuilder.lua",
}
KuxCoreLib.__classUtils.ctor(GuiBuilder, KuxGuiLib)
---------------------------------------------------------------------------------------------------
local Table= KuxCoreLib.require.Table
local Debug= KuxCoreLib.require.Debug
local StoragePlayers = KuxCoreLib.StoragePlayers
local Player = KuxCoreLib.require.Player

function GuiBuilder.generateName(name)
	return Debug.getCallingMod().."_"..name
end

---createRelativeToGui
---@param player PlayerIdentification
---@param name string
---@param caption string
---@param gui defines.relative_gui_type
---@param position defines.relative_gui_position
---@return LuaGuiElement
function GuiBuilder.createRelativeToGui(player, name, caption, gui, position)
	local player = Player.toLuaPlayer(player) or error("Invalid player")
	name = GuiBuilder.generateName(name)
	print("createRelativeToGui '"..name.."'")
	if(not gui) then error("Argument must not nil! Name: 'gui'"); end
	if(not position) then error("Argument must not nil! Name: 'position'"); end
	local oldframe = StoragePlayers[player.index].frames[name]
	if(oldframe) then oldframe.destroy(); StoragePlayers[player.index].frames[name]=nil end

	local frame = player.gui.relative.add({
		type = "frame",
		name = name,
		direction = "vertical",
		caption = caption,
		anchor = {
			gui =  gui,
			position = position,
		}
	})

	StoragePlayers[player.index].frames[name]=frame
	return frame
end

---destroyFrame
---@param player PlayerIdentification
---@param name string
function GuiBuilder.destroyFrame(player, name)
	local player = Player.toLuaPlayer(player) or error("Invalid player")
	name = GuiBuilder.generateName(name)
	print("destroyFrame '"..name.."'")

	local frame = StoragePlayers[player].frames[name]
	if frame then
		frame.destroy()
		StoragePlayers[player].frames[name]=nil
	end
end



--#region Example
--[[
script.on_event(defines.events.on_gui_opened, function(event)
	if
		event.gui_type == defines.gui_type.entity
		and event.entity
		and event.entity.type == "container"
	then
		GuiBuilder.createRelativeToGui(event.player_index,"container_gui","Container Test",defines.relative_gui_type.container_gui, defines.relative_gui_position.right)
	end
end)

script.on_event(defines.events.on_gui_closed, function(event)
	if
		event.gui_type == defines.gui_type.entity
		and event.entity
		and event.entity.type == "container"
	then
		GuiBuilder.destroyFrame(event.player_index, "container_gui")
	end
end)
]]
--#endregion

---@type KuxGuiLib.ElementBuilder
GuiBuilder.ElementBuilder = require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/ElementBuilder") or error("Invalid state")

---------------------------------------------------------------------------------------------------
return GuiBuilder