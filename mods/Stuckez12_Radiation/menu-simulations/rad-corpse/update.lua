local player_management = require("__Stuckez12_Radiation__/scripts/player_management")


function nonlinear_value(t, L)
    local k = 0.8
    local x0 = 8
    local value = L / (1 + math.exp(-k * (t - x0)))
    if value > L then value = L end
    return value
end


function spawn_character(logo, health)
    local x_pos = logo.position.x
    local y_pos = logo.position.y+11

    local predefined_locations = {
        {x=x_pos+35, y=y_pos, direction=defines.direction.west},
        {x=x_pos+20, y=y_pos+20, direction=defines.direction.northwest},
        {x=x_pos+20, y=y_pos-20, direction=defines.direction.southwest},
        {x=x_pos-35, y=y_pos, direction=defines.direction.east},
        {x=x_pos-20, y=y_pos+20, direction=defines.direction.northeast},
        {x=x_pos-20, y=y_pos-20, direction=defines.direction.southeast},
    }

    local spawn_pos = predefined_locations[math.random(1,6)]

    local surface = game.surfaces["nauvis"]
    local character = surface.create_entity{
        name = "character",
        position = {spawn_pos.x + (math.random(-2000, 2000) / 1000), spawn_pos.y + (math.random(-2000, 2000) / 1000)},
        force = "player",
        direction = spawn_pos.direction,
    }
    character.walking_state = {walking = true, direction = spawn_pos.direction}
    character.health = health

    player_management.add_character_reference(character)
end


local t = (game.tick - storage.timer) / 60
local current_interval
local health


if t < 2 then
    current_interval = 60
    health = 30
elseif t < 5 then
    current_interval = 30
    health = 15
elseif t < 8 then
    current_interval = 15
    health = 9
elseif t < 10 then
    current_interval = 7
    health = 4
else
    current_interval = 2
    health = 2
end


if game.tick % current_interval == 0 then
    spawn_character(storage.logo, health)
end
