-- Original Beta 8 artwork: KaoExtended chest and Miles/Bob electronics IV-V.
-- Only graphics; preserve current footprints, fluid connections and gameplay.
local root = "__zzzparanoidal__/graphics/entity/beta8-visuals/"
local chest = data.raw.container["bob-titanium-chest"]
if chest then
    chest.picture = { layers = {
        {
            filename = root .. "hr-titanium-chest.png",
            priority = "extra-high", width = 66, height = 86,
            shift = { 0, -3 / 32 }, scale = 0.5,
        },
        {
            filename = root .. "hr-titanium-chest-shadow.png",
            priority = "extra-high", width = 116, height = 48,
            shift = { 14 / 32, 6 / 32 }, draw_as_shadow = true, scale = 0.5,
        },
    } }
end

for _, spec in ipairs({
    { "electronics-machine-4", { r = 1, g = 0.5, b = 0.2 } },
    { "electronics-machine-5", { r = 1, g = 1, b = 1 } },
}) do
    local entity = data.raw["assembling-machine"][spec[1]]
    if entity then
        entity.graphics_set = entity.graphics_set or {}
        -- 2.0 has no hr_version: use the original HR layers directly.
        entity.graphics_set.animation = { layers = {
            {
                filename = root .. "hr-assembling-machine-2.png",
                priority = "high", width = 214, height = 218,
                frame_count = 32, line_length = 8,
                shift = { 0, (4 * 2 / 3) / 32 }, scale = 1 / 3,
            },
            {
                filename = root .. "assembling-machine-mask.png",
                priority = "high", width = 142, height = 113,
                repeat_count = 32, shift = { 0.84 * 2 / 3, -0.09 * 2 / 3 },
                scale = 2 / 3, tint = spec[2],
            },
            {
                filename = root .. "hr-assembling-machine-2-shadow.png",
                priority = "high", width = 196, height = 163,
                frame_count = 32, line_length = 8, draw_as_shadow = true,
                shift = { (12 * 2 / 3) / 32, (4.75 * 2 / 3) / 32 }, scale = 1 / 3,
            },
        } }
        entity.animation = nil
        -- Keep current working_visualisations (including Bottleneck status lights).
    end
end
