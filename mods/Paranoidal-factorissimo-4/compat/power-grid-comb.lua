if not mods["power-grid-comb"] then return end

local function array_combine(a, b)
    local result = {}
    for _, v in pairs(a) do
        table.insert(result, v)
    end
    for _, v in pairs(b) do
        table.insert(result, v)
    end
    return result
end

local our_poles = {"factory-circuit-connector", "factory-power-pole"}
local selection_tool = data.raw["selection-tool"]["power-grid-comb"]
selection_tool.entity_filters = array_combine(our_poles, selection_tool.entity_filters or {})
selection_tool.alt_entity_filters = array_combine(our_poles, selection_tool.alt_entity_filters or {})
selection_tool.entity_filter_mode = "blacklist"
selection_tool.alt_entity_filter_mode = "blacklist"
