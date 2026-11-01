-- Belt Brush (from beltbrush2-reforged). Names are unchanged, so custom keybindings are kept.
-- Paranoidal defaults: type and balancer cycling moved from CONTROL + R / CONTROL + B to ALT + C / ALT + B;
-- CONTROL + R is taken by Factory Planner, Bob's Inserters, Factorissimo and RuNames, CONTROL + B by the
-- planner menu of this mod.
data:extend({
    {
        type = 'custom-input',
        name = 'beltbrush-cycle-corners',
        order = 'beltbrush[a]',
        key_sequence = 'ALT + C'
    },
    {
        type = 'custom-input',
        name = 'beltbrush-cycle-corners-rev',
        order = 'beltbrush[b]',
        key_sequence = 'ALT + SHIFT + C'
    },
    {
        type = 'custom-input',
        name = 'beltbrush-line-longer',
        order = 'beltbrush[c]',
        key_sequence = 'CONTROL + SHIFT + EQUALS'
    },
    {
        type = 'custom-input',
        name = 'beltbrush-line-shorter',
        order = 'beltbrush[d]',
        key_sequence = 'CONTROL + SHIFT + MINUS'
    },
    {
        type = 'custom-input',
        name = 'beltbrush-cycle-balancers',
        order = 'beltbrush[e]',
        key_sequence = 'ALT + B'
    },
    {
        type = 'custom-input',
        name = 'beltbrush-cycle-balancers-rev',
        order = 'beltbrush[f]',
        key_sequence = 'ALT + SHIFT + B'
    }
})
