local players = game.players
for i = 1, (#players) do
    if players[i] and players[i].valid then
        local inv = players[i].get_main_inventory()
        if inv and inv.valid then
            inv.remove("red-wire")
            inv.remove("green-wire")
        end
    end
end

