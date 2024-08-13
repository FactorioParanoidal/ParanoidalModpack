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
-- в пересечениях - 10 км\ч
local overlaps_rail_speed_limit = 10
-- станционные блоки - 15 км\ч
local station_block_speed_limit = 15
-- проходные светофоры - 20 км\ч
local rail_chain_signal_speed_limit = 20
-- участки пролетаем без ограничений, если нет ограничений вида  знаков скорости
local rail_signal_speed_limit = 10000
-- коээфициент от длины состава, на число клеток, которые мы смотрим вперёд для торможения, базовый коэффициент
local train_length_multiplier_for_braking = 0.5
--[[ каждые 1.625 км\ч добавляют одну десятую клетки для предпросмотра, так же для баланса коротких поездов или слишком разогнавшихся, чем быстрее едет поезд, тем быстрее
он должен успевать реагировать, а значит дальше смотреть по клеткам]]
local train_speed_in_kmh_step_limit = 0.0325
-- для простейших поездов вида LC или LF с одним локомотивом и одним вагоном полезного содержимого вводим ещё одну длину состава для просмотра
--[[стандартный размер стандартного поезда(подсвечивающегося на путях около станции 5 вагонов, длинной 7 клеток).
при таком значении параметра будет относительно реалистичной динамика движения поездов состава "только локомотив" или "локомотив", т.е. чем короче состав, тем дальше он должен смотреть
соответственно происходит балансировка динамики торможения и в принципе торможения перед препятствиями как и их более длинные аналоги.
]]
local train_length_in_tiles_limit = 35
function TrainSpeedDecreasingHandling:train_speed_limit_on_the_path_or_stand_by_handling(e)
    local registry = ForceTrainsInfoHolderRegistry.get_registry_instance()
    local force_holder = registry:next_force()
    local trains = force_holder:get_next_train_infos()
    _table.each(
        trains,
        function(train)
            self:process_train(train)
        end
    )
end

function TrainSpeedDecreasingHandling:process_train(train)
    if not train or not train.valid then
        return
    end
    if not train.has_path then
        return
    end
    local preserved_rail_segment_length = self:evaluate_train_looking_up_in_tomorrow_coefficient(train)
    local train_path = train.path
    --обрабатываем правильный поезд
    local start_path_index = self:get_start_path_index(train_path)
    local rails_max_index = self:evaluate_rail_path_interval_max_index(train_path, start_path_index,
        preserved_rail_segment_length)
    local min_limited_train_speed_value = self:evaluate_max_train_speed_on_interval(train_path,
        start_path_index, rails_max_index)
    local current_train_speed = train.speed
    if not min_limited_train_speed_value then return end
    local limited_train_speed = min_limited_train_speed_value.limit
    if not self:available_to_train_speed_decrease(limited_train_speed, current_train_speed) then
        return
    end
    local different_speed = self:evaluate_different_speed(min_limited_train_speed_value, start_path_index,
        current_train_speed)
    --different_speed/train.max_forward_speed
    self:decrease_train_speed_if_need(train, current_train_speed, different_speed)
    self:return_fuel_to_train_accordingly_train_speed(train)
end

function TrainSpeedDecreasingHandling:evaluate_train_looking_up_in_tomorrow_coefficient(train)
    local current_train_speed = train.speed
    local train_length_in_tiles = self:evaluate_train_length(train)
    local coefficient_from_train_speed = math.abs(current_train_speed) /
        self:evaluate_target_train_speed(train_speed_in_kmh_step_limit)
    local coefficient_from_train_length = train_length_in_tiles / train_length_in_tiles_limit
    return train_length_in_tiles * train_length_multiplier_for_braking + coefficient_from_train_speed +
        coefficient_from_train_length
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

function TrainSpeedDecreasingHandling:get_start_path_index(train_path)
    local start_path_index = train_path.current -- shift_by_train
    if start_path_index <= 0 then
        start_path_index = 1
    end
    return start_path_index
end

function TrainSpeedDecreasingHandling:evaluate_rail_path_interval_max_index(train_path, start_path_index,
                                                                            preserved_rail_segment_length)
    local rails_max_index = start_path_index + preserved_rail_segment_length
    if rails_max_index > train_path.size then
        rails_max_index = train_path.size
    end
    return rails_max_index
end

function TrainSpeedDecreasingHandling:evaluate_max_train_speed_on_interval(train_path,
                                                                           start_path_index,
                                                                           rails_interval_max_index)
    local all_limited_train_speed_signs =
        self:detect_max_train_speed_on_the_current_rail_segment(train_path, start_path_index, rails_interval_max_index)
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
    return min_limited_train_speed_value
end

function TrainSpeedDecreasingHandling:detect_max_train_speed_on_the_current_rail_segment(train_path, start_path_index,
                                                                                         rails_max_index)
    local result = {}
    for train_path_rail_index = start_path_index, rails_max_index do
        local rail = train_path.rails[train_path_rail_index]
        local rail_segment_entrance_entity_prototype = rail.prototype
        -- если есть пересечение на пути и это не является поворотом, считаем, что мы проезжаем пересение нескольких рельс
        if rail.get_rail_segment_overlaps() and rail_segment_entrance_entity_prototype.type ~= 'curved-rail' then
            table.insert(
                result,
                {
                    limit = self:evaluate_target_train_speed(overlaps_rail_speed_limit),
                    position = train_path_rail_index,
                    is_stop_or_signal = false
                }
            )
        else
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
        end
    end
    return result
end

function TrainSpeedDecreasingHandling:get_evaluated_rail_segment_entrance_entity(rail, current_train_speed)
    local result = rail.get_rail_segment_entity(defines.rail_direction.front, true)
    if not result then
        result = rail.get_rail_segment_entity(defines.rail_direction.back, true)
    end
    if not result then
        result = rail.get_rail_segment_entity(defines.rail_direction.front, false)
    end
    if not result then
        result = rail.get_rail_segment_entity(defines.rail_direction.back, false)
    end
    return result
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
    --обычный рельс не создаёт препятствий для движения, если не имеет пересечения с другими рельсами
    if rail_segment_entrance_entity_prototype.type == "rail" then
        return self:evaluate_target_train_speed(rail_signal_speed_limit)
    end
    return self:evaluate_target_train_speed(rail_signal_speed_limit)
end

function TrainSpeedDecreasingHandling:is_train_or_chain_signal(rail_segment_entrance_entity_prototype)
    return rail_segment_entrance_entity_prototype.type == "train-stop" or
        rail_segment_entrance_entity_prototype.type == "rail-chain-signal"
end

function TrainSpeedDecreasingHandling:available_to_train_speed_decrease(limited_train_speed, current_train_speed)
    return limited_train_speed - math.abs(current_train_speed) <= epsilon
end

function TrainSpeedDecreasingHandling:evaluate_different_speed(min_limited_train_speed_value, start_path_index,
                                                               current_train_speed)
    local distance_in_rails = (min_limited_train_speed_value.position - start_path_index)
    if distance_in_rails == 0 then
        distance_in_rails = 4
    end
    local accelerate_braking_multiplier =
        self:evaluate_acceleration_braking_coefficient(
            min_limited_train_speed_value.is_stop_or_signal,
            current_train_speed
        )
    --=
    return accelerate_braking_multiplier * (min_limited_train_speed_value.limit - math.abs(current_train_speed)) /
        distance_in_rails
end

function TrainSpeedDecreasingHandling:decrease_train_speed_if_need(train, current_train_speed, different_speed)
    if current_train_speed > epsilon and current_train_speed + different_speed >= epsilon then
        train.speed = current_train_speed + different_speed
    elseif current_train_speed < epsilon and current_train_speed - different_speed <= epsilon then
        train.speed = current_train_speed - different_speed
    end
end

function TrainSpeedDecreasingHandling:evaluate_target_train_speed(target_speed_limit)
    return target_speed_limit / train_speed_multiplier_to_kmh
end

function TrainSpeedDecreasingHandling:evaluate_acceleration_braking_coefficient(is_arriving_stop_or_signal,
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

function TrainSpeedDecreasingHandling:return_fuel_to_train_accordingly_train_speed(train)
    local current_train_speed = train.speed
    local locomotives = train.locomotives
    local movers = self:detect_current_locomotives_in_movers_direction(locomotives, current_train_speed)
    local max_train_speed_in_movers_direction = self:detect_max_train_speed_in_movers_direction(train)
    local abs_current_train_speed = math.abs(current_train_speed)
    _table.each(movers, function(mover)
        self:handle_train_mover(abs_current_train_speed, mover, max_train_speed_in_movers_direction)
    end)
end

function TrainSpeedDecreasingHandling:detect_max_train_speed_in_movers_direction(train)
    local current_train_speed = train.speed
    if current_train_speed >= -epsilon then
        return train.max_forward_speed
    end
    return train.max_backward_speed
end

function TrainSpeedDecreasingHandling:detect_current_locomotives_in_movers_direction(locomotives, current_train_speed)
    if current_train_speed >= -epsilon and locomotives.front_movers then
        return locomotives.front_movers or {}
    end
    return locomotives.back_movers or P {}
end

function TrainSpeedDecreasingHandling:handle_train_mover(abs_current_train_speed, mover,
                                                         max_train_speed_in_movers_direction)
    local mover_burner = mover.burner
    if not mover_burner.currently_burning then return end
    local mover_prototype = mover.prototype
    local burner_effectivity = mover.prototype.burner_prototype.effectivity
    --
    --log('mover_prototype.max_energy_usage  ' .. tostring(mover_prototype.max_energy_usage))
    local fuel_max_remaining_value = mover_prototype.max_energy_usage / burner_effectivity
    local fuel_percent_remaining_accordingly_train_speed = (max_train_speed_in_movers_direction - abs_current_train_speed) /
        max_train_speed_in_movers_direction
    --[[ log('max_train_speed_in_movers_direction ' .. tostring(max_train_speed_in_movers_direction))
    log('abs_current_train_speed ' .. tostring(abs_current_train_speed))
    log('fuel_percent_remaining_accordingly_train_speed ' .. tostring(fuel_percent_remaining_accordingly_train_speed))
    log('fuel_max_remaining_value ' .. tostring(fuel_max_remaining_value))
    log('before mover_burner.remaining_burning_fuel ' .. tostring(mover_burner.remaining_burning_fuel))]]
    local adding_remaining_burner_fuel_value = fuel_percent_remaining_accordingly_train_speed * fuel_max_remaining_value
    mover_burner.remaining_burning_fuel = mover_burner.remaining_burning_fuel + adding_remaining_burner_fuel_value
    --[[log('adding_remaining_burner_fuel ' .. tostring(adding_remaining_burner_fuel_value))
    log('after mover_burner.remaining_burning_fuel ' .. tostring(mover_burner.remaining_burning_fuel))]]
end
