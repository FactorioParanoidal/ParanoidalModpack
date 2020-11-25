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
  --------------
  -- MILITARY --
  --------------
  --neurotixin-capsule
  {
    type = "recipe",
    name = "neurotoxin-capsule",
    category = "chemistry",
    enabled = false,
    energy_required = 4,
    ingredients =
    {
      {type = "fluid", name = "liquid-dimethylmercury", amount = 100},
      {type = "item", name = "steel-plate", amount = 2},
      {type = "item", name = "plastic-bar", amount = 5},
      {type = "item", name = "processing-unit", amount = 2},
    },
    results=
    {
      {type = "item", name = "neurotoxin-capsule", amount = 1},
    },
    icon_size = 32,
  },
  --alternative basic ammo
  {
    type = "recipe",
    name = "copper-nickel-firearm-magazine",
    energy_required = 1,
    ingredients = 
    {
      {type = "item", name = "copper-plate", amount = 3},
      {type = "item", name = "angels-plate-lead", amount = 2}
    },
    results =
    {
      {type = "item", name = "firearm-magazine", amount =  1}
    }
  },
  ---------------------------------
  -- DEPLETED URANIUM PROCESSING --
  ---------------------------------
  --processed
  {
    type = "recipe",
    name = "depleted-uranium-ore-processing",
    category = "ore-processing",
    subgroup = "clowns-depleted-uranium",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "uranium-238", amount = 4 * 4} --4 is standard
    },
    results =
    {
      {type = "item", name = "processed-depleted-uranium", amount = 2},
    },
    order = "a",
  },
  --pellet
  {
    type = "recipe",
    name = "depleted-uranium-processed-processing",
    category = "pellet-pressing",
    subgroup = "clowns-depleted-uranium",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "processed-depleted-uranium", amount = 3}
    },
    results=
    {
      {type = "item", name = "pellet-depleted-uranium", amount = 4},
    },
    order = "b",
  },
  --ingot
  {
    type = "recipe",
    name = "depleted-uranium-pellet-smelting",
    category = "blast-smelting",
    subgroup = "clowns-depleted-uranium",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "pellet-depleted-uranium", amount = 8},
    },
    results=
    {
      {type = "item", name = "powder-depleted-uranium", amount = 24},
    },
    order = "d",
  },
  --powder
  {
    type = "recipe",
    name = "casting-powder-depleted-uranium-1",
    category = "powder-mixing",
    subgroup = "clowns-depleted-uranium-casting",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "powder-depleted-uranium", amount = 12},
    },
    results=
    {
      {type = "item", name = "casting-powder-depleted-uranium", amount = 12},
    },
    icon_size = 32,
    order = "e-a",
  },
  --powder-mix
  {
    type = "recipe",
    name = "casting-powder-depleted-uranium-2",
    category = "powder-mixing",
    subgroup = "clowns-depleted-uranium-casting",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "powder-depleted-uranium", amount = 12},
      {type = "item", name = "powder-osmium", amount = 12},
    },
    results =
    {
      {type = "item", name = "casting-powder-depleted-uranium", amount = 24},
    },
    icon_size = 32,
    order = "e-b",
  },
  {
    type = "recipe",
    name = "casting-powder-depleted-uranium-3",
    category = "powder-mixing",
    subgroup = "clowns-depleted-uranium-casting",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "powder-depleted-uranium", amount = 12},
      {type = "item", name = "powder-aluminium", amount = 12},
    },
    results =
    {
      {type = "item", name = "casting-powder-depleted-uranium", amount = 24},
    },
    icon_size = 32,
    order = "e-c",
  },
  {
    type = "recipe",
    name = "casting-powder-depleted-uranium-4",
    category = "powder-mixing",
    subgroup = "clowns-depleted-uranium-casting",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "powder-depleted-uranium", amount = 12},
      {type = "item", name = "powder-osmium", amount = 12},
      {type = "item", name = "powder-aluminium", amount = 12},
    },
    results =
    {
      {type = "item", name = "casting-powder-depleted-uranium", amount = 36},
    },
    icon_size = 32,
    order = "e-d",
  },
  --plate
  {
    type = "recipe",
    name = "clowns-plate-depleted-uranium",
    category = "sintering",
    subgroup = "clowns-depleted-uranium-casting",
    normal =
    {
      enabled = false,
      energy_required = 4,
      ingredients =
      {
        {type = "item", name = "casting-powder-depleted-uranium", amount = 12}
      },
      results =
      {
        {type = "item", name = "clowns-plate-depleted-uranium", amount = 12}
      },
    },
    expensive =
    {
      enabled = false,
      energy_required = 4,
      ingredients =
      {
        {type = "item", name = "casting-powder-depleted-uranium", amount = 15 * intermediatemulti}
      },
      results=
      {
        {type = "item", name = "clowns-plate-depleted-uranium", amount = 12}
      },
    },
    icon_size = 32,
    order = "f",
  },
  --------------------------
  -- MAGNESIUM PROCESSING --
  --------------------------
  --processed
	{
		type = "recipe",
		name = "magnesium-ore-processing",
		category = "ore-processing",
		subgroup = "clowns-magnesium",
		energy_required = 2,
		enabled = false,
    ingredients =
    {
      {type = "item",name = "magnesium-ore", amount = 4}
    },
		results =
		{
			{type = "item", name = "processed-magnesium", amount = 2},
		},
		order = "a",
  },
  --pellet
  {
		type = "recipe",
		name = "magnesium-processed-processing",
		category = "pellet-pressing",
		subgroup = "clowns-magnesium",
		energy_required = 2,
		enabled = false,
    ingredients =
    {
      {type = "item", name = "processed-magnesium", amount = 3}
    },
		results =
		{
			{type = "item", name = "pellet-magnesium", amount = 4},
		},
		order = "b",
  },
	--ingot
	{
		type = "recipe",
		name = "magnesium-pellet-smelting",
		category = "blast-smelting",
		subgroup = "clowns-magnesium",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "pellet-magnesium", amount = 8},
			{type = "item", name = "solid-coke", amount = 2},
			{type = "item", name = "solid-limestone", amount = 2},
			{type = "fluid", name = "liquid-hydrochloric-acid", amount = 30}
		},
		results =
		{
			{type = "item", name = "ingot-magnesium", amount = 24},
			{type = "item", name = "solid-calcium-chloride", amount = 2},
		},
		icon = "__Clowns-Processing__/graphics/icons/ingot-magnesium.png",
		icon_size = 32,
		order = "d",
  },
	--molten
	{
		type = "recipe",
		name = "molten-magnesium-smelting",
		category = "induction-smelting",
		subgroup = "clowns-magnesium-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
		  {type = "item", name = "ingot-magnesium", amount = 12},
		},
		results =
		{
		  {type = "fluid", name = "liquid-molten-magnesium", amount = 120},
		},
		icon_size = 32,
		order = "i",
  },
	--plate
	{
		type = "recipe",
		name = "clowns-plate-magnesium",
		category = "casting",
		subgroup = "clowns-magnesium-casting",
		normal =
		{
			enabled = false,
			energy_required = 4,
      ingredients =
      {
        {type = "fluid", name = "liquid-molten-magnesium", amount = 40}
      },
      results =
      {
        {type = "item", name = "clowns-plate-magnesium", amount = 4}
      },
		},
		expensive =
		{
			enabled = false,
			energy_required = 4,
      ingredients =
      {
        {type = "fluid", name = "liquid-molten-magnesium", amount = 50 * intermediatemulti}
      },
      results =
      {
        {type = "item", name = "clowns-plate-magnesium", amount = 4}
      },
		},
		icon_size = 32,
		order = "j",
  },
  -------------------------
  -- MERCURY PROCESSING --
  -------------------------
  --Mercury from thermal
	{
		type = "recipe",
		name = "thermal-filtering-mercury",
		category = "water-treatment",
		subgroup = "water-treatment",
		enabled = false,
		energy_required = 1,
		ingredients =
		{
		  {type = "fluid", name = "thermal-water", amount = 100}
		},
		results =
		{
		  {type = "fluid", name = "liquid-mercury", amount = 40},
		  {type = "fluid", name = "water-purified", amount = 60},
		},
		icons = angelsmods.functions.create_liquid_recipe_icon({
			"water-purified",
			{"__Clowns-Processing__/graphics/icons/liquid-mercury.png",icon_size=32},
		}, {{238,113,22},{203,99,15},{167,78,13}}),
		order = "h"
	},
	--dimethyl
	{
		type = "recipe",
		name = "dimethylmercury-synthesis",
		category = "chemistry",
		subgroup = "petrochem-chlorine",
		enabled = false,
		energy_required = 10,
		ingredients =
		{
			{type = "fluid", name = "liquid-mercury", amount = 10},
			{type = "fluid", name = "gas-chlor-methane", amount = 20},
			{type = "item", name = "solid-sodium", amount = 2},
		},
		results =
		{
			{type = "fluid", name = "liquid-dimethylmercury", amount = 10},
			{type = "item", name = "solid-salt", amount = 2},
		},
		icons =
		{
			{icon = "__Clowns-Processing__/graphics/icons/liquid-dimethylmercury.png"},
		},
		icon_size = 32,
		order = "z"
  },
  -------------------------
  -- OSMIUM PROCESSING --
  -------------------------
  --processing
	{
		type = "recipe",
		name = "osmium-ore-processing",
		category = "ore-processing",
		subgroup = "clowns-osmium",
		energy_required = 2,
		enabled = false,
    ingredients =
    {
      {type = "item", name = "osmium-ore", amount = 4}
    },
		results =
		{
			{type = "item", name = "processed-osmium", amount = 2},
		},
		order = "a",
  },
  --pellet
  {
		type = "recipe",
		name = "osmium-processed-processing",
		category = "pellet-pressing",
		subgroup = "clowns-osmium",
		energy_required = 2,
		enabled = false,
    ingredients =
    {
      {type = "item", name = "processed-osmium", amount = 3}
    },
		results =
		{
			{type = "item", name = "pellet-osmium", amount = 4},
		},
		order = "b",
  },
	--powder
	{
		type = "recipe",
		name = "osmium-pellet-smelting",
		category = "blast-smelting",
		subgroup = "clowns-osmium",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "pellet-osmium", amount = 8},
		},
		results =
		{
			{type = "item", name = "powder-osmium", amount = 24},
		},
		order = "d",
  },
	--powder-mix
	{
		type = "recipe",
		name = "casting-powder-osmium",
		category = "powder-mixing",
		subgroup = "clowns-osmium-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "powder-osmium", amount = 12},
			--{type="item", name="powder-platinum", amount=12},
		},
		results =
		{
			{type = "item", name = "casting-powder-osmium", amount = 12},
		},
		icon_size = 32,
		order = "a",
    },
	--plate
	{
		type = "recipe",
		name = "clowns-plate-osmium",
		category = "sintering",
		subgroup = "clowns-osmium-casting",
		normal =
		{
			enabled = false,
			energy_required = 4,
      ingredients =
      {
        {type = "item", name = "casting-powder-osmium", amount = 12}
      },
      results =
      {
        {type = "item", name = "clowns-plate-osmium", amount = 12}
      },
		},
		expensive =
		{
			enabled = false,
			energy_required = 4,
      ingredients =
      {
        {type = "item", name = "casting-powder-osmium", amount = 15 * intermediatemulti}
      },
      results =
      {
        {type = "item", name = "clowns-plate-osmium", amount = 12}
      },
		},
		icon_size = 32,
		order = "b",
  },
  ---------------------------
  -- PHOSPHORUS PROCESSING --
  ---------------------------
  --sorting
  {
    type = "recipe",
    name = "crushed-stone-sorting",
    icons =
    {
      {
        icon = "__Clowns-Processing__/graphics/icons/sorting.png"
      },
      {
        icon = "__angelsrefining__/graphics/icons/stone-crushed.png",
        scale = 0.5,
        shift = {8, 8},
      },
    },
    icon_size = 32,
    category = "ore-sorting",
    subgroup = "ore-sorting-t1",
    order = "i",
    energy_required = 1,
    enabled = false,
    allow_decomposition = false,
    ingredients =
    {
      {type = "item", name = "stone-crushed", amount = 20},
    },
    results =
    {
      {type = "item", name = "slag", amount = 7},
      {type = "item", name = "phosphorus-ore", amount = 1},
    },
  },
  --white phos from ore
  {
    type = "recipe",
    name = "white-phosphorus-smelting",
    icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
    icon_size = 32,
    category = "chemical-smelting",
    subgroup = "clowns-phosphorus",
    order = "a",
    energy_required = 10,
    enabled = false,
    allow_decomposition = false,
    ingredients =
    {
      {type = "item", name = "phosphorus-ore", amount = 24},
      {type = "item", name = "solid-sand", amount = 2},
      {type = "item", name = "solid-carbon", amount = 2}
    },
    results =
    {
      {type = "item", name = "solid-white-phosphorus", amount = 24},--Should make phosphorus gas
      {type = "fluid", name = "gas-carbon-monoxide", amount = 10}
    },
  },
  --phosphoric acid
  {
    type = "recipe",
    name = "phosphoric-acid-1",
    icons =angelsmods.functions.create_liquid_recipe_icon({"liquid-phosphoric-acid"}, {{ r = 244, g = 125, b = 001 },{ 242, 242, 242 },{ 214, 012, 012 }}), 
    category = "chemistry",
    subgroup = "clowns-phosphorus",
    order = "b",
    energy_required = 10,
    enabled = false,
    allow_decomposition = false,
    ingredients =
    {
      {type = "item", name = "phosphorus-ore", amount = 8},
      {type = "fluid", name = "liquid-sulfuric-acid", amount = 10},
    },
    results =
    {
      {type = "fluid", name = "liquid-phosphoric-acid", amount = 10},
      {type = "item", name = "solid-calcium-sulfate", amount = 1}
    },
  },
  --phosphoric acid 2
  {
    type = "recipe",
    name = "white-phosphorus-smelting-2",
    icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
    icon_size = 32,
    category = "chemical-smelting",
    subgroup = "clowns-phosphorus",
    order = "a",
    energy_required = 10,
    enabled = false,
    allow_decomposition = false,
    ingredients =
    {
      {type = "item", name = "solid-white-phosphorus", amount = 24},--24 phosphorus ore
      {type = "fluid", name = "liquid-phosphoric-acid", amount = 10},--8 phosphorus ore
    },
    results =
    {
      {type = "fluid", name = "liquid-phosphoric-acid", amount = 60},--48 phosphorus ore i.e. 33% productivity gain
    },
  },
  --------------------------
  -- MAGNESIUM SALINATION --
  --------------------------
  --magnesium from salt water
  {
		type = "recipe",
		name = "intermediate-salination",
		category = "salination-plant",
		subgroup = "water-salination",
		energy_required = 5,
		enabled = false,
		ingredients =
		{
			{type = "fluid", name = "water-saline", amount = 1000}
		},
		results =
		{
			{type = "item", name = "solid-salt", amount = 10},
			{type = "item", name = "magnesium-ore", amount = 5},
		},
		icons = {
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
			{type = "fluid", name = "water-saline", amount = 1000}
		},
		results =
		{
			{type = "item", name = "magnesium-ore", amount = 10},
		},
		main_product = "",
		icons = create_recipe_icon("water-saline", "magnesium-ore"),
		order = "g",
	},
  ----------------------------
  -- URANIUM ORE PROCESSING --
  ----------------------------
  	--uranium from hexa
	{
    type = "recipe",
    name = "advanced-uranium-processing",
    energy_required = 5,--50% faster than vanilla
    enabled = false,
    category = "centrifuging",
    ingredients = 
    {
      {type = "item", name = "solid-uranium-hexafluoride", amount = 8} --20% less ingredients than vanilla
    },
    icons = 
    {
      {icon = "__Clowns-Processing__/graphics/icons/advanced-uranium-processing.png", icon_size = 32,}
    },
    icon_size=32,
    subgroup = "raw-material",
    order = "k-a",
    results =
    {
      {type = "item", name = "uranium-235", probability = 0.007, amount = 1},
      {type = "item", name = "uranium-238", probability = 0.993, amount = 1}
    }
  },
  --hexafluoride production
	{
		type = "recipe",
		name = "solid-uranium-hexafluoride",
		icon = "__Clowns-Processing__/graphics/icons/solid-uranium-hexafluoride.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "f",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "solid-uranium-tetrafluoride", amount = 12},
			{type = "fluid", name = "gas-fluorine", amount = 10}
		},
		results =
		{
			{type = "item", name = "solid-uranium-hexafluoride", amount = 12}
		},
  },
  --tetrafluoride
	{
		type = "recipe",
		name = "solid-uranium-tetrafluoride",
		icon = "__Clowns-Processing__/graphics/icons/solid-uranium-tetrafluoride.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "e",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "solid-uranium-oxide", amount = 12},
			{type = "fluid", name = "liquid-hydrofluoric-acid", amount = 10}
		},
		results =
		{
			{type = "item", name = "solid-uranium-tetrafluoride", amount = 12}
		},
  },
  --uranium oxide
	{
		type = "recipe",
		name = "solid-uranium-oxide-1",
		icon = "__Clowns-Processing__/graphics/icons/solid-uranium-oxide.png",
		icon_size = 32,
		category = "chemical-smelting",
		subgroup = "clowns-uranium",
		order = "a",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "uranium-ore", amount = 24},
			{type = "fluid", name = "gas-hydrogen", amount = 40}
		},
		results =
		{
			{type = "item", name = "solid-uranium-oxide", amount = 24}
		},
	},
	{
		type = "recipe",
		name = "solid-uranium-oxide-2",
		icon = "__Clowns-Processing__/graphics/icons/solid-uranium-oxide.png",
		icon_size = 32,
		category = "chemical-smelting",
		subgroup = "clowns-uranium",
		order = "d",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "solid-ammonium-diuranate", amount = 24},
			{type = "fluid", name = "gas-hydrogen", amount = 40}
		},
		results =
		{
			{type = "item", name = "solid-uranium-oxide", amount = 24},
		},
  },
  --diuranate
	{
		type = "recipe",
		name = "solid-ammonium-diuranate",
		icon = "__Clowns-Processing__/graphics/icons/solid-ammonium-diuranate.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "c",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "solid-uranyl-nitrate", amount = 12},
			{type = "fluid", name = "gas-ammonia", amount = 10}
		},
		results =
		{
			{type = "item", name = "solid-ammonium-diuranate", amount = 12}
		},
  },
  --uranyl-nitrate
	{
		type = "recipe",
		name = "solid-uranyl-nitrate",
		icon = "__Clowns-Processing__/graphics/icons/solid-uranyl-nitrate.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "b",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "uranium-ore", amount = 10},--20% less ingredients
			{type = "fluid", name = "liquid-nitric-acid", amount = 10}
		},
		results =
		{
			{type = "item", name = "solid-uranyl-nitrate", amount = 12}
		},
	},
}
)