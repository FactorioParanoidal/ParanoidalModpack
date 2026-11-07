-- Graphics helpers of the mod's buildings and demons (data stage).
local M = {}

local function files_of(t)
	local list = {}
	if type(t.filename) == "string" then list[#list + 1] = t.filename end
	for _, name in pairs(type(t.filenames) == "table" and t.filenames or {}) do list[#list + 1] = name end
	return list
end

-- Tints every sprite layer under t except shadows (a recolour of an existing building, user 2026-11-07).
function M.tint_layers(t, tint)
	if type(t) ~= "table" then return end
	if #files_of(t) > 0 and not t.draw_as_shadow then
		t.tint = tint
		return
	end
	for _, value in pairs(t) do M.tint_layers(value, tint) end
end

-- Recolours a vanilla biter or spitter: its two mask layers carry the colours.
function M.tint_masks(t, tint1, tint2)
	if type(t) ~= "table" then return end
	local files = files_of(t)
	if #files > 0 then
		local name = files[1]
		if name:find("mask1") then t.tint = tint1 elseif name:find("mask2") then t.tint = tint2 end
		return
	end
	for _, value in pairs(t) do M.tint_masks(value, tint1, tint2) end
end

-- Icons of a prototype (icon or icons), tinted.
function M.icons(prototype, tint)
	if prototype.icons then
		local icons = table.deepcopy(prototype.icons)
		for _, icon in pairs(icons) do icon.tint = tint end
		return icons
	end
	return {{icon = prototype.icon, icon_size = prototype.icon_size or 64, tint = tint}}
end

-- A platform-only crafting machine with one fixed recipe, made from a (hidden) Space Age machine.
function M.machine(base, name, recipe, energy_usage, tint)
	local machine = table.deepcopy(base)
	machine.name = name
	machine.icon = nil
	machine.icons = M.icons(base, tint)
	machine.minable = {mining_time = 1, result = name}
	machine.placeable_by = nil
	machine.crafting_categories = {recipe}
	machine.fixed_recipe = recipe
	machine.crafting_speed = 1
	machine.energy_usage = energy_usage
	machine.module_slots = 0
	machine.allowed_effects = {}
	machine.allowed_module_categories = nil
	machine.effect_receiver = nil
	machine.fluid_boxes = nil
	machine.fluid_boxes_off_when_no_fluid_recipe = nil
	machine.fast_replaceable_group = nil
	machine.next_upgrade = nil
	machine.additional_pastable_entities = nil
	machine.show_recipe_icon = false
	machine.surface_conditions = {{property = "gravity", min = 0, max = 0}} -- only on a space platform
	M.tint_layers(machine.graphics_set, tint)
	return machine
end

M.science = {
	{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1},
	{"production-science-pack", 1}, {"utility-science-pack", 1}, {"space-science-pack", 1},
}

return M
