local F = '__factorissimo-2-notnotmelon__'

local function blank()
	return {
		filename = F..'/graphics/nothing.png',
		priority = 'high',
		width = 1,
		height = 1
	}
end

for _, type in ipairs{'linked-belt', 'transport-belt', 'underground-belt', 'loader-1x1', 'loader', 'splitter'} do
	for _, belt in pairs(table.deepcopy(data.raw[type])) do
		local linked = belt
		linked.allow_side_loading = false
		linked.type = 'linked-belt'
		linked.next_upgrade = nil
		if not linked.localised_name then linked.localised_name = {'entity-name.' .. linked.name} end
		linked.name = 'factory-linked-' .. linked.name
		linked.structure = {
			direction_in = blank(),
			direction_out = blank()
		}
		linked.selection_box = nil
		linked.minable = nil
		linked.belt_length = nil
		linked.filter_count = nil
		linked.structure_render_layer = nil
		linked.container_distance = nil
		linked.belt_length = nil
		if type == 'loader' or type == 'splitter' then linked.collision_box = {{-0.4, -0.4}, {0.4, 0.4}} end
		
        data:extend{linked}
    end
end

local function factory_pipe(pipe, base_level, suffix)
	local new = table.deepcopy(pipe)
	new.name = 'factory-' .. pipe.name .. suffix
	if not pipe.localised_name then new.localised_name = {'entity-name.' .. pipe.name} end
	if mods['space-exploration'] and not pipe.localised_description then new.localised_description = {'entity-description.' .. pipe.name} end
	new.fluid_box.height = (pipe.fluid_box.height or 1) * 25
	new.fluid_box.base_level = new.fluid_box.height * base_level
	new.next_upgrade = nil

	local mine = new.minable
	if mine and not new.placeable_by then
		if mine.results then
			new.placeable_by = {}
			for _, result in pairs(mine.results) do
				local count = result.amount or result[2]
				if count then
					new.placeable_by[#new.placeable_by + 1] = {item = result.name or result[1], count = count}
				end
			end
		elseif mine.result then
			new.placeable_by = {item = mine.result, count = mine.count or 1}
		end
	end

	data:extend{new}
end

local blacklist = {
	['factory-fluid-dummy-connector-' .. defines.direction.north] = true,
	['factory-fluid-dummy-connector-' .. defines.direction.south] = true,
	['factory-fluid-dummy-connector-' .. defines.direction.east] = true,
	['factory-fluid-dummy-connector-' .. defines.direction.west] = true
}
for _, type in pairs{table.deepcopy(data.raw['pipe']), table.deepcopy(data.raw['pipe-to-ground'])} do
    for _, pipe in pairs(type) do
		if not blacklist[pipe.name] then
			factory_pipe(pipe, 0.96, '-output')
			factory_pipe(pipe, -0.96, '-input')
		end
    end
end
