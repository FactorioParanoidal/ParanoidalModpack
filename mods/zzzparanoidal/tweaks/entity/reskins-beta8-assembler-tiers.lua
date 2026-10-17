-- Beta 8's standard assemblers use color tiers 0..5; Reskins 2.3 uses 1..6.
-- Use Reskins itself before the pack's final recipe/item icon restoration.
if not (reskins and reskins.bobs and reskins.bobs.triggers.assembly.entities) then return end
if reskins.lib.settings.get_value("reskins-lib-tier-mapping") ~= "traditional-map" then return end
for index, name in ipairs({
    "assembling-machine-1", "assembling-machine-2", "assembling-machine-3",
    "bob-assembling-machine-4", "bob-assembling-machine-5", "bob-assembling-machine-6",
}) do
    if data.raw["assembling-machine"][name] then
        reskins.lib.apply_skin.assembling_machine(name, index - 1, nil, nil, { sprite_set = index - 1 })
    end
end
