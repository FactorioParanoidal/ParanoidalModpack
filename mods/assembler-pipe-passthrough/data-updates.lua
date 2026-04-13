function string.starts(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

appmod.blacklist['escape-pod-assembler'] = true

appmod.blacklist['assembling-machine'] = not settings.startup['app_assembling_machines'].value
appmod.blacklist['assembling-machine-2'] = not settings.startup['app_assembling_machines'].value
appmod.blacklist['assembling-machine-3'] = not settings.startup['app_assembling_machines'].value

appmod.blacklist['oil-refinery'] = not settings.startup['app_oil_refineries'].value
appmod.blacklist['chemical-plant'] = not settings.startup['app_chemical_plants'].value

-- I really don't want to be blacklisting other mods again...

if mods['bobassembly'] then
  appmod.blacklist['bob-steam-assembling-machine'] = true
end

-- P.U.M.P.S -- entities is 1x2, but has a calculated collision box of 2x2 2022.05.17
if mods['P-U-M-P-S'] then
  appmod.blacklist['offshore-pump-0'] = true
  appmod.blacklist['offshore-pump-1'] = true
  appmod.blacklist['offshore-pump-2'] = true
  appmod.blacklist['offshore-pump-3'] = true
  appmod.blacklist['offshore-pump-4'] = true

  appmod.blacklist['water-pumpjack-1'] = true
  appmod.blacklist['water-pumpjack-2'] = true
  appmod.blacklist['water-pumpjack-3'] = true
  appmod.blacklist['water-pumpjack-4'] = true
  appmod.blacklist['water-pumpjack-5'] = true

  appmod.blacklist['seafloor-pump'] = true
  appmod.blacklist['ground-water-pump'] = true
end

-- RealisticFusionReactors
appmod.blacklist['rfp-discharge-pump'] = true -- entity is 1x2, but has a calculated collision box of 2x2 2022.02.17

-- Yukio Industries - Engines (Addon)
appmod.blacklist['y-emotor-s'] = true

if mods['FluidicPower'] then
  for _, j in pairs(data.raw['assembling-machine']) do
    if string.starts(j.name, 'fluidic-') then
      appmod.blacklist[j.name] = true
    end
  end
end

-- 248k mod; thanks Shirotha
if mods['248k'] then
  appmod.blacklist['fu_star_engine_core_entity'] = true
  appmod.blacklist['fu_star_engine_heater_entity'] = true
  appmod.blacklist['fu_star_engine_heater_left_entity'] = true
  appmod.blacklist['fu_star_engine_cooler_entity'] = true
  appmod.blacklist['fu_star_engine_cooler_up_entity'] = true
end

-- Factorissimo 3 mod, thanks aerospacesmith
if mods['factorissimo-2-notnotmelon'] then
  appmod.blacklist['borehole-pump'] = true
end
