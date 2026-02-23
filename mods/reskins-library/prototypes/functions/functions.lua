-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Library directory
reskins.lib.directory = "__reskins-library__"

--- Searches through a nested table based on a sequence of keys and returns the final value.
---
--- This function takes a root table and a series of keys, then attempts to locate the value
--- at the nested position defined by the keys. If any key in the sequence does not exist or the
--- current value is not a table during traversal, the function returns `nil`.
---
--- This mimics the behavior of the null-conditional operator in C#, safely accessing deeply nested properties.
---
--- @param root table The table from which to begin the search.
--- @param ... string|integer A list of keys defining the path to traverse within the root table.
--- @return any #The value at the end of the key sequence if it exists; otherwise, `nil`.
local function try_get_value(root, ...)
	for i = 1, select("#", ...) do
		if type(root) ~= "table" then
			return nil
		end
		local key = select(i, ...)
		root = root[key]
		if root == nil then
			return nil
		end
	end

	return root
end

---@class SetupStandardEntityInputs : ParseInputsInputs, CreateExplosionsAndParticlesInputs, CreateRemnantInputs, ConstructIconInputsOld

---Most entities have a common process for reskinning, so consolidate the other functions under one superfunction for ease of use
---@param name string # The name of the entity prototype to be reskinned.
---@param tier integer # The tier of the entity. An integer value from 0 to 6. Default `0`.
---@param inputs SetupStandardEntityInputs
function reskins.lib.setup_standard_entity(name, tier, inputs)
	-- Parse inputs
	reskins.lib.set_inputs_defaults(inputs)

	-- Create particles and explosions
	if inputs.make_explosions then
		reskins.lib.create_explosions_and_particles(name, inputs)
	end

	-- Create remnants
	if inputs.make_remnants then
		reskins.lib.create_remnant(name, inputs)
	end

	-- Create icons
	if inputs.make_icons then
		reskins.lib.construct_icon(name, tier, inputs)
	end
end

---@class ParseInputsInputs
---@field icon_size? data.SpriteSizeType # Default `64`.
---@field technology_icon_size? data.SpriteSizeType # Default `128`.
---@field make_explosions? boolean # Default `true`, creates explosions in `standard_setup_entity`.
---@field make_remnants? boolean # Default `true`, creates corpses in `standard_setup_entity`.
---@field make_icons? boolean # Default `true`, create icons in `standard_setup_entity`.
---@field tier_labels? boolean # Default `true`, displays tier labels on icons.
---@field make_icon_pictures? boolean # Default `true`, creates pictures for item-on-ground icons.

---Adds missing default values to the given `inputs` table.
---@param inputs ParseInputsInputs
---@return ParseInputsInputs inputs
---```lua
--- inputs = {
---     icon_size = 64,
---     technology_icon_size = 128,
---     make_explosions = true,
---     make_remnants = true,
---     make_icons = true,
---     tier_labels = true,
---     make_icon_pictures = true,
--- }
---```
function reskins.lib.set_inputs_defaults(inputs)
	inputs.icon_size = inputs.icon_size or 64
	inputs.technology_icon_size = inputs.technology_icon_size or 128
	inputs.make_explosions = (inputs.make_explosions ~= false)
	inputs.make_remnants = (inputs.make_remnants ~= false)
	inputs.make_icons = (inputs.make_icons ~= false)
	inputs.tier_labels = (inputs.tier_labels ~= false)
	inputs.make_icon_pictures = (inputs.make_icon_pictures ~= false)

	return inputs
end

---Assigns a consistent `order` property to a given entity prototype and the associated items, explosions, and remnants if they exist
---@param name string
---@param inputs AssignOrderInputs
function reskins.lib.assign_order(name, inputs)
	-- Initialize paths
	local entity
	if inputs.type then
		entity = data.raw[inputs.type][name]
	end
	local item = data.raw["item"][name]
	local explosion = data.raw["explosion"][name .. "-explosion"]
	local remnant = data.raw["corpse"][name .. "-remnants"]

	if entity then
		entity.order = inputs.sort_order
		entity.group = inputs.sort_group
		entity.subgroup = inputs.sort_subgroup
	end

	if item then
		item.order = inputs.sort_order
		-- item.group = inputs.sort_group
		item.subgroup = inputs.sort_subgroup
	end

	if explosion then
		explosion.order = inputs.sort_order
		-- explosion.group = inputs.sort_group
		explosion.subgroup = inputs.sort_subgroup
	end

	if remnant then
		remnant.order = inputs.sort_order
		-- remnant.group = inputs.sort_group
		remnant.subgroup = inputs.sort_subgroup
	end
end

---@class CreateRemnantInputs
---@field base_entity_name string # The type name of the entity to copy an existing `CorpsePrototype` from.
---@field type string # The type name of the entity to be assigned the new `CorpsePrototype`.

---@class remnant # See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse)

---Copies the Factorio corpse specified by `inputs.base_entity_name`, extends `data` with a new
---corpse with the name `[name]-remnants`, and assigns it to the named entity
---@param name string
---@param inputs CreateRemnantInputs
---```
--- inputs = {
---     base_entity_name = string -- Name of Factorio reference entity to copy from, e.g. `stone-furnace`
---     type = string -- See https://wiki.factorio.com/Prototype_definitions
--- }
---```
function reskins.lib.create_remnant(name, inputs)
	---@type data.CorpsePrototype
	local remnant = util.copy(data.raw["corpse"][inputs.base_entity_name .. "-remnants"])
	remnant.name = name .. "-remnants"
	data:extend({ remnant })

	-- Assign corpse to originating entity
	data.raw[inputs.type][name]["corpse"] = remnant.name
end

---@class CreateExplosionInputs : CreateRemnantInputs

---Copies the Factorio explosion specified by `inputs.base_entity_name`, extends `data` with a new
---explosion with the name `ar-[name]-explosion`, and assigns it to the named entity
---@param name string
---@param inputs CreateExplosionInputs
---```
--- inputs = {
---     base_entity_name = string -- Name of Factorio reference entity to copy from, e.g. `stone-furnace`
---     type = string -- See https://wiki.factorio.com/Prototype_definitions
--- }
---```
function reskins.lib.create_explosion(name, inputs)
	local explosion_copy = util.copy(data.raw["explosion"][inputs.base_entity_name .. "-explosion"])
	explosion_copy.name = "ar-" .. name .. "-explosion"
	data:extend({ explosion_copy })

	-- Assign explosion to originating entity
	data.raw[inputs.type][name]["dying_explosion"] = explosion_copy.name
end

---Gets the preferred explosion for a given `explosion`, preferring the indirect base explosion, if it exists.
---@param explosion data.ExplosionPrototype The explosion to check for a base explosion.
---@return data.ExplosionPrototype
local function get_preferred_explosion(explosion)
	-- Several entities have a redirection to a base explosion entity, so we need to check for that and use it
	-- preferentially.

	---@type data.TriggerEffect[]|nil
	local target_effects = try_get_value(explosion, "created_effect", "action_delivery", "target_effects")

	if not target_effects or #target_effects == 0 then
		return explosion
	end

	if target_effects[1].type == "create-explosion" then
		-- Copy the explosion reference and update our explosion, if it doesn't already exist, as we may visit the same
		-- explosion multiple times.
		local explosion_base_name = target_effects[1].entity_name

		local base_explosion = data.raw["explosion"][explosion_base_name]
		if base_explosion.name:find("ar-", 1, true) then
			return base_explosion
		end

		base_explosion = util.copy(data.raw["explosion"][explosion_base_name])
		base_explosion.name = "ar-" .. explosion.name .. "-base"
		data:extend({ base_explosion })

		-- Update the explosion reference name.
		target_effects[1].entity_name = base_explosion.name
		return base_explosion
	end

	return explosion
end

---A map of particle names to particle exclusions to prevent false positives.
local particle_exclusions_map = {
	["metal-particle-medium"] = {
		"long-metal-particle-medium",
	},
}

---Checks if the given `particle_name` is a match for the `base_particle_name`, excepting any exclusions.
---@param particle_name data.ParticleID The particle name to check.
---@param base_particle_name string The base particle name to check against.
---@return boolean # `true` if the particle name is a match for the base particle name, otherwise `false`.
local function is_particle_name_intended_match(particle_name, base_particle_name)
	if particle_name:find(base_particle_name, 1, true) then
		local exclusions = particle_exclusions_map[base_particle_name]
		if exclusions then
			for _, exclusion in pairs(exclusions) do
				if particle_name:find(exclusion, 1, true) then
					return false
				end
			end
		end

		return true
	end

	return false
end

---Gets the preferred particle by checking for a particle name in `particle_effects` that contains the given
---`base_particle_name`. The method will preferentially select the particle at the index matching `key`, if it exists.
---Otherwise, the method will select the first particle that matches the `base_particle_name`.
---@param particle_effects data.CreateParticleTriggerEffectItem[] The particle effects to search through.
---@param base_particle_name string The base particle name to search for.
---@param key integer The key to preferentially select, if it exists.
---@return data.CreateParticleTriggerEffectItem|nil # The preferred particle effect, or `nil` if none are found.
local function get_preferred_particle(particle_effects, base_particle_name, key)
	local preferred_particle
	local fallback_particle
	for index, effect in pairs(particle_effects) do
		if is_particle_name_intended_match(effect.particle_name, base_particle_name) then
			if index == key then
				preferred_particle = effect
				break
			elseif not fallback_particle then
				fallback_particle = effect
			end
		end
	end

	return preferred_particle or fallback_particle
end

---Links a given `explosion` to the given `particle` by checking for particle effects in the explosion's target effects
---that match the `base_particle_name`. The method will preferentially select the particle at the index matching `key`,
---if it exists. Otherwise, the method will select the first particle that matches the `base_particle_name` to establish
---the link.
---@param explosion data.ExplosionPrototype The explosion to link the particle to.
---@param particle data.ParticlePrototype The particle to link to the explosion.
---@param base_particle_name string The base particle name to search for.
---@param key integer The key to preferentially select, if it exists.
local function link_particle_to_explosion(explosion, particle, base_particle_name, key)
	local target_effects = try_get_value(explosion, "created_effect", "action_delivery", "target_effects")
	if not target_effects or #target_effects == 0 then
		return
	end

	-- Filter target_effects for all particle effects.
	local particle_effects = {}
	for _, effect in pairs(target_effects) do
		if effect.type == "create-particle" then
			table.insert(particle_effects, effect)
		end
	end

	if #particle_effects > 0 then
		local particle_effect = get_preferred_particle(particle_effects, base_particle_name, key)

		if particle_effect then
			particle_effect.particle_name = particle.name
		end
	end
end

---Copies the Factorio particle specified by `base_entity_name`, applies tints, extends `data`
---with a new particle with the name `[name]-[base-particle-name]-tinted`, and links it to the named explosion
---@param name data.EntityID The name of the entity prototype for which an AR explosion exists.
---@param base_entity_name data.EntityID Name of Factorio reference entity to copy from, e.g. `stone-furnace`
---@param base_particle_name string A value from `reskins.lib.particle_index` used to find the particle to copy.
---@param key integer Index corresponding to the particle within the explosion target_effects table.
---@param tint data.Color The tint to apply to the particle.
function reskins.lib.create_particle(name, base_entity_name, base_particle_name, key, tint)
	local particle = util.copy(data.raw["optimized-particle"][base_entity_name .. "-" .. base_particle_name])

	particle.name = "ar-" .. name .. "-" .. base_particle_name .. "-tinted"
	particle.pictures.sheet.tint = tint

	data:extend({ particle })

	local explosion = data.raw["explosion"]["ar-" .. name .. "-explosion"]
	if not explosion then
		return
	else
		local preferred_explosion = get_preferred_explosion(explosion)
		link_particle_to_explosion(preferred_explosion, particle, base_particle_name, key)
	end
end

---@class CreateExplosionsAndParticlesInputs : CreateExplosionInputs
---@field particles? table # Table of keys for `reskins.lib.particle_index` and the target index within the explosion particle table to copy
---@field tint table # [Types/Color](https://wiki.factorio.com/Types/Color)

---Batches the `create_explosion` and `create_particle` function together for ease of use
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param inputs CreateExplosionsAndParticlesInputs @
---```
--- inputs = {
---     base_entity_name = string -- Name of Factorio reference entity to copy from, e.g. `stone-furnace`
---     type = string -- See https://wiki.factorio.com/Prototype_definitions
---     tint = table -- See https://wiki.factorio.com/Types/Color
---     particles? = {
---         [string] = integer, -- reskins.lib.particle_index key, and associated target particle index
---         ...
---     }
--- }
---```
function reskins.lib.create_explosions_and_particles(name, inputs)
	reskins.lib.create_explosion(name, inputs)

	if inputs.particles then
		for particle, key in pairs(inputs.particles) do
			-- Create and assign the particle
			reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index[particle], key, inputs.tint)
		end
	end
end

reskins.lib.particle_index = {
	["tiny-stone"] = "stone-particle-tiny",
	["small"] = "metal-particle-small",
	["small-stone"] = "stone-particle-small",
	["medium"] = "metal-particle-medium",
	["medium-long"] = "long-metal-particle-medium",
	["medium-stone"] = "stone-particle-medium",
	["big"] = "metal-particle-big",
	["big-stone"] = "stone-particle-big",
	["big-tint"] = "metal-particle-big-tint",
}
