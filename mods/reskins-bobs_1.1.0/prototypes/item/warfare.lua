-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobwarfare"] then return end
if reskins.lib.setting("reskins-bobs-do-bobwarfare") == false then return end

-- Setup inputs
local inputs = {
    mod = "bobs",
    group = "warfare",
    make_icon_pictures = false,
    flat_icon = true,
}

local plasma_tint = util.color("1280b2")
local uranium_tint = util.color("12b222")

local items = {
    -- Robot tools
    ["robot-tool-combat"] = {tier = 1, prog_tier = 2, icon_name = "robot-tool-combat", flat_icon = false, make_icon_pictures = true},
    ["robot-tool-combat-2"] = {tier = 2, prog_tier = 3, icon_name = "robot-tool-combat", flat_icon = false, make_icon_pictures = true},
    ["robot-tool-combat-3"] = {tier = 3, prog_tier = 4, icon_name = "robot-tool-combat", flat_icon = false, make_icon_pictures = true},
    ["robot-tool-combat-4"] = {tier = 4, prog_tier = 5, icon_name = "robot-tool-combat", flat_icon = false, make_icon_pictures = true},

    -- Bullets
    ["bullet"] = {subgroup = "bullets"},
    ["acid-bullet"] = {subgroup = "bullets"},
    ["ap-bullet"] = {subgroup = "bullets"},
    ["electric-bullet"] = {subgroup = "bullets", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "electric-bullet")}},
    ["flame-bullet"] = {subgroup = "bullets"},
    ["he-bullet"] = {subgroup = "bullets"},
    ["plasma-bullet"] = {subgroup = "bullets", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "aura-bullet", plasma_tint)}},
    ["poison-bullet"] = {subgroup = "bullets"},
    ["uranium-bullet"] = {subgroup = "bullets", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "aura-bullet", uranium_tint)}},

    -- Projectiles
    ["bullet-projectile"] = {subgroup = "projectiles"},
    ["acid-bullet-projectile"] = {subgroup = "projectiles"},
    ["ap-bullet-projectile"] = {subgroup = "projectiles"},
    ["electric-bullet-projectile"] = {subgroup = "projectiles", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "electric-projectile")}},
    ["flame-bullet-projectile"] = {subgroup = "projectiles"},
    ["he-bullet-projectile"] = {subgroup = "projectiles"},
    ["plasma-bullet-projectile"] = {subgroup = "projectiles", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "aura-projectile", plasma_tint)}},
    ["poison-bullet-projectile"] = {subgroup = "projectiles"},
    ["uranium-bullet-projectile"] = {subgroup = "projectiles", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "aura-projectile", uranium_tint)}},

    -- Magazines
    ["bullet-magazine"] = {type = "ammo", subgroup = "magazines"},
    ["acid-bullet-magazine"] = {type = "ammo", subgroup = "magazines"},
    ["ap-bullet-magazine"] = {type = "ammo", subgroup = "magazines"},
    ["electric-bullet-magazine"] = {type = "ammo", subgroup = "magazines"},
    ["flame-bullet-magazine"] = {type = "ammo", subgroup = "magazines"},
    ["he-bullet-magazine"] = {type = "ammo", subgroup = "magazines"},
    ["plasma-bullet-magazine"] = {type = "ammo", subgroup = "magazines", make_entity_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "rounds-magazine")}},
    ["poison-bullet-magazine"] = {type = "ammo", subgroup = "magazines"},
    ["uranium-rounds-magazine"] = {type = "ammo", subgroup = "magazines", make_entity_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "rounds-magazine")}},

    -- Warheads
    ["rocket-warhead"] = {subgroup = "warheads"},
    ["acid-rocket-warhead"] = {subgroup = "warheads"},
    ["piercing-rocket-warhead"] = {subgroup = "warheads"},
    ["electric-rocket-warhead"] = {subgroup = "warheads", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "electric-warhead")}},
    ["explosive-rocket-warhead"] = {subgroup = "warheads"},
    ["flame-rocket-warhead"] = {subgroup = "warheads"},
    ["plasma-rocket-warhead"] = {subgroup = "warheads", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "aura-warhead", plasma_tint)}},
    ["poison-rocket-warhead"] = {subgroup = "warheads"},

    -- Rockets
    ["bob-rocket"] = {type = "ammo", subgroup = "rockets"},
    ["bob-acid-rocket"] = {type = "ammo", subgroup = "rockets"},
    ["bob-piercing-rocket"] = {type = "ammo", subgroup = "rockets"},
    ["bob-electric-rocket"] = {type = "ammo", subgroup = "rockets", make_entity_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "electric-rocket")}},
    ["bob-flame-rocket"] = {type = "ammo", subgroup = "rockets"},
    ["bob-explosive-rocket"] = {type = "ammo", subgroup = "rockets"},
    ["bob-plasma-rocket"] = {type = "ammo", subgroup = "rockets", make_entity_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "aura-rocket", plasma_tint)}},
    ["bob-poison-rocket"] = {type = "ammo", subgroup = "rockets"},

    -- Shotgun Shells
    ["better-shotgun-shell"] = {type = "ammo", subgroup = "shells"},
    ["shotgun-acid-shell"] = {type = "ammo", subgroup = "shells"},
    ["shotgun-ap-shell"] = {type = "ammo", subgroup = "shells"},
    ["shotgun-electric-shell"] = {type = "ammo", subgroup = "shells", make_entity_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "electric-shotgun-shell")}},
    ["shotgun-explosive-shell"] = {type = "ammo", subgroup = "shells"},
    ["shotgun-flame-shell"] = {type = "ammo", subgroup = "shells"},
    ["shotgun-plasma-shell"] = {type = "ammo", subgroup = "shells", make_entity_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "aura-shotgun-shell", plasma_tint)}},
    ["shotgun-poison-shell"] = {type = "ammo", subgroup = "shells"},
    ["shotgun-uranium-shell"] = {type = "ammo", subgroup = "shells", make_entity_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer(inputs.mod, "aura-shotgun-shell", uranium_tint)}},

    -- Components
    ["bullet-casing"] = {subgroup = "components"},
    ["magazine"] = {subgroup = "components"},
    ["cordite"] = {subgroup = "components"},
    -- ["rocket-body"] = {subgroup = "components"},
    -- ["shot"] = {subgroup = "components"},
    -- ["shotgun-shell-casing"] = {subgroup = "components"},
}

reskins.lib.create_icons_from_list(items, inputs)