-- PlanetsLib assigns the sand extraction recipe to ground diggers when they are built,
-- since the shared prototype cannot bake in a per-planet recipe. Diggers migrated from
-- the old "-sand-extractor" prototypes (see sand-extractor.json) never fire a build
-- event, so assign and lock their recipe here.
local RECIPE = "maraxsis-sand-extraction"
local DIGGER_NAMES = {
    "electric-mining-drill-ground-digger",
    "big-mining-drill-ground-digger",
}

for _, surface in pairs(game.surfaces) do
    for _, name in pairs(DIGGER_NAMES) do
        for _, digger in pairs(surface.find_entities_filtered {name = name}) do
            if digger.valid then
                local ok, err = pcall(function()
                    digger.set_recipe(RECIPE, "normal")
                    digger.recipe_locked = true
                end)
                if not ok then
                    log("maraxsis sand-extractor migration: " .. tostring(err))
                end
            end
        end
    end
end
