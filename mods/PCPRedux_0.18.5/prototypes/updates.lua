if settings.startup["pcp-replace-phenol-oxygen"].value then
	data.raw.recipe["gas-phenol-catalyst"].ingredients= {
		{type="fluid", name="gas-benzene", amount=100},
		{type="fluid", name="gas-nitrous-oxide", amount=100},
		{type="item", name="catalyst-metal-yellow", amount=1},
	}
end
angelsmods.functions.OV.remove_unlock("angels-advanced-chemistry-4", "gas-phenol-catalyst")
angelsmods.functions.OV.add_unlock("k-angels-advanced-chemistry-5", "gas-phenol-catalyst")
angelsmods.functions.OV.add_unlock("angels-nitrogen-processing-2", "hydrogen-cyanide-synthesis")
angelsmods.functions.OV.add_unlock("angels-nitrogen-processing-2", "acetone-cyanohydrin-synthesis")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-4", "catalyst-metal-yellow")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-2", "methyl-methacrylate-synthesis")
angelsmods.functions.OV.add_unlock("chlorine-processing-1", "phosgene-synthesis")
angelsmods.functions.OV.add_unlock("chlorine-processing-2", "vinyl-chloride-synthesis")
angelsmods.functions.OV.add_unlock("k-angels-advanced-chemistry-5", "catalyst-metal-cyan")
angelsmods.functions.OV.add_unlock("resin-3", "PF-resin")

data.raw["assembling-machine"]["angels-electrolyser"].energy_usage= "1500kW"
data.raw["assembling-machine"]["angels-electrolyser-2"].energy_usage= "2000kW"
data.raw["assembling-machine"]["angels-electrolyser-3"].energy_usage= "2500kW"
data.raw["assembling-machine"]["angels-electrolyser-4"].energy_usage= "3000kW"
data.raw.recipe["angels-air-filtering"].energy_required= 1
data.raw.recipe["air-separation"].energy_required= 1

angelsmods.functions.allow_productivity("liquid-plastic-abs")
angelsmods.functions.allow_productivity("liquid-plastic-pvc")
angelsmods.functions.allow_productivity("liquid-plastic-pmma")
angelsmods.functions.allow_productivity("liquid-plastic-pc")
if data.raw.item["glass"] then
	angelsmods.functions.allow_productivity("pc-glass")
	angelsmods.functions.allow_productivity("pmma-glass")
	angelsmods.functions.OV.add_unlock("plastic-pmma", "pmma-glass")
	angelsmods.functions.OV.add_unlock("plastic-pc", "pc-glass")
end
if data.raw.item["zinc-ore"] and data.raw.item["gold-ore"] then
	data.raw.recipe["catalyst-metal-cyan"].ingredients ={
		{type="item", name="catalyst-metal-carrier", amount=10},
		{type="item", name="zinc-ore", amount=1},
		{type="item", name="gold-ore", amount=1},
	}
else
	data.raw.recipe["catalyst-metal-cyan"].ingredients ={
		{type="item", name="catalyst-metal-carrier", amount=10},
		{type="item", name="angels-iron-pebbles", amount=1},
		{type="item", name="angels-copper-pebbles", amount=1},
	}
end
if data.raw.item["ap-bullet-projectile"] then
	data.raw["wall"]["plaswall"].resistances ={
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
local unhide_rec= {      
  {name = "catalyst-steam-cracking-butane", tech = "oil-steam-cracking-1"},
  {name = "gas-styrene-catalyst", tech = "angels-advanced-chemistry-2"},
  {name = "gas-ethylbenzene-catalyst", tech ="angels-advanced-chemistry-2"},
  {name = "cumene-process", tech = "angels-advanced-chemistry-4"},
  {name = "gas-bisphenol-a", tech = "angels-advanced-chemistry-4"},
  {name = "gas-phosgene", tech = "chlorine-processing-3"},
}
  for _,rec in pairs(unhide_rec) do
    recs=data.raw.recipe[rec.name]
    angelsmods.functions.OV.add_unlock(rec.tech, rec.name)
  end
  angelsmods.functions.OV.remove_unlock("resin-3", "PF-resin")
end