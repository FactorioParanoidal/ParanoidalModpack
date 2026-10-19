-- Paranoidal: data-final-fixes part of factory building 4. Its ingredients are unlocked by these
-- technologies in the Paranoidal mod set; each is added as a prerequisite only when it exists.
--   angels-metallurgy-3        advanced structure components (added to the recipe by zzzparanoidal)
--   angels-titanium-smelting-1 titanium plates
--   bob-electric-substation-2  substation 2

local technology = data.raw.technology["factory-architecture-t4"]
if not technology then return end

local present = {}
for _, name in pairs(technology.prerequisites or {}) do present[name] = true end
technology.prerequisites = technology.prerequisites or {}
for _, name in pairs {"angels-metallurgy-3", "angels-titanium-smelting-1", "bob-electric-substation-2"} do
    if data.raw.technology[name] and not present[name] then
        table.insert(technology.prerequisites, name)
        present[name] = true
    end
end

-- The recipe picked steel and substations if Bob's items were not defined yet when it was created.
local recipe = data.raw.recipe["factory-4"]
local better = {
    ["steel-plate"] = {"bob-titanium-plate", 0.5},
    ["substation"] = {"bob-substation-2", 0.5},
}
for _, ingredient in pairs(recipe and recipe.ingredients or {}) do
    local replacement = better[ingredient.name]
    if replacement and data.raw.item[replacement[1]] then
        ingredient.name = replacement[1]
        ingredient.amount = math.floor(ingredient.amount * replacement[2])
    end
end
