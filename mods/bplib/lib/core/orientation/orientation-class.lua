-- Ways in which Factorio entities can be oriented in the world.
-- This includes their possible directions and how they transform under
-- rotation and flipping.

local dihedral = require("lib.core.math.dihedral")
local metadata = require("lib.core.metadata")

local dih_encode = dihedral.encode
local dih_decode = dihedral.decode
local dih_product = dihedral.product
local dih_power = dihedral.power

local lib = {}

---An entity's orientation class specifies which orientations it can occupy
---as well as how it responds to rotation and flipping. Note that orientation
---classes can be somewhat dynamic; for example, assembling machines with
---active fluid recipes have a different orientation class than those without.
---
---Naming convention: `(group)_(symmetry)_(possible transformations)`
---Group: D2, d8 (D8, ignore mirroring), D8 = Full D8 including mirroring, d16 = D16, ignore mirroring
---Symmetry: 0 = vertical (H=s), 1 = first diagonal (H=rs), 2 = horizontal (H=r^2s), 3 = second diagonal (H=r^3s)
---Possible transformations:
--- - `R` = rotate clockwise one notch
--- - `F` = flip
--- - lower case = as above but ONLY while held in cursor
--- - `c` = different behavior while held in cursor compared to placed
---@enum Core.OrientationClass
local OrientationClass = {
	"Unknown",
	"Unsupported",
	"Nil",
	"D2_r",
	"D2_R",
	"D2_1_RF",
	"d8_R",
	"d8_0_rf",
	"d8_0_rF",
	"d8_0_RF",
	"d8_1_RF",
	"d8_2_RF",
	"d8_3_RF",
	"d8_0_RFc",
	"D8_0_RF",
	"D8_1_RF",
	"D8_2_RF",
	"D8_3_RF",
	"D8_0_RFc",
	"D8_0_latent",
	"D8_1_latent",
	"D8_2_latent",
	"D8_3_latent",
	"d16_0_rf",
	"d8_0_latent",

	---Unknown or unregistered entities that can't be classified.
	---Will be treated as OC_0.
	["Unknown"] = 1,

	---Deliberately unsupported entities. Will be treated as OC_0.
	---[all rails/rail signals]
	["Unsupported"] = 2,

	---No flip or rotation possible.
	["Nil"] = 3,

	---North/east only
	---R=s, H=id, V=id
	---[`steam-turbine`]
	["D2_r"] = 4,

	---North/east only
	---R=s, H=id, V=id
	---[`fusion-reactor` with `two_direction_only=true`, ????]
	["D2_R"] = 5,

	---North/east only, diagonal symmetry.
	---R=s, H=s, V=s
	---[storage-tank with `two_direction_only=true`]
	["D2_1_RF"] = 6,

	---NESW, rotations only, no flips.
	---R=r, H=id, V=id
	---[`burner-mining-drill`]
	["d8_R"] = 7,

	---NESW, rotations, flips when equivalent to a rotation, in-hand only
	---[`offshore-pump`]
	["d8_0_rf"] = 8,

	---NESW, rotations, flips when equivalent to a rotation.
	---Rotation in hand only, flips in hand or world.
	---[`gun-turret`]
	["d8_0_rF"] = 9,

	---NESW, rotations, flips only when equivalent to a rotation.
	---Transformation group = D8 / <s>
	---[`simple-entity-with-owner`, all belt, all inserter, `big-mining-drill`]
	["d8_0_RF"] = 10,
	["d8_1_RF"] = 11,
	["d8_2_RF"] = 12,
	["d8_3_RF"] = 13,

	---NESW, rotations, flips only when equivalent to a rotation.
	---Transformation group = D8 / <s>
	---Rotation while in world = r^2
	---[`pump`, 1x2-combinators]
	["d8_0_RFc"] = 14,

	---NESW + mirror bit
	---Transformation group = D8.
	---R = r, H = s, V = r^2*H
	---[AMs with active fluid boxes]
	["D8_0_RF"] = 15,
	["D8_1_RF"] = 16,
	["D8_2_RF"] = 17,
	["D8_3_RF"] = 18,

	---NESW + mirror bit, oblong shape, rotation = flip when placed
	---Transformation group = D8
	---While held: R = r, H = s, V = r^2*H
	---While in world:  R = r^2, H = s, V = r^2*H
	---[`recycler`]
	["D8_0_RFc"] = 19,

	---NESW + mirror bit, latent orientation. This applies to
	---assembling machines with disabled fluid boxes. If they are re-enabled
	---they become D8_n_RF and their latent orientation is restored.
	---(The orientation is still readable from world entities while they are
	--- latent, but they can't be changed.)
	["D8_0_latent"] = 20,
	["D8_1_latent"] = 21,
	["D8_2_latent"] = 22,
	["D8_3_latent"] = 23,

	---8-directional, sane transforms in hand, fixed when placed
	---[`railgun-turret`]
	["d16_0_rf"] = 24,

	---NESW, no mirroring, latent orientation. Unflippable crafting machines
	---with fluid boxes disabled.
	["d8_0_latent"] = 25,
}
lib.OrientationClass = OrientationClass

---Properties of an orientation class.
---@class Core.OrientationClass.Properties
---@field public dihedral_r_order uint The order of the rotational element in the dihedral group representing this class.
---@field public can_mirror boolean Whether this class has a mirroring bit.
---@field public blueprint_transforms? Core.Dihedral[] Precomputed array of dihedral transformations for blueprints, indexed by D8-element index. !!!THIS IS ZERO-INDEXED!!!
---@field public R_hand Core.Dihedral|nil The dihedral transformation corresponding to a clockwise rotation while held in the cursor, if any.
---@field public Rinv_hand Core.Dihedral|nil The dihedral transformation corresponding to a counterclockwise rotation while held in the cursor, if any.
---@field public H_hand Core.Dihedral|nil The dihedral transformation corresponding to a horizontal flip while held in the cursor, if any.
---@field public V_hand Core.Dihedral|nil The dihedral transformation corresponding to a vertical flip while held in the cursor, if any.
---@field public R_world Core.Dihedral|nil The dihedral transformation corresponding to a clockwise rotation while placed in the world, if any.
---@field public Rinv_world Core.Dihedral|nil The dihedral transformation corresponding to a counterclockwise rotation while placed in the world, if any.
---@field public H_world Core.Dihedral|nil The dihedral transformation corresponding to a horizontal flip while placed in the world, if any.
---@field public V_world Core.Dihedral|nil The dihedral transformation corresponding to a vertical flip while placed in the world, if any.
---@field public R_blueprint Core.Dihedral|nil The dihedral transformation corresponding to a clockwise rotation while in a blueprint, if any.
---@field public Rinv_blueprint Core.Dihedral|nil The dihedral transformation corresponding to a counterclockwise rotation while in a blueprint, if any.
---@field public H_blueprint Core.Dihedral|nil The dihedral transformation corresponding to a horizontal flip while in a blueprint, if any.
---@field public V_blueprint Core.Dihedral|nil The dihedral transformation corresponding to a vertical flip while in a blueprint, if any.

---@type Core.OrientationClass.Properties
local zero = {
	dihedral_r_order = 0,
	can_mirror = false,
	R_hand = nil,
	Rinv_hand = nil,
	H_hand = nil,
	V_hand = nil,
	R_world = nil,
	Rinv_world = nil,
	H_world = nil,
	V_world = nil,
}

local D1_s = dih_encode(1, 0, 1)
local D8_r = dih_encode(4, 1, 0)
local D8_rinv = dih_encode(4, 3, 0)
local D8_s = dih_encode(4, 0, 1)
local D8_rs = dih_encode(4, 1, 1)
local D8_r2s = dih_encode(4, 2, 1)
local D8_r3s = dih_encode(4, 3, 1)
local D8_r2 = dih_encode(4, 2, 0)

---Properties of each individual orientation class.
---@type table<Core.OrientationClass, Core.OrientationClass.Properties>
lib.class_properties = {
	[OrientationClass.Unknown] = zero,
	[OrientationClass.Unsupported] = zero,
	[OrientationClass.Nil] = zero,
	[OrientationClass.D2_r] = {
		dihedral_r_order = 1,
		can_mirror = false,
		R_hand = D1_s,
		Rinv_hand = D1_s,
	},
	[OrientationClass.D2_R] = {
		dihedral_r_order = 1,
		can_mirror = false,
		R_hand = D1_s,
		Rinv_hand = D1_s,
		R_world = D1_s,
		Rinv_world = D1_s,
	},
	[OrientationClass.D2_1_RF] = {
		dihedral_r_order = 1,
		can_mirror = false,
		R_hand = D1_s,
		Rinv_hand = D1_s,
		H_hand = D1_s,
		V_hand = D1_s,
		R_world = D1_s,
		Rinv_world = D1_s,
		H_world = D1_s,
		V_world = D1_s,
	},
	[OrientationClass.d8_R] = {
		dihedral_r_order = 4,
		can_mirror = false,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		R_world = D8_r,
		Rinv_world = D8_rinv,
	},
	[OrientationClass.d8_0_rf] = {
		dihedral_r_order = 4,
		can_mirror = false,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_s,
		V_hand = D8_r2s,
		R_world = nil,
		Rinv_world = nil,
		H_world = nil,
		V_world = nil,
	},
	[OrientationClass.d8_0_rF] = {
		dihedral_r_order = 4,
		can_mirror = false,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_s,
		V_hand = D8_r2s,
		R_world = nil,
		Rinv_world = nil,
		H_world = D8_s,
		V_world = D8_r2s,
	},
	[OrientationClass.d8_0_RF] = {
		dihedral_r_order = 4,
		can_mirror = false,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_s,
		V_hand = dih_product(D8_r2, D8_s),
		R_world = D8_r,
		Rinv_world = D8_rinv,
		H_world = D8_s,
		V_world = dih_product(D8_r2, D8_s),
	},
	[OrientationClass.d8_1_RF] = {
		dihedral_r_order = 4,
		can_mirror = false,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_rs,
		V_hand = dih_product(D8_r2, D8_rs),
		R_world = D8_r,
		Rinv_world = D8_rinv,
		H_world = D8_rs,
		V_world = dih_product(D8_r2, D8_rs),
	},
	[OrientationClass.d8_2_RF] = {
		dihedral_r_order = 4,
		can_mirror = false,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_r2s,
		V_hand = dih_product(D8_r2, D8_r2s),
		R_world = D8_r,
		Rinv_world = D8_rinv,
		H_world = D8_r2s,
		V_world = dih_product(D8_r2, D8_r2s),
	},
	[OrientationClass.d8_3_RF] = {
		dihedral_r_order = 4,
		can_mirror = false,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_r3s,
		V_hand = dih_product(D8_r2, D8_r3s),
		R_world = D8_r,
		Rinv_world = D8_rinv,
		H_world = D8_r3s,
		V_world = dih_product(D8_r2, D8_r3s),
	},
	-- Rotation while in world = r^2
	[OrientationClass.d8_0_RFc] = {
		dihedral_r_order = 4,
		can_mirror = false,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_s,
		V_hand = D8_r2s,
		R_world = dih_encode(4, 2, 0),
		Rinv_world = dih_encode(4, 2, 0),
		H_world = D8_s,
		V_world = D8_r2s,
	},
	[OrientationClass.D8_0_RF] = {
		dihedral_r_order = 4,
		can_mirror = true,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_s,
		V_hand = dih_product(D8_r2, D8_s),
		R_world = D8_r,
		Rinv_world = D8_rinv,
		H_world = D8_s,
		V_world = dih_product(D8_r2, D8_s),
	},
	[OrientationClass.D8_1_RF] = {
		dihedral_r_order = 4,
		can_mirror = true,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_rs,
		V_hand = dih_product(D8_r2, D8_rs),
		R_world = D8_r,
		Rinv_world = D8_rinv,
		H_world = D8_rs,
		V_world = dih_product(D8_r2, D8_rs),
	},
	[OrientationClass.D8_2_RF] = {
		dihedral_r_order = 4,
		can_mirror = true,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_r2s,
		V_hand = dih_product(D8_r2, D8_r2s),
		R_world = D8_r,
		Rinv_world = D8_rinv,
		H_world = D8_r2s,
		V_world = dih_product(D8_r2, D8_r2s),
	},
	---While held: R = r, H = s, V = r^2*s
	---While in world:  R = r^2, H = s, V = r^2*s
	[OrientationClass.D8_0_RFc] = {
		dihedral_r_order = 4,
		can_mirror = true,
		R_hand = D8_r,
		Rinv_hand = D8_rinv,
		H_hand = D8_s,
		V_hand = dih_product(D8_r2, D8_s),
		R_world = dih_encode(4, 2, 0),
		Rinv_world = dih_encode(4, 2, 0),
		H_world = D8_s,
		V_world = dih_product(D8_r2, D8_s),
	},
	[OrientationClass.D8_0_latent] = {
		dihedral_r_order = 4,
		can_mirror = true,
		R_blueprint = D8_r,
		Rinv_blueprint = D8_rinv,
		H_blueprint = D8_s,
		V_blueprint = dih_product(D8_r2, D8_s),
	},
	[OrientationClass.D8_1_latent] = {
		dihedral_r_order = 4,
		can_mirror = true,
		R_blueprint = D8_r,
		Rinv_blueprint = D8_rinv,
		H_blueprint = D8_rs,
		V_blueprint = dih_product(D8_r2, D8_rs),
	},
	[OrientationClass.D8_2_latent] = {
		dihedral_r_order = 4,
		can_mirror = true,
		R_blueprint = D8_r,
		Rinv_blueprint = D8_rinv,
		H_blueprint = D8_r2s,
		V_blueprint = dih_product(D8_r2, D8_r2s),
	},
	[OrientationClass.D8_3_latent] = {
		dihedral_r_order = 4,
		can_mirror = true,
		R_blueprint = D8_r,
		Rinv_blueprint = D8_rinv,
		H_blueprint = D8_r3s,
		V_blueprint = dih_product(D8_r2, D8_r3s),
	},
	[OrientationClass.d16_0_rf] = {
		dihedral_r_order = 8,
		can_mirror = false,
		R_hand = dih_encode(8, 1, 0),
		Rinv_hand = dih_encode(8, 7, 0),
		H_hand = dih_encode(8, 0, 1),
		V_hand = dih_encode(8, 4, 1),
		R_world = nil,
		Rinv_world = nil,
		H_world = nil,
		V_world = nil,
		R_blueprint = dih_encode(8, 2, 0),
		Rinv_blueprint = dih_encode(8, 6, 0),
		H_blueprint = dih_encode(8, 0, 1),
		V_blueprint = dih_encode(8, 4, 1),
	},
	[OrientationClass.d8_0_latent] = {
		dihedral_r_order = 4,
		can_mirror = false,
		R_blueprint = D8_r,
		Rinv_blueprint = D8_rinv,
		H_blueprint = D8_s,
		V_blueprint = dih_product(D8_r2, D8_s),
	},
}

---@param oclass Core.OrientationClass?
---@return Core.OrientationClass.Properties
function lib.get_class_properties(oclass)
	if not oclass then return zero end
	return lib.class_properties[oclass] or zero
end

-- Precompute blueprint transforms for each orientation class
for _, props in pairs(lib.class_properties) do
	props.blueprint_transforms = {}
	local R = props.R_blueprint
		or props.R_hand
		or dih_encode(props.dihedral_r_order, 0, 0)
	local S = props.H_blueprint
		or props.H_hand
		or dih_encode(props.dihedral_r_order, 0, 0)
	for i = 0, 7 do
		local _, r, s = dihedral.elt(4, i)
		if s == 0 then
			props.blueprint_transforms[i] = dih_power(R, r)
		else
			props.blueprint_transforms[i] = dih_product(dih_power(R, r), S)
		end
	end
end

---The context in which an entity orientation is being changed. Entities may
---behave differently when being held in cursor versus placed in the world.
---@enum Core.OrientationContext
local OrientationContext = {
	"Unknown",
	"Cursor",
	"World",
	"Blueprint",
	---Unknown context. (The more generous context will be used to interpret
	---transforms.)
	["Unknown"] = 1,
	---The entity is being held in the cursor.
	["Cursor"] = 2,
	---The entity is placed in the world.
	["World"] = 3,
	---The entity is in a blueprint which is itself being transformed.
	["Blueprint"] = 4,
}
lib.OrientationContext = OrientationContext

---Create the `mod-data` object for holding custom orientation classes.
---Calling this function outside the data phase will crash.
function lib.data_phase_create_mod_data()
	if not data.raw["mod-data"]["orientation-classes-by-name"] then
		data.raw["mod-data"]["orientation-classes-by-name"] = {
			type = "mod-data",
			name = "orientation-classes-by-name",
			data_type = "table<string, Core.OrientationClass>",
			data = {},
		}
	end
end

---During the data phase, register a custom modded entity's orientation
---class.
---@param entity_name string
---@param orientation_class Core.OrientationClass
function lib.data_phase_register_entity_orientation_class(
	entity_name,
	orientation_class
)
	lib.data_phase_create_mod_data()
	data.raw["mod-data"]["orientation-classes-by-name"].data[entity_name] =
		orientation_class
end

--- Prototype-types with fixed orientation classes
---@type table<string, Core.OrientationClass>
local static_by_type = {
	["container"] = OrientationClass.Nil,
	["simple-entity-with-owner"] = OrientationClass.d8_0_RF,
	["transport-belt"] = OrientationClass.d8_0_RF,
	["underground-belt"] = OrientationClass.d8_0_RF,
	["linked-belt"] = OrientationClass.d8_0_RF,
	["splitter"] = OrientationClass.d8_0_RF,
	["inserter"] = OrientationClass.d8_0_RF,
	["loader"] = OrientationClass.d8_0_RF,
	["electric-pole"] = OrientationClass.Nil,
	["heat-pipe"] = OrientationClass.Nil,
	["pipe"] = OrientationClass.Nil,
	["pipe-to-ground"] = OrientationClass.d8_0_RF,
	["pump"] = OrientationClass.d8_0_RFc,
	["logistic-container"] = OrientationClass.Nil,
	["roboport"] = OrientationClass.Nil,
	["arithmetic-combinator"] = OrientationClass.d8_0_RFc,
	["decider-combinator"] = OrientationClass.d8_0_RFc,
	["selector-combinator"] = OrientationClass.d8_0_RFc,
	["constant-combinator"] = OrientationClass.d8_0_RF,
	["power-switch"] = OrientationClass.Nil,
	["programmable-speaker"] = OrientationClass.Nil,
	["lamp"] = OrientationClass.Nil,
	["accumulator"] = OrientationClass.Nil,
	["solar-panel"] = OrientationClass.Nil,
	["lightning-attractor"] = OrientationClass.Nil,
	["lab"] = OrientationClass.Nil,
	["radar"] = OrientationClass.Nil,
	["wall"] = OrientationClass.Nil,
	["gate"] = OrientationClass.D2_R,
	["rocket-silo"] = OrientationClass.Nil,
	["cargo-landing-pad"] = OrientationClass.Nil,
	["cargo-bay"] = OrientationClass.Nil,
	["assembling-machine"] = OrientationClass.D8_0_latent,
	-- Unsupported rail entities
	["rail-signal"] = OrientationClass.Unsupported,
	["rail-chain-signal"] = OrientationClass.Unsupported,
	["straight-rail"] = OrientationClass.Unsupported,
	["curved-rail-a"] = OrientationClass.Unsupported,
	["curved-rail-b"] = OrientationClass.Unsupported,
	["half-diagonal-rail"] = OrientationClass.Unsupported,
}

---If a prototype type has a statically determined orientation class, return it.
---Otherwise, return nil.
---@param prototype_type string?
---@return Core.OrientationClass?
local function get_static_orientation_class_for_type(prototype_type)
	return static_by_type[prototype_type or ""]
end
lib.get_static_orientation_class_for_type =
	get_static_orientation_class_for_type

---Prototype-names with fixed orientation classes
---@type table<string, Core.OrientationClass>
local static_by_name = {
	["boiler"] = OrientationClass.d8_0_RF,
	["steam-engine"] = OrientationClass.D2_r,
	["nuclear-reactor"] = OrientationClass.Nil,
	["heat-exchanger"] = OrientationClass.d8_0_RFc,
	["steam-turbine"] = OrientationClass.D2_r,
	["fusion-reactor"] = OrientationClass.D2_R,
	["fusion-generator"] = OrientationClass.d8_0_RFc,
	["burner-mining-drill"] = OrientationClass.d8_R,
	["electric-mining-drill"] = OrientationClass.d8_0_RF,
	["big-mining-drill"] = OrientationClass.d8_0_RF,
	["offshore-pump"] = OrientationClass.d8_0_rf,
	["pumpjack"] = OrientationClass.d8_R,
	["stone-furnace"] = OrientationClass.Nil,
	["steel-furnace"] = OrientationClass.Nil,
	["electric-furnace"] = OrientationClass.Nil,
	["recycler"] = OrientationClass.D8_0_RFc,
	["agricultural-tower"] = OrientationClass.Nil,
	["heating-tower"] = OrientationClass.Nil,
	["gun-turret"] = OrientationClass.d8_0_rF,
	["laser-turret"] = OrientationClass.d8_0_rF,
	["flamethrower-turret"] = OrientationClass.d8_0_rf,
	["artillery-turret"] = OrientationClass.d8_0_RF,
	["rocket-turret"] = OrientationClass.d8_0_rF,
	["tesla-turret"] = OrientationClass.d8_0_rF,
	["railgun-turret"] = OrientationClass.d16_0_rf,
	-- AMs with always-on fluidboxes
	["chemical-plant"] = OrientationClass.D8_0_RF,
	["oil-refinery"] = OrientationClass.D8_0_RF,
	["storage-tank"] = OrientationClass.D2_1_RF,
}

---If a prototype name has a statically determined orientation class, return it.
---Otherwise, return nil.
---@param prototype_name string?
---@return Core.OrientationClass?
local function get_static_orientation_class_for_name(prototype_name)
	if not prototype_name then return nil end
	-- Check mod data first
	local custom = prototypes.mod_data["orientation-classes-by-name"]
	if custom then
		local c = custom[prototype_name]
		if c then return c end
	end
	-- Fallback on static determination for base game entities.
	return static_by_name[prototype_name]
end
lib.get_static_orientation_class_for_name =
	get_static_orientation_class_for_name

local function get_actual_type(entity)
	if entity.type == "entity-ghost" then
		return entity.ghost_type
	else
		return entity.type
	end
end

local function get_actual_name(entity)
	if entity.type == "entity-ghost" then
		return entity.ghost_name
	else
		return entity.name
	end
end

---Attempt to get dynamic orientation class from a world entity. Returns
---`nil` if the entity isn't known to have a dynamic class or the class
---can't be determined.
---@param entity LuaEntity A *valid* entity.
---@param prototype_name string The entity's prototype name.
---@param prototype_type string The entity's prototype type.
---@return Core.OrientationClass?
local function get_dynamic_orientation_class_for_entity(
	entity,
	prototype_name,
	prototype_type
)
	if metadata.mirroring_possible_types[prototype_type] then
		-- Mirrorables
		local prototype = prototypes.entity[prototype_name]
		if prototype.use_mirroring then
			if prototype.fluid_boxes_off_when_no_fluid_recipe then
				if entity.fluids_count == 0 then
					return OrientationClass.D8_0_latent
				else
					return OrientationClass.D8_0_RF
				end
			else
				return OrientationClass.D8_0_RF
			end
		else
			if prototype.fluid_boxes_off_when_no_fluid_recipe then
				if entity.fluids_count == 0 then
					return OrientationClass.d8_0_latent
				else
					return OrientationClass.d8_0_RF
				end
			else
				return OrientationClass.d8_0_latent
			end
		end
	elseif metadata.two_direction_only_types[prototype_type] then
		-- Possible bidirectional entities
		local prototype = prototypes.entity[prototype_name]
		if prototype.two_direction_only then
			-- Weird rotation cases.
			if prototype_name == "storage-tank" then
				return OrientationClass.D2_1_RF
			end
			return OrientationClass.D2_R
		else
			return OrientationClass.d8_0_RF
		end
	end
end
lib.get_dynamic_orientation_class_for_entity =
	get_dynamic_orientation_class_for_entity

---Get the orientation class for an entity or ghost.
---@param entity LuaEntity?
---@return Core.OrientationClass
function lib.get_orientation_class_for_entity(entity)
	if not entity or not entity.valid then return OrientationClass.Unknown end
	local prototype_name = get_actual_name(entity)
	local prototype_type = get_actual_type(entity)
	return get_dynamic_orientation_class_for_entity(
		entity,
		prototype_name,
		prototype_type
	) or get_static_orientation_class_for_name(prototype_name) or get_static_orientation_class_for_type(
		prototype_type
	) or OrientationClass.Unknown
end

---Get the orientation class for an entity only by its prototype name.
---This is needed for e.g. blueprint or serialized entities.
---@param name string Prototype name
---@return Core.OrientationClass
function lib.get_orientation_class_by_name(name)
	local OC = get_static_orientation_class_for_name(name)
	if OC then return OC end
	local eproto = prototypes.entity[name]
	if not eproto then return OrientationClass.Unknown end
	OC = get_static_orientation_class_for_type(eproto.type)
	if OC then return OC end
	return OrientationClass.Unknown
end

---Convert an orientation class to a string for debugging.
---@param oclass Core.OrientationClass?
function lib.stringify(oclass)
	if not oclass then return "nil" end
	-- False positive type error
	---@diagnostic disable-next-line: undefined-field
	return OrientationClass[oclass] or "InvalidOrientationClass"
end

return lib
