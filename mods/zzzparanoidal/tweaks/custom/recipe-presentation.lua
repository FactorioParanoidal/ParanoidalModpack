-- Explicit exceptions approved from the crafting-menu screenshots.
-- Run after menu artwork, before recipe -> item sync. Keep process overlays.
local function match_product(recipe_name, item_name, keep_overlays, match_name)
    local recipe = data.raw.recipe[recipe_name]
    local item = data.raw.item[item_name]
    if not recipe or not item then return end

    local layers
    if item.icons then
        layers = table.deepcopy(item.icons)
    elseif item.icon then
        layers = {{icon = item.icon, icon_size = item.icon_size or 64}}
    else
        return
    end
    -- These explicit recipes use layer 1 for the product; the rest identify the process.
    if keep_overlays then
        for i = 2, #(recipe.icons or {}) do
            layers[#layers + 1] = table.deepcopy(recipe.icons[i])
        end
    end
    recipe.icons = layers
    recipe.icon = nil
    recipe.icon_size = nil
    recipe.icon_mipmaps = nil
    if match_name then
        recipe.localised_name = table.deepcopy(item.localised_name or {"item-name." .. item_name})
    end
end

local raw_brick = data.raw.item["angels-clay-brick-raw"]
if raw_brick then
    raw_brick.icon = "__zzzparanoidal__/graphics/recipe-presentation/clay-brick-raw.png"
    raw_brick.icon_size = 64
    raw_brick.icons = nil
    raw_brick.icon_mipmaps = nil
end
match_product("angels-clay-brick-raw", "angels-clay-brick-raw")
-- For the turret the approved crafting-menu artwork is authoritative, not the old item.
local turret = data.raw.item["bi-dart-turret"]
if turret then
    turret.icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/dart_turret.png"
    turret.icon_size = 64
    turret.icons = nil
    turret.icon_mipmaps = nil
end
match_product("bi-dart-turret", "bi-dart-turret")

for _, name in ipairs({"quartz-glass", "glass-from-ore4", "angels-plate-glass",
    "angels-plate-glass-2", "angels-plate-glass-3"}) do
    match_product(name, "bob-glass", true)
end
for _, name in ipairs({"bob-titanium-electrolysis-x", "angels-plate-titanium", "angels-plate-titanium-2"}) do
    match_product(name, "bob-titanium-plate", true, true)
end
for _, name in ipairs({"angels-steel-gear-wheel-casting", "ASE-steel-gear-casting-expendable",
    "ASE-steel-gear-casting-advanced"}) do
    match_product(name, "bob-steel-gear-wheel", true)
    local recipe = data.raw.recipe[name]
    if recipe then recipe.localised_name = {"recipe-name." .. name} end
end
