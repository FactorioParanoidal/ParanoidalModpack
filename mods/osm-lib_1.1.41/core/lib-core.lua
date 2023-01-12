------------------
---- Lib Core ----
------------------

if not OSM.utils then OSM.utils = require("__osm-lib__.functions.utils") end
if not OSM.debug_mode then OSM.debug_mode = settings.startup["OSM-debug-mode"].value end

if OSM.data_stage then

	if not OSM.lib then OSM.lib = {} end
	if not OSM.mod then OSM.mod = {} end
	if not OSM.log then OSM.log = {} end
	if not OSM.table then OSM.table = {} end

	-- Extend OSM.utils
	for i, command in pairs(require("__osm-lib__.functions.utils-data")) do
		OSM.utils[i] = command
	end

	if not OSM.log.errors then OSM.log.errors = {} end
	if not OSM.log.warnings then OSM.log.warnings = {} end

	-- Disabled prototype host table
	if not OSM.table.disabled_prototypes then OSM.table.disabled_prototypes = {} end
	if not OSM.table.disabled_prototypes["entity"] then OSM.table.disabled_prototypes["entity"] = {} end
	if not OSM.table.disabled_prototypes["recipe"] then OSM.table.disabled_prototypes["recipe"] = {} end
	if not OSM.table.disabled_prototypes["item"] then OSM.table.disabled_prototypes["item"] = {} end
	if not OSM.table.disabled_prototypes["fluid"] then OSM.table.disabled_prototypes["fluid"] = {} end
	if not OSM.table.disabled_prototypes["technology"] then OSM.table.disabled_prototypes["technology"] = {} end
	if not OSM.table.disabled_prototypes["resource"] then OSM.table.disabled_prototypes["resource"] = {} end
	
	-- Enabled prototype host table [overrides disable]
	if not OSM.table.enabled_prototypes then OSM.table.enabled_prototypes = {} end
	if not OSM.table.enabled_prototypes["entity"] then OSM.table.enabled_prototypes["entity"] = {} end
	if not OSM.table.enabled_prototypes["recipe"] then OSM.table.enabled_prototypes["recipe"] = {} end
	if not OSM.table.enabled_prototypes["item"] then OSM.table.enabled_prototypes["item"] = {} end
	if not OSM.table.enabled_prototypes["fluid"] then OSM.table.enabled_prototypes["fluid"] = {} end
	if not OSM.table.enabled_prototypes["technology"] then OSM.table.enabled_prototypes["technology"] = {} end
	if not OSM.table.enabled_prototypes["resource"] then OSM.table.enabled_prototypes["resource"] = {} end
	
	-- Prototype property indexing table [used for storing properties and infos related to the given prototype]
	if not OSM.table.prototype_index then
		OSM.table.prototype_index = {}
		for data_type, sub_type in pairs(OSM.data.raw) do
			OSM.table.prototype_index[data_type] = {}
			OSM.table.prototype_index[data_type].OSM_type = sub_type
		end
	end
	
	-- Handy constants
	OSM.void_recipe = {{type="item", name="OSM-hoffman-void-recipe", amount=1, probability=0}}
	
	-- Base game references
	OSM.hit_effects = require("__base__.prototypes.entity.hit-effects")
	OSM.sounds = require("__base__.prototypes.entity.sounds")
	
	-- Graphics paths
	OSM.lib.graphics = "__osm-lib__/graphics/"
end