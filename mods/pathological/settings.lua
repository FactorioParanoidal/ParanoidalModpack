local function create_settings(name,default,type)
  data:extend{
    {
      type = type.."-setting",
      name = "pathological-"..name,
      setting_type = "startup",
      default_value = default,
      order="pathological-"..name
    },
  }
end

-- too bad i can't auto-populate this from data.raw...
create_settings("train_stop_penalty", 2000, "int")
create_settings("stopped_manually_controlled_train_penalty", 2000, "int")
create_settings("stopped_manually_controlled_train_without_passenger_penalty", 7000, "int")
create_settings("signal_reserved_by_circuit_network_penalty", 1000, "int")
create_settings("train_in_station_penalty", 500, "int")
create_settings("train_in_station_with_no_other_valid_stops_in_schedule", 1000, "int")
create_settings("train_arriving_to_station_penalty", 100, "int")
create_settings("train_arriving_to_signal_penalty", 100, "int")
create_settings("train_waiting_at_signal_penalty", 100, "int")
create_settings("train_waiting_at_signal_tick_multiplier_penalty", 0.1, "double")
create_settings("train_with_no_path_penalty", 1000, "int")
