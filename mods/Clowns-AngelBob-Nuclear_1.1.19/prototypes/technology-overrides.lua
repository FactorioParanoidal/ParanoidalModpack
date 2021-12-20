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
if data.raw.item["thorium-fuel-cell"] or data.raw.item["angels-thorium-fuel-cell"] then
  --table.insert(data.raw["technology"]["mixed-oxide-fuel"].effects, {type = "unlock-recipe", recipe = "thorium-mixed-oxide"})
	OV.disable_recipe("angels-thorium-processing")
	OV.add_prereq("angels-thorium-power","thorium-ore-processing")
else
	clowns.functions.add_unlock("nuclear-fuel-reprocessing-2","advanced-nuclear-fuel-reprocessing-2")
end
--remove kovarex and remove it from bobingabout prereq
data.raw.technology["kovarex-enrichment-process"].enabled = false
clowns.functions.pre_req_repl("atomic-bomb","kovarex-enrichment-process","nuclear-power")
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

clowns.functions.add_unlock(centri_1,"depleted-uranium-reprocessing")
clowns.functions.add_unlock(centri_1,"clowns-centrifuging-45%")
clowns.functions.add_unlock(centri_1,"clowns-centrifuging-55%")
clowns.functions.add_unlock(centri_2,"clowns-centrifuging-65%")
clowns.functions.add_unlock(centri_2,"clowns-centrifuging-70%")
clowns.functions.add_unlock(centri_2,"clowns-centrifuging-75%")
clowns.functions.add_unlock(centri_2,"clowns-centrifuging-80%")
clowns.functions.add_unlock("water-treatment-4","radioactive-waste-water-purification")
