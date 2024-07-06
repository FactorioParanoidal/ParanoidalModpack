TrainSpeedDecreasingHandling = Class()
local epsilon = 0.00001
-- предельные скорости прохождения участков пути от точки А до точки Б.
-- convert from speed in kph to speed in meters per tick
-- frame = 60 ticks/s
-- 60 m/s = 1 m/frame = 216 km/h
-- from TrainSpeedLimit mod
local train_speed_multiplier_to_kmh = 216.6
-- в кривых - 7 км\ч
local curve_rail_speed_limit = 7
-- станционные блоки - 15 км\ч
local station_block_speed_limit = 15
-- проходные светофоры - 10 км\ч
local rail_chain_signal_speed_limit = 20
-- участки пролетаем без ограничений, если нет ограничений вида  знаков скорости
local rail_signal_speed_limit = 10000
-- коээфициент от длины состава, на число клеток, которые мы смотрим вперёд для торможения, базовый коэффициент
local train_length_multiplier_for_braking = 0.5
--[[ каждые 1.625 км\ч добавляют одну десятую клетки для предпросмотра, так же для баланса коротких поездов или слишком разогнавшихся, чем быстрее едет поезд, тем быстрее
он должен успевать реагировать, а значит дальше смотреть по клеткам]]
local train_speed_in_kmh_step_limit = 0.1625
-- для простейших поездов вида LC или LF с одним локомотивом и одним вагоном полезного содержимого вводим ещё одну длину состава для просмотра
--[[стандартный размер стандартного поезда(подсвечивающегося на путях около станции 5 вагонов, длинной 7 клеток).
при таком значении параметра будет относительно реалистичной динамика движения поездов состава "только локомотив" или "локомотив", т.е. чем короче состав, тем дальше он должен смотреть
соответственно происходит балансировка динамики торможения и в принципе торможения перед препятствиями как и их более длинные аналоги.
]]
local train_length_in_tiles_limit = 35
function TrainSpeedDecreasingHandling:train_speed_limit_on_the_path_or_stand_by_handling(e)
    local registry = ForceTrainsInfoHolderRegistry.get_registry_instance()
    force_holder = registry:next_force()
    local trains = force_holder:get_next_train_infos()
    _table.each(
        trains,
        function(train)
            self:process_train(train, force_holder)
        end
    )
end

function TrainSpeedDecreasingHandling:process_train(train, force_holder)
    if not train or not train.valid then
        return
    end
    if not train.has_path then
        return
    end
    --обрабатываем правильный поезд
    local train_path = train.path
    local current_train_speed = train.speed

    local train_length_in_tiles = self:evaluate_train_length(train)
    local coefficient_from_train_speed = math.abs(current_train_speed) /
        self:evaluate_target_train_speed(train_speed_in_kmh_step_limit)
    local coefficient_from_train_length = train_length_in_tiles / train_length_in_tiles_limit

    local preserved_rail_segment_length =
    -- длину состава не учитываем вообще(как слагаемое ), только скорость и длину состава как балансирующий множитель к базовой длине состава (5 вагонов)
    --[[ train_length_in_tiles * train_length_multiplier_for_braking +]] coefficient_from_train_speed +
        coefficient_from_train_length
    --  local shift_by_train = math.floor((preserved_rail_segment_length / 10) + 0.5)
    local start_path_index = train_path.current -- shift_by_train
    local rails_max_index = start_path_index + preserved_rail_segment_length
    if rails_max_index > train_path.size then
        rails_max_index = train_path.size
    end
    if start_path_index <= 0 then
        start_path_index = 1
    end
    --[[ log("preserved_rail_segment_length " .. preserved_rail_segment_length)
    log("rails_max_index " .. rails_max_index)
    log("start_path_index " .. start_path_index)
    log("train_path.current " .. train_path.current)
    log("train_path.size " .. train_path.size)]]

    local all_limited_train_speed_signs =
        self:detect_max_train_speed_on_the_current_rail_segment(train, start_path_index, rails_max_index)
    local min_limited_train_speed_value = nil
    _table.each(
        all_limited_train_speed_signs,
        function(limited_train_speed_sign)
            if not min_limited_train_speed_value then
                min_limited_train_speed_value = limited_train_speed_sign
                return
            end
            if min_limited_train_speed_value.limit - limited_train_speed_sign.limit > epsilon then
                min_limited_train_speed_value = limited_train_speed_sign
            end
        end
    )
    if not min_limited_train_speed_value then return end
    local limited_train_speed = min_limited_train_speed_value.limit
    if limited_train_speed - math.abs(current_train_speed) > epsilon then
        return
    end
    local distance_in_rails = (min_limited_train_speed_value.position - start_path_index)
    if distance_in_rails == 0 then
        distance_in_rails = 4
    end
    local accelerate_braking_multiplier =
        self:evaluate_acceleration_braking_coefficient(
            min_limited_train_speed_value.is_stop_or_signal,
            current_train_speed
        )
    local different_speed =
        accelerate_braking_multiplier * (limited_train_speed - math.abs(current_train_speed)) / distance_in_rails
    if current_train_speed > epsilon and current_train_speed + different_speed >= epsilon then
        train.speed = current_train_speed + different_speed
    elseif current_train_speed < epsilon and current_train_speed - different_speed <= epsilon then
        train.speed = current_train_speed - different_speed
    end
end

function TrainSpeedDecreasingHandling:evaluate_target_train_speed(target_speed_limit)
    return target_speed_limit / train_speed_multiplier_to_kmh
end

function TrainSpeedDecreasingHandling:detect_max_speed_from_connected_entity_prototype(
    rail_segment_entrance_entity_prototype)
    -- log("found " .. rail_segment_entrance_entity_prototype.type)
    -- если есть станция - проходим медленнее
    if rail_segment_entrance_entity_prototype.type == "train-stop" then
        --log("station_block_speed_limit " .. station_block_speed_limit)
        return self:evaluate_target_train_speed(station_block_speed_limit)
    end
    -- если есть проходной сигнал на пути - проходим медленнее, и группу таких сигналов тоже.
    if rail_segment_entrance_entity_prototype.type == "rail-chain-signal" then
        --log("rail_chain_signal_speed_limit " .. rail_chain_signal_speed_limit)
        return self:evaluate_target_train_speed(rail_chain_signal_speed_limit)
    end
    -- вход в сегмент считаем знаком "Конец всех ограничений" и движемся максимально с той скоростью которую позволяет знак ограничения скорости
    if rail_segment_entrance_entity_prototype.type == "rail-signal" then
        return self:evaluate_target_train_speed(rail_signal_speed_limit)
    end
    -- в кривых движемся сильно медленнее
    if rail_segment_entrance_entity_prototype.type == "curved-rail" then
        return self:evaluate_target_train_speed(curve_rail_speed_limit)
    end
    --обычный рельс не создаёт препятствий для движения
    if rail_segment_entrance_entity_prototype.type == "rail" then
        return self:evaluate_target_train_speed(rail_signal_speed_limit)
    end
    return self:evaluate_target_train_speed(rail_signal_speed_limit)
end

function TrainSpeedDecreasingHandling:detect_max_train_speed_on_the_current_rail_segment(train, start_path_index,
                                                                                         rails_max_index)
    local train_path = train.path
    local result = {}
    for train_path_rail_index = start_path_index, rails_max_index do
        local rail = train_path.rails[train_path_rail_index]
        local rail_segment_entrance_entity_prototype = rail.prototype
        -- log("rail_segment_entrance_entity_prototype.type " .. rail_segment_entrance_entity_prototype.type)
        local rail_segment_entrance_entity = self:get_evaluated_rail_segment_entrance_entity(rail)
        if rail_segment_entrance_entity then
            rail_segment_entrance_entity_prototype = rail_segment_entrance_entity.prototype
        end
        table.insert(
            result,
            {
                limit = self:detect_max_speed_from_connected_entity_prototype(rail_segment_entrance_entity_prototype),
                position = train_path_rail_index,
                is_stop_or_signal = self:is_train_or_chain_signal(rail_segment_entrance_entity_prototype)
            }
        )
        --
    end
    return result
end

function TrainSpeedDecreasingHandling:get_evaluated_rail_segment_entrance_entity(rail, current_train_speed)
    --  if current_train_speed > epsilon then
    local result = rail.get_rail_segment_entity(defines.rail_direction.front, true)
    if not result then
        result = rail.get_rail_segment_entity(defines.rail_direction.back, true)
    end
    --    end
    if not result then
        result = rail.get_rail_segment_entity(defines.rail_direction.front, false)
    end
    if not result then
        result = rail.get_rail_segment_entity(defines.rail_direction.back, false)
    end
    return result
end

function TrainSpeedDecreasingHandling:is_train_or_chain_signal(rail_segment_entrance_entity_prototype)
    return rail_segment_entrance_entity_prototype.type == "train-stop" or
        rail_segment_entrance_entity_prototype.type == "rail-chain-signal"
end

function TrainSpeedDecreasingHandling:evaluate_train_length(train)
    local result = 0
    _table.each(
        train.carriages,
        function(carriage)
            local carriage_prototype = carriage.prototype
            result = result + carriage_prototype.joint_distance + carriage_prototype.connection_distance
        end
    )
    return result
end

function TrainSpeedDecreasingHandling:evaluate_acceleration_braking_coefficient(
    is_arriving_stop_or_signal,
    current_train_speed)
    local factor = 2
    local abs_speed = math.abs(current_train_speed)
    if is_arriving_stop_or_signal then
        factor = 0.75
    end
    factor = factor * 10.0 -- line added to decellerate much quicker

    if abs_speed > 0.6 then
        factor = 0.08 * factor
    elseif abs_speed > 0.3 then
        factor = 0.075 * factor
    else
        factor = 2 * factor
    end
    factor = 0.3 * factor
    return factor
end
