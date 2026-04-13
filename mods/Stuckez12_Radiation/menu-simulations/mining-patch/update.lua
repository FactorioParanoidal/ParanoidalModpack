local start_tick = 2460

if storage.sim_char and storage.sim_char.valid then
    if game.tick <= start_tick + (60 * 3.5) then
        storage.sim_char.walking_state = {walking = true, direction = defines.direction.west}
    else
        storage.sim_char.walking_state = {walking = false, direction = defines.direction.west}
    end
end
