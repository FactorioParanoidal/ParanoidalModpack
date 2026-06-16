
function get_quality_names(max_level)
local qualit = {}
max_level=max_level or 100
if script.active_mods["quality"] then
    for name, proto in pairs(prototypes.quality) do
    if proto.level>0 and proto.level<=max_level then table.insert (qualit , {name=name, level=proto.level}) end
    end
end
return qualit
end