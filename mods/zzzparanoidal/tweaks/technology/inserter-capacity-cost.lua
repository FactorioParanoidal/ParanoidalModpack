-- Цена бонуса грузоподъёмности манипулятора II–IV (решение пользователя 2026-11-02).
-- Меняем только unit.count; паки, время, предшественники и эффекты не трогаем.
for tech, count in pairs({
  ["inserter-capacity-bonus-2"] = 1500,
  ["inserter-capacity-bonus-3"] = 2000,
  ["inserter-capacity-bonus-4"] = 3000,
}) do
  local t = data.raw.technology[tech]
  if t and t.unit then
    t.unit.count = count
    t.unit.count_formula = nil
  end
end
