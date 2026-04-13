local reverserMods = {
    "belt-reverser", "belt-reverser2", "belt-reverser-space-age", "belt-reverserup-fixed"
}
local notNeeded = false

for _, mod in pairs(reverserMods) do
    if mods[mod] then
        notNeeded = true
    end
end
if not notNeeded then
    data:extend{{type = 'custom-input', name = 'picker-reverse-belts', key_sequence = 'CONTROL + R'}}
end