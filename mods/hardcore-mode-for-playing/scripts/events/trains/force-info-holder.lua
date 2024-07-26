ForceTrainInfoHolder = Class()
-- за тик обрабатываем до 10 поездов
function ForceTrainInfoHolder:init()
    -- log("ForceTrainInfoHolder:init")
    self.trains = {}
    self.train_schedules = {}
    self.train_links = {}
    self.count = 0
    self.current_index = 1
    self.force_train_handling_step = 10
    self.max_train_speed_list = {}
end

function ForceTrainInfoHolder:insert_train_info_in_holder(train)
    local train_id = train.id
    self.trains[train_id] = train
    self.train_indexes = _table.keys(self.trains)
    --[[log("ForceTrainInfoHolder:insert_train_info_in_holder")
    log("self.trains " .. Utils.dump_to_console(self.trains))
    log("self.train_indexes " .. Utils.dump_to_console(self.train_indexes))]]
end

function ForceTrainInfoHolder:get_train_info_from_holder_by_train_index(train_id)
    return self.trains[train_id]
end

function ForceTrainInfoHolder:remove_train_info_from_holder_by_train_index(train_id)
    local exists = self.trains[train_id]
    if not exists then return false end
    self.trains[train_id] = nil
    self.train_indexes = _table.keys(self.trains)
    return true
    --[[   log("ForceTrainInfoHolder:remove_train_info_from_holder_by_train_index")
    log("self.trains " .. Utils.dump_to_console(self.trains))
    log("self.train_indexes " .. Utils.dump_to_console(self.train_indexes))]]
end

function ForceTrainInfoHolder:add_schedule_for_train(train_id, train_schedule)
    --log("ForceTrainInfoHolder:add_schedule_for_train train_id " .. train_id)
    self.train_schedules[train_id] = train_schedule
end

function ForceTrainInfoHolder:get_schedule_for_train(train_id, train_schedule)
    --log("ForceTrainInfoHolder:get_schedule_for_train train_id " .. train_id)
    local old_train_id_with_schedule = self.train_links[train_id]
    -- если расписания назначено не было, значит не назначаем ничего в ответ.
    if not old_train_id_with_schedule then
        return nil
    end
    local result = _table.deep_copy(self.train_schedules[old_train_id_with_schedule])
    self.train_links[train_id] = nil
    self.train_schedules[old_train_id_with_schedule] = nil
    return result
end

function ForceTrainInfoHolder:add_link_train(old_train_id, new_train_id)
    -- log("ForceTrainInfoHolder:add_link_train set link " .. old_train_id .. " to " .. new_train_id)
    self.train_links[new_train_id] = old_train_id
end

function ForceTrainInfoHolder:get_next_train_infos()
    local result = {}
    local end_index = self.current_index + self.force_train_handling_step
    if end_index >= self.count then
        end_index = self.count
    end
    --[[log("ForceTrainInfoHolder:get_next_train_infos")
    log("self.trains " .. Utils.dump_to_console(self.trains))
    log("self.train_indexes " .. Utils.dump_to_console(self.train_indexes))]]
    for index = self.current_index, end_index do
        table.insert(result, self:get_train_info_from_holder_by_train_index(self.train_indexes[index]))
    end
    if end_index == 0 or end_index == self.count then
        end_index = 1
    end
    self.current_index = end_index
    return result
end

function ForceTrainInfoHolder:set_last_max_train_speed(train_id, max_train_speed)
    self.max_train_speed_list[train_id] = max_train_speed
end

function ForceTrainInfoHolder:get_last_max_train_speed(train_id)
    return self.max_train_speed_list[train_id] or 10000
end
