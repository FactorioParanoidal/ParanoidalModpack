-- Upgrade and deconstruction planners list the input and output loader shells as two
-- identical entries. Whatever the player picked, extend the planner so a rule covers both
-- modes. Pure functions without event registration (also used by technical probes).
local defs = require("__zzzparanoidal__/loader-definitions")
local M = {}

function M.counterpart(shell_name)
    local def = defs.shells[shell_name]
    return def and defs.shell(def.machine, def.mode == "input" and "output" or "input")
end
local function filter_key(f)
    return (f.name or "") .. "|" .. tostring(f.quality) .. "|" .. tostring(f.comparator)
end

local function extend_upgrade_planner(planner)
    local count = planner.mapper_count
    local known, additions = {}, {}
    for i = 1, count do
        local from = planner.get_mapper(i, "from")
        if from and from.type == "entity" and from.name then known[filter_key(from)] = true end
    end
    for i = 1, count do
        local from = planner.get_mapper(i, "from")
        local other = from and from.type == "entity" and from.name and M.counterpart(from.name)
        if other then
            local source = { type = "entity", name = other, quality = from.quality, comparator = from.comparator }
            if not known[filter_key(source)] then
                known[filter_key(source)] = true
                additions[#additions + 1] = { from = source, to = planner.get_mapper(i, "to") }
            end
        end
    end
    -- Fill empty rows first; past the end the engine extends the list.
    local index = 1
    for _, add in ipairs(additions) do
        while index <= count and (planner.get_mapper(index, "from").name or planner.get_mapper(index, "to")) do
            index = index + 1
        end
        planner.set_mapper(index, "from", add.from)
        if add.to then planner.set_mapper(index, "to", add.to) end
        index = index + 1
    end
    return #additions
end

local function extend_deconstruction_planner(planner)
    local count = planner.entity_filter_count
    local known, additions = {}, {}
    for i = 1, count do
        local f = planner.get_entity_filter(i)
        if f and f.name then known[filter_key(f)] = true end
    end
    for i = 1, count do
        local f = planner.get_entity_filter(i)
        local other = f and f.name and M.counterpart(f.name)
        if other then
            local filter = { name = other, quality = f.quality, comparator = f.comparator }
            if not known[filter_key(filter)] then
                known[filter_key(filter)] = true
                additions[#additions + 1] = filter
            end
        end
    end
    local index, added = 1, 0
    for _, filter in ipairs(additions) do
        while index <= count and planner.get_entity_filter(index) do index = index + 1 end
        if index > count then
            log("Paranoidal loader: deconstruction planner is full, counterpart filter not added")
            break
        end
        planner.set_entity_filter(index, filter)
        index, added = index + 1, added + 1
    end
    return added
end

-- planner: LuaItemStack (also a blueprint book with an active planner) or LuaRecord.
-- Returns the number of added rows, or nil when this is not a planner.
function M.extend(planner)
    if not planner then return nil end
    local ok, kind = pcall(function()
        if planner.object_name == "LuaItemStack" then
            if not (planner.valid and planner.valid_for_read) then return nil end
            if planner.is_blueprint_book then
                local inventory = planner.get_inventory(defines.inventory.item_main)
                local active = inventory and planner.active_index and inventory[planner.active_index]
                if active and active.valid_for_read then planner = active else return nil end
            end
            return planner.type
        end
        return planner.valid and planner.type -- LuaRecord in the blueprint library
    end)
    if not ok then return nil end
    local done, result
    -- Item stacks report item types, library records their own record types.
    if kind == "upgrade-item" or kind == "upgrade-planner" then
        done, result = pcall(extend_upgrade_planner, planner)
    elseif kind == "deconstruction-item" or kind == "deconstruction-planner" then
        done, result = pcall(extend_deconstruction_planner, planner)
    else
        return nil
    end
    if not done then
        log("Paranoidal loader: planner not extended: " .. tostring(result))
        return nil
    end
    return result
end

return M
