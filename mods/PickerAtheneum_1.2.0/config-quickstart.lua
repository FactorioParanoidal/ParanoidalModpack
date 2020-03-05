-- Settings used for the quickstart script,
-- if an item doesn't exist it is ignored.
return {
    cheat_mode = true,
    always_day = true,
    power_armor = 'power-armor-mk2',
    equipment = {
        'fusion-reactor-equipment',
        'personal-roboport-mk2-equipment',
        'belt-immunity-equipment'
    },
    destroy_everything = true,
    disable_rso_starting = true,
    disable_rso_chunk = true,
    floor_tile = 'lab-dark-1',
    floor_tile_alt = 'lab-dark-2',
    ore_patches = true,
    water_tiles = true,
    custom_bp_string = false,
    default_bp_string = true,
    area_box = {{-250, -250}, {250, 250}},
    chunk_bounds = true,
    center_map_tag = true,
    setup_power = true,
    items = {
        ['picker-infinity-chest'] = 50,
        ['picker-infinity-pipe'] = 50,
        ['picker-heat-interface'] = 50,
        ['picker-electric-energy-interface'] = 50,
        ['construction-robot'] = 50,
        ['assembling-machine-3'] = 50,
        ['pipe'] = 50,
        ['fast-inserter'] = 50,
        ['picker-note'] = 50,
        ['picker-sign'] = 50
    }
}
