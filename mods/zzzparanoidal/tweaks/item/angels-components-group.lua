-- Keep Angel's component rows intact, after the existing vanilla component rows.
local source = "angels-components"
local target = "intermediate-products"
local groups = data.raw["item-group"]
if not (groups[source] and groups[target]) then return end

local rows = {}
local last_order = ""
for _, subgroup in pairs(data.raw["item-subgroup"]) do
    if subgroup.group == source then
        rows[#rows + 1] = subgroup
    elseif subgroup.group == target and (subgroup.order or "") > last_order then
        last_order = subgroup.order
    end
end

table.sort(rows, function(a, b)
    local a_order, b_order = a.order or "", b.order or ""
    if a_order == b_order then return a.name < b.name end
    return a_order < b_order
end)

-- A prefix beyond every existing order avoids collisions without moving old rows.
for index, subgroup in ipairs(rows) do
    subgroup.group = target
    subgroup.order = last_order .. "-angels-" .. string.format("%04d", index)
end

groups[source] = nil

-- Angels' splitter tutorial clicks the component tab to select a circuit.
local splitter_tip = data.raw["tips-and-tricks-item"] and data.raw["tips-and-tricks-item"].splitters
local simulation = splitter_tip and splitter_tip.simulation
if simulation and type(simulation.init) == "string" then
    simulation.init = simulation.init:gsub('"angels%-components"', '"intermediate-products"')
end
