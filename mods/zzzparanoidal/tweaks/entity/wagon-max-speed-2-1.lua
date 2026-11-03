-- Factorio 2.1 (решение пользователя G22 «А», 2026-11-03): скорость поезда в 2.1 — среднее max_speed тех
-- вагонов и локомотивов, у которых он задан, умноженное на модификатор топлива (в 2.0 — минимум по всему составу;
-- документация RollingStockPrototype::max_speed 2.1.24, проверено на обоих движках). Ваниль 2.1 убрала
-- max_speed у вагонов; у вагонов сборки (tweaks/entity/trains.lua, бронепоезд mk3, Bob, hiend, Yuoki) он
-- остался и поднимал бы поезд выше скорости его локомотивов (4 вагона Bob mk3 за локомотивом — до 8,24 тайла/тик).
-- Без max_speed у вагонов поезд идёт со средней скоростью своих локомотивов: при одном типе локомотива — как
-- в 2.0, пока вагоны были не медленнее локомотива; медленные вагоны больше не тормозят быстрый локомотив.
local removed = {}
for _, type_name in ipairs({ "cargo-wagon", "fluid-wagon", "artillery-wagon", "infinity-cargo-wagon" }) do
	for name, wagon in pairs(data.raw[type_name] or {}) do
		if wagon.max_speed ~= nil then
			wagon.max_speed = nil
			removed[#removed + 1] = name
		end
	end
end
table.sort(removed)
log("Paranoidal: Factorio 2.1 train speed rule, max_speed removed from " .. #removed .. " wagons: "
	.. table.concat(removed, ", "))
