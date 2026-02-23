Interface = {}
local this = {}

remote.add_interface("orbital_ion_cannon",
	{
		on_ion_cannon_targeted = function() return this.getIonCannonTargetedEventID() end,
		on_ion_cannon_fired = function() return this.getIonCannonFiredEventID() end,
		target_ion_cannon = function(force, position, surface, player) return IonCannon.target(force, position, surface, player) end -- Player is optional
	}
)

function Interface.generateEvents()
	this.getIonCannonTargetedEventID()
	this.getIonCannonFiredEventID()
end

function this.getIonCannonTargetedEventID()
	if not _G.when_ion_cannon_targeted then
		_G.when_ion_cannon_targeted = script.generate_event_name()
	end
	return _G.when_ion_cannon_targeted
end

function this.getIonCannonFiredEventID()
	if not _G.when_ion_cannon_fired then
		_G.when_ion_cannon_fired = script.generate_event_name()
	end
	return when_ion_cannon_fired
end


