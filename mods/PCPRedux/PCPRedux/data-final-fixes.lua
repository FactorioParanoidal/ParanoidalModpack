--[[ if mods["ShinyIcons"] and data.raw["item-subgroup"]["shinywalls1"] then
if data.raw.recipe["plaswall"] then
  data.raw["item"]["plaswall"].group="combat"
  data.raw["item"]["plaswall"].subgroup="shinywalls1"
  data.raw["recipe"]["plaswall"].group="combat"
  data.raw["recipe"]["plaswall"].subgroup="shinywalls1"
	end
end ]]
if data.raw.item["bob-rubber"] or data.raw.item["angels-solid-rubber"] --[[or data.raw.item["apm_rubber"] ]] then
  --  require("prototypes.rubber-extended")
  angelsmods.functions.OV.add_unlock("angels-steam-cracking-1", "catalyst-steam-cracking-butane-2")
  angelsmods.functions.OV.add_unlock("angels-chlorine-processing-2", "butadiene-chlorination")
  angelsmods.functions.OV.add_unlock("angels-chlorine-processing-2", "dichlorobutene-dechlorination")
  angelsmods.functions.OV.add_unlock("angels-rubber", "liquid-rubber-2")
  angelsmods.functions.OV.add_unlock("angels-steam-cracking-2", "vinyl-acetlyene-chlorination")
  angelsmods.functions.OV.add_unlock("angels-steam-cracking-2", "acetylene-diomerisation")
  angelsmods.functions.OV.add_unlock("angels-steam-cracking-2", "catalyst-steam-cracking-acetylene")
  angelsmods.functions.allow_productivity("angels-roll-rubber-converting")
  --[[  if data.raw.item["solid-saw"] and type(data.raw.recipe["rubber-slabbing"].ingredients)=="table" then
    table.insert(data.raw.recipe["rubber-slabbing"].ingredients,{type="item",name="solid-saw",amount=1})
    table.insert(data.raw.recipe["rubber-slabbing"].results,{type="item",name="solid-saw",{amount=1,probability=0.95}})
  end]]
end
