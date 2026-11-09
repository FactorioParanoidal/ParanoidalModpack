local swimming_armors = {}
local is_swimmable = {}

for _,armor in pairs(data.raw.armor) do
    if armor.provides_flight then
        table.insert(armor.resistances,{
            type = "drowning",
            percent = 50,
        })
    end
end

for _, armor in pairs(data.raw.armor) do
    armor = table.deepcopy(armor)
    is_swimmable[armor.name] = true
    armor.localised_name = armor.localised_name or {"item-name." .. armor.name}
    armor.name = armor.name .. "-maraxsis-swimming"
    armor.provides_flight = true
    armor.hidden = true
    armor.weight = 1000000
    if armor.flight_sound then
        if armor.flight_sound.sound.filename == "__space-age__/sound/entity/mech-armor/mech-armor-flight.ogg" then
            armor.flight_sound.sound.filename = "__maraxsis__/sounds/entity/mech-armor/mech-armor-flight-underwater.ogg"
        end
        if armor.takeoff_sound.filename == "__space-age__/sound/entity/mech-armor/mech-armor-takeoff.ogg" then
            armor.takeoff_sound.filename = "__maraxsis__/sounds/entity/mech-armor/mech-armor-takeoff-underwater.ogg"
        end
        
    end
    swimming_armors[#swimming_armors + 1] = armor
end

data:extend(swimming_armors)

local function reduce_animation_speed(animation, factor)
    if not animation then return end

    animation.animation_speed = (animation.animation_speed or 1) / factor
    for _, layer in pairs(animation.layers or {}) do
        layer.animation_speed = (layer.animation_speed or 1) / factor
    end
end

for _, character in pairs(data.raw.character) do
    local swimming_animations = table.deepcopy(character.animations)
    for _, animation in pairs(character.animations) do
        if animation.armors then
            local animation = table.deepcopy(animation)

            animation.flying = table.deepcopy(animation.running)
            reduce_animation_speed(animation.flying, 5)

            animation.idle_in_air = table.deepcopy(animation.running)
            reduce_animation_speed(animation.idle_in_air, 5)

            animation.idle_with_gun_in_air = table.deepcopy(animation.running_with_gun)
            reduce_animation_speed(animation.idle_with_gun_in_air, 5)

            animation.flying_with_gun = table.deepcopy(animation.running_with_gun)
            reduce_animation_speed(animation.flying_with_gun, 5)

            reduce_animation_speed(animation.take_off, 5)
            reduce_animation_speed(animation.landing, 5)

            animation.smoke_in_air = {
                {
                    name = "maraxsis-swimming-bubbles",
                    deviation = {0.35, 0.35},
                    frequency = 6,
                    position = {0, 0},
                }
            }

            local new_armors = {}
            for _, armor in pairs(animation.armors) do
                if is_swimmable[armor] then
                    new_armors[#new_armors + 1] = armor .. "-maraxsis-swimming"
                    is_swimmable[armor] = nil
                    if armor == "heavy-armor" then
                        new_armors[#new_armors + 1] = "light-armor-maraxsis-swimming"
                        is_swimmable["light-armor"] = nil
                    end
                end
            end

            animation.armors = new_armors
            swimming_animations[#swimming_animations + 1] = animation
        end
    end

    character.animations = swimming_animations
end
