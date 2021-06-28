local rate,frocks,tne,a = settings.startup["unpollock-decorative-rate"].value, settings.startup["unpollock-no-fake-rocks"].value, require("noise").to_noise_expression

if frocks or rate<1 then
	for _,d in pairs(data.raw["optimized-decorative"]) do
		a=d.autoplace
		if a then
			if rate==0 then
				d.autoplace=nil
			end
			
			if a.peaks then
				if frocks then
					for _,p in pairs(a.peaks) do
						if p.noise_layer=="rocks" then d.autoplace=nil break end
					end
				end
				if rate<1 then
					a.max_probability =(a.max_probability or 1) * rate
				end
			else
				a.probability_expression = a.probability_expression * tne(rate)
			end
		end
	end
end