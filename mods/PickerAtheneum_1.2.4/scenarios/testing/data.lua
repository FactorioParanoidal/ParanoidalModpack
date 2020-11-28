local Data = require('__stdlib__/stdlib/data/data')
local config = require('scenarios/testing/config')

local function make_no_controls()
    local controls = {}
    for name in pairs(data.raw['autoplace-control']) do
        if name == 'grass' then
            controls[name] = {size = 'very-high', frequency = 'very-high', richness = 'very-low'}
        else
            controls[name] = {size = 'none', frequency = 'very-low', richness = 'very-low'}
        end
    end
    return controls
end

Data('electric-energy-interface', 'electric-energy-interface'):copy('debug-energy-interface'):set_fields {
    flags = {'placeable-off-grid'},
    localised_name = 'Debug source',
    icon = data.raw['item']['electric-energy-interface'].icon,
    collision_mask = {},
    selection_box = {{0.0, -0.5}, {0.5, 0.5}},
    picture = Data.Sprites.empty_picture()
}:remove_fields {'minable', 'collision_box', 'vehicle_impact_sound', 'working_sound', 'next_upgrade'}

Data('substation', 'electric-pole'):copy('debug-substation'):set_fields {
    localised_name = 'Debug power substation',
    flags = {'placeable-off-grid'},
    icon = data.raw['item']['substation'].icon,
    selection_box = {{-0.5, -0.5}, {0.0, 0.5}},
    collision_mask = {},
    pictures = Data.Sprites.empty_pictures(),
    maximum_wire_distance = 64,
    supply_area_distance = 64,
    connection_points = Data.Sprites.empty_connection_points(1)
}:remove_fields {'minable', 'collision_box', 'vehicle_impact_sound', 'working_sound', 'next_upgrade'}

local gen = data.raw['map-gen-presets']
gen['default']['debug'] = {
    order = 'z',
    basic_settings = {
        terrain_segmentation = 'very-low',
        water = 'none',
        autoplace_controls = make_no_controls(),
        height = config.height,
        width = config.width
    }
}
