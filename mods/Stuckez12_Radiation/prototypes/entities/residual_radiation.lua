local invisible_point = {
    type = "simple-entity",
    name = "residual-radiation",
    icon = "__base__/graphics/icons/steel-chest.png",
    flags = {"placeable-neutral", "player-creation"},
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{0, 0}, {0, 0}},
    resistances = {
        { type = "explosion", percent = 100 }
    },
}

data:extend({invisible_point})


local explosion = data.raw["explosion"]["nuke-explosion"]

explosion.created_effect = {
    type = "direct",
    action_delivery = {
        type = "instant",
        target_effects = {}
    }
}

table.insert(explosion.created_effect.action_delivery.target_effects, {
    type = "script",
    effect_id = "on-atomic-detonation"
})
