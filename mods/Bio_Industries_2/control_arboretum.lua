------------------------------------------------------------------------------------
-- Terraformer (arboretum): every sector scan of its hidden radar plants a seedling
-- and/or fertilizes a random tile within plant_radius, using one set of ingredients.
-- The machine itself never finishes a craft (crafting speed ~0); the script consumes
-- the ingredients from its input inventory.
------------------------------------------------------------------------------------
local M = {}

local trees = require("control_tree")
local fertility = trees.fertility

-- If a recipe with NORMAL FERTILIZER is used, don't fertilize tiles set have "true"
-- set! (Fertile tiles set to true in this table can't be made more fertile with
-- normal fertilizer, and nothing should grow on the other tiles.)
local Terrain_Check_1 = {
    ["grass-1"] = true,                  -- Fertility: 100%
    ["grass-3"] = true,                  -- Fertility: 85%
    ["vegetation-green-grass-1"] = true, -- Fertility: 100%
    ["vegetation-green-grass-3"] = true, -- Fertility: 85%
}

-- If a recipe with ADVANCED FERTILIZER is used, don't fertilize tiles set have "true" set!
-- (Fertile tiles in this table can't be made more fertile, and nothing should grow on the
--  the others tiles!)
local Terrain_Check_2 = {
    ["grass-1"] = true,                  -- Fertility: 100%
    ["vegetation-green-grass-1"] = true, -- Fertility: 100%
}

local plant_radius = 75

-- Different tiles are used if Alien Biomes is active
local AB = BioInd.AB_tiles()
local terrain_name_g1 = AB and "vegetation-green-grass-1" or "grass-1"
local terrain_name_g3 = AB and "vegetation-green-grass-3" or "grass-3"

-- Ingredients of the terraformer recipes, read from the prototypes as other mods may
-- have changed them: recipe name -> {items = {name = amount}, fluids = {name = amount}}
local recipes
function M.get_recipes()
    if not recipes then
        recipes = {}
        for i = 1, 5 do
            local name = "bi-arboretum-r" .. i
            local recipe = prototypes.recipe[name]
            if recipe then
                local need = { items = {}, fluids = {} }
                for _, ingredient in pairs(recipe.ingredients) do
                    if ingredient.type == "item" then
                        need.items[ingredient.name] = ingredient.amount
                    else
                        need.fluids[ingredient.name] = ingredient.amount
                    end
                end
                recipes[name] = need
            end
        end
    end
    return recipes
end


-- Are all ingredients available? Items count only in the quality of the selected
-- recipe, as the machine itself would use them.
local function check_ingredients(arboretum)
    local recipe, quality = arboretum.get_recipe()
    if not recipe then
        return
    end
    local need = M.get_recipes()[recipe.name]
    if not need then
        return
    end
    local inventory = arboretum.get_inventory(defines.inventory.assembling_machine_input)
    if not inventory then
        return
    end

    local quality_name = quality and quality.name or "normal"
    for item, amount in pairs(need.items) do
        if inventory.get_item_count({ name = item, quality = quality_name }) < amount then
            return
        end
    end
    if next(need.fluids) then
        local fluids = arboretum.get_fluid_contents()
        for fluid, amount in pairs(need.fluids) do
            if (fluids[fluid] or 0) < amount then
                return
            end
        end
    end
    return need, recipe.name, inventory, quality_name
end

local function consume_ingredients(arboretum, inventory, need, quality)
    for item, amount in pairs(need.items) do
        inventory.remove({ name = item, count = amount, quality = quality })
    end
    for fluid, amount in pairs(need.fluids) do
        arboretum.remove_fluid({ name = fluid, amount = amount })
    end
end

-- Fertilizer is not wasted on ground that is already fertile enough.
local function refund(inventory, need, item, quality)
    local amount = need.items[item]
    if amount then
        inventory.insert({ name = item, count = amount, quality = quality })
    end
end

local function get_new_position(pos)
    local xxx = math.random(-plant_radius, plant_radius)
    local yyy = math.random(-plant_radius, plant_radius)
    return { x = pos.x + xxx, y = pos.y + yyy }
end

local function set_tile(current, target, surface, position)
    if current ~= target then
        surface.set_tiles(
            { { name = target, position = position } },
            true, -- correct_tiles
            true, -- remove_colliding_entities
            true, -- remove_colliding_decoratives
            true  -- raise_event
        )
    end
end

local function plant_seedling(surface, plant, tick)
    local seedling = surface.create_entity(plant)
    if seedling then
        trees.seed_planted_arboretum(seedling, tick)
    end
end


------------------------------------------------------------------------------------
-- entry: the terraformer's entry in storage.bi_arboretum_table
function M.process(entry, tick)
    local arboretum = entry.base
    if not (arboretum and arboretum.valid) then
        return
    end
    local need, recipe_name, inventory, quality = check_ingredients(arboretum)
    if not need then
        return
    end

    local pos = arboretum.position
    local surface = arboretum.surface
    local new_position, current, plant

    -- Just plant a tree and hope the ground is fertile!
    if recipe_name == "bi-arboretum-r1" then
        --- 10 attempts to find a random spot to plant a tree
        for k = 1, 10 do
            new_position = get_new_position(pos)
            plant = { name = "seedling", position = new_position, force = "neutral" }
            if surface.can_place_entity(plant) then
                consume_ingredients(arboretum, inventory, need, quality)
                plant_seedling(surface, plant, tick)
                break
            end
        end

        -- Fertilize the ground with normal fertilizer. Ignore tiles listed in Terrain_Check_1!
    elseif recipe_name == "bi-arboretum-r2" then
        for k = 1, 10 do
            new_position = get_new_position(pos)
            current = surface.get_tile(new_position.x, new_position.y).name
            if fertility[current] and not Terrain_Check_1[current] then
                consume_ingredients(arboretum, inventory, need, quality)
                set_tile(current, terrain_name_g3, surface, new_position)
                break
            end
        end

        -- Fertilize the ground with advanced fertilizer. Ignore tiles listed in Terrain_Check_2!
    elseif recipe_name == "bi-arboretum-r3" then
        for k = 1, 10 do
            new_position = get_new_position(pos)
            current = surface.get_tile(new_position.x, new_position.y).name
            if fertility[current] and current ~= terrain_name_g1 then
                consume_ingredients(arboretum, inventory, need, quality)
                set_tile(current, terrain_name_g1, surface, new_position)
                break
            end
        end

        -- Fertilize the ground with normal fertilizer and plant a tree.
    elseif recipe_name == "bi-arboretum-r4" then
        for k = 1, 10 do
            new_position = get_new_position(pos)
            current = surface.get_tile(new_position.x, new_position.y).name
            plant = { name = "seedling", position = new_position, force = "neutral" }
            if surface.can_place_entity(plant) and fertility[current] then
                consume_ingredients(arboretum, inventory, need, quality)
                if Terrain_Check_1[current] then
                    refund(inventory, need, "fertilizer", quality)
                end
                set_tile(current, terrain_name_g3, surface, new_position)
                plant_seedling(surface, plant, tick)
                break
            end
        end

        -- Fertilize the ground with advanced fertilizer and plant a tree.
    elseif recipe_name == "bi-arboretum-r5" then
        for k = 1, 10 do
            new_position = get_new_position(pos)
            current = surface.get_tile(new_position.x, new_position.y).name
            plant = { name = "seedling", position = new_position, force = "neutral" }
            if surface.can_place_entity(plant) and fertility[current] then
                consume_ingredients(arboretum, inventory, need, quality)
                if Terrain_Check_2[current] then
                    refund(inventory, need, "bi-adv-fertilizer", quality)
                end
                set_tile(current, terrain_name_g1, surface, new_position)
                plant_seedling(surface, plant, tick)
                break
            end
        end
    end
end


------------------------------------------------------------------------------------
-- The hidden radar of a terraformer has scanned a sector
function M.on_sector_scanned(event)
    local radar = event.radar
    if not (radar and radar.valid) then
        return
    end
    local map = storage.bi_arboretum_radar_table
    local base_id = map and map[radar.unit_number]
    local tab = base_id and storage.bi_arboretum_table
    local entry = tab and tab[base_id]
    if entry then
        M.process(entry, event.tick)
    end
end

return M
