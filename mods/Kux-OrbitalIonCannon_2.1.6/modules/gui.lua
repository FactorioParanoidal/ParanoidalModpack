require "modules.tools"
local mod_gui = require("mod-gui")

UiElementDefinitions = {
	["ion-cannon-button"] = {type="button", style = "ion-cannon-button-style"}
}

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

function replaceOrCreateUiElement(player, name)
	local element = findUiElementByName(player, name, false)

	local definition = UiElementDefinitions[name]
	if not definition then error("Definition not found. Name: '"..name.."'") end
	if element then
		local idx = element.get_index_in_parent()
		definition["index"]=idx
		element.destroy()
	end
	definition["name"]=name
	return findUiElementByName(player, name, true)
end

function init_GUI(player)
	--print("init_GUI")
	--TODO is called every 60 seconds!
	if #global.forces_ion_cannon_table[player.force.name] == 0 and not player.cheat_mode then
		local frame = player.gui.left["ion-cannon-stats"]
		if frame then frame.destroy() end
		if player.gui.top["ion-cannon-button"] then player.gui.top["ion-cannon-button"].destroy() end
		destroyUiElement(player,"ion-cannon-button")
	end
	findUiElementByName(player, "ion-cannon-button", true)
end

function open_GUI(player)
	local frame = player.gui.left["ion-cannon-stats"]
	local force = player.force
	local forceName = force.name
	local player_index = player.index
	if frame and global.goToFull[player_index] then
		frame.destroy()
	else
		if global.goToFull[player_index] and #global.forces_ion_cannon_table[forceName] < 40 then
			global.goToFull[player_index] = false
			if frame then
				frame.destroy()
			end
			frame = player.gui.left.add{type = "frame", name = "ion-cannon-stats", direction = "vertical"}
			frame.add{type = "label", caption = {"ion-cannon-details-full"}}
			frame.add{type = "table", column_count = 2, name = "ion-cannon-table"}
			for i = 1, #global.forces_ion_cannon_table[forceName] do
				frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannon-num", i}}
				if global.forces_ion_cannon_table[forceName][i][2] == 1 then
					frame["ion-cannon-table"].add{type = "label", caption = {"ready"}}
				else
					frame["ion-cannon-table"].add{type = "label", caption = {"cooldown", global.forces_ion_cannon_table[forceName][i][1]}}
				end
			end
		else
			global.goToFull[player_index] = true
			if frame then
				frame.destroy()
			end
			frame = player.gui.left.add{type = "frame", name = "ion-cannon-stats", direction = "vertical"}
			frame.add{type = "label", caption = {"ion-cannon-details-compact"}}
			if player.admin then
				frame.add{type = "table", column_count = 2, name = "ion-cannon-admin-panel-header"}
				frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-admin-panel-show"}}
				frame["ion-cannon-admin-panel-header"].add{type = "checkbox", state = global.permissions[-1], name = "show"}
				-- frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-cheat-menu-show"}}
				if global.permissions[-2] == nil then global.permissions[-2] = settings.global["ion-cannon-auto-targeting"].value end
				-- frame["ion-cannon-admin-panel-header"].add{type = "checkbox", state = global.permissions[-2], name = "cheats"}
				if frame["ion-cannon-admin-panel-header"]["show"].state then
					frame.add{type = "table", column_count = 2, name = "ion-cannon-admin-panel-table"}
					frame["ion-cannon-admin-panel-table"].add{type = "label", caption = {"player-names"}}
					frame["ion-cannon-admin-panel-table"].add{type = "label", caption = {"allowed"}}
					frame["ion-cannon-admin-panel-table"].add{type = "label", caption = {"toggle-all"}}
					frame["ion-cannon-admin-panel-table"].add{type = "checkbox", state = global.permissions[0], name = "0"}
					for i, player in pairs(game.players) do
						frame["ion-cannon-admin-panel-table"].add{type = "label", caption = player.name}
						frame["ion-cannon-admin-panel-table"].add{type = "checkbox", state = global.permissions[player.index], name = player.index .. ""}
					end
				end
				-- if frame["ion-cannon-admin-panel-header"]["cheats"].state then
				if settings.global["ion-cannon-cheat-menu"].value then
					frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-cheat-one"}}
					frame["ion-cannon-admin-panel-header"].add{type = "button", name = "add-ion-cannon", style = "ion-cannon-button-style"}
					frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-cheat-five"}}
					frame["ion-cannon-admin-panel-header"].add{type = "button", name = "add-five-ion-cannon", style = "ion-cannon-button-style"}
					frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-remove-one"}}
					frame["ion-cannon-admin-panel-header"].add{type = "button", name = "remove-ion-cannon", style = "ion-cannon-remove-button-style"}
				end
				frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"mod-setting-name.ion-cannon-auto-targeting"}}
				frame["ion-cannon-admin-panel-header"].add{type = "checkbox", state = global.permissions[-2], name = "ion-cannon-auto-target-enabled"}
			end
			frame.add{type = "table", column_count = 1, name = "ion-cannon-table"}
			frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannons-in-orbit", #global.forces_ion_cannon_table[forceName]}}
			frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannons-ready", countIonCannonsReady(force, player.surface)}}
			if countIonCannonsReady(force, player.surface) < #global.forces_ion_cannon_table[forceName] then
				frame["ion-cannon-table"].add{type = "label", caption = {"time-until-next-ready", timeUntilNextReady(force, player.surface)}}
			end
		end
	end
end

function update_GUI(player)
	init_GUI(player)
	local statsFrame = player.gui.left["ion-cannon-stats"]
	if not statsFrame then return end

	local force = player.force
	local forceName = force.name
	local playerIndex = player.index

	local cannonTable = statsFrame["ion-cannon-table"]
	if cannonTable then cannonTable.destroy() end

	if not global.goToFull[playerIndex] then
		if false then --TODO configuration
			cannonTable = createFullCannonTable(player)
		else
			cannonTable = createFullCannonTableFiltered(player)
		end
	else
		cannonTable = statsFrame.add{type = "table", column_count = 1, name = "ion-cannon-table"}
		--cannonTable.add{type = "label", caption = {"ion-cannons-in-orbit", #global.forces_ion_cannon_table[forceName]}}
		local numCannons = 0
		if false then
			numCannons =  #global.forces_ion_cannon_table[forceName]
		else
			for i = 1, #global.forces_ion_cannon_table[forceName] do
				if player.surface.name == global.forces_ion_cannon_table[forceName][i][3] then numCannons=numCannons+1 end
			end
		end

		cannonTable.add{type = "label", caption = {"ion-cannons-in-orbit", numCannons}}
		cannonTable.add{type = "label", caption = {"ion-cannons-ready", countIonCannonsReady(force, player.surface)}}
		if countIonCannonsReady(force, player.surface) < #global.forces_ion_cannon_table[forceName] then
			cannonTable.add{type = "label", caption = {"time-until-next-ready", timeUntilNextReady(force, player.surface)}}
		end
	end
end

function createFullCannonTable(player)
	local statsFrame = player.gui.left["ion-cannon-stats"]
	local forceName = player.force.name
	local cannonTable = statsFrame.add{type = "table", column_count = 3, name = "ion-cannon-table"}
	for i = 1, #global.forces_ion_cannon_table[forceName] do
		cannonTable.add{type = "label", caption = {"ion-cannon-num", i}}
		if global.forces_ion_cannon_table[forceName][i][2] == 1 then
			cannonTable.add{type = "label", caption = {"ready"}}
		else
			cannonTable.add{type = "label", caption = {"cooldown", global.forces_ion_cannon_table[forceName][i][1]}}
		end
		cannonTable.add{type = "label", caption = "["..tostring(global.forces_ion_cannon_table[forceName][i][3]).."]"}
	end
	return cannonTable
end

function createFullCannonTableFiltered(player)
	local statsFrame = player.gui.left["ion-cannon-stats"]
	local forceName = player.force.name
	local cannonTable = statsFrame.add{type = "table", column_count = 2, name = "ion-cannon-table"}
	for i = 1, #global.forces_ion_cannon_table[forceName] do
		if player.surface.name ~= global.forces_ion_cannon_table[forceName][i][3] then goto next end
		cannonTable.add{type = "label", caption = {"ion-cannon-num", i}}
		if global.forces_ion_cannon_table[forceName][i][2] == 1 then
			cannonTable.add{type = "label", caption = {"ready"}}
		else
			cannonTable.add{type = "label", caption = {"cooldown", global.forces_ion_cannon_table[forceName][i][1]}}
		end
		::next::
	end
	return cannonTable
end