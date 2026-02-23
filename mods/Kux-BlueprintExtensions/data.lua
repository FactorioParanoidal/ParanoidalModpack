_G.mod = require("mod") --[[@as mod]]
--require 'prototypes/inputs'
require 'prototypes/items'
--require 'prototypes/style'
--require 'prototypes/shortcuts'

local actions = require('modules/actions')

---create a SpritePrototype
---@param size any
---@param x any
---@param y any
---@return SpritePrototype
local function sprite(size, x, y)
    return {
        filename = "__Kux-BlueprintExtensions__/graphics/shortcut-bar-buttons-" .. size .. ".png",
        priority = "extra-high-no-scale",
        flags = { "icon" },
        size = size,
        x = size*(x or 0),
        y = size*(y or 0),
        scale = 1
    }
end

---Create IconData[]
---@param size any
---@param x any
---@param y any
---@return IconData[]
local function icons(size, x, y)
	if isV1 then error "not supported" end
    return {{
        icon = "__Kux-BlueprintExtensions__/graphics/shortcut-bar-buttons-" .. size .. ".png",
        icon_size = size,
		shift = {size*(x or 0),size*(y or 0)},
        scale = 1
		-- tint             optional	:: Color
		-- draw_background  optional	:: bool
    }}
end

for name, action in pairs(actions) do
    if action.key_sequence then
        data:extend{ {
            type = "custom-input",
            name = name,
            key_sequence = action.key_sequence,
            order = action.order
        }}
    end

    if action.icon ~= nil then
        local sprite = sprite(32, action.icon, 1)
        sprite.type = "sprite"
        sprite.name = name

		local shortcut = --[[@as ShortcutPrototype]] isV1 and {
			name = name,
			type = "shortcut",
			localised_name = { "controls." .. name },
			associated_control_input = (action.key_sequence and name or nil),
			action = "lua",
			toggleable = action.toggleable or false,
			icon = sprite(32, action.icon, 1),
			disabled_icon = sprite(32, action.icon, 0),
			small_icon = sprite(24, action.icon, 1),
			disabled_small_icon = sprite(24, action.icon, 0),
			style = action.shortcut_style,
			order = "b[blueprints]-x[bpex]-" .. action.order
		} or { -- V2
			-- TODO FACTORIO 2.0 test
			name = name,
			type = "shortcut",
			localised_name = { "controls." .. name },
			associated_control_input = (action.key_sequence and name or nil),
			action = "lua",
			toggleable = action.toggleable or false,
			icons = icons(32, action.icon, 1),
			small_icons = icons(24, action.icon, 1),
			style = action.shortcut_style,
			order = "b[blueprints]-x[bpex]-" .. action.order
		}
		--log("sortcut '"..shortcut.name.."' => ".. serpent.block(shortcut))

        data:extend {
            sprite,
            shortcut
        }
    end
end

--COMPATIBILITY 1.1.0 renamed "clean-cursor" to "clear-cursor"
local clearedCursorProxy_linkedGameControl = "clear-cursor"
if string.find(mods["base"],"^1%.0%.") then clearedCursorProxy_linkedGameControl = "clean-cursor" end

print(mods["base"], clearedCursorProxy_linkedGameControl)

data:extend({
    {
        type = "custom-input",
        name = "Kux-BlueprintExtensions_cleared_cursor_proxy",
        key_sequence = "",
        linked_game_control = clearedCursorProxy_linkedGameControl
    }
})

if isV2 then
	data.raw["gui-style"].default["slot_table_spacing_vertical_flow"] = {
		type = "vertical_flow_style",
		vertical_spacing = 0  -- Stelle den vertikalen Abstand auf den gewünschten Wert ein
	}
end