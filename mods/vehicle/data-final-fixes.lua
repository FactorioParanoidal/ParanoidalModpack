for a,b in pairs(data.raw.car) do
	if not a:find("tank") then
		b.stop_trigger = nil
	end
end