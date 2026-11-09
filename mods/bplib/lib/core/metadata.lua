--------------------------------------------------------------------------------
-- Reusable Metadata about Factorio entities, etc.
--------------------------------------------------------------------------------

local lib = {}

---Prototype-types that use build-grid 2
---@type {[string]: true}
local build_grid_2_types = {
	["curved-rail-a"] = true,
	["curved-rail-b"] = true,
	["straight-rail"] = true,
	["half-diagonal-rail"] = true,
	["train-stop"] = true,
	["rail-support"] = true,
	["rail-ramp"] = true,
	["cargo-bay"] = true,
	["cargo-landing-pad"] = true,
}
lib.build_grid_2_types = build_grid_2_types

---Prototype-types that can use mirroring bit in their orientation.
---Note that `use_mirroring` has to be checked in addition to this to
---determine if a specific prototype-name uses mirroring.
---@type {[string]: true}
local mirroring_possible_types = {
	["assembling-machine"] = true,
	["furnace"] = true,
	["rocket-silo"] = true,
	["inserter"] = true,
	["mining-drill"] = true,
}
lib.mirroring_possible_types = mirroring_possible_types

---Prototype-types that have "two-direction-only" fields in their type.
---@type {[string]: true}
local two_direction_only_types = {
	["storage-tank"] = true,
	["fusion-reactor"] = true,
	["generator"] = true,
}
lib.two_direction_only_types = two_direction_only_types

---Prototype-types that can connect to the circuit network
---@type {[string]: true}
local circuit_network_types = {
	["accumulator"] = true,
	["agricultural-tower"] = true,
	["ammo-turret"] = true,
	["arithmetic-combinator"] = true,
	["artillery-turret"] = true,
	["assembling-machine"] = true,
	["asteroid-collector"] = true,
	["boiler"] = true,
	["cargo-landing-pad"] = true,
	["constant-combinator"] = true,
	["container"] = true,
	["decider-combinator"] = true,
	["display-panel"] = true,
	["electric-pole"] = true,
	["electric-turret"] = true,
	["furnace"] = true,
	["heat-pipe"] = true,
	["infinity-container"] = true,
	["infinity-pipe"] = true,
	["inserter"] = true,
	["lab"] = true,
	["lamp"] = true,
	["land-mine"] = true,
	["linked-container"] = true,
	["loader-1x1"] = true,
	["loader"] = true,
	["logistic-container"] = true,
	["mining-drill"] = true,
	["offshore-pump"] = true,
	["pipe"] = true,
	["pipe-to-ground"] = true,
	["power-switch"] = true,
	["programmable-speaker"] = true,
	["proxy-container"] = true,
	["pump"] = true,
	["radar"] = true,
	["rail-chain-signal"] = true,
	["rail-signal"] = true,
	["roboport"] = true,
	["rocket-silo"] = true,
	["selector-combinator"] = true,
	["space-platform-hub"] = true,
	["splitter"] = true,
	["storage-tank"] = true,
	["temporary-container"] = true,
	["train-stop"] = true,
	["transport-belt"] = true,
	["turret"] = true,
}
lib.circuit_network_types = circuit_network_types

---Determine if a prototype-type can connect to the circuit network.
---@param ty string
function lib.type_can_connect_to_circuit_network(ty)
	return not not circuit_network_types[ty]
end

---@param name string Prototype name of the entity.
function lib.can_connect_to_circuit_network(name)
	local prototype = prototypes.entity[name]
	if not prototype then return false end
	if circuit_network_types[prototype.type] then return true end
	return prototype.get_max_circuit_wire_distance() > 0
end

return lib
