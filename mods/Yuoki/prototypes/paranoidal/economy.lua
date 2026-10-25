-- Paranoidal fork: economy holes found in the dump of 2026-10-26 (user, 2026-10-26: "make 1-3").
local P = require("prototypes.paranoidal.lib")

-- 1. Currencies and Yuoki intermediates are not fuel. Transmuted UC-A2 burned for 3 GJ in any burner: 100 iron ore ->
--    1 UC-A2 -> 3 GJ (30 MJ per ore). The split MOX fuel (10 x 600 MJ from one 7 GJ MOX cell) burned in any boiler,
--    furnace or vehicle; now it is reactor fuel like the other MOX cells.
local infused = P.entity("item", "y-infused-uca2")
infused.fuel_value, infused.fuel_category, infused.burnt_result = nil, nil, nil
P.entity("item", "y_mox2fuelsplited").fuel_category = "yfusion"

-- 2. Quantrinum is not bought for one meat package in 3 s (it bypassed the alien quantrinum chain): 20 packages, 30 s.
P.ingredients("ye_trademeat2", { { "ye_package_c_meat", 20 } })
P.set("ye_trademeat2", { energy_required = 30 })

-- 3. Techanic signs: their sinks needed 62 811 signs from by-products of 1-2 per craft. The mass intermediates now
--    yield 3, the big sinks cost about a quarter (YI armor: armor.lua).
for _, name in ipairs({ "y-chip-2", "y-basic-t2-mf", "yi_magnetron", "y-fuel-reactor", "y-mixfuel-load" }) do
	P.result_amount(name, "y_rwtechsign", 3)
end
for name, amount in pairs({
	y_obninsk_mc = 2500, y_mc_underground_drill = 1000, y_mc_dirtwasher = 600,
}) do
	P.upsert_ingredient(name, { "y_rwtechsign", amount })
end
-- The first animal DNA line took 8 automation packs at the utility stage: one Angels bio token instead.
local dna = P.recipe("ye_dna_animal1")
for _, ing in pairs(dna.ingredients) do
	if ing.name == "automation-science-pack" then
		ing.name, ing.amount = "angels-token-bio", 1
	end
end
-- Nature signs start with agronomy: no sign from condensing fly ash of the mid-game air scrubber.
P.results("y-waste-condense", { { "y-mixed-fuel", 2 } }, "y-mixed-fuel")
