---- remote test
-- copy remote_interface_example.lua to your mod folder 
-- add "RampantFixed" to dependencies of your mod (this guarantees the remote interface presence)
-- add require("remote_interface_example") to control.lua

-- parameter: nil or number (new WaveMaxSize)
commands.add_command('setWaveMaxSize', "", 
	function(command)
		if not remote.call("rampantFixed", "allowExternalControl") then
			game.print("external control isn't allowed")
			return		
		end
		local result = remote.call("rampantFixed", "setWaveMaxSize_ExtCtrl", {attackWaveMaxSize = tonumber(command.parameter)})
		if result then
			game.print("max wave size now:"..result)
		end
	end
)

-- no parameters
commands.add_command('getWaveMaxSize', "", 
	function()
		game.print(remote.call("rampantFixed", "getWaveMaxSize"))
	end
)

-- parameter: nil or number (new WaveSize)
commands.add_command('setWaveSize', "", 
	function(command)
		if not remote.call("rampantFixed", "allowExternalControl") then
			game.print("external control isn't allowed")
			return		
		end
		local result = remote.call("rampantFixed", "setWaveSize_ExtCtrl", {attackWaveSize = tonumber(command.parameter)})
		if result then
			game.print("wave size now:"..result)
		end
	end
)

-- no parameters
commands.add_command('getWaveSize', "", 
	function()
		game.print(remote.call("rampantFixed", "getWaveSize"))
	end
)

-- parameter: nil or number (how much biters in squad)
commands.add_command('createSquad', "", 
	function(command)
		if not remote.call("rampantFixed", "allowExternalControl") then
			game.print("external control isn't allowed")
			return		
		end
		local result = remote.call("rampantFixed", "createSquad_ExtCtrl", {surfaceIndex = game.players[command.player_index].surface.index, size = tonumber(command.parameter), ignoreSquadLimit = true})
		if result then
			game.print("squad created at [gps=" .. result.position.x .. "," .. result.position.y .."]")
		else
			game.print("Cant create squad")
		end
	end
)

-- no parameters. print stats of the base at player position
commands.add_command('getBaseByPosition', "", 
	function(command)
		local parameters = {}
		parameters.surfaceIndex = game.players[command.player_index].surface.index
		parameters.position = game.players[command.player_index].position
		game.print(serpent.dump(remote.call("rampantFixed", "getBaseByPosition", parameters)))
	end
)


-- parameter: number (id of base). print stats of specified base
commands.add_command('getBaseById', "", 
	function(command)
		game.print(serpent.dump(remote.call("rampantFixed", "getBaseById", {id = tonumber(command.parameter)})))
	end
)

-- no parameters. print stats of all bases
commands.add_command('getBases', "", 
	function()
		game.print(serpent.dump(remote.call("rampantFixed", "getBases")))
	end
)

-- no parameters. print list of factions. Shows the minimum and maximum faction tier
commands.add_command('getFactions', "", 
	function(command)
		local factions = remote.call("rampantFixed", "getFactions") 
		for faction, tiers in pairs(factions) do
			game.print(faction..", tiers:"..tiers.tierMin.."-"..tiers.tierMax)
		end
	end
)

-- parameter: number 1..10. Tier of biters
-- Print list of factions . Shows the minimum and maximum faction tier
commands.add_command('getFactionsByTier', "", 
	function(command)
		local factions = remote.call("rampantFixed", "getFactionsByTier", {tier = tonumber(command.parameter)}) 
		for faction, tiers in pairs(factions) do
			game.print(faction..", tiers:"..tiers.tierMin.."-"..tiers.tierMax)
		end
	end
)

-- parameter: faction name. Base at players position will mutate to specified faction. 
-- Mutation can take some time (1-10 minutes)
-- print "1", if faction set succesfull
commands.add_command('setFactionToBaseAtPlayerPosition', "", 
	function(command)
		if not remote.call("rampantFixed", "allowExternalControl") then
			game.print("external control isn't allowed")
			return		
		end
		local parameters = {}
		parameters.surfaceIndex = game.players[command.player_index].surface.index
		parameters.position = game.players[command.player_index].position
		local base = remote.call("rampantFixed", "getBaseByPosition", parameters)
		if not base then
			game.print("no base at player position!")
			return
		end
		if not command.parameter then
			game.print("specify faction name in parameters!")
			return
		end
		local factions = remote.call("rampantFixed", "getFactions") 
		if not factions[command.parameter] then
			game.print("wrong faction name. Use /getFactions to show factions list")
			return
		end
		
		parameters = {id = base.id, factions = {}}
		parameters.factions[command.parameter] = 1				-- 100% of specified faction
		local result = remote.call("rampantFixed", "setBaseFactions_ExtCtrl", parameters)		
		if not result then
			game.print("external control isn't allowed")	-- impossible in this algorithm, because allowExternalControl checked
		elseif result == 1 then
			game.print("success")
		elseif result == -1 then
			game.print("wrong parameters")					-- impossible in this algorithm, because base and factions checked
		elseif result == -2 then
			game.print("sum of rates is not equals 1")		 	-- impossible in this algorithm, because "parameters.factions[command.parameter] = 1"
		end
	end
)

-- no parameters. print list of groups. If its same surface then add "gps"
commands.add_command('getRampantAttackGroups', "", 
	function(command)
		local groups = remote.call("rampantFixed", "getRampantAttackGroups") 
		for index, group in pairs(groups) do
			if group.surface == game.players[command.player_index].surface then	-- lets ping only same surface groups
				game.print("group "..index..", [gps=" .. group.position.x .. "," .. group.position.y .."]")
			else
				game.print("group "..index..", x/y = " .. group.position.x .. "/" .. group.position.y)
			end	
		end
	end
)


-- no parameters: get AI points for player surface.
commands.add_command('getAI_points', "", 
	function(command)
		local result = remote.call("rampantFixed", "getAI_points", {surfaceIndex = game.players[command.player_index].surface.index})
		if result then
			game.print("AI_points: ".. result )
		else
			game.print("non-rampant surface")
		end
	end
)

-- parameter: number. set AI points for player surface.
commands.add_command('setAI_points', "", 
	function(command)
		if not remote.call("rampantFixed", "allowExternalControl") then
			game.print("external control isn't allowed")
			return		
		end
		
		local result = remote.call("rampantFixed", "setAI_points_ExtCtrl", {surfaceIndex = game.players[command.player_index].surface.index, points = (command.parameter and tonumber(command.parameter))})
		if result then
			game.print("AI_points: ".. result )
		else
			game.print("non-rampant surface")
		end
	end
)

-- no parameters: get AI state for player surface.
commands.add_command('getAI_state', "", 
	function(command)
		local result = remote.call("rampantFixed", "getAI_state", {surfaceIndex = game.players[command.player_index].surface.index})
		if result then
			game.print("AI_state: ".. result.state .. "("..result.stateEnglish..")")
		else
			game.print("non-rampant surface")
		end
	end
)

-- parameter: number. set AI points for player surface.
commands.add_command('setAI_state', "", 
	function(command)
		if not remote.call("rampantFixed", "allowExternalControl") then
			game.print("external control isn't allowed")
			return		
		end
		
		local result = remote.call("rampantFixed", "setAI_state_ExtCtrl", {surfaceIndex = game.players[command.player_index].surface.index, state = (command.parameter and tonumber(command.parameter))})
		if result then
			game.print("AI_state: ".. result.state .. "("..result.stateEnglish..")" )
		else
			game.print("non-rampant surface or invalid state. Use /printValidAI_StateList")
		end
	end
)

-- no parameters. Print AI state for player surface
commands.add_command('printValidAI_StateList', "", 
	function(command)
		local result = remote.call("rampantFixed", "getValidAI_StateList")
		for state, stateEnglish in pairs(result) do
			game.print(""..state.." = ".. stateEnglish)
		end
	end
)	


-- no parameters. Print pheromones at player position
commands.add_command('printPheromones', "", 
	function(command)
		local parameters = {}
		parameters.surfaceIndex = game.players[command.player_index].surface.index
		parameters.position = game.players[command.player_index].position
		local result = remote.call("rampantFixed", "getPheromones", parameters)
		for pheromoneType, pheromoneLvl in pairs(result) do
			game.print(""..pheromoneType.." = ".. pheromoneLvl)
		end
	end
)	