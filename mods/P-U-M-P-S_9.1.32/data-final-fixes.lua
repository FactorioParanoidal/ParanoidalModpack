------------------------------
---- data-final-fixes.lua ----
------------------------------

-- Fetch functions from library
local hide_entity = require("utils.lib").hide_entity
local fix_collision_mask = require("utils.lib").fix_collision_mask
local remove_tech_recipe = require("utils.lib").remove_tech_recipe
local replace_tech_recipe = require("utils.lib").replace_tech_recipe
local replace_ingredient_all_recipes = require("utils.lib").replace_ingredient_all_recipes

-- Prevent collision mask mismatch
fix_collision_mask("offshore-pump-0")
fix_collision_mask("offshore-pump-1")
fix_collision_mask("offshore-pump-2")
fix_collision_mask("offshore-pump-3")
fix_collision_mask("offshore-pump-4")

-- AAI Industry offshore pump unlock fix
--[[
if mods ["aai-industry"] then
	replace_tech_recipe("basic-fluid-handling", "offshore-pump", "offshore-pump-1")
	remove_tech_recipe("fluid-handling", "offshore-pump-1")
end
]]--

-- Fix vanilla pump being used as ingredient in recipes
replace_ingredient_all_recipes("offshore-pump", "offshore-pump-1")

-- Fix menu entries for lithia water
if data.raw["autoplace-control"]["ground-water"] then
	data.raw["autoplace-control"]["ground-water"].localised_name = {"", "[entity=lithia-water] ", {"entity-name.lithia-water"}}
end

-- Hide vanilla offshore pump
hide_entity("offshore-pump")