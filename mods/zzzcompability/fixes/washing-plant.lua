-- washing plant 3 have no volume value at the last fluid box(at 4 index)
-- so there i fix it

local Assert = require("utils.assert")


local function FixPlant(name)
	local plant = data.raw["assembling-machine"][name]
	Assert.AssertOutdated(plant and plant.fluid_boxes and #plant.fluid_boxes == 4 and plant.fluid_boxes[4].volume == nil, "Expected fluid_boxes[4].volume to be nil")

	plant.fluid_boxes[4].volume = 1000
end

FixPlant("angels-washing-plant-3")
FixPlant("angels-washing-plant-4")

