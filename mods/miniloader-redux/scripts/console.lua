--------------------------------------------------------------------------------
-- custom commands
--------------------------------------------------------------------------------
assert(script)

local Event = require('stdlib.event.event')
local Is = require('stdlib.utils.is')

local const = require('lib.constants')

--------------------------------------------------------------------------------

---@class miniloader.Console
local Console = {}

---@param unit_number integer
---@param ml_entity miniloader.Data
local function check_valid(unit_number, ml_entity)
    if not (ml_entity and Is.Valid(ml_entity.main)) then return false end

    if unit_number ~= ml_entity.main.unit_number then return false end

    if not Is.Valid(ml_entity.loader) then return false end

    for _, inserter in pairs(ml_entity.inserters) do
        if not Is.Valid(inserter) then return false end
    end
    return true
end

---@param data CustomCommandData
local function inspect_miniloaders(data)
    local all = {
        miniloader = {},
        loader = {},
        inserter = {},
    }

    local invalid = {
        miniloader = 0,
        loader = 0,
        inserter = 0,
    }

    local removed = {
        entity = 0,
        miniloader = 0,
        loader = 0,
        inserter = 0,
    }


    ---@param list LuaEntity[]
    ---@param entity_type string
    local function insert(list, entity_type)
        for _, entity in pairs(list) do
            if entity.valid then
                all[entity_type][entity.unit_number] = entity
            else
                invalid[entity_type] = invalid[entity_type] + 1
            end
        end
    end

    for _, surface in pairs(game.surfaces) do
        insert(surface.find_entities_filtered {
            name = const.supported_type_names,
            type = 'inserter',
        }, 'miniloader')

        insert(surface.find_entities_filtered {
            name = const.supported_loader_names,
            type = 'loader-1x1',
        }, 'loader')

        insert(surface.find_entities_filtered {
            name = const.supported_inserter_names,
            type = 'inserter',
        }, 'inserter')
    end

    for unit_number, ml_entity in pairs(This.MiniLoader:entities()) do
        if not check_valid(unit_number, ml_entity) then
            This.MiniLoader:destroy(unit_number)
            if ml_entity.main and ml_entity.main.valid then
                ml_entity.main.destroy()
            end

            removed.entity = removed.entity + 1
        else
            -- miniloader is valid. Remove innards from the the set of found entities
            all.miniloader[ml_entity.main.unit_number] = nil
            all.loader[ml_entity.loader.unit_number] = nil
            for i = 2, #ml_entity.inserters do
                all.inserter[ml_entity.inserters[i].unit_number] = nil
            end
        end
    end

    for _, type in pairs { 'miniloader', 'loader', 'inserter' } do
        for _, entity in pairs(all[type]) do
            entity.destroy()
            removed[type] = removed[type] + 1
        end
    end

    game.print { const:locale('command_inspect_miniloaders_invalid'), invalid.miniloader, invalid.loader, invalid.inserter }
    game.print { const:locale('command_inspect_miniloaders_removed'), removed.miniloader, removed.loader, removed.inserter, removed.entity }
end

---@param data CustomCommandData
local function inserter_control(data)
    local mode
    if data.parameter == 'on' then
        mode = true
        game.print { const:locale('command_control_miniloader_inserters_on') }
    elseif data.parameter == 'off' then
        mode = false
        game.print { const:locale('command_control_miniloader_inserters_off') }
    else
        game.print { const:locale('command_control_miniloader_inserters_invalid'), data.parameter or '' }
        return
    end

    for _, entity in pairs(This.MiniLoader:entities()) do
        assert(entity.main.valid)
        for _, inserter in pairs(entity.inserters) do
            assert(inserter.valid)
            inserter.active = mode
        end
    end
end

---@param data CustomCommandData
local function rebuild_inserter(data)
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
end


function Console:register_commands()
    commands.add_command('inspect-miniloaders', { const:locale('command_inspect_miniloaders') }, inspect_miniloaders)
    commands.add_command('control-miniloader-inserters', { const:locale('command_control_miniloader_inserters') }, inserter_control)
    commands.add_command('rebuild-miniloader-inserters', { const:locale('command_rebuild_miniloader_inserters') }, rebuild_inserter)
end

--------------------------------------------------------------------------------
-- mod init/load code
--------------------------------------------------------------------------------

local function on_init()
    Console:register_commands()
end

local function on_load()
    Console:register_commands()
end

Event.on_init(on_init)
Event.on_load(on_load)

return Console
