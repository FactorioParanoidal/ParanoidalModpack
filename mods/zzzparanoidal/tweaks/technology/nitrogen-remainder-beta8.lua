-- Beta 8: у азота IV два предка. Аммоний/платину и натриевые ворота III здесь не меняем.
local name = "angels-nitrogen-processing-4"
local technology = data.raw.technology[name]
if technology and technology.max_level ~= "infinite"
	and data.raw.technology["angels-nitrogen-processing-3"]
	and data.raw.technology["angels-advanced-chemistry-5"] then
	technology.prerequisites = { "angels-nitrogen-processing-3", "angels-advanced-chemistry-5" }
end
