---fixes for paranoidal

if bobmods and bobmods.plates then
    require("prototypes.remelting-override-bobplates")
end

if angelsmods and angelsmods.smelting then
    require("prototypes.remelting-override-angelssmelting")
end

if mods["Clowns-Processing"] then
    require("prototypes.remelting-override-clowns")
end