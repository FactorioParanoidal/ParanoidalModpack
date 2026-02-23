local collision_mask_util = require("collision-mask-util")

local layer = "landfill-layer"
data.raw.tile["landfill"].collision_mask[layer] = true
data.raw["offshore-pump"]["offshore-mk0-pump"].collision_mask[layer] = true
data.raw["offshore-pump"]["offshore-pump"].collision_mask[layer] = true
data.raw["offshore-pump"]["offshore-mk2-pump"].collision_mask[layer] = true
data.raw["offshore-pump"]["offshore-mk3-pump"].collision_mask[layer] = true
data.raw["offshore-pump"]["offshore-mk4-pump"].collision_mask[layer] = true
data.raw["offshore-pump"]["angels-seafloor-pump"].collision_mask[layer] = true
