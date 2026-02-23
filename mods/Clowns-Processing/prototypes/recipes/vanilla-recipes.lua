if angelsmods.trigger.smelting_products["lead"].plate == true then
  data:extend(
  {
    --------------
    -- MILITARY --
    --------------
    --alternative basic ammo
    {
      type = "recipe",
      name = "copper-nickel-firearm-magazine",
      energy_required = 1,
      enabled = false,
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
  }
  )
end
data:extend(
{
  --------------
  -- MILITARY --
  --------------
  --neurotixin-capsule
  {
    type = "recipe",
    name = "clowns-neurotoxin-capsule",
    category = "chemistry",
    enabled = false,
    energy_required = 4,
    ingredients =
    {
      {type = "fluid", name = "clowns-liquid-dimethylmercury", amount = 100},
      {type = "item", name = "steel-plate", amount = 2},
      {type = "item", name = "plastic-bar", amount = 5},
      {type = "item", name = "processing-unit", amount = 2},
    },
    results=
    {
      {type = "item", name = "clowns-neurotoxin-capsule", amount = 1},
    },
    icons = angelsmods.functions.get_object_icons("clowns-neurotoxin-capsule"),
    order = "m"
  },
  ---------------------------------
  -- DEPLETED URANIUM PROCESSING --
  ---------------------------------
  --processed
  {
    type = "recipe",
    name = "clowns-depleted-uranium-ore-processing",
    category = "angels-ore-processing-3",
    subgroup = "clowns-depleted-uranium",
    localised_name = {"item-name.clowns-processed-depleted-uranium"},
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "uranium-238", amount = 4 * 4} --4 is standard
    },
    results =
    {
      {type = "item", name = "clowns-processed-depleted-uranium", amount = 2},
    },
    icons = angelsmods.functions.get_object_icons("clowns-processed-depleted-uranium"),
    order = "a",
  },
  --pellet
  {
    type = "recipe",
    name = "clowns-depleted-uranium-processed-processing",
    category = "angels-pellet-pressing-2",
    localised_name = {"item-name.clowns-pellet-depleted-uranium"},
    subgroup = "clowns-depleted-uranium",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "clowns-processed-depleted-uranium", amount = 3}
    },
    results=
    {
      {type = "item", name = "clowns-pellet-depleted-uranium", amount = 4},
    },
    icons = angelsmods.functions.get_object_icons("clowns-pellet-depleted-uranium"),
    order = "b",
  },
  --ingot
  {
    type = "recipe",
    name = "clowns-depleted-uranium-pellet-smelting",
    category = "angels-blast-smelting-4",
    subgroup = "clowns-depleted-uranium",
    localised_name = {"item-name.clowns-powder-depleted-uranium"},
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "clowns-pellet-depleted-uranium", amount = 8},
    },
    results=
    {
      {type = "item", name = "clowns-powder-depleted-uranium", amount = 24},
    },
    icons = angelsmods.functions.get_object_icons("clowns-powder-depleted-uranium"),
    order = "d",
  },
  --powder
  {
    type = "recipe",
    name = "clowns-casting-powder-depleted-uranium-1",
    category = "angels-powder-mixing-3",
    subgroup = "clowns-depleted-uranium-casting",
    localised_name = {"item-name.clowns-casting-powder-depleted-uranium"},
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "clowns-powder-depleted-uranium", amount = 12},
    },
    results=
    {
      {type = "item", name = "clowns-casting-powder-depleted-uranium", amount = 12},
    },
    icons = angelsmods.functions.get_object_icons("clowns-casting-powder-depleted-uranium"),
    order = "e-a",
  },
  --powder-mix
  {
    type = "recipe",
    name = "clowns-casting-powder-depleted-uranium-2",
    category = "angels-powder-mixing-4",
    subgroup = "clowns-depleted-uranium-casting",
    localised_name = {"item-name.clowns-casting-powder-depleted-uranium"},
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "clowns-powder-depleted-uranium", amount = 12},
      {type = "item", name = "clowns-powder-osmium", amount = 12},
    },
    results =
    {
      {type = "item", name = "clowns-casting-powder-depleted-uranium", amount = 24},
    },
    icons = angelsmods.functions.get_object_icons("clowns-casting-powder-depleted-uranium"),
    order = "e-b",
  },
  {
    type = "recipe",
    name = "clowns-casting-powder-depleted-uranium-3",
    category = "angels-powder-mixing-4",
    subgroup = "clowns-depleted-uranium-casting",
    localised_name = {"item-name.clowns-casting-powder-depleted-uranium"},
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "clowns-powder-depleted-uranium", amount = 12},
      {type = "item", name = "angels-powder-aluminium", amount = 12},
    },
    results =
    {
      {type = "item", name = "clowns-casting-powder-depleted-uranium", amount = 24},
    },
    icons = angelsmods.functions.get_object_icons("clowns-casting-powder-depleted-uranium"),
    order = "e-c",
  },
  {
    type = "recipe",
    name = "clowns-casting-powder-depleted-uranium-4",
    category = "angels-powder-mixing-4",
    subgroup = "clowns-depleted-uranium-casting",
    localised_name = {"item-name.clowns-casting-powder-depleted-uranium"},
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "clowns-powder-depleted-uranium", amount = 12},
      {type = "item", name = "clowns-powder-osmium", amount = 12},
      {type = "item", name = "angels-powder-aluminium", amount = 12},
    },
    results =
    {
      {type = "item", name = "clowns-casting-powder-depleted-uranium", amount = 36},
    },
    icons = angelsmods.functions.get_object_icons("clowns-casting-powder-depleted-uranium"),
    order = "e-d",
  },
  --plate
  {
    type = "recipe",
    name = "clowns-plate-depleted-uranium",
    category = "angels-sintering-4",
    subgroup = "clowns-depleted-uranium-casting",
    enabled = false,
    energy_required = 4,
    ingredients =
    {
      {type = "item", name = "clowns-casting-powder-depleted-uranium", amount = 12}
    },
    results =
    {
      {type = "item", name = "clowns-plate-depleted-uranium", amount = 12}
    },
    icons = angelsmods.functions.get_object_icons("clowns-plate-depleted-uranium"),
    order = "f",
  },
  --------------------------
  -- MAGNESIUM PROCESSING --
  --------------------------
  --processed
	{
		type = "recipe",
		name = "clowns-magnesium-ore-processing",
		category = "angels-ore-processing-3",
		subgroup = "clowns-magnesium",
    localised_name = {"item-name.clowns-processed-magnesium"},
		energy_required = 2,
		enabled = false,
    ingredients =
    {
      {type = "item",name = "clowns-magnesium-ore", amount = 4}
    },
		results =
		{
			{type = "item", name = "clowns-processed-magnesium", amount = 2},
		},
    icons = angelsmods.functions.get_object_icons("clowns-processed-magnesium"),
		order = "a",
  },
  --pellet
  {
		type = "recipe",
		name = "clowns-magnesium-processed-processing",
		category = "angels-pellet-pressing-2",
		subgroup = "clowns-magnesium",
    localised_name = {"item-name.clowns-pellet-magnesium"},
		energy_required = 2,
		enabled = false,
    ingredients =
    {
      {type = "item", name = "clowns-processed-magnesium", amount = 3}
    },
		results =
		{
			{type = "item", name = "clowns-pellet-magnesium", amount = 4},
		},
    icons = angelsmods.functions.get_object_icons("clowns-pellet-magnesium"),
		order = "b",
  },
	--ingot
	{
		type = "recipe",
		name = "clowns-magnesium-pellet-smelting",
		category = "angels-blast-smelting-4",
		subgroup = "clowns-magnesium",
    localised_name = {"item-name.clowns-ingot-magnesium"},
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "clowns-pellet-magnesium", amount = 8},
			{type = "item", name = "angels-solid-coke", amount = 2},
			{type = "item", name = "angels-solid-limestone", amount = 2},
			{type = "fluid", name = "angels-liquid-hydrochloric-acid", amount = 30}
		},
		results =
		{
			{type = "item", name = "clowns-ingot-magnesium", amount = 24},
			{type = "item", name = "angels-solid-calcium-chloride", amount = 2},
		},
    icons = angelsmods.functions.get_object_icons("clowns-ingot-magnesium"),
		order = "d",
  },
	--molten
	{
		type = "recipe",
		name = "clowns-molten-magnesium-smelting",
		category = "angels-induction-smelting-4",
		subgroup = "clowns-magnesium-casting",
    localised_name = {"fluid-name.clowns-liquid-molten-magnesium"},
		energy_required = 4,
		enabled = false,
		ingredients =
		{
		  {type = "item", name = "clowns-ingot-magnesium", amount = 12},
		},
		results =
		{
		  {type = "fluid", name = "clowns-liquid-molten-magnesium", amount = 120},
		},
		order = "i",
  },
	--plate
	{
		type = "recipe",
		name = "clowns-plate-magnesium",
		category = "angels-casting-4",
		subgroup = "clowns-magnesium-casting",
    enabled = false,
    energy_required = 4,
    ingredients =
    {
      {type = "fluid", name = "clowns-liquid-molten-magnesium", amount = 40}
    },
    results =
    {
      {type = "item", name = "clowns-plate-magnesium", amount = 4}
    },
		order = "j",
  },
  -------------------------
  -- MERCURY PROCESSING --
  -------------------------
  --Mercury from thermal
  {
    type = "recipe",
    name = "clowns-thermal-filtering-mercury",
    category = "angels-water-treatment",
    subgroup = "angels-water-treatment",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {type = "fluid", name = "angels-thermal-water", amount = 100}
    },
    results =
    {
      {type = "fluid", name = "clowns-liquid-mercury", amount = 40},
      {type = "fluid", name = "angels-water-purified", amount = 60},
    },
    icons = angelsmods.functions.create_liquid_recipe_icon({
      "angels-water-purified",
      "clowns-liquid-mercury",
    }, {{238,113,22},{203,99,15},{167,78,13}}),
    order = "h"
  },
    --dimethyl
  {
    type = "recipe",
    name = "clowns-dimethylmercury-synthesis",
    category = "chemistry",
    subgroup = "angels-petrochem-chlorine",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {type = "fluid", name = "clowns-liquid-mercury", amount = 10},
      {type = "fluid", name = "angels-gas-chlor-methane", amount = 20},
      {type = "item", name = "angels-solid-sodium", amount = 2},
    },
    results =
    {
      {type = "fluid", name = "clowns-liquid-dimethylmercury", amount = 10},
      {type = "item", name = "angels-solid-salt", amount = 2},
    },
    icons = angelsmods.functions.create_viscous_liquid_recipe_icon(
      {"angels-solid-salt"},
      {{ 118, 141, 138 },{ 94, 113, 110 },{ 94, 113, 110 }}),
    order = "z"
  },
  -------------------------
  -- OSMIUM PROCESSING --
  -------------------------
  --processing
	{
		type = "recipe",
		name = "clowns-osmium-ore-processing",
		category = "angels-ore-processing",
		subgroup = "clowns-osmium",
    localised_name = {"item-name.clowns-processed-osmium"},
		energy_required = 2,
		enabled = false,
    ingredients =
    {
      {type = "item", name = "clowns-osmium-ore", amount = 4},
      {type="item", name="angels-solid-sodium-carbonate", amount=6},
    },
		results =
		{
			{type = "item", name = "clowns-processed-osmium", amount = 2},
		},
    icons = angelsmods.functions.get_object_icons("clowns-processed-osmium"),
		order = "a",
  },
  --pellet
  {
		type = "recipe",
		name = "clowns-osmium-processed-processing",
		category = "angels-pellet-pressing",
		subgroup = "clowns-osmium",
    localised_name = {"item-name.clowns-pellet-osmium"},
		energy_required = 2,
		enabled = false,
    ingredients =
    {
      {type = "item", name = "clowns-processed-osmium", amount = 3},
      {type = "item", name = "angels-solid-ammonium-perchlorate", amount = 6},
    },
		results =
		{
			{type = "item", name = "clowns-pellet-osmium", amount = 4},
		},
    icons = angelsmods.functions.get_object_icons("clowns-pellet-osmium"),
		order = "b",
  },
	--powder
	{
		type = "recipe",
		name = "clowns-osmium-pellet-smelting",
		category = "angels-blast-smelting",
		subgroup = "clowns-osmium",
		energy_required = 4,
    localised_name = {"item-name.clowns-powder-osmium"},
		enabled = false,
		ingredients =
		{
			{type = "item", name = "clowns-pellet-osmium", amount = 8},
		},
		results =
		{
			{type = "item", name = "clowns-powder-osmium", amount = 24},
			{type = "item", name = "angels-solid-salt", amount = 6},
		},
    icons = angelsmods.functions.get_object_icons("clowns-powder-osmium"),
		order = "d",
  },
	--powder-mix
	{
		type = "recipe",
		name = "clowns-casting-powder-osmium",
		category = "angels-powder-mixing",
		subgroup = "clowns-osmium-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "clowns-powder-osmium", amount = 8},
      {type = "item", name = "angels-solid-sodium-hydroxide", amount = 8},
		},
		results =
		{
			{type = "item", name = "clowns-casting-powder-osmium", amount = 16},
		},
    icons = angelsmods.functions.get_object_icons("clowns-casting-powder-osmium"),
		order = "a",
    },
	--plate
	{
		type = "recipe",
		name = "clowns-plate-osmium",
		category = "angels-sintering-4",
		subgroup = "clowns-osmium-casting",
    enabled = false,
    energy_required = 4,
    ingredients =
    {
      {type = "item", name = "clowns-casting-powder-osmium", amount = 12}
    },
    results =
    {
      {type = "item", name = "clowns-plate-osmium", amount = 12}
    },
    icons = angelsmods.functions.get_object_icons("clowns-plate-osmium"),
		order = "b",
  },
  ---------------------------
  -- PHOSPHORUS PROCESSING --
  ---------------------------
  --sorting
  {
    type = "recipe",
    name = "crushed-stone-sorting",
    category = "angels-ore-sorting",
    subgroup = "angels-ore-sorting-t1",
    order = "i",
    energy_required = 1,
    enabled = false,
    allow_decomposition = false,
    ingredients =
    {
      {type = "item", name = "angels-stone-crushed", amount = 20},
    },
    results =
    {
      {type = "item", name = "angels-slag", amount = 7},
      {type = "item", name = "clowns-phosphorus-ore", amount = 1},
    },
    icons =
    {
      { icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32, },
      {
        icon = "__angelsrefininggraphics__/graphics/icons/stone-crushed.png",
        icon_size = 32,
        scale = 0.5,
        shift = {8, 8},
      },
    },
  },
  --white phos from ore
  {
    type = "recipe",
    name = "clowns-white-phosphorus-smelting",
    category = "angels-chemical-smelting",
    subgroup = "clowns-phosphorus",
    order = "a",
    energy_required = 10,
    enabled = false,
    allow_decomposition = false,
    ingredients =
    {
      {type = "item", name = "clowns-phosphorus-ore", amount = 24},
      {type = "item", name = "angels-solid-sand", amount = 2},
      {type = "item", name = "angels-solid-carbon", amount = 2}
    },
    results =
    {
      {type = "item", name = "clowns-solid-white-phosphorus", amount = 24},--Should make phosphorus gas
      {type = "fluid", name = "angels-gas-carbon-monoxide", amount = 10}
    },
    icons = angelsmods.functions.get_object_icons("clowns-solid-white-phosphorus"),
  },
  --phosphoric acid
  {
    type = "recipe",
    name = "clowns-phosphoric-acid-1",
    category = "chemistry",
    subgroup = "clowns-phosphorus",
    order = "b",
    energy_required = 10,
    enabled = false,
    allow_decomposition = false,
    ingredients =
    {
      {type = "item", name = "clowns-phosphorus-ore", amount = 8},
      {type = "fluid", name = "angels-liquid-sulfuric-acid", amount = 10},
    },
    results =
    {
      {type = "fluid", name = "clowns-liquid-phosphoric-acid", amount = 10},
      {type = "item", name = "angels-solid-calcium-sulfate", amount = 1}
    },
    icons = angelsmods.functions.create_liquid_recipe_icon({"clowns-liquid-phosphoric-acid"}, {{ r = 244, g = 125, b = 001 },{ 242, 242, 242 },{ 214, 012, 012 }}),
  },
  --phosphoric acid 2
  {
    type = "recipe",
    name = "clowns-white-phosphorus-smelting-2",
    category = "angels-chemical-smelting-2",
    subgroup = "clowns-phosphorus",
    order = "a",
    energy_required = 10,
    enabled = false,
    allow_decomposition = false,
    ingredients =
    {
      {type = "item", name = "clowns-solid-white-phosphorus", amount = 24},--24 phosphorus ore
      {type = "fluid", name = "clowns-liquid-phosphoric-acid", amount = 10},--8 phosphorus ore
    },
    results =
    {
      {type = "fluid", name = "clowns-liquid-phosphoric-acid", amount = 60, ignored_by_productivity = 30},--48 phosphorus ore i.e. 33% productivity gain
    },
    icons = angelsmods.functions.create_solid_recipe_icon(nil, "clowns-liquid-phosphoric-acid", {"clowns-solid-white-phosphorus"}),
  },
  --------------------------
  -- MAGNESIUM SALINATION --
  --------------------------
  --magnesium from salt water
  {
		type = "recipe",
		name = "intermediate-salination",
		category = "angels-salination-plant",
		subgroup = "angels-water-salination",
		energy_required = 5,
		enabled = false,
		ingredients =
		{
			{type = "fluid", name = "angels-water-saline", amount = 1000}
		},
		results =
		{
			{type = "item", name = "angels-solid-salt", amount = 10},
			{type = "item", name = "clowns-magnesium-ore", amount = 5},
		},
    icons = angelsmods.functions.create_solid_recipe_icon({"angels-solid-salt"}, "clowns-magnesium-ore", {"angels-water-saline"}),
		order = "f",
	},
	{
		type = "recipe",
		name = "advanced-salination",
		category = "angels-salination-plant",
		subgroup = "angels-water-salination",
		energy_required = 5,
		enabled = false,
		ingredients =
		{
			{type = "fluid", name = "angels-water-saline", amount = 1000}
		},
		results =
		{
			{type = "item", name = "clowns-magnesium-ore", amount = 10},
		},
    icons = angelsmods.functions.create_solid_recipe_icon(nil, "clowns-magnesium-ore", {"angels-water-saline"}),
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
    ingredients = {
      {type = "item", name = "clowns-solid-uranium-hexafluoride", amount = 8} --20% less ingredients than vanilla
    },
    results = {
      {type = "item", name = "uranium-235", probability = 0.007, amount = 1},
      {type = "item", name = "uranium-238", probability = 0.993, amount = 1}
    },
    icons = {
      {icon = "__Clowns-Processing__/graphics/icons/advanced-uranium-processing.png", icon_size = 32,}
    },
    subgroup = "raw-material",
    order = "k-a",
  },
  --hexafluoride production
	{
		type = "recipe",
		name = "clowns-solid-uranium-hexafluoride",
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "f",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "clowns-solid-uranium-tetrafluoride", amount = 12},
			{type = "fluid", name = "clowns-gas-fluorine", amount = 10}
		},
		results =
		{
			{type = "item", name = "clowns-solid-uranium-hexafluoride", amount = 12}
		},
    icons = angelsmods.functions.get_object_icons("clowns-solid-uranium-hexafluoride"),
  },
  --tetrafluoride
	{
		type = "recipe",
		name = "clowns-solid-uranium-tetrafluoride",
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "e",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "clowns-solid-uranium-oxide", amount = 12},
			{type = "fluid", name = "angels-liquid-hydrofluoric-acid", amount = 10}
		},
		results =
		{
			{type = "item", name = "clowns-solid-uranium-tetrafluoride", amount = 12}
		},
    icons = angelsmods.functions.get_object_icons("clowns-solid-uranium-tetrafluoride"),
  },
  --uranium oxide
	{
		type = "recipe",
		name = "clowns-solid-uranium-oxide-1",
		category = "angels-chemical-smelting-3",
    localised_name = {"item-name.clowns-solid-uranium-oxide"},
		subgroup = "clowns-uranium",
		order = "c",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "uranium-ore", amount = 24},
			{type = "fluid", name = "angels-gas-hydrogen", amount = 40}
		},
		results =
		{
			{type = "item", name = "clowns-solid-uranium-oxide", amount = 24}
		},
    icons = angelsmods.functions.add_number_icon_layer(
      angelsmods.functions.get_object_icons("clowns-solid-uranium-oxide"),
      1, angelsmods.smelting.number_tint),
	},
	{
		type = "recipe",
		name = "clowns-solid-uranium-oxide-2",
		category = "angels-chemical-smelting-4",
		subgroup = "clowns-uranium",
		order = "d",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "clowns-solid-ammonium-diuranate", amount = 24},
			{type = "fluid", name = "angels-gas-hydrogen", amount = 40}
		},
		results =
		{
			{type = "item", name = "clowns-solid-uranium-oxide", amount = 24},
		},
    localised_name = {"item-name.clowns-solid-uranium-oxide"},
    icons = angelsmods.functions.add_number_icon_layer(
      angelsmods.functions.get_object_icons("clowns-solid-uranium-oxide"),
      2, angelsmods.smelting.number_tint),
  },
  --diuranate
	{
		type = "recipe",
		name = "clowns-solid-ammonium-diuranate",
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "b",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "clowns-solid-uranyl-nitrate", amount = 12},
			{type = "fluid", name = "angels-gas-ammonia", amount = 10}
		},
		results =
		{
			{type = "item", name = "clowns-solid-ammonium-diuranate", amount = 12}
		},
    icons = angelsmods.functions.get_object_icons("clowns-solid-ammonium-diuranate"),
  },
  --uranyl-nitrate
	{
		type = "recipe",
		name = "clowns-solid-uranyl-nitrate",
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "a",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type = "item", name = "uranium-ore", amount = 10},--20% less ingredients
			{type = "fluid", name = "angels-liquid-nitric-acid", amount = 10}
		},
		results =
		{
			{type = "item", name = "clowns-solid-uranyl-nitrate", amount = 12}
		},
    icons = angelsmods.functions.get_object_icons("clowns-solid-uranyl-nitrate"),
	},
  --Osmium Bullets
  {
    type = "recipe",
    name = "clowns-osmium-rounds-magazine",
    category = "advanced-crafting",
    subgroup = "ammo",
    energy_required = 10,
    enabled = false,
    allow_decomposition = false,
    ingredients = {
      {type="item",name="piercing-rounds-magazine",amount=1},
      {type="item",name="clowns-plate-osmium",amount=1}
    },
    results = {
      {type="item",name="clowns-osmium-rounds-magazine",amount=1}
    },
    icons = angelsmods.functions.get_object_icons("clowns-osmium-rounds-magazine"),
    order = "a[basic-clips]-d[osmium-rounds-magazine]"
  }
}
)