function on_train_changed_state(e)
    --[[ при прибытии на сигнал - пересчитываем путь явно или при ожидании на сигнале
    (может быть быстрее найдётся путь другой, чем мы будем стоять и ожидать, пока проедем текущим)]]
    if e.train.state == defines.train_state.arrive_signal or e.train.state == defines.train_state.wait_signal then
        e.train.recalculate_path(true)
    end
end

function on_train_created(e)
    local force_trains_info_holder_registry = ForceTrainsInfoHolderRegistry.get_registry_instance()
    local new_train = e.train
    local surface_index = new_train.carriages[1].surface_index
    local surface_holder = force_trains_info_holder_registry:get_by_index(surface_index)
    if e.old_train_id_1 then
        surface_holder:remove_train_info_from_holder_by_train_index(e.old_train_id_1)
    end
    if e.old_train_id_2 then
        surface_holder:remove_train_info_from_holder_by_train_index(e.old_train_id_2)
    end
    surface_holder:insert_train_info_in_holder(new_train)
end
