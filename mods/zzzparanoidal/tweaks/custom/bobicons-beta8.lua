-- Curated Beta 8 interface icons, after Reskins/OV and the pack's local overrides.
-- Never create prototypes or guess renamed IDs. Ground pictures and gameplay stay intact.
local entries = require("tweaks.custom.bobicons-beta8-data")

local function current_icon(prototype)
    if prototype.icons and next(prototype.icons) then
        local layers = table.deepcopy(prototype.icons)
        for _, layer in ipairs(layers) do
            layer.icon_size = layer.icon_size or prototype.icon_size or 64
            layer.icon_mipmaps = nil
        end
        return {icons = layers}
    end
    if prototype.icon then
        return {icon = prototype.icon, icon_size = prototype.icon_size or 64}
    end
    return {}
end

local function equal(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) == "number" then return math.abs(a - b) < 1e-12 end
    if type(a) ~= "table" then return a == b end
    for key, value in pairs(a) do
        if not equal(value, b[key]) then return false end
    end
    for key in pairs(b) do
        if a[key] == nil then return false end
    end
    return true
end

local applied, missing, changed = 0, 0, 0
for _, entry in ipairs(entries) do
    local prototypes = data.raw[entry.type]
    local prototype = prototypes and prototypes[entry.name]
    if not prototype then
        missing = missing + 1 -- An optional owner is not installed; do not resurrect it.
    elseif not equal(current_icon(prototype), entry.before) then
        changed = changed + 1 -- A newer owner/override needs a new review, not a blind overwrite.
        log("[bobicons-beta8] retained changed icon: " .. entry.type .. "/" .. entry.name)
    else
        prototype.icon = entry.after.icon
        prototype.icon_size = entry.after.icon_size
        prototype.icons = entry.after.icons and table.deepcopy(entry.after.icons) or nil
        prototype.icon_mipmaps = nil -- 1.1 metadata; the original PNG tiles remain unchanged.
        applied = applied + 1
    end
end
log(string.format("[bobicons-beta8] applied=%d missing=%d changed=%d", applied, missing, changed))
