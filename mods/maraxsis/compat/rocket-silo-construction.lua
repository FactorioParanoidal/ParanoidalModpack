if not mods["Rocket-Silo-Construction"] then return end

for _, silo in pairs {
    data.raw["assembling-machine"]["rsc-silo-stage1"],
    data.raw["assembling-machine"]["rsc-silo-stage2"],
    data.raw["assembling-machine"]["rsc-silo-stage3"],
    data.raw["assembling-machine"]["rsc-silo-stage4"],
    data.raw["assembling-machine"]["rsc-silo-stage5"],
    data.raw["assembling-machine"]["rsc-silo-stage6"],
} do
    silo.maraxsis_buildability_rules = {water = true, dome = false, coral = true, trench = false, trench_entrance = false, trench_lava = false}
end
