-- Paranoidal: factory dispatcher (script/dispatch.lua): button sprite, building pictures and the hotkey.

local F = "__factorissimo-2-notnotmelon__"

data:extend {
    {
        type = "sprite",
        name = "factorissimo-dispatch-button",
        filename = F .. "/graphics/icon/factory-1.png",
        size = 64,
        scale = 0.5,
        flags = {"gui-icon"},
    },
    {
        type = "custom-input",
        name = "factory-toggle-dispatch",
        key_sequence = "CONTROL + SHIFT + F",
        consuming = "none",
        order = "f-a",
    },
}

-- Pictures of the buildings for the factory list: the technology pictures show the building with its tier number.
for tier = 1, 4 do
    data:extend {{
        type = "sprite",
        name = "factorissimo-picture-factory-" .. tier,
        filename = F .. "/graphics/technology/factory-architecture-" .. tier .. ".png",
        size = 256,
        flags = {"gui-icon"},
    }}
end
