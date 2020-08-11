--увеличиваем максимальное потребление топлива дизель-генератором, так как уменьшена его энергоёмкость
if mods.KS_Power then
  data.raw.generator["petroleum-generator"].fluid_usage_per_tick = 5.1613 / 60
end
