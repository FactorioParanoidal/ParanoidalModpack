-- third-party/aai-industry

if DECT.ENABLED["concrete"] and mods["aai-industry"] then
	if data.raw["recipe"]["dect-concrete-grid"] then
		data.raw["recipe"]["dect-concrete-grid"].ingredients = data.raw["recipe"]["concrete"].ingredients
	end
end
