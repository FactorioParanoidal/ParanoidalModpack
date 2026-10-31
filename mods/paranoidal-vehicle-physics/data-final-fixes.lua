-- Cars other than tanks lose their stop trigger: the drift physics replaces the engine's stop effect (vehicle_physics).
for name, car in pairs(data.raw.car) do
	if not name:find("tank", 1, true) then
		car.stop_trigger = nil
	end
end
