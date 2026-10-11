-- Factorio 2.0 shortcut icons use square IconData resources, not Sprite crops.
-- Keep this compatibility fix in the pack instead of editing third-party mods.
local graphics = "__zzzparanoidal__/graphics/shortcut-icons/"

local function replace_icons(name, asset, icon_size)
	local shortcut = data.raw.shortcut[name]
	if not shortcut then
		return
	end

	-- Layered icons take precedence over the single-icon fields.
	shortcut.icons = nil
	shortcut.small_icons = nil
	shortcut.icon = graphics .. asset .. "-" .. icon_size .. ".png"
	shortcut.icon_size = icon_size
	shortcut.small_icon = graphics .. asset .. "-24.png"
	shortcut.small_icon_size = 24
	-- Legacy 1.1 fields; Factorio 2.0 shades unavailable shortcuts itself.
	shortcut.disabled_icon = nil
	shortcut.disabled_small_icon = nil
end

replace_icons("todo-toggle-ui-shortcut", "todo-list", 56)
replace_icons("todo-add-task-shortcut", "todo-add-task", 56)
