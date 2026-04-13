if game.tick >= storage.timer + (60 * 3) then
    if storage.sim_char and storage.sim_char.valid then
        storage.sim_char.shooting_state = {
            state = defines.shooting.shooting_enemies,
            position = {storage.sim_char.position.x - 10, storage.sim_char.position.y}
        }
    end
end
