-- reconfigure all miniloaders

local const = require('lib.constants')

for entity_id, entity in pairs(This.MiniLoader:entities()) do
    if not (entity.main.valid and entity.loader.valid) then
        This.MiniLoader:destroy(entity_id)
    else
        for i = 2, #entity.inserters do
            if entity.inserters[i].valid then
                entity.inserters[i].destroy()
            end
            entity.inserters[i] = nil
        end

        ---@type miniloader.SpeedConfig
        local speed_config = assert(prototypes.mod_data[const.name].data[entity.main.name].speed_config)
        entity.config.highspeed = speed_config.items_per_second > 240
        entity.inserters = assert(This.MiniLoader:createInserters(entity.main, speed_config, entity.config))

        This.MiniLoader:reconfigure(entity)
    end
end
