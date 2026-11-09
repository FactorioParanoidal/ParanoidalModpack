local surface = game.get_surface("maraxsis")
if not surface then return end

storage.coral_animations = storage.coral_animations or {}

local function coral_created(event)
    local coral = event.target_entity
    local surface = coral.surface
    local position = coral.position
    local force_index = coral.force_index

    -- move registration up, in case coral was already defined via storage migration
    local registration_number = script.register_on_object_destroyed(coral)
    local existing_animations = storage.coral_animations[registration_number]

    -- only generate new coral animations if they did not already exist
    if existing_animations and existing_animations[1] and existing_animations[1].valid
        and existing_animations[2] and existing_animations[2].valid
    then return end

    local coral_animation = {0, 0}
    for i = 1, 2 do
        local new_coral = surface.create_entity {
            name = "maraxsis-coral-animation",
            position = maraxsis.randomize_position(position, 0.75),
            force = force_index,
            create_build_effect_smoke = false
        }
        new_coral.disabled_by_script = true
        new_coral.destructible = false
        new_coral.minable_flag = false
        coral_animation[i] = new_coral
    end

    if coral_animation[1].graphics_variation == coral_animation[2].graphics_variation then
        coral_animation[2].graphics_variation = (coral_animation[1].graphics_variation % 8) + 1
    end

    -- create polycephalum-slime decorative
    surface.create_decoratives {
        check_collision = false,
        decoratives = {
            {
                amount = 1,
                name = "polycephalum-slime",
                position = maraxsis.randomize_position(position, 0.75),
            }
        }
    }

    storage.coral_animations[registration_number] = coral_animation
end

for _, coral in pairs(surface.find_entities_filtered {name = "maraxsis-coral"}) do
    coral_created {target_entity = coral}
end
