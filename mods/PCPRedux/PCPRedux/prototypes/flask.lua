local OV = angelsmods.functions.OV
local move_item = angelsmods.functions.move_item
--long sequence of checks...
if settings.startup["pcp-glass-sink"].value and
    not mods["ScienceCostTweakerM"] and
    not mods["MomoTweak"] and
    not data.raw.item["flask"] then
  data:extend(
    {
      {
        type = "item",
        name = "flask",
        icon = "__PCPRedux__/graphics/icons/flask.png",
        icon_size = 32,
        subgroup = "intermediate-product",
        order = "z[flask]",
        stack_size = 200
      },
      {
        type = "recipe",
        name = "flask",
        enabled = false,
        energy_required = 1,
        ingredients = { { type = "item", name = "angels-solid-sodium-hydroxide", amount = 1 } },
        results = { { type = "item", name = "flask", amount = 1 } },
      }
    })
  if type(data.raw.recipe["chemical-science-pack"].ingredients) == "table" then
    table.insert(
      data.raw.recipe["chemical-science-pack"].ingredients, { type = "item", name = "flask", amount = 1 })
  end
  if type(data.raw.recipe["military-science-pack"].ingredients) == "table" then
    table.insert(
      data.raw.recipe["military-science-pack"].ingredients, { type = "item", name = "flask", amount = 1 })
  end
  if type(data.raw.recipe["production-science-pack"].ingredients) == "table" then
    table.insert(
      data.raw.recipe["production-science-pack"].ingredients, { type = "item", name = "flask", amount = 1 })
  end
  if type(data.raw.recipe["utility-science-pack"].ingredients) == "table" then
    table.insert(
      data.raw.recipe["utility-science-pack"].ingredients, { type = "item", name = "flask", amount = 1 })
  end
  if data.raw.recipe["bob-advanced-logistic-science-pack"] then
    if data.raw.recipe["bob-advanced-logistic-science-pack"].ingredients then
      table.insert(data.raw.recipe["bob-advanced-logistic-science-pack"].ingredients,
        { type = "item", name = "flask", amount = 1 })
    elseif data.raw.recipe["bob-advanced-logistic-science-pack"].ingredients then
      table.insert(data.raw.recipe["bob-advanced-logistic-science-pack"].ingredients,
        { type = "item", name = "flask", amount = 1 })
    end
  end
  if data.raw.item["bob-glass"] then
    data.raw.recipe["flask"].ingredients = { { type = "item", name = "bob-glass", amount = 1 } }
  end
  if mods["angelsindustries"] and settings.startup["angels-enable-tech"].value then
    move_item("flask", "angels-pack-components", "ba")
  end
end
