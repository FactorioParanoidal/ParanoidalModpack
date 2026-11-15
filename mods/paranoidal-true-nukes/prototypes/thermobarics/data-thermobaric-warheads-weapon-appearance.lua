local create_utils = require("__paranoidal-true-nukes__.prototypes.sprite-assembly-util")


local createAppearance = create_utils.createAppearance
local tints = create_utils.tints


weaponTypes["cannon-shell"].icons["-thermobaric-1"] = createAppearance({type = "cannon", style = 3, tints = {tints.explosive}}).icons
weaponTypes["cannon-shell"].icons["-thermobaric-2"] = createAppearance({type = "cannon", style = 4, tints = {tints.explosive, tints.explosive}}).icons
weaponTypes["small-rocket"].icons["-thermobaric-1"] = createAppearance({type = "rocket", style = 3, tints = {tints.explosive, tints.explosive}}).icons


weaponTypes["big-rocket"].icons["-thermobaric-1"] = createAppearance({type = "rocket_big", style = 3, tints = {tints.explosive, tints.explosive}}).icons
weaponTypes["big-rocket"].icons["-thermobaric-2"] = createAppearance({type = "rocket_big", style = 4, tints = {tints.explosive, tints.explosive, tints.explosive}}).icons

weaponTypes["artillery-shell"].icons["-thermobaric-1"] = createAppearance({type = "artillery", style = 2, tints = {tints.explosive}}).icons
weaponTypes["artillery-shell"].icons["-thermobaric-2"] = createAppearance({type = "artillery", style = 3, tints = {tints.explosive, tints.explosive}}).icons
weaponTypes["artillery-shell"].icons["-thermobaric-3"] = createAppearance({type = "artillery", style = 4, tints = {tints.explosive, tints.explosive, tints.explosive}}).icons
