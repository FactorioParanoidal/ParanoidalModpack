require "arrays"
require "mathhelper"
require "strings"

--[[
local CAMPAIGN_ONLY = {
	"basic-mining",
	"basic-electronics",
	"basic-mapping",
	"electric-inserter",
	"basic-logistics",
	"analyse-ship",
	"basic-optics",
	"basic-military",
	"electric-mining",
	"active-defense",
	"repair-tech",
	"passive-defense",
	"improved-equipment",
	"demo-science-pack",
	"demo-logistics",
	"demo-productivity-1",
	"demo-shooting-speed-1",
}
--]]

function techHasDependencyRecursive(tech, dep, recurse, depth, path, root)
	if not root then root = tech.name end
	if not depth then depth = 0 end
	if not path then path = {} end
	if listHasValue(path, tech.name) then log("Found a tech recursion loop while checking " .. root .. " for " .. dep .. ", entering " .. tech.name .. ": " .. serpent.block(path)) return true end
	table.insert(path, tech.name)
	--if not recurse then log("Checking recursive deps of " .. tech.name .. " for " .. dep .. "; has [" .. serpent.block(tech.prerequisites)) end
	--log("path is " .. serpent.block(path))
	if not tech.prerequisites then return false end
	for _,pre in pairs(tech.prerequisites) do
		--log(depth .. " calls deep; Checking dep " .. pre .. " for " .. tech.name)
		if pre == dep then
			return true
		end
		if techHasDependencyRecursive(data.raw.technology[pre], dep, true, depth+1, path, root) then
			return true
		end
	end
	table.remove(path)
	return false
end

function techUsesPack(tech, pack)
	for _,ing in pairs(tech.unit.ingredients) do
		if ing[1] == pack then
			return true
		end
	end
	return false
end

function addTechUnlock(tech, recipe)
	if type(tech) == "string" then
		tech = data.raw.technology[tech]
	end
	if not tech then error(serpent.block("No such technology found! " .. debug.traceback())) end
	if not tech.effects then tech.effects = {} end
	table.insert(tech.effects, {type = "unlock-recipe", recipe = recipe})
end

function removeTechUnlock(tech, recipe)
	if type(tech) == "string" then
		tech = data.raw.technology[tech]
	end
	if not tech then error(serpent.block("No such technology found! " .. debug.traceback())) end
	if not tech.effects then return end
	for i,eff in ipairs(tech.effects) do
		if eff.type == "unlock-recipe" and eff.recipe == recipe then
			table.remove(tech.effects, i)
			break
		end
	end
end

--THIS IS NO LONGER A THING AS OF 0.18'S REVERSION TO THE CAMPAIGN
function isCampaignOnlyTech(tech)
	--[[
	if type(tech) == "string" then
		tech = data.raw.technology[tech]
	end
	if not tech then error(serpent.block("No such technology found! " .. debug.traceback())) end
	return not tech.enabled--listHasValue(CAMPAIGN_ONLY, tech.name)
	--]]
	return false
end

function getPrereqTechForPack(pack)
	local tech = data.raw.technology[pack]
	if pack == "automation-science-pack" and mods["EarlyExtensions"] then
		--tech = data.raw.technology["basic-science"] --EE compat
		return "basic-science"
	end
	return tech and tech.name or nil
end

function addPrereqToTech(tech, prereq)
	if type(tech) == "string" then tech = data.raw.technology[tech] end
	--if not tech then error("Tech does not exist!") end
	if not tech then return end
	if not tech.prerequisites then tech.prerequisites = {} end
	table.insert(tech.prerequisites, prereq)
end

function splitTech(tech, prereqs, recipesToMove)
	local base = data.raw.technology[tech]
	local tech2 = table.deepcopy(base)
	local a, b = string.find(tech, "-", 1, true)
	local number = b and tonumber(string.sub(tech, b+1)) or nil
	--error("Number " .. number .. " from " .. tech)
	tech2.name = number and (tech .. "-" .. (number+1)) or (tech .. "-2")
	log("Split " .. tech2.name .. " from " .. tech)
	tech2.prerequisites = prereqs
	table.insert(prereqs, tech)
	tech2.effects = {}
	for _,recipe in pairs(recipesToMove) do
		table.insert(tech2.effects, {type = "unlock-recipe", recipe = recipe})
	end
	--for k,v in pairs(recipesToMove) do log(v) end
	local keep = {}
	for _,effect in pairs(base.effects) do
		--log("Checking if list has " .. effect.recipe)
		if effect.type == "unlock-recipe" and listHasValue(recipesToMove, effect.recipe) then
			
		else
			table.insert(keep, effect)
		end
	end
	base.effects = keep
	data:extend({tech2})
end

function removeSciencePackFromTech(techname, pack)
	local tech = data.raw.technology[techname]
	if not tech then return end
	removeEntryFromListIf(tech.unit.ingredients, function(entry) return entry[1] == pack end)
	local prereq = getPrereqTechForPack(pack)
	if prereq and data.raw.technology[prereq] then
		removeEntryFromList(tech.prerequisites, prereq)
	end
	log("Removed science pack " .. pack .. " from tech " .. tech.name)
end

function addSciencePackToTech(techname, pack)
	local tech = data.raw.technology[techname]
	if not tech then return end
	if techUsesPack(tech, pack) then return end
	local prereq = getPrereqTechForPack(pack)
	if prereq and data.raw.technology[prereq] and not listHasValue(tech.prerequisites, prereq) then
		table.insert(tech.prerequisites, prereq)
	end
	table.insert(tech.unit.ingredients, {pack, 1})
	log("Added science pack " .. pack .. " to tech " .. tech.name)
end

function replaceTechPrereq(tech, old, new)
	if type(tech) == "string" then tech = data.raw.technology[tech] end
	if not tech then error(serpent.block("No such technology found! " .. debug.traceback())) end
	local repl = {}
	local flag = false
	for _,prereq in pairs (tech.prerequisites) do
		if prereq == old then
			table.insert(repl, new)
			flag = true
		else
			table.insert(repl, prereq)
		end
	end
	tech.prerequisites = repl
	log("Replaced prerequisite " .. old .. " with " .. new .. " in tech '" .. tech.name .. "'")
	return flag
end

function replaceTechPack(tech, old, new, factor)
	local f = factor and factor or 1
	if type(tech) == "string" then tech = data.raw.technology[tech] end
	if not tech then error(serpent.block("No such technology found! " .. debug.traceback())) end
	local repl = {}
	local flag = false
	for _,pack in pairs (tech.unit.ingredients) do
		if pack[1] == old then
			table.insert(repl, {new, math.floor(pack[2]*f)})
			flag = true
		else
			table.insert(repl, pack)
		end
	end
	tech.unit.ingredients = repl
	log("Replaced science pack " .. old .. " with " .. new .. " in tech '" .. tech.name .. "'")
	return flag
end

function tryFindTechUnlocking(proto)
	for name,tech in pairs(data.raw.technology) do
		if tech.effects then
			for _,eff in pairs(tech.effects) do
				if eff.type == "unlock-recipe" then
					local rec = data.raw.recipe[eff.recipe]
					if rec and not (string.find(rec.name, "barrel", 1, true) or string.find(rec.name, "canister", 1, true)) then
						if rec.result and rec.result.name and rec.result.name == proto.name then
							return tech
						elseif rec.results then
							for _,out in pairs(rec.results) do
								if out and out.name and out.type and out.type == proto.type and out.name == proto.name then
									return tech
								end
							end
						end
					end
				end
			end
		end
	end
	return nil
end