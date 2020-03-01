
--checks for spawning validity and if valid, clears space for the spawn
function s_clearArea(center, surface)
    --exclude tiles that we shouldn't spawn on
    local radius = 4
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

local s_ruins = {}


table.insert(s_ruins, require("smallRuins.crossOfPipes"))
table.insert(s_ruins, require("smallRuins.crossOfPipes2"))
table.insert(s_ruins, require("smallRuins.crossOfPipes3"))
table.insert(s_ruins, require("smallRuins.crossOfPipes4"))
table.insert(s_ruins, require("smallRuins.diagonalWall"))
table.insert(s_ruins, require("smallRuins.diagonalWall2"))
table.insert(s_ruins, require("smallRuins.diagonalWall3"))
table.insert(s_ruins, require("smallRuins.diagonalWall4"))
table.insert(s_ruins, require("smallRuins.gateWall"))
table.insert(s_ruins, require("smallRuins.gateWall2"))
table.insert(s_ruins, require("smallRuins.gateWall3"))
table.insert(s_ruins, require("smallRuins.gateWall4"))
table.insert(s_ruins, require("smallRuins.gateWall5"))
table.insert(s_ruins, require("smallRuins.gateWall6"))
table.insert(s_ruins, require("smallRuins.gears"))
table.insert(s_ruins, require("smallRuins.gears2"))
table.insert(s_ruins, require("smallRuins.harmlessTurret"))
table.insert(s_ruins, require("smallRuins.harmlessTurret2"))
table.insert(s_ruins, require("smallRuins.harmlessTurret3"))
table.insert(s_ruins, require("smallRuins.landMineBunker"))
table.insert(s_ruins, require("smallRuins.landMineBunker2"))
table.insert(s_ruins, require("smallRuins.landMineBunker3"))
table.insert(s_ruins, require("smallRuins.miningSetup"))
table.insert(s_ruins, require("smallRuins.miningSetup2"))
table.insert(s_ruins, require("smallRuins.miningSetup3"))
table.insert(s_ruins, require("smallRuins.miningSetup4"))
table.insert(s_ruins, require("smallRuins.railSection"))
table.insert(s_ruins, require("smallRuins.railSection2"))
table.insert(s_ruins, require("smallRuins.railSection3"))
table.insert(s_ruins, require("smallRuins.railSection4"))
table.insert(s_ruins, require("smallRuins.railSection5"))
table.insert(s_ruins, require("smallRuins.randomWalls"))
table.insert(s_ruins, require("smallRuins.randomWalls2"))
table.insert(s_ruins, require("smallRuins.randomWalls3"))
table.insert(s_ruins, require("smallRuins.randomWalls4"))
table.insert(s_ruins, require("smallRuins.randomWalls5"))
table.insert(s_ruins, require("smallRuins.researchStation"))
table.insert(s_ruins, require("smallRuins.researchStation2"))
table.insert(s_ruins, require("smallRuins.researchStation3"))
table.insert(s_ruins, require("smallRuins.researchStation4"))
table.insert(s_ruins, require("smallRuins.researchStation5"))
table.insert(s_ruins, require("smallRuins.researchStation6"))
table.insert(s_ruins, require("smallRuins.researchStation7"))
table.insert(s_ruins, require("smallRuins.researchStation8"))
table.insert(s_ruins, require("smallRuins.researchStation9"))
table.insert(s_ruins, require("smallRuins.researchStation10"))
table.insert(s_ruins, require("smallRuins.rockStash"))
table.insert(s_ruins, require("smallRuins.rockStash2"))
table.insert(s_ruins, require("smallRuins.rockStash3"))
table.insert(s_ruins, require("smallRuins.rockStash4"))
table.insert(s_ruins, require("smallRuins.rockStash5"))
table.insert(s_ruins, require("smallRuins.rockStash6"))
table.insert(s_ruins, require("smallRuins.rockStash7"))
table.insert(s_ruins, require("smallRuins.rockStash8"))
table.insert(s_ruins, require("smallRuins.rockStash9"))
table.insert(s_ruins, require("smallRuins.rockStash10"))
table.insert(s_ruins, require("smallRuins.smallDestroyedSetup"))
table.insert(s_ruins, require("smallRuins.smallDestroyedSetup2"))
table.insert(s_ruins, require("smallRuins.smallDestroyedSetup3"))
table.insert(s_ruins, require("smallRuins.smallDestroyedSetup4"))
table.insert(s_ruins, require("smallRuins.smallDualSplitter"))
table.insert(s_ruins, require("smallRuins.smallDualSplitter2"))
table.insert(s_ruins, require("smallRuins.smallDualSplitter3"))
table.insert(s_ruins, require("smallRuins.smallMining"))
table.insert(s_ruins, require("smallRuins.smallMining2"))
table.insert(s_ruins, require("smallRuins.smallMining3"))
table.insert(s_ruins, require("smallRuins.smallMining4"))
table.insert(s_ruins, require("smallRuins.smallMining5"))
table.insert(s_ruins, require("smallRuins.smallMining6"))
table.insert(s_ruins, require("smallRuins.smallMountain"))
table.insert(s_ruins, require("smallRuins.smallMountain2"))
table.insert(s_ruins, require("smallRuins.smallMountain3"))
table.insert(s_ruins, require("smallRuins.smallMountain4"))
table.insert(s_ruins, require("smallRuins.smallSmelting"))
table.insert(s_ruins, require("smallRuins.smallSmelting2"))
table.insert(s_ruins, require("smallRuins.smallSmelting3"))
table.insert(s_ruins, require("smallRuins.smallSmelting4"))
table.insert(s_ruins, require("smallRuins.smeltery"))
table.insert(s_ruins, require("smallRuins.smeltery2"))
table.insert(s_ruins, require("smallRuins.smeltery3"))
table.insert(s_ruins, require("smallRuins.smeltery4"))
table.insert(s_ruins, require("smallRuins.splitterI"))
table.insert(s_ruins, require("smallRuins.splitterI2"))
table.insert(s_ruins, require("smallRuins.splitterI3"))
table.insert(s_ruins, require("smallRuins.victoryPoles"))
table.insert(s_ruins, require("smallRuins.victoryPoles2"))
table.insert(s_ruins, require("smallRuins.victoryPoles3"))
table.insert(s_ruins, require("smallRuins.victoryPoles4"))
table.insert(s_ruins, require("smallRuins.victoryPoles5"))
table.insert(s_ruins, require("smallRuins.victoryPoles6"))
table.insert(s_ruins, require("smallRuins.victoryPoles7"))
table.insert(s_ruins, require("smallRuins.victoryPoles8"))
table.insert(s_ruins, require("smallRuins.victoryPoles9"))


function spawnSmallRuins(center, surface)
    if s_clearArea(center, surface) then
        s_ruins[math.random(#s_ruins)](center, surface) --call a random function
    end
end
