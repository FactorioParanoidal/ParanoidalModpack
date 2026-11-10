local audit = require("rules").apply(data.raw, defines.prototypes.item, mods, settings.startup,
    angelsmods and angelsmods.trigger or {},
    require("__paranoidal-stack-sizes__/selection").get(),
    require("__paranoidal-stack-sizes__/requests").get())
data:extend({{type = "mod-data", name = "paranoidal-stack-sizes-audit", data = audit}})
log("Stack sizes: " .. audit.count .. " item prototypes, " .. audit.changed .. " changed in one final pass")
