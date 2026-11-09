-- Data phase utilities
local tlib = require("lib.core.table")

local lib = {}

--- Copy a prototype, assigning a new name and minable properties.
--- This code comes from flib.
--- @param prototype table
--- @param new_name string string
--- @param remove_icon? boolean
--- @return table
function lib.copy_prototype(prototype, new_name, remove_icon)
	if not prototype.type or not prototype.name then
		error("Invalid prototype: prototypes must have name and type properties.")
		return --- @diagnostic disable-line
	end
	local p = table.deepcopy(prototype)
	p.name = new_name
	if p.minable and p.minable.result then p.minable.result = new_name end
	if p.place_result then p.place_result = new_name end
	if p.result then p.result = new_name end
	if p.results then
		for _, result in pairs(p.results) do
			if result.name == prototype.name then result.name = new_name end
		end
	end
	if remove_icon then
		p.icon = nil
		p.icon_size = nil
		p.icons = nil
	end

	return p
end

---Convert a Sprite to a RotatedSprite by adding `direction_count=1`.
---WARNING: this performs deep mutation of the table. Deepcopy first if you want to preserve the original.
---@param sprite data.Sprite
---@return data.RotatedSprite rotated_sprite
function lib.sprite_to_rotated(sprite)
	local rotated_sprite = sprite --[[@as data.RotatedSprite]]
	if rotated_sprite.layers then
		for _, layer in pairs(rotated_sprite.layers) do
			lib.sprite_to_rotated(layer --[[@as data.Sprite]])
		end
	else
		rotated_sprite.direction_count = 1
	end

	return rotated_sprite
end

---Trigger a recipe to unlock with a given technology.
---@param recipe_name string Name of a recipe prototype.
---@param technology_name string Name of a technology prototype.
function lib.unlock_recipe_with_technology(recipe_name, technology_name)
	if not data.raw.recipe[recipe_name] then
		log({
			"",
			"WARNING: unlock_recipe_with_technology: Recipe ",
			recipe_name,
			" does not exist, skipping.",
		})
		return
	end
	local tech = data.raw.technology[technology_name]
	if not tech then
		log({
			"",
			"WARNING: unlock_recipe_with_technology: Technology ",
			technology_name,
			" does not exist, skipping.",
		})
		return
	end

	if not tech.effects then tech.effects = {} end

	table.insert(tech.effects, {
		type = "unlock-recipe",
		recipe = recipe_name,
	})
end

return lib
