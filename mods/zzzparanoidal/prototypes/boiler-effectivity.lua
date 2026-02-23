-- добавляем смысла апгрейдить бойлеры на новые тиеры -- добавляем им КПД!

-- КПД    75% -- 95% -- 110% -- 120% -- 125%
-- или    0.5 -- 0.67 --0.80 -- 0.90 -- 0.98
-- т.е.           +17   +13     +10     +8
-- или    0.6 -- 0.8 -- 1.0 -- 1.15 -- 1.25

for name, value in pairs ({["boiler"]=0.5, ["bob-boiler-2"]=0.67, ["bob-boiler-3"]=0.8, ["bob-boiler-4"]=0.9, ["bob-boiler-5"]=0.98}) do
  data.raw.boiler[name].energy_source.effectivity=value
end
