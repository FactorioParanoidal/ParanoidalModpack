--- Muluna API
-- 
-- Dependencies: `lib.remove-replace-object`
-- @module api.lua
-- @pragma nostrip
Muluna = {}

Muluna.get_stage = require("lib.get-stage").get_stage
Muluna.stage = Muluna.get_stage()
--- Library of table manipulation scripts.
-- @see lib.remove-replace-object
Muluna.rro = require("lib.remove-replace-object")

Muluna.img = require("lib.images")
Muluna.vectors=require("lib.vectors")
Muluna.multiply_energy = require("lib.energy-multiply").multiply_energy
Muluna.pipe_pictures = require("lib.pipe-pictures")
Muluna.data_fluids = require("lib.data-lib")
--flib imports
Muluna.flib_bounding_box = require("__planet-muluna__.lib.flib-bounding-box")
Muluna.flib_prototypes = require("__flib__.prototypes")
Muluna.telescopes = require("lib.telescopes")
Muluna.machine_scaling = require("lib.machine_scaling")

function Muluna:extend(new_data)
    for _,prototype in pairs(new_data) do
        if prototype.type == "recipe" then
            if (prototype.icon or prototype.icons) and not prototype.hide_from_recipe_gui then
                prototype.hide_from_recipe_gui = false
            end
        elseif prototype.type == "technology" then
            if prototype.research_trigger and prototype.research_trigger.entity and not prototype.research_trigger.entities then
                prototype.research_trigger.entities = {prototype.research_trigger.entity}
            end
        end
    end
    data:extend(new_data)
end

if Muluna.stage == "data" then
    Muluna:extend{{
        type = "mod-data",
        name = "muluna-constants",
        data = {

        }
    }}
    Muluna.constants = data.raw["mod-data"]["muluna-constants"].data

    -- Resource generation libraries forked from vanilla 
    Muluna.resource = require("lib.resources").resource
    Muluna.resource_autoplace = require("lib.resource-autoplace")
    Muluna.icons = require("lib.dual-item-icon")
    Muluna.exploration_science = require("lib.exploration-science")
    require("prototypes.mod-data.constants")
    Muluna.constants.names = require("lib.names")
elseif Muluna.stage == "control" then
    Muluna.constants = prototypes.mod_data["muluna-constants"].data
    Muluna.events = require("lib.events")
    Muluna.complete_research = require("lib.notifications").research_technology
end 

require("lib.table")


return Muluna