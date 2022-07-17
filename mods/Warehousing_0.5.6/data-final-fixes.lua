require("util")

-- We have a default research cost defined in technology.lua,
-- but copying the game's dynamically was a requested feature.
--
-- Done in data-final-fixes because other mods that override the
-- cost of logistics research use both earlier steps.
if settings.startup["Warehousing-copy-logistic-system"].value
	and data.raw["technology"]["logistic-system"] ~= nil
	and data.raw["technology"]["logistic-system"].unit ~= nil then
		data.raw["technology"]["warehouse-logistics-research-2"].unit =
			table.deepcopy(data.raw["technology"]["logistic-system"].unit)

		data.raw["technology"]["warehouse-logistics-research-2"].unit.count =
			math.floor(
				data.raw["technology"]["warehouse-logistics-research-2"].unit.count * 2
			)
end
