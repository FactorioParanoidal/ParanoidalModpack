local util = require("data-util")

util.tech_add_prerequisites("programmable-structures", "radar")


util.tech_add_prerequisites("nuclear-power", "steam-power")
util.tech_add_prerequisites("modules", "electric-lab")
util.tech_add_prerequisites("advanced-material-processing", "basic-automation")
util.tech_add_prerequisites("engine", "basic-automation")
util.tech_add_prerequisites("oil-processing", "fluid-handling")
util.tech_add_prerequisites("steel", "basic-fluid-handling")


--bobs
util.tech_add_prerequisites("radars", "radar")
util.tech_add_prerequisites("water-bore-1", "basic-fluid-handling")
util.tech_add_prerequisites("electrolysis-1", "basic-fluid-handling")
util.tech_add_prerequisites("alloy-processing-1", "basic-fluid-handling")
util.tech_add_prerequisites("bob-greenhouse", "basic-fluid-handling")
util.tech_add_prerequisites("chemical-processing-1", "basic-fluid-handling")
util.tech_add_prerequisites("chemical-processing-1", "basic-fluid-handling")
util.tech_add_prerequisites("bob-drills-1", "electric-mining")
util.tech_add_prerequisites("bob-area-drills-1", "electric-mining")
util.tech_add_prerequisites("bob-pumpjacks-1", "basic-fluid-handling")
util.tech_add_prerequisites("bob-boiler-2", "steam-power")
util.tech_add_prerequisites("bob-steam-engine-2", "steam-power")
util.tech_add_prerequisites("steam-engine-generator-1", "steam-power")
util.tech_add_prerequisites("gas-canisters", "fluid-handling")

util.tech_add_prerequisites("bob-steam-power-1", "steam-power")
if data.raw.technology["bob-steam-power-1"] then
  data.raw.technology["bob-steam-power-1"].unit.count = 100
end


--angels
util.tech_add_prerequisites("ore-crushing", "electricity")
util.tech_add_prerequisites("angels-metallurgy-1", "electricity")
util.tech_add_prerequisites("basic-chemistry", "basic-fluid-handling")
util.tech_add_prerequisites("angels-fluid-control", "basic-fluid-handling")
util.tech_add_prerequisites("bio-processing-green", "basic-fluid-handling")
util.tech_add_prerequisites("bio-processing-brown", "basic-fluid-handling")
util.tech_add_prerequisites("water-treatment", "basic-fluid-handling")
util.tech_add_prerequisites("oil-gas-extraction", "basic-fluid-handling")
util.tech_add_prerequisites("slag-processing-1", "basic-fluid-handling")

util.tech_add_prerequisites("chemical-processing-1", "basic-chemistry") --DrD

-- util.tech_lock_recipes(    "fuel-processing",  {        "fuel-processor"})

util.tech_lock_recipes(
    "basic-automation",  {
        "burner-assembling-machine",
        "burner-inserter"})

util.tech_lock_recipes(
    "automation",  {
        "inserter"})

util.tech_lock_recipes(
--    "automation-2",  { --DrD
    "express-inserters",  {
        "fast-inserter"})

if data.raw.technology["bob-logistics-0"] and data.raw.recipe["basic-transport-belt"] then
    -- if bob-basic-logistics then use basic logistics to lock tsp-0
    data.raw.technology["basic-logistics"].localised_name = {"technology-name.basic-logistics-1"}
    util.tech_lock_recipes(
        "basic-logistics",  {
            "basic-transport-belt",
			"iron-chest"})  -- DrD

    data.raw.technology["bob-logistics-0"].localised_name = {"technology-name.basic-logistics-2"}
    data.raw.technology["bob-logistics-0"].prerequisites = {"basic-logistics"}
    data.raw.technology["bob-logistics-0"].unit.count = 20

    data.raw.technology["logistics"].prerequisites = {"bob-logistics-0"}
    data.raw.technology["logistics"].unit.count = 100

else
  util.tech_lock_recipes(
      "basic-logistics",  {
          "transport-belt"})
end



util.tech_lock_recipes(
    "logistics",  {
        "underground-belt",
        "splitter"})
		
util.tech_lock_recipes(
    "military",  {
        "light-armor"})		 -- DrD

util.tech_lock_recipes(
    "electricity",  {
        --"electric-motor",
        "burner-turbine",
        "inserter",
        --"small-electric-pole",
        --"small-iron-electric-pole"
		"burner-filter-inserter"
		})

if data.raw.recipe["basic-circuit-board"] then -- bobs
  util.tech_lock_recipes(
      "electricity",  {
          "wooden-board",
          "basic-circuit-board"})
else
  util.tech_lock_recipes(
      "electricity",  {
          "electronic-circuit",
          "electronic-circuit-stone"
		  })
end


util.tech_lock_recipes(
    "filter-inserters",  {
      "filter-inserter"})

util.tech_lock_recipes(
    "radar",  {
        "radar"})

--[[

util.tech_lock_recipes(
    "radar",  {
        "radar"})

util.tech_lock_recipes(
    "radar",  {
        "radar"})
]]

util.tech_lock_recipes(
    "basic-fluid-handling",  {
        "pipe",
        "pipe-to-ground",
        "copper-pipe",
        "copper-pipe-to-ground",
        --"stone-pipe",
        --"stone-pipe-to-ground",
        --"offshore-pump",
		
		"pipe-elbow", -- Flow Control pipes
		"pipe-junction",-- Flow Control pipes
		"pipe-straight",-- Flow Control pipes
		
        "bob-valve"})

util.tech_lock_recipes(
    "fluid-handling",  {
        "pump"})

util.tech_lock_recipes(
    "steam-power",  {
        "boiler",
        "steam-engine"})

util.tech_lock_recipes(
    "electric-lab",  {
        "lab"})

util.tech_lock_recipes(
    "electric-mining",  {
        "electric-mining-drill"})

--util.tech_lock_recipes(
--    "concrete-walls",  {
--        "concrete-wall"})

--util.tech_lock_recipes(
--    "steel-walls",  {
--        "steel-wall"})

util.tech_lock_recipes(
    "circuit-network",  {
        "pushbutton"})
