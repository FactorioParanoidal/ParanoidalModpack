data.raw["character"]["character"].mining_speed = 1
data.raw["tile"]["stone-path"].minable = {hardness = 0, mining_time = 0, result = "stone-brick"}
data.raw["tile"]["concrete"].minable = {hardness = 0, mining_time = 0, result = "concrete"}
data.raw["tile"]["hazard-concrete-right"].minable = {hardness = 0, mining_time = 0, result = "hazard-concrete"}
data.raw["tile"]["hazard-concrete-left"].minable = {hardness = 0, mining_time = 0, result = "hazard-concrete"}
data.raw["tile"]["refined-concrete"].minable = {hardness = 0, mining_time = 0, result = "refined-concrete"}
data.raw["tile"]["refined-hazard-concrete-left"].minable = {hardness = 0, mining_time = 0, result = "refined-hazard-concrete"}
data.raw["tile"]["refined-hazard-concrete-right"].minable = {hardness = 0, mining_time = 0, result = "refined-hazard-concrete"}


if (mods['Dectorio']) then 

if DECT.ENABLED["wood-floor"] then
data.raw["tile"]["dect-wood-floor"].minable = {hardness = 0, mining_time = 0, result = "dect-wood-floor"}
end

if DECT.ENABLED["concrete"] then
data.raw["tile"]["dect-concrete-grid"].minable = {hardness = 0, mining_time = 0, result = "dect-concrete-grid"}

if DECT.ENABLED["gravel"] then

	for _, variant in pairs(DECT.CONFIG.GRAVEL_VARIANTS) do
	data.raw["tile"]["dect-"..variant.name.."-gravel"].minable = {hardness = 0, mining_time = 0, result = variant.name}
	end

end


if DECT.ENABLED["painted-concrete"] then

	local directions = {
		{this="left", next="right"},
		{this="right", next="left"}
	}
	for _, variant in pairs(DECT.CONFIG.PAINT_VARIANTS) do
		for _, direction in pairs(directions) do
			data.raw["tile"]["dect-paint-"..variant.name.."-"..direction.this].minable = {hardness = 0, mining_time = 0, result = "dect-paint-"..variant.name}
			data.raw["tile"]["dect-paint-refined-"..variant.name.."-"..direction.this].minable = {hardness = 0, mining_time = 0, result = "dect-paint-refined-"..variant.name}
		end
	end
end
end
end



if (mods['Bio_Industries'])
and (data.raw["tile"]["bi-solar-mat"]) --DrD
 then 
if BI.Settings.BI_Solar_Additions then
data.raw["tile"]["bi-solar-mat"].minable = {hardness = 0, mining_time = 0, result = "bi-solar-mat"}
end
data.raw["tile"]["bi-wood-floor"].minable = {hardness = 0, mining_time = 0, result = "wood"}
end
