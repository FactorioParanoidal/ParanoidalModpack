-- Memory unit variants, shared by the data stage and control.
--
-- The plain unit is a container; the logistic units are logistic containers, one prototype per logistic mode
-- (the mode cannot change at runtime). Logic of the logistic units after "Logistic Memory Units" by restjack
-- (MIT, https://github.com/restjack/logistic-memory-unit): the chest is the part the logistic network sees,
-- the counter sits behind it, and the update keeps the chest at a level that matches the mode.
--
-- comfortable_slots: stacks of the locked item kept in the 300-slot chest; the rest lives in the counter.
--   passive provider 90% - robots always find stock to take;
--   storage 10%          - robots always find room to put (deconstruction output, trash);
--   buffer 50%, requester 25% - the chest is topped up from the counter, so requests pull from the network
--                          only when the counter is empty; what inserters or robots bring beyond the level
--                          goes to the counter.
-- There is no active provider: with an endless supply it would push into storage forever.
--
-- tint: icons; paint: dome rings of the building, the bright paint of the vanilla logistic chest of the mode
-- (median of its saturated pixels, brightest channel = 1).

local M = {}

M.names = {
	"memory-unit",
	"logistic-memory-unit-passive-provider",
	"logistic-memory-unit-storage",
	"logistic-memory-unit-buffer",
	"logistic-memory-unit-requester",
}

M.variants = {
	["memory-unit"] = {comfortable_slots = 150},
	["logistic-memory-unit-passive-provider"] = {
		logistic_mode = "passive-provider",
		comfortable_slots = 270,
		chest = "passive-provider-chest",
		tint = {r = 1.00, g = 0.45, b = 0.45},
		paint = {r = 1.00, g = 0.41, b = 0.37},
		order = "a",
	},
	["logistic-memory-unit-storage"] = {
		logistic_mode = "storage",
		comfortable_slots = 30,
		chest = "storage-chest",
		tint = {r = 1.00, g = 0.85, b = 0.35},
		paint = {r = 1.00, g = 0.81, b = 0.34},
		order = "b",
	},
	["logistic-memory-unit-buffer"] = {
		logistic_mode = "buffer",
		comfortable_slots = 150,
		chest = "buffer-chest",
		tint = {r = 0.45, g = 1.00, b = 0.50},
		paint = {r = 0.46, g = 1.00, b = 0.57},
		order = "c",
	},
	["logistic-memory-unit-requester"] = {
		logistic_mode = "requester",
		comfortable_slots = 75,
		chest = "requester-chest",
		tint = {r = 0.45, g = 0.65, b = 1.00},
		paint = {r = 0.48, g = 0.84, b = 1.00},
		order = "d",
	},
}

-- Packed unit (item with tags) placing the given unit.
function M.packed_name(name)
	return name .. "-with-tags"
end

return M
