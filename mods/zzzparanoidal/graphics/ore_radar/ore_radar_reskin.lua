local PATH = "__zzzparanoidal__/graphics/ore_radar/"
-------------------------------------------------------------------------------------------------
data.raw.radar["ore-radar"].icons = {{icon = PATH .. "ore_radar_icon.png", icon_size = 64,icon_mipmaps = 4}}
data.raw.item["ore-radar"].icons= {{icon = PATH .. "ore_radar_icon.png", icon_size = 64,icon_mipmaps = 4}}
data.raw.technology["ore-radar"].icons = {{icon = PATH .. "ore_radar_tech.png", icon_size = 256, icon_mipmaps = 4}}
-------------------------------------------------------------------------------------------------
data.raw.radar["ore-radar"].integration_patch = nil
-------------------------------------------------------------------------------------------------
data.raw.radar["ore-radar"].rotation_speed = 0.0008
-------------------------------------------------------------------------------------------------
data.raw.radar["ore-radar"].pictures = {
layers = 
{
    {
    filename = PATH .. "left.png",
    priority = "low",
    width = 64,
    height = 302,
    apply_projection = false,
    direction_count = 180,
    line_length = 32,
    shift = util.by_pixel(-32, -26),
    scale = 0.5
    },
    {
    filename = PATH .. "mid.png",
    priority = "low",
    width = 64,
    height = 302,
    apply_projection = false,
    direction_count = 180,
    line_length = 32,
    shift = util.by_pixel(0, -26),
    scale = 0.5
    },
    {
    filename = PATH .. "right.png",
    priority = "low",
    width = 64,
    height = 302,
    apply_projection = false,
    direction_count = 180,
    line_length = 32,
    shift = util.by_pixel(32, -26),
    scale = 0.5
    },
    {
    filename = PATH .. "left-sh.png",
    priority = "low",
    width = 128,
    height = 160,
    apply_projection = false,
    direction_count = 180,
    line_length = 16,
    shift = util.by_pixel(-16, 11),
    draw_as_shadow = true,
    scale = 0.5
    },
    {
    filename = PATH .. "right-sh.png",
    priority = "low",
    width = 128,
    height = 160,
    apply_projection = false,
    direction_count = 180,
    line_length = 16,
    shift = util.by_pixel(41, 11),
    draw_as_shadow = true,
    scale = 0.5
    }
}
}