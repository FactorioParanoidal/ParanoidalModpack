data.raw["car"]["cargo-plane"].equipment_grid = "cargo-plane-equipment-grid"

-- The mining time is a little too quick for my liking. Upped it 5 times ( 1 -> 5)
data.raw["car"]["cargo-plane"].minable.mining_time = 5
data.raw["car"]["gunship"].minable.mining_time = 5
data.raw["car"]["jet"].minable.mining_time = 5
data.raw["car"]["flying-fortress"].minable.mining_time = 5

data.raw.car["cargo-plane"].inventory_size = settings.startup["betterCargoPlanes-inventorySizeT1"].value;
data.raw.car["better-cargo-plane"].inventory_size = settings.startup["betterCargoPlanes-inventorySizeT2"].value;
data.raw.car["even-better-cargo-plane"].inventory_size = settings.startup["betterCargoPlanes-inventorySizeT3"].value;

data.raw.car["cargo-plane"].rotation_speed = settings.startup["betterCargoPlanes-rotationSpeedT1"].value;
data.raw.car["better-cargo-plane"].rotation_speed = settings.startup["betterCargoPlanes-rotationSpeedT2"].value;
data.raw.car["even-better-cargo-plane"].rotation_speed = settings.startup["betterCargoPlanes-rotationSpeedT3"].value;

