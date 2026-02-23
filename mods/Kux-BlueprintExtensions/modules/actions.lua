

---@class Action
---@field name string
---@field icon integer
---@field key_sequence string
---@field order string
---@field visibility_setting string
---@field data "h"|"v"|false|"center"|"n"|"e"|"s"|"w"|"nw"|"ne"|"sw"|"se"
---@field shortcut_style string
---@field handler function

--name is automatical assigned by the table key
--icon is the index of the icon in the sprite sheet
--handler is assigned later

---@diagnostic disable: missing-fields

--- Actions for shortcut bar/etc.
---@type {string: Action}
local actions = {
    [mod.prefix.."flip-h"] = {
        icon = 0,
        key_sequence = "SHIFT + X",
        order = 'a-a',
        visibility_setting = mod.prefix.."show-mirror",
        data = 'h',
        shortcut_style = 'blue',
    },
    [mod.prefix.."flip-v"] = {
        icon = 1,
        key_sequence = "SHIFT + V",
        order = 'a-b',
        visibility_setting = mod.prefix.."show-mirror",
        data = 'v',
        shortcut_style = 'blue',
    },
    [mod.prefix.."rotate-clockwise"] = {
        icon = 2,
        key_sequence = "CONTROL + ALT + R",
        order = 'a-c',
        visibility_setting = mod.prefix.."show-rotate",
        data = false,
        shortcut_style = 'blue',
    },
    [mod.prefix.."clone-blueprint"] = {
        icon = 3,
        key_sequence = "SHIFT + U",
        order = 'c-a',
        visibility_setting = mod.prefix.."show-clone",
        shortcut_style = 'green',
    },
    [mod.prefix.."wireswap"] = {
        icon = 4,
        key_sequence = "CONTROL + ALT + W",
        order = 'c-b',
        visibility_setting = mod.prefix.."show-wireswap",
        shortcut_style = 'blue',
    },
    [mod.prefix.."landfill"] = {
        icon = 5,
        key_sequence = "CONTROL + ALT + L",
        order = 'c-c',
        visibility_setting = mod.prefix.."show-landfill",
        shortcut_style = 'blue',
    },
	[mod.prefix.."remove-landfill"] = {
        icon = 6,
        key_sequence = "CONTROL + SHIFT + ALT + L",
        order = 'c-d',
        visibility_setting = mod.prefix.."show-remove-landfill",
        shortcut_style = 'blue',
    },
    [mod.prefix.."snap-center"] = {
        key_sequence = "PAD 5",
        order = 'f-a',
        data = 'center',
        shortcut_style = 'blue',
    }
}

for ix, t in pairs({
    { "n", "8" },
    { "e", "6" },
    { "s", "2" },
    { "w", "4" },
    { "nw", "7" },
    { "ne", "9" },
    { "sw", "1" },
    { "se", "3" }
}) do
    local d = t[1]
    local key = t[2]

    actions[mod.prefix.."snap-" .. d] = {
        key_sequence = "PAD " .. key,
        order = 'd-' .. ix,
        data = d,
    }

    actions[mod.prefix.."nudge-" .. d] = {
        key_sequence = "CONTROL + PAD " .. key,
        order = 'e-' .. ix,
        data = d,
    }
end

actions[mod.prefix.."snap-center"] = {
    key_sequence = "PAD 5",
    order = 'f-a',
    data = 'center',
}

for name, action in pairs(actions) do action.name = name end

return actions
