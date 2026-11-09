local surface = game.get_surface("maraxsis")
if not surface then return end

storage.fishing_tower_spawners = storage.fishing_tower_spawners or {}

for _, entity in pairs(surface.find_entities_filtered {name = "maraxsis-fishing-tower"}) do
    -- move registration up, in case fish spawner was already defined via storage migration
    local registration_number = script.register_on_object_destroyed(entity)
    local fish_spawner = storage.fishing_tower_spawners[registration_number]

    -- only create a new spawner if one did not already exist
    if not fish_spawner or not fish_spawner.valid then
        fish_spawner = entity.surface.create_entity {
            name = "maraxsis-fish-spawner",
            position = entity.position,
            force = "neutral",
        }
    end

    fish_spawner.destructible = false
    fish_spawner.disabled_by_script = false
    fish_spawner.operable = false
    fish_spawner.minable_flag = false

    storage.fishing_tower_spawners[registration_number] = fish_spawner
end
