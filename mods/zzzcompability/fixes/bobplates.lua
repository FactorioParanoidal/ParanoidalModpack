local Assert = require("utils.assert")

-- bobplates refers to bob-quartz in sand-processing's research_trigger which is removed by angels-refining
-- there i fix it by replacing original research recipe
-- In order to compability with paranoidal i remove sand-processing and glass-processing
local function FixSandProcessing()
	Assert(data.raw and data.raw.technology, "Expected data.raw.technology but it is nil")

	data.raw.technology["sand-processing"] = nil
	data.raw.technology["glass-processing"] = nil

	local sciencepack = data.raw.technology["automation-science-pack"]
	Assert.AssertOutdated(type(sciencepack) == "table", "automation-science-pack tech not found")
	for index, req in ipairs(sciencepack.prerequisites) do
		if req == "glass-processing" then
			table.remove(sciencepack.prerequisites, index)
			return
		end
	end

end

FixSandProcessing()
