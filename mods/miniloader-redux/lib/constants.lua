---@meta
------------------------------------------------------------------------
-- mod constant definitions.
--
-- can be loaded into scripts and data
------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- globals
--------------------------------------------------------------------------------

require('stdlib.utils.string')

local table = require('stdlib.utils.table')

--------------------------------------------------------------------------------
-- main constants
--------------------------------------------------------------------------------

---@class miniloader.Constants
---@field supported_types table<string, true>
---@field supported_type_names string[]
---@field supported_loaders table<string, true>
---@field supported_loader_names string[]
---@field supported_inserters table<string, true>
---@field supported_inserter_names string[]
---@field CURRENT_VERSION number
---@field prefix string
---@field name string
---@field root string
--_@field order string
local Constants = {
    -- the current version that is the result of the latest migration
    CURRENT_VERSION = 2,

    prefix = 'hps__ml-',
    name = 'miniloader',
    root = '__miniloader-redux__',
    order = 'l[oaders]-m[iniloader]',
    config_tag_name = 'ml_config',
    no_snapping_tag_name = 'no_snapping',

    supported_types = {},
    supported_type_names = {},
    supported_loaders = {},
    supported_loader_names = {},
    supported_inserters = {},
    supported_inserter_names = {},
}

Constants.gfx_location = Constants.root .. '/graphics/'

--------------------------------------------------------------------------------
-- Framework intializer
--------------------------------------------------------------------------------

---@return FrameworkConfig config
function Constants.framework_init()
    return {
        -- prefix is the internal mod prefix
        prefix = Constants.prefix,
        -- name is a human readable name
        name = Constants.name,
        -- The filesystem root.
        root = Constants.root,
    }
end

--------------------------------------------------------------------------------
-- Path and name helpers
--------------------------------------------------------------------------------

---@param value string
---@return string result
function Constants:with_prefix(value)
    return self.prefix .. value
end

---@param path string
---@return string result
function Constants:png(path)
    return self.gfx_location .. path .. '.png'
end

---@param id string
---@return string result
function Constants:locale(id)
    return Constants:with_prefix('gui.') .. id
end

---@param prefix string?
---@return string result
function Constants:name_from_prefix(prefix)
    local name = (prefix and prefix:len() > 0 and (prefix .. '-' .. self.name)) or self.name
    return self:with_prefix(name)
end

--------------------------------------------------------------------------------
-- entity names and maps
--------------------------------------------------------------------------------

-- Base name
Constants.miniloader_name = Constants:with_prefix(Constants.name)

---@param name string
---@return string
function Constants.loader_name(name)
    return name .. '-l'
end

---@param name string
---@return string
function Constants.inserter_name(name)
    return name .. '-i'
end

---@param name string
---@return string
function Constants.debug_name(name)
    return name .. '-debug'
end

Constants.miniloader_type_names = {
    'inserter',
}

Constants.miniloader_types = table.array_to_dictionary(Constants.miniloader_type_names, true)

-- supported types for snapping. Entities that are in front of the loader are considered for changing input/output direction
---@type string[]
Constants.forward_snapping_type_names = {
    'lane-splitter', 'linked-belt', 'loader', 'loader-1x1', 'splitter', 'underground-belt', 'transport-belt'
}

-- supported types for snapping. Entities that are in front of the loader will cause the loader to "flip around"
---@type string[]
Constants.backward_snapping_type_names = {
    -- all the stuff that a loader can send things into
    'agricultural-tower', 'ammo-turret', 'artillery-turret', 'assembling-machine', 'boiler', 'burner-generator',
    'cargo-landing-pad', 'container', 'furnace', 'infinity-container', 'lab', 'linked-container', 'logistic-container',
    'reactor', 'roboport', 'rocket-silo'
}

---@type string[]
Constants.snapping_type_names = table.array_combine(Constants.forward_snapping_type_names, Constants.backward_snapping_type_names)

---@type table<string, true>
Constants.forward_snapping_types = table.array_to_dictionary(Constants.forward_snapping_type_names, true)

---@enum miniloader.LoaderDirection
---@type table<miniloader.LoaderDirection, string>
Constants.loader_direction = {
    input = 'input',
    output = 'output',
}

--------------------------------------------------------------------------------
-- settings
--------------------------------------------------------------------------------

Constants.settings_keys = {
    'loader_snapping',
    'chute_loader',
    'migrate_loaders',
    'sanitize_loaders',
    'no_power',
    'double_recipes',
}

Constants.settings_names = {}
Constants.settings = {}

for _, key in pairs(Constants.settings_keys) do
    Constants.settings_names[key] = key
    Constants.settings[key] = Constants:with_prefix(key)
end

Constants.debug_lifetime = 10 -- how long debug info is shown

--------------------------------------------------------------------------------
-- migrations
--------------------------------------------------------------------------------

---@return table<string, string>
function Constants:migrations()
    -- entities that can be migrated from the old 1.1 miniloader.
    local migrations = {
        [''] = self:with_prefix('miniloader'),
        ['fast-'] = self:with_prefix('fast-miniloader'),
        ['express-'] = self:with_prefix('express-miniloader'),
        ['filter-'] = self:with_prefix('miniloader'),
        ['fast-filter-'] = self:with_prefix('fast-miniloader'),
        ['express-filter-'] = self:with_prefix('express-miniloader'),
    }

    if Framework.settings:startup_setting(Constants.settings_names.chute_loader) then
        migrations['chute-'] = self:with_prefix('chute-miniloader')
        migrations['chute-filter-'] = self:with_prefix('chute-miniloader')
    end

    return migrations
end

--------------------------------------------------------------------------------
-- supported entities
--------------------------------------------------------------------------------

if script then
    for prototype_name, prototype in pairs(prototypes.entity) do
        if prototype_name:starts_with(Constants.prefix) and Constants.miniloader_types[prototype.type] and prototype_name:ends_with(Constants.name) then
            Constants.supported_types[prototype_name] = true
            table.insert(Constants.supported_type_names, prototype_name)

            local loader_name = Constants.loader_name(prototype_name)
            Constants.supported_loaders[loader_name] = true
            table.insert(Constants.supported_loader_names, loader_name)

            local inserter_name = Constants.inserter_name(prototype_name)
            Constants.supported_inserters[inserter_name] = true
            table.insert(Constants.supported_inserter_names, inserter_name)
        end
    end
end

--------------------------------------------------------------------------------
return Constants
