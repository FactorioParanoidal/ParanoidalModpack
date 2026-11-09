if not mods["aai-signal-transmission"] then return end

for _, entity in pairs {
    data.raw["roboport"]["aai-signal-sender"],
    data.raw["roboport"]["aai-signal-receiver"],
} do
    entity.maraxsis_buildability_rules = {water = false, dome = true, coral = false, trench = true, trench_entrance = false, trench_lava = false}
end
