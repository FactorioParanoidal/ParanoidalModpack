-------------------------------------------------------------------------------
--[[robointerface]]
-------------------------------------------------------------------------------
local Event = require('__stdlib__/stdlib/event/event')
local Position = require('__stdlib__/stdlib/area/position')
local table = require('__stdlib__/stdlib/utils/table')
local Queue = require('scripts/hash_queue')
local queue

local floor = math.floor

local params_to_check = {
    ['nano-signal-chop-trees'] = {
        action = 'mark_items_or_trees',
        find_type = 'tree',
        item_name = 'raw-wood'
    },
    ['nano-signal-item-on-ground'] = {
        action = 'mark_items_or_trees',
        find_type = 'item-entity'
    },
    ['nano-tile'] = {
        action = 'tile_ground'
    },
    ['nano-signal-deconstruct-finished-miners'] = {
        action = 'deconstruct_finished_miners',
        find_type = 'mining-drill'
    },
    ['nano-signal-landfill-the-world'] = {
        action = 'landfill_the_world'
    },
    ['nano-signal-remove-tiles'] = {
        action = 'remove_tiles'
    },
    ['nano-signal-catch-fish'] = {
        action = 'mark_items_or_trees',
        find_type = 'fish',
        item_name = 'fish'
    }
}

--[[
raw-wood-cutting, scan for trees, if value is negative only scan for trees if wood in network is less then that amount
tile-item, scan for tiles, only checks first signal, if negative, will not place tiles unless that many are in network.
item-on-ground-sig, Scan for items on ground, if found cell will check for items-ground and mark for pickup if no enemies in range
networks-sig

parameters ={
    parameters = {
        {
            count = 1,
            index = 1,
            signal = {
                name = "nano-signal-item-on-ground",
                type = "virtual"
            }
        },
        {
            count = 1,
            index = 2,
            signal = {
                type = "item"
            }
        },
    }
}
--]]
local function get_parameters(params)
    local parameters = {}
    for _, param in pairs(params.parameters) do
        if param.signal.name then
            parameters[param.signal.name] = param.count
        end
    end
    return parameters
end

local function get_entity_info(entity)
    return entity.surface, entity.force, entity.position
end

Queue.mark_items_or_trees =
    function(data)
    if data.logistic_cell.valid and data.logistic_cell.construction_radius > 0 and data.logistic_cell.logistic_network then
        local surface, force, position = get_entity_info(data.logistic_cell.owner)
        if not (data.find_type or data.find_name) then
            data.find_type = 'NIL'
        end
        if not surface.find_nearest_enemy {position = position, max_distance = data.logistic_cell.construction_radius * 1.5 + 40, force = force} then
            local filter = {
                area = Position.expand_to_area(position, data.logistic_cell.construction_radius),
                name = data.find_name,
                type = data.find_type,
                limit = 300
            }
            local config = settings['global']
            local available_bots = floor(data.logistic_cell.logistic_network.available_construction_robots - (data.logistic_cell.logistic_network.all_construction_robots * (config['nanobots-free-bots-per'].value / 100)))
            local limit = -99999999999
            if data.value < 0 and data.item_name then
                limit = (data.logistic_cell.logistic_network.get_contents()[data.item_name] or 0) + data.value
            end

            for _, item in pairs(surface.find_entities_filtered(filter)) do
                if available_bots > 0 and (limit < 0) then
                    if not item.to_be_deconstructed(force) then
                        item.order_deconstruction(force)
                        available_bots = available_bots - 1
                        limit = limit + 1
                    end
                else
                    break
                end
            end
        end
    end
end

local function has_resources(miner)
    local _find = function(v, _)
        return v.prototype.resource_category == 'basic-solid' and (v.amount > 0 or v.prototype.infinite_resource)
    end
    local filter = {area = Position.expand_to_area(miner.position, miner.prototype.mining_drill_radius), type = 'resource'}
    if miner.mining_target then
        return (miner.mining_target.amount or 0) > 0
    else
        return table.find(miner.surface.find_entities_filtered(filter), _find)
    end
end

Queue.deconstruct_finished_miners = function(data)
    if not game.active_mods['AutoDeconstruct'] then
        if data.logistic_cell.valid and data.logistic_cell.construction_radius > 0 and data.logistic_cell.logistic_network then
            local surface, force, position = get_entity_info(data.logistic_cell.owner)
            local filter = {area = Position.expand_to_area(position, data.logistic_cell.construction_radius), type = data.find_type or 'error', force = force}
            for _, miner in pairs(surface.find_entities_filtered(filter)) do
                if not miner.to_be_deconstructed(force) and miner.minable and not miner.has_flag('not-deconstructable') and not has_resources(miner) then
                    miner.order_deconstruction(force)
                end
            end
        end
    end
end

local function find_network_and_cell(interface)
    local port = interface.surface.find_entities_filtered {name = 'roboport-interface-main', position = interface.position}[1]
    if port and port.valid then
        local network = port.logistic_network
        local cell =
            table.find(
            port.logistic_cell.neighbours,
            function(v)
                return v.construction_radius > 0
            end
        ) or port.logistic_cell
        return network, cell
    end
end

local function run_interface(interface)
    local behaviour = interface.get_control_behavior()
    if behaviour and behaviour.enabled then
        local logistic_network, logistic_cell = find_network_and_cell(interface)
        if logistic_network and logistic_network.available_construction_robots > logistic_network.all_construction_robots * (settings['global']['nanobots-free-bots-per'].value / 100) then
            local tick_spacing = settings['global']['nanobots-cell-queue-rate'].value
            local parameters = get_parameters(behaviour.parameters)
            --game.print(serpent.block(parameters, {comment=false, sparse=false}))
            -- If the closest roboport signal is present and > 0 then just run on the attached cell
            local just_cell = (parameters['nano-signal-closest-roboport'] or 0) > 0 and logistic_cell and {logistic_cell} or nil
            local fdata = global.forces[logistic_cell.owner.force.name]
            local next_tick = queue:next(fdata._next_cell_tick or game.tick, tick_spacing, true)
            for param_name, param_table in pairs(params_to_check) do
                if (parameters[param_name] or 0) ~= 0 then
                    for _, cell in pairs(just_cell or logistic_network.cells) do
                        local hash = queue:get_hash(cell.owner)
                        if not cell.mobile and cell.construction_radius > 0 and queue:count() < 5000 and not (hash and hash[param_table.action]) then
                            local data = {
                                position = cell.owner.position,
                                logistic_cell = cell,
                                entity = cell.owner,
                                logistic_network = logistic_network,
                                name = param_name,
                                action = param_table.action,
                                find_type = param_table.find_type,
                                find_name = param_table.find_name,
                                item_name = param_table.item_name,
                                value = parameters[param_name],
                                unit_number = cell.owner.unit_number
                            }
                            queue:insert(data, next_tick())
                        end
                    end
                end
            end
            fdata._next_cell_tick = queue:count() > 0 and next_tick() or game.tick
        end
    end
end

local function execute_interface_queue(event)
    queue:execute(event)
end
Event.register(defines.events.on_tick, execute_interface_queue)

--[Roboport Interface Scanner]--
 local function kill_or_remove_interface_parts(event, destroy)
    if event.entity.name == 'roboport-interface-main' then
        destroy = destroy or event.mod == 'creative-mode'
        local interface = event.entity
        for _, entity in pairs(interface.surface.find_entities_filtered {position = interface.position, force = interface.force}) do
            if entity ~= interface and entity.name:find('^roboport%-interface') then
                _ = (destroy and entity.destroy()) or entity.die()
            end
        end
    end
end
Event.register(defines.events.on_entity_died, kill_or_remove_interface_parts)
Event.register(
    Event.mined_events,
    function(event)
        kill_or_remove_interface_parts(event, true)
    end
)

--Build the interface, after built check the area around it for interface components to revive or create.
local function build_roboport_interface(event)
    if event.created_entity.name == 'roboport-interface-main' then
        local interface = event.created_entity
        local pos = Position(interface.position)
        local cc, ra = {}, {}
        for _, entity in pairs(interface.surface.find_entities_filtered {position = pos, force = interface.force}) do
            if entity ~= interface then
                --If we have ghosts either via blueprint or something killed them
                if entity.name == 'entity-ghost' then
                    if entity.ghost_name == 'roboport-interface-cc' then
                        _, cc = entity.revive()
                    elseif entity.ghost_name == 'roboport-interface-scanner' then
                        _, ra = entity.revive()
                    end
                elseif entity.name == 'roboport-interface-cc' then
                    cc = entity
                elseif entity.name == 'roboport-interface-scanner' then
                    ra = entity
                end
            end
        end
        --If neither CC or RA are valid at this point then let us create them.
        if not cc.valid then
            cc = interface.surface.create_entity {name = 'roboport-interface-cc', position = pos, force = interface.force}
        end
        if not ra.valid then
            ra = interface.surface.create_entity {name = 'roboport-interface-scanner', position = pos, force = interface.force}
        end

        --roboports start with a buffer of energy. Lets take that away!
        interface.energy = 0
        --Use the same backer name for the interface and radar
        ra.backer_name = interface.backer_name
        cc.direction = defines.direction.north
        cc.destructible = false
        ra.destructible = false
    end
end
Event.register(Event.build_events, build_roboport_interface)

local function on_sector_scanned(event)
    if event.radar.name == 'roboport-interface-scanner' then
        local entity = event.radar
        local interface = entity.surface.find_entities_filtered {name = 'roboport-interface-cc', position = entity.position, limit = 1}[1]
        if interface and interface.valid then
            run_interface(interface)
        end
    end
end
Event.register(defines.events.on_sector_scanned, on_sector_scanned)

local function on_init()
    global.cell_queue = Queue()
    queue = global.cell_queue
end
Event.register(Event.core_events.init, on_init)

local function on_load()
    queue = Queue(global.cell_queue)
end
Event.register(Event.core_events.load, on_load)

local function reset_cell_queue()
    global.cell_queue = nil
    queue = nil
    global.cell_queue = Queue()
    queue = global.cell_queue
    for _, fdata in pairs(global.forces) do
        fdata._next_cell_tick = game and game.tick or 0
    end
end
Event.register(Event.generate_event_name('reset_cell_queue'), reset_cell_queue)
