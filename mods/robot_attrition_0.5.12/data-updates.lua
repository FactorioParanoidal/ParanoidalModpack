
if settings.startup["robot-attrition-repair"].value == "Repair75" then
  local function repair_recipe_and_item(robot_prototype)
    if not robot_prototype.minable and robot_prototype.minable.result then return end

    local o_item_name = robot_prototype.minable.result
    local o_item = data.raw.item[o_item_name]
    if not o_item then return end

    local o_recipe = data.raw.recipe[o_item_name] -- TODO: could do something smarter here
    if not o_recipe then return end

    local item = table.deepcopy(o_item)
    item.name = o_item.name.."-crashed"
    item.place_result = nil

    item.localised_name = {"item-name.robot-attrition-crashed", {"entity-name."..robot_prototype.name}}

    local recipe_repair = table.deepcopy(o_recipe)
    recipe_repair.name = o_item.name.."-repair"
    recipe_repair.subgroup = o_item.subgroup or robot_prototype.subgroup
    recipe_repair.order = (o_item.order or robot_prototype.order) .. "-b"

    local recipe_recombine = table.deepcopy(o_recipe)
    recipe_recombine.name = o_item.name.."-recombine"
    recipe_recombine.subgroup = o_item.subgroup or robot_prototype.subgroup
    recipe_recombine.order = (o_item.order or robot_prototype.order) .. "-c"

    if o_item.icons then
      recipe_repair.icons = table.deepcopy(o_item.icons)
      recipe_recombine.icons = table.deepcopy(o_item.icons)
      table.insert(item.icons, {icon="__core__/graphics/icons/alerts/destroyed-icon.png", icon_size = 64, scale = 0.25})
      table.insert(recipe_repair.icons, {icon="__core__/graphics/icons/alerts/destroyed-icon.png", icon_size = 64, scale = 0.25})
      table.insert(recipe_recombine.icons, {icon="__core__/graphics/icons/alerts/destroyed-icon.png", icon_size = 64, scale = 0.25})
      item.icon_size = o_item.icon_size
      recipe_repair.icon_size = o_item.icon_size
      recipe_recombine.icon_size = o_item.icon_size
    else
      item.icons = {
        {icon = o_item.icon, icon_size = o_item.icon_size},
        {icon="__core__/graphics/icons/alerts/destroyed-icon.png", icon_size = 64, scale = 0.25}
      }
      recipe_repair.icons = {
        {icon = o_item.icon, icon_size = o_item.icon_size},
        {icon="__core__/graphics/icons/alerts/destroyed-icon.png", icon_size = 64, scale = 0.25}
      }
      recipe_recombine.icons = {
        {icon = o_item.icon, icon_size = o_item.icon_size},
        {icon="__core__/graphics/icons/alerts/destroyed-icon.png", icon_size = 64, scale = 0.25}
      }
    end

    local function repair_recipe(set)
      set.results = {{name = o_item.name, amount = 1}}
      if set and set.ingredients then
        local reduced = false
        local last_k
        for k, ingredient in pairs(set.ingredients) do
          last_k = k
          if ingredient[1] and ingredient[2] then
            set.ingredients[k] = {name = ingredient[1], amount = ingredient[2]}
          end
          local original_amount = set.ingredients[k].amount or 1
          local reduce_amount = math.ceil(original_amount * 0.75)
          if original_amount == reduce_amount and original_amount > 1 then
            reduce_amount = original_amount - 1
          end
          if reduce_amount == original_amount and original_amount == 1 then
            table.insert(set.results, {name = set.ingredients[k].name, amount_min = 1, amount_max = 1, probability = 0.25})
          end
          set.ingredients[k].amount = reduce_amount
        end
        table.insert(set.ingredients, {name = "repair-pack", amount = 1})
        table.insert(set.ingredients, {name = item.name, amount = 1})
      end
    end

    for _, set in pairs({recipe_repair, recipe_repair.normal, recipe_repair.expensive}) do
      repair_recipe(set)
    end

    for _, set in pairs({recipe_recombine, recipe_recombine.normal, recipe_recombine.expensive}) do
      set.ingredients = {
        {name = "repair-pack", amount = 1},
        {name = item.name, amount = 4}
      }
      set.results = {{name = o_item.name, amount = 1}}
    end

    recipe_repair.localised_name = {"recipe-name.robot-attrition-repair", {"entity-name."..robot_prototype.name}}
    recipe_recombine.localised_name = {"recipe-name.robot-attrition-recombine", {"entity-name."..robot_prototype.name}}

    for _, technology in pairs(data.raw.technology) do
      if technology.effects then
        for _, effect in pairs(technology.effects) do
          if effect.type == "unlock-recipe" and effect.recipe == o_recipe.name then
            table.insert(technology.effects, { type = "unlock-recipe", recipe = recipe_repair.name})
            table.insert(technology.effects, { type = "unlock-recipe", recipe = recipe_recombine.name})
          end
        end
      end
    end

    data:extend({item, recipe_repair, recipe_recombine})

  end

  for _, prototype in pairs(data.raw["logistic-robot"]) do
    repair_recipe_and_item(prototype)
  end
end
