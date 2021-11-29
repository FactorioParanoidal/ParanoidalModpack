local graphicsPath = "__betterCargoPlanes__/graphics/"
local iconPath = graphicsPath .. "icons/"
local entityPath = graphicsPath .. "entity/"


--region Copy-Pasta code

local function resist(type, decrease, percent)
	return {
		type = type,
		decrease = decrease,
		percent = percent
	}
end

--endregion

local function createPlane(planeNameWithDashes, guns, maxHealth, powerConsumption, powerEffectivity, accelPerEnergy, breakingPower, resistances)
	newPlane = table.deepcopy(data.raw["car"]["cargo-plane"])

	planeNameWithUnderscores = string.gsub(planeNameWithDashes, "-", "_");

	-- Metadata
	newPlane.name = planeNameWithDashes
	--newPlane.icon = iconPath .. planeNameWithUnderscores .. "_icon.png"

	-- Equipment and guns
	newPlane.equipment_grid = planeNameWithDashes .. "-equipment-grid"
	newPlane.guns = guns

	-- Stats
	newPlane.max_health = maxHealth
	newPlane.minable = { mining_time = 5, result = planeNameWithDashes }

	newPlane.consumption = tostring(powerConsumption) .. "kW"
	newPlane.effectivity = powerEffectivity
	newPlane.acceleration_per_energy = accelPerEnergy

	-- Movement
	newPlane.braking_power = tostring(breakingPower) .. "kW"

	-- Resistances
	newPlane.resistances = resistances

	-- Animation
	newPlaneBaseEntityPath = entityPath .. planeNameWithUnderscores

	newPlane.animation.layers[1].filename = newPlaneBaseEntityPath .. "/" .. planeNameWithUnderscores .. "_spritesheet.png"
	newPlane.animation.layers[1].hr_version.filename = newPlaneBaseEntityPath .. "/hr-" .. planeNameWithUnderscores .. "_spritesheet.png"

	return newPlane;
end

betterCargoPlaneResistances = {
	resist("fire", 5, 60),
	resist("physical", 5, 40),
	resist("impact", 20, 70),
	resist("explosion", 6, 40),
	resist("acid", 0, 30)
}
betterCargoPlane = createPlane("better-cargo-plane", { "flying-fortress-machine-gun" }, 1000, 1875, 1, 0.15, 3000, betterCargoPlaneResistances)

evenBetterCargoPlaneResistances = {
	resist("fire", 10, 70),
	resist("physical", 10, 50),
	resist("impact", 20, 80),
	resist("explosion", 10, 50),
	resist("acid", 0, 40)
}
evenBetterCargoPlane = createPlane("even-better-cargo-plane", { "flying-fortress-machine-gun" }, 2000, 2500, 1.25, 1, 10000, evenBetterCargoPlaneResistances)

data:extend({ betterCargoPlane, evenBetterCargoPlane })