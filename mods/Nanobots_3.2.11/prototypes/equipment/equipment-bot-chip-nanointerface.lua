local Data = require('__stdlib__/stdlib/data/data')
local make_shortcut = require('prototypes/equipment/make_shortcut')

Data {
    type = 'recipe',
    name = 'equipment-bot-chip-nanointerface',
    enabled = false,
    energy_required = 10,
    ingredients = {
        {'processing-unit', 1},
        {'battery', 1}
        --bobmods add construction brain
    },
    result = 'equipment-bot-chip-nanointerface'
}

Data {
    type = 'item',
    name = 'equipment-bot-chip-nanointerface',
    icon = '__Nanobots__/graphics/icons/equipment-bot-chip-nanointerface.png',
    icon_size = 32,
    placed_as_equipment_result = 'equipment-bot-chip-nanointerface',
    subgroup = 'equipment',
    order = 'e[robotics]-ae[personal-roboport-equipment]',
    stack_size = 20
}

local equipment_chip =
    Data {
    type = 'active-defense-equipment',
    name = 'equipment-bot-chip-nanointerface',
    take_result = 'equipment-bot-chip-nanointerface',
    ability_icon = {
        filename = '__Nanobots__/graphics/equipment/discharge-defense-equipment-ability.png',
        width = 32,
        height = 32,
        priority = 'medium'
    },
    sprite = {
        filename = '__Nanobots__/graphics/equipment/equipment-bot-chip-nanointerface.png',
        width = 32,
        height = 32,
        priority = 'medium'
    },
    shape = {
        width = 1,
        height = 1,
        type = 'full'
    },
    energy_source = {
        type = 'electric',
        usage_priority = 'secondary-input',
        buffer_capacity = '1kJ',
        input_flow_limit = '.5kW',
        drain = '1W'
    },
    attack_parameters = {
        type = 'projectile',
        ammo_category = 'nano-ammo',
        damage_modifier = 0,
        cooldown = 0,
        projectile_center = {0, 0},
        projectile_creation_distance = 0.6,
        range = 0,
        ammo_type = {
            type = 'projectile',
            category = 'electric',
            energy_consumption = '500W',
            action = {
                {
                    type = 'area',
                    radius = 30,
                    force = 'enemy',
                    action_delivery = nil
                }
            }
        }
    },
    automatic = false,
    categories = {'armor'}
}

make_shortcut(equipment_chip)

local effects = data.raw.technology['personal-roboport-equipment'].effects
effects[#effects + 1] = {type = 'unlock-recipe', recipe = 'equipment-bot-chip-nanointerface'}
