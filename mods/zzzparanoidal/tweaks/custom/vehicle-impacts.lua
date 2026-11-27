-- Migrate only the legacy vehicle sounds and material pairs known in this build.
-- Do not remap whole materials: two walls made from stone can have different vehicle hits.
local impact_material = require("__paranoidal-sound__.prototypes.vehicle-impacts")
local function numbered(prefix, first, volume)
    local variations = {}
    for i = first, first + 4 do variations[#variations + 1] = {filename = prefix .. "-" .. i .. ".ogg", volume = volume} end
    return variations
end
local metal, stone = "__base__/sound/car-metal-impact", "__base__/sound/car-stone-impact"
local function single(prefix, volume) return {filename = prefix .. ".ogg", volume = volume} end
-- ID, accepted original materials, old descriptor, replacement variations (if different).
local profiles = {
    {"metal-65", {default=true, metal=true}, single(metal, 0.65), numbered(metal, 1, 0.65)},
    {"metal-100", {stone=true}, single(metal, 1), numbered(metal, 1, 1)},
    {"stone-100", {default=true}, single(stone, 1), numbered(stone, 1, 1)},
    {"quiet", {wood=true, glass=true, metal=true}, single("__base__/sound/silence-1sec")},
    {"metal-alt-50", {default=true}, numbered(metal, 2, 0.5)},
    {"metal-alt-65", {default=true}, numbered(metal, 2, 0.65)},
    {"wood-65", {default=true}, numbered("__base__/sound/car-wood-impact", 1, 0.65)},
    {"junk-50", {["metal-large"]=true}, numbered("__JunkTrain3__/sound/car-metal-impact", 2, 0.5)},
}
local categories = {}
for kind in pairs(defines.prototypes.entity) do
    for _, entity in pairs(data.raw[kind] or {}) do
        local legacy = entity.vehicle_impact_sound
        if type(legacy) == "table" then
            local material = entity.impact_category or "default"
            for _, p in ipairs(profiles) do
                if p[2][material] and table.compare(legacy, p[3]) then
                    local id = material .. "/" .. p[1]
                    local variations = p[4] or (legacy.filename and {legacy}) or legacy
                    categories[id] = categories[id] or impact_material(material, p[1], variations)
                    entity.impact_category = categories[id]
                    entity.vehicle_impact_sound = nil
                    break
                end
            end
        end
    end
end
