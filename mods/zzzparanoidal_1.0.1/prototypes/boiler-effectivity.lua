-- добавляем смысла апгрейдить бойлеры на новые тиеры -- добавляем им КПД!

-- КПД    75% -- 95% -- 110% -- 120% -- 125%
-- или    0.5 -- 0.67 --0.80 -- 0.90 -- 0.98
-- т.е.           +17   +13     +10     +8
-- или    0.6 -- 0.8 -- 1.0 -- 1.15 -- 1.25

for name, value in pairs ({["boiler"]=0.6, ["boiler-2"]=0.8, ["boiler-3"]=1, ["boiler-4"]=1.15, ["boiler-5"]=1.25}) do
  data.raw.boiler[name].energy_source.effectivity=value
end
--[[
data.raw.boiler["boiler"].energy_source.effectivity=0.75
data.raw.boiler["boiler-2"].energy_source.effectivity=0.90
data.raw.boiler["boiler-3"].energy_source.effectivity=1
data.raw.boiler["boiler-4"].energy_source.effectivity=1.1
data.raw.boiler["boiler-5"].energy_source.effectivity=1.25
]]--