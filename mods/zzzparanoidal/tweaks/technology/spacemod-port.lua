require("__zzzparanoidal__.paralib")

-- Восстанавливаем 1.1-цену космо-техов, которую 2.0-форк потерял: в 1.1 SpaceMod/technology-bobs.lua
-- bob_coefficient был = 10 и умножал стоимость всех космо-техов, а форк обнулил его до 1.
-- Возвращаем тот же ×10 поверх модовых count. Ранние техи выходят точно как в 1.1 (60k–240k);
-- FTL-ветка остаётся прогрессивной лесенкой из 2.0-форка (в 1.1 была плоско 2M) — оставлено намеренно.
-- Наборы наук и bob-пререквизиты навешивает сам мод (гейт bobequipment проходит), дублировать не нужно.
if mods["SpaceModFeorasFork"] then
	local techs = {
		"space-assembly", "space-construction", "space-casings", "protection-fields",
		"fusion-reactor", "space-thrusters", "fuel-cells", "habitation", "life-support-systems",
		"spaceship-command", "laser-cannon", "astrometrics", "ftl-theory-A", "ftl-theory-B",
		"ftl-theory-C", "ftl-theory-D", "ftl-theory-D1", "ftl-theory-D2", "ftl-propulsion",
		"exploration-satellite", "space-ai-robots", "space-fluid-tanks", "space-cartography",
	}
	for _, name in ipairs(techs) do
		local t = data.raw.technology[name]
		if t and t.unit and t.unit.count then
			t.unit.count = math.floor(t.unit.count * 10)
		end
	end
end
