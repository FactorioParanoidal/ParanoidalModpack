local mod_gui = require("mod-gui")

function debug_button(event)
	if event and event.element then
		local player = game.players[event.player_index]
		local button_flow = mod_gui.get_button_flow(player)
		game.print("_________________________________________")
		local guiparams = { "type", "name", "caption", "tooltip", "enabled", "visible", "ignored_by_interaction", "style", "tags", "index", "children_names"}
		local butt = event.element

		for _,j in pairs(guiparams) do
			if butt[j] then
				player.print(j .. " = " .. serpent.block(butt[j]))
			end
		end
		if butt.type and butt.type == "sprite-button" then
			player.print("sprite = " .. serpent.block(butt.sprite))
		end

		local getmod = butt and butt.get_mod() or "nothing"
		player.print("mod = " .. getmod)
		if event.element.parent then
			player.print("parent1: " .. event.element.parent.name)
			if event.element.parent.parent then
				player.print("parent2: " .. event.element.parent.parent.name)
				if event.element.parent.parent.parent then
					player.print("parent3: " .. event.element.parent.parent.parent.name)
					if event.element.parent.parent.parent.parent then
						player.print("parent4: " .. event.element.parent.parent.parent.parent.name)
						if event.element.parent.parent.parent.parent.parent then
							player.print("parent5: " .. event.element.parent.parent.parent.parent.parent.name)
							if event.element.parent.parent.parent.parent.parent.parent then
								player.print("parent6: " .. event.element.parent.parent.parent.parent.parent.parent.name)
								if event.element.parent.parent.parent.parent.parent.parent.parent then
									player.print("parent7: " .. event.element.parent.parent.parent.parent.parent.parent.parent.name)
									if event.element.parent.parent.parent.parent.parent.parent.parent.parent then
										player.print("parent8: " .. event.element.parent.parent.parent.parent.parent.parent.parent.parent.name)
										if event.element.parent.parent.parent.parent.parent.parent.parent.parent.parent then
											player.print("parent9: " .. event.element.parent.parent.parent.parent.parent.parent.parent.parent.parent.name)
										end
									end
								end
							end
						end
					end
				end
			end
		end
		game.print("___________________________________________")
		player.print("surface = " .. player.surface.name)
	end
end