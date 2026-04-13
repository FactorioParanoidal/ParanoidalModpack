local actions = require('modules/actions')
local Util = require('modules/util')
local mod_gui = require("mod-gui")

local GUI = {}

-- Generate sorted action list.
local sorted_actions = {}
for _, action in pairs(actions) do
    sorted_actions[#sorted_actions + 1] = action
end
table.sort(sorted_actions, function(a, b) return a.order < b.order end)

GUI.sorted_actions = sorted_actions

function GUI.setup(player)
    --log("GUI.setup")
    local flow = mod_gui.get_frame_flow(player)
    if flow.BPEX_Button_Flow then
        flow.BPEX_Button_Flow.destroy()
    end
    local buttonFlow = flow.add {
        type = "flow",
        name = "BPEX_Button_Flow",
        enabled = true,
        style = "slot_table_spacing_vertical_flow",
        direction = "vertical"
    }

    for _, action in ipairs(sorted_actions) do
        if action.icon and player.mod_settings[action.visibility_setting].value then
            buttonFlow.add{
                name = action.name,
                type = "sprite-button",
                style = (action.shortcut_style and "shortcut_bar_button_" .. action.shortcut_style) or "shortcut_bar_button",
                sprite = action.name,
                tooltip = {""," ", {"controls." .. action.name} },
                enabled = true,
            }
        end
    end
    GUI.update_visibility(player, true)

    return buttonFlow
end


---@param player LuaPlayer
---@param force any
function GUI.update_visibility(player, force)
    --log("GUI.update_visibility")
    local pdata = storage.playerdata[player.index]
    if not pdata then
        pdata = {}
        storage.playerdata[player.index] = pdata
    end

    local bp = (Util.get_blueprint(player))
	local showButtonFlow = (bp and bp.valid_for_write) or false --TODO implement temporay blueprint fallback

    local was_enabled = pdata.buttons_enabled

    if (not force and was_enabled ~= nil and showButtonFlow == was_enabled) then
        --log("No update needed."..serpent.block({enabled=enabled,was_enabled=was_enabled,force=force~=nil}))
        return  -- No update needed.
    end

    local flow = mod_gui.get_frame_flow(player).BPEX_Button_Flow
    if flow then
        flow.visible = showButtonFlow
    else
        -- fallback if flow does not exist, why ever
        GUI.setup(player) -- this will call update_visibility again
        return
    end

    for name, action in pairs(actions) do
        if action.icon then
            player.set_shortcut_available(name, showButtonFlow)
        end
    end

    pdata.buttons_enabled = showButtonFlow
end

return GUI