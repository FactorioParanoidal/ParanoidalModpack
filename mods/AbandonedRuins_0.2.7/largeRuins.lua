--checks for spawning validity and if valid, clears space for the spawn
function l_clearArea(center, surface)
    --exclude tiles that we shouldn't spawn on
    local radius = 16
    if surface.count_tiles_filtered{ area = {{center.x-radius, center.y-radius}, {center.x+radius, center.y+radius}}, limit = 1, collision_mask = "item-layer" } == 1 then
        return false
    end

    for index, entity in pairs(surface.find_entities({{center.x-radius,center.y-radius},{center.x+radius,center.y+radius}})) do
        if entity.valid and entity.type ~= "resource" and entity.type ~= "tree" then --don't destroy ores or trees
            entity.destroy({do_cliff_correction=true})
        end
    end

    return true
end

local l_ruins = {}

table.insert(l_ruins, require("largeRuins.destroyedEnemyFort"))
table.insert(l_ruins, require("largeRuins.destroyedFort"))
table.insert(l_ruins, require("largeRuins.earlyGame"))
table.insert(l_ruins, require("largeRuins.mainBus"))
table.insert(l_ruins, require("largeRuins.orchard"))
table.insert(l_ruins, require("largeRuins.walledOrchard"))
table.insert(l_ruins, require("largeRuins.walledGrotto"))


function spawnLargeRuins(center, surface)
    if l_clearArea(center, surface) then
        l_ruins[math.random(#l_ruins)](center, surface) --call a random function
    end
end
