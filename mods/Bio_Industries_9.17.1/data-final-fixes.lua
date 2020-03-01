


-- 5dim Stack changes
if settings.startup["5d-change-stack"] and settings.startup["5d-change-stack"].value then
   if data.raw.item["wood"] then
      data.raw.item["wood"].stack_size = math.max(210, data.raw.item['raw-wood'].stack_size)
   end
end

---- Game Tweaks ---- Recipes
if BI.Settings.BI_Game_Tweaks_Recipe then
	--- Concrete Recipe Tweak
	bobmods.lib.recipe.remove_ingredient ("concrete", "iron-ore")
	bobmods.lib.recipe.add_new_ingredient ("concrete", {type="item", name="iron-stick", amount=2})
	--- Stone Wall
	bobmods.lib.recipe.add_new_ingredient ("stone-wall", {type="item", name="iron-stick", amount=1})

	-- Make Steel Axe use Iron Axe as an upgrade
	bobmods.lib.recipe.remove_ingredient ("steel-axe", "iron-stick")
	bobmods.lib.recipe.add_new_ingredient ("steel-axe", {type="item", name="iron-axe", amount=1})
	
	--- Rail (Remove Stone and Add Crushed Stone)
	if data.raw.item["stone-crushed"] then
		bobmods.lib.recipe.remove_ingredient ("rail", "stone")
		bobmods.lib.recipe.add_new_ingredient ("rail", {type="item", name="stone-crushed", amount=6})
		bobmods.lib.recipe.remove_ingredient ("bi_recipe_rail_wood", "stone")
		bobmods.lib.recipe.add_new_ingredient ("bi_recipe_rail_wood", {type="item", name="stone-crushed", amount=6})
	end
	
	-- vanilla rail recipe update
	bobmods.lib.recipe.add_new_ingredient("rail", {type="item", name="concrete", amount=6})
	
end

---- Game Tweaks ---- Tree
if BI.Settings.BI_Game_Tweaks_Tree then
	
		--- Trees Give Random 1 - 6 Raw Wood.
	for _, tree in pairs(data.raw["tree"]) do
   --CHECK FOR SINGLE RESULTS
		if tree.minable and tree.minable.result then
		  --CHECK FOR VANILLA TREES RAW WOOD x 4
		  if tree.minable.result == "wood" and tree.minable.count == 4 then
			 tree.minable = {mining_particle = "wooden-particle", mining_time = 1.5, results = {{type = "item", name = "wood", amount_min = 1, amount_max = 6}}}
		  end
		else
		  --CHECK FOR RESULTS TABLE
		  if tree.minable and tree.minable.results then
			 for k, results in pairs(tree.minable.results) do
				--CHECK FOR RESULT RAW-WOOD x 4
				if results.name == "wood" and results.amount == 4 then
				   results.amount = nil
				   results.amount_min = 1
				   results.amount_max = 6
				end
			 end      
		  end
		end
	end
end	

---- Game Tweaks ---- Player
if BI.Settings.BI_Game_Tweaks_Player then	
	
	--- Loot Picup	
	if data.raw.player.player.loot_pickup_distance < 5 then
		data.raw.player.player.loot_pickup_distance = 5 -- default 2
	end	

	--- Run Speed
	if data.raw.player.player.running_speed < 0.15 then
		data.raw.player.player.running_speed = 0.25 -- default 0.15
	end	

	if data.raw.player.player.build_distance < 20 then -- Vanilla 6
		data.raw.player.player.build_distance = 20
	end
	if data.raw.player.player.drop_item_distance < 20 then -- Vanilla 6
		data.raw.player.player.drop_item_distance = 20
	end
	if data.raw.player.player.reach_distance < 20 then -- Vanilla 6
		data.raw.player.player.reach_distance = 20
	end
	if data.raw.player.player.item_pickup_distance < 4 then -- Vanilla 1
		data.raw.player.player.item_pickup_distance = 4
	end
	if data.raw.player.player.reach_resource_distance <  4 then -- Vanilla 2.7
		data.raw.player.player.reach_resource_distance = 4
	end


end	
	
---- Game Tweaks ---- Disassemble Recipes
require("prototypes.Bio_Tweaks.recipe")
if BI.Settings.BI_Game_Tweaks_Disassemble then		

	bobmods.lib.tech.add_recipe_unlock("advanced-material-processing", "bi_recipe_steel_furnace_disassemble")
	bobmods.lib.tech.add_recipe_unlock("automation-2", "bi_recipe_burner_mining_drill_disassemble")
	bobmods.lib.tech.add_recipe_unlock("automation-2", "bi_recipe_stone_furnace_disassemble")
	bobmods.lib.tech.add_recipe_unlock("automation-2", "bi_recipe_burner_inserter_disassemble")
	bobmods.lib.tech.add_recipe_unlock("automation-2", "bi_recipe_long_handed_inserter_disassemble")
	
	if data.raw.item["bi-burner-pump"] then
		bobmods.lib.tech.add_recipe_unlock("automation-2", "bi_recipe_basic_pumpjack_disassemble")
	end

end

---- Game Tweaks ---- Bots
if BI.Settings.BI_Game_Tweaks_Bot then	

-- Logistic & Construction bots can't catch fire or be Mined
	local function immunify(bot)
	  if not bot.flags then bot.flags = {} end
	  if not bot.resistances then bot.resistances = {} end
	  table.insert(bot.flags,"not-flammable")
	  table.insert(bot.resistances, {type = "fire", percent = 100})
	  bot.minable = nil
	  end

	--catches modded bots too
	for _,bot in pairs(data.raw['construction-robot']) do
		immunify(bot)
	end

	for _,bot in pairs(data.raw['logistic-robot']) do
		immunify(bot)
	end
	
	
end

---- Game Tweaks ----
if BI.Settings.BI_Game_Tweaks_Stack_Size then

	---- Inrease Wood Stack Size
	if data.raw.item["wood"] and data.raw.item["wood"].stack_size < 400 then
		data.raw.item["wood"].stack_size = 400
	end

	--- Stone Stack Size	
	if data.raw.item["stone"] and data.raw.item["stone"].stack_size < 400 then
		data.raw.item["stone"].stack_size = 400
	end	
	
	--- Crushed Stone Stack Size	
	if data.raw.item["stone-crushed"] and data.raw.item["stone-crushed"].stack_size < 800 then
		data.raw.item["stone-crushed"].stack_size = 800
	end		
	
	--- Concrete Stack Size	
	if data.raw.item["concrete"] and data.raw.item["concrete"].stack_size < 400 then
		data.raw.item["concrete"].stack_size = 400
	end		
	
	--- Slag Stack Size	
	if data.raw.item["slag"] and data.raw.item["slag"].stack_size < 800 then
		data.raw.item["slag"].stack_size = 800
	end		
		
end


