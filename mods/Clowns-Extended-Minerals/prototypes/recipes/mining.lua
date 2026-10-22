local time_parameter = 3

data:extend(
{
--BASIC
	{
	type = "recipe",
	name = "limestone-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__angelsrefininggraphics__/graphics/icons/solid-limestone.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="angels-solid-limestone", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 1.5 * time_parameter, --CONFIRM 1.5?
	subgroup = "raw-resource",
	order = "a",
	},
	{
	type = "recipe",
	name = "angels-stone-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__base__/graphics/icons/stone.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="stone", amount=1},
	},
	energy_required = 0.5 * time_parameter, --CONFIRM 1.5?
	subgroup = "raw-resource",
	order = "a",
	},
	{
	type = "recipe",
	name = "coal-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__base__/graphics/icons/coal.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="coal", amount=1},
	{type="item", name="angels-slag", amount=1},
	},
	energy_required = 4 * time_parameter, --CONFIRM?
	subgroup = "raw-resource",
	order = "a",
	},
--Sapharite Mining
	{
	type = "recipe",
	name = "angels-ore1-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__angelsrefininggraphics__/graphics/icons/angels-ore1.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="angels-ore1", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 1.5 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},
--Jivolite Mining
	{
	type = "recipe",
	name = "angels-ore2-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__angelsrefininggraphics__/graphics/icons/angels-ore2.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="angels-ore2", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 2 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},
--Stiratite Mining
	{
	type = "recipe",
	name = "angels-ore3-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__angelsrefininggraphics__/graphics/icons/angels-ore3.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="angels-ore3", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 2 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},
--Crotinnium Mining
	{
	type = "recipe",
	name = "angels-ore4-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__angelsrefininggraphics__/graphics/icons/angels-ore4.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="angels-ore4", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 2 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},
--Rubyte Mining
	{
	type = "recipe",
	name = "angels-ore5-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__angelsrefininggraphics__/graphics/icons/angels-ore5.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="angels-ore5", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 2.5 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},
--Bobmonium Mining
	{
	type = "recipe",
	name = "angels-ore6-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__angelsrefininggraphics__/graphics/icons/angels-ore6.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="angels-ore6", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 2.5 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},
--CLOWN MINERAL MINING
	{
	type = "recipe",
	name = "clowns-ore1-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-ore1.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="clowns-ore1", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 1 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},
	--[[{
	type = "recipe",
	name = "clowns-ore6-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-ore6-ore.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="clowns-ore6", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 1 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},]]
	{
	type = "recipe",
	name = "clowns-ore3-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-ore3.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="clowns-ore3", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 1 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},
	{
	type = "recipe",
	name = "clowns-ore4-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-ore4.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="clowns-ore4", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 1 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},
	{
	type = "recipe",
	name = "clowns-ore5-mining",
	category = "shaft-mining",
	hidden = false,
	icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-ore5.png",
	icon_size = 32,
	ingredients = {},
	results =
	{
	{type="item", name="clowns-ore5", amount=1},
	{type="item", name="angels-slag", amount=2},
	},
	energy_required = 1 * time_parameter,
	subgroup = "raw-resource",
	order = "a",
	},
--Rare Stuff Mining
}
)