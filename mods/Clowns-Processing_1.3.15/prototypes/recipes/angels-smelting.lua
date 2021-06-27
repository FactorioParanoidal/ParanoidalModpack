local recipe={}
log(serpent.block(angelsmods.functions.get_object_icons("liquid-molten-brass")))
--set required triggers
angelsmods.trigger.smelting_products["iron"].plate = true
angelsmods.trigger.smelting_products["iron"].ingot = true
if mods["bobplates"] or (mods["angelsindustries"] and angelsmods.industries.overhaul) then
  angelsmods.trigger.smelting_products["manganese"].ingot = true
  --iron ingot recipes
  recipe[#recipe+1]=
  {
    type = "recipe",
    name = "molten-iron-smelting-6",
    category = "induction-smelting",
    subgroup = "angels-iron-casting",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type="item", name="ingot-iron", amount=12},
      {type="item", name="ingot-magnesium", amount=12},
      {type="item", name="ingot-manganese", amount=12},
    },
    results=
    {
      {type="fluid", name="liquid-molten-iron", amount=360},
    },
    icons = angelsmods.functions.add_number_icon_layer(
      angelsmods.functions.get_object_icons("liquid-molten-iron"),
      6, angelsmods.smelting.number_tint),
    order = "i[liquid-molten-iron]-f",
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-molten-iron"),
  }
else --include a magnesium sink for vanilla cases
  recipe[#recipe+1]=
  {
    type = "recipe",
    name = "molten-steel-smelting-c2",
    category = "induction-smelting",
    subgroup = "angels-steel-casting",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type="item", name="ingot-steel", amount=12},
      {type="item", name="ingot-magnesium", amount=12},
      {type="item", name="solid-white-phosphorus", amount=12},
    },
    results=
    {
      {type="fluid", name="liquid-molten-steel", amount=360},
    },
    icons =angelsmods.functions.add_number_icon_layer(
      angelsmods.functions.get_object_icons("liquid-molten-steel"),
      2, angelsmods.smelting.number_tint),
    order = "i[liquid-molten-iron]-b",
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-molten-steel"),
  }

end
--aluminium ingot recipes
if angelsmods.trigger.smelting_products["aluminium"].plate then
  recipe[#recipe+1]=
  {
    type = "recipe",
    name = "molten-aluminium-smelting-4",
    category = "induction-smelting",
    subgroup = "angels-aluminium-casting",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type="item", name="ingot-aluminium", amount=12},
      {type="item", name="ingot-magnesium", amount=12}
    },
    results=
    {
      {type="fluid", name="liquid-molten-aluminium", amount=240},
    },
    icons = angelsmods.functions.add_number_icon_layer(
      angelsmods.functions.get_object_icons("liquid-molten-aluminium"),
      3, angelsmods.smelting.number_tint),
    order = "i[liquid-molten-aluminium]-c",
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-molten-aluminium"),
  }
  if angelsmods.trigger.smelting_products["zinc"].plate then 
    recipe[#recipe+1]=
    {
      type = "recipe",
      name = "molten-aluminium-smelting-5",
      category = "induction-smelting",
      subgroup = "angels-aluminium-casting",
      energy_required = 4,
      enabled = false,
      ingredients =
      {
        {type="item", name="ingot-aluminium", amount=12},
        {type="item", name="ingot-magnesium", amount=12},
        {type="item", name="ingot-zinc", amount=12},
      },
      results=
      {
        {type="fluid", name="liquid-molten-aluminium", amount=360},
      },
      icons = angelsmods.functions.add_number_icon_layer(
        angelsmods.functions.get_object_icons("liquid-molten-aluminium"),
        5, angelsmods.smelting.number_tint),
      order = "i[liquid-molten-aluminium]-e",
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-molten-aluminium"),
    }
  end
end
--brass ingot recipes
if angelsmods.trigger.smelting_products["brass"].plate then
  log("beepClownsABS4")
    recipe[#recipe+1]=
    {
      type = "recipe",
      name = "angels-brass-smelting-4",
      category = "induction-smelting",
      subgroup = "angels-alloys-casting",
      energy_required = 4,
      enabled = false,
      ingredients =
      {
        {type="item", name="ingot-copper", amount=18},
        {type="item", name="ingot-zinc", amount=12},
        {type="item", name="solid-white-phosphorus", amount=6},
      },
      results=
      {
        {type="fluid", name="liquid-molten-brass", amount=360},
      },
      icons = angelsmods.functions.add_number_icon_layer(
        {{icon = "__angelssmelting__/graphics/icons/molten-brass.png",icon_size = 64, icon_mipmaps = 4, scale = 32/64}},
        4, angelsmods.smelting.number_tint),
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-molten-brass"),
      order = "b[brass]-a[liquid-molten-brass]-d",
    }
end
--titanium ingot recipes
if angelsmods.trigger.smelting_products["titanium"].plate then
  recipe[#recipe+1]=
  {
		type = "recipe",
		name = "sponge-magnesium-titanium-smelting",
		category = "chemical-smelting",
		subgroup = "angels-titanium",
		energy_required = 6,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="liquid-titanium-tetrachloride", amount=90},
			{type="item", name="solid-sodium", amount=8},
		},
		results=
		{
			{type="item", name="sponge-titanium", amount=24},
			{type="item", name="solid-salt", amount=8}
		},
		main_product= "sponge-titanium",
		icon_size = 32,
		order = "ea",
  }
  recipe[#recipe+1]=
  {
		type = "recipe",
		name = "pellet-magnesium-titanium-smelting",
		category = "chemical-smelting",
		subgroup = "angels-titanium",
		energy_required = 6,
		enabled = false,
		ingredients =
		{
			{type="item", name="pellet-titanium", amount=8},
			{type="item", name="ingot-magnesium", amount=6},
		},
		results=
		{
			{type="item", name="ingot-titanium", amount=30}, --drd 24
			--{type="item", name="magnesium-oremagnesium-ore", amount=6} --drd
		},
    main_product= "ingot-titanium",
    icons = angelsmods.functions.add_number_icon_layer(
      angelsmods.functions.get_object_icons("ingot-titanium"),
      3, angelsmods.smelting.number_tint),
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("ingot-titanium"),
    order = "f[ingot-titanium]-c",
  }
end
if #recipe >=1 then
  data:extend(recipe)
end
