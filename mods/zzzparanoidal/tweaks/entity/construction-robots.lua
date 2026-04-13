-- set immunity to fire
for _, bot in pairs(data.raw["construction-robot"]) do
	bot.resistances = bot.resistances or {}
	table.insert(bot.resistances, {type = "fire", percent = 100})
end

