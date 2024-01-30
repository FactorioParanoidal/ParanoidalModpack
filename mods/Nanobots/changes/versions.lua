local changes = {}

local interface = require('interface')

changes['1.8.2'] = function()
    interface.reset_queue('nano_queue')
end

changes['1.8.7'] = function()
    interface.reset_queue('cell_queue')
end

return changes
