-- Paranoidal runtime rework of Factorissimo.
-- Storage initialization for it (deleted ids, building registrations, scheduled calls) runs in
-- on_configuration_changed, which this migration triggers by being applied.

-- Earlier versions toggled the "remove cables" permission of the hovering player's permission group
-- every time a power pole was selected, and left it as it was last set. Wires between factories and the
-- outside are script wires that players cannot remove anyway, so the permission is given back.
local remove_cables = defines.input_action.remove_cables
for _, group in pairs(game.permissions.groups) do
    if #group.players > 0 and not group.allows_action(remove_cables) then
        group.set_allows_action(remove_cables, true)
    end
end
