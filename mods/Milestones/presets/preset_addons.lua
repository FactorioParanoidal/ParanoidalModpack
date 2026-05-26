-- These preset addons will add new milestones at the end of the detected milestones preset
-- All addons that meet their "required mods" will be used.

-- If you would like to add a preset addon for your own mod, you will need to implement the remote interface. Please see the README for more info.


preset_addons = {
    ["Quality"] = {
        required_mods = {"quality"},
        forbidden_mods = {"space-age"},
        milestones = {
            {type="group", name="Quality"},
            {type="item", name="quality-module",        quantity=1, quality="rare"},
            {type="item", name="quality-module-2",      quantity=1, quality="rare"},
            {type="item", name="quality-module-3",      quantity=1, quality="epic"},
            {type="item", name="quality-module-3",      quantity=1, quality="legendary"},
            {type="item", name="productivity-module-3", quantity=100, next="x10", quality="legendary"},
        }
    },

    ["Power Armor MK3"] = {
        required_mods = {"Power Armor MK3"},
        milestones = {
            {type="group", name="Progress"},
            {type="item", name="pamk3-pamk3", quantity=1},
            {type="item", name="pamk3-pamk4", quantity=1},
        }
    },

    ["Space Extension (SpaceX)"] = {
        required_mods = {"SpaceMod"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="group", name="Progress"},
            {type="item", name="satellite",            quantity=7},
            {type="item", name="drydock-structural",   quantity=10},
            {type="item", name="drydock-assembly",     quantity=2},
            {type="item", name="protection-field",     quantity=1},
            {type="item", name="fusion-reactor",       quantity=1},
            {type="item", name="habitation",           quantity=1},
            {type="item", name="life-support",         quantity=1},
            {type="item", name="command",              quantity=1},
            {type="item", name="fuel-cell",            quantity=2},
            {type="item", name="space-thruster",       quantity=4},
            {type="item", name="hull-component",       quantity=10},
            {type="technology", name="ftl-theory-A",   quantity=1},
            {type="technology", name="ftl-theory-B",   quantity=1},
            {type="technology", name="ftl-theory-C",   quantity=1},
            {type="technology", name="ftl-theory-D1",  quantity=1},
            {type="technology", name="ftl-theory-D2",  quantity=1},
            {type="technology", name="ftl-theory-E",   quantity=1},
            {type="technology", name="ftl-propulsion", quantity=1},
            {type="item", name="ftl-drive",            quantity=1},
        }
    },

    ["Cargo Ships"] = {
        required_mods = {"cargo-ships"},
        milestones = {
            {type="group", name="Progress"},
            {type="item", name="boat",       quantity=1},
            {type="item", name="cargo_ship", quantity=1},
        }
    },

    ["Spidertron Extended"] = {
        required_mods = {"spidertron-extended"},
        milestones = {
            {type="group", name="Progress"},
            {type="item", name="spidertronmk2", quantity=1},
            {type="item", name="spidertronmk3", quantity=1},
        }
    },

    ["Armoured Biters"] = {
        required_mods = {"ArmouredBiters"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="group", name="Kills"},
            {type="kill", name="behemoth-armoured-biter",  quantity=1},
            {type="kill", name="leviathan-armoured-biter", quantity=1},
        }
    },

    ["Cold Biters"] = {
        required_mods = {"Cold_biters"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="group", name="Kills"},
            {type="kill", name="behemoth-cold-biter",  quantity=1},
            {type="kill", name="leviathan-cold-biter", quantity=1},
        }
    },

    ["Explosive Biters"] = {
        required_mods = {"Explosive_biters"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="group", name="Kills"},
            {type="kill", name="behemoth-explosive-biter",  quantity=1},
            {type="kill", name="explosive-leviathan-biter", quantity=1},
        }
    },

    ["BZ Aluminum"] = {
        required_mods = {"bzaluminum"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="aluminum-plate", quantity=1},
            {type="item", name="copper-plate", quantity=1}, -- pushed further into the tech tree
        }
    },

    ["BZ Graphite & Diamonds"] = {
        required_mods = {"bzcarbon"},
        milestones = {
          {type = "group", name = "Resources", quantity = 1},
          {type = "item", name = "graphite", quantity = 1},
          {type = "item", name = "diamond", quantity = 1},
      }
    },

    ["BZ Lead"] = {
        required_mods = {"bzlead"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="lead-plate", quantity=1},
        }
    },

    ["BZ Silicon"] = {
        required_mods = {"bzsilicon"},
        forbidden_mods = {"Krastorio2"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="silica", quantity=1},
            {type="item", name="silicon", quantity=1},
        }
    },

    ["BZ Silicon (with K2)"] = { -- K2 removes BZ's silicon
        required_mods = {"bzsilicon", "Krastorio2"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="silica", quantity=1},
        }
    },

    ["BZ Titanium"] = {
        required_mods = {"bztitanium"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="titanium-plate", quantity=1},
        }
    },

    ["BZ Tungsten"] = {
        required_mods = {"bztungsten"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="tungsten-plate", quantity=1},
        }
    },

    ["BZ Zirconium"] = {
        required_mods = {"bzzirconium"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="zirconium-plate", quantity=1},
        }
    },

    ["Kitty Cat"] = {
        required_mods = {"kittycat"},
        milestones = {
            {type="group", name="Progress"},
            {type="item", name="kcat-cat", quantity=1},
        }
    },
}
