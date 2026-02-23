data:extend({
    {
        type = "item",
        name = "mining-shuttle",
        icon = "__expanded-rocket-payloads-continued__/graphic/mining-shuttle-32.png",
        icon_size = 32,
        subgroup = "Space-Shuttles",
        stack_size = 1,
        rocket_launch_products = {{ type = "item", name ="landed-mining-shuttle", amount=1}},
        weight = 1000,
        send_to_orbit_mode = "automated"
    }
})