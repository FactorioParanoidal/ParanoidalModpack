local entities = require "prototypes.entities"
local items = require "prototypes.items"
local recipes = require "prototypes.recipes"
local technologies = require "prototypes.technologies"
local templates = require "prototypes.templates"

local function create_miniloader(prefix, next_prefix, tech_prereqs, tint, base_underground_name)
  base_underground_name = base_underground_name or (prefix .. "underground-belt")
  entities.create_loaders(prefix, base_underground_name, tint)
  entities.create_inserters(prefix, next_prefix, base_underground_name, tint)
  items.create_items(prefix, base_underground_name, tint)
  recipes.create_recipes(prefix)
  technologies.create_technology(prefix, tech_prereqs, tint)
end

for prefix, args in pairs(templates) do
  create_miniloader(prefix, args.next_prefix, args.prerequisite_techs, args.tint, args.base_underground_name)
end
