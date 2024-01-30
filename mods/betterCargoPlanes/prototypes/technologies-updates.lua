-- Adds Vehicle Overdrive Motor to Cargo Plane MK2 if Bob's Mods are installed.
if data.raw.technology["vehicle-motor-equipment"] then
	bobmods.lib.tech.add_prerequisite("better-cargo-planes", "vehicle-motor-equipment")
end

-- Adds Vehicle Overdrive Engine prerequisite to Cargo Plane MK3 if Bob's Mods are installed.
if data.raw.technology["vehicle-engine-equipment"] then
	bobmods.lib.tech.add_prerequisite("even-better-cargo-planes", "vehicle-engine-equipment")
end