-- КПД топлива локомотивов: расход выше, КПД растёт с уровнем. Мощность поднята только МК2 и МК3.
-- Варианты -mu (MultipleUnitTrainControl) получают тот же КПД, если уже созданы.

local EFFECTIVITY = {
  ["yir_usl"] = 0.20,
  ["locomotive"] = 0.25,
  ["bob-locomotive-2"] = 0.30,
  ["bob-locomotive-3"] = 0.35,
  ["bob-armoured-locomotive"] = 0.225,
  ["bob-armoured-locomotive-2"] = 0.275,
  ["bob-armoured-locomotive-3"] = 0.325,
  ["bet-locomotive"] = 0.40,
  ["hiend_loco"] = 0.45,
}

-- мощность в kW; у -mu двойная
local POWER_KW = {
  ["bob-locomotive-2"] = 1100,
  ["bob-locomotive-3"] = 1350,
}

for name, kw in pairs(POWER_KW) do
  local loco = data.raw.locomotive[name]
  if loco then loco.max_power = kw .. "kW" end
  local mu = data.raw.locomotive[name .. "-mu"]
  if mu then mu.max_power = (kw * 2) .. "kW" end
end

for name, effectivity in pairs(EFFECTIVITY) do
  for _, proto_name in pairs({name, name .. "-mu"}) do
    local loco = data.raw.locomotive[proto_name]
    local source = loco and (loco.energy_source or loco.burner)
    if source and source.type ~= "electric" and source.type ~= "void" then
      source.effectivity = effectivity
    end
  end
end
