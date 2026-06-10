-- Цена техов инсертеров (near/long/more) как в 1.1 Oberhaul: больше циклов + logistic ×2.
-- Меняем только цену (unit.count и кол-во logistic-колб); дерево (prerequisites) и типы паков НЕ трогаем.
local function set_cost(tech, count, logistic)
  local t = data.raw.technology[tech]
  if not (t and t.unit) then return end
  t.unit.count = count
  if logistic then
    for _, ing in ipairs(t.unit.ingredients or {}) do
      if (ing.name or ing[1]) == "logistic-science-pack" then
        if ing.name then ing.amount = logistic else ing[2] = logistic end
      end
    end
  end
end

set_cost("bob-near-inserters", 100, nil)    -- было 25
set_cost("bob-long-inserters-2", 500, 2)    -- было 50, logistic 1→2
set_cost("bob-more-inserters-1", 500, 2)    -- было 25, logistic 1→2
set_cost("bob-more-inserters-2", 900, 2)    -- было 50, logistic 1→2
