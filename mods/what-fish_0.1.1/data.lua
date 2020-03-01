fish_disabled = settings.startup["what-fish-toggle"].value
if fish_disabled then
	data.raw["fish"]["fish"].autoplace = {influence = 0.00}
end