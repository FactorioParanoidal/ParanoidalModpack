local intermediatemulti = angelsmods.marathon.intermediatemulti
--lifted special recipe icon script from angels water treatment
local function create_recipe_icon(fluid_name, overlay_icon)
  if not overlay_icon then return angelsmods.functions.get_object_icons(fluid_name) end
  local icon_layers = util.table.deepcopy(angelsmods.functions.get_object_icons(overlay_icon))
  for layer_index, layer in pairs(icon_layers) do
    layer.shift = layer.shift or {}
    layer.shift = {(layer.shift[1] or 0)/2.3-9, (layer.shift[2] or 0)/2.3-9}
    layer.scale = (layer.scale or 1)/2.3
  end
  return angelsmods.functions.add_icon_layer(angelsmods.functions.get_object_icons(fluid_name), icon_layers)
end
data:extend(
{
--SALINATION
	{
		type = "recipe",
		name = "intermediate-salination",
		category = "salination-plant",
		subgroup = "water-salination",
		energy_required = 5,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="water-saline", amount=1000}
		},
		results=
		{
			{type="item", name="solid-salt", amount=10},
			{type="item", name="magnesium-ore", amount=5},
		},
		icons={
			{
				icon = "__angelsrefining__/graphics/icons/water-saline.png",
			},
			{
				icon = "__angelsrefining__/graphics/icons/solid-salt.png",
				scale = 0.4,
				shift = {-8, -8},
			},
			{
				icon = "__Clowns-Processing__/graphics/icons/magnesium-ore.png",
				scale = 0.4,
				shift = {8, -8},
			},
		},
		icon_size = 32,
		order = "f",
	},
	{
		type = "recipe",
		name = "advanced-salination",
		category = "salination-plant",
		subgroup = "water-salination",
		energy_required = 5,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="water-saline", amount=1000}
		},
		results=
		{
			{type="item", name="magnesium-ore", amount=10},
		},
		main_product= "",
		icons =create_recipe_icon("water-saline", "magnesium-ore"),
		order = "g",
	},
}
)
