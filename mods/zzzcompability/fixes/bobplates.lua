local Assert = require("utils.assert")

-- bobplates refers to bob-quartz in sand-processing's research_trigger which is removed by angels-refining
-- there i fix it by replacing original research recipe
-- In order to compability with paranoidal i remove sand-processing and glass-processing
local function FixSandProcessing()
	Assert(data.raw and data.raw.technology, "Expected data.raw.technology but it is nil")

	data.raw.technology["sand-processing"] = nil
	data.raw.technology["glass-processing"] = nil

	for _, tech in pairs(data.raw.technology) do
		if tech.prerequisites then
			for i = #tech.prerequisites, 1, -1 do
				local req = tech.prerequisites[i]
				if req == "glass-processing" or req == "sand-processing" then
					table.remove(tech.prerequisites, i)
				end
			end
		end
	end
end

FixSandProcessing()
