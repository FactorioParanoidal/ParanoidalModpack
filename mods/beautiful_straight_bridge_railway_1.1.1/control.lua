
runOnce = false

script.on_event(defines.events.on_tick, function(event)
	if runOnce then return end
	runOnce = true
	if remote.interfaces.RailPowerSystem and remote.interfaces.RailPowerSystem.addRail then
		local bridges = { "wood", "iron", "brick" }
		for i, id in ipairs(bridges) do
			remote.call("RailPowerSystem", "addRail", "bbr-straight-rail-electric-"..id, "bbr-curved-rail-electric-"..id)
		end
	end
end)

script.on_event("kap-bbr-cycle-key", function(event)
	local player = game.players[event.player_index]
	if player then
		local bprint = player.cursor_stack
		if bprint and bprint.valid and (bprint.is_blueprint or bprint.is_blueprint_book) and bprint.valid_for_read and bprint.is_blueprint_setup() then
			replace_blueprint_rails(player, bprint)
		end
	end
end)

function get_replace_list(entities)
-- get installed rails
	local item = game.item_prototypes
	local index = {}
	local s_rails = {}
	local c_rails = {}
	local rail_counts = {}
	local rail_nums = {}
	if item then
		for i, val in pairs(item) do
			if val.type == "rail-planner" then
				local s_name = val.straight_rail.name
				local c_name = val.curved_rail.name
				table.insert(index, {name = val.name, straight_rail = s_name, curved_rail = c_name, local_name = val.localised_name})
				s_rails[s_name] = 1
				c_rails[c_name] = 1
				rail_counts[val.name] = 0
				rail_nums[s_name] = { name = val.name, num = 1}
				rail_nums[c_name] = { name = val.name, num = 4}
			end
		end
	end

-- count rails in blueprint
	for i, entity in pairs (entities) do
		if rail_nums[entity.name] then
			rail_counts[rail_nums[entity.name].name] = rail_counts[rail_nums[entity.name].name] + rail_nums[entity.name].num
		end
	end

-- get next rail
	local max_num = -1
	local max_name
	for name, count in pairs(rail_counts) do
		if count > max_num then
			max_num = count
			max_name = name
		end
	end

	local target_index = 1
	if not max_name then return end
	for i, val in pairs(index) do
		if max_name == val.name then
			target_index = i+1
			break
		end
	end
	if target_index > #index then
		target_index = 1
	end

	return { [index[target_index].straight_rail] = s_rails, [index[target_index].curved_rail] = c_rails }, index[target_index].local_name

end


function replace_blueprint_rails(player, bprint)
	local entities = bprint.get_blueprint_entities()
	if entities then
		local is_replace = false
		local lists, replace_name = get_replace_list(entities)
		if lists then
			for r_to, r_from in pairs(lists) do
			    for k, entity in pairs (entities) do
					if r_from[entity.name] then
						is_replace = true
						entities[k].name = r_to
					end
				end
			end
			bprint.set_blueprint_entities(entities)
		end
		if is_replace then
			player.print(replace_name)
		end
	end
end

