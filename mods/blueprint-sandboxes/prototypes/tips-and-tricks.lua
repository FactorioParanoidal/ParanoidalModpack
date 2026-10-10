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
        tag = "[img=shortcut." .. ToggleGUI.toggleShortcut .. "]",
        name = pfxCategory .. "introduction",
        order = pfxOrder .. "a",
        is_title = true,
        starting_status = "suggested",
        trigger = {
            type = "time-elapsed",
            ticks = 60 * 5 -- 5 seconds
        },
        image = BPSB.path .. "/graphics/sandbox.png",
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "isolation",
        indent = 1,
        order = pfxOrder .. "b",
        starting_status = "unlocked",
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "multiple-sandboxes",
        indent = 1,
        order = pfxOrder .. "c",
        starting_status = "unlocked",
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
        order = pfxOrder .. "d",
        starting_status = "unlocked",
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
        image = BPSB.path .. "/graphics/reset-sandbox.png",
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        tag = "[img=space-location/nauvis]",
        name = pfxCategory .. "surface-properties",
        indent = 1,
        order = pfxOrder .. "e",
        starting_status = "unlocked",
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
        image = BPSB.path .. "/graphics/surface-properties.png",
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "sandbox-force",
        indent = 1,
        order = pfxOrder .. "f",
        starting_status = "unlocked",
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "new-recipes-v2",
        indent = 1,
        order = pfxOrder .. "g",
        starting_status = "unlocked",
        trigger = {
            type = "unlock-recipe",
            recipe = BPSB.pfx .. "electric-energy-interface",
        },
    },
    {
        type = "tips-and-tricks-item",
        category = category,
        name = pfxCategory .. "god-mode",
        indent = 1,
        order = pfxOrder .. "h",
        starting_status = "unlocked",
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
        order = pfxOrder .. "i",
        starting_status = "unlocked",
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
})

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
            tag = "[img=item.factory-1] [img=shortcut." .. ToggleGUI.toggleShortcut .. "]",
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
