local mod = require("mod")
local Version = KuxCoreLib.Version

local newBaseVersion = Version.baseVersionGreaterOrEqual1d1()

data.raw.item["ion-cannon-targeter"].flags = data.raw.item["ion-cannon-targeter"].flags or {}
--table.insert(data.raw.item["ion-cannon-targeter"].flags, "only-in-cursor")
if newBaseVersion then table.insert(data.raw.item["ion-cannon-targeter"].flags, "spawnable") end

--[[local color = function (category, color, text)

end]]

data:extend({
    {
        type = "shortcut",
        name = "ion-cannon-targeter",
        localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"controls.ion-cannon-targeter"} },
        order = "d[artillery]-e[ion-cannon-targeter-1]",
        -- associated_control_input = "ion-cannon-targeter",
        --action = "lua", --> Events.on_event(defines.events.on_lua_shortcut,...)
		action = "spawn-item", item_to_spawn = "ion-cannon-targeter", --TODO select correct targeter
        style = "red",
        technology_to_unlock = mod.tech.cannon,
		unavailable_until_unlocked = true,
        icons = {{
            icon = mod.path.."graphics/ion-cannon-targeter-x32-white.png",
            priority = "extra-high-no-scale",
            icon_size = 32,
            scale = 0.5,
            flags = {"gui-icon"}
        }},
        small_icons = {
			{
				icon = mod.path.."graphics/ion-cannon-targeter-x24-white.png",
				priority = "extra-high-no-scale",
				icon_size = 24,
				scale = 1, -- 0.5,
				flags = {"gui-icon"}
			}
		}
	}--[[@as data.ShortcutPrototype]],
})

data:extend({
	{
		type = "custom-input",
		name = "ion-cannon-targeter",
		key_sequence = ""
	}
})

data:extend{{
	type = "shortcut",
	name = "orbital-ion-cannon-area-targeter",
	localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"controls.orbital-ion-cannon-area-targeter"} },
    order = "d[artillery]-e[orbital-ion-cannon-area-targeter]",
	icons = {{
		icon = mod.path .. "graphics/crosshairs64.png",
		size = 64,
		scale = 0.5
	}},
	small_icons = {{
		icon = mod.path .. "graphics/crosshairs64.png",
		size = 64,
		scale = 0.3
	}},
	action = "spawn-item",
	item_to_spawn = "orbital-ion-cannon-area-targeter",
	technology_to_unlock = mod.tech.area_fire,
	unavailable_until_unlocked = true,
	style = "red",
}}

data:extend({
	{
		type = "custom-input",
		name = "orbital-ion-cannon-area-targeter",
		key_sequence = ""
	}
})

-- ickputzdirwech (https://mods.factorio.com/mod/Shortcuts-ick), morley376 (https://mods.factorio.com/mod/Shortcuts)
