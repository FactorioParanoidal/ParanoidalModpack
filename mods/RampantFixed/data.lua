-- import

local colorUtils = require("prototypes/utils/ColorUtils")
local smokeUtils = require("prototypes/utils/SmokeUtils")
local targetDummy = require("prototypes/TargetDummy")	

-- imported functions

local makeSmokeSoft = smokeUtils.makeSmokeSoft
local makeSmokeWithGlow = smokeUtils.makeSmokeWithGlow
local makeSmokeWithoutGlow = smokeUtils.makeSmokeWithoutGlow
local makeSmokeAddingFuel = smokeUtils.makeSmokeAddingFuel

local makeColor = colorUtils.makeColor

-- module code

makeSmokeSoft({name="the", softSmokeTint=makeColor(0.3, 0.75, 0.3, 0.1)})
makeSmokeWithGlow({name="the", smokeWithGlowTint=makeColor(0.3, 0.75, 0.3, 0.1)})
makeSmokeWithoutGlow({name="the", smokeWithoutGlowTint=makeColor(0.3, 0.75, 0.3, 0.1)})
makeSmokeAddingFuel({name="the"})

require("prototypes/buildings/ChunkScanner")
require("prototypes/Gui_style")	

-- + !КДА 2021.11
data:extend(
{
  {
    type = "damage-type",
    name = "rampant-longRangeImmunity"
  },
  {
    type = "damage-type",
    name = "rampant-overdamageProtection"
  },
}
)
-- - !КДА 2021.11

local attributes = {}

-- acid-splash-purple удалён (Paranoidal): ни один прототип и скрипт на него не ссылался.

local swarmUtils = require("prototypes/SwarmUtils")

targetDummy.addTargetDummies()
targetDummy.addDummySetters()

if settings.startup["rampantFixed--newEnemies"].value then
	swarmUtils.processFactions()
    swarmUtils.generateSpawnerProxy(data.raw["unit-spawner"]["neutral-biter-spawner-v1-t10-rampant"].result_units)

else
    swarmUtils.generateSpawnerProxy(data.raw["unit-spawner"]["biter-spawner"].result_units)
end

local bitersEnrage = require("libs/BitersEnrage")
bitersEnrage.createStickers()
----- undergroundAttack
local slowdownSticker = util.table.deepcopy(data.raw["sticker"]["slowdown-sticker"])
slowdownSticker.name = "slowdown-sticker-rampant"
slowdownSticker.duration_in_ticks = 5 * 60
slowdownSticker.target_movement_modifier = 0.5
data:extend({slowdownSticker})

data:extend(
{
  {
    type = "virtual-signal",
    name = "undergroundPass-warning-rampant",
    icons = {{icon = "__RampantFixed__/graphics/icons/alerts/underground-icon.png", icon_size = 64}}
  }
}
)
data:extend(
{
  {
    type = "virtual-signal",
    name = "undergroundDigout-warning-rampant",
    icons = {{icon = "__RampantFixed__/graphics/icons/alerts/underground-icon2.png", icon_size = 64}}
  }
}
)
data:extend(
{
  {
    type = "virtual-signal",
    name = "squadDetected-warning-rampant",
    icons = {{icon = "__core__/graphics/icons/alerts/warning-icon.png", icon_size = 64}}	
  }
}
)

data:extend(
{
  {
    type = "virtual-signal",
    name = "demolisherAttack-warning-rampant",
    icons = {{icon = "__RampantFixed__/graphics/icons/alerts/demolisherAttack-icon.png", icon_size = 64}}	
  }
}
)

----- Powerup
local powerup = require("libs/Powerup")
powerup.makePowerup_capsule()
powerup.make_RegenerationCrystal()

local stickers = require("prototypes/Stickers")
stickers.makeSpeedStickers()

------ biter supperessor
if mods["space-age"] then
	local biterSupressors = require("libs/BiterSupressors")
	biterSupressors.addEntities()
	
end	

------ 
if mods["space-age"] then
	local demolisherUtils = require("libs/DemolisherUtils")
	demolisherUtils.makeDemolisherFood()
	demolisherUtils.makeUnstableReactor()
	
	require("prototypes/buildings/HeatingTower")
end
