
--checks for spawning validity and if valid, clears space for the spawn
function m_clearArea(center, surface)
    --exclude tiles that we shouldn't spawn on
    local radius = 8
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

local m_ruins = {}

table.insert(m_ruins, require("mediumRuins.assemblingLine"))
--table.insert(m_ruins, require("mediumRuins.biterDefense"))
table.insert(m_ruins, require("mediumRuins.encampment"))
table.insert(m_ruins, require("mediumRuins.mountainRange"))
table.insert(m_ruins, require("mediumRuins.pipeChain"))
table.insert(m_ruins, require("mediumRuins.powerSetup"))
--table.insert(m_ruins, require("mediumRuins.queenNest"))
table.insert(m_ruins, require("mediumRuins.roughPerimeter2"))
table.insert(m_ruins, require("mediumRuins.roughPerimeter"))
table.insert(m_ruins, require("mediumRuins.smallOilSetup"))
table.insert(m_ruins, require("mediumRuins.overgrownFort"))
table.insert(m_ruins, require("mediumRuins.radarOutpost"))
--table.insert(m_ruins, require("mediumRuins.railCrossing"))
table.insert(m_ruins, require("mediumRuins.treeFortTrapped"))
table.insert(m_ruins, require("mediumRuins.treeIsland"))
table.insert(m_ruins, require("mediumRuins.treeRing"))
table.insert(m_ruins, require("mediumRuins.roughFort"))
table.insert(m_ruins, require("mediumRuins.storageArea"))
--table.insert(m_ruins, require("mediumRuins.helipad"))
table.insert(m_ruins, require("mediumRuins.militaryField"))


function spawnMediumRuins(center, surface)
    if m_clearArea(center, surface) then
        m_ruins[math.random(#m_ruins)](center, surface) --call a random function
    end
end
