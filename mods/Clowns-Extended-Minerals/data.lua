--set up clowns ore listing
clowns.tables.ores={"clowns-ore1","clowns-ore4","clowns-ore5","clowns-ore7"}
if not clowns.special_vanilla then
  table.insert(clowns.tables.ores,"clowns-ore2")
  table.insert(clowns.tables.ores,"clowns-ore3")
  table.insert(clowns.tables.ores,"clowns-ore6")
  table.insert(clowns.tables.ores,"clowns-ore8")
  table.insert(clowns.tables.ores,"clowns-ore9")
end
--set metalic ore tables and triggers for sorting
require("prototypes.generation.angels-trigger-sets")
clowns.functions.triggers_on()

require("prototypes.categories")
require("prototypes.lookup-tables")

require("prototypes.generation.clowns-ore-set")
require("prototypes.generation.clowns-resource-set") --waiting for angels next update to activate the new method
angelsmods.functions.make_resource()

require("prototypes.items.item-builder")
require("prototypes.items.resource-processing")

require("prototypes.recipes.ore-refining")
require("prototypes.recipes.ore-sorting-mix")
require("prototypes.recipes.ore-sorting")
require("prototypes.recipes.ore-sorting-mix-static")

require("prototypes.recipes.liquification")
--require("prototypes.recipes.mining")
require("prototypes.recipes.sluicing")

require("prototypes.technology.water-treatment")
require("prototypes.technology.ore-refining")

--functions for omnimatter crystals
require("prototypes.omnicrystals.omnicrystal_functions")
--CONFIGURE RESOURCES WITH OMNIMATTER FUNCTIONS, INPUTS ARE {NAME, TIER??, LOCALE, NAME OF MOD}
--[[local ore1fluid,ore2fluid,ore3fluid,ore4fluid,ore5fluid,ore6fluid,ore7fluid,ore8fluid,ore9fluid
	ore1fluid = "angels-liquid-hydrofluoric-acid"
	ore3fluid = "angels-liquid-nitric-acid"
	ore4fluid = "angels-liquid-hydrochloric-acid"
	ore5fluid = "angels-liquid-nitric-acid"
	ore7fluid = "angels-liquid-hydrofluoric-acid"
	ore8fluid = "angels-liquid-hydrochloric-acid"
	ore9fluid = "clowns-liquid-phosphoric-acid"
	ore2fluid = "sulfuric-acid"
	ore6fluid = "sulfuric-acid"
	res1fluid = "clowns-liquid-phosphoric-acid"
	res2fluid = "steam"]]

if mods["omnimatter"] then
	omni.matter.add_resource("clowns-ore1",3,"Adamantite","Clowns-Extended-Minerals")
	omni.matter.add_resource("clowns-ore2",2,"Antitate","Clowns-Extended-Minerals")
	omni.matter.add_resource("clowns-ore3",2,"Pro-Galena","Clowns-Extended-Minerals")
	omni.matter.add_resource("clowns-ore4",2,"Orichalcite","Clowns-Extended-Minerals")
	omni.matter.add_resource("clowns-ore5",2,"Phosphorite","Clowns-Extended-Minerals")
	omni.matter.add_resource("clowns-ore6",3,"Sanguinate","Clowns-Extended-Minerals")
	omni.matter.add_resource("clowns-ore7",3,"Elionagate","Clowns-Extended-Minerals")
	omni.matter.add_resource("clowns-ore8",3,"Meta-Garnierite","Clowns-Extended-Minerals")
	omni.matter.add_resource("clowns-ore9",3,"Nova-Leucoxene","Clowns-Extended-Minerals")
	omni.matter.add_resource("clowns-resource1",2,"Alluvial Deposit","Clowns-Extended-Minerals")
	omni.matter.add_resource("clowns-resource2",2,"Oil Sands","Clowns-Extended-Minerals")
end

--APPLY THE EFFECTS OF SETTINGS THAT ARE RELEVANT TO ANGEL'S INFINITE ORES
if mods["angelsinfiniteores"] and angelsmods.ores.enablefluidreq then
	if settings.startup["enableinfiniteclownsore1"].value then
		data.raw["resource"]["infinite-clowns-ore1"].minable.fluid_amount = 10
		--data.raw["resource"]["infinite-clowns-ore1"].minable.required_fluid = ore1fluid
	end
	if settings.startup["enableinfiniteclownsore2"].value and not clowns.special_vanilla then
		data.raw["resource"]["infinite-clowns-ore2"].minable.fluid_amount = 10
		--data.raw["resource"]["infinite-clowns-ore2"].minable.required_fluid = ore2fluid
	end
	if settings.startup["enableinfiniteclownsore3"].value and not clowns.special_vanilla then
		data.raw["resource"]["infinite-clowns-ore3"].minable.fluid_amount = 10
		--data.raw["resource"]["infinite-clowns-ore3"].minable.required_fluid = ore3fluid
	end
	if settings.startup["enableinfiniteclownsore4"].value then
		data.raw["resource"]["infinite-clowns-ore4"].minable.fluid_amount = 10
		--data.raw["resource"]["infinite-clowns-ore4"].minable.required_fluid = ore4fluid
	end
	if settings.startup["enableinfiniteclownsore5"].value then
		data.raw["resource"]["infinite-clowns-ore5"].minable.fluid_amount = 10
		--data.raw["resource"]["infinite-clowns-ore5"].minable.required_fluid = ore5fluid
	end
	if settings.startup["enableinfiniteclownsore6"].value and not clowns.special_vanilla then
		data.raw["resource"]["infinite-clowns-ore6"].minable.fluid_amount = 10
		--data.raw["resource"]["infinite-clowns-ore6"].minable.required_fluid = ore6fluid
	end
	if settings.startup["enableinfiniteclownsore7"].value then
		data.raw["resource"]["infinite-clowns-ore7"].minable.fluid_amount = 10
		--data.raw["resource"]["infinite-clowns-ore7"].minable.required_fluid = ore7fluid
  end
  if settings.startup["enableinfiniteclownsore8"].value and not clowns.special_vanilla then
		data.raw["resource"]["infinite-clowns-ore8"].minable.fluid_amount = 10
		--data.raw["resource"]["infinite-clowns-ore8"].minable.required_fluid = ore8fluid
  end
  if settings.startup["enableinfiniteclownsore9"].value and not clowns.special_vanilla then
		data.raw["resource"]["infinite-clowns-ore9"].minable.fluid_amount = 10
		--data.raw["resource"]["infinite-clowns-ore9"].minable.required_fluid = ore9fluid
	end
	if settings.startup["enableinfiniteclownsresource1"].value then
    	data.raw["resource"]["infinite-clowns-resource1"].minable.fluid_amount = 10
    --data.raw["resource"]["infinite-clowns-resource1"].minable.required_fluid = res1fluid
	end
	if settings.startup["enableinfiniteclownsresource2"].value then
		data.raw["resource"]["infinite-clowns-resource2"].minable.fluid_amount = 50
		--data.raw["resource"]["infinite-clowns-resource2"].minable.required_fluid = res2fluid
	end
end
--reverse triggers, and let angel take them back
clowns.functions.triggers_off()