
if data.raw.item["ion-cannon-targeter"].flags then
	table.insert(data.raw.item["ion-cannon-targeter"].flags, "only-in-cursor")
	table.insert(data.raw.item["ion-cannon-targeter"].flags, "spawnable")
else
	data.raw.item["ion-cannon-targeter"].flags = {"only-in-cursor", "spawnable"}
end
data:extend(
{
	{
		type = "shortcut",
		name = "ion-cannon-targeter",
		localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.ion-cannon-targeter"}, {"Shortcuts-ick.control-ion-cannon-targeter"}},
		order = "d[artillery]-e[ion-cannon-targeter]",
		--associated_control_input = "ion-cannon-targeter",
		action = "lua", -- script.on_event(defines.events.on_lua_shortcut,...)
		style = "red",
		icon =
		{
			filename = modFolder.."/graphics/ion-cannon-targeter-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		small_icon =
		{
			filename = modFolder.."/graphics/ion-cannon-targeter-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		},
	},
  {
		type = "custom-input",
	name = "ion-cannon-targeter",
		localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.ion-cannon-targeter"}},
		order = "d[artillery]-e[ion-cannon-targeter]",
	key_sequence = "",
  },
})

-- ickputzdirwech (https://mods.factorio.com/mod/Shortcuts-ick), morley376 (https://mods.factorio.com/mod/Shortcuts)