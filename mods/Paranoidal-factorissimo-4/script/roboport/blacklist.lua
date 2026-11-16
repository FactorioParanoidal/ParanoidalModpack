require("util")

local blacklisted_names = {}

local blacklisted_types = util.list_to_map {
    "legacy-curved-rail",
    "legacy-straight-rail",

    "straight-rail",
    "curved-rail-a",
    "curved-rail-b",
    "half-diagonal-rail",

    "rail-ramp",
    "rail-support",
    "elevated-straight-rail",
    "elevated-curved-rail-a",
    "elevated-curved-rail-b",
    "elevated-half-diagonal-rail",

    "car",
    "spider-vehicle",
    "locomotive",
    "cargo-wagon",
    "fluid-wagon",
    "artillery-wagon",
}

for _, entity in pairs(prototypes.entity) do
    if blacklisted_types[entity.type] then
        blacklisted_names[entity.name] = true
    end
end

return blacklisted_names
