-- if bobs mods ["wooden-board"]
if data.raw.recipe["wooden-board"] then
  table.insert(data.raw.recipe["wooden-board"].ingredients, {type = "item", name = "stone-tablet", amount = 1})
  data.raw.recipe["wooden-board"].enabled = false
end

-- if bobs mods ["wooden-board-synthetic"]
if data.raw.recipe["wooden-board-synthetic"] then
  table.insert(data.raw.recipe["wooden-board-synthetic"].ingredients, {type = "item", name = "stone-tablet", amount = 1})
  data.raw.recipe["wooden-board-synthetic"].enabled = false
end


if data.raw.item["solid-sand"] then -- angels sand
  data:extend({{
      type = "recipe",
      name = "sand-to-solid-sand",
      category = "washing-plant",
      subgroup = data.raw.item["solid-sand"].subgroup or "raw-material",
      energy_required = 0.5,
      enabled = false,
      ingredients = {
        {type="item", name=aai_sand_name, amount=10},
        {type="fluid", name="water", amount=100},
      },
      results= { {type="item", name="solid-sand", amount=10} },
      allow_productivity = true,
  }})
end
