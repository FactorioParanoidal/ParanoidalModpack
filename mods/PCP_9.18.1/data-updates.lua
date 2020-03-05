require("prototypes.updates")
if settings.startup["pcp-glass-sink"].value ==true and
not mods["ScienceCostTweakerM"] and
not mods["MomoTweak"] and
not data.raw.item["flask"] then
    require("prototypes.flask")
end
