if mod.modules.IonTargeter then return mod.modules.IonTargeter end

---@class Targeter
Targeter = {}
local this = {}
mod.modules.IonTargeter = Targeter

function this.on_player_cursor_stack_changed(event)
	local player = game.players[event.player_index]
	if not isHolding({name = "ion-cannon-targeter", count = 1}, player) and not isHolding({name = "ion-cannon-targeter-mk2", count = 1}, player)then return end
	if player.character and not Permissions.hasPermission(player.index) then
		player.print({"ion-permission-denied"})
		playSoundForPlayer(mod.defines.sound.unable_to_comply, player)
		if Version.baseVersionGreaterOrEqual1d1() then
			player.clear_cursor() --COMPATIBILITY 1.1
		else
			player["clean_cursor"]() --Factorio < 1.1
		end
		--global.holding_targeter[player.index] = false
	elseif ((IonCannonStorage.count(player.force) > 0 and not IonCannon.isAllIonCannonOnCooldown(player))) --and not global.holding_targeter[player.index]
	then
		playSoundForPlayer(mod.defines.sound.select_target, player)
	end
end

local allowed_items = {"ion-cannon-targeter", "ion-cannon-targeter-mk2","orbital-ion-cannon-area-targeter"}

local function give_shortcut_item(player, prototype_name)
	if prototype_name == "ion-cannon-targeter" and player.force.technologies[mod.tech.cannon_mk2_upgrade].researched then
		prototype_name = "ion-cannon-targeter-mk2"
	end
	if not prototypes.item[prototype_name] then return end
	local cc = false
	if Version.baseVersionGreaterOrEqual1d1() then
		cc = player.clear_cursor() --COMPATIBILITY 1.1
	else
		cc = player.clean_cursor() --Factorio < 1.1
	end
	if player.controller_type == defines.controllers.remote then
		 --Warning: this will allow the player to obtain infinite remotes
		player.cursor_stack.set_stack({name = prototype_name})
		--player.cursor_ghost = prototypes.item[prototype_name]
	elseif remote.interfaces["space-exploration"] and remote.call("space-exploration", "remote_view_is_active", {player=player}) then
		 --Warning: this will allow the player to obtain infinite remotes
		player.cursor_ghost = prototypes.item[prototype_name]
	else
		player.cursor_stack.set_stack({name = prototype_name}) --Warning: this will allow the player to obtain infinite remotes
		player.get_main_inventory().remove({name = prototype_name, count = 1})
	end
end

function this.on_lua_shortcut(event)
	local prototype_name = event.prototype_name
	local player = game.players[event.player_index]
	if prototypes.shortcut[prototype_name] then
		for _, item_name in pairs(allowed_items) do
			if item_name == prototype_name then
				give_shortcut_item(player, prototype_name)
			end
		end
	end
end


function this.on_player_selected_area(event)
	if event.item ~= "orbital-ion-cannon-area-targeter" then return end

	local player = game.players[event.player_index]
	local radius = IonCannon.getRadius(player.force) --[[@as number]] -- Radius eines Kreises
	local surface = player.surface
	local force = player.force --[[@as LuaForce]]
	local positions = {}

	-- Bereichsgrenzen
	local area = event.area
	--local x_start, x_end = area.left_top.x, area.right_bottom.x
	--local y_start, y_end = area.left_top.y, area.right_bottom.y
	--allow 30% border overlap
	local x_start, x_end = area.left_top.x - radius/3, area.right_bottom.x + radius/3
	local y_start, y_end = area.left_top.y - radius/3, area.right_bottom.y + radius/3

	-- Abstand für hexagonales Muster
	local radius = radius / 1.2 -- 20% Overlap
	local x_step = 2 * radius
	local y_step = math.sqrt(3) * radius

	-- Berechne effektive Anzahl der Kreise
	local x_count = math.floor((x_end - x_start) / x_step)
	local y_count = math.floor((y_end - y_start) / y_step)

	-- Berechne tatsächliche Abdeckung durch die Kreise
	local effective_width = (x_count - 1) * x_step + 2 * radius
	local effective_height = (y_count - 1) * y_step + 2 * radius

	-- Zentrierung: Versatz berechnen
	local x_offset = x_start + ((x_end - x_start) - effective_width) / 2
	local y_offset = y_start + ((y_end - y_start) - effective_height) / 2

	-- Versuche, hexagonales Gitter zu platzieren
	for y = y_offset + radius, y_offset + effective_height - radius, y_step do
		local row_offset = ((math.floor((y - y_offset) / y_step) % 2) == 0) and 0 or radius

		for x = x_offset + radius + row_offset, x_offset + effective_width - radius, x_step do
			-- Setze Dummy-Entität als "Kreis"
			table.insert(positions, {x, y})
			circles_placed = true -- Mindestens ein Kreis wurde gesetzt
		end
	end

	-- Fallback: Eine horizontale oder vertikale Reihe, falls kein Gitter passt
	if #positions == 0 then
		local x_range = x_end - x_start
		local y_range = y_end - y_start

		if x_range >= y_range then
			-- Horizontale Reihe platzieren
			for x = x_start + radius, x_end - radius, x_step do
				table.insert(positions,  {x, (y_start + y_end) / 2})
			end
		else
			-- Vertikale Reihe platzieren
			for y = y_start + radius, y_end - radius, y_step do
				table.insert(positions, {(x_start + x_end) / 2, y})
			end
		end
	end

	-- Letzter Fallback: Ein Kreis in die Mitte setzen
	if #positions == 0 then
		local center_x = (x_start + x_end) / 2
		local center_y = (y_start + y_end) / 2
		table.insert(positions, {center_x, center_y})
	end

	for _, position in ipairs(positions) do
		--game.forces[player.force.name].add_chart_tag(surface, {position = position, text = "O"})
		IonCannon.target(force, {x=position[1],y=position[2]}, surface, player)
	end
end

Events.on_event(defines.events.on_player_cursor_stack_changed, this.on_player_cursor_stack_changed)
Events.on_event(defines.events.on_lua_shortcut, this.on_lua_shortcut)
Events.on_event(defines.events.on_player_selected_area, this.on_player_selected_area)

return Targeter