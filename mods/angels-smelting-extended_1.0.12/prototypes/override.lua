require("prototypes.data-tables")
angelsmods.functions.OV.add_unlock("angels-tungsten-smelting-2", "angels-roll-tungsten-casting")
angelsmods.functions.OV.add_unlock("angels-tungsten-smelting-2", "angels-roll-tungsten-converting")
angelsmods.functions.allow_productivity("angels-roll-tungsten-converting")
if mods["bobplates"] then -- just in case angels overrides miss the ones in this mod
    --brass
    angelsmods.functions.OV.global_replace_item("angels-plate-brass", "brass-alloy")
    --bronze
    angelsmods.functions.OV.global_replace_item("angels-plate-bronze", "bronze-alloy")
    --gunmetal
    angelsmods.functions.OV.global_replace_item("angels-plate-gunmetal", "gunmetal-alloy")
    --invar
    angelsmods.functions.OV.global_replace_item("angels-plate-invar", "invar-alloy")
    --nitinol
    angelsmods.functions.OV.global_replace_item("angels-plate-nitinol", "nitinol-alloy")
    --cobalt-steel
    angelsmods.functions.OV.global_replace_item("angels-plate-cobalt-steel", "cobalt-steel-alloy")
end
--==CLEANS UP RECIPE/ITEM ORDER AND EXPANDS ALLOYS TO BE IN THEIR OWN CATEGORIES==--
angelsmods.functions.OV.add_unlock("angels-tungsten-smelting-3", "angels-roll-tungsten-casting-fast")
--BRASS
if angelsmods.trigger.smelting_products["brass"].plate then
    data.raw.recipe["angels-brass-smelting-1"].order = "angels-brass-casting"
    data.raw.recipe["angels-brass-smelting-2"].order = "angels-brass-casting"
    data.raw.recipe["angels-brass-smelting-3"].order = "angels-brass-casting"
    data.raw.recipe["angels-brass-smelting-1"].order = "a"
    data.raw.recipe["angels-brass-smelting-2"].order = "b"
    data.raw.recipe["angels-brass-smelting-3"].order = "c"
    data.raw.recipe["angels-plate-brass"].order = "i"
    data.raw.recipe["brass-alloy"].order = "k"
    angelsmods.functions.OV.add_unlock("angels-brass-smelting-2", "angels-roll-brass-casting")
    angelsmods.functions.OV.add_unlock("angels-brass-smelting-2", "angels-roll-brass-converting")
    angelsmods.functions.OV.add_unlock("angels-brass-smelting-3", "angels-roll-brass-casting-fast")
end
--Bronze
if angelsmods.trigger.smelting_products["bronze"].plate then
    data.raw.recipe["angels-bronze-smelting-1"].subgroup = "angels-bronze-casting"
    data.raw.recipe["angels-bronze-smelting-2"].subgroup = "angels-bronze-casting"
    data.raw.recipe["angels-bronze-smelting-3"].subgroup = "angels-bronze-casting"
    data.raw.recipe["angels-plate-bronze"].subgroup = "angels-bronze-casting"
    data.raw.recipe["bronze-alloy"].subgroup = "angels-bronze-casting"
    data.raw.recipe["angels-bronze-smelting-1"].order = "a"
    data.raw.recipe["angels-bronze-smelting-2"].order = "b"
    data.raw.recipe["angels-bronze-smelting-3"].order = "c"
    data.raw.recipe["angels-plate-bronze"].order = "i"
    data.raw.recipe["bronze-alloy"].order = "k"
    angelsmods.functions.OV.add_unlock("angels-bronze-smelting-2", "angels-roll-bronze-casting")
    angelsmods.functions.OV.add_unlock("angels-bronze-smelting-2", "angels-roll-bronze-converting")
    angelsmods.functions.OV.add_unlock("angels-bronze-smelting-3", "angels-roll-bronze-casting-fast")
end
--Invar
if angelsmods.trigger.smelting_products["invar"].plate then
    data.raw.recipe["angels-invar-smelting-1"].subgroup = "angels-invar-casting"
    data.raw.recipe["angels-plate-invar"].subgroup = "angels-invar-casting"
    data.raw.recipe["invar-alloy"].subgroup = "angels-invar-casting"
    data.raw.recipe["angels-invar-smelting-1"].order = "a"
    data.raw.recipe["angels-plate-invar"].order = "i"
    data.raw.recipe["invar-alloy"].order = "k"
    angelsmods.functions.OV.add_unlock("angels-alloys-smelting-2", "angels-roll-invar-casting")
    angelsmods.functions.OV.add_unlock("angels-alloys-smelting-2", "angels-roll-invar-converting")
    angelsmods.functions.OV.add_unlock("angels-alloys-smelting-3", "angels-roll-invar-casting-fast")
end
--Nitinol
if angelsmods.trigger.smelting_products["nitinol"].plate then
    data.raw.recipe["angels-nitinol-smelting-1"].subgroup = "angels-nitinol-casting"
    data.raw.recipe["angels-plate-nitinol"].subgroup = "angels-nitinol-casting"
    data.raw.recipe["nitinol-alloy"].subgroup = "angels-nitinol-casting"
    data.raw.recipe["angels-nitinol-smelting-1"].order = "a"
    data.raw.recipe["angels-plate-nitinol"].order = "i"
    data.raw.recipe["nitinol-alloy"].order = "k"
    angelsmods.functions.OV.add_unlock("nitinol-processing", "angels-roll-nitinol-casting")
    angelsmods.functions.OV.add_unlock("nitinol-processing", "angels-roll-nitinol-converting")
    angelsmods.functions.OV.add_unlock("angels-alloys-smelting-3", "angels-roll-nitinol-casting-fast")
end
--Cobalt-Steel
if angelsmods.trigger.smelting_products["cobalt-steel"].plate then
    data.raw.recipe["angels-cobalt-steel-smelting-1"].subgroup = "angels-cobalt-steel-casting"
    data.raw.recipe["angels-plate-cobalt-steel"].subgroup = "angels-cobalt-steel-casting"
    data.raw.recipe["cobalt-steel-alloy"].subgroup = "angels-cobalt-steel-casting"
    data.raw.recipe["angels-cobalt-steel-smelting-1"].order = "a"
    data.raw.recipe["angels-plate-cobalt-steel"].order = "i"
    data.raw.recipe["cobalt-steel-alloy"].order = "k"
    angelsmods.functions.OV.add_unlock("angels-alloys-smelting-2", "angels-roll-cobalt-steel-casting")
    angelsmods.functions.OV.add_unlock("angels-alloys-smelting-2", "angels-roll-cobalt-steel-converting")
    angelsmods.functions.OV.add_unlock("angels-alloys-smelting-3", "angels-roll-cobalt-steel-casting-fast")
end
--gunmetal
if angelsmods.trigger.smelting_products["gunmetal"].plate then
    data.raw.recipe["angels-gunmetal-smelting-1"].order = "a"
    data.raw.recipe["angels-plate-gunmetal"].order = "i"
    data.raw.recipe["gunmetal-alloy"].order = "k"
    angelsmods.functions.OV.add_unlock("angels-alloys-smelting-2", "angels-roll-gunmetal-casting")
    angelsmods.functions.OV.add_unlock("angels-alloys-smelting-2", "angels-roll-gunmetal-converting")
    angelsmods.functions.OV.add_unlock("angels-alloys-smelting-3", "angels-roll-gunmetal-casting-fast")
end
--Add unlocks for pipes
if mods["boblogistics"] and mods["bobplates"] then
    for n, metal in pairs(ASE.tables.metal_tab) do
        angelsmods.functions.OV.add_unlock("angels-" .. metal .. "-smelting-1", "angels-" .. metal .. "-pipe-casting")
        angelsmods.functions.OV.add_unlock("angels-" .. metal .. "-smelting-1", "angels-" .. metal .. "-pipe-to-ground-casting")
    end
    --patch non compliants
    --plastic
    angelsmods.functions.OV.add_unlock("plastic-1", "angels-plastic-pipe-casting")
    angelsmods.functions.OV.add_unlock("plastic-1", "angels-plastic-pipe-to-ground-casting")
    --stone
    angelsmods.functions.OV.add_unlock("powder-metallurgy-1", "angels-stone-pipe-casting")
    angelsmods.functions.OV.add_unlock("powder-metallurgy-1", "angels-stone-pipe-to-ground-casting")
    --copper-tungsten
    angelsmods.functions.OV.add_unlock("tungsten-alloy-processing", "angels-copper-tungsten-pipe-casting")
    angelsmods.functions.OV.add_unlock("tungsten-alloy-processing", "angels-copper-tungsten-pipe-to-ground-casting")
end
--find activation settings
if mods["angelsindustries"] and angelsmods.industries.components then
    for item, i in pairs(ASE.tables.a_inters) do
        angelsmods.functions.OV.add_unlock(i.tech, item .. "-casting")
        angelsmods.functions.OV.add_unlock(i.tech, "ASE-" .. item .. "-casting-expendable")
        angelsmods.functions.OV.add_unlock(i.tech, "ASE-" .. item .. "-casting-advanced")
    end
    for n, item in pairs(ASE.tables.shielding) do
        angelsmods.functions.OV.add_unlock("angels-" .. item.metal .. "-smelting-2", "angels-shielding-coil-" .. item.metal .. "-casting")
        angelsmods.functions.OV.add_unlock("angels-" .. item.metal .. "-smelting-2", "angels-shielding-coil-" .. item.metal .. "-converting")
        angelsmods.functions.OV.add_unlock("angels-" .. item.metal .. "-smelting-3", "angels-shielding-coil-" .. item.metal .. "-casting-fast")
    end
    --add girder stack recipes
    angelsmods.functions.OV.add_unlock("angels-iron-smelting-2", "girder-stack-casting")
    angelsmods.functions.OV.add_unlock("angels-iron-smelting-2", "angels-girder-stack-converting")
    angelsmods.functions.OV.add_unlock("angels-iron-smelting-3", "girder-stack-casting-fast")
    --if mods["bobplates"] then --replace iron gear icons --activates for all conditions
    data.raw.recipe["angels-iron-gear-wheel-casting"].localised_name={"recipe-name.angels-advanced-regular","Mechanical Parts"}
    data.raw.recipe["ASE-iron-gear-casting-expendable"].icons[1]={icon="__angelsindustries__/graphics/icons/mechanical-parts.png",icon_size=32,}
    data.raw.recipe["ASE-iron-gear-casting-expendable"].localised_name={"recipe-name.angels-advanced-expendable","Mechanical Parts"}
    data.raw.recipe["ASE-iron-gear-casting-advanced"].icons[1]={icon="__angelsindustries__/graphics/icons/mechanical-parts.png",icon_size=32,}
    data.raw.recipe["ASE-iron-gear-casting-advanced"].localised_name={"recipe-name.angels-advanced-crafting","Mechanical Parts"}
    --end
    --disable the recipes for iron gear wheels since they convert to recipes for mechanical parts
    angelsmods.functions.OV.disable_recipe("angels-iron-gear-wheel-casting")
    angelsmods.functions.OV.disable_recipe("ASE-iron-gear-casting-expendable")
    angelsmods.functions.OV.disable_recipe("ASE-iron-gear-casting-advanced")
end
if data.raw.item["insulated-cable"] then
    angelsmods.functions.OV.add_unlock("rubber", "angels-wire-coil-insulated-casting")
    angelsmods.functions.OV.add_unlock("rubber", "angels-wire-coil-insulated-converting")
    angelsmods.functions.OV.add_unlock("rubber", "angels-wire-coil-insulated-casting-fast")
    angelsmods.functions.allow_productivity("angels-wire-coil-insulated-converting")
    angelsmods.functions.allow_bio_productivity("angels-wire-coil-insulated-converting")--only because the competing chain has access :(
end
-- EXECUTE OVERRIDES
angelsmods.functions.OV.execute()
