local config_decoder = require('config_decoder')

-- Some metatable shenannigans to defer loading the configuration until it is
-- first used. This is necessary, because reading the configuration requires
-- access to game.entity_prototypes, which is not available initially or during
-- on_load.
local metatable = {}
local table = setmetatable(table, metatable)

function metatable.__index(_, key)
    local virtual_signals_prototypes = prototypes.virtual_signal
    local config_table = {}
    for i = 1, 1000000 do
        local virtual_signal_prototype = virtual_signals_prototypes['qol-config-dummy-' .. tostring(i)]
        if virtual_signal_prototype then
            config_table[#config_table + 1] = virtual_signal_prototype.order
        else
            break
        end
    end

    local decoded_config = config_decoder(table.concat(config_table))
    metatable.__index = decoded_config
    return decoded_config[key]
end

return table
