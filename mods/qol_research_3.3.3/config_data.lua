--[[
    Custom configurations can be made on https://qol-research.aidiakapi.com/.
]]

local config_decoder = require('config_decoder')
local setting_name_formats = require('defines.setting_name_formats')
local config = [[1,17,crafting-speed,150*L,automation-science-pack,logistic-science-pack,175*L,chemical-science-pack,225*L,production-science-pack,300*L,space-science-pack,250*2^L,inventory-size,utility-science-pack,500*2^L,mining-speed,movement-speed,player-reach,5,1,5,5,20,0,0,2,10,1,1,3,5,10,3,1,4,5,15,2,1,3,1,4,5,5,3,1,6,7,20,3,1,3,1,4,1,6,5,5,3,1,8,9,25,4,1,3,1,4,1,6,1,8,0,5,5,1,10,11,30,5,1,3,1,4,1,6,1,8,1,10,12,5,2,5,0,0,2,10,1,1,3,2,5,1,1,4,5,15,2,1,3,1,4,4,5,1,1,6,7,20,3,1,3,1,4,1,6,4,5,2,1,13,9,25,4,1,3,1,4,1,6,1,13,0,5,4,1,10,14,30,5,1,3,1,4,1,6,1,13,1,10,15,5,5,30,0,0,2,10,1,1,3,5,20,3,1,4,5,15,2,1,3,1,4,5,10,3,1,6,7,20,3,1,3,1,4,1,6,5,10,3,1,8,9,25,4,1,3,1,4,1,6,1,8,0,10,5,1,10,11,30,5,1,3,1,4,1,6,1,8,1,10,16,5,4,5,0,0,2,10,1,1,3,4,5,2,1,4,5,15,2,1,3,1,4,4,5,2,1,6,7,20,3,1,3,1,4,1,6,4,5,2,1,13,9,25,4,1,3,1,4,1,6,1,13,0,5,4,1,10,11,30,5,1,3,1,4,1,6,1,13,1,10,17,5,3,1,0,0,2,10,1,1,3,3,1,2,1,4,5,15,2,1,3,1,4,3,1,2,1,6,7,20,3,1,3,1,4,1,6,3,1,2,1,8,9,25,4,1,3,1,4,1,6,1,8,0,1,3,1,10,11,30,5,1,3,1,4,1,6,1,8,1,10]]

local overrides = {
    {
        mod_names = { 'space-exploration' },
        config = [[1,23,crafting-speed,150*L,automation-science-pack,logistic-science-pack,175*L,chemical-science-pack,225*L,space-science-pack,300*L,se-biological-science-pack,10*L,se-space-catalogue-biological-2,100+20*L,se-space-catalogue-biological-3,250+50*L,se-space-catalogue-biological-4,500+100*L,se-deep-space-science-pack,500*2^L,inventory-size,mining-speed,movement-speed,player-reach,5,1,9,5,5,0,0,2,10,1,1,3,5,5,3,1,4,5,15,2,1,3,1,4,5,5,3,1,6,7,20,3,1,3,1,4,1,6,5,5,3,1,8,9,25,4,1,3,1,4,1,6,1,8,5,5,3,1,10,11,30,5,1,3,1,4,1,6,1,8,1,10,5,5,5,1,12,13,30,5,1,3,1,4,1,6,1,8,1,10,5,5,5,1,14,15,30,5,1,3,1,4,1,6,1,8,1,10,5,5,5,1,16,17,30,5,1,3,1,4,1,6,1,8,1,10,0,5,5,1,18,19,30,6,1,3,1,4,1,6,1,8,1,10,1,18,20,9,5,2,0,0,2,10,1,1,3,5,2,3,1,4,5,15,2,1,3,1,4,5,2,3,1,6,7,20,3,1,3,1,4,1,6,5,2,3,1,8,9,25,4,1,3,1,4,1,6,1,8,5,2,3,1,10,11,30,5,1,3,1,4,1,6,1,8,1,10,5,2,5,1,12,13,30,5,1,3,1,4,1,6,1,8,1,10,5,2,5,1,14,15,30,5,1,3,1,4,1,6,1,8,1,10,5,2,5,1,16,17,30,5,1,3,1,4,1,6,1,8,1,10,0,2,5,1,18,19,30,6,1,3,1,4,1,6,1,8,1,10,1,18,21,9,5,10,0,0,2,10,1,1,3,5,10,3,1,4,5,15,2,1,3,1,4,5,10,3,1,6,7,20,3,1,3,1,4,1,6,5,10,3,1,8,9,25,4,1,3,1,4,1,6,1,8,5,10,3,1,10,11,30,5,1,3,1,4,1,6,1,8,1,10,5,10,5,1,12,13,30,5,1,3,1,4,1,6,1,8,1,10,5,10,5,1,14,15,30,5,1,3,1,4,1,6,1,8,1,10,5,10,5,1,16,17,30,5,1,3,1,4,1,6,1,8,1,10,0,10,5,1,18,19,30,6,1,3,1,4,1,6,1,8,1,10,1,18,22,9,5,2,0,0,2,10,1,1,3,5,2,3,1,4,5,15,2,1,3,1,4,5,2,3,1,6,7,20,3,1,3,1,4,1,6,5,2,3,1,8,9,25,4,1,3,1,4,1,6,1,8,5,2,3,1,10,11,30,5,1,3,1,4,1,6,1,8,1,10,5,2,5,1,12,13,30,5,1,3,1,4,1,6,1,8,1,10,5,2,5,1,14,15,30,5,1,3,1,4,1,6,1,8,1,10,5,2,5,1,16,17,30,5,1,3,1,4,1,6,1,8,1,10,0,2,5,1,18,19,30,6,1,3,1,4,1,6,1,8,1,10,1,18,23,9,5,1,0,0,2,10,1,1,3,5,1,3,1,4,5,15,2,1,3,1,4,5,1,3,1,6,7,20,3,1,3,1,4,1,6,5,1,3,1,8,9,25,4,1,3,1,4,1,6,1,8,5,1,3,1,10,11,30,5,1,3,1,4,1,6,1,8,1,10,5,1,5,1,12,13,30,5,1,3,1,4,1,6,1,8,1,10,5,1,5,1,14,15,30,5,1,3,1,4,1,6,1,8,1,10,5,1,5,1,16,17,30,5,1,3,1,4,1,6,1,8,1,10,0,1,5,1,18,19,30,6,1,3,1,4,1,6,1,8,1,10,1,18]],
    },
    {
        mod_names = { 'Krastorio2' },
        config = [[1,20,crafting-speed,150*L,automation-science-pack,logistic-science-pack,175*L,chemical-science-pack,225*L,production-science-pack,300*L,space-science-pack,250*2^L,utility-science-pack,matter-tech-card,advanced-tech-card,singularity-tech-card,inventory-size,500*2^L,mining-speed,movement-speed,player-reach,5,1,7,5,20,0,0,2,10,1,1,3,5,10,3,1,4,5,15,2,1,3,1,4,5,5,3,1,6,7,20,3,1,3,1,4,1,6,5,5,3,1,8,9,25,4,1,3,1,4,1,6,1,8,5,5,5,1,10,11,30,4,1,12,1,8,1,10,1,13,10,5,5,1,10,11,30,5,1,12,1,8,1,10,1,13,1,14,0,5,5,1,10,11,30,6,1,12,1,8,1,10,1,13,1,14,1,15,16,7,2,5,0,0,2,10,1,1,3,2,5,1,1,4,5,15,2,1,3,1,4,4,5,1,1,6,7,20,3,1,3,1,4,1,6,4,5,2,1,12,9,25,4,1,3,1,4,1,6,1,12,4,5,4,1,10,17,30,4,1,12,1,8,1,10,1,13,8,5,4,1,10,17,30,5,1,12,1,8,1,10,1,13,1,14,0,5,4,1,10,17,30,6,1,12,1,8,1,10,1,13,1,14,1,15,18,7,5,30,0,0,2,10,1,1,3,5,20,3,1,4,5,15,2,1,3,1,4,5,10,3,1,6,7,20,3,1,3,1,4,1,6,5,10,3,1,8,9,25,4,1,3,1,4,1,6,1,8,5,10,5,1,10,11,30,4,1,12,1,8,1,10,1,13,10,10,5,1,10,11,30,5,1,12,1,8,1,10,1,13,1,14,0,10,5,1,10,11,30,6,1,12,1,8,1,10,1,13,1,14,1,15,19,7,4,5,0,0,2,10,1,1,3,4,5,2,1,4,5,15,2,1,3,1,4,4,5,2,1,6,7,20,3,1,3,1,4,1,6,4,5,2,1,12,9,25,4,1,3,1,4,1,6,1,12,4,5,4,1,10,11,30,4,1,12,1,8,1,10,1,13,10,5,4,1,10,11,30,5,1,12,1,8,1,10,1,13,1,14,0,5,4,1,10,11,30,6,1,12,1,8,1,10,1,13,1,14,1,15,20,7,3,1,0,0,2,10,1,1,3,3,1,2,1,4,5,15,2,1,3,1,4,3,1,2,1,6,7,20,3,1,3,1,4,1,6,3,1,2,1,8,9,25,4,1,3,1,4,1,6,1,8,3,1,3,1,10,11,30,4,1,12,1,8,1,10,1,13,3,1,3,1,10,11,30,5,1,12,1,8,1,10,1,13,1,14,3,1,3,1,10,11,30,6,1,12,1,8,1,10,1,13,1,14,1,15]]
    }
}

local is_matching_override
do
    local active_mods
    if script then
        active_mods = script.active_mods
    else
        active_mods = mods
    end
    is_matching_override = function (override)
        for _, mod_name in ipairs(override.mod_names) do
            if not active_mods[mod_name] then
                return false
            end
        end
        return true
    end
end
local get_config_from_external
do
    qol_research_config_overrides = qol_research_config_overrides or {}
    local concat_table = {}
    get_config_from_external = function (override)
        for _, mod_name in ipairs(override.mod_names) do
            concat_table[#concat_table + 1] = mod_name
            concat_table[#concat_table + 1] = ':'
        end
        concat_table[#concat_table] = nil
        local external_key = table.concat(concat_table)
        for i = #concat_table, 1, -1 do
            concat_table[i] = nil
        end
        return qol_research_config_overrides[external_key]
    end
end

if settings.startup[setting_name_formats.modpack_compatibility_enabled].value then
    for _, override in ipairs(overrides) do
        if is_matching_override(override) then
            local external_config = get_config_from_external(override)
            log(('[qol] enable default %s configuration override for %s'):format(
                external_config and 'external' or 'internal',
                serpent.line(override.mod_names)
            ))
            config = external_config or override.config
            break
        end
    end
end

local config_override = settings.startup[setting_name_formats.custom_config].value
if config_override ~= '' then config = config_override end

-- TODO: Investigate if there's a better way than this ugly hack
do
    local prototype_count = (#config + 199) / 200
    local prototypes = {}
    local prototype_base = {
        type = 'flying-text',
        name = 'qol-config-dummy-',
        flags = {'not-on-map', 'not-blueprintable', 'hidden', 'no-copy-paste', 'not-selectable-in-game', 'not-upgradable'},
        time_to_live = 1,
        speed = 1,
    }

    for nr = 1, prototype_count do
        local prototype = table.deepcopy(prototype_base)
        prototype.name = prototype.name .. tostring(nr)
        prototype.order = config:sub(nr * 200 - 199, nr * 200)
        prototypes[#prototypes + 1] = prototype
    end

    data:extend(prototypes)
end

return config_decoder(config)
