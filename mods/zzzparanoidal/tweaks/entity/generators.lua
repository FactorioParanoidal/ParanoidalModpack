--увеличиваем максимальное потребление топлива дизель-генератором, так как уменьшена его энергоёмкость
if mods.KS_Power then
  data.raw.generator["petroleum-generator"].fluid_usage_per_tick = 5.1613 / 60
end
--Увеличиваем выработку энергии орбитальным приёмником, так как иначе он получается очень дорогим и невыгодным
local entity = data.raw["electric-energy-interface"]["orbital-power-reciver"]
--data.raw["electric-energy-interface"] имеется всегда, поэтому его можно индексировать, а если ERP мод выключен,
--и orbital-power-reciver отсутствует, получится nil
if entity then
  local power = "1000MW"
  local buffer = "10GJ"
  entity.energy_source.buffer_capacity = buffer
  entity.energy_source.output_flow_limit = power
  entity.energy_production = power
  entity.production = power
end

paralib.bobmods.lib.recipe.enabled("wind-turbine-2", false)

-- Wind Turbines (relaunched): рецепты крафта возвращаем 1-в-1 как в 1.1 (Texugo_windgenerator).
-- relaunched ставит свои (более лёгкие) рецепты — перетираем тут (data-final-fixes, рецепты уже созданы).
-- T2: big-electric-pole-2 → bob-big-electric-pole-2 (Bob's 2.x переименовал прототип).
local function setWindRecipe (name, energy, ingredients)
  local r = data.raw.recipe[name]
  if r then
    r.energy_required = energy
    r.ingredients = ingredients
  end
end

setWindRecipe("texugo-wind-turbine", 8, {
  { type = "item", name = "wood",                amount = 10 },
  { type = "item", name = "copper-cable",        amount = 20 },
  { type = "item", name = "iron-stick",          amount = 20 },
  { type = "item", name = "small-electric-pole", amount = 4  },
  { type = "item", name = "iron-gear-wheel",     amount = 4  },
})
setWindRecipe("texugo-wind-turbine2", 30, {
  { type = "item", name = "bob-big-electric-pole-2", amount = 4   },
  { type = "item", name = "electronic-circuit",      amount = 10  },
  { type = "item", name = "iron-gear-wheel",         amount = 50  },
  { type = "item", name = "steel-plate",             amount = 150 },
  { type = "item", name = "stone-brick",             amount = 150 },
})
setWindRecipe("texugo-wind-turbine3", 150, {
  { type = "item", name = "advanced-circuit",   amount = 25  },
  { type = "item", name = "flying-robot-frame", amount = 25  },
  { type = "item", name = "iron-gear-wheel",    amount = 100 },
  { type = "item", name = "substation",         amount = 10  },
  { type = "item", name = "steel-plate",        amount = 500 },
  { type = "item", name = "concrete",           amount = 500 },
})

-- T4 (titanic) убираем из доступа: сносим только рецепт и технологию.
-- Прототипы entity/item/twt-collision-rect4 ОСТАВЛЯЕМ: их жёстко перечисляют миграции самого мода
-- (migrations/1.1.7.lua, 2.0.2.lua) в find_entities_filtered — удаление уронит загрузку сейва.
if data.raw.recipe then data.raw.recipe["texugo-wind-turbine4"] = nil end
if data.raw.technology then data.raw.technology["texugo-wind-turbine4"] = nil end