-- From zzzcompability (Tias): run in data-updates, before the final recipe/icon passes.
local function assert_current(condition, message)
	assert(condition, message .. " Maybe current fix outdated?")
end

assert(data.raw and data.raw.recipe, "Expected data.raw.recipe but it is nil")
local recipe = data.raw.recipe["bi-sand"]
assert_current(type(recipe) == "table", "Recipe bi-sand not found.")
assert_current(type(recipe.results) == "table" or type(recipe.result) == "string",
	"Recipe bi-sand structure has changed: neither 'results' table nor 'result' string found.")

local amount = 5
if recipe.results and type(recipe.results) == "table" and recipe.results[1] then
	amount = recipe.results[1].amount or amount
elseif recipe.result_count then
	amount = recipe.result_count
end
recipe.results = { { type = "item", name = "angels-solid-sand", amount = amount } }
recipe.result = nil
recipe.result_count = nil

-- Preserve the explicit scale inherited by later composite icons and void recipes.
local biomass = data.raw.fluid and data.raw.fluid["bi-biomass"]
assert_current(biomass, "Fluid bi-biomass not found.")
assert_current(biomass.icons, "Fluid bi-biomass icons not found.")
for _, icon in pairs(biomass.icons) do
	if not icon.scale then
		icon.scale = 1
	end
end
