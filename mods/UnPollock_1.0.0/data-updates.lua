local rate,tne,a = settings.startup["unpollock-decorative-rate"].value, require("noise").to_noise_expression

for _,p in pairs(data.raw["optimized-decorative"]) do
	a=p.autoplace
	if a then
		if a.peaks then
			a.max_probability =(a.max_probability or 1) * rate
		else
			a.probability_expression = a.probability_expression * tne(rate)
		end
	end
end
