-- Pack-owned shortcut for the pack-owned demotion tool.
-- Shortcuts-ick 1.1 generated a shortcut for every selection tool of other mods; 2.0 removed it.
-- Paranoidal Beta 8 relied on it for its own tools, so it is restored for those tools only.
local paranoidal_tools = {
	"hero_downgrade", -- zzzparanoidal: demote HeroTurretRedux turrets
}

for _, name in ipairs(paranoidal_tools) do
	local tool = data.raw["selection-tool"][name]
	local exists = false
	for _, shortcut in pairs(data.raw["shortcut"]) do
		if shortcut.action == "spawn-item" and shortcut.item_to_spawn == name then
			exists = true
			break
		end
	end
	if tool and not exists then
		local icon, icon_size = tool.icon, tool.icon_size
		if not icon and tool.icons then
			icon, icon_size = tool.icons[1].icon, tool.icons[1].icon_size
		end
		icon = icon or "__core__/graphics/shoot.png"
		icon_size = icon_size or 64

		-- A shortcut can only spawn an item with the "spawnable" flag.
		tool.flags = tool.flags or {}
		local spawnable = false
		for _, flag in pairs(tool.flags) do
			if flag == "spawnable" then spawnable = true end
		end
		if not spawnable then table.insert(tool.flags, "spawnable") end

		data:extend({{
			type = "shortcut",
			name = name,
			order = tool.order,
			action = "spawn-item",
			localised_name = {"item-name." .. name},
			item_to_spawn = name,
			style = "default",
			icon = icon,
			icon_size = icon_size,
			small_icon = icon,
			small_icon_size = icon_size
		}})
	end
end
