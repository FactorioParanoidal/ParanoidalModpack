



script.on_init(function()
    local frozeta_start = settings.startup["check-this-if-frozeta-start"].value 
    if(script.active_mods["aps-planet"]) then
        if(settings.startup["aps-planet"].value == "frozeta") then --No idea why this line doesn't trigger. Doesn't work for cubium either.
            frozeta_start = true
        end
    end

    if not remote.interfaces["freeplay"] then return end
    if not frozeta_start then return end
    remote.call("freeplay", "set_ship_items", 
    {
        ["copper-plate"] = 50,
    })
    remote.call("freeplay", "set_created_items", {
        ["recycler"] = 1,
        ["medium-electric-pole"] = 20,
        ["biochamber"] = 5,
        ["uranium-235"] = 50,
        ["heavy-oil-barrel"] = 1,
        ["concrete"] = 100,
    })
    remote.call("freeplay", "set_debris_items", {
        ["iron-plate"] = 50,
        ["copper-plate"] = 50,
    })

    

end)


script.on_event(defines.events.on_player_joined_game, function(event)
    local frozeta_start = settings.startup["check-this-if-frozeta-start"].value 
    if(script.active_mods["aps-planet"]) then
        if(settings.startup["aps-planet"].value == "frozeta") then
            frozeta_start = true
        end
    end
    if not frozeta_start then return end -- No soup for you if you don't start on Frozeta

    local player = game.players[event.player_index]
    player.force.technologies["recycling"].research_recursive()
    player.force.technologies["planet-discovery-secretas"].research_recursive()
	player.force.technologies["nuclear-power"].research_recursive()
    --Not sure why this last part isn't working. But whatever.
    local armor = player.insert({ name = "power-armor", count = 1 })
	local inv = player.get_inventory(defines.inventory.character_armor)

	if armor > 0 and inv and inv.valid then
		local armor_item = inv[1]
		if armor_item and armor_item.valid then
			local grid = armor_item.grid
			if grid then
				grid.put({ name = "fission-reactor-equipment" })
				grid.put({ name = "exoskeleton-equipment" })
				grid.put({ name = "exoskeleton-equipment" })
				grid.put({ name = "personal-roboport-equipment" })
				grid.put({ name = "battery-mk2-equipment" })
				grid.put({ name = "battery-mk2-equipment" })
				grid.put({ name = "battery-mk2-equipment" })
				grid.put({ name = "battery-mk2-equipment" })
				grid.put({ name = "battery-mk2-equipment" })
				grid.put({ name = "battery-mk2-equipment" })
			end
		end
	end

end)


--I didn't write this. Frontrider did.
if script.active_mods["dea-dia-system"] then
    -- dea dia does not want to, or need to know about what tile this surface needs a replacement for,
    -- so we include the normal paltform cleaning code here.
    local function mine_collector(entity, player)
        local platform_radius = remote.call("dea_dia_system", "platform_radius")
        local position = entity.position
        local surface = entity.surface
        -- reset the surface tiles
        if entity.surface.name == "secretas" then
            local tiles = {}
            for x = position.x - platform_radius, position.x + platform_radius do
                for y = position.y - platform_radius, position.y + platform_radius do
                    table.insert(tiles, #tiles + 1, {
                        position = { x = x, y = y },
                        name = "secretas-surface"
                    })
                end
            end
            surface.set_tiles(tiles, true, false, true, false)
        end
    end


    script.on_event(defines.events.on_entity_died, function(event)
        mine_collector(event.entity)
    end, { {
        filter = "name",
        name = "gas-collector-roboport"
    } })

    script.on_event(defines.events.on_player_mined_entity, function(event)
        mine_collector(event.entity, event.player)
    end, { {
        filter = "name",
        name = "gas-collector-roboport"
    } })

    script.on_event(defines.events.on_robot_mined_entity, function(event)
        mine_collector(event.entity)
    end, { {
        filter = "name",
        name = "gas-collector-roboport"
    } })
end
