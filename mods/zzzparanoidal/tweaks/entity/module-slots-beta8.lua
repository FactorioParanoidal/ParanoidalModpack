-- Final Beta 8 slots for unambiguous surviving machines only.
-- Removed pumpjack/electrowinning tiers require a separate content decision.
local slots = {
    ["assembling-machine"] = {
        ["bi-bio-garden"] = 0,
        ["bi-bio-garden-large"] = 0,
        ["bi-bio-garden-huge"] = 0,
    },
    furnace = { ["bi-stone-crusher"] = 2 },
    ["mining-drill"] = {
        ["bob-area-mining-drill-1"] = 3,
        ["bob-area-mining-drill-2"] = 4,
        ["bob-area-mining-drill-3"] = 4,
        ["bob-area-mining-drill-4"] = 5,
    },
    lab = { ["burner-lab"] = 0 },
    ["rocket-silo"] = { ["rocket-silo"] = 6 },
}
for entity_type, names in pairs(slots) do
    for name, count in pairs(names) do
        local entity = (data.raw[entity_type] or {})[name]
        if entity then entity.module_slots = count end
    end
end
-- Resource-specific clones inherit the same reference slots, not a new tier.
for name, entity in pairs(data.raw["mining-drill"] or {}) do
    local base = name:match("^(.-)___")
    if base and slots["mining-drill"][base] then
        entity.module_slots = slots["mining-drill"][base]
    end
end
