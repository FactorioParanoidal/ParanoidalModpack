------------------------------------------------------------------------
-- data phase 2
------------------------------------------------------------------------

require('lib.init')

------------------------------------------------------------------------

local util = require('util')

local const = require('lib.constants')

-- all loaders are templated
local templates = require('prototypes.templates')
local functions = require('prototypes.functions')

local upgrades = {}

if Framework.settings:startup_setting('debug_mode') then
    data:extend {
        {
            type = 'item-subgroup',
            name = 'miniloader-debug',
            group = 'logistics',
            order = 'ca',
        }
    }
end

local mod_data = {
    type = 'mod-data',
    name = const.name,
    hidden = true,
    hidden_in_factoriopedia = true,
    data = {}
}

-- find all active processors
---@type miniloader.PrototypeProcessor[]
local global_prototype_processors = {}
for key, value in pairs(templates.game_mode) do
    if value and templates.prototype_processors[key] then
        table.insert(global_prototype_processors, templates.prototype_processors[key])
    end
end

for prefix, loader_definition in pairs(templates.loaders) do
    assert(loader_definition.condition)
    if (loader_definition.condition()) then
        local dash_prefix = functions.compute_dash_prefix(prefix)
        ---@type miniloader.LoaderTemplate
        local params = util.copy(loader_definition.data(dash_prefix))
        params.prefix = prefix
        params.name = const:with_prefix(dash_prefix .. const.name)
        params.localised_name = params.localised_name and params.localised_name or { 'entity-name.' .. params.name }
        if params.upgrade_from then
            upgrades[params.upgrade_from] = params.name
        end

        params.global_prototype_processors = global_prototype_processors

        -- create per-loader items
        functions.create_item(params)
        functions.create_entity(params)
        functions.create_recipe(params)

        mod_data.data[params.name] = {
            speed_config = params.speed_config,
            nerf_mode = params.nerf_mode or false,
        }

        if Framework.settings:startup_setting('debug_mode') then
            functions.create_debug(params)
        end
    end
end

for upgrade, target in pairs(upgrades) do
    local previous_tier = data.raw['inserter'][upgrade]
    if previous_tier then
        assert(previous_tier.next_upgrade == nil)
        previous_tier.next_upgrade = target
    end
end

data:extend { mod_data }

------------------------------------------------------------------------

Framework.post_data_updates_stage()
