if mods.extendedangels then
    local seed_extractor_fluid_box = {
    {
        production_type = 'input',
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, -2} }}
    },
    off_when_no_fluid_recipe = true
}
    data.raw["assembling-machine"]["seed-extractor-2"].fluid_boxes = seed_extractor_fluid_box
    data.raw["assembling-machine"]["seed-extractor-3"].fluid_boxes = seed_extractor_fluid_box
end
