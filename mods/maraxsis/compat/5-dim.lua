local collision_mask_util = require("collision-mask-util")

data.raw.radar["maraxsis-sonar"].next_upgrade = nil

-- Paranoidal fork: the upgrade target may be of another entity type (the build's big copper lamp, an assembling
-- machine, upgrades into the large lamp, a lamp): look it up in every entity type, not only in the entity's own.
local function find_entity(name)
    if not name then return nil end
    for prototype in pairs(defines.prototypes.entity) do
        local entity = data.raw[prototype] and data.raw[prototype][name]
        if entity then return entity end
    end
    return nil
end

for prototype in pairs(defines.prototypes.entity) do
    for name, entity in pairs(data.raw[prototype] or {}) do
        local next_upgrade = find_entity(entity.next_upgrade)
        if next_upgrade then
            local collision_mask_1 = collision_mask_util.get_mask(entity)
            local collision_mask_2 = collision_mask_util.get_mask(next_upgrade)
            if not collision_mask_util.masks_are_same(collision_mask_1, collision_mask_2) then
                entity.next_upgrade = nil
            end
        else
            entity.next_upgrade = nil
        end
        if not entity.minable then
            entity.next_upgrade = nil
        end
    end
end
