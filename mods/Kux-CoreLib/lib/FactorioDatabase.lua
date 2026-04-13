require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.FactorioDatabase : KuxCoreLib.Class
---@field prototypes DbPrototypes
---@field asGlobal fun():KuxCoreLib.FactorioDatabase
-- replaces script (LuaBootstrap) for all event actions
local FactorioDatabase = {
	__class  = "KuxCoreLib.FactorioDatabase",
	__guid   = "fca4585b-533d-4d9f-87c3-f88546cb0edf",
	__origin = "Kux-CoreLib/lib/FactorioDatabase.lua",
	__writableMembers={"getDisplayName","registerName"}
}
if not KuxCoreLib.__classUtils.ctor(FactorioDatabase) then return self end
-----------------------------------------------------------------------------------------------------------------------
_G.fdb = FactorioDatabase

local RecipeUtils = KuxCoreLib.require.RecipeUtils

---@class FactorioDatabase.private
local this = {}

-----------------------------------------------------------------------------------------------------------------------


local function init()
	---@diagnostic disable: missing-fields
	FactorioDatabase.prototypes = {}
	---@diagnostic enable: missing-fields
end

function FactorioDatabase.load()
	RecipeUtils.generateRecipeCatalog()
	this.read_entities()
	this.read_items()
	this.read_fluids()
	this.read_tiles()
	this.read_technologies()
end

function this.read_fluids()
	fdb.prototypes.fluid = prototypes.fluid
	fdb.prototypes.fluids = {
		count_total = 0,
		rows        = fdb.prototypes.fluid,
		made_in     = {}
	}

	for fluid_name, fluid in pairs(prototypes.fluid) do
		fdb.prototypes.fluids.count_total = fdb.prototypes.fluids.count_total + 1
	end
end

function this.read_items()
	fdb.prototypes.item = prototypes.item
	fdb.prototypes.items = {
		count_total = 0,
		rows        = fdb.prototypes.item,
		made_in     = {}
	}

	for item_name, item in pairs(prototypes.item) do
		fdb.prototypes.items.count_total = fdb.prototypes.items.count_total + 1
	end
end

function this.read_tiles()
	assert(fdb.prototypes.fluids.made_in ~= nil, "Fluids must be read before tiles")
	assert(fdb.prototypes.entities.by_type ~= nil, "Entities must be read before tiles")

	fdb.prototypes.tile = prototypes.tile
	fdb.prototypes.tiles = {
		count_total = 0,
		rows        = fdb.prototypes.tile,
		by_fluid    = {},
	}

	for tile_name, tile in pairs(prototypes.tile) do
		fdb.prototypes.tiles.count_total = fdb.prototypes.tiles.count_total + 1

		if tile.fluid then
			fdb.prototypes.tiles.by_fluid[tile.fluid.name] = fdb.prototypes.tiles.by_fluid[tile.fluid.name] or {}
			table.insert(fdb.prototypes.tiles.by_fluid[tile.fluid.name], tile_name)

			fdb.prototypes.fluids.made_in[tile.fluid.name] = fdb.prototypes.fluids.made_in[tile.fluid.name] or {}
			for entity_name, _ in ipairs(fdb.prototypes.entities.by_type["offshore-pump"]) do
				table.insert(fdb.prototypes.fluids.made_in[tile.fluid.name], entity_name)
			end
		end
	end
end

function this.read_entities()
	fdb.prototypes.entities = fdb.prototypes.entities or {}
	fdb.prototypes.entities.rows = prototypes.entity
	fdb.prototypes.entity = fdb.prototypes.entities.rows
	fdb.prototypes.entities.by_crafting_category = {}
	fdb.prototypes.entities.by_resource_category = {}
	fdb.prototypes.entities.by_type = {}
	fdb.prototypes.entities.by_fixed_recipe = {}
	fdb.prototypes.entities.with_fixed_recipe = {}
	fdb.prototypes.entities.mineable = {}
	fdb.prototypes.entities.by_mining_item = {}
	fdb.prototypes.entities.by_mining_fluid = {}
	--fdb.prototypes.entities.by_placeable_item = {}
	--fdb.prototypes.entities.placeable_items = {}
	--fdb.prototypes.entities.by_fuel_category = {}
	--fdb.prototypes.entities.by_energy_fluid = {}


	for category_name, _ in pairs(prototypes.recipe_category) do
		fdb.prototypes.entities.by_crafting_category[category_name] = {}
	end
	for category_name, _ in pairs(prototypes.resource_category) do
		fdb.prototypes.entities.by_resource_category[category_name] = {}
	end

	for _, entity in pairs(prototypes.entity) do

		-- index by type
		fdb.prototypes.entities.by_type[entity.type] = fdb.prototypes.entities.by_type[entity.type] or {}
		table.insert(fdb.prototypes.entities.by_type[entity.type], entity.name)

		-- index by crafting_category
		for category in pairs(entity.crafting_categories or {}) do
			table.insert(fdb.prototypes.entities.by_crafting_category[category], entity.name)
		end

		-- index by resource_category
		for category in pairs(entity.resource_categories or {}) do
			table.insert(fdb.prototypes.entities.by_resource_category[category], entity.name)
		end

		if entity.fixed_recipe then
			fdb.prototypes.entities.by_fixed_recipe[entity.fixed_recipe] = fdb.prototypes.entities.by_fixed_recipe[entity.fixed_recipe] or {}
			table.insert(fdb.prototypes.entities.by_fixed_recipe[entity.fixed_recipe], entity.name)

			fdb.prototypes.entities.with_fixed_recipe[entity.name] = entity.fixed_recipe
		end

		if entity.mineable_properties then
			if entity.mineable_properties.minable then
				table.insert(fdb.prototypes.entities.mineable, entity.name)
			end
			if entity.mineable_properties.products then
				for _, product in ipairs(entity.mineable_properties.products) do
					if product.type == "item" then
						fdb.prototypes.entities.by_mining_item[product.name] = fdb.prototypes.entities.by_mining_item[product.name] or {}
						table.insert(fdb.prototypes.entities.by_mining_item[product.name], entity.name)
					elseif product.type == "fluid" then
						fdb.prototypes.entities.by_mining_fluid[product.name] = fdb.prototypes.entities.by_mining_fluid[product.name] or {}
						table.insert(fdb.prototypes.entities.by_mining_fluid[product.name], entity.name)
					end
				end
			end
		end

		if entity.items_to_place_this then

		end

		if entity.fluid_energy_source_prototype then

		end
	end
end


function this.read_technologies()
	fdb.prototypes.technologies = fdb.prototypes.technologies or {}
	local set = fdb.prototypes.technologies
	fdb.prototypes.technologies.by_recipe = {}
	fdb.prototypes.technologies.by_prerequisite = {}
	local idx_prerequisite =  fdb.prototypes.technologies.by_prerequisite

	for recipe_name, _ in pairs(prototypes.recipe) do
		set.by_recipe[recipe_name] = {}
	end

	for tech_name, tech in pairs(prototypes.technology) do
		for _, effect in ipairs(tech.effects) do
			if effect.type == "unlock-recipe" then
				table.insert(set.by_recipe[effect.recipe], tech_name)
			end
		end
		for prereq_name, _ in pairs(tech.prerequisites) do
			idx_prerequisite[prereq_name] = idx_prerequisite[prereq_name] or {}
			table.insert(fdb.prototypes.technologies.by_prerequisite[prereq_name], tech_name)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------
init()
return FactorioDatabase
-----------------------------------------------------------------------------------------------------------------------



---@class RecordBase
--- ----------------
---@field count_total number
---@field count_filtered number
---@field rows any[]


---@class SubGroupRecord subgroup, set with prototypes
--- --------------------
---@field count_total number             total number of prototypes in the subgroup
---@field count_filtered number          number of filtered prototypes in the subgroup
---@field rows KuxCoreLib.LuaGenericPrototype[]


---@class GroupRecord group, set with subgroups->prototypes
--- -----------------
---@field name string                    name of the group
---@field index number                   index of the group
---@field count_total number             total number of prototypes in the group
---@field count_filtered number          number of filtered prototypes in the group
---@field rows SubGroupRecord[]


---@class ElementCatalog set with groups->subgroups->prototypes
---- ---------------------
---@field count_total number             total number of prototypes in the catalog
---@field count_filtered number          number of filtered prototypes in the catalog
---@field idx_row_index_group_name {[number]: string} -- e.g 1 -> "logistics"
---@field idx_type_name_key {[string]: {[string]: {[1]: string, [2]: number, [3]: number}}} -- type->name->key
---@field rows {[string]: GroupRecord}


--- @class DbPrototypes -- fdb.prototypes
--- --------------------
--- @field recipes RecipeCatalog
--- @field entities EntityCatalog
--- @field items ItemCatalog
--- @field fluids FluidCatalog
--- @field tiles TileCatalog
--- @field technologies TechnologyCatalog
---
--- @field item table<string, LuaItemPrototype>
--- @field fluid table<string, LuaFluidPrototype>
--- @field tile table<string, LuaTilePrototype>
--- @field recipe table<string, LuaRecipePrototype>
--- @field technology table<string, LuaTechnologyPrototype>
--- @field entity table<string, LuaEntityPrototype>
--- @field crafting_category table<string, string>


--- @class EntityCatalog
--- ---------------------
--- @field count_total number                           total number of prototypes in the catalog
--- @field rows table<string, LuaEntityPrototype> 	    entity name -> prototype
--- @field by_crafting_category table<string, string[]> crafting category -> entity names
--- @field by_resource_category table<string, string[]> resource category -> entity names
--- @field by_type table<string, string[]>              entity type -> entity names
--- @field by_fixed_recipe table<string, string[]>      recipe name -> entity names
--- @field with_fixed_recipe table<string, string>      entity name -> recipe name
--- @field mineable string[]                            entity names
--- @field by_mining_item table<string, string[]>       item name -> entity names
--- @field by_mining_fluid table<string, string[]>      fluid name -> entity names


--- @class ItemCatalog
--- ---------------------
--- @field count_total number             total number of prototypes in the catalog
--- @field rows table<string, LuaItemPrototype>
--- @field made_in table<string, string[]>       index item name -> made in entity names


--- @class FluidCatalog
--- ---------------------
--- @field count_total number             total number of prototypes in the catalog
--- @field rows table<string, LuaFluidPrototype>
--- @field made_in table<string, string[]>       index fluid name -> made in entity names

--- @class TileCatalog
--- ---------------------
--- @field count_total number             total number of prototypes in the catalog
--- @field rows table<string, LuaTilePrototype>
--- @field by_fluid table<string, string[]>       index fluid name -> tile names

--- @class TechnologyCatalog
--- ---------------------
--- @field count_total number                          total number of prototypes in the catalog
--- @field rows table<string, LuaTechnologyPrototype>
--- @field by_recipe table<string, string[]>           index recipe name -> technology names
--- @field by_prerequisite table<string, string[]>     index prerequisite name -> technology names