if not mods["aai-programmable-structures"] then return end

local cant_be_placed_on_water = {water = false, dome = true, coral = false, trench = true, trench_entrance = false, trench_lava = false}
data.raw.radar["tile-scan"].maraxsis_buildability_rules = cant_be_placed_on_water
data.raw.radar["zone-scan"].maraxsis_buildability_rules = cant_be_placed_on_water
data.raw.radar["unit-scan"].maraxsis_buildability_rules = cant_be_placed_on_water
data.raw.roboport["zone-control"].maraxsis_buildability_rules = cant_be_placed_on_water
