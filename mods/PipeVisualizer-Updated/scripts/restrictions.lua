
local restrictions = {}

---@alias UnitType string

restrictions.add_remote_interface = function()
    remote.add_interface("PipeVisualizer", {
        --- @param entity_names string[]
        blacklist = function(entity_names)
            if type(entity_names) ~= "table" then
                return
            end
            for _, entity_name in pairs(entity_names) do
                storage.blacklist[entity_name] = true
            end
        end,
        --- @param entity_type string
        --- @param entity_name string
        pipelist_add = function(entity_type, entity_name)
            if type(entity_type) ~= "string" or type(entity_name) ~= "string" then
                return
            end
            storage.pipelist[entity_type] = storage.pipelist[entity_type] or {}
            storage.pipelist[entity_type][entity_name] = true
        end,
        --- @param entity_type string
        --- @param entity_name string
        complexlist_add = function(entity_type, entity_name)
            if type(entity_type) ~= "string" or type(entity_name) ~= "string" then
                return
            end
            storage.complexlist[entity_type] = storage.complexlist[entity_type] or {}
            storage.complexlist[entity_type][entity_name] = true
        end,
    })
end

---@param e ConfigurationChangedData?
local function reset(e)
    -- Blacklist has to be rebuilt on every config change
    --- @type table<UnitNumber, boolean>
    storage.blacklist = {}
    --- @type table<UnitType, table<UnitNumber, boolean>>
    storage.pipelist = {}
    --- @type table<UnitType, table<UnitNumber, boolean>>
    storage.complexlist = {}
end

restrictions.on_init = reset
restrictions.on_configuration_changed = reset

return restrictions