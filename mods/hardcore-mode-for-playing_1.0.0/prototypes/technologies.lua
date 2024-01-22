local function showTechnologies()
	local technologies = data.raw["technology"]
	-- открываем технологию радара вновь, потому что она используется в нескольких других технлогиях явно, про которые забыли
	TreeRecipeUtil.showTechnologyWithoutMode(technologies["radars-1"])
	-- технология powder-metallurgy-1 - почему-то отключает ангел-боб, включаем, используется в нескольких местах! ОТКЛЮЧАТЬ ТОЛЬКО ЯВНО, ВО ВСЕХ ТЕХНОЛОГИЯХ ГДЕ ИСПОЛЬЗУЮТСЯ ЗАВИСИМОСТИ!!!
	TreeRecipeUtil.showTechnologyWithoutMode(technologies["powder-metallurgy-1"])
	-- вооружение боба, скрытые технологии и рецепты
	TreeRecipeUtil.showTechnologyWithoutMode(technologies["bob-bullets"])
	-- технология серной кислоты, открываем для газов из мода
	TreeRecipeUtil.showTechnologyWithoutMode(technologies["sulfur-processing"])
	TreeRecipeUtil.showTechnologyWithoutMode(technologies["oil-processing"])
end
local function hideTechnologies()
	local technologies = data.raw["technology"]
	_table.each(technologies, function(technology)
		if string.find(technology.name, "qol-", 1, true) then
			TreeRecipeUtil.hideTechnologyWithoutMode(technology)
		end
	end)
end
showTechnologies()
hideTechnologies()
