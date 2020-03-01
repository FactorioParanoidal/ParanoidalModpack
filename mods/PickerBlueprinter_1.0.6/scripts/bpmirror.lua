-- Mirroring and Upgradeing code from "Foreman", by "Choumiko"

local Event = require('__stdlib__/stdlib/event/event')
local Gui = require('__stdlib__/stdlib/event/gui')
local Position = require('__stdlib__/stdlib/area/position')
local Inventory = require('__stdlib__/stdlib/entity/inventory')
local table = require('__stdlib__/stdlib/utils/table')
local interface = require('__stdlib__/stdlib/scripts/interface')
local mod_gui = require('mod-gui')

local function get_or_create_mirror_button(flow)
    local button = flow['picker_mirror_button']
    if not button then
        button =
            flow.add {
            type = 'sprite-button',
            name = 'picker_mirror_button',
            sprite = 'picker-mirror-sprite',
            style = 'picker_buttons',
            tooltip = {'blueprinter.btn-mirror'}
        }
    end
    return button
end

local function show_bp_tools(event)
    local player = game.get_player(event.player_index)
    local bp = Inventory.get_blueprint(player.cursor_stack)
    local flow = mod_gui.get_button_flow(player)
    local button = get_or_create_mirror_button(flow)
    if bp and not Inventory.is_named_bp(bp, 'Belt brush') then
        button.visible = true
    else
        button.visible = false
    end
end
Event.register(defines.events.on_player_cursor_stack_changed, show_bp_tools)

local swap_sides = {
    ['left'] = 'right',
    ['right'] = 'left',
    ['in'] = 'out',
    ['out'] = 'in',
    ['input'] = 'output',
    ['output'] = 'input'
}

function interface.on_blueprint_mirrored()
    return Event.get_event_name('on_blueprint_mirrored')
end

local function get_mirrored_blueprint(blueprint)
    local curves, others, stops, signals, tanks = 9, 0, 4, 4, 2

    local smartTrains = remote.interfaces.st and remote.interfaces.st.getProxyPositions
    local smartStops = {['smart-train-stop-proxy'] = {}, ['smart-train-stop-proxy-cargo'] = {}}
    local smartSignal, smartCargo = {}, {}

    local proxyKeys = function(trainStop)
        local proxies = remote.call('st', 'getProxyPositions', trainStop)
        local signal = proxies.signalProxy.x .. ':' .. proxies.signalProxy.y
        local cargo = proxies.cargo.x .. ':' .. proxies.cargo.y
        return {signal = signal, cargo = cargo}
    end

    local entities = blueprint.get_blueprint_entities()
    local tiles = blueprint.get_blueprint_tiles()

    if entities then
        for i, ent in pairs(entities) do
            local entType = game.entity_prototypes[ent.name] and game.entity_prototypes[ent.name].type
            ent.direction = ent.direction or 0
            if entType == 'curved-rail' then
                ent.direction = (curves - ent.direction) % 8
            elseif entType == 'rail-signal' or entType == 'rail-chain-signal' then
                ent.direction = (signals - ent.direction) % 8
            elseif entType == 'train-stop' then
                if ent.name == 'smart-train-stop' and smartTrains then
                    local proxies = proxyKeys(ent)
                    smartStops['smart-train-stop-proxy'][proxies.signal] = {old = {direction = ent.direction, position = Position.copy(ent.position)}}
                    smartStops['smart-train-stop-proxy-cargo'][proxies.cargo] = {old = {direction = ent.direction, position = Position.copy(ent.position)}}
                    ent.direction = (stops - ent.direction) % 8
                    smartStops['smart-train-stop-proxy'][proxies.signal].new = ent
                    smartStops['smart-train-stop-proxy-cargo'][proxies.cargo].new = ent
                else
                    ent.direction = (stops - ent.direction) % 8
                end
            elseif entType == 'lamp' then
                if ent.name == 'smart-train-stop-proxy' then
                    ent.direction = 0
                    table.insert(smartSignal, {entity = {name = ent.name, position = Position.copy(ent.position)}, i = i})
                end
            elseif entType == 'constant-combinator' then
                if ent.name == 'smart-train-stop-proxy-cargo' then
                    ent.direction = 0
                    table.insert(smartCargo, {entity = {name = ent.name, position = Position.copy(ent.position)}, i = i})
                end
            elseif entType == 'storage-tank' then
                ent.direction = (tanks + ent.direction) % 8
            elseif entType == 'splitter' then
                ent.direction = (others - ent.direction) % 8
                ent.input_priority = ent.input_priority and swap_sides[ent.input_priority]
                ent.output_priority = ent.output_priority and swap_sides[ent.output_priority]
            elseif entType == 'pipe-to-ground' then
                if ent.name:find('%-clamped%-l$') then
                    ent.direction = (others - ent.direction + 2) % 8
                end
            else
                ent.direction = (others - ent.direction) % 8
            end

            ent.position.x = -1 * ent.position.x

            if ent.drop_position then
                ent.drop_position.x = -1 * ent.drop_position.x
            end
            if ent.pickup_position then
                ent.pickup_position.x = -1 * ent.pickup_position.x
            end
        end
    end

    for _, data in pairs(smartSignal) do
        local proxy = data.entity
        local stop = smartStops[proxy.name][proxy.position.x .. ':' .. proxy.position.y]
        if stop then
            local newPositions = remote.call('st', 'getProxyPositions', stop.new)
            entities[data.i].position = newPositions.signalProxy
        end
    end
    for _, data in pairs(smartCargo) do
        local proxy = data.entity
        local stop = smartStops[proxy.name][proxy.position.x .. ':' .. proxy.position.y]
        if stop then
            local newPositions = remote.call('st', 'getProxyPositions', stop.new)
            entities[data.i].position = newPositions.cargo
        end
    end

    if tiles then
        for _, tile in pairs(tiles) do
            tile.position.x = -1 * tile.position.x
        end
    end
    return {entities = entities, tiles = tiles}
end

local function mirror_blueprint(event)
    local player = game.players[event.player_index]
    local blueprint = Inventory.get_blueprint(player.cursor_stack, true)
    if blueprint then
        local mirrored = get_mirrored_blueprint(blueprint)
        blueprint.set_blueprint_entities(mirrored.entities)
        blueprint.set_blueprint_tiles(mirrored.tiles)
        if blueprint.label and not event.corner then
            if blueprint.label:find('Belt Brush Corner Left') then
                blueprint.label = 'Belt Brush Corner Right ' .. blueprint.label:match('%d+')
            elseif blueprint.label:find('Belt Brush Corner Right') then
                blueprint.label = 'Belt Brush Corner Left ' .. blueprint.label:match('%d+')
            end
        end
    end
end
Gui.on_click('picker_mirror_button', mirror_blueprint)
Event.register('picker-mirror-blueprint', mirror_blueprint)
Event.register(Event.generate_event_name('on_blueprint_mirrored'), mirror_blueprint)
