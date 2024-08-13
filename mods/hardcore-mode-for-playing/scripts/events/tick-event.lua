require("trains.train-speed-decreasing-handling")
local train_speed_decreasing_handling = TrainSpeedDecreasingHandling()
function on_tick_event(e)
    disable_on_start_if_need()
    train_speed_decreasing_handling:train_speed_limit_on_the_path_or_stand_by_handling(e)
end
