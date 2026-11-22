if not mods["power-grid-comb"] then return end

local tool = data.raw["selection-tool"]["power-grid-comb"]
if not tool then return end

local excluded = {
    ["factory-circuit-connector"] = true,
    ["factory-circuit-connector-invisible"] = true,
    ["factory-power-pole"] = true,
    ["factory-distribution-power-pole"] = true,
    ["factory-global-electric-network-pole"] = true,
}

local function protect_factory_poles(mode)
    if not mode then return end
    local names, types = mode.entity_filters, mode.entity_type_filters
    local filter_mode = mode.entity_filter_mode or "whitelist"
    if filter_mode ~= "whitelist" or (names and types) then return end
    if types and (#types ~= 1 or types[1] ~= "electric-pole") then return end
    if not names and not types then return end

    local allowed = {}
    if names then
        for _, name in ipairs(names) do
            if not excluded[name] then allowed[#allowed + 1] = name end
        end
    else
        for name in pairs(data.raw["electric-pole"]) do
            if not excluded[name] then allowed[#allowed + 1] = name end
        end
    end
    if #allowed == 0 then
        -- Do not turn an empty whitelist into an unfiltered selection.
        mode.mode = {"nothing"}
        mode.entity_filters = nil
        mode.entity_type_filters = nil
        return
    end
    table.sort(allowed)
    mode.entity_filters = allowed
    mode.entity_filter_mode = "whitelist"
    mode.entity_type_filters = nil
end

protect_factory_poles(tool.select)
protect_factory_poles(tool.alt_select)
