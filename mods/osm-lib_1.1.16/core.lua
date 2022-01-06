------------------
---- data.lua ----
------------------

-- Setup core hosts
if not OSM.table then OSM.table = {} end
if not OSM.table.removed_prototypes then OSM.table.removed_prototypes = {} end	-- Stores prototypes to be removed in updates stage [data.lua]
if not OSM.table.enabled_prototypes then OSM.table.enabled_prototypes = {} end	-- Stores prototypes to be kept and overrides the above [data.lua]
if not OSM.table.removed_icons then OSM.table.removed_icons = {} end			-- Stores icons for prototypes to be removed
if not OSM.entity_types then OSM.entity_types = {} end				-- Stores all game entity types

-- Make item group [removed items]
local item_group =
{
	type = "item-group",
	name = "OSM-removed",
	icon = "__osm-lib__/graphics/ban.png",
	icon_size = 64,
	inventory_order = "zzzz",
	order = "zzzz",
	localised_name = {"", "Disabled prototypes"}
}	data:extend({item_group})

local item_subgroup =
{
	group = "OSM-removed",
	type = "item-subgroup",
	name = "OSM-removed",
	order = "a"
}	data:extend({item_subgroup})

local recipe_category =
{
    type = "recipe-category",
    name = "OSM-removed"
}	data:extend({recipe_category})

local OSM_void =
{
	type = "item",
	name = "OSM_void",
	icon = "__core__/graphics/empty.png",
	icon_size = 1,
	subgroup = "OSM-removed",
	flags = {"hidden"},
	order = "zzzz",
	stack_size = 1
}	data:extend({OSM_void})

-- Host entity types
OSM.entity_types =
{
	"arrow",
	"artillery-flare",
	"artillery-projectile",
	"beam",
	"character-corpse",
	"cliff",
	"corpse",
	"rail-remnants",
	"deconstructible-tile-proxy",
	"prototype-ghost",
	"accumulator",
	"artillery-turret",
	"beacon",
	"boiler",
	"burner-generator",
	"character",
	"arithmetic-combinator",
	"decider-combinator",
	"constant-combinator",
	"container",
	"logistic-container",
	"infinity-container",
	"assembling-machine",
	"rocket-silo",
	"furnace",
	"electric-energy-interface",
	"electric-pole",
	"unit-spawner",
	"fish",
	"combat-robot",
	"construction-robot",
	"logistic-robot",
	"gate",
	"generator",
	"heat-interface",
	"heat-pipe",
	"inserter",
	"lab",
	"lamp",
	"land-mine",
	"linked-container",
	"market",
	"mining-drill",
	"offshore-pump",
	"pipe",
	"infinity-pipe",
	"pipe-to-ground",
	"player-port",
	"power-switch",
	"programmable-speaker",
	"pump",
	"radar",
	"curved-rail",
	"straight-rail",
	"rail-chain-signal",
	"rail-signal",
	"reactor",
	"roboport",
	"simple-prototype",
	"simple-prototype-with-owner",
	"simple-prototype-with-force",
	"solar-panel",
	"spider-leg",
	"storage-tank",
	"train-stop",
	"linked-belt",
	"loader-1x1",
	"loader",
	"splitter",
	"transport-belt",
	"underground-belt",
	"tree",
	"turret",
	"ammo-turret",
	"electric-turret",
	"fluid-turret",
	"unit",
	"car",
	"artillery-wagon",
	"cargo-wagon",
	"fluid-wagon",
	"locomotive",
	"spider-vehicle",
	"wall",
	"flame-thrower-explosion",
	"stream",
	"flying-text",
	"highlight-box",
	"item-prototype",
	"item-request-proxy",
	"particle-source",
	"projectile",
	"rocket-silo-rocket",
	"rocket-silo-rocket-shadow",
	"tile-ghost"
}