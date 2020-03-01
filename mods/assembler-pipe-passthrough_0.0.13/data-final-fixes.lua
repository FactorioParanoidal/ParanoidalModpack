--[[
    Do all the changes in data-final-fixes.lua, in case other mods have modified the technologies
]]
local assembler_pipe_passthrough_defines = require('defines')

for j_index, j in pairs(data.raw['assembling-machine']) do
    -- if assembling-machine (vanilla)
    -- if electronics-machine (bobs)
    if j.fluid_boxes and not appmod.blacklist[j.name] then
        log('Adding fluid boxes to ' .. j.name)
        local connections_to_add = {}
        if settings.startup[assembler_pipe_passthrough_defines.names.settings.multiple_pipe_passthrough].value then
            -- add 3 extra pipe connections
            for pipe_index, pipe in ipairs(j.fluid_boxes) do -- ipairs because array with a boolean on the end
                for connection_index, connection in ipairs(pipe.pipe_connections) do
                    data.raw['assembling-machine'][j.name].fluid_boxes[pipe_index].pipe_connections[connection_index].type = 'input-output'
                    data.raw['assembling-machine'][j.name].fluid_boxes[pipe_index].base_level = -1
                    data.raw['assembling-machine'][j.name].fluid_boxes[pipe_index].height = 2
                    table.insert(
                        connections_to_add,
                        {
                            position = {connection.position[1], connection.position[2] * -1},
                            type = 'input-output'
                        }
                    )
                    table.insert(
                        connections_to_add,
                        {
                            position = {connection.position[2], connection.position[1]},
                            type = 'input-output'
                        }
                    )
                    table.insert(
                        connections_to_add,
                        {
                            position = {connection.position[2] * -1, connection.position[1]},
                            type = 'input-output'
                        }
                    )
                end
                for _, to_add in pairs(connections_to_add) do
                    table.insert(data.raw['assembling-machine'][j.name].fluid_boxes[pipe_index].pipe_connections, to_add)
                end
            end
        else
            -- only add 1
            for pipe_index, pipe in ipairs(j.fluid_boxes) do -- ipairs because array with a boolean on the end
                for connection_index, connection in ipairs(pipe.pipe_connections) do
                    data.raw['assembling-machine'][j.name].fluid_boxes[pipe_index].pipe_connections[connection_index].type = 'input-output'
                    data.raw['assembling-machine'][j.name].fluid_boxes[pipe_index].base_level = -1
                    data.raw['assembling-machine'][j.name].fluid_boxes[pipe_index].height = 2
                    data.raw['assembling-machine'][j.name].fluid_boxes[pipe_index].base_area = 20
                    table.insert(
                        connections_to_add,
                        {
                            position = {connection.position[1], connection.position[2] * -1},
                            type = 'input-output'
                        }
                    )
                end
                for _, to_add in pairs(connections_to_add) do
                    table.insert(data.raw['assembling-machine'][j.name].fluid_boxes[pipe_index].pipe_connections, to_add)
                end
            end
        end
    end
end
