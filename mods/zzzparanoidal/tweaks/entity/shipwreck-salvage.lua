local salvage = require("shipwreck-salvage-definitions")

for _, entity_type in ipairs({"simple-entity", "simple-entity-with-owner", "container"}) do
    for name in pairs(salvage.names) do
        local wreck = (data.raw[entity_type] or {})[name]
        if wreck and wreck.minable then
            wreck.minable.mining_time = salvage.mining_time

            local boards = salvage.boards[name]
            if mods.LootingSpaceshipWrecks and boards and data.raw.item["bob-basic-circuit-board"] then
                local results = wreck.minable.results
                local index = #results + 1
                for i, product in ipairs(results) do
                    if product.name == "offshore-mk0-pump" then index = i; break end
                end
                table.insert(results, index, {
                    type = "item", name = "bob-basic-circuit-board",
                    amount_min = boards[1], amount_max = boards[2],
                })
            end

            -- Keep the six visible twins from LootingSpaceshipWrecks 2.0.4 for existing saves.
            -- New wrecks use the same temporary mining targets as the larger ship parts.
            if entity_type == "simple-entity-with-owner"
                and name:match("^crash%-site%-spaceship%-wreck%-small%-%d+$") then
                local twin = table.deepcopy(wreck)
                twin.type = "simple-entity"
                twin.name = name .. "-salvage"
                twin.localised_name = twin.localised_name or {"entity-name.crash-site-spaceship-wreck-small"}
                data:extend({twin})
            end

            if entity_type ~= "simple-entity" then
                -- The original keeps its graphics and inventory while this invisible target
                -- gives the character the simple-entity pickaxe animation during mining.
                data:extend({{
                    type = "simple-entity",
                    name = salvage.target_prefix .. name,
                    localised_name = wreck.localised_name or {"entity-name." .. name},
                    icon = wreck.icon,
                    icons = table.deepcopy(wreck.icons),
                    icon_size = wreck.icon_size,
                    flags = {"placeable-neutral", "placeable-off-grid", "not-on-map",
                        "not-blueprintable", "not-deconstructable", "not-in-kill-statistics"},
                    hidden_in_factoriopedia = true,
                    max_health = wreck.max_health,
                    collision_box = table.deepcopy(wreck.collision_box),
                    collision_mask = {layers = {}},
                    selection_box = table.deepcopy(wreck.selection_box),
                    selection_priority = 255,
                    minable = {mining_time = salvage.mining_time},
                    picture = {filename = "__core__/graphics/empty.png", width = 1, height = 1},
                }})
            end
        end
    end
end
