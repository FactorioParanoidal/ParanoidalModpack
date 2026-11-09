local core = ["SpidertronEnhancements", "SpidertronPatrols", "remove-animations"];
local SA = ["space-age", "elevated-rails", "quality"];
local K2 = ["Krastorio2", "Krastorio2Assets", "ChangeInserterDropLane", "flib"];
{
    default_settings:
    {
        startup: {
            "sp-enable-dock": true,
            "sp-enable-spiderling": true,
            "sp-spiderling-requires-fuel": "No",
            "sp-remove-military-requirement": false,
        },
    },
    configurations:
    {
        "Base": {mods: core},
        "Base no dock": {mods: core, settings: {startup: {"sp-enable-dock": false}}},
        "Base no spiderling": {mods: core, settings: {startup: {"sp-enable-spiderling": false}}},
        "Base spiderling fuel": {mods: core, settings: {startup: {"sp-spiderling-requires-fuel": "Yes"}}},
        "Base no military": {mods: core, settings: {startup: {"sp-remove-military-requirement": true}}},  // TODO fix test
        "SA": {mods: core + SA},
        "SA no dock": {mods: core + SA, settings: {startup: {"sp-enable-dock": false}}},
        "SA no spiderling": {mods: core + SA, settings: {startup: {"sp-enable-spiderling": false}}},
        "SA spiderling fuel": {mods: core + SA, settings: {startup: {"sp-spiderling-requires-fuel": "Yes"}}},
        "SA no military": {mods: core + SA, settings: {startup: {"sp-remove-military-requirement": true}}},
        "K2": {mods: core + K2},
        "K2 no military": {mods: core + K2, settings: {startup: {"sp-remove-military-requirement": true}}},
    },
    tests:
    {
        "common.*": {},
    },
}