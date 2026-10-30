-- Logistic robot speeds as the build had them with Robot Attrition (Beta 8 and 2.0 until 2026-10-30, moved here
-- from paranoidal-robot-attrition): robots faster than 0.06 tiles/tick are slowed to (v / 0.06)^0.9 × 0.06,
-- Bob 2–4 0.07 → 0.069, 0.09 → 0.086, 0.12 → 0.112.
local reference = 0.06

for _, robot in pairs(data.raw["logistic-robot"]) do
	if robot.speed and robot.speed > reference then
		robot.speed = (robot.speed / reference) ^ 0.9 * reference
	end
end
