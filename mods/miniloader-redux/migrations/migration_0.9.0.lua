-- reconfigure all miniloaders

local const = require('lib.constants')

for entity_id, entity in pairs(This.MiniLoader:entities()) do
    if not (entity.main.valid and entity.loader.valid) then
        This.MiniLoader:destroy(entity_id)
    else
        ---@type miniloader.SpeedConfig
        local speed_config = assert(prototypes.mod_data[const.name].data[entity.main.name].speed_config)
        entity.config.highspeed = speed_config.items_per_second > 240
        This.MiniLoader:reconfigure(entity)
    end
end
