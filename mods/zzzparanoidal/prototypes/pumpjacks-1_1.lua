-- Bob Mining 1.1: restore the missing fourth pumpjack before Cursed-FMD copies it.
-- Keep Bob's existing top-tier ID so placed entities, items and blueprints survive.
local drills = data.raw["mining-drill"]
local source = drills["bob-pumpjack-3"]
if not (source and data.raw.item["bob-pumpjack-3"] and data.raw.recipe["bob-pumpjack-3"]
    and data.raw.technology["bob-pumpjacks-4"]) then return end

local name = "paranoidal-pumpjack-4"
local entity = table.deepcopy(source)
entity.name = name
entity.localised_name = {"entity-name." .. name}
entity.minable.result = name
entity.placeable_by = nil
entity.next_upgrade = "bob-pumpjack-3"
entity.mining_speed = 4
entity.energy_usage = "306kW"
entity.module_slots = 5
entity.max_health = 250

local item = table.deepcopy(data.raw.item["bob-pumpjack-3"])
item.name = name
item.place_result = name
item.localised_name = {"entity-name." .. name}
item.order = "b[fluids]-b[pumpjack-4]"

local recipe = table.deepcopy(data.raw.recipe["bob-pumpjack-3"])
recipe.name = name
recipe.localised_name = {"entity-name." .. name}
recipe.results = {{type = "item", name = name, amount = 1}}
recipe.enabled = false

local technology = table.deepcopy(data.raw.technology["bob-pumpjacks-4"])
technology.name = "paranoidal-pumpjacks-4"
technology.localised_name = {"technology-name.paranoidal-pumpjacks-4"}
technology.prerequisites = {"bob-pumpjacks-3"}
technology.effects = {{type = "unlock-recipe", recipe = name}}
technology.unit = {
    count = 100, time = 30,
    ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}},
}
local prototypes = {entity, item, recipe, technology}
local corpse = data.raw.corpse[source.corpse]
if corpse then
    corpse = table.deepcopy(corpse)
    corpse.name = name .. "-remnants"
    entity.corpse = corpse.name
    prototypes[#prototypes + 1] = corpse
end
data:extend(prototypes)

drills["bob-pumpjack-2"].next_upgrade = name
source.next_upgrade = nil
source.module_slots = 6
source.max_health = 300
source.localised_name = {"entity-name.paranoidal-pumpjack-5"}
data.raw.item["bob-pumpjack-3"].localised_name = {"entity-name.paranoidal-pumpjack-5"}
data.raw.item["bob-pumpjack-3"].order = "b[fluids]-b[pumpjack-5]"
