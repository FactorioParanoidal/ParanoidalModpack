-- Angels snapshots these categories in data-updates, before the Beta 8 modules
-- are restored. Repair only that stale whitelist; keep custom/empty filters and
-- unrestricted bio buildings unchanged. Do not enable Raw Productivity here.
local stale_categories = {
    productivity = true,
    speed = true,
    efficiency = true,
    ["pollution-clean"] = true,
    ["pollution-create"] = true,
    god = true,
}
local restored_categories = { "effectivity", "raw-speed", "green" }

for _, entity_type in ipairs({ "assembling-machine", "furnace", "mining-drill", "lab", "rocket-silo" }) do
    for _, entity in pairs(data.raw[entity_type] or {}) do
        local categories = entity.allowed_module_categories
        if categories and #categories == 6 then
            local seen = {}
            local stale = true
            for _, category in ipairs(categories) do
                if not stale_categories[category] or seen[category] then stale = false end
                seen[category] = true
            end
            if stale then
                local updated = table.deepcopy(categories)
                for _, category in ipairs(restored_categories) do
                    if data.raw["module-category"][category] then
                        updated[#updated + 1] = category
                    end
                end
                entity.allowed_module_categories = updated
            end
        end
    end
end

-- Final slot counts from Beta 8. These machines still define only the obsolete
-- module_specification field; Factorio 2.0 reads module_slots directly.
local slots = {
    ["assembling-machine-7"] = 7,
    ["assembling-machine-8"] = 8,
    ["assembling-machine-9"] = 9,
    ["electronics-machine-4"] = 7,
    ["electronics-machine-5"] = 8,
    ["alloy-mixer"] = 2,
    ["alloy-mixer-2"] = 2,
    ["alloy-mixer-3"] = 2,
    ["alloy-mixer-4"] = 2,
    ["bi-bio-reactor-2"] = 2,
    ["bi-bio-reactor-3"] = 3,
}
for name, count in pairs(slots) do
    local entity = data.raw["assembling-machine"][name]
    if entity and entity.module_slots == nil then
        entity.module_slots = count
    end
end
