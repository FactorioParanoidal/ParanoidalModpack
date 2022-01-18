local base_bot_speed = 0.06
for _, bot in pairs(data.raw["logistic-robot"]) do
    if bot.speed > base_bot_speed then
      bot.speed = math.pow(bot.speed / base_bot_speed, 0.9) * base_bot_speed
    end
end

function robot_attrition_bot_corpse(bot)
  local remnant_name = bot.name.."-remnants"
  local remnant = data.raw["corpse"][remnant_name]
  if not remnant then
     remnant = table.deepcopy(data.raw["corpse"]["logistic-robot-remnants"] or data.raw["simple-entity"]["logistic-robot-remnants"])
  end
  data.raw["corpse"][remnant_name] = nil
  remnant.name = remnant_name
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
  for _, prototype in pairs(data.raw["optimized-particle"]) do
    if prototype.ended_on_ground_trigger_effect
      and prototype.ended_on_ground_trigger_effect[1]
      and prototype.ended_on_ground_trigger_effect[1].entity_name == remnant_name then
        -- allows it to be marked for deconstruction
        prototype.ended_on_ground_trigger_effect[1].trigger_created_entity = true
    end
  end
end

if settings.startup["robot-attrition-repair"].value ~= "Disabled" then
  for _, bot in pairs(data.raw["logistic-robot"]) do
    if bot.dying_trigger_effect and bot.dying_trigger_effect[1] and bot.dying_trigger_effect[1] then
      robot_attrition_bot_corpse(bot)
    end
  end
end

--[[
TODO:
The falling particle needs to be a projectile instead of a particle so that force is preserved.

]]
