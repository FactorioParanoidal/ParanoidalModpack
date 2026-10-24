-- An ore must look the same everywhere: as on the ground/belt (Beta 8 bobicons pictures) and in the
-- inventory. Composite icons of recipes, technologies, etc. still carried older ore art: the 2.0
-- bobores/Reskins files and the Reskins 1.1 snapshots baked into the Beta 8 menu patches
-- (refining-smelting-menu-beta8). Run after all icon/menu patches and repoint such layers.
-- Only layers are swapped: placement, tint, shift and the visual size are kept; gameplay untouched.
local entries = require("tweaks.custom.bobicons-beta8-data")
local ore_pictures = require("tweaks.custom.bobicons-beta8-ore-pictures-data")

-- Reskins 1.1 ore icons copied into the Beta 8 menu patches (matched pixel-for-pixel to the Beta 8 sources).
local menu_snapshots = {
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/8c5bda9289479be65450.png"] = "bob-quartz",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/3ba6e8df7069ce82cd3e.png"] = "bob-nickel-ore",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/41468bf35988aa262284.png"] = "tungsten-ore",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/4d4a3d340916930b4bf0.png"] = "bob-cobalt-ore",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/8a1895be03530e411644.png"] = "bob-lead-ore",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/8cea21de2c9ff1f1f8ec.png"] = "bob-zinc-ore",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/ba08c1386af301c822fc.png"] = "bob-tin-ore",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/c40f64a51b209bfb9934.png"] = "bob-bauxite-ore",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/ced4fe660ad05f6c497f.png"] = "bob-gold-ore",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/0d44a932f8cd4f6ccb0f.png"] = "bob-thorium-ore",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/18821b224320ff52f1ce.png"] = "bob-rutile-ore",
    ["__zzzparanoidal__/graphics/refining-smelting-menu-beta8/70ecddc333966186b528.png"] = "bob-silver-ore",
}

-- Target: the curated Beta 8 item icon of every ore that has Beta 8 ground pictures.
local targets, sources = {}, {}
for _, entry in ipairs(entries) do
    if entry.type == "item" and ore_pictures[entry.name] and entry.after.icon then
        targets[entry.name] = {icon = entry.after.icon, icon_size = entry.after.icon_size}
        local before = entry.before
        local old = before.icon and before or (before.icons and #before.icons == 1 and before.icons[1])
        if old then sources[old.icon] = entry.name end
        local short = entry.name:gsub("^bob%-", "")
        sources["__bobores__/graphics/icons/" .. short .. ".png"] = entry.name
    end
end
for file, name in pairs(menu_snapshots) do sources[file] = name end

local function target_for(file)
    local name = file and sources[file]
    return name and targets[name]
end

local remapped = 0
for _, prototypes in pairs(data.raw) do
    for _, prototype in pairs(prototypes) do
        if type(prototype) == "table" then
            if type(prototype.icons) == "table" then
                for _, layer in ipairs(prototype.icons) do
                    local target = type(layer) == "table" and target_for(layer.icon)
                    if target then
                        local old_size = layer.icon_size or 64
                        layer.icon = target.icon
                        layer.icon_size = target.icon_size
                        layer.icon_mipmaps = nil
                        -- Keep the visual size; an absent scale already means the same size for any icon_size.
                        if layer.scale then layer.scale = layer.scale * old_size / target.icon_size end
                        remapped = remapped + 1
                    end
                end
            elseif target_for(prototype.icon) then
                local target = target_for(prototype.icon)
                prototype.icon = target.icon
                prototype.icon_size = target.icon_size
                prototype.icon_mipmaps = nil
                remapped = remapped + 1
            end
        end
    end
end
log("[ore-icon-layers-beta8] remapped=" .. remapped)
