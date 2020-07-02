local OV = angelsmods.functions.OV

--REPLACE URANIUM HEXAFLUORIDE CENTRIFUGING RECIPE
data.raw.technology["advanced-uranium-processing-1"].effects =
{
	{type = "unlock-recipe", recipe = "solid-uranium-hexafluoride"},
	{type = "unlock-recipe", recipe = "solid-uranium-tetrafluoride"},
	{type = "unlock-recipe", recipe = "solid-uranium-oxide-1"},
	{type = "unlock-recipe", recipe = "clowns-centrifuging-20%-hexafluoride"},
}
--clobber vanilla and angels nuclear fuel recipes
if data.raw.technology["angels-nuclear-fuel"] then
	data.raw.technology["angels-nuclear-fuel"].enabled=false
end
if data.raw.technology["nuclear-fuel"] then
	data.raw.technology["nuclear-fuel"].enabled=false
end
--if advanced centrifuging, push bomb behind it
if data.raw.technology["advanced-centrifuging-2"] then
  data.raw["technology"]["atomic-bomb"].prerequisites = {"advanced-centrifuging-2"}
end
--if thorium ore add thorium mox fuel cell recipe, or move advanced uranium to nuclear 2 to allow all fuels
if data.raw.item["thorium-fuel-cell"] then
  --table.insert(data.raw["technology"]["mixed-oxide-fuel"].effects, {type = "unlock-recipe", recipe = "thorium-mixed-oxide"})
else
	table.insert(data.raw["technology"]["nuclear-fuel-reprocessing-2"].effects, {type = "unlock-recipe", recipe = "advanced-nuclear-fuel-reprocessing-2"})
end
--remove kovarex and remove it from bobingabout prereq
data.raw.technology["kovarex-enrichment-process"].enabled = false
if data.raw.technology["bobingabout-enrichment-process"] then
  OV.remove_prereq("bobingabout-enrichment-process", "kovarex-enrichment-process")
  clowns.functions.pre_req_repl("thorium-nuclear-fuel-reprocessing-2", "nuclear-fuel-reprocessing-2", "bobingabout-enrichment-process")
end
--set-up default tech names for centrifuge tech update
local centri_1="nuclear-power"
local centri_2="nuclear-power"
if settings.startup["MCP_enable_centrifuges"].value then
	centri_1="centrifuging-1"
	centri_2="centrifuging-2"
elseif mods["bobassembly"] and mods["bobassembly"] and settings.startup["bobmods-assembly-centrifuge"].value then
	centri_1="centrifuge-2"
	centri_2="centrifuge-3"
end

table.insert(data.raw["technology"][centri_1].effects, {type = "unlock-recipe", recipe = "depleted-uranium-reprocessing"})
table.insert(data.raw["technology"][centri_1].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-45%"})
table.insert(data.raw["technology"][centri_1].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-55%"})
table.insert(data.raw["technology"][centri_2].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-65%"})
table.insert(data.raw["technology"][centri_2].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-70%"})
table.insert(data.raw["technology"][centri_2].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-75%"})
table.insert(data.raw["technology"][centri_2].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-80%"})
table.insert(data.raw["technology"]["water-treatment-4"].effects, {type = "unlock-recipe", recipe = "radioactive-waste-water-purification"})
