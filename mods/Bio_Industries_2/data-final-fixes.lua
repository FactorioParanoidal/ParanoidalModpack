local BioInd = require('common')('Bio_Industries_2')
local ICONPATH = "__Bio_Industries_2__/graphics/icons/"

-- If OwnlyMe's or Tral'a "Robot Tree Farm" mods are active, they will create variatons
-- of our variations of tree prototypes. Remove them!
local ignore_trees = BioInd.get_tree_ignore_list()
local removed = 0

for name, _ in pairs(ignore_trees or {}) do
    if name:match("rtf%-bio%-tree%-.+%-%d-%d+") then
        data.raw.tree[name] = nil
        ignore_trees[name] = nil
        removed = removed + 1
        BioInd.show("Removed tree prototype", name)
    end
end
BioInd.writeDebug("Removed %g tree prototypes. Number of trees to ignore now: %g", { removed, table_size(ignore_trees) })

BI.Settings.BI_Game_Tweaks_Emissions_Multiplier = settings.startup["BI_Game_Tweaks_Emissions_Multiplier"].value

---- Game Tweaks ---- Tree
if BI.Settings.BI_Game_Tweaks_Tree then
    local new_results = {
        {
            type = "item",
            name = "wood",
            amount_min = 1,
            amount_max = 6
        }
    }

    for tree_name, tree in pairs(data.raw["tree"] or {}) do
        if tree.minable and not ignore_trees[tree_name] then
            BioInd.writeDebug("Tree name: %s\tminable.result: %s\tminable.count: %s",
                { tree.name, (tree.minable and tree.minable.result or "nil"), (tree.minable and tree.minable.count or "nil") },
                "line")
            BioInd.writeDebug("Tree name: %s\tminable.results: %s",
                { tree.name, (tree.minable and tree.minable.results or "nil") }, "line")
            --CHECK FOR SINGLE RESULTS
            -- mining.result may be set although mining.results exists (mining.result
            -- will be ignored in that case; happens, for example with IR2's rubber
            -- trees). In this case, overwriting mining.results with the data from
            -- mining.result could break other mods (e.g. IR2's rubber trees should
            -- yield "rubber-wood" instead of "wood").
            if tree.minable.result and not tree.minable.results then
                BioInd.writeDebug("Tree has minable.result")
                --CHECK FOR VANILLA TREES WOOD x 4
                if tree.minable.result == "wood" and tree.minable.count == 4 then
                    BioInd.writeDebug("Changing wood yield of %s to random value.", { tree.name })
                    tree.minable.mining_particle = "wooden-particle"
                    tree.minable.mining_time = 1.5
                    tree.minable.results = new_results
                    -- CONVERT RESULT TO RESULTS
                else
                    BioInd.writeDebug("Converting tree.minable.result to tree.minable.results!")
                    tree.minable.mining_particle = "wooden-particle"
                    tree.minable.results = {
                        {
                            type = "item",
                            name = tree.minable.result,
                            amount = tree.minable.count,
                        }
                    }
                end
                --CHECK FOR RESULTS TABLE
            elseif tree.minable.results then
                BioInd.writeDebug("Checking minable.results!")
                for r, result in pairs(tree.minable.results) do
                    --CHECK FOR RESULT WOOD x 4
                    if result.name == "wood" and result.amount == 4 then
                        BioInd.writeDebug("Changing result %s: %s", { r, result }, "line")
                        result.amount = nil
                        result.amount_min = 1
                        result.amount_max = 6
                    end
                end
                tree.minable.result = nil
                tree.minable.count = nil
                -- NEITHER RESULT NOR RESULTS EXIST -- CREATE RESULTS!
            else
                BioInd.writeDebug("Creating minable.results!")
                tree.minable.results = new_results
            end
            BioInd.writeDebug("New minable.results: %s",
                { tree.minable and tree.minable.results or "nil" }, "line")
        else
            BioInd.writeDebug("Won't change results of %s!", { tree.name })
        end
    end
end


---- Game Tweaks ---- Player (Changed for 0.18.34/1.1.4!)
if BI.Settings.BI_Game_Tweaks_Player then
    -- There may be more than one character in the game! Here's a list of
    -- the character prototype names or patterns matching character prototype
    -- names we want to ignore.
    local blacklist = {
        ------------------------------------------------------------------------------------
        --                                  Known dummies                                 --
        ------------------------------------------------------------------------------------
        -- Autodrive
        "autodrive-passenger",
        -- AAI Programmable Vehicles
        "^.+%-_%-driver$",
        -- Minime
        "minime_character_dummy",
        -- Water Turret (currently the dummies are not characters -- but things may change!)
        "^WT%-.+%-dummy$",
        ------------------------------------------------------------------------------------
        --                                Other characters                                --
        ------------------------------------------------------------------------------------
        -- Bob's Classes and Multiple characters mod
        "^.*bob%-character%-.+$",
    }

    local whitelist = {
        -- Default character
        "^character$",
        -- Characters compatible with Minime
        "^.*skin.*$",
    }

    local tweaks = {
        loot_pickup_distance    = 5,  -- default 2
        build_distance          = 20, -- Vanilla 6
        drop_item_distance      = 20, -- Vanilla 6
        reach_distance          = 20, -- Vanilla 6
        item_pickup_distance    = 6,  -- Vanilla 1
        reach_resource_distance = 6,  -- Vanilla 2.7
    }

    local found, ignore
    for char_name, character in pairs(data.raw.character) do
        BioInd.show("Checking character", char_name)
        found = false

        for w, w_pattern in ipairs(whitelist) do
            if char_name == w_pattern or char_name:match(w_pattern) then
                ignore = false
                BioInd.show("Found whitelisted character name", char_name)
                for b, b_pattern in ipairs(blacklist) do
                    if char_name == b_pattern or char_name:match(b_pattern) then
                        BioInd.writeDebug("%s is on the ignore list!", char_name)
                        -- Mark character as found
                        ignore = true
                        break
                    end
                end
                if not ignore then
                    found = true
                    break
                end
            end
            if found then
                break
            end
        end

        -- Apply tweaks
        if found then
            for tweak_name, tweak in pairs(tweaks) do
                if character[tweak_name] < tweak then
                    BioInd.writeDebug("Changing %s from %s to %s", { tweak_name, character[tweak_name], tweak })
                    character[tweak_name] = tweak
                end
            end
        end
    end
end



---- Game Tweaks ---- Production science pack recipe
if data.raw.recipe["bi-production-science-pack"] then
    BI_Functions.lib.allow_productivity("bi-production-science-pack")
    thxbob.lib.tech.add_recipe_unlock("production-science-pack", "bi-production-science-pack")
    BioInd.writeDebug("Unlock for recipe \"bi-production-science-pack\" added.")
end

---- Game Tweaks ---- Bots
if BI.Settings.BI_Game_Tweaks_Bot then
    -- Logistic & Construction bots can't catch fire or be mined
    local function immunify(bot)
        local can_insert = true
        bot.flags = bot.flags or {}
        bot.resistances = bot.resistances or {}
        for f, flag in pairs(bot.flags) do
            if flag == "not-flammable" then
                can_insert = false
                break
            end
        end
        if can_insert then
            table.insert(bot.flags, "not-flammable")
            BioInd.writeDebug("Added flag \"not-flammable\" to %s", { bot.name })
        end

        can_insert = true
        for r, resistance in pairs(bot.resistances) do
            if resistance.type == "fire" and resistance.percent ~= 100 then
                BioInd.writeDebug("Change resistance against \"fire\" from %s to 100 %% for %s",
                    { resistance.percent or "nil", bot.name })
                bot.resistances[r] = { type = "fire", percent = 100 }
                can_insert = false
                break
            end
        end
        if can_insert then
            table.insert(bot.resistances, { type = "fire", percent = 100 })
            BioInd.writeDebug("Added resistance against  \"fire\" to %s", { bot.name })
        end

        bot.minable = nil
        BioInd.writeDebug("Made  %s unminable", { bot.name })
    end

    --catches modded bots too
    for _, bot in pairs(data.raw['construction-robot']) do
        immunify(bot)
    end

    for _, bot in pairs(data.raw['logistic-robot']) do
        immunify(bot)
    end
end


---- Game Tweaks stack size ----
if BI.Settings.BI_Game_Tweaks_Stack_Size then
    -- Changed for 0.18.34/1.1.4
    local tweaks = {
        ["wood"]          = { value = 400, se_limit = 200 },
        ["stone"]         = { value = 400, se_limit = 50 },
        ["stone-crushed"] = { value = 800, se_limit = 200 },
        ["concrete"]      = { value = 400, se_limit = 200 },
        ["slag"]          = { value = 800, se_limit = 200 },
    }
    local item
    local five_dim = BioInd.get_startup_setting("5d-change-stack")

    for tweak_name, tweak in pairs(tweaks) do
        item = data.raw.item[tweak_name]
        if item then
            -- Only adjust stack_size if 5Dim sets multiplier of 1 or is not active!
            if item.stack_size < tweak.value and (five_dim == 1 or not five_dim) then
                BioInd.writeDebug("Changing stacksize of %s from %s to %s",
                    { item.name, item.stack_size, tweak.value })
                item.stack_size = tweak.value
            end
            if mods["space-exploration"] then
                item.stack_size = math.min(tweak.se_limit, item.stack_size)
                BioInd.show("Adjusted stack_size on account of SE", item.stack_size)
            end
        end
    end
end


--- Update fuel_emissions_multiplier values
if BI.Settings.BI_Game_Tweaks_Emissions_Multiplier then
    for item, factor in pairs({
        ["pellet-coke"] = 0.80,
        ["enriched-fuel"] = 0.90,
        ["solid-fuel"] = 1.00,
        ["solid-carbon"] = 1.05,
        ["carbon"] = 1.05,
		["bob-carbon"] = 1.05,
        ["wood-bricks"] = 1.10,
        ["rocket-fuel"] = 1.20,
        ["bi-seed"] = 1.30,
		["tree-seed"] = 1.30,
        ["seedling"] = 1.30,
        ["bi-wooden-pole-big"] = 1.30,
        ["bi-wooden-pole-huge"] = 1.30,
        ["bi-wooden-fence"] = 1.30,
        ["bi-wood-pipe"] = 1.30,
        ["bi-wood-pipe-to-ground"] = 1.30,
        ["bi-wooden-chest-large"] = 1.30,
        ["bi-wooden-chest-huge"] = 1.30,
        ["bi-wooden-chest-giga"] = 1.30,
        ["bi-ash"] = 1.30,
        ["ash"] = 1.30,
        ["wood-charcoal"] = 1.25,
        ["cellulose-fiber"] = 1.40,
        ["bi-woodpulp"] = 1.40,
        ["solid-coke"] = 1.40,
        ["wood-pellets"] = 1.40,
        ["coal-crushed"] = 1.50,
        ["wood"] = 1.60,
        ["coal"] = 2.00,
    }) do
        BI_Functions.lib.fuel_emissions_multiplier_update(item, factor)
    end
end




-- Make vanilla and Bio boilers exchangeable
if BI.Settings.BI_Bio_Fuel then
    local boiler = data.raw["boiler"]["boiler"]
    local boiler_group = boiler.fast_replaceable_group or "boiler"

    boiler.fast_replaceable_group = boiler_group
    data.raw["boiler"]["bi-bio-boiler"].fast_replaceable_group = boiler_group
end




if mods["Krastorio2"] or mods["Krastorio2-spaced-out"] then
    -- Krastorio² needs much more wood than usually provided by Bio Industries. If Krastorio² is
    -- active, BI should produce much more wood/wood pulp. For better baĺancing, our recipes should
    -- also be changed to require more wood/wood pulp as ingredients.
    -- Recipes for making wood should also use/produce more seeds, seedlings, and water. It shouldn't
    -- be necessary to increase the input of ash and fertilizer in these recipes as they already
    -- require more wood/wood pulp.
    local update = {
        "wood", "bi-woodpulp",
        "bi-seed", "tree-seed","seedling", "water"
    }
    local multiply = function(items)
        for _, item in pairs(items) do
            for _, updateItem in pairs(update) do
                if item.name == updateItem then
                    if item.amount then
                        item.amount = item.amount * 4
                    end
                    if item.amount_min then
                        item.amount_min = item.amount_min * 4
                    end
                    if item.amount_max then
                        item.amount_max = item.amount_max * 4
                    end
                end
            end
        end
    end
    for _, recipe in pairs(data.raw.recipe) do
        BioInd.writeDebug("Recipe has \"mod\" property: %s", { recipe.mod and true or false })
        if recipe.mod == "Bio_Industries_2" then
            multiply(recipe.ingredients)
            multiply(recipe.results)
            BioInd.writeDebug("Changed ingredients for %s: %s",
                { recipe and recipe.name or "nil", recipe and recipe.ingredients or "nil" })
            BioInd.writeDebug("Changed results for %s: %s",
                { recipe and recipe.name or "nil", recipe and recipe.results or "nil" })
        end
    end
end




-- Make sure fertilizers have the "place_as_tile" property!
local AlienBiomes = data.raw.tile["vegetation-green-grass-3"] and
    data.raw.tile["vegetation-green-grass-1"] and true or false

-- We've already set place_as_tile. If it doesn't exist, our fertilizer definition has
-- been overwritten by some other mod, so we restore icons and localization and add
-- place_as_tile again!
local fertilizer = data.raw.item["fertilizer"]
if not fertilizer.place_as_tile then
    fertilizer.place_as_tile = {
        result = AlienBiomes and "vegetation-green-grass-3" or "grass-3",
        condition_size = 1,
        condition = { layers = { water_tile = true } }
    }
    fertilizer.icon = ICONPATH .. "fertilizer.png"
    fertilizer.icon_size = 64
    fertilizer.icons = {
        {
            icon = ICONPATH .. "fertilizer.png",
            icon_size = 64,
        }
    }
    fertilizer.localised_name = { "BI-item-name.fertilizer" }
    fertilizer.localised_description = { "BI-item-description.fertilizer" }
end

data.raw.item["bi-adv-fertilizer"].place_as_tile = {
    result = AlienBiomes and "vegetation-green-grass-1" or "grass-1",
    condition_size = 1,
    condition = { layers = { water_tile = true } }
}

if mods["pycoalprocessing"] and BI.Settings.BI_Bio_Fuel then
    -- Bio_Fuel/recipe.lua:30:      {type = "item", name = "bi-ash", amount = 15}
    thxbob.lib.recipe.remove_result("bi-basic-gas-processing", "bi-ash")
    thxbob.lib.recipe.add_result("bi-basic-gas-processing", {
        type = "item",
        name = "ash",
        amount = 15
    })
end


--- If Space Exploration Mod is installed.
if mods["space-exploration"] then
    -- Space Exploration Mod likes Stack Sizes to be 200 max.
    -- Changed in 1.1.11
    local tweaks = {
        ["bi-solar-mat"]  = 400,
        ["bi-seed"]       = 800,
		["tree-seed"]     = 800,
        ["seedling"]      = 400,
        ["bi-woodpulp"]   = 800,
        ["bi-ash"]        = 400,
        ["wood-charcoal"] = 400,
        ["pellet-coke"]   = 400,
        ["stone-crushed"] = 400,
    }
    local item

    for tweak_name, tweak in pairs(tweaks) do
        item = data.raw.item[tweak_name]
        if item and item.stack_size then
            item.stack_size = 200
        end
    end

    if not mods["Natural_Evolution_Buildings"] then
        local ammo_tweaks = {
            ["bi-dart-magazine-basic"]    = 400,
            ["bi-dart-magazine-standard"] = 400,
            ["bi-dart-magazine-enhanced"] = 400,
            ["bi-dart-magazine-poison"]   = 400,
        }
        local item

        for tweak_name, tweak in pairs(ammo_tweaks) do
            item = data.raw.ammo[tweak_name]
            item.stack_size = 200
        end
    end
end

if BI.Settings.Bio_Cannon then
    local default_target_masks = data.raw["utility-constants"].default.default_trigger_target_mask_by_type
    default_target_masks["unit-spawner"] = default_target_masks["unit-spawner"] or
        { "common" } -- everything should have "common", unless there is specific reason not to
    table.insert(default_target_masks["unit-spawner"], "Bio_Cannon_Ammo")

    for w, worm in pairs(data.raw.turret) do
        worm.trigger_target_mask = worm.trigger_target_mask or default_target_masks["turret"] or { "common" }
        table.insert(worm.trigger_target_mask, "Bio_Cannon_Ammo")
    end
end

------------------------------------------------------------------------------------
-- Add icons to our prototypes
BioInd.BI_add_icons()


---TESTING!


for k, v in pairs(data.raw) do
    for t, p in pairs(v) do
        if p.se_allow_in_space then
            BioInd.writeDebug("%s (%s) can be built in space!", { p.name, t })
        end
    end
end
