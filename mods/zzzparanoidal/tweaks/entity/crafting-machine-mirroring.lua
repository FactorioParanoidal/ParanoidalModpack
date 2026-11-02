-- Factorio 2.1 (user decision D30 "A", 2026-11-03): in 2.0 every assembling machine and furnace could be flipped (F/V)
-- for the other fluid box layout; 2.1 flips only crafting machines with use_mirroring (default true only with
-- vector_to_place_result; engine probe test-runs/port21-mirror2-20261102: without it flip returns false). Keep 2.0:
-- every crafting machine with fluid boxes that does not set use_mirroring itself gets it. Pictures are not mirrored,
-- as in 2.0. The production mode twins of ic-more-qualities copy their machines later.
local count = 0
for _, kind in ipairs({ "assembling-machine", "furnace" }) do
	for _, machine in pairs(data.raw[kind] or {}) do
		if machine.use_mirroring == nil and type(machine.fluid_boxes) == "table" and next(machine.fluid_boxes) then
			machine.use_mirroring = true
			count = count + 1
		end
	end
end
log("zzzparanoidal: crafting machines flippable as in 2.0 (use_mirroring): " .. count)
