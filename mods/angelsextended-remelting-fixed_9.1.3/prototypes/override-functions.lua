local ov_functions = {}

ov_functions.disable_technology = function (technology) -- disable technology (may be a table containing a list of technologies)
	if type(technology) == "table" then
		for tk, tech in pairs(technology) do
			data.raw["technology"][tech].enabled = false
		end
	else
		data.raw["technology"][technology].enabled = false
	end
end

ov_functions.enable_technology = function (technology) -- enable technology (may be a table containing a list of technologies)
	if type(technology) == "table" then
		for tk, tech in pairs(technology) do
			data.raw["technology"][tech].enabled = true
		end
	else
		data.raw["technology"][technology].enabled = true
	end
end

return ov_functions