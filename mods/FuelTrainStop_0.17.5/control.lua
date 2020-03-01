require("lib")

-- remote.call("FuelTrainStop", "exclude_from_fuel_schedule", locomotive-name)
remote.add_interface("FuelTrainStop",{exclude_from_fuel_schedule = function(name) AddTrainIgnore(name) end})

local train_ignore_list = {}


function Init()
	global.TrainStop = {}
	global.TrainStopName = "Fuel Stop"
	global.EnergyList = {}
	global.FinishTrain = {}
	global.TrainList = {}
end

function EnableFuelTrainStop()
	for _,force in pairs(game.forces) do
		local tech = force.technologies['automated-rail-transportation']
		if tech and tech.researched then 
			force.recipes['fuel-train-stop'].enabled = true
		end
	end
end

function CreateEnergyList()
	for _,item in pairs(game.item_prototypes) do
		if item.fuel_category then
			global.EnergyList[item.name] = item.fuel_value
		end
	end
end

function CreateTrainList()
	for _,surface in pairs(game.surfaces) do
		local trains = surface.get_trains()
		for _,train in pairs(trains) do
			for _,carriage in pairs(train.carriages) do
				if Contains(train_ignore_list,carriage.name) then goto continue end
			end
			
			global.TrainList[train.id] = train
			::continue::
		end
	end
end

function ON_INIT()
	Init()
	EnableFuelTrainStop()
	CreateEnergyList()
	CreateTrainList()
end
script.on_init(ON_INIT)

function ON_CONFIGURATION_CHANGED(data)
	global.EnergyList = {}
	CreateEnergyList()

	local mod_name = "FuelTrainStop"
	if NeedMigration(data,mod_name) then
		local old_version = GetOldVersion(data,mod_name)
		if old_version < "00.17.0" then
			ON_INIT()
	
			for _,surface in pairs(game.surfaces) do
				local train_stops = surface.find_entities_filtered{name="fuel-train-stop"}
				for _,stop in pairs(train_stops) do
					table.insert(global.TrainStop,stop)
				end
			end	
			
			if Count(global.TrainStop) > 0 then
				global.TrainStopName = global.TrainStop[1].backer_name or "Fuel Stop"
			end
			
			for _,train in pairs(global.TrainList) do
				local schedule = train.schedule
				if schedule then
					for i,record in pairs(schedule.records) do
						if record.station == global.TrainStopName then
							table.remove(schedule.records,i)
							if i > Count(schedule.records) then
								schedule.current = 1
							else
								schedule.current = i
							end					
							break
						end
					end
					train.schedule = schedule
				end
			end
		end
	end
end
script.on_configuration_changed(ON_CONFIGURATION_CHANGED)

function AddTrainIgnore(name)
	if not Contains(train_ignore_list,name) then 
		table.insert(train_ignore_list,name)
		CheckTrainList()
	end
end

function CheckTrainList()
	if global.TrainList then
		for i,train in pairs(global.TrainList) do
			if train and train.valid then
				for _,carriage in pairs(train.carriages) do
					if Contains(train_ignore_list,carriage.name) then 
						global.TrainList[i] = nil
						break;
					end
				end
			else
				global.TrainList[i] = nil
			end
		end
	end
end

function ON_BUILT_ENTITY(event)
	local entity = event.created_entity or event.entity
	if entity and entity.valid then
		if entity.name == "fuel-train-stop" then
			table.insert(global.TrainStop,entity)
			entity.backer_name = global.TrainStopName
		end
	end
end
script.on_event({defines.events.on_built_entity,defines.events.on_robot_built_entity,defines.events.script_raised_built},ON_BUILT_ENTITY)
	
function ON_REMOVE_ENTITY(event)
	local entity = event.entity
	if entity and entity.valid then
		if entity.name == "fuel-train-stop" then
			for i,stop in pairs(global.TrainStop) do
				if stop == entity then
					table.remove(global.TrainStop,i)
					break
				end
			end
		end
	end
end
script.on_event({defines.events.on_pre_player_mined_item,defines.events.on_robot_pre_mined,defines.events.on_entity_died,defines.events.script_raised_destroy},ON_REMOVE_ENTITY)

function ON_ENTITY_RENAMED(event)
	if not event.by_script and event.entity.name == "fuel-train-stop" then
		global.TrainStopName = event.entity.backer_name
		for i,stop in pairs(global.TrainStop) do
			if stop and stop.valid then
				stop.backer_name = global.TrainStopName
			else
				table.remove(global.TrainStop,i)
			end
		end
	end
end
script.on_event(defines.events.on_entity_renamed,ON_ENTITY_RENAMED)

function ON_TRAIN_CREATED(event)
	local train = event.train
	local old_train_id_1 = event.old_train_id_1
	local old_train_id_2 = event.old_train_id_2

	for _,carriage in pairs(train.carriages) do
		if Contains(train_ignore_list,carriage.name) then
			if old_train_id_1 then		
				global.TrainList[old_train_id_1] = nil
			end
			if old_train_id_2 then
				global.TrainList[old_train_id_2] = nil
			end
			goto continue 
		end
	end
	
	global.TrainList[train.id] = train
	
	if old_train_id_1 then
		global.TrainList[old_train_id_1] = nil
		
		if global.FinishTrain[old_train_id_1] then
			global.FinishTrain[old_train_id_1] = nil
			global.FinishTrain[train.id] = train
		end	
	end
	if old_train_id_2 then
		global.TrainList[old_train_id_2] = nil
		
		if global.FinishTrain[old_train_id_2] then
			global.FinishTrain[old_train_id_2] = nil
			global.FinishTrain[train.id] = train
		end	
	end
	::continue::
end
script.on_event(defines.events.on_train_created,ON_TRAIN_CREATED)

function ON_TRAIN_CHANGED_STATE(event)
	local train = event.train
	if train.state == defines.train_state.wait_station then
		if train.station and train.station.backer_name == global.TrainStopName then
			global.FinishTrain[train.id] = train
		end
	end
end
script.on_event(defines.events.on_train_changed_state,ON_TRAIN_CHANGED_STATE)

function GetEnergy(fuel_list)
	local e = 0
	for name,amount in pairs(fuel_list) do
		e = e + global.EnergyList[name] * amount
	end
	return e
end

function LowFuel(locomotive)
	local inventory = locomotive.get_fuel_inventory()
	if not inventory then return false end
	local contents = inventory.get_contents()
	local min_fuel = settings.global['min-fuel-amount'].value * locomotive.prototype.max_energy_usage * 800
	min_fuel = min_fuel / locomotive.prototype.burner_prototype.effectivity	
	if GetEnergy(contents) < min_fuel then
		return true
	else
		return false
	end
end

function AddSchedule(train)
	local schedule = train.schedule or {}
	if not train.schedule then
		schedule.records = {}
	end
	for _,record in pairs(schedule.records) do
		if record.station == global.TrainStopName then return end
	end
	local record = {station = global.TrainStopName, wait_conditions = {}}
	record.wait_conditions[#record.wait_conditions+1] = {type = "inactivity", compare_type = "and", ticks = 120 }
	local current = schedule.current or 0
	table.insert(schedule.records,current+1,record)
	train.schedule = schedule
end

function ON_1200TH_TICK()
	if Count(global.TrainStop) > 0 then 
		for i,train in pairs(global.TrainList) do
			if not train.valid then
				global.TrainList[i] = nil
				goto continue
			end
			
			if train.manual_mode then goto continue end
	
			for _,carriage in pairs(train.carriages) do
				if carriage.type == "locomotive" then
					if LowFuel(carriage) then
						AddSchedule(train)
						goto continue
					end
				end
			end
			::continue::
		end	
	end
end
script.on_nth_tick(1200,ON_1200TH_TICK)	

function ON_300TH_TICK()
	if Count(global.FinishTrain) > 0 then
		for i,train in pairs(global.FinishTrain) do
			if not train.valid then
				global.FinishTrain[i] = nil
			else
				if not (train.station and train.station.backer_name == global.TrainStopName) then 
					local schedule = train.schedule
					if(schedule) then
						for i,record in pairs(schedule.records) do
							if record.station == global.TrainStopName then
								table.remove(schedule.records,i)
								if i > Count(schedule.records) then
									schedule.current = 1
								else
									schedule.current = i
								end					
								break
							end
						end
						train.schedule = schedule
					end
					global.FinishTrain[i] = nil
				end
			end
		end
	end
end
script.on_nth_tick(300,ON_300TH_TICK)