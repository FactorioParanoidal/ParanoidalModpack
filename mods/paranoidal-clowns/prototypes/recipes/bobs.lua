--check alloys exist before adding them
if data.raw.item["bronze-alloy"] and data.raw.item["angels-plate-nickel"] then
  data:extend(
  {
    {
      type = "recipe",
      name = "nickel-piercing-rounds-magazine",
      enabled = false,
      energy_required = 3,
      ingredients = {
        {type = "item", name = "firearm-magazine", amount = 1},
        {type = "item", name = "angels-plate-nickel", amount = 5},
        {type = "item", name = "bob-bronze-alloy", amount = 3}
      },
      results = {
        {type = "item", name = "piercing-rounds-magazine", amount = 1}
      }
    },
  }
  )
end
--may want to look at adding a non-bobs/angels variant
--data.raw.item["angels-platinum-ore"] and data.raw.item["angels-gold-ore"] then
  data:extend(
  {
    {
      type = "recipe",
      name = "sand-sluicing",
      category = "sluicing",
      enabled = false,
      icon = "__angelsrefininggraphics__/graphics/icons/solid-sand.png",
      icon_size = 32,
      ingredients = {
        {type = "item", name = "angels-solid-sand", amount = 10},
        {type = "fluid", name = "water", amount = 10}
      },
      results = {
        {type = "fluid", name = "angels-water-thin-mud", amount = 10},
        {type = "item", name = "iron-ore", amount = 1, probability = 0.2},
        {type = "item", name = "copper-ore", amount = 1, probability = 0.1},
        {type = "item", name = "angels-crystal-dust", amount = 1, probability = 0.1},
        angelsmods.trigger.ores["gold"] and {type = "item", name = "angels-gold-ore", amount = 1, probability = 0.05} or {type = "item", name = "uranium-ore", amount = 1, probability = 0.001},
        {type = "item", name = "clowns-osmium-ore", amount = 1, probability = 0.01},
        angelsmods.trigger.ores["platinum"] and {type = "item", name = "angels-platinum-ore", amount = 1, probability = 0.01} or nil,
      },
      energy_required = 5,
      subgroup = "angels-water-washing",
      order = "k-a",
    },
  }
  )