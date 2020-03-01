
script.on_event(defines.events.on_player_created, function(event)
	for nameA, vers in pairs(game.active_mods) do
		if nameA == "ShinyBob_Graphics" then
			game.print{"message.warn"}
		end
		if nameA == "ShinyBob_Icons" then
			game.print{"message.warn2"}
		end
	end
end )

script.on_configuration_changed( function(event)
	for nameA, vers in pairs(game.active_mods) do
		if nameA == "ShinyBob_Graphics" then
			game.print{"message.warn"}
		end
		if nameA == "ShinyBob_Icons" then
			game.print{"message.warn2"}
		end
	end
 end )


 
 
