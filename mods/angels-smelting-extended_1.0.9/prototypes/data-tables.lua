coil_metals = {
    --as much as i would love to do the commented out ones... id need to think on how to do the powder/plastic systems
    ["tungsten"] = { tint = { r = 136 / 255, g = 98 / 255, b = 65 / 255 }, ing_1 = { type = "fluid", name = "gas-tungsten-hexafluoride", amount = 20 } },
}
if mods["bobplates"] then
    coil_metals["brass"] = { tint = { r = 204 / 256, g = 153 / 256, b = 102 / 256 } }
    coil_metals["bronze"] = { tint = { r = 224 / 256, g = 155 / 256, b = 58 / 256 } }
    coil_metals["nitinol"] = { tint = { r = 106 / 256, g = 92 / 256, b = 153 / 256 } }
    coil_metals["invar"] = { tint = { r = 95 / 256, g = 125 / 256, b = 122 / 256 } }
    coil_metals["cobalt-steel"] = { tint = { r = 61 / 256, g = 107 / 256, b = 153 / 256 } }
    coil_metals["gunmetal"] = { tint = { r = 224 / 256, g = 103 / 256, b = 70 / 256 } }
end
metal_tab = {
    --as much as i would love to do the commented out ones... id need to think on how to do the powder/plastic systems
    "copper",
    "stone",
    "steel",
    "plastic",
    --"ceramic",
    "titanium",
    "brass",
    "bronze",
    "tungsten",
    "copper-tungsten",
    "nitinol"
}
gears = {
    "steel",
    "nitinol",
    "titanium",
    "brass",
    "cobalt-steel",
    "tungsten"
}
a_inters = {
    ["angels-gear"]={metal="iron", icon = "gear", tech = "angels-components-mechanical-1", cost = 1, amount = 1},--iron gear is now the angels-gear
    ["angels-axle"] = { metal = "steel", icon = "axle", tech = "angels-components-mechanical-2", cost = 2, amount = 1 },
    ["angels-roller-chain"] = { metal = "aluminium", icon = "roller-chain", tech = "angels-components-mechanical-3", cost = 1, amount = 1 },
    ["angels-spring"] = { metal = "titanium", icon = "spring", tech = "angels-components-mechanical-4", cost = 1, amount = 1 },
    --["angels-bearing"]={metal="tungsten",icon="bearing",tech="mechanical-components-5"}, --not adding lube and steel to a casting
    ["grate-iron"] = { metal = "iron", tech = "angels-components-construction-2", cost = 2, amount = 0.5 },
    ["grate-steel"] = { metal = "steel", tech = "angels-components-construction-2", cost = 2, amount = 0.5 },
    ["grate-aluminium"] = { metal = "aluminium", tech = "angels-components-construction-3", cost = 2, amount = 1 },
    ["grate-titanium"] = { metal = "titanium", tech = "angels-components-construction-4", cost = 2, amount = 1 },
    ["grate-tungsten"] = { metal = "tungsten", tech = "angels-components-construction-5", cost = 2, amount = 1 },
    ["angels-girder"] = { metal = "iron", icon = "girder", tech = "angels-components-construction-2", cost = 1, amount = 1 },
    ["angels-rivet"] = { metal = "steel", icon = "rivet", tech = "angels-components-construction-2", cost = 1, amount = 1 },
    ["angels-bracket"] = { metal = "aluminium", icon = "bracket", tech = "angels-components-construction-3", cost = 1, amount = 1 },
    ["angels-plating"] = { metal = "titanium", icon = "plating", tech = "angels-components-construction-4", cost = 1, amount = 1 },
    ["angels-strut"] = { metal = "tungsten", icon = "strut", tech = "angels-components-construction-5", cost = 1, amount = 1 },
    ["body-1"] = { metal = "iron", tech = "angels-components-weapons-basic", cost = 2, amount = 1 },
    ["body-2"] = { metal = "steel", tech = "military", cost = 2, amount = 1 },
    ["body-3"] = { metal = "aluminium", tech = "military-2", cost = 2, amount = 1 },
    ["body-4"] = { metal = "titanium", tech = "angels-components-weapons-advanced", cost = 2, amount = 1 },
    ["body-5"] = { metal = "tungsten", tech = "military-3", cost = 2, amount = 1 },
    ["angels-trigger"] = { metal = "iron", icon = "trigger", tech = "angels-components-weapons-basic", cost = 1, amount = 1 },
    ["angels-explosionchamber"] = { metal = "steel", icon = "explosion-chamber", tech = "military", cost = 1, amount = 1 },
    ["angels-fluidchamber"] = { metal = "aluminium", icon = "fluid-chamber", tech = "military-2", cost = 1, amount = 1 },
    ["angels-energycrystal"] = { metal = "titanium", icon = "energy-chamber", tech = "angels-components-weapons-advanced", cost = 1, amount = 1 },
    --["angels-acceleratorcoil"]={metal="tungsten",icon="accelerator-coil",tech="military-3"}
}
shielding = {
    { metal = "copper", order = "i-z" },
    { metal = "tin", order = "h-z" },
    { metal = "silver", order = "l-z"},
    { metal = "gold", order = "k-z"},
    { metal = "platinum", order = "j-z"}
}
