data:extend({
    {
        type = "item",
        name = "observation-satellite",
        icon = "__expanded-rocket-payloads-continued__/graphic/observation-sat-32.png",
        icon_size = 32,
        subgroup = "satellites",
        order = "mS",
        stack_size = 1,
        rocket_launch_products = {{ type = "item", name ="planetary-data", amount=5}},
        weight = 1000,
        send_to_orbit_mode = "automated"

    }
})