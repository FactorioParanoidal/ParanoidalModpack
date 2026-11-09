local collision_mask_util = require "__core__/lualib/collision-mask-util"

local water = {
    type = "simple-entity",
    name = "maraxsis-water-shader",
    localised_name = "Maraxsis water shader", -- dont @ me
    count_as_rock_for_filtered_deconstruction = false,
    icon_size = 64,
    protected_from_tile_building = false,
    remove_decoratives = "false",
    selectable_in_game = false,
    subgroup = data.raw.tile["water"].subgroup,
    flags = {"not-on-map"},
    collision_box = {{-16, -16}, {16, 16}},
    secondary_draw_order = -1,
    collision_mask = {layers = {}},
    render_layer = "light-effect",
    icon = "__maraxsis__/graphics/tile/water/water-combined.png",
    icon_size = 32,
    hidden = true,
}

local frame_sequence = {}
for k = 1, 32 do
    table.insert(frame_sequence, k)
end
local visiblity = tonumber(settings.startup["maraxsis-water-opacity"].value) / 255
water.animations = {
    tint = {r = visiblity, g = visiblity, b = visiblity, a = 1 / 255},
    height = 256,
    width = 256,
    line_length = 32,
    variation_count = 1,
    filename = "__maraxsis__/graphics/tile/water/water-combined.png",
    frame_count = 32,
    animation_speed = 0.5,
    scale = 4,
    frame_sequence = frame_sequence,
    draw_as_glow = false,
    shift = nil,
    flags = {"no-scale"}
}
data:extend {water}
