
function enableTesting(event)
    local player = game.players[event.player_index]
    if player.name ~= "Gangsir" then --safeguard, just in case I forget to comment this out
        player.print("You aren't the dev. He must've forgot to comment this out. Sorry for polluting your commands with debug.")
    else
        player.cheat_mode = true
        player.force.research_all_technologies()
    end
end
--commands.add_command("achieverTesting", "Run to enable testing of achiever without disabling achievements.", enableTesting)

require("vanillaScripting")
