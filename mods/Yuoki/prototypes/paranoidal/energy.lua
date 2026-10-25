-- Paranoidal fork: energy.
-- 1. Perpetual-motion fixes (machine/generator chains that returned more energy than they took). Real balance of the
--    outputs is a later task (user, 2026-10-23); these are only the minimum to keep every chain below 100 %.
-- 2. The mechanical-force (MF) power plant of Yuoki Engines and the simple Yuoki steam machines are decoupled from
--    Yuoki materials and built from mid-game products of the build (user, 2026-10-24: generators/turbines/motors are
--    not near-end-game content). Heavy MF, Obninsk, Rheinsberg and TMFW stay in the late Yuoki branch.
-- 3. MF chain for the player (user, 2026-10-25): all MF engines burn fuel themselves and share the three modes of the
--    solid-fuel engine; MF is also consumed early (air scrubber, H-Metal forging); MF cannot be barrelled; the
--    Yuoki steam boilers and turbines (weaker than Bob's) are removed in removed-names.lua.
-- 4. MF is honest energy (user, 2026-10-26): no cold MF; electric motors make hot MF at ~96 %, every MF consumer needs
--    MF of at least 150 °C, the MF water pump is removed, big late consumers; Sol-Ray works day and night; the Yuoki
--    accumulators are three strong steps (compensator, AQE, crystal); the solar Stirling dish is a green-science panel.
local P = require("prototypes.paranoidal.lib")

-- generators above 100 % turn the Angels electric boiler into an energy source
for _, generator in pairs(data.raw.generator) do
	if generator.name:find("^y") and (generator.effectivity or 1) > 1 then
		generator.effectivity = 1
	end
end
P.entity("burner-generator", "y_bg-1").burner.effectivity = 0.5

P.result_amount("ye_mf_mfheatmotor_m", "y-mechanical-force", 6) -- 6 MW in, ~5 MW out
P.results("ye_steam2mf", { { type = "fluid", name = "y-mechanical-force", amount = 22, temperature = 400 },
	{ type = "fluid", name = "water", amount = 180 } }, "y-mechanical-force")
P.results("ye_steam3mf", { { type = "fluid", name = "y-mechanical-force", amount = 60, temperature = 400 },
	{ type = "fluid", name = "steam", amount = 75, temperature = 265 } }, "y-mechanical-force")
for _, r in pairs(P.recipe("ye_makesteam").results) do
	if r.name == "steam" then
		r.amount = 280
	end
end
for name, amount in pairs({ ye_rheins_HT = 380, ye_rheins_MT = 770, ye_rheins_LT = 1590 }) do -- LT was 100.3 %
	for _, r in pairs(P.recipe(name).results) do
		if r.name == "steam" then
			r.amount = amount
		end
	end
end
-- solid-fuel engine: about 0.95 / 0.83 / 0.71 of the burned fuel instead of 1.43 / 1.19 / 1.07
P.result_amount("y-mf1a", "y-mechanical-force", 4)
P.result_amount("y-mf1a1", "y-mechanical-force", 3.5)
P.result_amount("y-mf1f", "y-mechanical-force", 3)

-- Research Center: JATMN's values instead of 208 MW / 440 pollution
local rc = P.entity("assembling-machine", "yie_science_blue_gen")
rc.energy_usage = "45MW"
rc.energy_source.emissions_per_minute = { pollution = 100 }

-- H-Metal for MF shafts, iron housings and engines is made in an ordinary assembler
P.set("yie_hard_metals", { category = "crafting" })
P.ingredients("yie_hard_metals", { { "steel-plate", 2 }, { "coal", 3 } })

local mid = {
	["y-sfe"] = { { "engine-unit", 4 }, { "y-iron-case", 2 }, { "steel-plate", 10 }, { "bob-steel-gear-wheel", 6 } },
	["y-ffe"] = { { "engine-unit", 4 }, { "y-iron-case", 2 }, { "steel-plate", 10 }, { "bob-steel-pipe", 6 },
		{ "advanced-circuit", 2 } },
	ye_gasmotor = { { "electric-engine-unit", 2 }, { "y-iron-case", 4 }, { "steel-plate", 6 }, { "advanced-circuit", 4 } },
	["y-seg"] = { { "electric-engine-unit", 2 }, { "y-iron-case", 2 }, { "steel-plate", 10 }, { "advanced-circuit", 4 },
		{ "copper-cable", 10 } },
	["y-meg-s"] = { { "electric-engine-unit", 4 }, { "y-iron-case", 4 }, { "steel-plate", 20 }, { "advanced-circuit", 8 },
		{ "bob-steel-bearing", 4 } },
	["y_bg-1"] = { { "engine-unit", 2 }, { "y-iron-case", 2 }, { "steel-plate", 10 }, { "electronic-circuit", 2 } },
	["y-notfall-generator-s2"] = { { "steel-plate", 10 }, { "bob-steel-gear-wheel", 4 }, { "copper-cable", 4 },
		{ "y-winding", 2 } },
	-- MF consumers of the mid game
	["y-electric-air-heater"] = { { "steel-plate", 10 }, { "y-iron-case", 2 }, { "electric-engine-unit", 1 },
		{ "advanced-circuit", 2 }, { "bob-steel-pipe", 4 } },
	["y-emotor-s"] = { { "electric-engine-unit", 2 }, { "y-iron-case", 2 }, { "y-winding", 2 }, { "copper-cable", 8 },
		{ "advanced-circuit", 1 } },
	-- solar Stirling dish: a green-science panel from what the player already has
	["y-stirling-solar-dish"] = { { "steel-plate", 5 }, { "iron-gear-wheel", 5 }, { "copper-cable", 10 },
		{ "electronic-circuit", 3 }, { "pipe", 4 } },
}
for name, ingredients in pairs(mid) do
	P.ingredients(name, ingredients)
end

-- Small Generator-P (primary output) had no recipe
local seg_p = table.deepcopy(P.recipe("y-seg"))
seg_p.name = "y-seg-p"
seg_p.results = { { type = "item", name = "y-seg-p", amount = 1 } }
seg_p.main_product = "y-seg-p"
data:extend({ seg_p })

-- Liquid- and gas-fuel engines: they took the fuel as a recipe ingredient while running on electricity (no fuel
-- pollution, 24-35 % of the fuel energy after zzzparanoidal raised the fuel values). Now the fuel is their energy source
-- (any fluid with a fuel value, pollution scaled by the fluid), fed through the centre of the north/south side, and
-- they craft the solid-fuel engine recipes: water + lubricant / water / dry -> 4 / 3.5 / 3 MF per craft of 3 MJ.
-- Fuel -> MF: solid 95/83/71 % (SFE, effectivity 0.85), liquid 90/78/67 % (0.8, twice the power), gas 95/83/71 %
-- (0.85, twice the power, cleaner). Their boxes are laid out here as pass-through pipes (inputs on the north/south
-- corners, MF output east/west): assembler-pipe-passthrough skips machines with input-output connections; its own
-- layout collided with the fuel connection (load error y-ffe, 2026-10-26).
local function fuel_engine(name, effectivity, pollution)
	local engine = P.entity("assembling-machine", name)
	local output, by_x = nil, {}
	for _, box in ipairs(engine.fluid_boxes) do
		if box.production_type == "output" then
			output = box
		else
			by_x[box.pipe_connections[1].position[1]] = box
		end
	end
	assert(output and by_x[0] and by_x[1] and by_x[-1], "Yuoki (Paranoidal): unexpected fluid boxes of " .. name)
	local function connections(a, b)
		return {
			{ flow_direction = "input-output", direction = a[3], position = { a[1], a[2] } },
			{ flow_direction = "input-output", direction = b[3], position = { b[1], b[2] } },
		}
	end
	local d = defines.direction
	output.pipe_connections = connections({ 1, 0, d.east }, { -1, 0, d.west })
	by_x[1].pipe_connections = connections({ 1, -1, d.north }, { 1, 1, d.south })
	by_x[-1].pipe_connections = connections({ -1, -1, d.north }, { -1, 1, d.south })
	by_x[1].base_level, by_x[-1].base_level = -1, -1
	engine.fluid_boxes = { output, by_x[1], by_x[-1] }
	engine.energy_source = {
		type = "fluid",
		burns_fluid = true,
		scale_fluid_usage = true,
		effectivity = effectivity,
		emissions_per_minute = { pollution = pollution },
		fluid_box = {
			volume = 200,
			production_type = "input",
			pipe_connections = {
				{ flow_direction = "input-output", direction = defines.direction.north, position = { 0, -1 } },
				{ flow_direction = "input-output", direction = defines.direction.south, position = { 0, 1 } },
			},
		},
		smoke = { { name = "smoke", deviation = { 0.65, -0.2 }, frequency = 1 } },
	}
	engine.crafting_categories = { "yrcat-mf1a" }
	engine.crafting_speed = 2
	engine.energy_usage = "6MW"
	engine.fast_replaceable_group = "yuoki-mf-engine"
end
fuel_engine("y-ffe", 0.8, 24)
fuel_engine("ye_gasmotor", 0.85, 12)
P.entity("assembling-machine", "y-sfe").fast_replaceable_group = "yuoki-mf-engine" -- was "assembling-machine"
for _, name in ipairs({ "y-mf2a", "y-mf2b", "y-mf2c", "y-mf2d", "y-mf2e" }) do
	P.recipe(name)
	data.raw.recipe[name] = nil
end
-- Yuoki fuels for these engines, on the scale of the build (Angels hydrogen 150 kJ / 0.1; corn oil like a bio oil)
for name, v in pairs({ y_hydrogen = { "150kJ", 0.1 }, ye_cornoil = { "150kJ", 0.5 } }) do
	local fluid = P.entity("fluid", name)
	fluid.fuel_value, fluid.emissions_multiplier = v[1], v[2]
end

-- MF is a pressurised working fluid: a barrel would keep the amount but not the temperature (no energy).
P.entity("fluid", "y-mechanical-force").auto_barrel = false

-- Early MF consumers.
-- Air scrubber ("Fatmice"): at -2500 pollution/min for 1.25 MW it was 20 times the build's best filter. Now about the
-- Clowns filter of the same stage (CW 3: -125/min, 1.2 MW and filters) without consumables, but it needs MF: one small
-- electric motor or a tenth of an engine drives one scrubber. The fly ash is condensed into burnable fuel blocks.
local scrubber = P.entity("assembling-machine", "y-electric-air-heater")
scrubber.energy_usage = "200kW"
scrubber.energy_source.emissions_per_minute = { pollution = -150 }
scrubber.fast_replaceable_group = nil
P.ingredients("y-rmvpol", { { "water", 60, "fluid" }, { "y-mechanical-force", 0.4, "fluid" } })
local mixed_fuel = P.entity("item", "y-mixed-fuel")
mixed_fuel.fuel_category, mixed_fuel.fuel_value = "chemical", "4MJ"
-- H-Metal forged with MF in an assembler: less steel and coal per H-Metal than the plain recipe.
local forged = table.deepcopy(P.recipe("yie_hard_metals"))
forged.name = "yie_hard_metals_mf"
forged.category = "crafting-with-fluid"
forged.ingredients = P.list({ { "steel-plate", 3 }, { "coal", 2 }, { "y-mechanical-force", 2, "fluid" } })
forged.results = { { type = "item", name = "yie_hard_metals", amount = 2 } }
forged.main_product = "yie_hard_metals"
forged.localised_name = { "recipe-name.yie_hard_metals_mf" }
forged.order = (forged.order or "c1") .. "-mf"
data:extend({ forged })

-- MF is honest energy (2026-10-26). 1 MF at 150 °C carries 840 kJ.
-- Electric motors make hot MF at ~96 %: small 350 kW -> 0.4 MF/s, medium 3.5 MW -> 4 MF/s (was 350 kW for 4 cold MF/s).
for _, name in ipairs({ "y-mf1c", "ye_motorm_mf" }) do
	for _, r in pairs(P.recipe(name).results) do
		if r.name == "y-mechanical-force" then
			r.temperature = 150
		end
	end
end
P.entity("assembling-machine", "ye_emotor_m").energy_usage = "3.5MW"
-- Neutralisation is a chemical wash, not an MF source (9 hot MF per craft would be energy from acid and substrate).
local neutral = P.recipe("ye_neutralisatzion")
for i = #neutral.results, 1, -1 do
	if neutral.results[i].name == "y-mechanical-force" then
		table.remove(neutral.results, i)
	end
end
neutral.main_product = "y-con_water"
-- The Rheinsberg needed two MF water pumps (removed): two medium electric motors instead.
local function replace_ingredient(recipe_name, old, new)
	for _, ing in pairs(P.recipe(recipe_name).ingredients) do
		if ing.name == old then
			ing.name = new
			return
		end
	end
	error("Yuoki (Paranoidal): " .. recipe_name .. " has no ingredient " .. old)
end
replace_ingredient("ye_rheinsberg", "ye_wpump_m", "ye_emotor_m")

-- Big late consumers: the Zeidon charger heats its blocks with MF, the crystalliser grows seeds with MF instead of
-- steam, the form press drives the mass Yuoki intermediates with MF.
P.upsert_ingredient("y_block_heat", { "y-mechanical-force", 20, "fluid" })
for _, name in ipairs({ "y-crystal-seed", "y-crystal-seed-fragment", "y-crystal-seed-geode" }) do
	replace_ingredient(name, "steam", "y-mechanical-force")
	P.upsert_ingredient(name, { "y-mechanical-force", 10, "fluid" })
end
for _, name in ipairs({ "y-raw-fuelnium", "y-unicomp-raw" }) do
	P.upsert_ingredient(name, { "y-mechanical-force", 2, "fluid" })
end

-- Accumulators: three steps above the build's accumulators of the same stage (Bob fast 3: 64 MJ / 15 MW,
-- Bio Industries: 300 MJ / 25 MW). The flywheel, MCD and BCD are removed.
for name, v in pairs({
	y_compensator_25 = { "50MJ", "8MW" },
	["y-accumulator-b-tx"] = { "200MJ", "20MW" },
	["y-accumulator-crystal-m"] = { "600MJ", "40MW" },
}) do
	local source = P.entity("accumulator", name).energy_source
	source.buffer_capacity, source.input_flow_limit, source.output_flow_limit = v[1], v[2], v[2]
end
P.upsert_ingredient("y_compensator_25", { "bob-fast-accumulator-2", 1 })
replace_ingredient("y-fame-gen", "y-ups-flywheel-b", "y_compensator_25")

-- Alien flux: Sol-Ray collectors and the solar Stirling dish give the same power day and night.
for name, power in pairs({ y_alien_solar = "1.5MW", y_alien_solar2 = "3MW", ["y-stirling-solar-dish"] = "30kW" }) do
	local panel = P.entity("solar-panel", name)
	panel.production = power
	panel.performance_at_day, panel.performance_at_night = 1, 1
end

-- Mixed fuel -> rocket fuel shows the product icon: a recipe icon of its own would replace the build's rocket fuel
-- icon through zzzparanoidal's recipe-item-icon-sync.
P.set("y_mixedfuel2rocketfuel", { icon = nil, icon_size = nil, icons = nil })

-- Efficiency modules in beacons lower the energy of a craft but not its MF/steam output: no consumption, speed
-- (it would be free once consumption is ignored) or productivity effect on any Yuoki recipe that makes MF or steam
-- (otherwise every MF chain exceeds 100 %).
for name, recipe in pairs(data.raw.recipe) do
	if not YUOKI_PARANOIDAL.foreign_recipes[name] then
		-- no cold MF: every consumer takes MF of at least 150 °C
		for _, ing in pairs(recipe.ingredients or {}) do
			if ing.type == "fluid" and ing.name == "y-mechanical-force" then
				ing.minimum_temperature = 150
			end
		end
		for _, r in pairs(recipe.results or {}) do
			if r.type == "fluid" and r.name == "y-mechanical-force" and not r.temperature then
				error("Yuoki (Paranoidal): cold MF result in " .. name)
			end
		end
		for _, r in pairs(recipe.results or {}) do
			if r.type == "fluid" and (r.name == "y-mechanical-force" or r.name == "steam") then
				recipe.allow_consumption = false
				recipe.allow_speed = false
				recipe.allow_productivity = false
				break
			end
		end
	end
end
