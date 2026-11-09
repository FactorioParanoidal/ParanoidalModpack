-- Adds helper functions for data stage. Shared across all pymods and adapted for use in maraxsis
local table = require("lib.table")
maraxsis.on_event = function() end

---Returns a 1x1 empty image.
---@return table
maraxsis.empty_image = function()
    return {
        filename = "__core__/graphics/empty.png",
        size = 1,
        priority = "high",
        direction_count = 1,
        frame_count = 1,
        line_length = 1
    }
end

---Creates a new prototype by cloning 'old' and overwriting it with properties from 'new'. Provide 'nil' as a string in order to delete items inside 'old'
---@param old data.AnyPrototype
---@param new table
---@return data.AnyPrototype
maraxsis.merge = function(old, new)
    if not old then
        error("Failed to maraxsis.merge: Old prototype is nil", 2)
    end

    old = table.deepcopy(old)
    for k, v in pairs(new) do
        if v == "nil" then
            old[k] = nil
        else
            old[k] = v
        end
    end
    return old
end

maraxsis.surface_conditions = function()
    return {{
        property = "pressure",
        min = 200000,
        max = 800000,
    }}
end

maraxsis.trench_surface_conditions = function()
    return {{
        property = "pressure",
        min = 800000,
        max = 800000,
    }}
end

maraxsis.shallow_surface_conditions = function()
    return {{
        property = "pressure",
        min = 200000,
        max = 200000,
    }}
end

-- Recursive function to ensure all strings are within 20 units.
-- Factorio crashes if a localised string is greater than 20 units
maraxsis.shorten_localised_string = function(localised_string)
    if table_size(localised_string) <= 20 then return localised_string end

    local first_half = {}
    local second_half = {}
    local midway_point = math.ceil(table_size(localised_string) / 2)

    for i, v in ipairs(localised_string) do
        if i <= midway_point then
            if not next(first_half) and v ~= "" then first_half[#first_half + 1] = "" end
            first_half[#first_half + 1] = v
        else
            if not next(second_half) and v ~= "" then second_half[#second_half + 1] = "" end
            second_half[#second_half + 1] = v
        end
    end

    return {"", maraxsis.shorten_localised_string(first_half), maraxsis.shorten_localised_string(second_half)}
end

--- The position in a nuke's target effects right after it destroys cliffs, or
--- the end of the list if it doesn't.
--- @param target_effects table
--- @return integer
maraxsis.index_after_destroy_cliffs = function(target_effects)
    local _, index = table.find(target_effects, function(effect) return effect.type == "destroy-cliffs" end)
    return index and index + 1 or #target_effects + 1
end
