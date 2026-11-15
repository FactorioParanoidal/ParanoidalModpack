local create_utils = require("__paranoidal-true-nukes__.prototypes.sprite-assembly-util")


local setupWarheadsForWeapon = create_utils.setupWarheadsForWeapon
local tints = create_utils.tints

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
