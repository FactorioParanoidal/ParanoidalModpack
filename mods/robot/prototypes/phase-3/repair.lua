Repair = {}

local function get_level_suffix(name)
  return tonumber(string.match(name, "%d+$"))
end

local function get_highest_matching_repair_pack(level)
  for i=level, 1, -1 do
    if data.raw["repair-tool"]["repair-pack-" .. i] then
      return "repair-pack-" .. i
    end
  end
  return "repair-pack"
end

local function repair_recipe(set, original_item, crashed_item, repair_pack_name)
  local repair_cost = 0.75

  set.results = {{name = original_item.name, amount = 1}}
  if set and set.ingredients then
    for k, ingredient in pairs(set.ingredients) do
      if ingredient[1] and ingredient[2] then -- Short ingredient form, without keys
        set.ingredients[k] = {name = ingredient[1], amount = ingredient[2]}
      end
      local original_amount = set.ingredients[k].amount or 1
      local reduced_amount = math.ceil(original_amount * repair_cost)
      if original_amount == reduced_amount and original_amount > 1 then
        reduced_amount = original_amount - 1
      elseif original_amount == reduced_amount and original_amount == 1 then
        table.insert(set.results, {name = set.ingredients[k].name, amount_min = 1, amount_max = 1, probability = (1 - repair_cost)})
      end
      set.ingredients[k].amount = reduced_amount
    end
    table.insert(set.ingredients, {name = repair_pack_name, amount = 1})
    table.insert(set.ingredients, {name = crashed_item.name, amount = 1})
  end
end

function Repair.make_repair_recipe_and_item(robot_prototype)
  if not robot_prototype.minable and robot_prototype.minable.result then return end

  local o_item_name = robot_prototype.minable.result
  local o_item = data.raw.item[o_item_name]
  if not o_item then return end

  local o_recipe = data.raw.recipe[o_item_name] -- TODO: could do something smarter here
  if not o_recipe then return end

  local crashed_item = table.deepcopy(o_item)
  crashed_item.name = o_item.name.."-crashed"
  crashed_item.place_result = nil

  crashed_item.localised_name = {"item-name.robot-attrition-crashed", {"entity-name."..robot_prototype.name}}

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
    table.insert(crashed_item.icons, {icon="__core__/graphics/icons/alerts/destroyed-icon.png", icon_size = 64, scale = 0.25})
    table.insert(recipe_repair.icons, {icon="__core__/graphics/icons/alerts/destroyed-icon.png", icon_size = 64, scale = 0.25})
    table.insert(recipe_recombine.icons, {icon="__core__/graphics/icons/alerts/destroyed-icon.png", icon_size = 64, scale = 0.25})
    crashed_item.icon_size = o_item.icon_size
    recipe_repair.icon_size = o_item.icon_size
    recipe_recombine.icon_size = o_item.icon_size
  else
    crashed_item.icons = {
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

  local bot_level = get_level_suffix(o_item.name)
  local repair_pack_name = "repair-pack"
  if bot_level then
    repair_pack_name = get_highest_matching_repair_pack(bot_level)
  end

  for _, set in pairs({recipe_repair, recipe_repair.normal, recipe_repair.expensive}) do
    repair_recipe(set, o_item, crashed_item, repair_pack_name)
  end

  for _, set in pairs({recipe_recombine, recipe_recombine.normal, recipe_recombine.expensive}) do
    set.ingredients = {
      {name = repair_pack_name, amount = 1},
      {name = crashed_item.name, amount = 4}
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

  data:extend({crashed_item, recipe_repair, recipe_recombine})
end

function Repair.make_robot_attrition_bot_corpse(bot)
  -- Dying effect, creates dying particle
  local particle_name
  if bot.dying_trigger_effect and bot.dying_trigger_effect[1] and bot.dying_trigger_effect[1].particle_name then
    -- Already has one
    particle_name = bot.dying_trigger_effect[1].particle_name
  else
    -- Try to give it a dying_trigger_effect if it doesn't have one
    if data.raw["logistic-robot"]["logistic-robot"] and data.raw["logistic-robot"]["logistic-robot"].dying_trigger_effect then
      log("Adding dying_trigger_effect for " .. bot.name)
      particle_name = bot.name.."-dying-particle"
      bot.dying_trigger_effect = table.deepcopy(data.raw["logistic-robot"]["logistic-robot"].dying_trigger_effect)
      bot.dying_trigger_effect[1].particle_name = particle_name
    else
      return -- Give up
    end
  end

  -- Some modded bots reuse the vanilla bot death, we want them to have their own death particle
  if bot.name ~= "logistic-robot" and particle_name == "logistic-robot-dying-particle" then
    particle_name = bot.name.."-dying-particle"
    bot.dying_trigger_effect[1].particle_name = particle_name
  end

  -- Dying particle, creates remnant
  local particle = data.raw["optimized-particle"][particle_name]
  local remnant_name
  if particle and particle.ended_on_ground_trigger_effect then
    -- Already has one
    if particle.ended_on_ground_trigger_effect.entity_name then
      remnant_name = particle.ended_on_ground_trigger_effect.entity_name
      particle.ended_on_ground_trigger_effect.trigger_created_entity = true -- allows it to be marked for deconstruction
    elseif particle.ended_on_ground_trigger_effect[1] and particle.ended_on_ground_trigger_effect[1].entity_name then
      remnant_name = particle.ended_on_ground_trigger_effect[1].entity_name
      particle.ended_on_ground_trigger_effect[1].trigger_created_entity = true -- allows it to be marked for deconstruction
    else
      return
    end
  else
    -- Try to give it one
    if data.raw["optimized-particle"]["logistic-robot-dying-particle"] then
      log("Creating dying particle for " .. bot.name)
      remnant_name = bot.name.."-remnants"
      particle = table.deepcopy(data.raw["optimized-particle"]["logistic-robot-dying-particle"])
      particle.name = particle_name
      particle.ended_on_ground_trigger_effect[1].entity_name = remnant_name
      particle.ended_on_ground_trigger_effect[1].trigger_created_entity = true -- allows it to be marked for deconstruction
      data:extend({particle})
    else
      return -- Give up
    end
  end

  -- Remnant, can be mined for crashed item
  local remnant = data.raw["corpse"][remnant_name]
  if not remnant then
    log("Creating remnant for " .. bot.name)
    remnant = table.deepcopy(data.raw["corpse"]["logistic-robot-remnants"] or data.raw["simple-entity"]["logistic-robot-remnants"])
  end
  data.raw["corpse"][remnant_name] = nil
  remnant.name = remnant_name
  remnant.localised_name = {"remnant-name", bot.localised_name or {"entity-name." .. bot.name}}
  remnant.type = "simple-entity"
  remnant.minable = {mining_time = 0.1, result = data.raw.item[ bot.name.."-crashed"] and bot.name.."-crashed" or nil}
  remnant.max_health = 50
  remnant.se_allow_in_space = true
  remnant.collision_box = {{-0.1,-0.1},{0.1,0.1}}
  remnant.selection_box = {{-0.2,-0.2},{0.2,0.2}}
  remnant.selectable_in_game = true
  remnant.collision_mask = {}
  remnant.flags = {"placeable-neutral"}
  table.insert(remnant.flags, "placeable-off-grid")
  remnant.animations = remnant.animations or remnant.animation
  data:extend({remnant})
end

return Repair
