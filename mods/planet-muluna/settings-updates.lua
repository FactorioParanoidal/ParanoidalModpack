-- if data.raw["bool-setting"]["PlanetsLib-enable-temperature"] then
--     data.raw["bool-setting"]["PlanetsLib-enable-temperature"].forced_value = true
-- end


data.raw["bool-setting"]["PlanetsLib-enable-oxygen"].forced_value = true
data.raw["bool-setting"]["PlanetsLib-enable-temperature"].forced_value = true
--data.raw["bool-setting"]["PlanetsLib-enable-nitrogen"].forced_value = true
data.raw["bool-setting"]["PlanetsLib-enable-carbon-dioxide"].forced_value = true
--data.raw["bool-setting"]["PlanetsLib-enable-argon"].forced_value = true

data.raw["bool-setting"]["PlanetsLib-enforce-gas-percentage"].forced_value = false

-- if mods["Igrys"] then --Temporary fix to get around issue with naive recipe modification in Igrys to science pack recipes that causes a lot of crashes.
--     data.raw["bool-setting"]["igrys-enhance-modded-science-packs"].hidden = true
--     data.raw["bool-setting"]["igrys-enhance-modded-science-packs"].forced_value = false
-- end