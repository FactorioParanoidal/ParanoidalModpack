local boomMaterial = "uranium-235";

local deadMaterial = "uranium-238";

local smallBoomMaterial = "californium";


if settings.startup["dead-material"].value == "mod-dependant" then 

elseif settings.startup["dead-material"].value == "custom" then 
	boomMaterial = settings.startup["dead-material-name"].value
end

if settings.startup["boom-material"].value == "mod-dependant" then 
	if mods["apm_nuclear_ldinc"] then
		boomMaterial = "apm_oxide_pellet_pu239";
	end 
	if mods["Clowns-Nuclear"] then
		boomMaterial = "plutonium-239";
	end 
	if mods["Nuclear Fuel"] then
		boomMaterial = "plutonium";
	end
elseif settings.startup["boom-material"].value == "custom" then 
	boomMaterial = settings.startup["boom-material-name"].value
end

if(settings.startup["small-boom-material"].value == "same-as-boom") then
	smallBoomMaterial = boomMaterial
elseif settings.startup["small-boom-material"].value == "mod-dependant" then 
	
elseif settings.startup["small-boom-material"].value == "custom" then 
	smallBoomMaterial = settings.startup["small-boom-material-name"].value
end


return {
	boomMaterial = boomMaterial,
	deadMaterial = deadMaterial,
	smallBoomMaterial = smallBoomMaterial,
};
