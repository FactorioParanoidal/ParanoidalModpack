-- Copyright (C) 2022  veden

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

if constantsG then
	return constantsG
end

local mMin = math.min
local mMax = math.max

local constants = {}

constants.ALL_ENTITY_TYPES = {
	"accumulator",
	"ammo-turret",
	"artillery-turret",
	"assembling-machine",
	"beacon",
	"boiler",
	"electric-pole",
	"electric-turret",
	"fluid-turret",
	"furnace",
	"generator",
	"inserter",
	"lab",
	"lamp",
	"mining-drill",
	"offshore-pump",
	"pump",
	"radar",
	"reactor",
	"roboport",
	"rocket-silo",
	"solar-panel",
}
constants.ENTITES_WITHOUT_DOWNTIME = {
	["solar-panel"] = true,
	["lamp"] = true,
	["electric-pole"] = true,
	["accumulator"] = true,
}

constants.RESEARCH_LOOKUP = {}
for i = 1, 9 do
	constants.RESEARCH_LOOKUP["rampant-maintenance-reduce-failure-" .. i] = "failure"
	constants.RESEARCH_LOOKUP["rampant-maintenance-reduce-damage-" .. i] = "damage"
	constants.RESEARCH_LOOKUP["rampant-maintenance-reduce-damage-failure-" .. i] = "damage-failure"
	constants.RESEARCH_LOOKUP["rampant-maintenance-reduce-downtime-" .. i] = "downtime"
	constants.RESEARCH_LOOKUP["rampant-maintenance-reduce-checks-" .. i] = "cooldown"
	constants.RESEARCH_LOOKUP["rampant-maintenance-reduce-tile-" .. i] = "tile"
	constants.RESEARCH_LOOKUP["rampant-maintenance-reduce-pollution-" .. i] = "pollution"
	constants.RESEARCH_LOOKUP["rampant-maintenance-reduce-energy-" .. i] = "energy"
end

constants.POPUP_TTL = 60 * 5
constants.TICKS_PER_MINUTE = 60 * 60
constants.TICKS_PER_HOUR = constants.TICKS_PER_MINUTE * 60
constants.TICKS_PER_FIVE_HOURS = constants.TICKS_PER_MINUTE * 60 * 5

constants.TERRAIN_MODIFIERS = {
	{ "reinforced", -0.35 },
	{ "refined", -0.3 },
	{ "marking", -0.3 },
	{ "asphalt", -0.3 },
	{ "concrete", -0.2 },
	{ "stone", -0.1 },
	{ "grass", 0 },
	{ "landfill", 0.1 },
	{ "dirt", 0.1 },
	{ "snow", 0.2 },
	{ "volcanic", 0.2 },
	{ "desert", 0.3 },
	{ "sand", 0.3 },
	{ "nuclear", 0.3 },
}

constants.POLLUTION_TO_PERCENTAGE = 1 / 2000

function constants.roundToNearest(number, multiple)
	local num = number + (multiple * 0.5)
	return num - (num % multiple)
end

function constants.getResearch(forceName, world, typeName)
	local researches = world.forceResearched[forceName]
	if typeName == "tile" or typeName == "energy" then
		return (researches and researches[typeName]) or 0
	else
		return (researches and researches[typeName]) or 1
	end
end

function constants.calculateLowFailure(world, entityRecord, invertedHealthPercent)
	local entity = entityRecord.e
	local entityType = entity.type
	local entityForceName = entity.force.name
	local buildFailure = world.buildFailure[entityType]
	local buildDamageFailure = world.buildDamageFailure[entityType]
	local failureChance = (buildFailure.low * constants.getResearch(entityForceName, world, "failure"))
	local damageFailureChance = (buildDamageFailure.low * invertedHealthPercent)
		* constants.getResearch(entityForceName, world, "damage-failure")
	local pollutionModifier = (
		1
		+ (
			mMin(
				entity.surface.get_pollution(entity.position) * constants.POLLUTION_TO_PERCENTAGE,
				entityRecord.p * constants.getResearch(entityForceName, world, "pollution")
			)
		)
	)
	local tileModifier = (
		1 + (entityRecord.t + entityRecord.tM + constants.getResearch(entityForceName, world, "tile"))
	)
	return (failureChance + damageFailureChance) * pollutionModifier * tileModifier
end

function constants.calculateHighFailure(world, entityRecord, invertedHealthPercent)
	local entity = entityRecord.e
	local entityType = entity.type
	local entityForceName = entity.force.name
	local buildFailure = world.buildFailure[entityType]
	local buildDamageFailure = world.buildDamageFailure[entityType]
	local failureChance = (
		(buildFailure.low + buildFailure.range) * constants.getResearch(entityForceName, world, "failure")
	)
	local damageFailureChance = ((buildDamageFailure.low + buildDamageFailure.range) * invertedHealthPercent)
		* constants.getResearch(entityForceName, world, "damage-failure")
	local pollutionModifier = (
		1
		+ (
			mMin(
				entity.surface.get_pollution(entity.position) * constants.POLLUTION_TO_PERCENTAGE,
				entityRecord.p * constants.getResearch(entityForceName, world, "pollution")
			)
		)
	)
	local tileModifier = (
		1 + (entityRecord.t + entityRecord.tM + constants.getResearch(entityForceName, world, "tile"))
	)
	return (failureChance + damageFailureChance) * pollutionModifier * tileModifier
end

function constants.calculateLowCooldown(world, entityRecord, healthPercent)
	local entity = entityRecord.e
	local cooldowns = world.buildCooldown[entity.type]
	local cooldown = mMax(0.2, healthPercent) * cooldowns.low
	return cooldown * (1 + constants.getResearch(entity.force.name, world, "cooldown"))
end

function constants.calculateHighCooldown(world, entityRecord, healthPercent)
	local entity = entityRecord.e
	local cooldowns = world.buildCooldown[entity.type]
	local cooldown = mMax(0.2, healthPercent) * (cooldowns.low + cooldowns.range)
	return cooldown * (1 + constants.getResearch(entity.force.name, world, "cooldown"))
end

function constants.calculateLowDowntime(world, entityRecord, invertedHealthPercent)
	local entity = entityRecord.e
	local entityForceName = entity.force.name
	local downtimes = world.buildDowntime[entity.type]
	if not downtimes then
		return 0
	end
	local downtime = (downtimes.low * mMax(1, 1 + invertedHealthPercent))
		* constants.getResearch(entityForceName, world, "downtime")
	local tileModifier = (
		1 + (entityRecord.t + entityRecord.tM + constants.getResearch(entityForceName, world, "tile"))
	)
	local pollutionModifier = (
		1
		+ (
			mMin(
				entity.surface.get_pollution(entity.position) * constants.POLLUTION_TO_PERCENTAGE,
				entityRecord.p * constants.getResearch(entityForceName, world, "pollution")
			)
		)
	)
	return downtime * tileModifier * pollutionModifier
end

function constants.calculateHighDowntime(world, entityRecord, invertedHealthPercent)
	local entity = entityRecord.e
	local entityForceName = entity.force.name
	local downtimes = world.buildDowntime[entity.type]
	if not downtimes then
		return 0
	end
	local downtime = ((downtimes.low + downtimes.range) * mMax(1, 1 + invertedHealthPercent))
		* constants.getResearch(entityForceName, world, "downtime")
	local tileModifier = (
		1 + (entityRecord.t + entityRecord.tM + constants.getResearch(entityForceName, world, "tile"))
	)
	local pollutionModifier = (
		1
		+ (
			mMin(
				entity.surface.get_pollution(entity.position) * constants.POLLUTION_TO_PERCENTAGE,
				entityRecord.p * constants.getResearch(entityForceName, world, "pollution")
			)
		)
	)
	return downtime * tileModifier * pollutionModifier
end

function constants.calculateLowDamage(world, entityRecord, invertedHealthPercent)
	local entity = entityRecord.e
	local entityForceName = entity.force.name
	local damages = world.buildDamage[entity.type]
	local damage = damages.low * constants.getResearch(entityForceName, world, "damage")
	local tileModifier = (
		1 + (entityRecord.t + entityRecord.tM + constants.getResearch(entityForceName, world, "tile"))
	)
	local pollutionModifier = (
		1
		+ (
			mMin(
				entity.surface.get_pollution(entity.position) * constants.POLLUTION_TO_PERCENTAGE,
				entityRecord.p * constants.getResearch(entityForceName, world, "pollution")
			)
		)
	)
	return (damage + (damage * invertedHealthPercent)) * tileModifier * pollutionModifier
end

function constants.calculateHighDamage(world, entityRecord, invertedHealthPercent)
	local entity = entityRecord.e
	local entityForceName = entity.force.name
	local damages = world.buildDamage[entity.type]
	local damage = (damages.low + damages.range) * constants.getResearch(entityForceName, world, "damage")
	local tileModifier = (
		1 + (entityRecord.t + entityRecord.tM + constants.getResearch(entityForceName, world, "tile"))
	)
	local pollutionModifier = (
		1
		+ (
			mMin(
				entity.surface.get_pollution(entity.position) * constants.POLLUTION_TO_PERCENTAGE,
				entityRecord.p * constants.getResearch(entityForceName, world, "pollution")
			)
		)
	)
	return (damage + (damage * invertedHealthPercent)) * tileModifier * pollutionModifier
end

constantsG = constants
return constantsG
