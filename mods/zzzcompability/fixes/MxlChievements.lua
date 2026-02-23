local Assert = require("utils.assert")
-- MxlChievements refers to older item names so there i fix it

local function FixAcheveItemNameMismatch(achieveName, oldEntityName, newEntityName)
	local achieve = data.raw["produce-achievement"][achieveName]
	Assert.AssertOutdated(achieve ~= nil, "Achieve to fix no exists")
	Assert.AssertOutdated(
		achieve.item_product == oldEntityName or achieve.fluid_product == oldEntityName,
		"Old item name not match"
	)
	Assert.AssertOutdated(
		data.raw.item[newEntityName] ~= nil or data.raw.fluid[newEntityName] ~= nil,
		"Item or fluid with new name not exists"
	)
	if achieve.item_product == oldEntityName then
		achieve.item_product = newEntityName
	end
	if achieve.fluid_product == oldEntityName then
		achieve.fluid_product = newEntityName
	end
end


local function TryFindWithPrefix(section, name, prefixes)
	Assert.Expected(type(name) == "string", "string", name)
	Assert.Expected(type(prefixes) == "table", "table", prefixes)

	if data.raw[section][name] then
		return name
	end
	for _, prefix in ipairs(prefixes) do
		Assert.Expected(type(prefix) == "string", "string", prefix)
		if data.raw[section][prefix .. name] then
			return prefix .. name
		end
	end
	return nil
end

local prefixes = {
	"bob-",
	"angels-",
}

local function GetAchieveProductName(achieve)
	Assert.Expected(type(achieve) == "table", "table", achieve)
	if achieve.fluid_product then
		return achieve.fluid_product
	end
	if type(achieve.item_product) == "string" then
		return achieve.item_product
	end
	return achieve.item_product.name
end

local function TryFixAchievementsByPrefixes()
	for name, achieve in pairs(data.raw["produce-achievement"]) do
		local productType = achieve.item_product and "item" or "fluid"
		local oldName = GetAchieveProductName(achieve)
		local newName = TryFindWithPrefix(productType, oldName, prefixes)
		if newName == nil then
			log("Failed to fix: " .. name .. " achievement. Undefined item name: " .. oldName)
			goto continue
		end
		if oldName == newName then
			goto continue
		end
		if productType == "fluid" then
			achieve.fluid_product = newName
		elseif achieve.item_product.name then
			achieve.item_product.name = newName
		else
			achieve.item_product = newName
		end
		log("In achievement: " .. name .. " substitution: " .. oldName .. " -> " .. newName)
	    ::continue::
	end
end

local function FixMxlChievements()
	for lvl = 1, 3 do
		FixAcheveItemNameMismatch("stack-inserter-" .. tostring(lvl), "stack-inserter", "bulk-inserter")
		FixAcheveItemNameMismatch(
			"turbo-transport-belt-" .. tostring(lvl),
			"bob-turbo-transport-belt",
			"bob-turbo-transport-belt"
		)
	end
end

FixMxlChievements()
TryFixAchievementsByPrefixes()
