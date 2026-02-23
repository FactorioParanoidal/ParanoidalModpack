local flib = { entity = require("__BigLight__/lualib/functions/entity")}
------------------------------------------------------------------------------

local layer_animation = {
    filename="__BigLight__/graphics/addon-entity/addon-entity.png",
    draw_as_shadow=false,
    draw_as_light=false,
    draw_as_glow=false,
    animation_speed=1,
    frame_count=30,
    line_length=5, 
    width=800,
    height=558,
    x=0,
    y=0,
    scale=0.5,
    shift={0, -0.09375},
    priority = "high",
}

local layer_glow = {
    filename="__BigLight__/graphics/addon-entity/addon-entity-glow.png",
    draw_as_shadow=false,
    draw_as_light=false,
    draw_as_glow=true,
    animation_speed=1,
    frame_count=30,
    line_length=5, 
    width=800,
    height=558,
    x=0,
    y=0,
    scale=0.5,
    shift={0, -0.09375},
    priority = "high",
}


local assemblerName = "assembling-machine-1"
local am1 = table.deepcopy(data.raw["assembling-machine"][assemblerName])

am1.status_colors = flib.entity.standard_status_colours()
am1.working_visualisations = {
    --{animation = am1.animation.layers[1]},
    --{animation = am1.animation.layers[2]},
    {
        animation = layer_animation,
        always_draw = true,
    },
    {
        animation = layer_glow,
        light = flib.entity.standard_status_light(),
        apply_tint = "status",
        always_draw = true
    }
}

--am1.animation = nil
data.raw["assembling-machine"][assemblerName] = am1