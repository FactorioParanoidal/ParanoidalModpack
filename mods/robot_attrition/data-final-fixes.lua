if settings.startup["robot-attrition-repair"].value == "Repair75" then
  require("prototypes/phase-3/repair")
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
