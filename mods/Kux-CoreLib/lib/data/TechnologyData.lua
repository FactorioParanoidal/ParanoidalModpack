require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.TechnologyData : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.TechnologyData
local TechnologyData = {
	__class  = "TechnologyData",
	__guid   = "69c904c0-8169-454a-a807-d9d5232e9986",
	__origin = "Kux-CoreLib/lib/data/TechnologyData.lua",
}
if not KuxCoreLib.__classUtils.ctor(TechnologyData) then return self end
---------------------------------------------------------------------------------------------------
local Table = KuxCoreLib.Table
local utils = KuxCoreLib.PrototypeData.extend.utils

---@class KuxCoreLib.Data.TechnologyPrototype : data.TechnologyPrototype
---@field base data.TechnologyPrototype additional internal reference

---Clones a technology
---@param name string base name
---@param newName string new name
---@param patch table?
---@return KuxCoreLib.Data.TechnologyPrototype
function TechnologyData.clone(name, newName, patch)
	local base = data.raw["technology"][name]
	if(not base) then error("Prototype not found: "..name.." (type: technology)") end
	local technology = table.deepcopy(base) --[[@as KuxCoreLib.Data.TechnologyPrototype]]
	technology.name = newName
	--technology.localised_name = {"recipe-name."..newName}
	technology.base = base -- additional internal reference
	if(patch) then utils.patch(technology, patch) end -- apply patch if any
	return technology
end

---Remove prerequisites
---@param technology data.TechnologyPrototype
---@param name string
function TechnologyData.removePrerequisites(technology, name)
	local i = Table.indexOf(technology.prerequisites, name)
	if(i>0) then table.remove(technology.prerequisites, i) end
end

---Add prerequisites
---@param technology data.TechnologyPrototype
---@param name string
function TechnologyData.addPrerequisites(technology, name)
	assert(data.raw["technology"][name], "Prototype not found: "..name.." (type: technology)")
	local i = Table.indexOf(technology.prerequisites, name)
	if(not i) then table.insert(technology.prerequisites, name) end
end

function TechnologyData.indexOfIngredient(technology, name)
	for i, v in ipairs(technology.unit.ingredients) do
		print(v[1] or v["name"])
		if(v[1] == name) then return i end
		if(v["name"]==name) then return i end
	end
	return 0
end

function TechnologyData.findIngredient(technology, name)
	for i, v in ipairs(technology.unit.ingredients) do
		print(v[1] or v["name"])
		if(v[1] == name) then return v end
		if(v["name"]==name) then return v end
	end
	return nil
end

function TechnologyData.removeIngredients(technology, name)
	local i = TechnologyData.indexOfIngredient(technology, name)
	if(i>0) then table.remove(technology.unit.ingredients,i) end
end

function TechnologyData.findByEffectsUnlockRecipe(recipe, findAll)
	local dicOfTechnologies = {}
	for _, tech in pairs(data.raw.technology) do
		for iEffect, effect in ipairs(tech.effects) do
			if(effect.type == "unlock-recipe" and effect.recipe == recipe) then
				if(not findAll) then return tech.name, iEffect end
				dicOfTechnologies[tech.name] = iEffect
			end
		end
	end
	return dicOfTechnologies
end

function TechnologyData.findByPrerequisites(prerequisite)
	local technologyNames = {}
	for _, tech in pairs(data.raw.technology) do
		local i = Table.indexOf(tech.prerequisites, prerequisite)
		if(i>0) then table.insert(technologyNames, tech.name) end
	end
	return technologyNames
end

function TechnologyData.findByIngredient(ingredient)
	local technologyNames = {}
	for _, tech in pairs(data.raw.technology) do
		for _, value in ipairs(tech.unit.ingredients) do
			if(value[1] == ingredient and (value[2] or 0)>0) then
				table.insert(technologyNames, tech.name)
			end
		end
	end
	return technologyNames
end

---------------------------------------------------------------------------------------------------
return TechnologyData