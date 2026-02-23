---Provides a wrapper for LuaRecipe with quality
---@class KuxCoreLib.RecipeWithQuality.static
local RecipeWithQuality = {}

local mt = {}

mt.__index = function(t, k)
	if k == "quality" then return nil end
	return t.recipe[k]
end

function RecipeWithQuality.new(recipe, quality)
	local instance = {
		__class = "KuxCoreLib.RecipeWithQuality",
		recipe = recipe,
		quality = quality
	}
	return setmetatable(instance, mt)
end

-----------------------------------------------------------------------------------------------------------------------
return RecipeWithQuality


-----------------------------------------------------------------------------------------------------------------------

---@class KuxCoreLib.RecipeWithQuality : LuaRecipe
--- -----------------------------------
---@field __class "KuxCoreLib.RecipeWithQuality"
---@field recipe LuaRecipe
---@field quality LuaQualityPrototype