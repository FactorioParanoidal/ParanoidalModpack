data.raw["generator"]["texugo-wind-turbine"].effectivity = settings.startup["texugo-wind-power"].value*0.121
data.raw["generator"]["texugo-wind-turbine2"].effectivity = settings.startup["texugo-wind-power"].value*1.21
data.raw["generator"]["texugo-wind-turbine3"].effectivity = settings.startup["texugo-wind-power"].value*12.1


--if bobsmods and bobmods.electronics then 
if mods["bobelectronics"] and mods["boblibrary"] then 
bobmods.lib.recipe.replace_ingredient("texugo-wind-turbine", "electronic-circuit", "basic-circuit-board")
 end