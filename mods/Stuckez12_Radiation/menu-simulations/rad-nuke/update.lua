if game.tick >= storage.timer + (60 * 12) then
    if storage.sim_char and storage.sim_char.valid then
        storage.sim_char.damage(100000, "neutral", "physical")
    end
elseif game.tick >= storage.timer + (60 * 9) then
    if storage.sim_char and storage.sim_char.valid then
        storage.sim_char.character_running_speed_modifier = 0
        storage.sim_char.walking_state = {walking = true, direction = defines.direction.east}
    end
elseif game.tick >= storage.timer + (60 * 6.2) then
    if storage.sim_char and storage.sim_char.valid then
        storage.sim_char.walking_state = {walking = false, direction = defines.direction.west}
        storage.sim_char.health = storage.sim_char.max_health
    end
elseif game.tick >= storage.timer + (60 * 5.2) then
    if storage.sim_char and storage.sim_char.valid then
        storage.sim_char.shooting_state = { state = defines.shooting.not_shooting }
    end
elseif game.tick >= storage.timer + (60 * 5) then
    if storage.sim_char and storage.sim_char.valid then
        storage.sim_char.shooting_state = {
            state = defines.shooting.shooting_enemies,
            position = {storage.sim_char.position.x + 22, storage.sim_char.position.y}
        }
    end
end






