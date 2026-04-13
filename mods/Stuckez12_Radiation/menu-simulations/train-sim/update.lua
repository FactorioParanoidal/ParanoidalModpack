local start_tick = 43662

if storage.sim_char and storage.sim_char.valid then
    if game.tick <= start_tick + (60 * 2.7) then
        storage.sim_char.walking_state = {walking = true, direction = defines.direction.north}
        -- storage.sim_char.teleport({pos.x, pos.y - 0.07})
    elseif game.tick <= start_tick + (60 * 3.1) then
        storage.sim_char.walking_state = {walking = true, direction = defines.direction.northeast}
        -- storage.sim_char.teleport({pos.x, pos.y - 0.07})
    else
        storage.sim_char.walking_state = {walking = true, direction = defines.direction.east}
        -- storage.sim_char.teleport({pos.x + 0.07, pos.y})
    end
end
