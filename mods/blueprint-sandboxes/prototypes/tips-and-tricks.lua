local category = BPSB.pfx .. "intro"
local pfxOrder = BPSB.pfx
local pfxCategory = category .. "-"

data:extend({
    {
        type = "tips-and-tricks-item-category",
        name = category,
        order = pfxOrder .. "a",
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        tag = "[img=item-group." .. BPSB.name .. "]",
        name = pfxCategory .. "introduction",
        order = pfxOrder .. "a",
        is_title = true,
        starting_status = "unlocked",
        trigger = {
            type = "time-elapsed",
            ticks = 60 * 5 -- 5 seconds
        },
        image = BPSB.path .. "/graphics/toggle-gui.png",
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "multiple-sandboxes",
        indent = 1,
        order = pfxOrder .. "b",
        dependencies = { pfxCategory .. "introduction" },
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
        image = BPSB.path .. "/graphics/choose-sandbox.png",
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        tag = "[img=utility/reset_white]",
        name = pfxCategory .. "reset-v2",
        indent = 1,
        order = pfxOrder .. "c",
        dependencies = { pfxCategory .. "introduction" },
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
        image = BPSB.path .. "/graphics/reset-sandbox.png",
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        tag = "[img=utility/select_icon_white]",
        name = pfxCategory .. "daylight",
        indent = 1,
        order = pfxOrder .. "d",
        dependencies = { pfxCategory .. "introduction" },
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
        image = BPSB.path .. "/graphics/daylight-slider.png",
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "sandbox-force",
        indent = 1,
        order = pfxOrder .. "e",
        dependencies = { pfxCategory .. "introduction" },
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "new-recipes",
        indent = 1,
        order = pfxOrder .. "f",
        dependencies = { pfxCategory .. "introduction" },
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
        image = BPSB.path .. "/graphics/recipes.png",
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "god-mode",
        indent = 1,
        order = pfxOrder .. "g",
        dependencies = { pfxCategory .. "introduction" },
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "auto-building",
        indent = 1,
        order = pfxOrder .. "h",
        dependencies = { pfxCategory .. "introduction" },
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
        simulation = {
            init = [[
                local stack = game.create_inventory(1)[1]
                stack.import_stack("0eNqV1NuKwyAQBuB3mWtb4ilpfZWyLEkri5CYoHbZEHz3muambFOYufT0ifLPLND1dzsF5xOYBdx19BHMZYHofnzbr3NpniwYcMkOwMC3wzpKofVxGkM6dLZPkBk4f7N/YHj+YmB9csnZTXoO5m9/HzobyoZPBoNpjOXY6NdbC3UQR81gBiOPulxwc8Fet2WR2Zsr8G5FcSXe5RRXoV0Sq9Es6RdqNCs/sWqHbdAsKQsnesZUcXekM13S+xKv6EHS/x9b78GcnnwcLMhZwrmSHH2cq8hpwrmaHH6cSy8q9V5Upd0+W7N56eQMfm2IW3mcuGrOotFcc1lXOT8AiIPzfg==")
                stack.build_blueprint {
                    surface = game.surfaces[1],
                    force = game.forces.player,
                    position = { 0, 0 },
                }

                script.on_nth_tick(30, function()
                    local requestsHandled = 0
                    local requestedRevives = game.surfaces[1].find_entities_filtered({
                        type = "entity-ghost",
                        limit = 1,
                    })
                    for _, request in pairs(requestedRevives) do
                        requestsHandled = requestsHandled + 1
                        request.revive()
                    end
                    if requestsHandled == 0 then
                        script.on_nth_tick(60, nil)
                    end
                end)
            ]]
        },
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "illusions",
        indent = 1,
        order = pfxOrder .. "i",
        dependencies = { pfxCategory .. "introduction" },
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
    },
})

if mods["space-exploration"] then
    category = BPSB.pfx .. "space-exploration"
    pfxCategory = category .. "-"
    data:extend({
        {
            type = "tips-and-tricks-item-category",
            name = category,
            order = pfxOrder .. "b",
        },
        {
            type = "tips-and-tricks-item",
            category = category,
            tag = "[img=virtual-signal.se-spaceship] [img=item-group." .. BPSB.name .. "]",
            name = pfxCategory .. "introduction",
            order = pfxOrder .. "a",
            is_title = true,
            trigger = {
                type = "and",
                triggers = {
                    {
                        type = "unlock-recipe",
                        recipe = BPSB.pfx .. "electric-energy-interface",
                    }, {
                        type = "unlock-recipe",
                        recipe = "se-medpack",
                    }
                },
            },
        },
        {
            type = "tips-and-tricks-item",
            category = category,
            tag = "[img=virtual-signal.se-star]",
            name = pfxCategory .. "inner-star-tech",
            indent = 1,
            order = pfxOrder .. "b",
            dependencies = { pfxCategory .. "introduction" },
            trigger = {
                type = "unlock-recipe",
                recipe = BPSB.pfx .. "electric-energy-interface",
            },
        },
        {
            type = "tips-and-tricks-item",
            category = category,
            tag = "[img=virtual-signal.se-planet]",
            name = pfxCategory .. "planetary-lab",
            indent = 1,
            order = pfxOrder .. "c",
            dependencies = { pfxCategory .. "introduction" },
            trigger = {
                type = "unlock-recipe",
                recipe = BPSB.pfx .. "electric-energy-interface",
            },
        },
        {
            type = "tips-and-tricks-item",
            category = category,
            tag = "[img=virtual-signal.se-planet-orbit]",
            name = pfxCategory .. "orbital-sandbox",
            indent = 1,
            order = pfxOrder .. "d",
            dependencies = { pfxCategory .. "introduction" },
            trigger = {
                type = "unlock-recipe",
                recipe = BPSB.pfx .. "electric-energy-interface",
            },
        },
        {
            type = "tips-and-tricks-item",
            category = category,
            tag = "[img=virtual-signal.se-remote-view]",
            name = pfxCategory .. "remote-view",
            indent = 1,
            order = pfxOrder .. "e",
            dependencies = { pfxCategory .. "introduction" },
            trigger = {
                type = "unlock-recipe",
                recipe = BPSB.pfx .. "electric-energy-interface",
            },
        },
        {
            type = "tips-and-tricks-item",
            category = category,
            name = pfxCategory .. "mining",
            indent = 1,
            order = pfxOrder .. "f",
            dependencies = { pfxCategory .. "introduction" },
            trigger = {
                type = "unlock-recipe",
                recipe = BPSB.pfx .. "electric-energy-interface",
            },
        },
    })
end

if mods["factorissimo-2-notnotmelon"] then
    category = BPSB.pfx .. "factorissimo"
    pfxCategory = category .. "-"
    data:extend({
        {
            type = "tips-and-tricks-item-category",
            name = category,
            order = pfxOrder .. "c",
        },
        {
            type = "tips-and-tricks-item",
            category = category,
            tag = "[img=item.factory-1] [img=item-group." .. BPSB.name .. "]",
            name = pfxCategory .. "introduction",
            order = pfxOrder .. "a",
            is_title = true,
            trigger = {
                type = "and",
                triggers = {
                    {
                        type = "unlock-recipe",
                        recipe = BPSB.pfx .. "electric-energy-interface",
                    }, {
                        type = "unlock-recipe",
                        recipe = "factory-1",
                    }
                },
            },
        },
    })
end
