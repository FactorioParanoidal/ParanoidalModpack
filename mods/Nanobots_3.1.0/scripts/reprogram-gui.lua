local Player = require('__stdlib__/stdlib/event/player')
local Pad = prequire('__PickerAtheneum__/utils/adjustment-pad', true)
local config = require('config')

local match_to_item = {
    ['equipment-bot-chip-trees'] = true,
    ['equipment-bot-chip-items'] = true,
    ['ammo-nano-constructors'] = true,
    ['ammo-nano-termites'] = true
}

local bot_radius = config.BOT_RADIUS

local function get_match(stack)
    return stack.valid_for_read and match_to_item[stack.name]
end

local function get_max_radius(player)
    if player.cursor_stack.type == 'ammo' then
        return bot_radius[player.force.get_ammo_damage_modifier(player.cursor_stack.prototype.get_ammo_type().category)] or bot_radius[4]
    else
        local c = player.character
        return c and c.logistic_cell and c.logistic_cell.mobile and math.floor(c.logistic_cell.construction_radius) or 15
    end
end

if Pad then
    local function increase_decrease_reprogrammer(event)
        local player, pdata = Player.get(event.player_index)
        local stack = player.cursor_stack
        local change = event.change or 0
        if get_match(stack) then
            local pad = Pad.get_or_create_adjustment_pad(player, 'nano')
            local text_field = pad['nano_text_box']
            local max_radius = get_max_radius(player)
            local radius = pdata.ranges[stack.name] or max_radius
            if event.element and event.element.name == 'nano_text_box' then
                if not tonumber(event.element.text) then
                    radius = max_radius
                else
                    radius = math.min(tonumber(event.element.text), max_radius)
                end
            elseif event.element and event.element.name == 'nano_btn_reset' then
                radius = max_radius
            else
                radius = math.min(math.max(0, radius + change), max_radius)
            end
            pad['nano_btn_reset'].enabled = radius ~= max_radius
            pdata.ranges[stack.name] = radius ~= max_radius and radius or nil
            text_field.text = radius
        else
            Pad.remove_gui(player, 'nano_frame_main')
        end
    end
    local events = {defines.events.on_player_cursor_stack_changed}
    Pad.register_events('nano', increase_decrease_reprogrammer, events)
end
