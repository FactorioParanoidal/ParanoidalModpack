local create_utils = require("__Warheads__.prototypes.sprite-assembly-util")


local setupWarheadsForWeapon = create_utils.setupWarheadsForWeapon
local tints = create_utils.tints

if weaponTypes["rounds-magazine"] then
  weaponTypes["rounds-magazine"].icons["-atomic-0_1t"] = { "__True-Nukes__/graphics/rounds/yy-atomic-rounds-magazine.png"}
  weaponTypes["rounds-magazine"].icons["-atomic-0_5t"] = { "__True-Nukes__/graphics/rounds/yg-atomic-rounds-magazine.png"}
  weaponTypes["rounds-magazine"].icons["-atomic-2t"] = { "__True-Nukes__/graphics/rounds/gg-atomic-rounds-magazine.png"}
end
if weaponTypes["Schall-sniper-magazine"] then
  weaponTypes["Schall-sniper-magazine"].icons["-atomic-0_1t"] = { "__True-Nukes__/graphics/rounds/yy-atomic-rounds-magazine.png"}
  weaponTypes["Schall-sniper-magazine"].icons["-atomic-0_5t"] = { "__True-Nukes__/graphics/rounds/yy-atomic-rounds-magazine.png"}
  weaponTypes["Schall-sniper-magazine"].icons["-atomic-2t"] = { "__True-Nukes__/graphics/rounds/yg-atomic-rounds-magazine.png"}
  weaponTypes["Schall-sniper-magazine"].icons["-atomic-4t"] = { "__True-Nukes__/graphics/rounds/gg-atomic-rounds-magazine.png"}
end

local setupForShotgun = {
  type = "shotgun",
  weapon = "shotgun-shell",
  warheads = {}
}
setupForShotgun.warheads["-atomic-0_1t"] = {style = 1, tints = {tints.californium}}
setupForShotgun.warheads["-atomic-0_5t"] = {style = 2, tints = {tints.californium, tints.nothing}}
setupForShotgun.warheads["-atomic-2t"] = {style = 2, tints = {tints.californium, tints.californium}}
setupForShotgun.warheads["-atomic-4t"] = {style = 2, tints = {tints.californium, tints.uraniumLive}}
setupForShotgun.warheads["-atomic-8t"] = {style = 2, tints = {tints.uraniumLive, tints.californium}}
setupForShotgun.warheads["-atomic-20t"] = {style = 2, tints = {tints.uraniumLive, tints.uraniumLive}}

setupWarheadsForWeapon(setupForShotgun)

local setupForShotgunBuck = {
  type = "shotgun",
  weapon = "shotgun-shell-buckshot",
  warheads = {}
}
setupForShotgunBuck.warheads["-atomic-0_1t"] = {style = 3, tints = {tints.nothing, tints.californium}}
setupForShotgunBuck.warheads["-atomic-0_5t"] = {style = 3, tints = {tints.californium, tints.californium}}
setupForShotgunBuck.warheads["-atomic-2t"] = {style = 3, tints = {tints.californium, tints.uraniumLive}}

setupWarheadsForWeapon(setupForShotgunBuck)


local setupForCannon = {
  type = "cannon",
  weapon = "cannon-shell",
  warheads = {}
}
setupForCannon.warheads["-atomic-0_1t"] = {style = 3, tints = {tints.californium}}
setupForCannon.warheads["-atomic-0_5t"] = {style = 3, tints = {tints.californium}}
setupForCannon.warheads["-atomic-2t"] = {style = 2, tints = {tints.californium}}
setupForCannon.warheads["-atomic-4t"] = {style = 4, tints = {tints.californium, tints.californium}}
setupForCannon.warheads["-atomic-8t"] = {style = 4, tints = {tints.californium, tints.uraniumLive}}
setupForCannon.warheads["-atomic-20t"] = {style = 4, tints = {tints.uraniumLive, tints.californium}}

setupForCannon.warheads["-atomic-500t"] = {style = 4, tints = {tints.uraniumLive, tints.uraniumLive}}
setupWarheadsForWeapon(setupForCannon)

if mods["SchallTankPlatoon"] then
  setupForCannon.weapon = "cannon-H1-shell"
  setupWarheadsForWeapon(setupForCannon)
  setupForCannon.weapon = "cannon-H2-shell"
  setupWarheadsForWeapon(setupForCannon)
end


local setupForRocket = {
  type = "rocket",
  weapon = "small-rocket",
  warheads = {}
}
setupForRocket.warheads["-atomic-0_1t"] = {style = 2, tints = {tints.californium}}
setupForRocket.warheads["-atomic-0_5t"] = {style = 3, tints = {tints.lightNothing, tints.californium}}
setupForRocket.warheads["-atomic-2t"] = {style = 3, tints = {tints.californium, tints.californium}}

setupForRocket.warheads["-atomic-4t"] = {style = 4, tints = {tints.lightNothing, tints.californium, tints.californium}}
setupForRocket.warheads["-atomic-8t"] = {style = 4, tints = {tints.californium, tints.californium, tints.californium}}
setupForRocket.warheads["-atomic-20t"] = {style = 5, tints = {tints.californium, tints.californium, tints.californium, tints.californium}}
setupWarheadsForWeapon(setupForRocket)

local setupForBigRocket = {
  type = "rocket_big",
  weapon = "big-rocket",
  warheads = {}
}
setupForBigRocket.warheads["-atomic-0_1t"] = {style = 2, tints = {tints.californium}}
setupForBigRocket.warheads["-atomic-0_5t"] = {style = 3, tints = {tints.nothing, tints.californium}}
setupForBigRocket.warheads["-atomic-2t"] = {style = 3, tints = {tints.californium, tints.californium}}

setupForBigRocket.warheads["-atomic-4t"] = {style = 2, tints = {tints.uraniumLive}}
setupForBigRocket.warheads["-atomic-8t"] = {style = 3, tints = {tints.nothing, tints.uraniumLive}}
setupForBigRocket.warheads["-atomic-20t"] = {style = 3, tints = {tints.uraniumLive, tints.uraniumLive}}

setupForBigRocket.warheads["-atomic-500t"] = {style = 4, tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}}
setupForBigRocket.warheads["-atomic-1kt"] = {style = 5, tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}}
setupWarheadsForWeapon(setupForBigRocket)


local setupForArtillery = {
  type = "artillery",
  weapon = "artillery-shell",
  warheads = {}
}

setupForArtillery.warheads["-atomic-4t"] = {style = 2, tints = {tints.californium}}
setupForArtillery.warheads["-atomic-8t"] = {style = 3, tints = {tints.californium, tints.californium}}
setupForArtillery.warheads["-atomic-20t"] = {style = 2, tints = {tints.uraniumLive}}

setupForArtillery.warheads["-atomic-500t"] = {style = 3, tints = {tints.uraniumLive, tints.uraniumLive}}
setupForArtillery.warheads["-atomic-1kt"] = {style = 4, tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}}

setupForArtillery.warheads["-atomic-15kt"] = {style = 5, tints = {tints.uraniumLive, tints.uraniumLive}}

setupForArtillery.warheads["-atomic-2-stage-15kt"] = {style = 5, tints = {tints.uraniumLive, tints.nothing}}

setupForArtillery.warheads["-atomic-2-stage-100kt"] = {style = 5, tints = {tints.uraniumLive, tints.tritium}}
setupWarheadsForWeapon(setupForArtillery)













