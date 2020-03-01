
script.on_init(initialization)
script.on_event({defines.events.on_player_changed_force}, initialization)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
		--player.insert{name="steel-axe", count=1}	
		player.insert{name="iron-plate", count=200}
		player.insert{name="copper-plate", count=200}
		--player.insert{name="electronic-circuit", count=400}
		player.insert{name="iron-gear-wheel", count=200}
		
		player.insert{name="inserter", count=50}
		player.insert{name="long-handed-inserter", count=25}
		player.insert{name="fast-inserter", count=25}
		--player.insert{name="filter-inserter", count=25}
		
		player.insert{name="basic-transport-belt", count=200}
		--player.insert{name="transport-belt", count=200}
		player.insert{name="medium-electric-pole", count=25}
		player.insert{name="big-electric-pole", count=10}
		--player.insert{name="electric-mining-drill", count=3}
		player.insert{name="stone-furnace", count=1}
		player.insert{name="assembling-machine-2", count=1}
		player.insert{name="pipe", count=50}
		--player.insert{name="steel-chest", count=5}
		player.insert{name="wooden-chest", count=5}
		player.insert{name="iron-chest", count=5}
		--player.insert{name="steam-engine", count=20}
		--player.insert{name="boiler", count=10}
		player.insert{name="offshore-pump", count=1}
		player.insert{name="pipe-to-ground", count=10}
		--player.insert{name="lab", count=6}
		player.insert{name="basic-splitter", count=10}
		player.insert{name="basic-underground-belt", count=20}
		--player.insert{name="coal", count=200}
		
  --player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="burner-ore-crusher", count = 1}
  --player.insert{name="stone-furnace", count = 1}

  --player.insert{name="pipe-to-ground", count = 50}
--player.insert{name="steam-engine", count = 1}
--player.insert{name="boiler", count = 1}
  --player.insert{name="small-electric-pole", count = 30}
  
  player.insert{name="slag", count=14}
  player.insert{name="stone-crushed", count=22}
  player.insert{name="stone", count=18}
  player.insert{name="wood", count=9}
  player.insert{name="battery", count=7}
  player.insert{name="silver-zinc-battery", count=1}
  player.insert{name="unused-air-filter", count=10}
  player.insert{name="nuclear-fuel", count=1}
  player.insert{name="intelligent-io", count=1}
  player.insert{name="intergrated-electronics", count=2}
  player.insert{name="aluminium-plate", count=16}
  player.insert{name="titanium-plate", count=1}
  player.insert{name="repair-pack", count=5}
  --player.insert{name="angels-wire-platinum", count=5}
	end)