local util = {}
util.SMALL_RUIN_HALF_SIZE = 8 / 2
util.MEDIUM_RUIN_HALF_SIZE = 16 / 2
util.LARGE_RUIN_HALF_SIZE = 32 / 2

local function clear_area(half_size, center, surface)
    local area = {{center.x-half_size, center.y-half_size}, {center.x+half_size, center.y+half_size}}
    --exclude tiles that we shouldn't spawn on
    if surface.count_tiles_filtered{ area = area, limit = 1, collision_mask = "item-layer" } == 1 then
        return false
    end

    for index, entity in pairs(surface.find_entities_filtered({area = area, type={"resource", "tree"}, invert = true})) do
        entity.destroy({do_cliff_correction=true})
    end

    return true
end

util.spawn_ruin = function(ruins, half_size, center, surface)
    if clear_area(half_size, center, surface) then
        ruins[math.random(#ruins)](center, surface) --call a random function
    end
end

return util
