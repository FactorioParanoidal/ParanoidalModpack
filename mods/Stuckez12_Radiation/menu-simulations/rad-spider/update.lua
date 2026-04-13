if game.tick >= storage.timer + (60 * 3.8) then
    if storage.sim_char and storage.sim_char.valid then
        storage.sim_char.die()
    end
else
    storage.sim_char.health = storage.sim_char.max_health
end
