
function get_quality_names()
local qualit = {}
if script.active_mods["quality"] then
    for name, proto in pairs(prototypes.quality) do
    if proto.level>0 then table.insert (qualit , {name=name, level=proto.level}) end
    end
end
return qualit
end