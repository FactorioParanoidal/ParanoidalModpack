-------------------------------------------------------------------------------
--[Chest Limiter]--
-------------------------------------------------------------------------------
local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')
local Pad = require('__PickerAtheneum__/utils/adjustment-pad')

local containers = {
    ['container'] = true,
    ['logistic-container'] = true,
    ['infinity-container'] = true,
    ['cargo-wagon'] = true
}

local function get_match(stack)
    if stack.valid_for_read and stack.prototype.place_result and containers[stack.prototype.place_result.type or 'nil'] then
        return true
    end
end

local function increase_decrease_reprogrammer(event)
    local player, pdata = Player.get(event.player_index)
    local stack = player.cursor_stack
    if get_match(stack) then
        if not player.mod_settings['picker-use-bar-limit'].value then
            return
        end
        pdata.chests = pdata.chests or {}
        local bar = pdata.chests[stack.name] or 0
        local pad = Pad.get_or_create_adjustment_pad(player, 'chestlimit')
        local text_field = pad['chestlimit_text_box']
        if event.element and event.element.name == 'chestlimit_text_box' then
            if not tonumber(event.element.text) then
                bar = 0
            else
                bar = tonumber(event.element.text)
            end
        elseif event.element and event.element.name == 'chestlimit_btn_reset' then
            bar = 0
        else
            bar = math.max(0, bar + (event.change or 0))
        end
        pdata.chests[stack.name] = (bar > 0 and bar) or nil
        text_field.text = tostring(bar)
        pad['chestlimit_btn_reset'].enabled = bar ~= 0
    else
        Pad.remove_gui(player, 'chestlimit_frame_main')
    end
end
local events = {defines.events.on_player_cursor_stack_changed}
Pad.register_events('chestlimit', increase_decrease_reprogrammer, events)

--Set the limit when chests are built and data is saved.
local function on_chest_built(event)
    if containers[event.created_entity.type] then
        local player, pdata = Player.get(event.player_index)
        if not player.mod_settings['picker-use-bar-limit'].value then
            return
        end
        pdata.chests = pdata.chests or {}
        local entity = event.created_entity
        local bar = pdata.chests[entity.name]
        local inventory = entity.get_inventory(defines.inventory.chest)
        if inventory and inventory.supports_bar() and bar and bar > 0 then
            inventory.set_bar(bar + 1)
        end
    end
end
Event.register(defines.events.on_built_entity, on_chest_built)
