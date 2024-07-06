function on_train_changed_state(e)
    --[[ при прибытии на сигнал - пересчитываем путь явно или при ожидании на сигнале
    (может быть быстрее найдётся путь другой, чем мы будем стоять и ожидать, пока проедем текущим)]]
    if e.train.state == defines.train_state.arrive_signal or e.train.state == defines.train_state.wait_signal then
        e.train.recalculate_path(true)
    end
end
