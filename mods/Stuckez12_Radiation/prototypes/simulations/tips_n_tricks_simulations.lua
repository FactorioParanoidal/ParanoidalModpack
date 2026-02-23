

local simulations = {}

simulations.uranium_patch_walk_over = {
    type = "simulation-definition",
    name = "Stuckez12-uranium-patch-walk-over",
    init = [[
        local radiation_funcs = require("__Stuckez12_Radiation__/scripts/radiation_damage")
        local player_management = require("__Stuckez12_Radiation__/scripts/player_management")

        storage.active_characters = {}
        storage.radiation_items = {
            ["uranium-ore"] = 1
        }

        game.simulation.camera_position = {0, 0.5}

        local surface = game.surfaces[1]

        for dx = -10, -4 do
            for dy = -3, 3 do
                surface.create_entity{
                    name = "uranium-ore",
                    amount = 50000,
                    position = {dx, dy},
                    force = "neutral"
                }
            end
        end

        script.on_nth_tick(20, radiation_funcs.player_radiation_damage)

        script.on_nth_tick(400, function(event)
            local surface = game.surfaces[1]

            local player_management = require("__Stuckez12_Radiation__/scripts/player_management")

            if storage.sim_char then
                player_management.remove_character_reference(storage.sim_char)

                local corpses = surface.find_entities_filtered{
                    type = "character-corpse"
                }

                for _, corpse in pairs(corpses) do
                    if corpse.valid then
                        corpse.destroy()
                    end
                end
            end

            local character = surface.create_entity{
                name = "character",
                position = {14, 0.5},
                force = "neutral"
            }

            player_management.add_character_reference(character)

            storage.sim_char = character

            storage.sim_char.walking_state = {walking = true, direction = defines.direction.west}
        end)
    ]],

    update = [[
        if storage.sim_char and storage.sim_char.valid then
            local pos = storage.sim_char.position
            -- Move left by 0.1 tile per tick
            storage.sim_char.teleport({pos.x - 0.01, pos.y})
        end
    ]],

    mods = {"base", "Stuckez12_Radiation"}
}


simulations.radiation_entity_list = {
    type = "simulation-definition",
    name = "Stuckez12-radiation-entity-list",
    init = [[
        game.simulation.camera_position = {0, 0.5}

        game.surfaces[1].create_entities_from_blueprint_string
        {
            string = "0eNrNmN1uozAQhd/F1xCB+c+rrCrkEIdYNTZrm2arKu++Q9ICaQwxbVfaqyTEfGdmPD7GvKEd72irmDBo+4ZYJYVG219vSLNaEN5fE6ShaIsk476iByaoekVnDzGxp3/QNjx7lsGiqzglCm4glZFqMh6fnzxEhWGG0avS5cdrKbpmRxUAvQ+INoqw+mh8+ODIQ63UcJcUvQ6QsqTw0Cva+kly7oP4xMHeXDD3pBhvkndWtLHSIs9aBwsqu0F5aM8Ura4jcgs4HsCQrdCtVMbfUW5s+Ybz6NiCTgZ0B7VXtZLw6QDHd3APmde2BzHRdgZZtNJBi/5pFdXad9GMvqWZDZoHoo2TIP6WYH6X5OM5i9bNWXGb02M+XscPg0GgIralkCSbPMJBFOKxUnkcZT2bCrLjtOSyZtqwSpenI4PfjXxhokZbozoKRVSdeC6ZeAFlCUtkKzrOPUSaRt5f3Sv2QlXJdNkQJsq6E6KP8kC4BpSmHHKh+/56+eE3HpKKAYVcow42OLHlOdoIl5VspAGhJQ+JNil2yPE9stsQbPp4vY1FNuMJR+fRLWfGULW8ekOHJojvGnmJHa1iJ7cdvATGq8CjxRginm28dBOkaRykQ+sGm/+obRX93VFtygPjUA/dR62vCV/3wWFDfZqMVbIpd93hcLmhj/Ts2P/Z+v4Lrf03mh7RmjY7DkXzG1IdYQf0Q9sOOPRiXNg307BYYmIbM37ExMESM1rcqWeZo4kwoamaaeNg4OQuFoxHa9h1ChrHd4MXTvBo9bzHhTX30SOqI21YRbjfciLM8oynn4MMsQ0+mkQFfyl26Gq6PO3pzBSlt3bjVsrUqZTZZAuBXjoSWKB7R4XMSSGfeDuDpxejYKiFG2/yNAvzbBJ/VAROG9aPuxvpjGzAfKrSEFVTAyplSxSk8eFq/Yj3P8sTM0fZmQFyDefziFuN87+2UNtUFNPnolr6J1Lb56IY5uDrDwz9aeim6LYTR7B+JWfWo8vExaC/fFjO+sEqjmcOQaNznaTc0wVW8JA1GhWcyqDh/FZByWARzEOjh9B4UjNK+TwKP0QlE5RUpKbzsOQGtqZNrcqjpbWwlbmVJn6Yz+hm7+Et4bKfzSif7Hj9QpwXTn9WuJgI82dH705cvDv+wvKEiQFjgnaqnstKguNNErlcvZ5bdqT/hovLm5Xr5d6ewMj6lzThxd2YoU2f1fDyxkPg2fqimqS4iIsiyaIkijN8Pv8FUDzz2w==",
            position = {0, -2}
        }

        storage.sim_char = "hello"

        local surface = game.surfaces[1]

        surface.create_entity{
            name = "logistic-robot",
            position = {-1, 4},
            force = "neutral"
        }

        surface.create_entity{
            name = "construction-robot",
            position = {-3, 4},
            force = "neutral"
        }

        surface.create_entity{
            name = "character-corpse",
            position = {5, 5},
            force = "neutral"
        }
    ]]
}


simulations.radiation_distance_impact = {
    type = "simulation-definition",
    name = "Stuckez12-radiation-distance-impact",
    init = [[
        game.simulation.camera_position = {6, 0.5}

        local radiation_funcs = require("__Stuckez12_Radiation__/scripts/radiation_damage")
        local player_management = require("__Stuckez12_Radiation__/scripts/player_management")

        storage.active_characters = {}
        storage.radiation_items = {
            ["uranium-ore"] = 1
        }

        storage.sim_char = "hello"
        storage.sim_dist = 12

        local surface = game.surfaces[1]

        surface.create_entity{
            name = "uranium-ore",
            amount = 1000000,
            position = {0, 0},
            force = "neutral"
        }

        script.on_nth_tick(20, radiation_funcs.player_radiation_damage)

        script.on_nth_tick(1800, function(event)
            local surface = game.surfaces[1]

            local entities = surface.find_entities_filtered{
                type = {"character-corpse", "character"}
            }

            for _, entity in pairs(entities) do
                if entity.valid then
                    entity.destroy()
                end
            end

            for i = 1, 6 do
                local character = surface.create_entity{
                    name = "character",
                    position = {(i * 2), 0.5},
                    force = "neutral"
                }

                character.direction = defines.direction.south

                player_management.add_character_reference(character)
            end
        end)
    ]]
}


simulations.radiation_resistance = {
    type = "simulation-definition",
    name = "Stuckez12-radiation-resistance",
    init = [[
        game.simulation.camera_position = {1, 0.5}

        game.surfaces[1].create_entities_from_blueprint_string
        {
            string = "0eNqNkNEKwjAMRf8lz53oZh3rr4hI54IEtqy2nVhG/912E3xQwbck7bkH7gxtP6GxxB7UDHQZ2YE6zuDoyrrPN9YDgoKOnOl1KIxm7CEKIO7wAWoXTwKQPXnCFV2WcOZpaNGmD+J7hAAzukSNnC0pqZbbjRQQQBWV3MisuKyPL97qjnQGCt260ZplxNtEZkhOiFF8yMv/5Ycfch9M5u9k/aQz+QpcGyo65JDUqQTyOKT7u1ABd7RucchD2eybRtaVrPZ1GeMTUrV9DQ==",
            position = {0, 2}
        }

        local radiation_funcs = require("__Stuckez12_Radiation__/scripts/radiation_damage")
        local player_management = require("__Stuckez12_Radiation__/scripts/player_management")

        storage.active_characters = {}
        storage.radiation_items = {
            ["uranium-ore"] = 1
        }

        storage.sim_char = "hello"
        storage.sim_dist = 12

        local surface = game.surfaces[1]

        surface.create_entity{
            name = "uranium-ore",
            amount = 400000,
            position = {0, 0},
            force = "neutral"
        }

        script.on_nth_tick(20, radiation_funcs.player_radiation_damage)

        script.on_nth_tick(900, function(event)
            local surface = game.surfaces[1]

            local entities = surface.find_entities_filtered{
                type = {"character-corpse", "character"}
            }

            for _, entity in pairs(entities) do
                if entity.valid then
                    entity.destroy()
                end
            end

            local character = surface.create_entity{
                name = "character",
                position = {3.5, 0.5},
                force = "neutral"
            }

            character.direction = defines.direction.south

            player_management.add_character_reference(character)

            local character_equipped = surface.create_entity{
                name = "character",
                position = {-2.5, 0.5},
                force = "neutral"
            }

            character_equipped.direction = defines.direction.south

            player_management.add_character_reference(character_equipped)

            local inv = character_equipped.get_inventory(defines.inventory.character_armor)
            inv.insert{name = "modular-armor", count = 1}

            local armor = inv[1]
            local grid = armor.grid
            grid.put{name = "radiation-absorption-equipment", position = {0,0}}
        end)
    ]]
}


simulations.radiation_walls = {
    type = "simulation-definition",
    name = "Stuckez12-radiation-suit",
    init = [[
        game.simulation.camera_position = {1, 0.5}

        local radiation_funcs = require("__Stuckez12_Radiation__/scripts/radiation_damage")
        local player_management = require("__Stuckez12_Radiation__/scripts/player_management")

        storage.active_characters = {}
        storage.radiation_items = {
            ["uranium-ore"] = 1
        }

        storage.sim_char = "hello"
        storage.sim_dist = 12

        local surface = game.surfaces[1]

        surface.create_entity{
            name = "uranium-ore",
            amount = 1200000,
            position = {0, 0},
            force = "neutral"
        }

        for i = 1, 5 do
            surface.create_entity{
                name = "radiation-wall",
                position = {-2, -3 + i},
                force = "neutral"
            }
        end

        script.on_nth_tick(20, radiation_funcs.player_radiation_damage)

        script.on_nth_tick(600, function(event)
            local surface = game.surfaces[1]

            local entities = surface.find_entities_filtered{
                type = {"character-corpse", "character"}
            }

            for _, entity in pairs(entities) do
                if entity.valid then
                    entity.destroy()
                end
            end

            local character = surface.create_entity{
                name = "character",
                position = {-3.5, 0.5},
                force = "neutral"
            }

            player_management.add_character_reference(character)

            character.direction = defines.direction.south

            local character_2 = surface.create_entity{
                name = "character",
                position = {4.5, 0.5},
                force = "neutral"
            }

            player_management.add_character_reference(character_2)

            character_2.direction = defines.direction.south
        end)
    ]]
}


simulations.radiation_suit = {
    type = "simulation-definition",
    name = "Stuckez12-radiation-suit",
    init = [[
        game.simulation.camera_position = {1, 0.5}

        game.surfaces[1].create_entities_from_blueprint_string
        {
            string = "0eNqt0sGOgyAQBuB3mTM2WxWNvMpms0GdbCbRkQXZrDG8e8E26aE9kKY3YPj/7zI79JNHY4lXUDvQsLAD9bmDox/WU3pjPSMoGMmZSW+F0YwTBAHEI/6DOocvAcgrrYTX6HHZvtnPPdr4QTyvEGAWF1MLJyU2tU13kgI2UEUlTzIRw3V4y1s9kk6BwuLoh+OEv57MHEkIQTzY5St2/R67yrbbj1xb926xJgOvX8Hlm3CZjze5uPOUsLhrtOIcR/e9FfCH1h2tsim7uutkW8mqbssQLjz+9jg=",
            position = {0, 3}
        }

        local radiation_funcs = require("__Stuckez12_Radiation__/scripts/radiation_damage")
        local player_management = require("__Stuckez12_Radiation__/scripts/player_management")

        storage.active_characters = {}
        storage.radiation_items = {
            ["uranium-ore"] = 1
        }

        storage.sim_char = "hello"
        storage.sim_dist = 12

        local surface = game.surfaces[1]

        surface.create_entity{
            name = "uranium-ore",
            amount = 1200000,
            position = {0, 0},
            force = "neutral"
        }

        script.on_nth_tick(20, radiation_funcs.player_radiation_damage)

        script.on_nth_tick(900, function(event)
            local surface = game.surfaces[1]

            local entities = surface.find_entities_filtered{
                type = {"character-corpse", "character"}
            }

            for _, entity in pairs(entities) do
                if entity.valid then
                    entity.destroy()
                end
            end

            local character = surface.create_entity{
                name = "character",
                position = {3.5, 0.5},
                force = "neutral"
            }

            character.direction = defines.direction.south

            player_management.add_character_reference(character)

            local inv = character.get_inventory(defines.inventory.character_armor)
            inv.insert{name = "radiation-suit", count = 1}

            local character_equipped = surface.create_entity{
                name = "character",
                position = {-2.5, 0.5},
                force = "neutral"
            }

            character_equipped.direction = defines.direction.south

            player_management.add_character_reference(character_equipped)

            local inv = character_equipped.get_inventory(defines.inventory.character_armor)
            inv.insert{name = "modular-armor", count = 1}

            local armor = inv[1]
            local grid = armor.grid
            grid.put{name = "radiation-absorption-equipment", position = {0,0}}
            grid.put{name = "radiation-absorption-equipment", position = {1,0}}
            grid.put{name = "radiation-reduction-equipment", position = {2,0}}
            grid.put{name = "radiation-reduction-equipment", position = {3,0}}
        end)
    ]]
}


simulations.radiation_biters = {
    type = "simulation-definition",
    name = "Stuckez12-radiation-biters",
    init = [[
        game.simulation.camera_position = {1, 0.5}

        local radiation_funcs = require("__Stuckez12_Radiation__/scripts/radiation_damage")
        local player_management = require("__Stuckez12_Radiation__/scripts/player_management")

        storage.active_characters = {}
        storage.radiation_items = {}
        storage.biters = {
            ["big-biter"] = 750
        }

        storage.sim_char = "hello"
        storage.sim_dist = 12

        local surface = game.surfaces[1]

        script.on_nth_tick(20, radiation_funcs.player_radiation_damage)

        script.on_nth_tick(800, function(event)
            local surface = game.surfaces[1]

            local entities = surface.find_entities_filtered{
                type = {"character-corpse", "character", "unit", "wall"}
            }

            for _, entity in pairs(entities) do
                if entity.valid then
                    entity.destroy()
                end
            end

            surface.create_entities_from_blueprint_string
            {
                string = "0eNqV1c1ugzAMB/B38TmtSMgHyatUU0W3aIoEoQK6rUJ59wI77DCsxEci/JOtWP8scOse/j6GOINbILwPcQJ3WWAKn7HttrPY9h4cTPMQ/em77TpIDEL88D/geHpj4OMc5uB/6/aP5zU++psf1x/YQT2D+zCtJUPc/I2RZ8XgCe7ExVmlxP45osxROacuc3TOkWWOyTmqzGlyji5zbM4xRY6ock5Dvffq2LFUhx87vKIOhjTEORXCOhLE0RrEqYmORRxJHAzrRxEdrB9NnEsjjiFGB+ZQV9ogjiVGENKPqIgRhDmcGEGYI4gRhDk1cX8wh7rP+32tz1mYfb8W/b2LDL78OO0lSgsrrVXGSK0bm9ILmXBPHw==",
                position = {4, 0}
            }

            local character = surface.create_entity{
                name = "character",
                position = {-2.5, 0.5},
                force = "neutral"
            }

            character.direction = defines.direction.south

            player_management.add_character_reference(character)

            local character = surface.create_entity{
                name = "big-biter",
                position = {3.5, 0.5},
                force = "neutral"
            }
        end)
    ]]
}


return simulations
