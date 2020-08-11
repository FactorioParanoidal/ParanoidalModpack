local function create_label_sprite(label)
    data:extend({
        {
            type = "sprite",
            name = "reskins-lib-"..label.."-tier-label",
            filename = reskins.lib.directory.."/graphics/icons/icon-"..label..".png",
            size = 40,
            mipmap_count = 2,
            flags = {"gui-icon"}
        }
    })
end

local icons = {
    "dots",
    "half-circle",
    "rectangle",
    "rounded-half-circle",
    "rounded-rectangle",
    "teardrop",
}

for _, v in pairs(icons) do
    create_label_sprite(v)
end