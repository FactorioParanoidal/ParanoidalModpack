-- set immunity to fire
for _, bot in pairs(data.raw["construction-robot"]) do
	bot.resistances = bot.resistances or {}
	table.insert(bot.resistances, {type = "fire", percent = 100})
end

-- Correct Bob's MK3/MK4 links before unminable-robots removes upgrades together with minability.
for tier = 3, 4 do
	local robot = data.raw["construction-robot"]["bob-construction-robot-" .. tier]
	local next_name = "bob-construction-robot-" .. (tier + 1)
	if robot and data.raw["construction-robot"][next_name] then robot.next_upgrade = next_name end
end

