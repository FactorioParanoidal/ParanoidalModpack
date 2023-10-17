local boomMaterial = "uranium-235";
local UBoomMaterial = "uranium-235";


local deadMaterial = "uranium-238";

local smallBoomMaterial = "californium";

local lightMaterial = "low-density-structure";

local computer = "processing-unit";

local fusionMaterial = "tritium-canister";

local reflector = "neutron-reflector";


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
  if mods["PlutoniumEnergy"] then
    boomMaterial = "plutonium-239";
  end
  if mods["Atomic_Overhaul"] then
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

if settings.startup["computer-material"].value == "mod-dependant" then
  if mods["bobelectronics"] then
    computer = "superior-circuit-board"
  end
elseif settings.startup["computer-material"].value == "custom" then
  computer = settings.startup["computer-material-name"].value
end

if settings.startup["light-material"].value == "mod-dependant" then

elseif settings.startup["light-material"].value == "custom" then
  computer = settings.startup["light-material-name"].value
end

return {
  UBoomMaterial = UBoomMaterial,
  boomMaterial = boomMaterial,
  deadMaterial = deadMaterial,
  smallBoomMaterial = smallBoomMaterial,
  fusionMaterial = fusionMaterial,
  lightMaterial = lightMaterial,
  computer = computer,
  reflector = reflector
};
