data:extend({
    {
        type = "item",
        name = "orbital-solar-collector",
        icon = "__expanded-rocket-payloads-continued__/graphic/solar-collector-32.png",
        icon_size = 32,
        subgroup = "satellites",
        order = "mS",
        stack_size = 1,
        rocket_launch_products = { { type = "item", name = "orbital-power-reciver", amount = 1 } },
        weight = 1000,
        send_to_orbit_mode = "automated"

    }
})
