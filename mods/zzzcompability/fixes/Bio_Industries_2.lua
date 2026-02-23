local Assert = require("utils.assert")
-- fix Bio_farm + angelsrefining patch
-- fix old recipe result definition
local function FixBiSand()
	Assert(data.raw ~= nil and data.raw.recipe ~= nil, "Expected data.raw.recipe but it is nil")

	local recipe = data.raw.recipe["bi-sand"]
	Assert.AssertOutdated(type(recipe) == "table", "Recipe bi-sand not found.")
	Assert.AssertOutdated(type(recipe.result) == "string", "Recipe bi-sand not contain result as string section.")

	local amount = 5
	local newName = "angels-solid-sand"
	if recipe.results and type(recipe.results.amount) == "number" then
		amount = recipe.results.amount
	end

	recipe.results = { { type = "item", name = newName, amount = amount } }
	recipe.result = nil -- clear old definition
end

-- fluid.bi-biomass.icons[1].scale = nil
-- angelsrefining have logic hole on make_void function which leads to error when recipe.icons[i].scale not set
-- there i fix it
local function FixBiomass()
	Assert.AssertOutdated(data.raw.fluid and data.raw.fluid["bi-biomass"], "")
	Assert.AssertOutdated(data.raw.fluid["bi-biomass"].icons, "")
	for _, iconLayer in pairs(data.raw.fluid["bi-biomass"].icons) do
		if not iconLayer.scale then
			iconLayer.scale = 1
		end
	end
end

FixBiSand()
FixBiomass()
