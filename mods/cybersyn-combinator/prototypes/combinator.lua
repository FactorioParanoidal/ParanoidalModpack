local constants = require "scripts.constants"
local flib_data_util = require "__flib__.data-util"

local name = constants.ENTITY_NAME
local combi = flib_data_util.copy_prototype(data.raw["constant-combinator"]["constant-combinator"], name)
combi.icon = "__cybersyn-combinator__/graphics/icons/cybersyn-combinator.png"
combi.icon_size = 64
combi.next_upgrade = nil
combi.fast_replaceable_group = "constant-combinator"
combi.sprites = make_4way_animation_from_spritesheet {
  layers = {
    {
      filename = "__cybersyn-combinator__/graphics/entity/combinator/cybersyn-combinator.png",
      scale = 0.5,
      width = 114,
      height = 102,
      shift = util.by_pixel(0, 5)
    },
    {
      filename = "__base__/graphics/entity/combinator/constant-combinator-shadow.png",
      scale = 0.5,
      width = 98,
      height = 66,
      shift = util.by_pixel(8.5, 5.5),
      draw_as_shadow = true
    }
  }
}

local combi_item = flib_data_util.copy_prototype(data.raw.item["constant-combinator"], name)
combi_item.icon = "__cybersyn-combinator__/graphics/icons/cybersyn-combinator.png"
combi_item.icon_size = 64
combi_item.subgroup = data.raw.item["train-stop"].subgroup
combi_item.place_result = name

local combi_recipe = flib_data_util.copy_prototype(data.raw.recipe["constant-combinator"], name)
combi_recipe.ingredients = {
  { type = "item", name = "constant-combinator", amount = 1 },
  { type = "item", name = "electronic-circuit", amount = 1 }
}
combi_recipe.enabled = false
combi_recipe.subgroup = data.raw.recipe["train-stop"].subgroup

if mods["nullius"] then
  combi.localised_name = { "entity-name." .. name }
  combi.minable.mining_time = 1
  -- Place item and recipe after Project Cybersyn's
  combi_item.order = "nullius-eca-b"
  combi_item.localised_name = { "item-name." .. name }
  combi_recipe.order = "nullius-eca-b"
  combi_recipe.localised_name = { "recipe-name." .. name }
  combi_recipe.category = "tiny-crafting"
  combi_recipe.always_show_made_in = true
  combi_recipe.energy_required = 2
  combi_recipe.ingredients = {
    { "constant-combinator", 1 },
    { "decider-combinator", 1 }
  }
else
  local cybersyn_item = data.raw.item["cybersyn-combinator"]
  local cybersyn_recipe = data.raw.recipe["cybersyn-combinator"]
  if cybersyn_item and cybersyn_item.order then
    combi_item.order = cybersyn_item.order .. "-b"
  else
    combi_item.order = data.raw.item["constant-combinator"].order .. "-b"
  end

  if cybersyn_recipe and cybersyn_recipe.order then
    combi_recipe.order = cybersyn_recipe.order .. "-b"
  end
end

data:extend {
  combi,
  combi_item,
  combi_recipe
}
