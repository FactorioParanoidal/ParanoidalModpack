local Events = KuxCoreLib.Events
require "modules/tools"
require "modules/IonCannonStorage"
local mod_gui = require("mod-gui")
local ElementBuilder = KuxGuiLib.require.GuiBuilder.ElementBuilder
local GuiElementCache = KuxGuiLib.require.GuiElementCache


UiElementDefinitions = {
	["ion-cannon-button"] = {type="button", style = "ion-cannon-button-style"}
}

---@class ModGui
ModGui = {}

---@class ModGui.private : ModGui
local this = setmetatable({}, {__index = ModGui})

-----------------------------------------------------------------------------------------------------------------------

local createButtonContent = nil

do --#region ElementBuilder
	local eb = ElementBuilder or error("Invalid state")
	local frame = eb.frame
	local flow = eb.flow
	local table = eb.table
	local label = eb.label
	local textfield = eb.textfield
	local button = eb.button
	local empty_widget = eb.emptywidget

	createButtonContent = function(button)
		ElementBuilder.createView{
			container = button,

		empty_widget{ width = 32, height = 32, children = {
				flow{
					width = 32, height = 32,
					horizontal_align = "right",
					vertical_align = "top",
					children = {
						label{caption = "0",top_padding = -2, right_padding = 2},
					}
				},
				flow{
					width = 32, height = 32,
					horizontal_align = "left",
					vertical_align = "bottom",
					children = {
						label{caption = "0", left_margin=2, bottom_padding = -2},
					}
				}
			}
		}
	}
	end
end --#endregion ElementBuilder

---@param e EventData.on_gui_checked_state_changed
function this.on_gui_checked_state_changed(e)
	local checkbox = e.element
	if checkbox.name == "show" then
		storage.goToFull[e.player_index] = false
		storage.permissions[-1] = checkbox.state
		open_GUI(game.players[e.player_index])
	elseif checkbox.name == "ion-cannon-auto-target-enabled" then
		storage.goToFull[e.player_index] = false
		storage.permissions[-2] = checkbox.state
		open_GUI(game.players[e.player_index])
	else
		local index = tonumber(checkbox.name)
		if checkbox.parent.name == "ion-cannon-admin-panel-table" then
			Permissions.setPermission(index, checkbox.state)
			if index == 0 then
				Permissions.setAll(checkbox.state)
				storage.goToFull[e.player_index] = false
				open_GUI(game.players[e.player_index])
			end
		end
	end
end

--- Called when LuaGuiElement is clicked.
-- element :: LuaGuiElement: The clicked element.
-- player_index :: uint: The player who did the clicking.
-- button :: defines.mouse_button_type: The mouse button used if any.
-- alt :: boolean: If alt was pressed.
-- control :: boolean: If control was pressed.
-- shift :: boolean: If shift was pressed.

---@param e EventData.on_gui_click
function this.on_gui_click(e)
	local player = game.players[e.element.player_index]
	local force = player.force
	local name = e.element.name
	local surfaceName
	if name == "ion-cannon-button" then
		open_GUI(player)
		return
	elseif name == "add-ion-cannon" then
		surfaceName = IonCannon.add(force, player.surface)
		storage.IonCannonLaunched = true
		Control.enableNthTick60()
		for i, player in pairs(force.connected_players) do
			init_GUI(player)
			playSoundForPlayer(mod.defines.sound.charging, player)
		end
		force.print({"ion-cannons-in-orbit", surfaceName, IonCannon.countOrbitingIonCannons(force, surfaceName)})
		return
	elseif name == "add-five-ion-cannon" then
		surfaceName = IonCannon.add(force, player.surface)
		IonCannon.add(force, surfaceName)
		IonCannon.add(force, surfaceName)
		IonCannon.add(force, surfaceName)
		IonCannon.add(force, surfaceName)
		storage.IonCannonLaunched = true
		Control.enableNthTick60()
		for i, player in pairs(force.connected_players) do
			init_GUI(player)
			playSoundForPlayer(mod.defines.sound.charging, player)
		end
		force.print({"ion-cannons-in-orbit", surfaceName, IonCannon.countOrbitingIonCannons(force, surfaceName)})
		return
	elseif name == "remove-ion-cannon" then
		local cannons = IonCannonStorage.fromForce(force) or {}
		for _, cannon in ipairs(cannons) do
			if cannon[3] == player.surface.name then
				table.remove(cannons)
				for i, player in pairs(force.connected_players) do update_GUI(player) end
				force.print({"ion-cannon-removed"})
				return
			end
		end
		player.print({"no-ion-cannons"})
		return
	elseif name == "recharge-ion-cannon" then
		IonCannon.ReduceIonCannonCooldowns(settings.global["ion-cannon-cooldown-seconds"].value);
	end
end

function ModGui.initEvents()
	Events.on_event(defines.events.on_gui_checked_state_changed, this.on_gui_checked_state_changed)
	Events.on_event(defines.events.on_gui_click, this.on_gui_click)
end

function getUiElement(parent, name, createIfNotExist)
	--print("getUiElement",name)
	if not parent.object_name then
		parent = findUiElementByName(parent[1], parent[2], createIfNotExist)
	end
	if parent == nil then return nil end

	local element = parent[name]
	if element then return element end
	if not createIfNotExist then return nil end
	local definition = UiElementDefinitions[name]
	if not definition then error("Definition not found. Name: '"..name.."'") end
	definition["name"]=name
	definition["index"]=nil
	print("create "..definition["type"].." '"..definition["name"].."'")
	return parent.add(definition)
end

function findUiElementByName(player, name, createIfNotExist)
	if name == "ion-cannon-button" then return getUiElement(mod_gui.get_button_flow(player), name, createIfNotExist) end
	error("Unknwon element. Name: '"..name.."'")
end

function destroyUiElement(player, name)
	local element = findUiElementByName(player, name, false)
	if not element then return end
	element.parent[name].destroy()
end

---@param player LuaPlayer
function init_GUI(player)
	--print("init_GUI")
	--is called every 60 seconds

	local cannons = IonCannonStorage.fromForce(player.force)
	if cannons == nil or #cannons == 0 and not settings.global["ion-cannon-cheat-menu"].value then
		local frame = player.gui.left["ion-cannon-stats"]
		if frame then frame.destroy() end
		if player.gui.top["ion-cannon-button"] then player.gui.top["ion-cannon-button"].destroy() end
		destroyUiElement(player,"ion-cannon-button")
	else
		findUiElementByName(player, "ion-cannon-button", true)
	end
end

function this.createAdminPanel(parent)
	-- parent: frame
	local adminPanel = parent.add{type = "table", column_count = 3, name = "ion-cannon-admin-panel-table"}

	-- 1st row
	adminPanel.add{type = "label", caption = {"player-names"}}
	adminPanel.add{type = "label", caption = {"allowed"}}
	adminPanel.add{type = "label", caption = ""}

	-- 2nd row
	adminPanel.add{type = "label", caption = {"toggle-all"}}
	adminPanel.add{type = "checkbox", state = storage.permissions[0], name = "0"}
	adminPanel.add{type = "label", caption = ""}

	-- player rows
	for _, player in pairs(game.players) do
		adminPanel.add{type = "label", caption = player.name }
		adminPanel.add{type = "checkbox", state = Permissions.getPermission(player.index), name = player.index .. ""}
		adminPanel.add{type = "label", caption = iif(player.admin," [Admin]","") }
	end

	return adminPanel
end

---@param player LuaPlayer
function open_GUI(player)
	local frame = player.gui.left["ion-cannon-stats"]
	local force = player.force
	local forceName = force.name
	local surfaceName = IonCannon.getOrbitingSurface(player.surface).name
	local player_index = player.index
	if frame and storage.goToFull[player_index] then frame.destroy() return end

	if storage.goToFull[player_index] and IonCannonStorage.count(force) < 40 then
		storage.goToFull[player_index] = false
		if frame then frame.destroy() end
		frame = player.gui.left.add{type = "frame", name = "ion-cannon-stats", direction = "vertical"}
		frame.add{type = "label", caption = {"ion-cannon-details-full"}}
		frame.add{type = "table", column_count = 2, name = "ion-cannon-table"}
		for i = 1, IonCannonStorage.count(force) do
			frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannon-num", i}}
			if IonCannonStorage.fromForce(force)[i][2] == 1 then
				frame["ion-cannon-table"].add{type = "label", caption = {"ready"}}
			else
				frame["ion-cannon-table"].add{type = "label", caption = {"cooldown", IonCannonStorage.fromForce(force)[i][1]}}
			end
		end
	else
		storage.goToFull[player_index] = true
		if frame then frame.destroy() end
		frame = player.gui.left.add{type = "frame", name = "ion-cannon-stats", direction = "vertical"}
		frame.add{type = "label", caption = {"ion-cannon-details-compact"}}
		if player.admin then
			frame.add{type = "table", column_count = 2, name = "ion-cannon-admin-panel-header"}
			frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-admin-panel-show"}}
			frame["ion-cannon-admin-panel-header"].add{type = "checkbox", state = storage.permissions[-1], name = "show"}
			-- frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-cheat-menu-show"}}
			--TODO WTF? if global.permissions[-2] == nil then global.permissions[-2] = settings.global["ion-cannon-auto-targeting"].value end
			-- frame["ion-cannon-admin-panel-header"].add{type = "checkbox", state = global.permissions[-2], name = "cheats"}
			if frame["ion-cannon-admin-panel-header"]["show"].state then
				this.createAdminPanel(frame)
			end
			-- if frame["ion-cannon-admin-panel-header"]["cheats"].state then
			if settings.global["ion-cannon-cheat-menu"].value then
				frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-cheat-one"}}
				frame["ion-cannon-admin-panel-header"].add{type = "button", name = "add-ion-cannon", style = "ion-cannon-button-style"}
				frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-cheat-five"}}
				frame["ion-cannon-admin-panel-header"].add{type = "button", name = "add-five-ion-cannon", style = "ion-cannon-button-style"}
				frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-remove-one"}}
				frame["ion-cannon-admin-panel-header"].add{type = "button", name = "remove-ion-cannon", style = "ion-cannon-remove-button-style"}
				frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-cheat-recharge-all"}}
				frame["ion-cannon-admin-panel-header"].add{type = "button", name = "recharge-ion-cannon", style = "ion-cannon-button-style"}
			end
			frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"mod-setting-name.ion-cannon-auto-targeting"}}
			frame["ion-cannon-admin-panel-header"].add{type = "checkbox", state = storage.permissions[-2], name = "ion-cannon-auto-target-enabled"}
		end
		frame.add{type = "table", column_count = 1, name = "ion-cannon-table"}
		frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannons-in-orbit", surfaceName, IonCannonStorage.count(force)}}
		frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannons-ready", IonCannonStorage.countIonCannonsReady(force, surfaceName)}}
		if IonCannonStorage.countIonCannonsReady(force, surfaceName) < IonCannonStorage.count(force) then
			frame["ion-cannon-table"].add{type = "label", caption = {"time-until-next-ready", IonCannon.timeUntilNextReady(force, surfaceName)}}
		end
	end
end

---@param player LuaPlayer
function update_GUI(player)
	init_GUI(player)

	local button = findUiElementByName(player, "ion-cannon-button", false)
	local statsFrame = player.gui.left["ion-cannon-stats"]
	if not statsFrame and not button then return end

	local force = player.force
	--local forceName = force.name
	local playerIndex = player.index
	local surfaceName = IonCannon.getOrbitingSurface(player.surface).name

	if button then
		local numReadyCannons = IonCannon.countReady(force, surfaceName)
		local numCannons = IonCannon.countOrbitingIonCannons (force, surfaceName)
		--if #button.children == 0 then createButtonContent(button) end
		button.clear(); createButtonContent(button) --WORKAROUND for GUI Unifier

		button.children[1].children[1].children[1].caption = tostring(numCannons)
		if numReadyCannons > 0 then
			button.children[1].children[2].children[1].caption = tostring(numReadyCannons)
			button.children[1].children[2].children[1].style.font_color ={r=0.25,g=1,b=0.25}
		else
			local timeUntilNextReady = IonCannon.timeUntilNextReady(force, surfaceName)
			button.children[1].children[2].children[1].caption = tostring(timeUntilNextReady)
			button.children[1].children[2].children[1].style.font_color ={r=1,g=0.25,b=0.25}
		end
	end

	if not statsFrame then return end

	local cannonTable = statsFrame["ion-cannon-table"]
	if cannonTable then cannonTable.destroy() end

	if not storage.goToFull[playerIndex] then
		--if false then --TODO configuration
		--	cannonTable = createFullCannonTable(player)
		--else
			cannonTable = createFullCannonTableFiltered(player)
		--end
	else
		cannonTable = statsFrame.add{type = "table", column_count = 1, name = "ion-cannon-table"}
		--cannonTable.add{type = "label", caption = {"ion-cannons-in-orbit", #GetCannonTableFromForce(force)}}
		local numCannons = 0
		if false then
			numCannons =  IonCannonStorage.count(force)
		else
			for i = 1, IonCannonStorage.count(force) do
				if surfaceName == IonCannonStorage.fromForce(force)[i][3] then numCannons=numCannons+1 end
			end
		end

		cannonTable.add{type = "label", caption = {"ion-cannons-in-orbit", surfaceName, numCannons}}
		cannonTable.add{type = "label", caption = {"ion-cannons-ready", IonCannonStorage.countIonCannonsReady(force, surfaceName)}}
		if IonCannonStorage.countIonCannonsReady(force, surfaceName) < IonCannon.countOrbitingIonCannons(force, surfaceName) then
			cannonTable.add{type = "label", caption = {"time-until-next-ready", IonCannon.timeUntilNextReady(force, surfaceName)}}
		end
	end
end

---@param player LuaPlayer
function createFullCannonTableFiltered(player)
	local statsFrame = player.gui.left["ion-cannon-stats"]
	local force = player.force
	local cannonTable = statsFrame.add{type = "table", column_count = 2, name = "ion-cannon-table"}
	local cannons = IonCannonStorage.fromForce(force)
	local surfaceName = IonCannon.getOrbitingSurface(player.surface).name

	for i = 1, #cannons do
		if surfaceName == cannons[i][3] then
			cannonTable.add{type = "label", caption = {"ion-cannon-num", i}}
			if cannons[i][2] == 1 then cannonTable.add{type = "label", caption = {"ready"}}
			else cannonTable.add{type = "label", caption = {"cooldown", cannons[i][1]}} end
		end
	end
	return cannonTable
end

function ModGui.reset(player)

end

Events.on_event("ion-cannon-hotkey", function(event)
	local player = game.players[event.player_index]
	if storage.IonCannonLaunched or player.admin then
		open_GUI(player)
	end
end)
-----------------------------------------------------------------------------------------------------------------------
return ModGui