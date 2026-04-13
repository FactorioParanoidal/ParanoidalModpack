if data.raw["container"]["steel-chest"].surface_conditions ~= nil then
	local containers = { -- prototype type -> list[prototype name]
		container = {"basic"},
		["logistic-container"] = {"passive-provider", "active-provider", "storage", "buffer", "requester"},
	}
	for t, l in pairs(containers) do
		for _, n in pairs(l) do
			data.raw[t]["warehouse-" .. n].surface_conditions = {
				{
					property = "gravity",
					min = 0.1,
				}
			}

			data.raw[t]["storehouse-" .. n].surface_conditions = {
				{
					property = "gravity",
					min = 0.1,
				}
			}
		end
	end
end
