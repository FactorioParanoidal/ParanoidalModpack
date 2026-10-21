-- Keep upstream light mods intact; apply the pack's Factorio 2.0 graphics fixes last.
if mods["BigLight"] then
    local color = settings.startup["ritnmods-bl-02"].value and "green" or "yelow"
    local glow_scale = settings.startup["ritnmods-bl-03"].value / 2
    local geometry = {
        [1] = {
            north = {17, 9, -70.75, -44.25},
            west = {6, 16, 34.5, 19.5},
            south = {16, 4, 70, -95},
            east = {6, 16, -30.5, -112},
        },
        [2] = {
            north = {16, 9, -57.5, -43.75},
            west = {6, 16, 34.5, 10},
            south = {16, 5, 57, -94.75},
            east = {7, 15, -30.75, -102.75},
        },
    }
    local lights = {}
    for index = 1, 2 do
        -- Upstream tables retain the glow offsets, colours and directional mapping.
        -- Their primary sprites are LR; the commented HR definitions cannot be used as-is.
        local light = table.deepcopy(require("__BigLight__/lualib/train/" .. color .. "/light" .. index))
        for _, picture in ipairs({light.picture, light.red_picture}) do
            for direction, dimensions in pairs(geometry[index]) do
                local sprite = picture[direction].layers[1]
                if picture == light.picture then
                    sprite.filename = sprite.filename:gsub("/train%-stop%-", "/hr-train-stop-")
                end
                -- Base red sprites already use the HR filenames in Factorio 2.0.
                sprite.width = dimensions[1]
                sprite.height = dimensions[2]
                sprite.shift = {dimensions[3] / 32, dimensions[4] / 32}
                sprite.scale = 0.5
                picture[direction].layers[2].scale = glow_scale
            end
        end
        lights[index] = light
    end

    local function light_stop(name)
        local stop = data.raw["train-stop"][name]
        if stop then
            stop.light1 = table.deepcopy(lights[1])
            stop.light2 = table.deepcopy(lights[2])
        end
    end
    if not mods["trainstopnostalgia"] or mods["cybersyn"] then
        light_stop("train-stop")
    end
    if mods["LogisticTrainNetwork"] then
        light_stop("logistic-train-stop")
    end
    if mods["train-scaling"] then
        light_stop("train-scaling-stop")
    end
end

if mods["LargerLamps-2_0"] then
    local copper_lamp = data.raw["assembling-machine"]["deadlock-copper-lamp"]
    if copper_lamp then
        copper_lamp.next_upgrade = "deadlock-large-lamp"
        -- The upstream helper already constructs the exact HR sheets, offsets and animation.
        -- Promote those definitions: Factorio 2.0 ignores nested hr_version sprites.
        local graphics = copper_lamp.graphics_set
        for index, layer in ipairs(graphics.animation.layers) do
            if layer.hr_version then
                graphics.animation.layers[index] = layer.hr_version
            end
        end
        for _, visualisation in ipairs(graphics.working_visualisations) do
            local animation = visualisation.animation
            if animation and animation.hr_version then
                visualisation.animation = animation.hr_version
            end
        end
    end
end
