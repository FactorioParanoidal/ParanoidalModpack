local utility_constants = {
    small_area_size = 1.5, -- less than this plays the 'small' sound variants
    medium_area_size = 6.5, -- less than this plays the 'medium' sound variants
    large_area_size = 15, -- less than this plays the 'large' sound variants, otherwise plays the 'huge' sound variants.
}

-- if data stage
if mods then
    local prototype = data.raw["utility-constants"]["default"]
    for key, value in pairs(utility_constants) do
        assert(prototype[key] == value, "expected %s to be %s but was %s.", key, serpent.line(value), serpent.line(prototype[key]))
    end
end

return utility_constants
