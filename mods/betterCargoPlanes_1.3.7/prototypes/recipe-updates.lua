-- Replaces Steel Chest in the Better Cargo Plane recipe with Brass Chest if Bob's mods are detected.
if data.raw.item["brass-chest"] then
	bobmods.lib.recipe.replace_ingredient("better-cargo-plane", "steel-chest", "brass-chest")
end

-- Replaces Steel Chest in the Even Better Cargo Plane recipe with Titanium Chest if Bob's mods are detected.
if data.raw.item["titanium-chest"] then
	bobmods.lib.recipe.replace_ingredient("even-better-cargo-plane", "steel-chest", "titanium-chest")
end

-- Replaces Electrical Engine in the Better Cargo Plane recipe with Vehicle Overdrive Motor if Bob's mods are detected.
if data.raw.item["vehicle-motor"] then
	bobmods.lib.recipe.remove_ingredient("better-cargo-plane", "electric-engine-unit")
	bobmods.lib.recipe.add_new_ingredient("better-cargo-plane", { name = "vehicle-motor", amount = 1 })
end

-- Replaces Electrical Engine in the Better Cargo Plane recipe with Vehicle Overdrive Engine if Bob's mods are detected.
if data.raw.item["vehicle-engine"] then
	bobmods.lib.recipe.remove_ingredient("even-better-cargo-plane", "electric-engine-unit")
	bobmods.lib.recipe.add_new_ingredient("even-better-cargo-plane", { name = "vehicle-engine", amount = 1 })
end
