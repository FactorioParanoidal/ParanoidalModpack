local bubbles = table.deepcopy(data.raw["trivial-smoke"]["smoke-fast"])
bubbles.name = "maraxsis-bubbles"
bubbles.animation = {
    filename = "__maraxsis__/graphics/entity/bubbles/bubbles.png",
    priority = "high",
    width = 64,
    height = 64,
    scale = 0.4,
    flags = {"smoke"},
    frame_count = 1,
}
bubbles.duration = 180
bubbles.cyclic = true
bubbles.show_when_smoke_off = true
bubbles.start_scale = 1
bubbles.end_scale = 5
bubbles.fade_away_duration = 120
data:extend {bubbles}

local submarine_bubbles = table.deepcopy(bubbles)
submarine_bubbles.name = "maraxsis-submarine-bubbles"
submarine_bubbles.show_when_smoke_off = false
submarine_bubbles.tint = {1, 1, 1, 0.15}
submarine_bubbles.render_layer = "lower-object-above-shadow"
data:extend {submarine_bubbles}

local swimming_bubbles = table.deepcopy(bubbles)
swimming_bubbles.name = "maraxsis-swimming-bubbles"
swimming_bubbles.show_when_smoke_off = false
swimming_bubbles.tint = {1, 1, 1, 0.15}
swimming_bubbles.animation.scale = 0.2
data:extend {swimming_bubbles}

local nuclear_bubbles = table.deepcopy(bubbles)
nuclear_bubbles.name = "maraxsis-nuclear-bubbles"
nuclear_bubbles.animation.tint = {0.5, 1, 0.5}
data:extend {nuclear_bubbles}
