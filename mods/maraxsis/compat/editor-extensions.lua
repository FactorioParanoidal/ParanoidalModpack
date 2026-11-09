if not mods["EditorExtensions"] then return end

for _, entity in pairs {
    data.raw["electric-energy-interface"]["ee-infinity-accumulator-primary-output"],
    data.raw["electric-energy-interface"]["ee-infinity-accumulator-secondary-output"],
    data.raw["electric-energy-interface"]["ee-infinity-accumulator-tertiary-output"],
    data.raw["electric-energy-interface"]["ee-infinity-accumulator-primary-input"],
    data.raw["electric-energy-interface"]["ee-infinity-accumulator-secondary-input"],
    data.raw["electric-energy-interface"]["ee-infinity-accumulator-tertiary-input"],
    data.raw["electric-energy-interface"]["ee-infinity-accumulator-tertiary-buffer"],
} do
    entity.maraxsis_buildability_rules = {water = true, dome = true, coral = true, trench = true, trench_entrance = false, trench_lava = false}
end
