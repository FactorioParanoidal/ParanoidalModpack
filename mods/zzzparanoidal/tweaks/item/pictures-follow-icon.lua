-- Belt/ground graphics of these items repeat their final interface icon (user decision 2026-11-01):
-- separate Reskins pictures showed another artwork on belts. Without pictures the engine draws the icon.
-- Ingots with intended belt variations are not listed.
for _, name in ipairs({
    "bob-bronze-alloy", "bob-brass-alloy", "bob-gunmetal-alloy", "bob-invar-alloy", "bob-nitinol-alloy",
    "bob-cobalt-steel-alloy", "bob-copper-tungsten-alloy", "bob-alien-blue-alloy", "bob-alien-orange-alloy",
    "lithium-plate", "bob-gold-plate", "bob-zinc-plate", "bob-silicon-wafer", "iron-stick",
    "bob-titanium-gear-wheel", "bob-nitinol-gear-wheel", "bob-brass-gear-wheel", "bob-steel-gear-wheel",
    "bob-tungsten-gear-wheel", "bob-titanium-bearing", "bob-titanium-bearing-ball",
    "bob-nitinol-bearing", "bob-nitinol-bearing-ball",
}) do
    local item = data.raw.item[name]
    if item then item.pictures = nil end
end
