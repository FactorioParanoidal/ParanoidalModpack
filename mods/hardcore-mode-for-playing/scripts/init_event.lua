-- корабль пуст, всё что могло сгорело при посадке, либо в плотных слоях атмосферы, если она на планете имеется(конечно имеется).
local function on_init_event()
	if remote.interfaces["freeplay"] then
		local created_items = {}
		local ship_items = {}
		local debris_items = {}
		remote.call("freeplay", "set_created_items", created_items)
		remote.call("freeplay", "set_ship_items", ship_items)
		remote.call("freeplay", "set_debris_items", debris_items)
		remote.call("freeplay", "set_ship_parts", {})
	end
end
script.on_init(on_init_event)
