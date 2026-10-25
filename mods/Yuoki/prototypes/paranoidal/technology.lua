-- Paranoidal fork: technology tree of Yuoki, grafted onto the build (user decision 2026-10-24; design and player path
-- in Yuoki/_notes/TECH-TREE.md). Every Yuoki recipe is disabled and unlocked here. Prerequisites listed below are
-- the design anchors; derive_prerequisites() then adds, until a fixpoint, the build or Yuoki technology that unlocks
-- each missing ingredient or crafting machine, and every unit gets the science packs of its prerequisites.
local P = require("prototypes.paranoidal.lib")

local R, G, B, PR, U, M, BIO = "automation-science-pack", "logistic-science-pack", "chemical-science-pack",
	"production-science-pack", "utility-science-pack", "military-science-pack", "angels-token-bio"

-- name, icon item, base packs, count, time, anchors, recipes
local tree = {
	-- mid game: decoupled mechanical-force power plant (solid and liquid fuel), then the efficient gas engine and the
	-- first MF consumers (MF chain, user 2026-10-25)
	{ "yuoki-mechanical-force", "y-seg", { R, G, B }, 150, 30,
		{ "electric-engine", "bob-steam-engine-3", "angels-oil-processing" }, {
		"yie_hard_metals", "yie_hard_metals_mf", "y-iron-case", "y-winding", "y-mftrans-shaft", "y-mftrans-shaft-ground",
		"y-mftrans-shaft-red", "y-mftrans-shaft-ground-red", "y-sfe", "y-ffe", "y-mf1a", "y-mf1a1", "y-mf1f", "y-seg",
		"y-seg-p", "y_bg-1", "y-notfall-generator-s2" } },
	{ "yuoki-mechanical-force-2", "y-meg-s", { R, G, B }, 200, 30,
		{ "yuoki-mechanical-force", "angels-gas-processing", "CW-air-filtering-3" }, {
		"ye_gasmotor", "y-meg-s", "y-electric-air-heater", "y-rmvpol", "y-waste-condense", "y-emotor-s", "y-mf1c" } },

	-- production era: entry into Yuoki
	{ "yuoki-materials", "y-res1", { R, G, B, PR }, 200, 30, { "angels-ore-refining", "uranium-processing" }, {
		"y-centrifuge-n4", "y-centrifuge-f7", "y_crusher2", "y_formpress2", "y-crush-unicomp-raw", "y-crush-fuel-raw",
		"y-smelt-crush-res1", "y-smelt-crush-res2", "y-unicomp-raw", "y-raw-fuelnium", "y-mixing-rich", "y-orange-stuff",
		"ye_fassembly1", "y_structure_element", "y_structure_vessel", "y-bluegear", "y-conductive-wire-1", "y-coal-dust" } },
	{ "yuoki-electronics", "y-chip-2", { R, G, B, PR }, 300, 30, { "yuoki-materials" }, {
		"y_chip_plate", "y_dotzetron", "y-chip-1", "y-chip-2", "y-conductive-coil-1", "y-heat-pipe", "y_structure_electric",
		"y-battery-single-use1", "y-battery-single-use2", "y-battery-single-use3", "y_gauge_analog", "y-basic-t1-mf",
		"y-basic-t2-mf", "ye_fassembly2" } },
	{ "yuoki-archaeology", "y-dirtwasher", { R, G, B, PR }, 300, 30, { "yuoki-electronics" }, {
		"y-dirtwasher", "y-underground-drill", "y-digfdirt", "y-digfdirt2", "y_drillhead", "y_drillhead_repair", "y_toolhead",
		"y_toolhead_repair", "y_maintance_workshop", "y-wash-dirt", "y-wash-special", "y-pressed_dry_mud",
		"y-release-cwater", "y-filtering-dust", "y-sulfuric-acid", "y-pure-iron", "y-pure-copper", "y-refined-iron",
		"y-refined-copper", "y_pure_iron_wtool", "y_pure_copper_wtool", "y-crush-blue_whead", "y-crush-green_whead",
		"yi_magnetron", "y_blocked_capa", "y_mud2solidfuel", "y-coaldust-mixing", "y-mixfuel-load" } },
	{ "yuoki-transmutation", "y-atomic-constructor", { R, G, B, PR }, 400, 30, { "yuoki-archaeology" }, {
		"y-atomic-constructor", "y-fuel-reactor", "y-press-richdust", "y-uc2liquid", "y-liquid2uc", "j-cw2uc-recipe",
		"y-ac-slag2uc", "y-ac-crystal2uc", "y-ac-toxic2uc", "y-ac-mud2uc", "y-lightoil2uc", "y-heavyoil2uc",
		"y-lubricant2uc", "y-petroleum", pattern = "^y%-ac%-.+2uc$" } },
	{ "yuoki-smelting", "y_smelter", { R, G, B, PR }, 300, 30, { "yuoki-archaeology" }, {
		"y_smelter", "y_charger", "y_block_cold", "y_block_heat", "y_hps_pureiron", "y_hps_purecopper", "y_hps_steel" } },
	{ "yuoki-crystallization", "y_crystalizer", { R, G, B, PR }, 400, 30, { "yuoki-archaeology", "bob-centrifuge-2" }, {
		"y_steinmehl", "y_mixer_emu", "y_emulsion", "y_hppump", "y_richemulsion", "y_trockner", "y_crystal_dust",
		"y_crystalizer", "y-crystal-seed", "y-crystal-seed-fragment", "y-crystal-seed-geode", "y-centrifuge-n4-seeded",
		"y-centrifuge-f7-seeded" } },
	{ "yuoki-chemistry", "y_catalyst_ft", { R, G, B, PR }, 300, 30, { "yuoki-transmutation" }, {
		"y_rawsyngas1", "y_rawsyngas2", "y_granulate_wood", "y_refinehydrogen", "y_catalyst_ft", "y_catalyst_bp",
		"y_regcatbp", "y_regcatft", "y_ft", "y_coal2liquid", "y_mixedfuel2rocketfuel" } },
	{ "yuoki-accumulators", "y-ups-flywheel-b", { R, G, B, PR }, 300, 30, { "yuoki-archaeology" }, {
		"y-ups-flywheel-b", "y_compensator_25" } },
	{ "yuoki-agronomy", "ye_farm", { R, G, B, PR, BIO }, 300, 30, { "yuoki-electronics", "angels-bio-farm-2" }, {
		"ye_farm", "ye-seed_a1", "ye-seed_a2", "ye-growcorn", "ye_seed_b", "ye_cornb", "ye_sugar", "ye_celluose",
		"ye_biomixed", "ye_biofuel", "ye_granulate_corn", "ye_granulate_vuger", "ye_granulate_trifitan", "ye_synwood",
		"ye-corn2fluid", "ye-cf2lubricant", "ye-corn-to-angels", "ye-corn-from-angels", "y-1stirling-engine" } },

	-- utility era: the alien part
	{ "yuoki-research-center", "yie_science_blue_gen", { R, G, B, PR, U }, 300, 45, { "yuoki-electronics", "utility-science-pack" }, {
		"ye_createbluesigns", "yie_science_blue_gen", "ye_science_blue" } },
	{ "yuoki-alien-technology", "y-quantrinum", { R, G, B, PR, U }, 500, 45, { "yuoki-transmutation", "yuoki-research-center" }, {
		"y-atomic-quantum-composer", "y-alien-infuser", "y-infused-uca2", "y-infused-mud", "y-quantrinum",
		"y_quantrinum_infusion", "y-crystal-cnd", "y_data_crystal", "ye_center", "y-quantrinum-charge" } },
	{ "yuoki-fabrication-3", "ye_fassembly_sp", { R, G, B, PR, U }, 300, 45, { "yuoki-alien-technology", "automation-5" }, {
		"ye_fassembly_sp" } },
	{ "yuoki-catalytic-centrifuging", "y-crystal-cnd", { R, G, B, PR, U }, 500, 45,
		{ "yuoki-crystallization", "yuoki-alien-technology", "bob-centrifuge-3" }, {
		"y-centrifuge-n4-catalytic", "y-centrifuge-f7-catalytic" } },
	{ "yuoki-accumulators-2", "y-accumulator-b-tx", { R, G, B, PR, U }, 500, 45, { "yuoki-accumulators", "yuoki-alien-technology" }, {
		"y-accumulator-m-t2", "y-accumulator-b-t2", "y-accumulator-b-tx", "y-accumulator-crystal-m" } },
	{ "yuoki-aeet", "y-substation-h", { R, G, B, PR, U }, 300, 45, { "yuoki-accumulators-2", "bob-electric-substation-4" }, {
		"y-substation-h" } },
	{ "yuoki-solar", "y_alien_solar2", { R, G, B, PR, U }, 400, 45, { "yuoki-alien-technology", "bob-solar-energy-3" }, {
		"y-stirling-solar-dish", "y_alien_solar", "y_alien_solar2" } },
	{ "yuoki-heavy-mf", "y-heg", { R, G, B, PR, U }, 400, 45,
		{ "yuoki-mechanical-force-2", "yuoki-research-center", "yuoki-archaeology" }, {
		"y-beg", "y-heg", "ye_overheater", "ye_makesteam", "ye_sturbine", "ye_steam2mf", "ye_steam3mf",
		"ye_tfmw_generator-s", "ye_emotor_m", "ye_motorm_mf", "ye_mfheatmotor_m", "ye_mf_mfheatmotor_m", "ye_wpump_m",
		"y_mpump_mf", "y_mpump_water" } },
	{ "yuoki-obninsk", "y-obninsk-reactor", { R, G, B, PR, U }, 600, 45,
		{ "yuoki-heavy-mf", "yuoki-alien-technology", "yuoki-smelting", "nuclear-power" }, {
		"y-obninsk-reactor", "y-obninsk-turbine", "y_moxmixer", "yi_graphite", "y_mox1mixed", "y_mox2mixed",
		"y_reactor_mf1", "y_reactor_mox1", "y_reactor_mox2", "y_mox1fuel", "y_mox2fuel", "y_mox2fuelsplited",
		"y_obninsk_mc" } },
	{ "yuoki-genetics", "ye_dnasplicer", { R, G, B, PR, U, BIO }, 400, 45, { "yuoki-agronomy", "yuoki-research-center" }, {
		"ye_dnasplicer", "ye_dna_animal0", "ye_dna_animal1", "ye_dna_animal2", "ye_dna_animal3", "ye_dna_animal4",
		"ye_dna_plant0", "ye_dna_plant1", "ye_dna_plant3", "ye_meatfarm", "ye_grow_animal_a", "ye_grow_animal2",
		"ye_grow_animal3", "ye_grow_animal4", "ye_canmachine", "ye_grow_plant1", "ye_grow_plant1_waste",
		"y-yellow-waste-purification", "yie_bloodfrommeat", "ye_cooking_meat", "yie_pureiron", "ye_neutralisatzion",
		"ye_pool", "ye_pool_slurry", "ye-growcorn_ws", "ye_cornb_ws", "ye_slurry2ethanol",
		"ye_futtermittel_d" } },
	{ "yuoki-rheinsberg", "ye_rheinsberg", { R, G, B, PR, U }, 800, 60, { "yuoki-obninsk", "yuoki-genetics" }, {
		"ye_rheinsberg", "ye_rheins_LT", "ye_rheins_MT", "ye_rheins_HT", "ye_tfmw_turbine-s", "y-quantrinum-reactor",
		"y-mf1-q1", "y-mf1-q2", "y-mf1-q3" } },
	{ "yuoki-reputation", "y-fame-gen", { R, G, B, PR, U }, 400, 45, { "yuoki-alien-technology", "yuoki-accumulators" }, {
		"y-fame-gen", "y-fame", "y_fame_tech" } },
	{ "yuoki-trade", "y-stargate", { R, G, B, PR, U }, 600, 45, { "yuoki-reputation", "yuoki-accumulators-2" }, {
		"y-stargate", "ye_trade_node", "y-export-krakon", "y-export-chips", "y-export-fuel-cells", "y_exchange_b2",
		"y_exchange_b3", "y_exchange_b4", "yi_slayerfame", "y-fuel-cell-c", "ye_dna_import" } },
	{ "yuoki-transmutation-2", "y-unicomp-a2", { R, G, B, PR, U }, 600, 45, { "yuoki-trade" }, {
		"y-uc2crudeoil", pattern = "^y%-ac%-uc2" } },
	{ "yuoki-food-trade", "ye_icemaker", { R, G, B, PR, U, BIO }, 500, 45,
		{ "yuoki-genetics", "yuoki-trade", "yuoki-chemistry" }, {
		"ye_icemaker", "ye_ice_container_empty", "ye_ice_container_filled", "ye_package_empty", "ye_package_r_meat",
		"ye_package_c_meat", "ye_package_omtrinit", "ye_package_verotin", "ye_package_fish2",
		"ye_buechse_empty", "ye_buechse_gelb", "ye_buechse_white", "ye_buechse_gelb_export", "ye_buechse_weiss_export",
		"ye_trademeat1", "ye_trademeat2", "ye_export02", "ye_export03", "ye_export_fish2", "ye_fish2", "ye_dna_fish2",
		"ye-export-blood", "ye_futtermittel_c", "ye_grow_animal3fast", "y_exchange_b1" } },
	{ "yuoki-mastercraft", "y_mc_dirtwasher", { R, G, B, PR, U }, 600, 45, { "yuoki-genetics", "yuoki-archaeology" }, {
		"y_mc_dirtwasher", "y_mc_underground_drill" } },
	{ "yuoki-ultimates", "y_trade_ultimate", { R, G, B, PR, U }, 1000, 60, { "yuoki-trade", "yuoki-genetics" }, {
		"y_trade_ultimate", "ypfw_trader_sign", "ye_science_ultimate", "ye_green_ultimate", "y_greensign_ulti",
		"y_unlimited_wood" } },
	{ "yuoki-armor", "yi_armor_gray", { R, G, B, PR, U, M }, 500, 45, { "yuoki-trade", "power-armor-mk2" }, {
		"yi_armor_gray", "yi_armor_red" } },
	{ "yuoki-armor-2", "yi_walker_a", { R, G, B, PR, U, M }, 1000, 60, { "yuoki-armor", "bob-power-armor-3" }, {
		"yi_armor_gold", "yi_walker_a", "yi_walker_c" } },
	{ "yuoki-defense", "y_turret_gun2f12", { R, G, B, PR, U, M }, 400, 45,
		{ "yuoki-electronics", "bob-turrets-5", "bob-laser-turrets-5" }, {
		"y_turret_gun2f12", "y_turret_gun1f12", "y_turret_laser22f12", "y-wall-forcefield" } },
	{ "yuoki-defense-2", "y-weapon-ztt", { R, G, B, PR, U, M }, 600, 45,
		{ "yuoki-defense", "yuoki-archaeology", "yuoki-accumulators-2", "bob-plasma-turrets-2" }, {
		"y_ammo_case", "y_turret_plasma", "y_ammo_plasma", "y_turret_flame", "y_ammo_flame", "y-weapon-ztt" } },
	{ "yuoki-repair", "y-repair-krakon", { R, G, B, PR, U }, 300, 45, { "yuoki-electronics", "bob-repair-pack-5" }, {
		"y-repair-durotal", "y-repair-krakon" } },
	{ "yuoki-repair-2", "y_repair_quantrinum", { R, G, B, PR, U }, 400, 45, { "yuoki-repair", "yuoki-alien-technology" }, {
		"y_repair_quantrinum" } },
}

local owned = YUOKI_PARANOIDAL.owned_recipes
local assigned = {}
-- fluid hand-in recipes exist only with the startup setting yuoki-uc-from-fluids
local optional = { ["y-lightoil2uc"] = true, ["y-heavyoil2uc"] = true, ["y-lubricant2uc"] = true, ["y-petroleum"] = true }
local techs = {}

-- 256 px technology icons, neural upscale of the item icon (graphics/technology/<same file name>).
local tech_icon_files = {
	"accflywheel_icon.png", "aqe-icon.png", "substation-h-icon.png", "farm-icon.png", "quantrinum_icon.png",
	"dw.png", "mcb_icon.png", "neron_u3_32.png", "crystal_3.png", "icon_ftcat32.png", "crys_icon.png",
	"gun2_icon.png", "zzt-icon.png", "chip2-icon.png", "factory_var_3_icon.png", "icemaker_icon.png",
	"dna_splicer_icon.png", "heg-icon.png", "mc_washer_icon.png", "uni-com-pur.png", "seg-s_icon.png",
	"meg-s-icon.png", "obninsk-reactor-icon.png", "repair-krakon-icon.png", "repair_quantrinum.png",
	"thanks-icon.png", "science_gen_icon.png", "rheinsberg-icon.png", "smelter_icon.png",
	"yi_alien_solar2_icon.png", "laika-gate-icon.png", "cimota_64.png", "unicomp_icon.png",
	"trade_ultimate_icon.png",
}
local tech_icons = {}
for _, file in ipairs(tech_icon_files) do
	tech_icons[file] = "__Yuoki__/graphics/technology/" .. file
end

local function icon_of(item_name)
	for _, t in pairs({ "item", "repair-tool", "armor", "ammo", "capsule", "module", "tool" }) do
		local p = data.raw[t] and data.raw[t][item_name]
		if p then
			local file = type(p.icon) == "string" and p.icon:match("^__Yuoki__/.*/([^/]+)$")
			if file and tech_icons[file] then
				return { icon = tech_icons[file], icon_size = 256 }
			end
			if p.icons then
				return { icons = table.deepcopy(p.icons) }
			end
			return { icon = p.icon, icon_size = p.icon_size or 64 }
		end
	end
	error("Yuoki (Paranoidal): technology icon item not found: " .. item_name)
end

for index, t in ipairs(tree) do
	local name, icon_item, packs, count, time, anchors, recipes = t[1], t[2], t[3], t[4], t[5], t[6], t[7]
	local effects, seen = {}, {}
	local function add(recipe_name)
		if not seen[recipe_name] and data.raw.recipe[recipe_name] then
			seen[recipe_name] = true
			assigned[recipe_name] = (assigned[recipe_name] or 0) + 1
			effects[#effects + 1] = { type = "unlock-recipe", recipe = recipe_name }
		end
	end
	for _, recipe_name in ipairs(recipes) do
		if not data.raw.recipe[recipe_name] and not optional[recipe_name] then
			error("Yuoki (Paranoidal): technology " .. name .. " lists a missing recipe " .. recipe_name)
		end
		add(recipe_name)
	end
	if recipes.pattern then
		local matched = {}
		for recipe_name in pairs(owned) do
			if data.raw.recipe[recipe_name] and recipe_name:find(recipes.pattern) then
				matched[#matched + 1] = recipe_name
			end
		end
		table.sort(matched)
		for _, recipe_name in ipairs(matched) do
			add(recipe_name)
		end
	end
	for _, a in ipairs(anchors) do
		if not data.raw.technology[a] and not a:find("^yuoki%-") then
			error("Yuoki (Paranoidal): technology " .. name .. " anchors to a missing technology " .. a)
		end
	end
	local ingredients = {}
	for _, pack in ipairs(packs) do
		ingredients[#ingredients + 1] = { pack, 1 }
	end
	local tech = {
		type = "technology",
		name = name,
		effects = effects,
		prerequisites = table.deepcopy(anchors),
		unit = { count = count, time = time, ingredients = ingredients },
		order = string.format("y-%02d", index),
	}
	for k, v in pairs(icon_of(icon_item)) do
		tech[k] = v
	end
	techs[#techs + 1] = tech
end
data:extend(techs)

for name in pairs(owned) do
	local recipe = data.raw.recipe[name]
	if recipe and assigned[name] then
		recipe.enabled = false
	end
end
YUOKI_PARANOIDAL.assigned = assigned
YUOKI_PARANOIDAL.tech_names = {}
for _, t in ipairs(techs) do
	YUOKI_PARANOIDAL.tech_names[t.name] = true
end

require("prototypes.paranoidal.technology-derive")
