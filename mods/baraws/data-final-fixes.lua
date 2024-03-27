--need to add check if type is a number because.... I have no idea why. someone had a set of mods where result_count was a string apparently.
function checkResults(recipe)
	if recipe.result_count and type(recipe.result_count) == "number" and recipe.result_count > 1 then
		return true
	end

	if recipe.results then
		local resultCount = 0
		for _, v in pairs(recipe.results) do
			resultCount = resultCount + 1
			if v.amount and type(v.amount) == "number" and v.amount > 1 then
				return true
			end

			if v.probability and type(v.probability) == "number" and v.probability ~= 1 then
				return true
			end
		end
		if resultCount > 1 then
			return true
		end
	end

	return false
end

--unify all recipe settings.
-- 1: set always_show_made_in to <<baraws_all_made_in>> (will display which assembly machines can craft the recipe for all recipes)
-- 2: set allow_decomposition:
-- buildings and final products have it set to true
-- any intermediates from angels smelting, metallurgy, chemistry, bio, etc (the ones that go into FUBAR loops) are set to false
-- idea is to make any recipe you might be interested in (circuits, science, etc) be easily broken down into plates, wires, basic boards, etc.
-- liquids arent handled that well... petrochem is a FUBAR just by itself anyway.
-- 3: set show_amount_in_title to true (if more than 1, will always show ?x in title)
-- 4: set always_show_products to <<baraws_all_products>> (every recipe will have a products, even if its just the 1.)
-- note: if normal & expensive recipes are planned for, have to account for them as well (otherwise it wont work...)

for k, v in pairs(data.raw.recipe) do
	-- this takes care of most of the cases (either +ve or -ve)
	-- any of the edge cases (and pretty much all of petrochem) is taken care of individually
	local allowDecomposition = (v.category == "crafting")
		or (
						--no barreling; leave liquids alone!
v.category ~= "barreling-pump"
			-- no ore sorting of any kind. AB has WAY too many options here
			and v.category ~= "ore-sorting-t1"
			and v.category ~= "ore-sorting-t2"
			and v.category ~= "ore-sorting-t3"
			and v.category ~= "ore-sorting-t4"
			and v.category ~= "crystallizing"
			and v.category ~= "ore-sorting"
			and v.category ~= "ore-sorting-t1-5"
			and v.category ~= "ore-sorting-t3-5"
			and v.category ~= "filtering"
			-- no ore to plate production. its not exactly FUBAR, but best to keep things plates up.
			-- plus, most people would probably not care about plates down (leave it to your own planning)
			and v.category ~= "ore-processing"
			and v.category ~= "pellet-pressing"
			and v.category ~= "chemical-smelting"
			and v.category ~= "powder-mixing"
			and v.category ~= "blast-smelting"
			and v.category ~= "smelting"
			and v.category ~= "induction-smelting"
			and v.category ~= "induction-smelting-2"
			and v.category ~= "induction-smelting-3"
			and v.category ~= "strand-casting"
			and v.category ~= "strand-casting-2"
			and v.category ~= "casting"
			and v.category ~= "sintering"
			-- no petrochem at all unless set by exceptions. FUBAR is the least you can call it.
			and v.category ~= "chemistry"
			and v.category ~= "liquifying"
			and v.category ~= "petrochem-electrolyser"
			and v.category ~= "petrochem-air-filtering"
			and v.category ~= "steam-cracking"
			and v.category ~= "gas-refining"
			and v.category ~= "oil-processing"
			and v.category ~= "advanced-chemistry"
			-- most of the furnace recipes are part of smelting, with the rest being best left off anyway. few exceptions are set below.
			and v.category ~= "mixing-furnace"
			and v.category ~= "chemical-furnace"
			-- water processing. not really necessary overall
			and v.category ~= "thermal-bore"
			and v.category ~= "thermal-extractor"
			and v.category ~= "water-treatment"
			and v.category ~= "salination-plant"
			and v.category ~= "washing-plant"
			and v.category ~= "cooling"
			and v.category ~= "petrochem-boiler"
			-- angel bio... this is where raws come to die. TOO MANY LOOPS! Plus, anything that leads into here will cause untold havoc upon the raw results.
			-- once again, few exceptions.
			and v.category ~= "bio-processing"
			and v.category ~= "bio-processor"
			and v.category ~= "bio-processing-wood"
			and v.category ~= "angels-arboretum"
			and v.category ~= "angels-arboretum-temperate"
			and v.category ~= "angels-arboretum-swamp"
			and v.category ~= "angels-arboretum-desert"
			and v.category ~= "angels-tree"
			and v.category ~= "angels-tree-temperate"
			and v.category ~= "angels-tree-swamp"
			and v.category ~= "angels-tree-desert"
			and v.category ~= "seed-extractor"
			and v.category ~= "basic-farming"
			and v.category ~= "temperate-farming"
			and v.category ~= "swamp-farming"
			and v.category ~= "desert-farming"
			and v.category ~= "nutrient-extractor"
			and v.category ~= "bio-pressing"
			and v.category ~= "bio-refugium-fish"
			and v.category ~= "bio-refugium-puffer"
			and v.category ~= "bio-refugium-biter"
			and v.category ~= "bio-butchery"
			and v.category ~= "bio-hatchery"
			--deadlock (i like those mods, crating especially)
			and v.category ~= "crating"
			and v.category ~= "packing"
			and v.category ~= "stacking"
			--several edge cases we can handle in bulk:
			and string.find(k, "-sawing") == nil --wood production from tree cutting
			and string.find(k, "-converting") == nil -- metal roll to plate and roll to wire recipes. plate to wire direct recipes taken care of in exceptions
			and string.find(k, "-plate") == nil -- bob plate recipes (blocked in angel)
			--gems
			--	string.find(k, "ruby") == nil and
			--	string.find(k, "sapphire") == nil and
			--	string.find(k, "emerald") == nil and
			--	string.find(k, "amethyst") == nil and
			--	string.find(k, "topaz") == nil and
			--	string.find(k, "diamond") == nil and
			--nuclear (fun fact: without this the engine thinks all lead comes from used up fuel cells)
			and string.find(k, "reprocessing") == nil
			and string.find(k, "enrichment") == nil
		)

	--extra checks with general crafting included (have to watch out for recipes we dont want to touch)
	--allowDecomposition = allowDecomposition and
	-- basically, crystal creation (harmonic and all)
	--	string.find(k, "crystal") == nil

	if v.normal ~= nil then
		v.normal.show_amount_in_title = true
		v.normal.always_show_products = settings.startup["baraws-all-products"].value or checkResults(v.normal)
		v.normal.always_show_made_in = settings.startup["baraws-all-made-in"].value
		v.normal.allow_decomposition = allowDecomposition
	end
	if v.expensive ~= nil then
		v.expensive.show_amount_in_title = true
		v.expensive.always_show_products = settings.startup["baraws-all-products"].value or checkResults(v.expensive)
		v.expensive.always_show_made_in = settings.startup["baraws-all-made-in"].value
		v.expensive.allow_decomposition = allowDecomposition
	end
	v.show_amount_in_title = true
	v.always_show_products = settings.startup["baraws-all-products"].value or checkResults(v)
	v.always_show_made_in = settings.startup["baraws-all-made-in"].value
	v.allow_decomposition = allowDecomposition
end

specificRecipes = {
	--BLOCK:
	--seablock
	["sb-cellulose-foraging"] = false,

	-- boards (3 types, but we allow phenolic boards to break into wood + resin)
	["angels-glass-fiber-board"] = false,
	["wooden-board-paper"] = false,
	["wooden-board"] = false,

	--cables (direct from plates recipes)
	["copper-cable"] = false,
	["angels-wire-gold"] = false,
	["basic-tinned-copper-wire"] = false,

	-- steel T0 recipe
	["angels-plate-steel-pre-heating"] = false,

	-- science waste (sci cost tweaker)
	["sct-waste-processing-copper"] = false,
	["sct-waste-processing-mixed"] = false,

	-- catalyst/electrode/filters (which arent used up, just need cleaning)
	["catalyst-metal-carrier"] = false,
	["angels-electrode"] = false,
	["filter-frame"] = false,
	["milling-drum"] = false,

	-- plastic,resin,rubber (otherwise converted to liquid versions)
	["solid-plastic"] = false,
	["solid-resin"] = false,
	["solid-rubber"] = false,

	--angels bio not handled above
	["solid-alginic-acid"] = false,
	["celluose-fiber-algae"] = false,
	["blue-fiber-algae"] = false,
	["red-fiber-algae"] = false,
	["solid-wood-pulp"] = false,
	["paper-bleaching-1"] = false,
	["alien-spores"] = false,
	["biter-small-eggsperiment"] = false,
	["biter-medium-eggsperiment"] = false,
	["biter-big-eggsperiment"] = false,
	["hogger-hogging-1"] = false,
	["hogger-breeding-1"] = false,
	["hogger-hogging-2"] = false,
	["hogger-breeding-2"] = false,
	["hogger-hogging-3"] = false,
	["hogger-breeding-3"] = false,
	["hogger-hogging-4"] = false,
	["hogger-breeding-4"] = false,
	["hogger-hogging-5"] = false,
	["hogger-breeding-5"] = false,
	["alien-processed-meat"] = false,
	["solid-soil"] = false,
	["solid-soil-alternative"] = false,
	["solid-fertilizer"] = false,
	["solid-alienated-fertilizer"] = false,

	-- hidden recipes (bob only, etc)
	["bob-resin-wood"] = false,
	["tinned-copper-cable"] = false,
	["gilded-copper-cable"] = false,
	["solder"] = false,
	["fibreglass-board"] = false,
	["sodium-chlorate"] = false,
	["sodium-perchlorate"] = false,
	["brine-electrolysis"] = false,
	["rtg"] = false,
	["angelsore1-crushed-hand"] = false,
	["angelsore3-crushed-hand"] = false,
	["gas-separation"] = false,
	["oil-separation"] = false,
	["basic-platinated-copper-wire"] = false,
	["angels-silicon-wafer"] = false,
	["basic-silvered-copper-wire"] = false,
	["angels-casting-resin-mold"] = false,

	--ALLOW:

	--science parts which unfortunately are touched by the mass filters above
	["sct-t3-flash-fuel2"] = true,
	["sct-prod-baked-biopaste"] = true,
	["sct-prod-biosilicate"] = true,
	["sct-htech-thermalstore-heated"] = true,
	["sct-htech-thermalstore"] = true,
	["heat-shield-tile"] = true,

	--batteries (petrochem)... too close. best leave them as is
	--["battery"] = true,
	--["lithium-ion-battery"] = true,
	--["silver-zinc-battery"] = true,
	--["rtg"] = true,

	--polishing compound (chemistry)
	["polishing-compound"] = true,

	--silicon endproducts (chemistry)
	["silicon-carbide"] = true,
	["silicon-nitride"] = true,
}

for v, ad in pairs(specificRecipes) do
	if data.raw.recipe[v] then
		if data.raw.recipe[v].normal ~= nil then
			data.raw.recipe[v].normal.allow_decomposition = ad
		end
		if data.raw.recipe[v].expensive ~= nil then
			data.raw.recipe[v].expensive.allow_decomposition = ad
		end
		data.raw.recipe[v].allow_decomposition = ad
	end
end

--[[for k,v in pairs(data.raw.recipe) do
	if v.allow_decomposition then
		log(k)
	end
end]]
