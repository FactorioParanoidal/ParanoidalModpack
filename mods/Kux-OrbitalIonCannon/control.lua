---------------------------------------------------------------------------------------------------
--- Design rules:
--- * `KuxCoreLib.Events` should be uses instead `script`
--- * there must be no global functions -> WIP
---------------------------------------------------------------------------------------------------

---@class Control
Control = {}

---@class Control.private : Control
local this = {}
---------------------------------------------------------------------------------------------------
require("mod")
if script.active_mods["gvv"] then require("__gvv__.gvv")() end
Version = KuxCoreLib.Version.asGlobal()
Events = KuxCoreLib.Events.asGlobal()
-- require("__Kux-CoreLib__/stdlib/core")
Area = require("__Kux-CoreLib__/stdlib/area/area") -- preload required by Position
Chunk = require("__Kux-CoreLib__/stdlib/area/chunk")
Position = require("__Kux-CoreLib__/stdlib/area/position")

require "modules/tools"
require "modules/autotargeter"
require "modules/gui"
require "modules/Permissions"
require "modules/IonCannonStorage"
require "modules/targeter"
require "modules/interface"
require "modules/IonCannon"
---------------------------------------------------------------------------------------------------

local fLog = function (functionName) print("control."..functionName) end

setmetatable(this, {__index = Control})

_G.when_ion_cannon_targeted = nil


function this.initialize()
	fLog("initialize")
	-- on_init, on_configuration_changed, on_force_created
	Interface.generateEvents()
	IonCannonStorage.initialize()

	storage.goToFull = storage.goToFull or {}
	storage.markers = storage.markers or {}
	--global.holding_targeter = global.holding_targeter or {} --MAV This doesn't do anything that makes sense, getting rid of it. If necessary can be replaced with isHolding()
	storage.klaxonTick = storage.klaxonTick or 0
	storage.auto_tick = storage.auto_tick or 0
	storage.readyTick = {}
--	if remote.interfaces["silo_script"] then
--		local tracked_items = remote.call("silo_script", "get_tracked_items") --COMPATIBILITY 1.1 get_tracked_items removed
--		if not tracked_items["orbital-ion-cannon"] then
--			remote.call("silo_script", "add_tracked_item", "orbital-ion-cannon") --COMPATIBILITY 1.1 add_tracked_item removed
--		end
--	end
	if not storage.permissions then Permissions.initialize() end
	for _, player in pairs(game.players) do
		storage.readyTick[player.index] = 0
		if storage.goToFull[player.index] == nil then
			storage.goToFull[player.index] = true
		end
		if player.gui.top["ion-cannon-button"] then player.gui.top["ion-cannon-button"].destroy() end
		if player.gui.top["ion-cannon-stats"] then player.gui.top["ion-cannon-stats"].destroy() end
	end
	for i, force in pairs(game.forces) do
		force.reset_recipes()
	end
	if IonCannonStorage.countAll() > 0 then
		storage.IonCannonLaunched = true
		this.enableNthTick60()
	end
end

function this.onLoad()
	fLog("onLoad")
	Interface.generateEvents()
	if storage.IonCannonLaunched then
		this.enableNthTick60()
	end
end

function this.on_force_created(e)
	if not storage.forces_ion_cannon_table then this.initialize() end
	IonCannonStorage.newForce(e.force)
end

---@param e EventData.on_forces_merging
function this.on_forces_merging(e)
	local dest = IonCannonStorage.fromForce(e.destination)
	for _, connon in ipairs(IonCannonStorage.fromForceOrEmpty(e.source)) do
		table.insert(dest, connon)
	end
	storage.forces_ion_cannon_table[e.source.name]=nil
end


--why we should open the GUI always? KUX MODIFICATION
--[[Events.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.player_index then
		local player = game.players[event.player_index]
		if global.IonCannonLaunched or player.cheat_mode or player.admin then
			open_GUI(player)
		end
	end
end)]]

function this.on_player_created(e)
	fLog("on_player_created")
	init_GUI(game.players[e.player_index])
	storage.readyTick[e.player_index] = 0
end

---@param e NthTickEventData
function this.process_60_ticks(e)
	local current_tick = e.tick
	for i = #storage.markers, 1, -1 do -- Loop over table backwards because some entries get removed within the loop
		local marker = storage.markers[i]
		if marker[2] <= current_tick then
			if marker[1] and marker[1].valid then
				marker[1].destroy()
			end
			table.remove(storage.markers, i)
		end
	end
	IonCannon.ReduceIonCannonCooldowns()
	for i, force in pairs(game.forces) do
		if IonCannon.isIonCannonReady(force) then
			for i, player in pairs(force.connected_players) do
				if storage.readyTick[player.index] < current_tick then
					storage.readyTick[player.index] = current_tick + settings.get_player_settings(player)["ion-cannon-ready-ticks"].value
					playSoundForPlayer(mod.defines.sound.ready, player)
				end
			end
		end
	end
	for i, player in pairs(game.connected_players) do
		update_GUI(player)
	end
end

--Returns true if the payer is holding the specified stack or a ghost of it
function isHolding(stack, player)
	local holding = player.cursor_stack
	if holding and holding.valid_for_read and holding.name == stack.name and holding.count >= stack.count then
		return true
	--"crafting" an item in SE remote view doesn't craft the item but instead puts a ghost of it into the cursor
	--Checking for cheat mode is a simple alternative to calling an SE remote function to check if the remote view is active
	elseif --[[player.cheat_mode and]] player.cursor_ghost and player.cursor_ghost.name == stack.name then
		return true
	end
	return false
end

--- Called when the rocket is launched.
---@param e EventData.on_rocket_launched
-- rocket :: LuaEntity
-- rocket_silo :: LuaEntity (optional)
-- player_index :: uint (optional): The player that is riding the rocket, if any.
function this.on_rocket_launched(e)
	--TODO: run only only if space_travel is false
	print("on_rocket_launched")
	local force = e.rocket.force

	-- no valid inventories for the rocket!
	-- for inventory_name, inventory_key in pairs(defines.inventory) do ..

	--[[
	for inventory_name, inventory_key in pairs(defines.inventory) do
		inv = e.rocket_silo.get_inventory(inventory_key)
		if inv then
			print("inventory["..tostring(inventory_name).."]")
			for i=1,#inv do
				print("  item["..tostring(i).."] = "..tostring(inv[i]))
			end
		end
	end
	]]

	if e.rocket.cargo_pod and e.rocket.cargo_pod.get_item_count("orbital-ion-cannon") > 0 then
		-- only vanilla (with space-age activated cargo_pod is nil)
		print("ion-cannon-targeter found in rocket")
		IonCannon.install(force, e.rocket_silo.surface)
		local inv = e.rocket.cargo_pod.get_inventory(defines.inventory.cargo_unit)
		inv.remove({name = "orbital-ion-cannon", count = 1})
		return
	end

end

--- @param e EventData.on_pre_build
function this.on_pre_build(e)
	local current_tick = e.tick
	if storage.tick and storage.tick > current_tick then
		return
	end
	storage.tick = current_tick + 10
	local player = game.players[e.player_index]
	if isHolding({name = "ion-cannon-targeter", count = 1}, player) and player.force.is_chunk_charted(player.surface, Chunk.from_position(e.position)) then
		IonCannon.target(player.force, e.position, player.surface, player)
	elseif isHolding({name = "ion-cannon-targeter-mk2", count = 1}, player) and player.force.is_chunk_charted(player.surface, Chunk.from_position(e.position)) then
		IonCannon.target(player.force, e.position, player.surface, player)
	end
end

--- Called when an entity is built by a player.
--- @param e EventData.on_built_entity
function this.on_built_entity(e)
	local entity = e.entity
	if not entity.valid then return end
	local targeter_names ={"ion-cannon-targeter", "ion-cannon-targeter-mk2"}
	for _, targeter_name in ipairs(targeter_names) do
		if entity.name == targeter_name then
			local player = game.players[e.player_index]
			player.cursor_stack.set_stack({name = targeter_name, count = 1})
			entity.destroy()
			return
		end
		if entity.name == "entity-ghost" then
			if entity.ghost_name == targeter_name then
				entity.destroy()
				return
			end
		end
	end
end

---Called when an entity with a trigger prototype (such as capsules) create an entity AND that trigger prototype defined trigger_created_entity=true.
---@param e EventData.on_trigger_created_entity
function this.on_trigger_created_entity(e)
	local created_entity = e.entity
	if created_entity.name == "ion-cannon-explosion" then
		script.raise_event(when_ion_cannon_fired, {surface = created_entity.surface, position = created_entity.position, radius = IonCannon.getRadius(created_entity.force)})		-- Passes event.surface, event.position, and event.radius
		--TODO: Is this charting the chunk for every force in the game? wtf?
		for i, force in pairs(game.forces) do
			force.chart(created_entity.surface, Position.expand_to_area(created_entity.position, 1))
		end
	end
end

function Control.enableNthTick60()
	Events.on_nth_tick(60, this.process_60_ticks)
end


ModGui.initEvents()

Events.on_event(defines.events.on_force_created, this.on_force_created)
Events.on_event(defines.events.on_forces_merging,this.on_forces_merging)
Events.on_event(defines.events.on_player_created, this.on_player_created)
Events.on_event(defines.events.on_trigger_created_entity, this.on_trigger_created_entity)
Events.on_event(defines.events.on_built_entity, this.on_built_entity)
local c_on_pre_build = defines.events.on_pre_build --COMPATIBILITY 1.1 'on_put_item' renamed to 'on_pre_build'
if not c_on_pre_build then c_on_pre_build = (defines.events--[[@as any]]).on_put_item end
Events.on_event(c_on_pre_build, this.on_pre_build)
Events.on_event(defines.events.on_rocket_launched, this.on_rocket_launched)



Events.on_init(this.initialize)
Events.on_load(this.onLoad)
script.on_configuration_changed(this.initialize)

commands.add_command("ion-cannon", {"command-help.ion-cannon"}, function(event)
	local player = game.players[event.player_index] --[[@as LuaPlayer]]
	if player.admin then
		if event.parameter == "reset-gui" then
			ModGui.reset(player)
		elseif event.parameter == "research" then
			player.print("Researching Ion Cannon")
			player.force.technologies["orbital-ion-cannon"].research_recursive()
		elseif event.parameter == "research auto-targeting" then
			player.print("Researching Ion Cannon")
			player.force.technologies["auto-targeting"].research_recursive()
		else
			player.print("Unknown command "..event.parameter)
		end
	end
end)
