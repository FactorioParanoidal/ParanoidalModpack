-- Main hosts
if not OSM then OSM = {} end
if not OSM.lib then OSM.lib = {} end
if not OSM.mod then OSM.mod = {} end
if not OSM.log then OSM.log = {} end
if not OSM.utils then OSM.utils = {} end
if not OSM.table then OSM.table = {} end
if not OSM.data_stage then OSM.data_stage = 1 end

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
if not OSM.table.prototype_index then OSM.table.prototype_index = {} end

-- log tables
OSM.log.entity = {}
OSM.log.recipe = {}
OSM.log.item = {}
OSM.log.fluid = {}
OSM.log.technology = {}
OSM.log.resource = {}
OSM.log.errors = {}
OSM.log.warnings = {}

-- Handy constants
OSM.void_recipe = {{type="item", name="OSM-hoffman-void-recipe", amount=1, probability=0}}

-- Handy stuff
OSM.data_types = require("utils.data-types")			--[[contains all data.raw prototype subtypes]]
OSM.entity_types = require("utils.entity-types") 		--[[contains all entity subtypes]]
OSM.item_types = require("utils.item-types")			--[[contains all item subtypes]]
OSM.selection_tools = require("utils.selection-tools")	--[[contains all selection tools subtypes]]

-- Graphics paths
OSM.lib.graphics_path = "__osm-lib__/graphics/"
OSM.lib.icons_path = OSM.lib.graphics_path.."icons/"

-- Settings
OSM.debug_mode = settings.startup["OSM-debug-mode"].value