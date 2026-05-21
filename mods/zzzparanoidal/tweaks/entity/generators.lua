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

local function changePower (itemName, power)
  if (data.raw["generator"] and data.raw["generator"][itemName]) then
    data.raw["generator"][itemName].fluid_usage_per_tick = power
  end
end

changePower("EasyWindTurbine1",0.00049) --50KW
changePower("EasyWindTurbine2",0.00392) --400KW
changePower("EasyWindTurbine3",0.0098)  --1MW
changePower("EasyWindTurbine4",0.0196)  --2MW
changePower("EasyWindTurbine5",0.049)   --5MW