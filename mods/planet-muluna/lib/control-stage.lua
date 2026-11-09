-- Adds helper functions for control stage. Shared across all pymods & adapted for use in muluna

local random = math.random

require "events"

---Draws a red error icon at the entity's position.
---@param entity LuaEntity
---@param sprite string
---@param time_to_live integer
muluna.draw_error_sprite = function(entity, sprite, time_to_live)
	rendering.draw_sprite {
		sprite = sprite,
		x_scale = 0.5,
		y_scale = 0.5,
		target = entity,
		surface = entity.surface,
		time_to_live = time_to_live or 30,
		render_layer = "air-entity-info-icon"
	}
end

---Randomizes a position by a factor.
---@param position Position
---@param factor number?
---@return Position
muluna.randomize_position = function(position, factor)
	local x = position.x or position[1]
	local y = position.y or position[2]
	factor = factor or 1
	return {x = x + factor * (random() - 0.5), y = y + factor * (random() - 0.5)}
end

---Intended to be called inside a build event. Cancels creation of the entity.
---Returns its item_to_place back to the player or spills it on the ground.
---@param entity LuaEntity
---@param player_index integer?
---@param message LocalisedString?
---@param color Color?
muluna.cancel_creation = function(entity, player_index, message, color)
	local inserted = 0
	local items_to_place_this = entity.prototype.items_to_place_this
	local item_to_place = items_to_place_this and items_to_place_this[1]
	local surface = entity.surface
	local position = entity.position
	local quality = entity.quality.name
	local name = entity.name

	if player_index then
		local player = game.get_player(player_index)
		if player.mine_entity(entity, false) then
			inserted = 1

			-- remove from undo stack
			local undo_stack = player.undo_redo_stack
			local top
			for i = 1, undo_stack.get_undo_item_count() do
				top = undo_stack.get_undo_item(i)
				for j, action in pairs(top) do
					local target = action.target
					if target and target.name == name and serpent.line(target.position) == serpent.line(position) then
						undo_stack.remove_undo_action(i, j)
						break
					end
				end
			end
		elseif item_to_place then
			item_to_place.quality = quality
			inserted = player.insert(item_to_place)
		end
	end

	if inserted == 0 and item_to_place then
		item_to_place.quality = quality
		surface.spill_item_stack {
			position = position,
			stack = item_to_place,
			enable_looted = true,
			force = entity.force_index,
			allow_belts = false
		}
	end

	entity.destroy {raise_destroy = true}

	if not message then return end

	local tick = game.tick
	local last_message = storage._last_cancel_creation_message or 0
	if last_message + 60 < tick then
		for _, player in pairs(game.connected_players) do
			player.create_local_flying_text {
				text = message,
				position = position,
				color = color,
				create_at_cursor = player.index == player_index
			}
		end
		storage._last_cancel_creation_message = game.tick
	end
end

---Returns the grandparent gui element with the given name.
---@param element LuaGuiElement
---@param name string
---@return LuaGuiElement
muluna.find_grandparent = function(element, name)
	while element do
		if element.name == name then return element end
		element = element.parent
	end
	error("Could not find parent gui element with name: " .. name)
end

local si_prefixes = {
	[0] = "",
	"si-prefix-symbol-kilo",
	"si-prefix-symbol-mega",
	"si-prefix-symbol-giga",
	"si-prefix-symbol-tera",
	"si-prefix-symbol-peta",
	"si-prefix-symbol-exa",
	"si-prefix-symbol-zetta",
	"si-prefix-symbol-yotta"
}
---formats a number into the amount of energy. Requires 'W' or 'J' as the second parameter
---@param energy number
---@param watts_or_joules string
muluna.format_energy = function(energy, watts_or_joules)
	if watts_or_joules == "W" then
		watts_or_joules = "si-unit-symbol-watt"
		energy = energy * 60
	elseif watts_or_joules == "J" then
		watts_or_joules = "si-unit-symbol-joule"
	else
		error()
	end

	local prefix = 0
	while energy >= 1000 do
		energy = energy / 1000
		prefix = prefix + 1
	end
	return {"", string.format("%.1f", energy), " ", si_prefixes[prefix] and {si_prefixes[prefix]} or "* 10^" .. (prefix * 3) .. " ", {watts_or_joules}}
end

---Returns the distance from 0,0
---@param x number
---@param y number
---@return number
muluna.distance = function(x, y)
	return (x ^ 2 + y ^ 2) ^ 0.5
end

---Returns the squared distance between two points.
---@param first Position
---@param second Position
---@return number
muluna.distance_squared = function(first, second)
	local x = first.x - second.x
	local y = first.y - second.y
	return x * x + y * y
end
