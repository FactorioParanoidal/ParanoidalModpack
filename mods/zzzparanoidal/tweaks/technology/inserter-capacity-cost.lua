-- Цена бонуса грузоподъёмности манипулятора II–IV (решение пользователя 2026-11-02).
-- Это линия Bob's inserter-stack-size-bonus-N («Бонус грузоподъемности манипулятора», обычные манипуляторы),
-- а не базовая inserter-capacity-bonus-N (пакетные манипуляторы): её цену не трогаем.
-- Меняем только unit.count; паки, время, предшественники и эффекты не трогаем.
for tech, count in pairs({
  ["inserter-stack-size-bonus-2"] = 1500,
  ["inserter-stack-size-bonus-3"] = 2000,
  ["inserter-stack-size-bonus-4"] = 3000,
}) do
  local t = data.raw.technology[tech]
  if t and t.unit then
    t.unit.count = count
    t.unit.count_formula = nil
  end
end
