local recipe={}
--set required triggers
angelsmods.trigger.smelting_products["iron"].plate = true
angelsmods.trigger.smelting_products["iron"].ingot = true
  angelsmods.trigger.smelting_products["manganese"].ingot = true
  --iron ingot recipes
  recipe[#recipe+1]=
  {
    type = "recipe",
    name = "molten-iron-smelting-6",
    category = "angels-induction-smelting",
    subgroup = "angels-iron-casting",
    localised_name = {"fluid-name.angels-liquid-molten-iron"},
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type="item", name="angels-ingot-iron", amount=12},
      {type="item", name="clowns-ingot-magnesium", amount=12},
      {type="item", name="angels-ingot-manganese", amount=12},
    },
    results=
    {
      {type="fluid", name="angels-liquid-molten-iron", amount=360},
    },
    icons = angelsmods.functions.add_number_icon_layer(
      angelsmods.functions.get_object_icons("angels-liquid-molten-iron"),
      6, angelsmods.smelting.number_tint),
    order = "i[liquid-molten-iron]-f",
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-molten-iron"),
  }
 --include a magnesium sink for vanilla cases
  recipe[#recipe+1]=
  {
    type = "recipe",
    name = "molten-steel-smelting-c2",
    category = "angels-induction-smelting-2",
    subgroup = "angels-steel-casting",
    localised_name = {"fluid-name.angels-liquid-molten-steel"},
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type="item", name="angels-ingot-steel", amount=12},
      {type="item", name="clowns-ingot-magnesium", amount=12},
      {type="item", name="clowns-solid-white-phosphorus", amount=12},
    },
    results=
    {
      {type="fluid", name="angels-liquid-molten-steel", amount=360},
    },
    icons =angelsmods.functions.add_number_icon_layer(
      angelsmods.functions.get_object_icons("angels-liquid-molten-steel"),
      2, angelsmods.smelting.number_tint),
    order = "i[liquid-molten-iron]-b",
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-molten-steel"),
  }
--aluminium ingot recipes
if angelsmods.trigger.smelting_products["aluminium"].plate then
  recipe[#recipe+1]=
  {
    type = "recipe",
    name = "molten-aluminium-smelting-4",
    category = "angels-induction-smelting",
    subgroup = "angels-aluminium-casting",
    localised_name = {"fluid-name.angels-liquid-molten-aluminium"},
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type="item", name="angels-ingot-aluminium", amount=12},
      {type="item", name="clowns-ingot-magnesium", amount=12}
    },
    results=
    {
      {type="fluid", name="angels-liquid-molten-aluminium", amount=240},
    },
    icons = angelsmods.functions.add_number_icon_layer(
      angelsmods.functions.get_object_icons("angels-liquid-molten-aluminium"),
      4, angelsmods.smelting.number_tint),
    order = "i[liquid-molten-aluminium]-c",
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-molten-aluminium"),
  }
  if angelsmods.trigger.smelting_products["zinc"].plate then 
    recipe[#recipe+1]=
    {
      type = "recipe",
      name = "molten-aluminium-smelting-5",
      category = "angels-induction-smelting",
      subgroup = "angels-aluminium-casting",
      localised_name = {"fluid-name.angels-liquid-molten-aluminium"},
      energy_required = 4,
      enabled = false,
      ingredients =
      {
        {type="item", name="angels-ingot-aluminium", amount=12},
        {type="item", name="clowns-ingot-magnesium", amount=12},
        {type="item", name="angels-ingot-zinc", amount=12},
      },
      results=
      {
        {type="fluid", name="angels-liquid-molten-aluminium", amount=360},
      },
      icons = angelsmods.functions.add_number_icon_layer(
        angelsmods.functions.get_object_icons("angels-liquid-molten-aluminium"),
        5, angelsmods.smelting.number_tint),
      order = "i[liquid-molten-aluminium]-e",
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-molten-aluminium"),
    }
  end
end
--brass ingot recipes
if angelsmods.trigger.smelting_products["brass"].plate then
    recipe[#recipe+1]=
    {
      type = "recipe",
      name = "angels-brass-smelting-4",
      category = "angels-induction-smelting",
      subgroup = "angels-alloys-casting",
      localised_name = {"fluid-name.angels-liquid-molten-brass"},
      energy_required = 4,
      enabled = false,
      ingredients =
      {
        {type="item", name="angels-ingot-copper", amount=18},
        {type="item", name="angels-ingot-zinc", amount=12},
        {type="item", name="clowns-solid-white-phosphorus", amount=6},
      },
      results=
      {
        {type="fluid", name="angels-liquid-molten-brass", amount=360},
      },
      icons = angelsmods.functions.add_number_icon_layer(
        {{icon = "__angelssmeltinggraphics__/graphics/icons/molten-brass.png",icon_size = 64, icon_mipmaps = 4, scale = 32/64}},
        4, angelsmods.smelting.number_tint),
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-molten-brass"),
      order = "b[brass]-a[liquid-molten-brass]-d",
    }
end
--titanium ingot recipes
if angelsmods.trigger.smelting_products["titanium"].plate then
  recipe[#recipe+1]=
  {
		type = "recipe",
		name = "angels-sponge-magnesium-titanium-smelting",
		category = "angels-chemical-smelting",
		subgroup = "angels-titanium",
    localised_name = {"item-name.angels-sponge-titanium"},
		energy_required = 6,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="angels-liquid-titanium-tetrachloride", amount=90},
			{type="item", name="angels-solid-sodium", amount=8},
		},
		results=
		{
			{type="item", name="angels-sponge-titanium", amount=24},
			{type="item", name="angels-solid-salt", amount=8}
		},
		main_product= "angels-sponge-titanium",
		icon_size = 32,
		order = "ea",
  }
  recipe[#recipe+1]=
  {
		type = "recipe",
		name = "angels-pellet-magnesium-titanium-smelting",
		category = "angels-chemical-smelting",
		subgroup = "angels-titanium",
    localised_name = {"item-name.angels-ingot-titanium"},
		energy_required = 6,
		enabled = false,
		ingredients =
		{
			{type="item", name="angels-pellet-titanium", amount=8},
			{type="item", name="clowns-ingot-magnesium", amount=6},
		},
		results=
		{
			{type="item", name="angels-ingot-titanium", amount=24},
			{type="item", name="clowns-magnesium-ore", amount=6}
		},
    main_product= "angels-ingot-titanium",
    icons = angelsmods.functions.add_number_icon_layer(
      angelsmods.functions.get_object_icons("angels-ingot-titanium"),
      3, angelsmods.smelting.number_tint),
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-ingot-titanium"),
    order = "f[ingot-titanium]-c",
  }
end
if #recipe >=1 then
  data:extend(recipe)
end
