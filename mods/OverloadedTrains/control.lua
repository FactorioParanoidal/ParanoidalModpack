local fluiddensity = { -- fluid = 0.1/wagon weight factor * content factor
	["water"] = 1, -- g/cm3 or t/m3
	["sulfuric-acid"] = 1.84, -- g/cm3 or t/m3
	["lubricant"] = 1, -- g/cm3 or t/m3
	["petroleum-gas"] = 0.8, -- 0.002g/cm3 (vapor), 0.8 g/cm3 (fluid)
	["light-oil"] = 0.87, -- g/cm3 or t/m3
	["heavy-oil"] = 1, -- g/cm3 or t/m3
	["crude-oil"] = 0.92, -- g/cm3 or t/m3
}

local items =
	{ -- density/stacksize*stackability -- stacksize is fixed to the vanilla values, so stuff gets heavier when a mod increases them
		["iron-ore"] = 5.1 / 50 * 0.6,
		["copper-ore"] = 5.7 / 50 * 0.6, -- actually 2.3 but needs to be heavier than iron-ore
		["uranium-ore"] = 2.1 / 50 * 0.6,
		["stone"] = 1.6 / 50 * 0.6,
		["iron-plate"] = 7.9 / 100 * 0.4,
		["steel-plate"] = 7.9 / 100 * 0.4,
		["copper-plate"] = 8.9 / 100 * 0.4,
		["raw-wood"] = 0.8 / 100 * 0.5,
		["wood"] = 0.8 / 50 * 0.7,
		["coal"] = 0.9 / 50 * 0.7,
		["plastic-bar"] = 0.9 / 100 * 0.7,
		["solid-fuel"] = 1.8 / 50 * 0.6,
		["bob-glass"] = 2.8 / 50 * 0.6,
		["bob-sulfur"] = 1.9 / 50 * 0.6,
		["battery"] = 2.3 / 200 * 0.6,
		["uranium-238"] = 19 / 50 * 0.3,
		["uranium-235"] = 19 / 50 * 0.3,
		["raw-fish"] = 1 / 50 * 0.6,
		["processing-unit"] = 4.9 / 100 * 0.4, -- 50% copper + plastic (?)
		["advanced-circuit"] = 4.1 / 200 * 0.4, -- 40% copper + plastic (?)
		["electronic-circuit"] = 3.3 / 200 * 0.4, -- 30% copper + plastic (?)
		["empty-barrel"] = 0.8 / 10 * 0.5,
		["engine-unit"] = 5.5 / 50 * 0.5, -- 70% steel (?)
		["electric-engine-unit"] = 6.7 / 50 * 0.5, -- 85% steel (?)
		["iron-gear-wheel"] = 3.9 / 100 * 0.5, -- 50% iron (?)
		["iron-stick"] = 6.7 / 100 * 0.5, -- 85% iron (?)
		["copper-cable"] = 6 / 200 * 0.4, -- 66% copper (100 copper = 300 cables, reduced to a 200-stack)
		["science-pack-1"] = 4 / 200 * 0.6, -- no idea..
		["science-pack-2"] = 4 / 200 * 0.6, -- no idea..
		["science-pack-3"] = 4 / 200 * 0.6, -- no idea..
		["military-science-pack"] = 4 / 200 * 0.6, -- no idea..
		["production-science-pack"] = 4 / 200 * 0.6, -- no idea..
		["high-tech-science-pack"] = 4 / 200 * 0.6, -- no idea..
		["flying-robot-frame"] = 6.4 / 50 * 0.5, -- 80% steel (?)
		["pistol"] = 1.2,
		["submachine-gun"] = 3.2,
		["shotgun"] = 3.2,
		["combat-shotgun"] = 4,
		["flamethrower"] = 20,
		["rocket-launcher"] = 4.5,
		["firearm-magazine"] = 8 / 200 * 0.4, -- iron
		["piercing-rounds-magazine"] = 8.5 / 200 * 0.4, -- steel/copper
		["uranium-rounds-magazine"] = 13.5 / 200 * 0.4, -- 50%uranium + steel
		["flamethrower-ammo"] = 3 / 100 * 0.4, -- no idea
		-- ["stone"] =						/200 	*2/23.4*1000,
	}

local entities = {
	["charactercorpse"] = 2,
	["corpse"] = 2,
	["entitywithhealth"] = 10,
	["solar-panel"] = 6,
	["accumulator"] = 6,
	["artilleryturret"] = 8,
	["beacon"] = 8,
	["boiler"] = 10,
	["character"] = 2,
	["combinator"] = 2,
	["arithmeticcombinator"] = 2,
	["decidercombinator"] = 2,
	["constantcombinator"] = 2,
	["container"] = 2,
	["logisticcontainer"] = 2,
	["infinitycontainer"] = 2,
	["craftingmachine"] = 10,
	["assemblingmachine"] = 10,
	["rocketsilo"] = 30,
	["furnace"] = 10,
	["electricenergyinterface"] = 8,
	["electricpole"] = 4,
	["enemyspawner"] = 10,
	["fish"] = 1,
	["flyingrobot"] = 1,
	["combatrobot"] = 1,
	["robotwithlogisticinterface"] = 1,
	["constructionrobot"] = 1,
	["logisticrobot"] = 1,
	["gate"] = 6,
	["generator"] = 15,
	["heatpipe"] = 3,
	["inserter"] = 2,
	["lab"] = 10,
	["lamp"] = 2,
	["landmine"] = 2,
	["market"] = 10,
	["miningdrill"] = 8,
	["offshorepump"] = 5,
	["pipe"] = 3,
	["pipetoground"] = 3,
	["playerport"] = 10,
	["powerswitch"] = 8,
	["programmablespeaker"] = 4,
	["pump"] = 4,
	["radar"] = 15,
	["rail"] = 3,
	["curvedrail"] = 3,
	["straightrail"] = 3,
	["railsignalbase"] = 2,
	["railchainsignal"] = 2,
	["railsignal"] = 2,
	["reactor"] = 25,
	["roboport"] = 20,
	["simpleentity"] = 8,
	["simpleentitywithowner"] = 8,
	["simpleentitywithforce"] = 8,
	["solarpanel"] = 5,
	["storagetank"] = 9,
	["trainstop"] = 2,
	["transportbeltconnectable"] = 1,
	["loader"] = 3,
	["splitter"] = 3,
	["transportbelt"] = 1,
	["undergroundbelt"] = 2,
	["tree"] = 2,
	["turret"] = 5,
	["ammoturret"] = 5,
	["electricturret"] = 5,
	["fluidturret"] = 5,
	["unit"] = 3,
	["vehicle"] = 5,
	["car"] = 7,
	["rollingstock"] = 10,
	["artillerywagon"] = 18,
	["cargowagon"] = 12,
	["fluidwagon"] = 12,
	["locomotive"] = 16,
	["wall"] = 6,
	["arrow"] = 1,
	["artilleryprojectile"] = 20,
	["beam"] = 1,
	["cliff"] = 5,
	["deconstructibletileproxy"] = 1,
	["entityghost"] = 1,
	["explosion"] = 2,
	["flamethrowerexplosion"] = 2,
	["fireflame"] = 2,
	["fluidstream"] = 2,
	["flyingtext"] = 2,
	["itementity"] = 1,
	["itemrequestproxy"] = 3,
	["legacydecorative"] = 3,
	["particle"] = 1,
	["artilleryflare"] = 1,
	["leafparticle"] = 1,
	["particlesource"] = 1,
	["projectile"] = 1,
	["railremnants"] = 3,
	["resourceentity"] = 1,
	["rocketsilorocket"] = 10,
	["rocketsilorocketshadow"] = 1,
	["smoke"] = 1,
	["simplesmoke"] = 1,
	["smokewithtrigger"] = 1,
	["sticker"] = 1,
	["tileghost"] = 1,
}

local blacklist = {
	["minigun-platform-mk1"] = true,
	["minigun-platform-mk2"] = true,
	["shotgun-platform-mk1"] = true,
	["cannon-platform-mk1"] = true,
	["rocket-platform-mk1"] = true,
	["rocket-platform-mk2"] = true,
	["flamethrower-wagon-mk1"] = true,
	["radar-platform-mk1"] = true,
	["searchlight-platform-mk1"] = true,
	["repair-platform-mk1"] = true,
	["accumulator-wagon"] = true,
}

local train_state_translations = {}
for a, b in pairs(defines.train_state) do
	train_state_translations[b] = a
end
local function dbg(str)
	if not storage.setting_debug_mode then
		return
	end
	if not storage.dbg then
		storage.dbg = 1
	end
	--game.players[1].print(storage.dbg .. " " .. game.tick .. ": " .. str)
	game.players[1].print(str)
	storage.dbg = storage.dbg + 1
end

-- freight wagon 26t empty weight, full with steel: +647t (total: 82 m3) (2 m3 per slot)
local function itemweight(name)
	--game.print(name)
	local weight = 10
	if items[name] then
		weight = items[name] -- tons per m3 / stacksize
		-- example: 4000 steel
		-- /100 stacksize
		weight = weight / 40 * 82 -- *~2m3 per slot
		if prototypes.item[name].stack_size then
			dbg(math.floor(weight * prototypes.item[name].stack_size * 40) .. "t/wagon: " .. name)
		else
			dbg(math.floor(weight * 40) .. "t/wagon: " .. name)
		end
	elseif prototypes.item[name].place_result then
		if entities[prototypes.item[name].place_result.type] then
			--basically 400-600t per wagon
			weight = (20 + entities[prototypes.item[name].place_result.type]) / 2
		end

		-- honestly, the factorio weights are all over the place and can't be used.
		-- 800 portable fusion reactors = 800t (stacks 20x)
		-- 2000 ore = 4t (stacks 50x)
		-- 4000 refined concrete = 40t (stacks 100x)
		-- 4000 rockets/magazines = 160t (stack 100x)
		-- maybe mult by 10? idk, this is ridiculous and shouldnt be used

		-- native weights
		if
			storage.setting_factorio_weights
			and (prototypes.item[name].place_result.weight or prototypes.item[name].weight)
		then
			weight = (prototypes.item[name].place_result.weight or prototypes.item[name].weight) / 1000 / 1000 * 10
			if prototypes.item[name].stack_size then
				dbg(
					math.floor(weight * prototypes.item[name].stack_size * 40)
						.. "t/wagon: "
						.. name
						.. " ("
						.. prototypes.item[name].place_result.type
						.. ")"
				)
			else
				dbg(
					math.floor(weight * 40)
						.. "t/wagon: "
						.. name
						.. " ("
						.. prototypes.item[name].place_result.type
						.. ")"
				)
			end
			return weight
		end
		dbg(math.floor(weight * 40) .. "t/wagon: " .. name .. " (" .. prototypes.item[name].place_result.type .. ")")
		if prototypes.item[name].stack_size then
			weight = weight / prototypes.item[name].stack_size
		end
	elseif prototypes.item[name].stack_size then
		-- native weights
		if storage.setting_factorio_weights and prototypes.item[name].weight then
			weight = prototypes.item[name].weight / 1000 / 1000 * 10
			dbg(math.floor(weight * prototypes.item[name].stack_size * 40) .. "t/wagon: " .. name)
			return weight
		end

		--basically 400t per wagon
		weight = 8 / prototypes.item[name].stack_size * 0.6 / 40 * 82
		dbg(math.floor(weight * prototypes.item[name].stack_size * 40) .. "t/wagon: " .. name)
	end
	return weight
end

local function deadlocks(name)
	local weight = 1
	local amount = 1
	if string.sub(name, 1, 15) == "deadlock-crate-" then
		local actual_item_name = string.sub(name, 16)
		amount = prototypes.item[actual_item_name].stack_size / 5
		weight = itemweight(actual_item_name)
	elseif string.sub(name, 1, 15) == "deadlock-stack-" then
		local actual_item_name = string.sub(name, 16)
		amount = 5
		weight = itemweight(actual_item_name)
	elseif string.sub(name, 1, 18) == "deadlock-stacking-" then
		local actual_item_name = string.sub(name, 19)
		amount = 5
		weight = itemweight(actual_item_name)
	end
	return weight * amount
end

local function GetCargoCarriageWeight(carriage)
	local carriage_weight = 0
	local contents = carriage.get_inventory(defines.inventory.cargo_wagon).get_contents()
	for _, _contents in ipairs(contents) do
		local content = _contents.name
		local amount = _contents.count
		local weight = 1
		if string.sub(content, 1, 8) == "deadlock" then
			weight = deadlocks(content)
		else
			weight = itemweight(content)
		end
		weight = weight * amount
		carriage_weight = carriage_weight + weight
	end
	return carriage_weight
end

local function GetFluidCarriageWeight(carriage)
	local contents = carriage.get_fluid_contents()
	local carriage_weight = 0
	for content, amount in pairs(contents) do
		-- tankwagon 23.4t empty weight, +86t (86 m3) water https://www.vtg.com/fileadmin/vtg/dokumente/waggon-datenblaetter/Mineraloelkesselwagen-M16.086C.pdf
		if fluiddensity[content] then -- tons per m3
			carriage_weight = carriage_weight + fluiddensity[content] * amount / 50000 * 86 --50k units in factorio must be 86 m3
		else
			carriage_weight = carriage_weight + 1 * amount / 50000 * 86
		end
	end
	return carriage_weight
end

---@class CarriageData
---@field baseName string name of in game carriage entity
---@field level number weightness [0, 20] 0 -- empty, 20 -- max weight
local CarriageData = {}

---@param name string
---@return CarriageData
local function GetCarriageData(name)
	if name:sub(#"OT_level-") ~= "OT_level-" then
		return { -- default in game carriage -- 0 level
			baseName = name,
			level = 0,
		}
	end
	-- Example
	-- 1 2 3 4 5 6 7 8 9 10 11 13 14 15 16 17
	-- O T _ l e v e l - 1  2  -  s  o  m  e
	--          begin -> ^  ^ <- end     (inclusive)
	local levelOffset = name:find("-", 10)
	local level = tonumber(name:sub(10, levelOffset - 1))
	local baseName = name:sub(levelOffset + 1)
	return {
		baseName = baseName,
		level = level,
	}
end

---Creates new carriage entity name based on old and new levels
---@param carriageData CarriageData
---@param newLevel number must be not negative
local function GetNewCarriageName(carriageData, newLevel)
	if newLevel <= 0 then
		return carriageData.baseName
	end
	newLevel = math.min(20, newLevel)
	return "OT_level-" .. newLevel .. "-" .. carriageData.baseName
end

script.on_event(defines.events.on_train_changed_state, function(event)
	local train = event.train
	local new_state = train_state_translations[train.state]

	for _, carriage in pairs(train.carriages) do
		if carriage.type == "locomotive" then
			if not storage.trains[carriage.unit_number] then
				storage.trains[carriage.unit_number] = game.tick
			elseif storage.trains[carriage.unit_number] > game.tick - 2 then
				return -- infinine loop detected
			else
				storage.trains[carriage.unit_number] = game.tick
			end
		end
	end
	if new_state == "arrive_station" then
		return
	end
	if train.speed == 0 and new_state ~= "on_the_path" then
		return
	end
	local manual_mode = train.manual_mode
	local drivers = {}

	local carriages = {}
	local players = 0
	local player_weight = 0 --unused
	local total_weight = 0
	local already_applied_player_level = 0
	-- first pass, scan
	for iCarriage, carriage in pairs(train.carriages) do
		local passenger = false
		if carriage.get_driver() then
			passenger = true
			table.insert(drivers, {
				player = carriage.get_driver(),
				position = carriage.position,
				riding_state = carriage.get_driver().riding_state,
			})
		end
		if blacklist[carriage.name] then
			goto continue
		end
		table.insert(carriages, GetCarriageData(carriage.name))
		local carriage_weight = 0
		if carriage.type == "cargo-wagon" then
			carriage_weight = GetCargoCarriageWeight(carriage)
		elseif carriage.type == "fluid-wagon" then
			carriage_weight = GetFluidCarriageWeight(carriage)
		end
		total_weight = total_weight + carriage_weight
		if passenger then
			players = players + 1
			player_weight = player_weight + carriage_weight
			already_applied_player_level = already_applied_player_level + carriages[iCarriage].level
		end
		::continue::
	end
	total_weight = total_weight * settings.global["OT_realism"].value
	--total_weight = total_weight/1000 --tons
	dbg("total: " .. math.floor(total_weight * 10) / 10 .. "t" .. " / " .. #carriages .. " cars")
	local total_level = total_weight / 26 -- times 1000 factorio weight, 1 wagon = 1000 weight
	local weight_per_wagon = (total_level - already_applied_player_level) / (#carriages - players)
	local remainder = (total_level - already_applied_player_level)
		- (#carriages - players) * math.floor(weight_per_wagon)
	local should_glitch = false
	if #carriages <= players then
		should_glitch = true
		weight_per_wagon = total_level / #carriages
		remainder = total_level - #carriages * math.floor(weight_per_wagon)
	end
	local extra_levels = math.ceil(remainder)
	local train_unchanged = true
	local current_schedule = train.schedule

	--replace entities
	for iCarriage, carriage in pairs(train.carriages) do
		if not blacklist[carriage.name] then
			if
				(carriage.type == "fluid-wagon" or carriage.type == "cargo-wagon")
				and (not carriage.get_driver() or should_glitch)
			then
				local old_level = carriages[iCarriage].level
				local new_level = math.floor(weight_per_wagon)
				if extra_levels > 0 then
					new_level = new_level + 1
				end
				new_level = math.min(20, new_level)
				if old_level ~= new_level then
					train_unchanged = false
					local position = carriage.position
					local orientation = carriage.orientation
					local force = carriage.force
					local health = carriage.health
					local surface = carriage.surface
					local quality = carriage.quality
					local disconnected_back = carriage.disconnect_rolling_stock(defines.rail_direction.back)
					local disconnected_front = carriage.disconnect_rolling_stock(defines.rail_direction.front)
					local contents
					if carriage.type == "cargo-wagon" then
						contents = carriage.get_inventory(defines.inventory.cargo_wagon).get_contents()
					else
						contents = carriage.get_fluid(1)
					end
					local grid_contents = nil
					if carriage.grid then
						grid_contents = {}
						for _, equipment in pairs(carriage.grid.equipment) do
							table.insert(grid_contents, {
								name = equipment.name,
								quality = equipment.quality,
								position = equipment.position,
								energy = equipment.energy,
								shield = equipment.shield,
							})
						end
					end

					carriage.destroy({ raise_destroy = true })
					local newcar = surface.create_entity({
						name = GetNewCarriageName(carriages[iCarriage], new_level),
						position = position,
						orientation = orientation,
						force = force,
						quality = quality,
						raise_built = true,
					})

					newcar.health = health
					if grid_contents then
						for _, equipment in pairs(grid_contents) do
							local new_eq =
								newcar.grid.put({ name = equipment.name, quality = equipment.quality, position = equipment.position })
							new_eq.energy = equipment.energy
							if equipment.shield > 0 then
								new_eq.shield = equipment.shield
							end
						end
					end
					if newcar.type == "cargo-wagon" then
						for _, content in pairs(contents) do
							newcar.insert(content)
						end
					elseif contents then
						newcar.insert_fluid({
							name = contents.name,
							amount = contents.amount,
							temperature = contents.temperature,
						})
					end
					if disconnected_front then
						newcar.connect_rolling_stock(defines.rail_direction.front)
					end
					if disconnected_back then
						newcar.connect_rolling_stock(defines.rail_direction.back)
					end
					train = newcar.train
					extra_levels = extra_levels - 1
				end
			end
		end
	end
	if not train_unchanged then
		train.schedule = current_schedule
		for _, tbl in pairs(drivers) do
			if not tbl.player.driving then
				tbl.player.teleport(tbl.position)
				tbl.player.driving = true
			end
			tbl.player.riding_state = tbl.riding_state
		end
		train.manual_mode = manual_mode
	end
end)

-- much more performant settings:
script.on_init(function()
	storage.trains = {}
	storage.setting_factorio_weights = settings.global["OT_factorio-weights"].value
	storage.setting_realism = settings.global["OT_realism"].value
	storage.setting_debug_mode = settings.global["OT_debug-mode"].value
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(_)
	storage.setting_factorio_weights = settings.global["OT_factorio-weights"].value
	storage.setting_realism = settings.global["OT_realism"].value
	storage.setting_debug_mode = settings.global["OT_debug-mode"].value
end)

script.on_configuration_changed(function()
	storage.setting_factorio_weights = settings.global["OT_factorio-weights"].value
	storage.setting_realism = settings.global["OT_realism"].value
	storage.setting_debug_mode = settings.global["OT_debug-mode"].value
end)
