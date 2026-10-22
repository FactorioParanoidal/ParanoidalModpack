-- Match the restored tank item tiers, not Reskins' shifted progression tiers.
-- Only recolor the known technology mask; preserve the artwork and other layers.
local mask = "__reskins-bobs__/graphics/technology/plates/fluid-handling/fluid-handling-technology-mask.png"
local colors = {
    ["fluid-handling"] = "#ffb726",
    ["bob-fluid-handling-2"] = "#f22318",
    ["bob-fluid-handling-3"] = "#33b4ff",
    ["bob-fluid-handling-4"] = "#b459ff",
}

for name, color in pairs(colors) do
    local technology = data.raw.technology[name]
    if technology then
        for _, layer in ipairs(technology.icons or {}) do
            if layer.icon == mask then
                layer.tint = util.color(color)
            end
        end
    end
end
