-------------------------------------------------------------------------------
--[Planners]--
-------------------------------------------------------------------------------
-- TODO Remote API for registering/removing planners

local Event = require('__stdlib__/stdlib/event/event')
local Gui = require('__stdlib__/stdlib/event/gui')
local Player = require('__stdlib__/stdlib/event/player')
local lib = require('__PickerAtheneum__/utils/lib')

-------------------------------------------------------------------------------
--[Planner Menu]--
-------------------------------------------------------------------------------
local function is_creative(player, item)
    return (item.name:find('creative%-mode') and (player.admin or player.cheat_mode) and remote.call('creative-mode', 'is_enabled'))
end

local function planner_enabled(player, item)
    local recipe = player.force.recipes[item.name]
    return not recipe or (recipe and recipe.enabled) or is_creative(player, item)
end

local function get_or_create_planner_flow(player, destroy)
    local pdata = global.players[player.index]
    local flow = player.gui.center['picker_planner_flow']
    if flow and destroy then
        return flow.destroy()
    elseif not flow then
        local planners = global.planners
        pdata.planners = pdata.planners or {}

        flow = player.gui.center.add {type = 'flow', name = 'picker_planner_flow', direction = 'vertical'}
        local frame = flow.add {type = 'frame', name = 'picker_planner_frame', direction = 'vertical', caption = {'planner-menu.header'}}
        local scroll = frame.add {type = 'scroll-pane', name = 'picker_planner_scroll'}
        scroll.style.maximal_height = 110
        local gui_table = scroll.add {type = 'table', name = 'picker_planner_table', column_count = 6}
        for planner in pairs(planners) do
            local proto = game.item_prototypes[planner]
            if pdata.planners[planner] == false then
                if not proto then
                    pdata.planners[planner] = nil
                end
            else
                pdata.planners[planner] = true
            end
            gui_table.add {
                type = 'sprite-button',
                name = 'picker_planner_table_sprite_' .. planner,
                sprite = 'item/' .. planner,
                style = pdata.planners[planner] and 'picker_buttons_med' or 'picker_buttons_med_off',
                tooltip = {'planner-menu.button', proto.localised_name, proto.localised_description}
            }
        end
        flow.visible = false
    end
    return flow
end

local function planner_clicked(event)
    local player, pdata = Player.get(event.player_index)
    local item = game.item_prototypes[event.match]

    if item then
        if event.button == defines.mouse_button_type.left then
            if planner_enabled(player, item) and player.clean_cursor() then
                player.cursor_stack.set_stack(event.match)
                event.element.parent.parent.parent.parent.visible = false
                player.opened = nil
            else
                player.print({'planner-menu.not-enabled'})
            end
        elseif event.button == defines.mouse_button_type.right then
            event.element.style = event.element.style.name == 'picker_buttons_med' and 'picker_buttons_med_off' or 'picker_buttons_med'
            pdata.planners[item.name] = event.element.style.name == 'picker_buttons_med'
        end
    end
end
Gui.on_click('picker_planner_table_sprite_(.*)', planner_clicked)

local function close_planner_menu(event)
    if event.element and event.element.name == 'picker_planner_flow' then
        event.element.visible = false
    end
end
Event.register(defines.events.on_gui_closed, close_planner_menu)

local function open_or_close_planner_menu(event)
    local player = game.players[event.player_index]
    local flow = get_or_create_planner_flow(player)
    flow.visible = not flow.visible
    player.opened = flow.visible and flow or nil
end
Event.register('picker-planner-menu', open_or_close_planner_menu)

-------------------------------------------------------------------------------
--[Next Planner]--
-------------------------------------------------------------------------------

local function get_next_planner(player, last_planner)
    local stack = player.cursor_stack
    local pdata = global.players[player.index]
    local fail = 0
    get_or_create_planner_flow(player).visible = false

    if (not stack.valid_for_read) then
        local planner
        if player.mod_settings['picker-remember-planner'].value and pdata.planners[last_planner] then
            planner = last_planner
        else
            repeat
                planner = next(pdata.planners, planner)
                fail = fail + 1
            until pdata.planners[planner] and game.item_prototypes[planner] and planner_enabled(player, game.item_prototypes[planner]) or fail == 100
        end
        return planner and pdata.planners[planner] and player.clean_cursor() and lib.get_planner(player, planner)
    elseif stack.valid_for_read then
        local name = stack.name
        local selected = player.selected
        if pdata.planners[name] and not (name == 'deconstruction-planner' and selected) then
            repeat
                name = next(pdata.planners, name)
                fail = fail + 1
            until name and pdata.planners[name] and game.item_prototypes[name] and planner_enabled(player, game.item_prototypes[name]) or fail == 100
            return name and pdata.planners[name] and player.clean_cursor() and lib.get_planner(player, name)
        end
    end
end

local function cycle_planners(event)
    local player, pdata = Player.get(event.player_index)
    if player.controller_type ~= defines.controllers.ghost then
        if not pdata.new_simple or not player.cursor_stack.valid_for_read then
            pdata.last_planner = get_next_planner(player, pdata.last_planner) and player.cursor_stack.name
        end
        pdata.new_simple = false
    end
end
Event.register('picker-next-planner', cycle_planners)

local function planners_changed()
    global.planners = {}
    for _, item in pairs(game.item_prototypes) do
        if item.type == 'blueprint-book' or item.type == 'blueprint' or item.type == 'deconstruction-item' or item.type == 'selection-tool' or item.type == 'upgrade-item' then
            if not (item.name:find('^selection%-tool') or item.order:find('no%-picker')) then
                global.planners[item.name] = true
            end
        end
    end
    for _, player in pairs(game.players) do
        local gui = player.gui.center['picker_planner_flow']
        if gui then
            gui.destroy()
        end
    end
end
Event.register(Event.core_events.init_and_config, planners_changed)
