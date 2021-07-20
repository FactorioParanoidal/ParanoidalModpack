global.delta_at_limit = {}
global.delta_below_limit = {}
global.gui_players = {}

for index, _ in pairs(game.players) do
    global.gui_players[index] = { elements = {} }
end
