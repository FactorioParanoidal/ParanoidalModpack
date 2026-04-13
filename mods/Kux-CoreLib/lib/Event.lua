require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

--- @class KuxCoreLib.Event The event class represents an event. : KuxCoreLib.Class
--- @field asGlobal fun():KuxCoreLib.Event
--- @field name string Gets the name of the event. [ReadOnly]
--- @field id integer Gets the ID of the event. [ReadOnly]
local Event = {
	__class  = "Event",
	__guid   = "2f60d204-a0b5-4dd1-ae43-63bc65cfbe14",
	__origin = "Kux-CoreLib/lib/Event.lua",
}
if not KuxCoreLib.__classUtils.ctor(Event) then return self end

---Create a new event.
---@param eventIdentifier any
---@return KuxCoreLib.Event
function Event:new(eventIdentifier)
	self = {name=nil, id=nil}
	setmetatable(self, Event)
	self.__index = Event
	--self.name, self.id = eventPair(eventIdentifier)
	return self
end

function Event:raise()
	print("raise "..self.id)
end

---------------------------------------------------------------------------------------------------
return Event