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

if not data.raw["corpse"]["acid-splash-purple"] then
    data:extend({
            {
                type = "corpse",
                name = "acid-splash-purple",
                flags = {"not-on-map"},
                time_before_removed = 60 * 30,
                final_render_layer = "corpse",
                splash =
                    {
                        {
                            filename = "__base__/graphics/entity/acid-splash/acid-splash-1.png",
                            line_length = 8,
                            direction_count = 1,
                            width = 106,
                            height = 116,
                            frame_count = 26,
                            shift = util.mul_shift(util.by_pixel(-12, -10), attributes.scale or 1),
                            tint = attributes.tint,
                            scale = (attributes.scale or 1),
                            hr_version = {
                                filename = "__base__/graphics/entity/acid-splash/hr-acid-splash-1.png",
                                line_length = 8,
                                direction_count = 1,
                                width = 210,
                                height = 224,
                                frame_count = 26,
                                shift = util.mul_shift(util.by_pixel(-12, -8), attributes.scale or 1),
                                tint = attributes.tint,
                                scale = 0.5 * (attributes.scale or 1),
                            }
                        },
                        {
                            filename = "__base__/graphics/entity/acid-splash/acid-splash-2.png",
                            line_length = 8,
                            direction_count = 1,
                            width = 88,
                            height = 76,
                            frame_count = 29,
                            shift = util.mul_shift(util.by_pixel(-10, -18), attributes.scale or 1),
                            tint = attributes.tint,
                            scale = (attributes.scale or 1),
                            hr_version = {
                                filename = "__base__/graphics/entity/acid-splash/hr-acid-splash-2.png",
                                line_length = 8,
                                direction_count = 1,
                                width = 174,
                                height = 150,
                                frame_count = 29,
                                shift = util.mul_shift(util.by_pixel(-9, -17), attributes.scale or 1),
                                tint = attributes.tint,
                                scale = 0.5 * (attributes.scale or 1),
                            }
                        },
                        {
                            filename = "__base__/graphics/entity/acid-splash/acid-splash-3.png",
                            line_length = 8,
                            direction_count = 1,
                            width = 118,
                            height = 104,
                            frame_count = 29,
                            shift = util.mul_shift(util.by_pixel(22, -16), attributes.scale or 1),
                            tint = attributes.tint,
                            scale = (attributes.scale or 1),
                            hr_version = {
                                filename = "__base__/graphics/entity/acid-splash/hr-acid-splash-3.png",
                                line_length = 8,
                                direction_count = 1,
                                width = 236,
                                height = 208,
                                frame_count = 29,
                                shift = util.mul_shift(util.by_pixel(22, -16), attributes.scale or 1),
                                tint = attributes.tint,
                                scale = 0.5 * (attributes.scale or 1),
                            }
                        },
                        {
                            filename = "__base__/graphics/entity/acid-splash/acid-splash-4.png",
                            line_length = 8,
                            direction_count = 1,
                            width = 128,
                            height = 80,
                            frame_count = 24,
                            shift = util.mul_shift(util.by_pixel(16, -20), attributes.scale or 1),
                            tint = attributes.tint,
                            scale = (attributes.scale or 1),
                            hr_version = {
                                filename = "__base__/graphics/entity/acid-splash/hr-acid-splash-4.png",
                                line_length = 8,
                                direction_count = 1,
                                width = 252,
                                height = 154,
                                frame_count = 24,
                                shift = util.mul_shift(util.by_pixel(17, -19), attributes.scale or 1),
                                tint = attributes.tint,
                                scale = 0.5 * (attributes.scale or 1),
                            }
                        }
                    },
                splash_speed = 0.03
            }
    })
end

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
