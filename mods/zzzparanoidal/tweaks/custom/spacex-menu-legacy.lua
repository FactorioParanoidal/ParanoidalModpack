-- SpaceX Get a Room (Ober3550): https://mods.factorio.com/mod/SpaceXGAR
-- Initial placement only: run before zzz's recipe/product sorting and compaction.
-- RCU is registered later; some SpaceMod items depend on classic mode.
for _, row in ipairs{
    {"a", "rocket-fuel low-density-structure rocket-control-unit satellite"},
    {"b", "rocket-silo"},
    {"x", "assembly-robot drydock-assembly drydock-structural spacex-combinator"},
    {"y", "fusion-reactor hull-component protection-field space-thruster fuel-cell habitation life-support command astrometrics ftl-drive"},
} do
    for name in row[2]:gmatch("%S+") do
        local item = data.raw.item[name]
        if item then item.subgroup = "space-exploration-" .. row[1] end
    end
end
