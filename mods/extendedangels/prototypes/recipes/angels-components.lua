if mods["angelsindustries"] then
    if angelsmods.industries.components then
        -- Final fixes of angels to squeeze in a new construction tier material
        local OV = angelsmods.functions.OV

        -- Set local table for use in multiple functions
        local building_prototypes = {
            "assembling-machine",
            "mining-drill",
            "lab",
            "furnace",
            "offshore-pump",
            "pump",
            "rocket-silo",
            "radar",
            "beacon",
            "boiler",
            "generator",
            "solar-panel",
            "accumulator",
            "reactor",
            "electric-pole",
            "wall",
            "gate"
        }

        local block_ingredients = {
            ["block-construction-0"] = { new = "stone", old = "stone" },
            ["block-construction-1"] = { new = "stone-brick", old = "stone" },
            ["block-construction-2"] = { new = "clay-brick", old = "stone-brick" },
            ["block-construction-3"] = { new = "concrete-brick", old = "clay-brick" },
            ["block-construction-4"] = { new = "reinforced-concrete-brick", old = "concrete-brick" },
            ["block-construction-5"] = { new = "titanium-concrete-brick", old = "reinforced-concrete-brick" }
        }

        -- Add a 0th tier construction block
        data:extend({
            {
                type = "item",
                name = "block-construction-0", -- required at start
                icon = "__angelsindustries__/graphics/icons/block-construction-1.png",
                icon_size = 32,
                subgroup = "blocks-frames",
                order = "a",
                stack_size = 200,
            },

            {
                type = "recipe",
                name = "block-construction-0",
                enabled = true,
                category = "crafting",
                energy_required = 5,
                ingredients = {
                    { type = "item", name = "construction-frame-1", amount = 1 },
                    { type = "item", name = "stone",                amount = 3 },
                },
                results = {
                    { type = "item", name = "block-construction-0", amount = 1 },
                },
            },
        })

        -- Replace ingredients
        local function change_construction_block_ingredients()
            for block, list in pairs(block_ingredients) do
                local ingredients = data.raw.recipe[block].ingredients

                if not ingredients then
                    ingredients = data.raw.recipe[block].normal.ingredients
                end

                for n, _ in pairs(ingredients) do
                    if ingredients[n].name == list.old then
                        ingredients[n].name = list.new
                    end
                end

                -- For Logging
                -- log(serpent.block(ingredients))
            end
        end

        -- Shifts the construction block ingredients down one tier
        local shift_block_ingredients = function(ingredients)
            for n, _ in pairs(ingredients) do
                if ingredients[n].name == "block-construction-1" then
                    ingredients[n].name = "block-construction-0"
                end

                if ingredients[n].name == "block-construction-2" then
                    ingredients[n].name = "block-construction-1"
                end

                if ingredients[n].name == "block-construction-3" then
                    ingredients[n].name = "block-construction-2"
                end

                if ingredients[n].name == "block-construction-4" then
                    ingredients[n].name = "block-construction-3"
                end

                if ingredients[n].name == "block-construction-5" then
                    ingredients[n].name = "block-construction-4"
                end

                if ingredients[n].name == "titanium-concrete-brick" then
                    ingredients[n].name = "block-construction-5"
                end
            end
        end

        -- ADD BUILDING BLOCKS TO BUILDINGS
        function extangels.replace_construction_materials()
            for _, prototype in pairs(building_prototypes) do
                extangels.shuffle_construction_materials(prototype)
            end
        end

        -- REPLACE CONSTRUCTION BLOCKS
        function extangels.shuffle_construction_materials(prototype)
            for name, _ in pairs(data.raw[prototype]) do
                if data.raw.recipe[name] then
                    local recipe = data.raw.recipe[name]

                    if recipe.normal then
                        local ingredients = recipe.normal.ingredients
                        shift_block_ingredients(ingredients)

                        local expensive_ingredients = recipe.expensive.ingredients
                        shift_block_ingredients(expensive_ingredients)
                    else
                        local ingredients = recipe.ingredients
                        shift_block_ingredients(ingredients)
                    end
                end
            end
            change_construction_block_ingredients()
        end
    end
end
