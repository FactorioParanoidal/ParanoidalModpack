-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.plates.items) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "plates",
	make_icon_pictures = false,
	flat_icon = true,
}

---
---Validates that a value is exists at the end of a path described by a series
---of keys in a given `root` table, and if so returns that value.
---
---Provides similar behavior to the null-conditional operator `?` in C#.
---
---Examples:
---```
---local leaf = get_value(root, "trunk", "branch", "twig", "leaf")
---```
---
---@param root table # The root table.
---@param ... string|integer # Keys that describe a path to a value in `root`.
---@return any # The value at the end of the path if it is exists; otherwise, `nil`.
local function get_value(root, ...)
	local current_obj = root

	for _, key in pairs({ ... }) do
		if type(current_obj) == "table" and current_obj[key] ~= nil then
			current_obj = current_obj[key]
		else
			return nil
		end
	end

	return current_obj
end

---
---Checks if a value is exists at the end of a path described
---by a series of keys in a given `root` table.
---
---Examples:
---```
---local leaf_exists = value_exists(root, "trunk", "branch", "twig", "leaf")
---local leaf = leaf_exists and root["trunk"]["branch"]["twig"].leaf
---```
---
---@param root table # The root table.
---@param ... string|integer # Keys that describe a path to a value in `root`.
---@return boolean # `true` if the value at the end of the path is exists; otherwise, `false`.
local function value_exists(root, ...)
	return get_value(root, ...) == nil
end

---
--- Evaluates the given `condition` and returns the appropriate value.
---
--- Note that both `if_true` and `if_false` are evaluated. Be cautious of
--- side effects.
---
---@param condition boolean # The condition to evaluate.
---@param if_true any # The value returned when `condition` is `true`.
---@param if_false any # The value returned when `condition` is `false`.
---@return any # When `condition == true`, returns `if_true`; otherwise, returns `if_false`.
local function ternary(condition, if_true, if_false)
	if condition then
		return if_true
	else
		return if_false
	end
end

---@type CreateIconsFromListTable
local intermediates = {
	-- Powders
	["bob-alumina"] = ternary(get_value(angelsmods, "trigger", "smelting_products", "aluminium", "ingot"), nil, { subgroup = "powders" }),
	["bob-cobalt-oxide"] = ternary(get_value(angelsmods, "trigger", "smelting_products", "cobalt", "ingot"), nil, { subgroup = "powders" }),
	["bob-tungsten-oxide"] = ternary(get_value(angelsmods, "trigger", "smelting_products", "tungsten", "powder"), nil, { subgroup = "powders" }),
	["bob-powdered-tungsten"] = ternary(get_value(angelsmods, "trigger", "smelting_products", "tungsten", "powder"), nil, { subgroup = "powders" }),
	["bob-lead-oxide"] = ternary(get_value(angelsmods, "triggers", "smelting_products", "lead", "ingot"), nil, { subgroup = "powders" }),
	["bob-silver-nitrate"] = ternary(get_value(angelsmods, "triggers", "smelting_products", "silver", "ingot"), nil, { subgroup = "powders" }),
}

reskins.internal.create_icons_from_list(intermediates, inputs)
