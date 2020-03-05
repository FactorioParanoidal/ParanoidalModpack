if settings.startup["coppermine-bob-module-exponential-modules"].value then
  -- Search every recipe for the ones we want to modify
  for product, recipe in pairs(data.raw.recipe) do
    local match_start, match_end = product:find("-module")

    if match_start then
      local product_type = product:sub(1, match_end)

      for i, ingredient in pairs(recipe.ingredients) do
        local item = bobmods.lib.item.basic_item(ingredient)

        match_start, match_end = item.name:find("-module")

        if match_start then
          local ingredient_type = item.name:sub(1, match_end)

          -- Only alter amounts when the types match (i.e. the upgrading
          -- recipes rather than the combining recipes)

          if product_type == ingredient_type then
            if product_type == "god-module" then
              multiplier = 5
            else
              multiplier = 2
            end
            new_amount = item.amount * multiplier

            if ingredient.amount then
              ingredient.amount = new_amount
            else
              ingredient[2] = new_amount
            end
          end
        end
      end
    end
  end

  -- If CMHModBobEndGame is loaded, it sets rocket control units to require god
  -- module 5s or (raw) speed module 8s; with these changes those are far too
  -- expenisve to be an ingredient like that, so we change things up by
  -- allowing them to be broken down into circuits usable by many rocket
  -- control units

  function replace_module_in_rocket_recipe(ingredients)
    for i, ingredient in pairs(ingredients) do
      local item = bobmods.lib.item.basic_item(ingredient)
      local match_start, match_end = item.name:find("-module")

      if match_start and item.name ~= "speed-module" then
        data:extend({
          {
            type = "item",
            name = "rocket-control-circuit",
            icon = "__CoppermineBobModuleRebalancing__/graphics/icons/rocket-control-circuit.png",
            icon_size = 32,
            subgroup = "intermediate-product",
            order = "n[rocket-control-circuit]",
            stack_size = 100,
          },

          {
            type = "recipe",
            name = "rocket-control-circuit",
            category = "electronics",
            energy_required = 150,
            enabled = false,
            ingredients =
            {
              {item.name, 1},
              {"superior-circuit-board", 20},
            },
            result = "rocket-control-circuit",
            result_count = 20
          }
        })

        bobmods.lib.recipe.replace_ingredient("rocket-control-unit", item.name, "rocket-control-circuit")
        bobmods.lib.tech.add_recipe_unlock("rocket-control-unit", "rocket-control-circuit")
      end
    end
  end

  if data.raw.recipe["rocket-control-unit"].normal then
    replace_module_in_rocket_recipe(data.raw.recipe["rocket-control-unit"].normal.ingredients)
    replace_module_in_rocket_recipe(data.raw.recipe["rocket-control-unit"].expensive.ingredients)
  else
    replace_module_in_rocket_recipe(data.raw.recipe["rocket-control-unit"].ingredients)
  end
end
