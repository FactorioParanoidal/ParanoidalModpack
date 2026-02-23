if settings.startup["pcp-replace-phenol-oxygen"].value then
	data.raw.recipe["angels-liquid-phenol"].ingredients = {
		{ type = "fluid", name = "angels-gas-benzene",           amount = 100 },
		{ type = "fluid", name = "gas-nitrous-oxide",            amount = 100 },
		{ type = "item",  name = "angels-catalyst-metal-yellow", amount = 1 },
	}
end

angelsmods.functions.OV.remove_unlock("angels-advanced-chemistry-4", "angels-liquid-phenol")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-5", "angels-liquid-phenol")
angelsmods.functions.OV.add_unlock("angels-nitrogen-processing-2", "hydrogen-cyanide-synthesis")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-5", "acetone-cyanohydrin-synthesis")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-5", "methyl-methacrylate-synthesis")
angelsmods.functions.OV.add_unlock("angels-chlorine-processing-1", "phosgene-synthesis")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-3", "vinyl-chloride-synthesis")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-5", "catalyst-metal-cyan")
angelsmods.functions.OV.add_unlock("angels-chlorine-processing-3", "gas-phosgene")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-5", "nitrous-oxide-synthesis-1")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-5", "nitrous-oxide-synthesis-2")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-5", "sodium-nitrate-synthesis")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-5", "acrylonitrile-synthesis")
angelsmods.functions.OV.add_prereq("military-science-pack", "flask")
angelsmods.functions.OV.add_prereq("chemical-science-pack", "flask")
angelsmods.functions.OV.add_prereq("angels-nitrogen-processing-2", "angels-gas-processing")
angelsmods.functions.OV.add_prereq("angels-advanced-chemistry-2", "angels-chlorine-processing-2")
angelsmods.functions.OV.add_prereq("plastic-pmma", "angels-advanced-chemistry-5")
angelsmods.functions.OV.add_prereq("rubber-processing", "angels-ore-processing-2")

if data.raw.item["bob-glass"] then
	angelsmods.functions.OV.add_prereq("flask", "angels-glass-smelting-1")
end
if mods.bobplates or mods.apm_resource_pack_ldinc and (data.raw.item["angels-solid-rubber"] or data.raw.item["bob-rubber"]) then
	angelsmods.functions.OV.add_unlock("angels-resin-3", "PF-resin")
	if not mods.bobplates then
		angelsmods.functions.OV.global_replace_item("angels-solid-rubber", "apm_rubber")
	end
end

data.raw["assembling-machine"]["angels-electrolyser"].energy_usage = "1500kW"
data.raw["assembling-machine"]["angels-electrolyser-2"].energy_usage = "2000kW"
data.raw["assembling-machine"]["angels-electrolyser-3"].energy_usage = "2500kW"
data.raw["assembling-machine"]["angels-electrolyser-4"].energy_usage = "3000kW"
data.raw.recipe["angels-gas-compressed-air"].energy_required = 1
data.raw.recipe["angels-air-separation"].energy_required = 1

angelsmods.functions.allow_productivity("liquid-plastic-abs")
angelsmods.functions.allow_productivity("liquid-plastic-pvc")
angelsmods.functions.allow_productivity("liquid-plastic-pmma")
angelsmods.functions.allow_productivity("liquid-plastic-pc")
--[[fallback require for glass
require("prototypes.bobs-glass-OV")
if data.raw.item["bob-glass"] then
	angelsmods.functions.allow_productivity("pc-glass")
	angelsmods.functions.allow_productivity("pmma-glass")
	angelsmods.functions.OV.add_unlock("plastic-pmma", "pmma-glass")
	angelsmods.functions.OV.add_unlock("plastic-pc", "pc-glass")
end]]
if data.raw.item["bob-zinc-ore"] and data.raw.item["bob-gold-ore"] then
	data.raw.recipe["catalyst-metal-cyan"].ingredients = {
		{ type = "item", name = "angels-catalyst-metal-carrier", amount = 10 },
		{ type = "item", name = "bob-zinc-ore",                  amount = 1 },
		{ type = "item", name = "bob-gold-ore",                  amount = 1 },
	}
elseif data.raw.item["angels-zinc-ore"] then
	data.raw.recipe["catalyst-metal-cyan"].ingredients = {
		{ type = "item", name = "angels-catalyst-metal-carrier", amount = 10 },
		{ type = "item", name = "angels-zinc-ore",               amount = 1 },
		{ type = "item", name = "angels-bauxite-ore",            amount = 1 },
	}
else --only petrochem
	data.raw.recipe["catalyst-metal-cyan"].ingredients = {
		{ type = "item", name = "angels-catalyst-metal-carrier", amount = 10 },
		{ type = "item", name = "angels-ore1",               amount = 1 },
		{ type = "item", name = "angels-ore4",            amount = 1 },
	}
end
if data.raw.item["ap-bullet-projectile"] then
	data.raw["wall"]["plaswall"].resistances = {
		{
			type = "physical",
			decrease = 3,
			percent = 20
		},
		{
			type = "impact",
			decrease = 45,
			percent = 60
		},
		{
			type = "explosion",
			decrease = 10,
			percent = 30
		},
		{
			type = "fire",
			percent = 100
		},
		{
			type = "laser",
			percent = 70
		}
	}
end

if angelsmods.functions.is_special_vanilla() then --revert removal settings
	local unhide_rec = {
		{ name = "angels-gas-butadiene",       tech = "angels-oil-steam-cracking-1" },
		{ name = "angels-liquid-styrene",      tech = "angels-advanced-chemistry-2" },
		{ name = "angels-liquid-ethylbenzene", tech = "angels-advanced-chemistry-2" },
		{ name = "angels-cumene-process",      tech = "angels-advanced-chemistry-4" },
		{ name = "angels-liquid-bisphenol-a",  tech = "angels-advanced-chemistry-4" },
		{ name = "gas-phosgene",               tech = "angels-chlorine-processing-3" },
	}
	for _, rec in pairs(unhide_rec) do
		recs = data.raw.recipe[rec.name]
		angelsmods.functions.OV.add_unlock(rec.tech, rec.name)
	end
	angelsmods.functions.OV.remove_unlock("angels-resin-3", "PF-resin")
end
