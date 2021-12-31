local function add_water_casting_recipe(metal)
  data:extend({
    {
      type = "recipe",
      name = "angels-shielding-coil-" .. metal .. "-casting",
      category = "strand-casting",
      subgroup = "angels-" .. metal .. "-casting" or "angels-alloys-casting",
      energy_required = 4,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "liquid-molten-" .. metal, amount = 40 },
        { type = "fluid", name = "liquid-molten-copper", amount = 40 },
        { type = "fluid", name = "water", amount = 40 }
      },
      results =
      {
        { type = "item", name = "angels-shielding-coil-" .. metal, amount = 4 },
      },
      icons = angelsmods.functions.add_number_icon_layer(angelsmods.functions.get_object_icons("angels-shielding-coil-" .. metal), 1 , angelsmods.smelting.number_tint),
    }
  })
end

local function add_coolant_casting_recipe(metal)
  data:extend({
    {
      type = "recipe",
      name = "angels-shielding-coil-" .. metal .. "-casting-fast",
      category = "strand-casting",
      subgroup = "angels-" .. metal .. "-casting" or "angels-alloys-casting",
      energy_required = 2,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "liquid-molten-" .. metal, amount = 70 },
        { type = "fluid", name = "liquid-molten-copper", amount = 70 },
        { type = "fluid", name = "liquid-coolant", amount = 40 }
      },
      results =
      {
        { type = "item", name = "angels-shielding-coil-" .. metal, amount = 8 },
        { type = "fluid", name = "liquid-coolant-used", amount = 40, temperature = 300 }
      },
      main_product = "angels-shielding-coil-" .. metal,
      icons = angelsmods.functions.add_number_icon_layer(angelsmods.functions.get_object_icons("angels-shielding-coil-" .. metal), 2 , angelsmods.smelting.number_tint),
    }
  })
end

local function add_cutting_recipe(metal, tier)
  data:extend({
    {
      type = "recipe",
      name = "angels-shielding-coil-" .. metal .. "-converting",
      category = mods["bobelectronics"] and "electronics" or "crafting",
      subgroup = "angels-" .. metal .. "-casting" or "angels-alloys-casting",
      energy_required = 1,
      enabled = false,
      ingredients = {
        { type = "item", name = "angels-shielding-coil-" .. metal, amount = 4 }
      },
      results =
      {
        { type = "item", name = "cable-shielding-" .. tier, amount = 16 },
      },
      main_product = "cable-shielding-" .. tier,
      icons = angelsmods.functions.add_icon_layer(
        angelsmods.functions.get_object_icons("cable-shielding-" .. tier),
        angelsmods.functions.get_object_icons("angels-shielding-coil-" .. metal),
        {10, -10}, 0.4375*0.5),
    }
  })
end

if mods["angelsindustries"] and angelsmods.industries.components then

  -- Add regular recipe for copper shielding individually because it only takes one metal
  data:extend({
    {
      type = "recipe",
      name = "angels-shielding-coil-copper-casting",
      category = "strand-casting",
      subgroup = "angels-copper-casting",
      energy_required = 4,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "liquid-molten-copper", amount = 80 },
        { type = "fluid", name = "water", amount = 40 }
      },
      results =
      {
        { type = "item", name = "angels-shielding-coil-copper", amount = 4 },
      },
      icons = angelsmods.functions.add_number_icon_layer(angelsmods.functions.get_object_icons("angels-shielding-coil-copper"), 1 , angelsmods.smelting.number_tint),
    }
  })

  -- Add fast recipe for copper shielding individually because it only takes one metal
  data:extend({
    {
      type = "recipe",
      name = "angels-shielding-coil-copper-casting-fast",
      category = "strand-casting",
      subgroup = "angels-copper-casting",
      energy_required = 2,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "liquid-molten-copper", amount = 140 },
        { type = "fluid", name = "liquid-coolant", amount = 40 }
      },
      results =
      {
        { type = "item", name = "angels-shielding-coil-copper", amount = 8 },
        { type = "fluid", name = "liquid-coolant-used", amount = 40, temperature = 300 }
      },
      main_product = "angels-shielding-coil-copper",
      icons = angelsmods.functions.add_number_icon_layer(angelsmods.functions.get_object_icons("angels-shielding-coil-copper"), 2 , angelsmods.smelting.number_tint),
    }
  })

  -- Add regular recipes for each of the four other shielding types
  add_water_casting_recipe("tin")
  add_water_casting_recipe("silver")
  add_water_casting_recipe("gold")
  add_water_casting_recipe("platinum")

  -- Add fast recipes for each of the four other shielding types
  add_coolant_casting_recipe("tin")
  add_coolant_casting_recipe("silver")
  add_coolant_casting_recipe("gold")
  add_coolant_casting_recipe("platinum")

  -- Add cutting recipes for all five shielding types
  add_cutting_recipe("copper", 1)
  add_cutting_recipe("tin", 2)
  add_cutting_recipe("silver", 3)
  add_cutting_recipe("gold", 4)
  add_cutting_recipe("platinum", 5)
end

if data.raw.item["insulated-cable"] then
  local count = 16
  local ings = data.raw.recipe["insulated-cable"].ingredients
  if ings[1] and ings[1].amount then
      count = ings[1].amount * 8
  elseif ings[1] and ings[1][2] then
      count = ings[1][2] * 8
  end
  --[[this is based on the rubber rework
  insulated-cable amount = wood_per_rubber * 2
  tinned-copper-cable amount = wood_per_rubber * 2
  energy_required = wood_per_rubber / 2 ]]
  data:extend({
    {
      type = "recipe",
      name = "angels-wire-coil-insulated-casting",
      category = "strand-casting",
      subgroup = "angels-alloys-casting",
      energy_required = 4,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "liquid-rubber", amount = 10, fluidbox_index = 4},
        { type = "fluid", name = "liquid-molten-tin", amount = count * 8, fluidbox_index = 1},
        { type = "fluid", name = "liquid-molten-copper", amount = count * 8, fluidbox_index = 2},
        { type = "fluid", name = "water", amount = 40, fluidbox_index = 3}
      },
      results =
      {
        { type = "item", name = "angels-wire-coil-insulated", amount = count },
      },
      icons = angelsmods.functions.add_number_icon_layer(angelsmods.functions.get_object_icons("angels-wire-coil-insulated"), 1 , angelsmods.smelting.number_tint),
    },
    {
      type = "recipe",
      name = "angels-wire-coil-insulated-casting-fast",
      category = "strand-casting",
      subgroup = "angels-alloys-casting",
      energy_required = 2,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "liquid-rubber", amount = 18, fluidbox_index = 4},
        { type = "fluid", name = "liquid-molten-tin", amount = count*14, fluidbox_index = 1},
        { type = "fluid", name = "liquid-molten-copper", amount = count*14, fluidbox_index = 2},
        { type = "fluid", name = "liquid-coolant", amount = 40, fluidbox_index = 3}
      },
      results =
      {
        { type = "item", name = "angels-wire-coil-insulated", amount = count*2 },
        { type = "fluid", name = "liquid-coolant-used", amount = 40, temperature = 300, fluidbox_index = 1}
      },
      main_product = "angels-wire-coil-insulated",
      icons = angelsmods.functions.add_number_icon_layer(angelsmods.functions.get_object_icons("angels-wire-coil-insulated"), 2 , angelsmods.smelting.number_tint),
    },
    {
      type = "recipe",
      name = "angels-wire-coil-insulated-converting",
      category = mods["bobelectronics"] and "electronics" or "crafting",
      subgroup = "angels-alloys-casting",
      energy_required = 1,
      enabled = false,
      ingredients = {
        { type = "item", name = "angels-wire-coil-insulated", amount = 4 }
      },
      results =
      {
        { type = "item", name = "insulated-cable", amount = 20 }, --should be 16, but with ag modules in the others, this is "worse"
      },
      main_product = "insulated-cable",
      icons = angelsmods.functions.add_icon_layer(angelsmods.functions.get_object_icons("insulated-cable"), angelsmods.functions.get_object_icons("angels-wire-coil-insulated"), {-10, -10}, 0.4375*0.5),
    }
  })
  --add additional fluid box on one side
  if data.raw.item["strand-casting-machine"] then
    local box = {
      production_type = "input",
      pipe_covers = pipecoverspictures(),
      base_area = 10,
      base_level = -1,
      filter = "liquid-rubber",
      pipe_connections = {{type = "input-output", position = {-3, 1}}, {type = "input-output", position = {3, 1}}}
    }
    table.insert(data.raw["assembling-machine"]["strand-casting-machine"].fluid_boxes, box)
    for i=2,4 do
      table.insert(data.raw["assembling-machine"]["strand-casting-machine-"..i].fluid_boxes, box)
    end
  end
end