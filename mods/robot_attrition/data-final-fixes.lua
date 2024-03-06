Repair = require("prototypes/phase-3/repair")
if settings.startup["robot-attrition-repair"].value == "Repair75" then
  for _, prototype in pairs(data.raw["logistic-robot"]) do
    Repair.make_repair_recipe_and_item(prototype)
    Repair.make_robot_attrition_bot_corpse(prototype)
  end
end

local base_bot_speed = 0.06
for _, bot in pairs(data.raw["logistic-robot"]) do
    if bot.speed > base_bot_speed then
      bot.speed = math.pow(bot.speed / base_bot_speed, 0.9) * base_bot_speed
    end
end

--[[
TODO:
The falling particle needs to be a projectile instead of a particle so that force is preserved.

]]
