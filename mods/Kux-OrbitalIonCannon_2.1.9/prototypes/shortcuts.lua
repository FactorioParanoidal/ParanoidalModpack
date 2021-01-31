local newBaseVersion = Version.baseVersionGreaterOrEqual1d1()

data.raw.item["ion-cannon-targeter"].flags = data.raw.item["ion-cannon-targeter"].flags or {}
table.insert(data.raw.item["ion-cannon-targeter"].flags, "only-in-cursor")
if newBaseVersion then table.insert(data.raw.item["ion-cannon-targeter"].flags, "spawnable") end

local color = function (category, color, text)
	
end

data:extend({
    {
        type = "shortcut",
        name = "ion-cannon-targeter",
        localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"controls.ion-cannon-targeter"} },
        order = "d[artillery]-e[ion-cannon-targeter]",
        -- associated_control_input = "ion-cannon-targeter",
        action = "lua", -- script.on_event(defines.events.on_lua_shortcut,...)
        style = "red",
        icon = {
            filename = ModPath.."graphics/ion-cannon-targeter-x32-white.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 0.5,
            flags = {"gui-icon"}
        },
        small_icon = {
            filename = ModPath.."graphics/ion-cannon-targeter-x24-white.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 0.5,
            flags = {"gui-icon"}
        }
	},
})

data:extend({
	{
		type = "custom-input",
		name = "ion-cannon-targeter",
		key_sequence = ""
	}
})

-- ickputzdirwech (https://mods.factorio.com/mod/Shortcuts-ick), morley376 (https://mods.factorio.com/mod/Shortcuts)
