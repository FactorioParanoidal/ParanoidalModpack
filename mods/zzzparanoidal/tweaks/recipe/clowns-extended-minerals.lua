-- Балансовые правки Clowns-Extended-Minerals под канон пака (Angel/zzz).
--   (1) Катализаторные сортировочные рецепты — выход дефицитных металлов к канону.
--   (2) Добыча руд — жидкость выровнена под Angel-руды.
-- Запускается из data-final-fixes ПОСЛЕ OV.execute (Clowns патчит сорты через OV); guard'ы на всё.

-------------------------------------------------------------------------------
-- (1) Катализаторная сортировка
-------------------------------------------------------------------------------
-- меняет только количество указанного металла на выходе (побочка сохраняется)
local function rebal_output(recipe_name, item_name, amount)
  local r = data.raw.recipe[recipe_name]
  if not r or not r.results then return end
  for _, res in pairs(r.results) do
    if res.name == item_name then
      res.amount = amount
      res.amount_min = nil
      res.amount_max = nil
    end
  end
end

-- меняет вход и выход целиком (для рецептов-обходов, где правим и ингредиенты)
local function rebal_full(recipe_name, ingredients, results)
  local r = data.raw.recipe[recipe_name]
  if not r then return end
  r.ingredients = ingredients
  r.results = results
end

-- Марганец — канон zzz angelsore-crushed-manganese (через ferrous-mixture = angels-ore8).
-- angels-manganese-pure брал сырьё в обход ferrous → переводим на ferrous.
rebal_full("angels-manganese-pure-processing",
  {
    { type = "item", name = "clowns-ore6-crushed",      amount = 2 }, -- Sanguinate
    { type = "item", name = "angels-ore8-crushed",      amount = 4 }, -- ferrous mixture
    { type = "item", name = "angels-catalysator-brown", amount = 1 },
  },
  { { type = "item", name = "angels-manganese-ore", amount = 1 } })

-- crushed-mix5 уже идёт через ferrous-mixture → правим только масштаб (вход/выход).
rebal_full("clowns-crushed-mix5-processing",
  {
    { type = "item", name = "angels-ore8-crushed",      amount = 5 }, -- ferrous mixture
    { type = "item", name = "clowns-ore8-crushed",      amount = 4 }, -- Meta-Garnierite
    { type = "item", name = "angels-ore6-crushed",      amount = 3 }, -- Bobmonium
    { type = "item", name = "angels-catalysator-brown", amount = 1 },
  },
  { { type = "item", name = "angels-manganese-ore", amount = 2 } })

-- Хром — канон zzz angelsore-pure-chrome (crystal). pure-mix3 на pure-тире → выше.
rebal_output("angels-chrome-pure-processing", "angels-chrome-ore", 2)
rebal_output("clowns-pure-mix3-processing",   "angels-chrome-ore", 3)

-- Платина — канон zzz angelsore-pure-platinum (pure).
rebal_output("clowns-platinum-pure-processing", "angels-platinum-ore", 2)
-- pure-mix4: добираем вход (elionagate 1->2) под выход 2.
rebal_full("clowns-pure-mix4-processing",
  {
    { type = "item", name = "angels-ore5-pure",          amount = 1 },
    { type = "item", name = "angels-ore9-crystal",       amount = 1 },
    { type = "item", name = "clowns-ore2-pure",          amount = 1 },
    { type = "item", name = "clowns-ore7-pure",          amount = 2 }, -- Elionagate
    { type = "item", name = "clowns-resource2",          amount = 1 },
    { type = "item", name = "angels-catalysator-orange", amount = 1 },
  },
  { { type = "item", name = "angels-platinum-ore", amount = 2 } })

-- Уран — канон Angel crystal-mix5 (crystal). Срезаем лишний Stiratite (ore3 2->1).
rebal_full("clowns-crystal-mix4-processing",
  {
    { type = "item", name = "clowns-ore5-crystal",       amount = 2 },
    { type = "item", name = "angels-ore3-crystal",       amount = 1 }, -- Stiratite
    { type = "item", name = "angels-ore1-crystal",       amount = 1 },
    { type = "item", name = "angels-ore4-crystal",       amount = 1 },
    { type = "item", name = "angels-ore6-crystal",       amount = 1 },
    { type = "item", name = "angels-catalysator-orange", amount = 1 },
  },
  { { type = "item", name = "uranium-ore", amount = 3 } })

-- Фторит — канон Angel chunk-mix6.
rebal_output("clowns-chunk-mix1-processing", "angels-fluorite-ore", 4)

-------------------------------------------------------------------------------
-- (2) Добыча руд (жидкость) — выровнено под Angel-руды (см. tweaks/entity/add-liquid-to-mine-ores)
-------------------------------------------------------------------------------
-- Обычные Clowns-руды добывались без жидкости → пар x100, как Angel-руды.
for i = 1, 9 do
  local r = data.raw.resource["clowns-ore" .. i]
  if r and r.minable then
    r.minable.required_fluid = "steam"
    r.minable.fluid_amount = 100
  end
end
for i = 1, 2 do
  local r = data.raw.resource["clowns-resource" .. i]
  if r and r.minable then
    r.minable.required_fluid = "steam"
    r.minable.fluid_amount = 100
  end
end
-- Бесконечные Clowns-руды были на жидкости x10 → x100, как бесконечные Angel; тип кислоты не трогаем.
for i = 1, 9 do
  local r = data.raw.resource["infinite-clowns-ore" .. i]
  if r and r.minable then r.minable.fluid_amount = 100 end
end
for i = 1, 2 do
  local r = data.raw.resource["infinite-clowns-resource" .. i]
  if r and r.minable then r.minable.fluid_amount = 100 end
end

-------------------------------------------------------------------------------
-- (3) Hydro refining (chunk): сток «жёлтой» ветки к канону Angel
-------------------------------------------------------------------------------
-- Clowns-руды на серной/фосфорной кислоте давали 50 yellow-waste; у Angel-серных руд — 25
-- (больше стока = больше возврата воды + шлама). Выравниваем до 25.
local function fix_chunk_yellow_waste(recipe_name)
  local r = data.raw.recipe[recipe_name]
  if not r or not r.results then return end
  for _, res in pairs(r.results) do
    if res.name == "angels-water-yellow-waste" then res.amount = 25 end
  end
end
fix_chunk_yellow_waste("clowns-ore2-chunk") -- Antitate (серная)
fix_chunk_yellow_waste("clowns-ore6-chunk") -- Sanguinate (серная)
fix_chunk_yellow_waste("clowns-ore9-chunk") -- Nova-Leucoxene (фосфорная)

-------------------------------------------------------------------------------
-- (4) Скорость первой (crushed) сортировки — буф как у zzz базовым Angel-рудам
-------------------------------------------------------------------------------
-- metallurgy.lua укрупняет crushed-сорт базовых руд (4→20 вход, выходы ×5, 2s).
-- Даём Clowns-рудам тот же буф: рейт I→O (0.75) не меняется, растёт throughput на машину.
for i = 1, 9 do
  local r = data.raw.recipe["clowns-ore" .. i .. "-crushed-processing"]
  if r and r.ingredients and r.results then
    r.energy_required = 2
    for _, ing in pairs(r.ingredients) do
      if ing.amount then ing.amount = ing.amount * 5 end
    end
    for _, res in pairs(r.results) do
      if res.amount then res.amount = res.amount * 5 end
      if res.amount_min then res.amount_min = res.amount_min * 5 end
      if res.amount_max then res.amount_max = res.amount_max * 5 end
    end
  end
end
