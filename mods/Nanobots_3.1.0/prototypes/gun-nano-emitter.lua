local recipe_nano_gun = {
    type = 'recipe',
    name = 'gun-nano-emitter',
    enabled = false,
    energy_required = 30,
    ingredients = {
        {'copper-plate', 5},
        {'iron-plate', 10},
        {'electronic-circuit', 2}
    },
    result = 'gun-nano-emitter'
}

local item_nano_gun = {
    type = 'gun',
    name = 'gun-nano-emitter',
    icon = '__Nanobots__/graphics/icons/nano-gun.png',
    icon_size = 32,
    subgroup = 'tool',
    order = 'c[automated-construction]-g[gun-nano-emitter]',
    attack_parameters = {
        type = 'projectile',
        ammo_category = 'nano-ammo',
        cooldown = 60,
        movement_slow_down_factor = 0.0,
        shell_particle = nil,
        projectile_creation_distance = 1.125,
        range = 40,
        sound = {
            filename = '__base__/sound/roboport-door.ogg',
            volume = 0.50
        }
    },
    stack_size = 1
}

local category_nano_gun = {
    type = 'ammo-category',
    name = 'nano-ammo'
}

data:extend({recipe_nano_gun, item_nano_gun, category_nano_gun})

local effects = data.raw.technology['nanobots'].effects
effects[#effects + 1] = {type = 'unlock-recipe', recipe = 'gun-nano-emitter'}
