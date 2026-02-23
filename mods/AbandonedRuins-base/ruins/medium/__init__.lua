-- A "list" of ruins, including their names
--- @type Ruin[]
local ruins = {}

-- Insert all ruins
for _, name in pairs({
	"assemblingLine",
	"carAssembly",
	"carBelt",
	"centrifuges",
	"chemicalPlant",
	"crashedShip",
	"eFurnace",
	"encampment",
	"helipad",
	"militaryField",
	"mountainRange",
	"nuclearAccident",
	"nuclearPower",
	"overgrownFort",
	"overwhelmedFlamers",
	"overwhelmedGunturrets",
	"pipeChain",
	"powerSetup",
	"radarOutpost",
	"roughFort",
	"roughPerimeter",
	"smallOilSetup",
	"smeltery",
	"street",
	"storageArea",
	"swamp",
	"trappedRocks",
	"treeFortTrapped",
	"treeIsland",
	"treeRing",
	"uraniumMining",
	"walledSolar"
}) do
	if debug_log then log(string.format("Loading name='%s' ...", name)) end

	---@type Ruin Individual ruin, file' name becomes ruin's name
	local ruin = require(name)
	ruin.name = name
	ruins[#ruins + 1] = ruin
end

return ruins
