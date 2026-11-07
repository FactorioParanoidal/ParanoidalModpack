-- Demons keep their own health, speed and no loot, whatever later data stages did to every unit.
if not mods["space-age"] then return end
local shared = require("shared")
for _, sin in ipairs(shared.sins) do
	for size, spec in ipairs(shared.demon_sizes) do
		local demon = data.raw.unit[shared.demon(sin, size)]
		if demon then
			demon.max_health = spec.health * sin.health
			demon.movement_speed = spec.speed * sin.speed
			demon.loot = nil
		end
	end
end
