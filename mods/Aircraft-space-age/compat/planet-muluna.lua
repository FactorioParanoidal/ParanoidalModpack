local rro = require("lib.remove-replace-object")
if mods["planet-muluna"] then
    rro.remove(data.raw["technology"]["afterburner"].unit.ingredients,{"space-science-pack",1})
    data.raw["technology"]["afterburner"].unit.count = 500
end