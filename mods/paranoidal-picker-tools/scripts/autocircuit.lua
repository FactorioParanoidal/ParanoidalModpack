-------------------------------------------------------------------------------
--[Auto Circuit Power Poles]--
-------------------------------------------------------------------------------
-- Paranoidal: rewritten for the 2.0 wire API. A newly built pole gets a red/green wire to a pole it
-- is copper-connected to when, for that colour, those poles carry exactly one circuit network and
-- the new pole has none yet. Two different networks are never joined.
local events = require('utils/events')

local wire_ids = {defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green}

local function shortcut(event)
    if event.prototype_name == 'picker-auto-circuit' then
        local player = game.get_player(event.player_index)
        if player and player.is_shortcut_available('picker-auto-circuit') then
            player.set_shortcut_toggled('picker-auto-circuit', not player.is_shortcut_toggled('picker-auto-circuit'))
        end
    end
end
events.on(defines.events.on_lua_shortcut, shortcut)

local function connect_wires(pole)
    local copper = pole.get_wire_connector(defines.wire_connector_id.pole_copper, false)
    if not copper then return end

    -- visible poles of the same force joined to the new pole by a copper wire
    local neighbours = {}
    for _, connection in pairs(copper.connections) do
        local other = connection.target.owner
        if other ~= pole and other.valid and other.type == 'electric-pole' and other.force == pole.force
            and not other.prototype.hidden then
            neighbours[#neighbours + 1] = other
        end
    end
    if not neighbours[1] then return end

    for _, wire_id in pairs(wire_ids) do
        if not pole.get_circuit_network(wire_id) then
            local network_id, target, single = nil, nil, true
            for _, other in pairs(neighbours) do
                local network = other.get_circuit_network(wire_id)
                if network then
                    if not network_id then
                        network_id, target = network.network_id, other
                    elseif network.network_id ~= network_id then
                        single = false
                        break
                    end
                end
            end
            if target and single then
                local source = pole.get_wire_connector(wire_id, true)
                local destination = target.get_wire_connector(wire_id, true)
                if source and destination then
                    source.connect_to(destination)
                end
            end
        end
    end
end

local function on_built_entity(event)
    local entity = event.entity
    if entity.valid and entity.type == 'electric-pole' and not entity.prototype.hidden then
        if event.name == defines.events.on_built_entity then
            local player = game.get_player(event.player_index)
            if player and player.is_shortcut_toggled('picker-auto-circuit') then
                connect_wires(entity)
            end
        elseif settings.global['picker-auto-circuit-robots'].value then
            connect_wires(entity)
        end
    end
end
events.on({defines.events.on_robot_built_entity, defines.events.on_built_entity}, on_built_entity)
