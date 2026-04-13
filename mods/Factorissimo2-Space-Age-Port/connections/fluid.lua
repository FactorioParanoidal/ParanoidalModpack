Fluid = {}

Fluid.color = {r = 167/255, g = 229/255, b = 255/255}
Fluid.entity_types = {"pipe", "pipe-to-ground", "storage-tank"}
Fluid.unlocked = function(force) return force.technologies["factory-connection-type-fluid"].researched end

local DX = {
	[defines.direction.north] = 0,
	[defines.direction.east] = 1,
	[defines.direction.south] = 0,
	[defines.direction.west] = -1,
}
local DY = {
	[defines.direction.north] = -1,
	[defines.direction.east] = 0,
	[defines.direction.south] = 1,
	[defines.direction.west] = 0,
}

local blacklist = {
	"factory-fluid-dummy-connector-" .. defines.direction.north,	"factory-fluid-dummy-connector-" .. defines.direction.east,	"factory-fluid-dummy-connector-" .. defines.direction.south,	"factory-fluid-dummy-connector-" .. defines.direction.west,
}
local blacklisted = {}
for _,name in pairs(blacklist) do blacklisted[name] = true end

local function is_inside_connected(factory, cid, entity)
	if blacklisted[entity.name] then return false end
	local connector = factory.inside_fluid_dummy_connectors[cid]
	local neighbours = connector.neighbours[1]
	for _, e2 in pairs(neighbours) do
		if e2.unit_number == entity.unit_number then return true end
	end
end

local function is_outside_connected(factory, cid, entity)
	if blacklisted[entity.name] then return false end
	local connector = factory.outside_fluid_dummy_connectors[cid]
	local neighbours = connector.neighbours[1]
	for _, e2 in pairs(neighbours) do
		if e2.unit_number == entity.unit_number then return true end
	end
end

Fluid.connect = function(factory, cid, cpos, outside_entity, inside_entity)	
	if is_inside_connected(factory, cid, inside_entity) and is_outside_connected(factory, cid, outside_entity) and outside_entity.fluidbox.get_capacity(1) > 0 and inside_entity.fluidbox.get_capacity(1) > 0 then
		return {
			outside = outside_entity, inside = inside_entity,
			outside_capacity = outside_entity.fluidbox.get_prototype(1).volume,
			inside_capacity = inside_entity.fluidbox.get_prototype(1).volume,
		}
	end
	return nil
end

Fluid.recheck = function (conn)
	local cpos = conn._factory.layout.connections[conn._id]
	return conn.outside.valid and conn.inside.valid
	and is_outside_connected(conn._factory, conn._id, conn.outside) and is_inside_connected(conn._factory, conn._id, conn.inside)
end

local DELAYS = {1, 4, 10, 30, 120}
local DEFAULT_DELAY = 10

Fluid.indicator_settings = {"d0", "b0"}

for _,v in pairs(DELAYS) do
	table.insert(Fluid.indicator_settings, "d" .. v)
	table.insert(Fluid.indicator_settings, "b" .. v)
end

local function make_valid_delay(delay)
	for _,v in pairs(DELAYS) do
		if v == delay then return v end
	end
	return 0 -- Catchall
end

Fluid.direction = function (conn)
	local mode = (conn._settings.mode or 0)
	if mode == 0 then
		return "b" .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), defines.direction.north
	elseif mode == 1 then
		return "d" .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), conn._factory.layout.connections[conn._id].direction_in
	else
		return "d" .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), conn._factory.layout.connections[conn._id].direction_out
	end
	
end

Fluid.rotate = function (conn)
	conn._settings.mode = ((conn._settings.mode or 0)+1)%3
	local mode = conn._settings.mode
	if mode == 0 then
		return {"factory-connection-text.balance-mode"}
	elseif mode == 1 then
		return {"factory-connection-text.input-mode"}
	else
		return {"factory-connection-text.output-mode"}
	end
end

Fluid.adjust = function (conn, positive)
	local delay = conn._settings.delay or DEFAULT_DELAY
	if positive then
		for i = #DELAYS,1,-1 do
			if DELAYS[i] < delay then
				delay = DELAYS[i]
				break
			end
		end
		conn._settings.delay = delay
		return {"factory-connection-text.update-faster", delay}
	else
		for i = 1,#DELAYS do
			if DELAYS[i] > delay then
				delay = DELAYS[i]
				break
			end
		end
		conn._settings.delay = delay
		return {"factory-connection-text.update-slower", delay}
	end
end

-- So... Why is this needed???
-- Before the space age update it seems like each pipe had its own fluidbox so just updating the .amount of it
-- would be enough to update the fluid amount in the pipe. 
-- But now, it seems like all pipes share the same fluidbox (or something like that) since asking for the fluidbox's
-- capacity returns the total capacity in the pipeline.
-- So, one would assume that doing fluidbox[1].amount will give the total fluid in the pipeline, but it returns the fluid in the pipe only.
-- From this you would think that doing fluidbox[1].amount = x would only update the fluid in the pipe
-- BUT NO, it updates the total fluid in the pipeline (i.e. setting it to 100 empties the entire pipeline and sets all of it to 100).
-- This is inconsistent as the `.amount` acts differently depending on if you get or set it, so... Maybe it is a bug?
-- This function is a workaround for this inconsistency.
-- fluid is just the fluidbox[1] object. Since it can be nil, we also get a reffluid which is just a fluid object
-- that we can use to get the fluid's name and temperature (has to be non-nil).
local function set_pipe_amount(fluidbox, fluid, reffluid, amount)
	if fluid == nil then
		fluid = {name = reffluid.name, amount = amount, temperature = reffluid.temperature}
		fluidbox[1] = fluid
		return
	end

	local realamount = fluidbox.get_fluid_segment_contents(1)[fluid.name]
	local pipeamount = fluid.amount
	local newamount = realamount - pipeamount + amount

	if newamount <= 0.01 then
		fluidbox[1] = nil
		return
	end
	fluid.amount = newamount
	fluidbox[1] = fluid
end

local function transfer(from, to, from_cap, to_cap)
	local from_fluidbox = from.fluidbox
	local from_fluid = from_fluidbox[1]
	local to_fluidbox = to.fluidbox
	local to_fluid = to_fluidbox[1]

	if from_fluid ~= nil then
		if to_fluid == nil then 
			if from_fluid.amount <= to_cap then
				-- from_fluidbox[1] = nil
				set_pipe_amount(from_fluidbox, from_fluid, from_fluid, 0)
				-- to_fluidbox[1] = from_fluid
				set_pipe_amount(to_fluidbox, to_fluid, from_fluid, from_fluid.amount)
			else
				-- from_fluid.amount = from_fluid.amount - to_cap
				-- from_fluidbox[1] = from_fluid
				set_pipe_amount(from_fluidbox, from_fluid, from_fluid, from_fluid.amount - to_cap)
				-- from_fluid.amount = to_cap
				-- to_fluidbox[1] = from_fluid
				set_pipe_amount(to_fluidbox, from_fluid, from_fluid, to_cap)
			end
		elseif to_fluid.name == from_fluid.name then
			local total = from_fluid.amount + to_fluid.amount
			if total <= to_cap then
				-- from_fluidbox[1] = nil
				set_pipe_amount(from_fluidbox, from_fluid, from_fluid, 0)
				to_fluid.temperature = (from_fluid.amount*from_fluid.temperature + to_fluid.amount*to_fluid.temperature)/total
				-- to_fluid.amount = total
				-- to_fluidbox[1] = to_fluid
				set_pipe_amount(to_fluidbox, to_fluid, from_fluid, total)
			else
				to_fluid.temperature = (to_fluid.amount*to_fluid.temperature + (to_cap-to_fluid.amount)*from_fluid.temperature)/to_cap
				-- to_fluid.amount = to_cap
				-- to_fluidbox[1] = to_fluid
				set_pipe_amount(to_fluidbox, to_fluid, from_fluid, to_cap)
				-- from_fluid.amount = total - to_cap
				-- from_fluidbox[1] = from_fluid
				set_pipe_amount(from_fluidbox, from_fluid, from_fluid, total - to_cap)
			end
		end
	end
end

local function balance(from, to, from_cap, to_cap)
	local from_fluidbox = from.fluidbox
	local from_fluid = from_fluidbox[1]
	local to_fluidbox = to.fluidbox
	local to_fluid = to_fluidbox[1]
	if from_fluid ~= nil and to_fluid ~= nil then
		if from_fluid.name == to_fluid.name then
			local from_amount = from_fluid.amount
			local to_amount = to_fluid.amount
			local both_fill = (from_amount+to_amount)/(from_cap+to_cap)
			local transfer_amount = (from_amount+to_amount)*to_cap/(from_cap+to_cap)-to_amount
			if transfer_amount > 0 then
				to_fluid.temperature = (to_amount*to_fluid.temperature + transfer_amount*from_fluid.temperature)/(to_amount+transfer_amount)
			else
				from_fluid.temperature = (from_amount*from_fluid.temperature - transfer_amount*to_fluid.temperature)/(from_amount-transfer_amount)
			end
			-- from_fluid.amount = from_amount-transfer_amount
			-- to_fluid.amount = to_amount+transfer_amount
			-- from_fluidbox[1] = from_fluid
			-- to_fluidbox[1] = to_fluid

			set_pipe_amount(from_fluidbox, from_fluid, from_fluid, from_amount-transfer_amount)
			set_pipe_amount(to_fluidbox, to_fluid, to_fluid, to_amount+transfer_amount)
		end
	elseif from_fluid ~= nil then
		local from_amount = from_fluid.amount
		local transfer_amount = from_amount * to_cap / (from_cap + to_cap)
		-- from_fluid.amount = from_amount - transfer_amount
		-- from_fluidbox[1] = from_fluid
		set_pipe_amount(from_fluidbox, from_fluid, from_fluid, from_amount - transfer_amount)
		from_fluid.amount = transfer_amount
		-- to_fluidbox[1] = from_fluid
		set_pipe_amount(to_fluidbox, to_fluid, from_fluid, transfer_amount)
	elseif to_fluid ~= nil then
		local to_amount = to_fluid.amount
		local transfer_amount = to_amount * from_cap / (from_cap + to_cap)
		-- to_fluid.amount = to_amount - transfer_amount
		-- to_fluidbox[1] = to_fluid
		set_pipe_amount(to_fluidbox, to_fluid, to_fluid, to_amount - transfer_amount)
		-- to_fluid.amount = transfer_amount
		-- from_fluidbox[1] = to_fluid
		set_pipe_amount(from_fluidbox, from_fluid, to_fluid, transfer_amount)
	end
end

Fluid.tick = function(conn)
	local outside = conn.outside
	local inside = conn.inside
	local outside_cap = conn.outside_capacity
	local inside_cap = conn.inside_capacity
	if outside.valid and inside.valid then
		local mode = conn._settings.mode or 0
		if mode == 0 then
			-- Balance
			balance(outside, inside, outside_cap, inside_cap)
		elseif mode == 1 then
			-- Input
			transfer(outside, inside, outside_cap, inside_cap)
		else
			-- Output
			transfer(inside, outside, inside_cap, outside_cap)
		end
		return conn._settings.delay or DEFAULT_DELAY
	else
		return false
	end
end

Fluid.destroy = function(conn)
end