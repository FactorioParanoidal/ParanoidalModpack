-- Automatic-Cursed-FMD 9.0.0: native resource filters, not per-ore drill copies.
-- Fluid-output extractors keep their original behaviour and prototypes.
local drills = {}
for name, drill in pairs(data.raw["mining-drill"]) do
    if drill.input_fluid_box and not drill.output_fluid_box and drill.vector_to_place_result then
        drill.filter_count = math.max(drill.filter_count or 0, 1)
        drills[name] = true
    end
end
data:extend({{
    type = "mod-data",
    name = "automatic-cursed-fmd",
    data = {version = "9.0.0", drills = drills},
}})
