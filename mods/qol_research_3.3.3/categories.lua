local function percentage_description(value)
    return ('%g%%'):format(value * 100)
end
local function pluralize_description(unit)
    return function(value)
        return ('%d %s%s'):format(value, unit, value == 1 and '' or 's')
    end
end

local category_list = {
    {
        name = 'crafting-speed',
        type = 'double',
        effects = { 'character-crafting-speed' },
        internal_technology_spec = {
            value_scale = 0.01,
            count = 20,
        },
        import_settings = {
            multiplier = 0.01,
            min = 0.001,
            max = 100,
        },
        description_factory = percentage_description,
    },
    {
        name = 'inventory-size',
        type = 'int',
        effects = { 'character-inventory-slots-bonus' },
        internal_technology_spec = {
            value_scale = 1,
            count = 14,
        },
        import_settings = {
            multiplier = 1,
            min = 1,
            max = 1000,
        },
        description_factory = pluralize_description('slot'),
    },
    {
        name = 'mining-speed',
        type = 'double',
        effects = { 'character-mining-speed' },
        internal_technology_spec = {
            value_scale = 0.01,
            count = 20,
        },
        import_settings = {
            multiplier = 0.01,
            min = 0.001,
            max = 100,
        },
        description_factory = percentage_description,
    },
    {
        name = 'movement-speed',
        type = 'double',
        effects = { 'character-running-speed' },
        internal_technology_spec = {
            value_scale = 0.01,
            count = 20,
        },
        import_settings = {
            multiplier = 0.01,
            min = 0.001,
            max = 100,
        },
        description_factory = percentage_description,
    },
    {
        name = 'player-reach',
        type = 'int',
        effects = {
            'character-build-distance',
            'character-item-drop-distance',
            'character-resource-reach-distance',
            'character-reach-distance',
        },
        effect_settings = {
            ['character-item-drop-distance'] = 'item-drop-distance',
            ['character-resource-reach-distance'] = 'resource-reach-distance',
        },
        internal_technology_spec = {
            value_scale = 1,
            count = 20,
        },
        import_settings = {
            multiplier = 1,
            min = 1,
            max = 1000000,
        },
        description_factory = pluralize_description('tile'),
    }
}

local category_map = {}
for index, category in ipairs(category_list) do
    category.index = index
    category_map[category.name] = category
end

return {
    list = category_list,
    map = category_map,
    count = #category_list,
}
