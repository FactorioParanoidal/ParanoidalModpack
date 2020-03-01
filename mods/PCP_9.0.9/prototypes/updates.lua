data.raw.recipe["gas-phenol-catalyst"].ingredients= {{type="fluid", name="gas-benzene", amount=100},
													 {type="fluid", name="gas-nitrous-oxide", amount=100},
													 {type="item", name="catalyst-metal-yellow", amount=1}}
angelsmods.functions.OV.add_unlock("angels-nitrogen-processing-2", "hydrogen-cyanide-synthesis")
angelsmods.functions.OV.add_unlock("angels-nitrogen-processing-2", "acetone-cyanohydrin-synthesis")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-3", "cumene-process")
--angelsmods.functions.OV.add_unlock("basic-chemistry-2", "water-gas-shift-reaction")
--angelsmods.functions.OV.add_unlock("basic-chemistry-2", "reverse-water-gas-shift-reaction")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-4", "catalyst-metal-yellow")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-4", "bisphenol-a-synthesis")
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-2", "methyl-methacrylate-synthesis")
angelsmods.functions.OV.remove_unlock("angels-advanced-chemistry-4", "gas-phenol-catalyst")
angelsmods.functions.OV.add_unlock("chlorine-processing-1", "phosgene-synthesis")
angelsmods.functions.OV.add_unlock("chlorine-processing-2", "vinyl-chloride-synthesis")
--[[data.raw["assembling-machine"]["angels-electrolyser"].energy_usage= "1500kW"
data.raw["assembling-machine"]["angels-electrolyser-2"].energy_usage= "2000kW"
data.raw["assembling-machine"]["angels-electrolyser-3"].energy_usage= "2500kW"
data.raw["assembling-machine"]["angels-electrolyser-4"].energy_usage= "3000kW"]]
data.raw.recipe["angels-air-filtering"].energy_required= 1
data.raw.recipe["air-separation"].energy_required= 1													 
--[[data.raw.recipe["gas-ammonia"].order= "c[gas-ammonia]"
data.raw.recipe["gas-nitrogen-dioxide"].order= "e[gas-nitrogen-dioxide]"
data.raw.recipe["liquid-nitric-acid"].order= "f[liquid-nitric-acid]"
data.raw.recipe["gas-urea"].order= "g[gas-urea]"
data.raw.recipe["gas-melamine"].order= "h[gas-melamine]"
data.raw.recipe["gas-ammonium-chloride"].order= "i[gas-ammonium-chloride]"]]

