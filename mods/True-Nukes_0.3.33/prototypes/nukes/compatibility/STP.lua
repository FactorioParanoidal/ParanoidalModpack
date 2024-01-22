local create_utils = require("__Warheads__.prototypes.sprite-assembly-util")

local setupWarheadsForWeapon = create_utils.setupWarheadsForWeapon
local tints = create_utils.tints



local setupForAutocannon = {
  sprite_types = require("__Warheads__.prototypes.compatibility.SchallTankPlatoon-sprites"),
  type = "autocannon",
  weapon = "autocannon-shell",
  warheads = {}
}
setupForAutocannon.warheads["-atomic-0_1t"] = {style = 3, tints = {tints.californium, tints.californium, tints.californium}}
setupForAutocannon.warheads["-atomic-0_5t"] = {style = 2, tints = {tints.californium, tints.californium, tints.californium}}
setupForAutocannon.warheads["-atomic-2t"] = {style = 4, tints = {tints.californium, tints.californium, tints.californium, tints.californium, tints.californium, tints.californium}}
setupForAutocannon.warheads["-atomic-4t"] = {style = 4, tints = {tints.californium, tints.californium, tints.californium, tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}}
setupForAutocannon.warheads["-atomic-8t"] = {style = 4, tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive, tints.californium, tints.californium, tints.californium}}
setupForAutocannon.warheads["-atomic-20t"] = {style = 4, tints = {tints.uraniumLive, tints.uraniumLive, tints.uraniumLive, tints.uraniumLive, tints.uraniumLive, tints.uraniumLive}}
setupWarheadsForWeapon(setupForAutocannon)