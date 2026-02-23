require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

-- https://wiki.factorio.com/Prototype/Technology (obsolete)
-- https://lua-api.factorio.com/latest/prototypes/TechnologyPrototype.html

-- "normal"|"expensive" has been removed in 2.0 but I keep it for compatibility. always use TechnologyIndex.normal

---@class KuxCoreLib.TechnologyIndex
TechnologyIndex = {
	__class  = "TechnologyIndex",
	__guid   = "331e212d-14ba-4de5-b69a-c6f50dd30da6",
	__origin = "Kux-CoreLib/lib/data/TechnologyIndex.lua",
}
if not KuxCoreLib.__classUtils.ctor(TechnologyIndex) then return self end
---------------------------------------------------------------------------------------------------
TechnologyIndex.normal={
	effectsUnlockRecipe = {},
	ingredients = {},
	prerequisites = {}
}

---@deprecated "normal"|"expensive" has been removed in 2.0
TechnologyIndex.expensive={
	effectsUnlockRecipe = {},
	ingredients = {},
	prerequisites = {}
}

---dictionary of recipe_name → technology_name[]
---@type { [string]: string[] }
TechnologyIndex.effectsUnlockRecipe = TechnologyIndex.normal.effectsUnlockRecipe

---dictionary of ingredient_name → technology_name[]
---@type { [string]: string[] }
TechnologyIndex.ingredients = TechnologyIndex.normal.ingredients

---dictionary of prerequisite_name → technology_name[]
---@type {string: string[]}
TechnologyIndex.prerequisites = TechnologyIndex.normal.prerequisites

---@deprecated use data.TechnologyPrototype
---@class TechnologyData : data.TechnologyPrototype

--[[ TODO backward compatibility for 1.1
---Gets the data for the technology depending on mode
---@param technology data.TechnologyPrototype
---@param mode "normal"|"expensive"
---@return TechnologyData?
local function getData(technology, mode)
	if(technology.normal==nil and technology.expensive==nil) then
		return technology --[[@as TechnologyData]~]
	end
	if(mode=="normal") then
		if(type(technology.normal)=="table") then
			return technology.normal --[[@as TechnologyData]~]
		elseif(technology.normal==false) then
			return nil
		elseif(technology.normal==nil and type(technology.expensive)=="table") then
			return technology.expensive --[[@as TechnologyData]~]
		else
			return nil -- configuration error
		end
	else
		if(type(technology.expensive)=="table") then
			return technology.expensive --[[@as TechnologyData]~]
		elseif(technology.expensive==false) then
			return nil
		elseif(technology.expensive==nil and type(technology.normal)=="table") then
			return technology.normal --[[@as TechnologyData]~]
		else
			return nil -- configuration error
		end
	end
end
--]]

--[[ TODO backward compatibility for 1.1
local function build(mode)
    TechnologyIndex[mode].effectsUnlockRecipe = {}
    TechnologyIndex[mode].ingredients = {}
    TechnologyIndex[mode].prerequisites = {}

    for _, tech --[[@as TechnologyData]~] in pairs(data.raw.technology) do
		local data = getData(tech,mode)
		if(not data) then goto next_tech end

        for _, effect in ipairs(data.effects or {}) do
            if(effect.type == "unlock-recipe") then
                ---@cast effect UnlockRecipeModifierPrototype
                local list = TechnologyIndex.effectsUnlockRecipe[effect.recipe] or {}
                if(#list==0) then TechnologyIndex.effectsUnlockRecipe[effect.recipe] = list end
                table.insert(list, tech.name)
            end
        end

        for _, ingredient in ipairs(data.unit.ingredients or {}) do
            if((ingredient[2] or 0)>0) then
                local list = TechnologyIndex.ingredients[ingredient[1] ] or {}
                if(#list==0) then TechnologyIndex.ingredients[ingredient[1] ] = list end
                table.insert(list, tech.name)
            end
        end

        for _, prerequisite in ipairs(data.prerequisites or {}) do
            local list = TechnologyIndex.prerequisites[prerequisite] or {}
            if(#list==0) then TechnologyIndex.prerequisites[prerequisite] = list end
            table.insert(list, tech.name)
        end
		::next_tech::
    end
end
--]]

---Builds the technology index
local function build()
    TechnologyIndex["normal"].effectsUnlockRecipe = {}
    TechnologyIndex["normal"].ingredients = {}
    TechnologyIndex["normal"].prerequisites = {}

    for _, tech --[[@as TechnologyData]] in pairs(data.raw.technology) do
		local data = tech
		if(not data) then goto next_tech end

        for _, effect in ipairs(data.effects or {}) do
            if(effect.type == "unlock-recipe") then
                local list = TechnologyIndex.effectsUnlockRecipe[effect.recipe] or {}
                if(#list==0) then TechnologyIndex.effectsUnlockRecipe[effect.recipe] = list end
                table.insert(list, tech.name)
            end
        end

		if(data.unit) then
			for _, ingredient in ipairs(data.unit.ingredients or {}) do
				if((ingredient[2] or 0)>0) then
					local list = TechnologyIndex.ingredients[ingredient[1] ] or {}
					if(#list==0) then TechnologyIndex.ingredients[ingredient[1] ] = list end
					table.insert(list, tech.name)
				end
			end
		end

        for _, prerequisite in ipairs(data.prerequisites or {}) do
            local list = TechnologyIndex.prerequisites[prerequisite] or {}
            if(#list==0) then TechnologyIndex.prerequisites[prerequisite] = list end
            table.insert(list, tech.name)
        end
		::next_tech::
    end
end

---Builds the technology index
---@return KuxCoreLib.TechnologyIndex
function TechnologyIndex.build()
    ---@diagnostic disable-next-line: redundant-parameter
	if isV1 then build("normal") build("expensive")
	else build() end
    return TechnologyIndex
end

---------------------------------------------------------------------------------------------------

function TechnologyIndex.asGlobal() return KuxCoreLib.__classUtils.asGlobal(TechnologyIndex) end

TechnologyIndex.build()

return TechnologyIndex