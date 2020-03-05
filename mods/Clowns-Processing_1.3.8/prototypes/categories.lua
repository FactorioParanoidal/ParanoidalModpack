data:extend(
{
	{
		type = "recipe-category",
		name = "sluicing"
	},
	--Most intermediates (raw material subgroup) seem to be like aa or something similar
	{
		type = "item-subgroup",
		name = "spacex",
		group = "intermediate-products",
		order = "b-c",
	},
	{
		type = "item-group",
		name = "equipment",
		order = "k",
		inventory_order = "k",
		icon = "__base__/graphics/technology/armor-making.png",
		icon_size = 128,
	},
	{
		type = "item-group",
		name = "fortifications",
		order = "k",
		inventory_order = "k",
		icon = "__base__/graphics/technology/turrets.png",
		icon_size = 128,
	},
	{
		type = "item-subgroup",
		name = "walls",
		group = "fortifications",
		order = "a-a",
	},
	{
		type = "item-subgroup",
		name = "armor",
		group = "equipment",
		order = "a",
	},
	{
		type = "item-subgroup",
		name = "power",
		group = "equipment",
		order = "b-a",
	},
	{
		type = "item-subgroup",
		name = "batteries",
		group = "equipment",
		order = "b-b",
	},
	{
		type = "item-subgroup",
		name = "shields",
		group = "equipment",
		order = "b-c",
	},
	{
		type = "item-subgroup",
		name = "personal-laser-defences",
		group = "equipment",
		order = "b-d",
	},
	{
		type = "item-subgroup",
		name = "misc1",
		group = "equipment",
		order = "b-e-a",
	},
	{
		type = "item-subgroup",
		name = "misc2",
		group = "equipment",
		order = "b-e-b",
	},
	{
		type = "item-subgroup",
		name = "vehicle-power1",--solar
		group = "equipment",
		order = "c-a-a",
	},
	{
		type = "item-subgroup",
		name = "vehicle-power2",--fusion cell
		group = "equipment",
		order = "c-a-b",
	},
	{
		type = "item-subgroup",
		name = "vehicle-power3",--fusion reactor
		group = "equipment",
		order = "c-a-c",
	},
	{
		type = "item-subgroup",
		name = "vehicle-batteries",
		group = "equipment",
		order = "c-b",
	},
	{
		type = "item-subgroup",
		name = "vehicle-shields",
		group = "equipment",
		order = "c-c",
	},
	{
		type = "item-subgroup",
		name = "vehicle-personal-laser-defences",
		group = "equipment",
		order = "c-d-a",
	},
	{
		type = "item-subgroup",
		name = "vehicle-plasma-cannons",
		group = "equipment",
		order = "c-d-b",
	},
	{
		type = "item-subgroup",
		name = "vehicle-misc1",
		group = "equipment",
		order = "c-e-a",
	},
	{
		type = "item-subgroup",
		name = "vehicle-misc2",
		group = "equipment",
		order = "c-e-b",
	},
	{
		type = "item-subgroup",
		name = "mines",
		group = "fortifications",
		order = "a-b",
	},
	{
		type = "item-subgroup",
		name = "gun-turrets",
		group = "fortifications",
		order = "b-a",
	},
	{
		type = "item-subgroup",
		name = "sniper-turrets",
		group = "fortifications",
		order = "b-b",
	},
	{
		type = "item-subgroup",
		name = "fluid-turrets",
		group = "fortifications",
		order = "b-f",
	},
	{
		type = "item-subgroup",
		name = "rocket-turrets",
		group = "fortifications",
		order = "b-d",
	},
	{
		type = "item-subgroup",
		name = "cannon-turrets",
		group = "fortifications",
		order = "b-e",
	},
	{
		type = "item-subgroup",
		name = "laser-turrets",
		group = "fortifications",
		order = "b-c",
	},
	{
		type = "item-subgroup",
		name = "artillery",
		group = "fortifications",
		order = "b-e",
	},
	{
		type = "item-subgroup",
		name = "radar",
		group = "fortifications",
		order = "c",
	},
	{
		type = "item-subgroup",
		name = "rocket",
		group = "fortifications",
		order = "d",
	},
	{
		type = "item-subgroup",
		name = "clowns-depleted-uranium",
		group = "angels-smelting",
		order = "ea",--Just after angels-copper (e)
	},
	{
		type = "item-subgroup",
		name = "clowns-magnesium",
		group = "angels-smelting",
		order = "ha",--Just after angels-lead (h)
	},
	{
		type = "item-subgroup",
		name = "clowns-osmium",
		group = "angels-smelting",
		order = "ja",--Just after angels-nickel (j)
	},
	{
		type = "item-subgroup",
		name = "clowns-phosphorus",
		group = "angels-smelting",
		order = "jb",
	},
	{
		type = "item-subgroup",
		name = "clowns-uranium",
		group = "angels-smelting",
		order = "pa",
	},
	{
		type = "item-subgroup",
		name = "clowns-magnesium-casting",
		group = "angels-casting",
		order = "ha",
	},
	{
		type = "item-subgroup",
		name = "clowns-osmium-casting",
		group = "angels-casting",
		order = "ja",
	},
	{
		type = "item-subgroup",
		name = "clowns-depleted-uranium-casting",
		group = "angels-casting",
		order = "ea",
	},
	{
		type = "item-subgroup",
		name = "clowns-electrolysis",
		group = "petrochem-refining",
		order = "caa",
	},
	{
		type = "item-subgroup",
		name = "clown-ores",
		group = "resource-refining",
		order = "ac",
	},
}
)