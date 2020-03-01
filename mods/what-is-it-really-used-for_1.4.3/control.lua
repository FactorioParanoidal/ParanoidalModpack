require("mod-gui")

SHOW_ALL = false	-- Set to true to also display disabled recipes and recipes without technology.

function find_technology(recipe, player)
	for _,tech in pairs(player.force.technologies) do
		if not tech.researched then
			for _, effect in pairs(tech.effects) do
				if effect.type == "unlock-recipe" then
					if effect.recipe == recipe then
						if tech.enabled then
							return tech.localised_name
						else
							if SHOW_ALL then
								return {"disabled_thing", tech.localised_name}
							else
								return false
							end
						end
					end
				end
			end
		end
	end
	if SHOW_ALL then
		return {"not_found"}
	else
		return false
	end
end

function get_machines_for_recipe(recipe, player)
	local factories = {}
	local recipe_category = recipe.category

	for _, entity in pairs(game.entity_prototypes) do
		if entity.crafting_categories and entity.ingredient_count then
			if entity.crafting_categories[recipe_category] and entity.ingredient_count >= #recipe.ingredients then
				factories[entity.name] = entity
			end
		end
	end

	return factories
end

function sort_recipes(recipes, player)
	function compare(l, r)
		-- We want hidden recipes at the end
		if l.hidden ~= r.hidden then
			return r.hidden
		end
		if l.group.order ~= r.group.order then
			return l.group.order < r.group.order
		end
		if l.subgroup.order ~= r.subgroup.order then
			return l.subgroup.order < r.subgroup.order
		end
		if l.order ~= r.order then
			return l.order < r.order
		end
		return l.name < r.name
	end
	table.sort(recipes, compare)
end

function add_recipe_to_list(recipe, table, player)
	local from_research = recipe.enabled or find_technology(recipe.name, player)
	if from_research then
		table.add{type="sprite", name="wiiuf_recipe_sprite_"..recipe.name, sprite="recipe/"..recipe.name}
		local label = table.add{
			type="label", name="wiiuf_recipe_label_"..recipe.name, caption=recipe.localised_name,
			single_line=false
		}
		label.style.minimal_height = 39
		label.style.maximal_width = 249
		if not recipe.enabled then
			label.style = "invalid_label"
			label.tooltip = {"behind_research", from_research}
		elseif recipe.hidden then
			label.style = "wiiuf_hidden_label_style"
		end
		return true
	else
		return false
	end
end

function identify(item, player, side)
	-- If it's not actually an item, do nothing
	-- This can happen if you click the recipe name on the recipe pane
	if not game.item_prototypes[item] and not game.fluid_prototypes[item] then
		return
	end
	
	local ingredient_in = {}
	local mined_from = {}
	local pumped_from = {}
	local looted_from = {}
	local product_of = {}
	
	for name, recipe in pairs(player.force.recipes) do
		for _, ingredient in pairs(recipe.ingredients) do
			if ingredient.name ==  item then
				table.insert(ingredient_in, recipe)
				break
			end
		end
		
		for _, product in pairs(recipe.products) do
			if product.name == item then
				table.insert(product_of, recipe)
				break
			end
		end
	end

	-- Sort both recipe lists
	sort_recipes(ingredient_in, player)
	sort_recipes(product_of, player)
	
	for _, entity in pairs(game.entity_prototypes) do
		if entity.loot then
			for _,loot in pairs(entity.loot) do
				if loot.item == item then
					table.insert(looted_from, entity)
					break
				end
			end
		end
		
		if ((entity.type == "resource" or entity.type == "tree") and
				entity.mineable_properties and
				entity.mineable_properties.products) then
			for _, product in pairs(entity.mineable_properties.products) do
				if product.name == item then
					table.insert(mined_from, entity)
					break
				end
			end
		end

		if entity.fluid and entity.fluid.name == item then
			pumped_from[entity.name] = entity
		end
	end
	
	local table_height = 350
	if side then table_height = 250 end

	local section_width = 300
	
	-- GUI stuff
	if player.gui.center.wiiuf_center_frame then
		player.gui.center.wiiuf_center_frame.destroy()
	end

	local mod_frame_flow = mod_gui.get_frame_flow(player)
	if side and mod_frame_flow.wiiuf_left_frame then
		mod_frame_flow.wiiuf_left_frame.destroy()
	end

	-- Create center frame
	local main_frame = {}
	if not side then
		main_frame = player.gui.center.add{
			type = "frame", name = "wiiuf_center_frame", direction = "vertical"
		}
		-- Register this frame as GUI so it will be closed by usual GUI close
		-- controls
		player.opened = main_frame
	else
		main_frame = mod_gui.get_frame_flow(player).add{
			type = "frame", name = "wiiuf_left_frame", direction = "vertical"
		}
	end
	
	
	-- Title flow
	local title_flow = main_frame.add{type = "flow", name = "wiiuf_title_flow", direction = "horizontal"}

	local sprite = "questionmark"
	local localised_name = item
	if game.item_prototypes[item] then
		sprite = "item/"..item
		localised_name = game.item_prototypes[item].localised_name
	elseif game.fluid_prototypes[item] then
		sprite = "fluid/"..item
		localised_name = game.fluid_prototypes[item].localised_name
	end

	local button_style = "small_slot_button"

	local history = global.wiiuf_item_history[player.index]
	if history.position > 1 then
		title_flow.add{
			type = "sprite-button",
			name = "wiiuf_back",
			sprite = "arrow-left",
			style = button_style,
			tooltip = {"back"}
		}
	end
	if history.position < #history.list then
		title_flow.add{
			type = "sprite-button",
			name = "wiiuf_forward",
			sprite = "arrow-right",
			style = button_style,
			tooltip = {"forward"}
		}
	end

	title_flow.add{type = "sprite", name = "wiiuf_title_sprite", sprite = sprite}
	title_flow.add{type = "label", name = "wiiuf_title_label", caption = localised_name, style = "large_caption_label"}

	title_flow.add{
		type = "sprite-button",
		name = "wiiuf_minimise_" .. item,
		sprite = "arrow-box",
		style = button_style,
		tooltip = {"minimise"}
	}

	if side then
		title_flow.add{
			type = "sprite-button",
			name = "wiiuf_show_" .. item,
			sprite = "arrow-right",
			style = button_style,
			tooltip = {"show", localised_name}
		}
	else
		title_flow.add{
			type = "sprite-button",
			name = "wiiuf_pin_" .. item,
			sprite = "arrow-bar",
			style = button_style,
			tooltip = {"pin"}
		}
	end

	title_flow.add{
		type = "sprite-button",
		name = "wiiuf_close",
		sprite = "close",
		style = button_style,
		tooltip = {"close"}
	}

	-- Body flow
	local body_flow = {}
	if side then
		local body_scroll = main_frame.add{type = "scroll-pane", name = "wiiuf_body_scroll"}
		body_scroll.style.maximal_width = 250
		body_scroll.vertical_scroll_policy = "never"
		body_flow = body_scroll.add{type = "flow", name = "wiiuf_body_flow", direction = "horizontal", style = "slot_table_spacing_horizontal_flow"}
	else
		body_flow = main_frame.add{type = "flow", name = "wiiuf_body_flow", direction = "horizontal", style = "slot_table_spacing_horizontal_flow"}
	end

	-- mined from
	if #mined_from > 0 then
		local mined_frame = body_flow.add{type = "frame", name = "wiiuf_mined_frame", caption = {"mined_from"}}
		local mined_scroll = mined_frame.add{type = "scroll-pane", name = "wiiuf_mined_scroll"}
		mined_scroll.style.minimal_height = table_height
		mined_scroll.style.maximal_height = table_height
		local mined_table = mined_scroll.add{type = "table", name = "wiiuf_mined_table", column_count = 2}
		for i, entity in pairs(mined_from) do
			mined_table.add{type = "sprite", name = "wiiuf_sprite_" .. i, sprite = "entity/"..entity.name}
			local label = mined_table.add{type = "label", name = "wiiuf_label_" .. i, caption = entity.localised_name}
			label.style.minimal_height = 34
		end
	end

	-- looted from
	if #looted_from > 0 then
		local looted_frame = body_flow.add{type = "frame", name = "wiiuf_looted_frame", caption = {"looted_from"}}
		local looted_scroll = looted_frame.add{type = "scroll-pane", name = "wiiuf_looted_scroll"}
		looted_scroll.style.minimal_height = table_height
		looted_scroll.style.maximal_height = table_height
		local looted_table = looted_scroll.add{type = "table", name = "wiiuf_looted_table", column_count = 2}
		for i, entity in pairs(looted_from) do
			looted_table.add{type = "sprite", name = "wiiuf_sprite_" .. i, sprite = "entity/"..entity.name}
			local label = looted_table.add{type = "label", name = "wiiuf_label_" .. i, caption = entity.localised_name}
			label.style.minimal_height = 34
		end
	end

	-- pumped from
	if next(pumped_from) then
		local pumped_frame = body_flow.add{
			type = "frame", name = "wiiuf_pumped_frame", caption = {"pumped_from"}
		}
		local pumped_scroll = pumped_frame.add{
			type = "scroll-pane", name = "wiiuf_pumped_scroll"
		}
		pumped_scroll.style.minimal_height = table_height
		pumped_scroll.style.maximal_height = table_height
		local pumped_table = pumped_scroll.add{
			type = "table", name = "wiiuf_pumped_table", column_count = 2
		}
		machine_unlocks = get_item_unlocks(pumped_from, player)
		for i, entity in pairs(pumped_from) do
			local unlock = machine_unlocks[entity.name]
			local caption = entity.localised_name
			local tooltip = nil
			local style = nil
			if unlock ~= "already_unlocked" then
				style = "invalid_label"
				tooltip = {"behind_research", unlock}
			end
			if unlock == false then
				style = "invalid_label"
				tooltip = {"wiiuf_unavailable"}
				caption = {"disabled_thing", caption}
			end
			pumped_table.add{
				type = "sprite",
				name = "wiiuf_sprite_" .. i,
				sprite = "entity/"..entity.name,
				tooltip = tooltip
			}
			local label = pumped_table.add{
				type = "label",
				name = "wiiuf_label_" .. i,
				caption = caption,
				style = style,
				tooltip = tooltip
			}
			label.style.minimal_height = 34
		end
	end

	function set_scroll_dimensions(scroll)
		scroll.horizontal_scroll_policy = "never"
		scroll.style.minimal_height = table_height
		scroll.style.maximal_height = table_height
		if not side then
			scroll.style.minimal_width = section_width
			scroll.style.maximal_width = section_width
		end
	end

	-- ingredient in
	local ingredient_frame = body_flow.add{type = "frame", name = "wiiuf_ingredient_frame", caption = {"ingredient_in"}}
	local ingredient_scroll = ingredient_frame.add{type = "scroll-pane", name = "wiiuf_ingredient_scroll"}
	set_scroll_dimensions(ingredient_scroll)
	local ingredient_table = ingredient_scroll.add{type = "table", name = "wiiuf_ingredient_table", column_count = 2}
	local is_ingredient = false
	for i, recipe in pairs(ingredient_in) do
		if add_recipe_to_list(recipe, ingredient_table, player) then
			is_ingredient = true
		end
	end
	
	if side and not is_ingredient then
		ingredient_frame.destroy()
	end

	-- product of
	local product_frame = body_flow.add{type = "frame", name = "wiiuf_product_frame", caption = {"product_of"}}
	local product_scroll = product_frame.add{type = "scroll-pane", name = "wiiuf_product_scroll"}
	set_scroll_dimensions(product_scroll)
	local product_table = product_scroll.add{type = "table", name = "wiiuf_product_table", column_count = 2}
	local last_product_recipe = nil
	local num_product_recipes = 0
	for i, recipe in pairs(product_of) do
		if add_recipe_to_list(recipe, product_table, player) then
			last_product_recipe = recipe
			num_product_recipes = num_product_recipes + 1
		end
	end

	if side and num_product_recipes == 0 then
		product_frame.destroy()
	end

	-- If there was only one recipe for making this item, then go ahead and show
	-- it immediately
	if num_product_recipes == 1 then
		show_recipe_details(last_product_recipe.name, player)
	else
		-- Otherwise, add an empty recipe frame so that things don't shift when it's used later
		local recipe_frame = body_flow.add{
			type="frame", name="wiiuf_recipe_frame", caption={"wiiuf_recipe_details"}
		}
		local recipe_scroll = recipe_frame.add{type="scroll-pane", name="wiiuf_recipe_scroll"}
		set_scroll_dimensions(recipe_scroll)
		local label = recipe_scroll.add{
			type="label", name="wiiuf_recipe_hint", caption={"wiiuf_recipe_hint"}, single_line=false
		}
		label.style.maximal_width = 249
	end
end

function identify_and_add_to_history(item, player, side, should_clear_history)
	-- If it's not actually an item, do nothing
	-- This can happen if you click the recipe name on the recipe pane
	if not game.item_prototypes[item] and not game.fluid_prototypes[item] then
		return
	end

	local history
	if (should_clear_history or
			global.wiiuf_item_history == nil or
			global.wiiuf_item_history[player.index] == nil) then
		clear_history(player)
		history = global.wiiuf_item_history[player.index]
	else
		-- Truncate the history by deleting anything after the present entry
		history = global.wiiuf_item_history[player.index]
		while #history.list > history.position do
			history.list[#history.list] = nil
		end
	end

	-- Then add this to the end if it's not already there
	if history.list[#history.list] ~= item then
		table.insert(history.list, item)
		history.position = history.position + 1
	end

	identify(item, player, side)
end

function get_item_unlocks(items, player)
	local item_unlocks = {}
	for name, recipe in pairs(player.force.recipes) do
		for _, product in pairs(recipe.products) do
			if items[product.name] then
				if recipe.enabled then
					item_unlocks[product.name] = "already_unlocked"
				else
					item_unlocks[product.name] = find_technology(recipe.name, player)
				end
			end
		end
	end
	return item_unlocks
end

function show_recipe_details(recipe_name, player)
	local recipe = player.force.recipes[recipe_name]

	local main_frame = player.gui.center.wiiuf_center_frame
	local side = false
	if not main_frame then
		side = true
		main_frame = mod_gui.get_frame_flow(player).wiiuf_left_frame
		if main_frame then
			main_frame = main_frame.wiiuf_body_scroll
		end
	end

	if not main_frame then
		player.print("No main frame")
		return
	end

	local body_flow = main_frame.wiiuf_body_flow

	-- Remove any existing recipe entry
	if body_flow.wiiuf_recipe_frame then
		body_flow.wiiuf_recipe_frame.destroy()
	end

	-- TODO: table_height and section_width should probably be globals, and
	-- maybe configurable
	local table_height = 350
	local section_width = 300
	if side then table_height = 250 end

	local recipe_frame = body_flow.add{
		type="frame", name="wiiuf_recipe_frame", caption={"wiiuf_recipe_details"}
	}
	local recipe_scroll = recipe_frame.add{type="scroll-pane", name="wiiuf_recipe_scroll"}
	recipe_scroll.style.minimal_height = table_height
	recipe_scroll.style.maximal_height = table_height
	recipe_scroll.style.minimal_width = section_width
	recipe_scroll.style.maximal_width = section_width

	-- A generic function for adding an item to the list in the recipe pane

	function add_sprite_and_label(add_to, thing_to_add, with_amount, style, tooltip, sprite_dir, i, force_decimals)
		if sprite_dir == "auto" then
			if game.item_prototypes[thing_to_add.name] then
				sprite_dir = "item"
			elseif game.fluid_prototypes[thing_to_add.name] then
				sprite_dir = "fluid"
			else
				player.print("Unknown sprite type for "..thing_to_add.name)
				return
			end
		end
		local localised_name = thing_to_add.localised_name
		if sprite_dir == "item" then
			if game.item_prototypes[thing_to_add.name] then
				localised_name = game.item_prototypes[thing_to_add.name].localised_name
			else
				-- We were told it was an item but it wasn't.  This can happen for
				-- crafting entities sometimes.  Just silently do nothing in this case
				return
			end
		elseif sprite_dir == "fluid" then
			localised_name = game.fluid_prototypes[thing_to_add.name].localised_name
		end
		local table = add_to.add{
			type="table", name="wiiuf_recipe_table_"..i, column_count=2
		}
		-- In case the sprite does not exist we use pcall to catch the exception
		-- and don't have a sprite (thanks to Helfima/Helmod for the trick).
		local sprite = sprite_dir.."/"..thing_to_add.name
		local sprite_options = {
			type="sprite", name="wiiuf_recipe_item_sprite_"..thing_to_add.name, sprite=sprite
		}
		local ok, error = pcall(function()
			table.add(sprite_options)
		end)
		if not(ok) then
			player.print("Sprite missing: "..sprite)
		end
		local caption = localised_name
		if with_amount then
			local amount = nil
			if with_amount ~= true then
				amount = with_amount
			elseif thing_to_add.amount then
				amount = thing_to_add.amount
			elseif thing_to_add.amount_min and thing_to_add.amount_max then
				amount = (thing_to_add.amount_min + thing_to_add.amount_max) / 2
				if thing_to_add.probability then
					amount = amount * thing_to_add.probability
				end
			end

			if amount then
				local formatted_amount = amount
				if force_decimals or amount ~= math.floor(amount) then
					formatted_amount = string.format("%.3f", amount)
				end
				caption = {"wiiuf_recipe_entry", formatted_amount, localised_name}
			end
		end
		local label = table.add{
			type="label", name="wiiuf_recipe_item_label_"..thing_to_add.name, caption=caption,
			single_line=false
		}
		if style then
			label.style = style
		end
		label.style.maximal_width = 249
		if tooltip then
			label.tooltip = tooltip
		end
	end

	local i = 0

	local recipe_style = nil
	local unlock = nil
	if not recipe.enabled then
		unlock = find_technology(recipe.name, player)
		recipe_style = "invalid_label"
	end

	add_sprite_and_label(
		recipe_scroll, recipe, false, recipe_style, nil, "recipe", i
	)
	i = i + 1

	if not recipe.enabled and unlock then
		recipe_scroll.add{
			type="label",
			name="wiiuf_recipe_unlock_warning",
			caption={"behind_research", unlock},
			style="invalid_label"
		}
	end

	-- First add ingredients
	recipe_scroll.add{
		type="label", name="wiiuf_recipe_ingredients_heading", caption={"wiiuf_recipe_ingredients_heading"},
		style="bold_label"
	}
	for _, ingredient in pairs(recipe.ingredients) do
		add_sprite_and_label(recipe_scroll, ingredient, true, nil, nil, "auto", i)
		i = i + 1
	end

	-- Next add products
	recipe_scroll.add{
		type="label", name="wiiuf_recipe_products_heading", caption={"wiiuf_recipe_products_heading"},
		style="bold_label"
	}
	for _, product in pairs(recipe.products) do
		add_sprite_and_label(recipe_scroll, product, true, nil, nil, "auto", i)
		i = i + 1
	end

	-- Finally add machines
	recipe_scroll.add{
		type="label", name="wiiuf_recipe_machines_heading", caption={"wiiuf_recipe_machines_heading"},
		style="bold_label"
	}
	local machines = get_machines_for_recipe(recipe, player)
	-- Figure out which machines are available at current tech
	local machine_unlocks = get_item_unlocks(machines, player)
	for _, machine in pairs(machines) do
		local unlock = machine_unlocks[machine.name]
		if unlock then
			local tooltip = nil
			local style = nil
			if unlock ~= "already_unlocked" then
				style = "invalid_label"
				tooltip = {"behind_research", unlock}
			end
			local crafting_time = recipe.energy / machine.crafting_speed
			add_sprite_and_label(
				recipe_scroll, machine, crafting_time, style, tooltip, "item", i, true
			)
			i = i + 1
		end
	end
end

function minimise(item, player, from_side)
	if not player.gui.left.wiiuf_item_flow then
		local item_flow = player.gui.left.add{type = "scroll-pane", name = "wiiuf_item_flow", style = "small_spacing_scroll_pane_style"}
		local item_table = item_flow.add{
			type = "table",
			column_count = 1,
			name = "wiiuf_item_table",
			style = "slot_table"
		}
		item_table.add{type = "sprite-button", name = "wiiuf_close", sprite = "close", style = "slot_button", tooltip = {"close"}}
		item_flow.style.maximal_height = 350
	end	
	
	local sprite = "questionmark"
	local localised_name = item
	if game.item_prototypes[item] then
		sprite = "item/"..item
		localised_name = game.item_prototypes[item].localised_name
	elseif game.fluid_prototypes[item] then
		sprite = "fluid/"..item
		localised_name = game.fluid_prototypes[item].localised_name
	end
	if not player.gui.left.wiiuf_item_flow.wiiuf_item_table["wiiuf_show_" .. item] then
		player.gui.left.wiiuf_item_flow.wiiuf_item_table.add{
			type = "sprite-button",
			name = "wiiuf_show_" .. item,
			sprite = sprite,
			tooltip = {"show", localised_name},
			style = "slot_button"
		}
	end
	if not from_side and player.gui.center.wiiuf_center_frame then player.gui.center.wiiuf_center_frame.destroy() end
	local mod_frame_flow = mod_gui.get_frame_flow(player)
	if from_side and mod_frame_flow.wiiuf_left_frame then mod_frame_flow.wiiuf_left_frame.destroy() end
end

function get_wiiuf_flow(player)
	local button_flow = mod_gui.get_button_flow(player)
	local flow = button_flow.wiiuf_flow
	if not flow then
		flow = button_flow.add{
			type = "flow", name = "wiiuf_flow", direction = "horizontal"
		}
	end
	return flow
end

function add_top_button(player)
	if player.gui.top.wiiuf_flow then player.gui.top.wiiuf_flow.destroy() end -- remove the old flow

	local flow = get_wiiuf_flow(player)

	if flow["search_flow"] then flow["search_flow"].destroy() end
	local search_flow = flow.add{type = "flow", name = "search_flow", direction = "horizontal"}
	search_flow.add{
		type = "flow",
		name = "search_bar_placeholder",
		direction = "vertical"
	}
	search_flow.add{
		type = "sprite-button",
		name = "looking-glass",
		sprite = "looking-glass",
		style = mod_gui.button_style,
		tooltip = {"top_button_tooltip"}
	}
end

function clear_history(player)
	if global.wiiuf_item_history == nil then
		global.wiiuf_item_history = {}
	end
	global.wiiuf_item_history[player.index] = {
		position = 0,
		list = {}
	}
end

script.on_init(function()
	global.n_fluids = 0
	for _ in pairs(game.fluid_prototypes) do
		global.n_fluids = global.n_fluids +1
	end
	global.wiiuf_item_history = {}
	for _, player in pairs(game.players) do
		add_top_button(player)
		clear_history(player)
	end
end)

script.on_configuration_changed(function()
	global.n_fluids = 0
	for _ in pairs(game.fluid_prototypes) do
		global.n_fluids = global.n_fluids +1
	end
	for _, player in pairs(game.players) do add_top_button(player) end
end)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	add_top_button(player)
	clear_history(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]
	local flow = get_wiiuf_flow(player)

	-- There was a report that the search flow spontaneously vanished during a
	-- game (possibly another mod messed with it?).  Check for that and recreate
	-- as necessary
	if not flow.search_flow then
		add_top_button(player)
	end

	if event.element.name == "looking-glass" then
		if player.cursor_stack.valid_for_read then
			identify_and_add_to_history(player.cursor_stack.name, player, false, true)
		else
			if flow.fluids_table then flow.fluids_table.destroy()
			else
				local fluids_table = flow.add{type = "table", column_count = math.ceil(global.n_fluids/10), name = "fluids_table", style = "slot_table"}
				for _, fluid in pairs(game.fluid_prototypes) do
					fluids_table.add{type = "sprite-button", name = "wiiuf_fluid_" .. fluid.name, sprite = "fluid/"..fluid.name, style = "slot_button", tooltip = fluid.localised_name}
				end
			end
		end
	
	--Label for fluid in search results. Check it before root "wiiuf_fluid_"
	elseif event.element.name:find("wiiuf_fluid_label_") then
		identify_and_add_to_history(event.element.name:sub(19), player, false, true)
	
	--Sprite for fluid in search results
	elseif event.element.name:find("wiiuf_fluid_") then
		identify_and_add_to_history(event.element.name:sub(13), player, false, true)
		if flow.fluids_table then flow.fluids_table.destroy() end
	
	elseif event.element.name == "wiiuf_close" then
		event.element.parent.parent.destroy()
	
	elseif event.element.name:find("wiiuf_minimise_") then
		minimise(event.element.name:sub(16), player, event.element.parent.parent.name == "wiiuf_left_frame")
	
	-- Unminimizing button
	elseif event.element.name:find("wiiuf_show_") then
		identify_and_add_to_history(
			event.element.name:sub(12), player, false, false)
		if event.element.parent.name == "wiiuf_item_table" then 
			event.element.destroy()
			if #player.gui.left.wiiuf_item_flow.wiiuf_item_table.children_names == 1 then
				player.gui.left.wiiuf_item_flow.destroy()
			end
		else mod_gui.get_frame_flow(player).wiiuf_left_frame.destroy()
		end
	
	elseif event.element.name:find("wiiuf_pin_") then
		identify_and_add_to_history(
			event.element.name:sub(11), player, true, false)

	--Sprite for item in search results
	elseif event.element.name:find("wiiuf_item_sprite_") then
		identify_and_add_to_history(
			event.element.name:sub(19), player, false, true)
		flow.search_flow.search_bar_placeholder.search_bar_scroll.destroy()
		flow.search_flow.search_bar_placeholder.search_bar_textfield.destroy()

	--Label for item in search results
	elseif event.element.name:find("wiiuf_item_label_") then
		identify_and_add_to_history(
			event.element.name:sub(18), player, false, true)
		flow.search_flow.search_bar_placeholder.search_bar_scroll.destroy()
		flow.search_flow.search_bar_placeholder.search_bar_textfield.destroy()

	-- Sprite for recipe in list
	elseif event.element.name:find("wiiuf_recipe_sprite_") then
		show_recipe_details(event.element.name:sub(21), player)

	-- Label for recipe in list
	elseif event.element.name:find("wiiuf_recipe_label_") then
		show_recipe_details(event.element.name:sub(20), player)

	-- Sprite for item in recipe view
	elseif event.element.name:find("wiiuf_recipe_item_sprite_") then
		identify_and_add_to_history(
			event.element.name:sub(26), player, false, false)

	-- Label for item in recipe view
	elseif event.element.name:find("wiiuf_recipe_item_label_") then
		identify_and_add_to_history(
			event.element.name:sub(25), player, false, false)

	-- Back through item history
	elseif event.element.name == "wiiuf_back" then
		local history = global.wiiuf_item_history[player.index]
		if history.position > 1 then
			history.position = history.position - 1
		end
		identify(history.list[history.position], player)

	-- Forward through item history
	elseif event.element.name == "wiiuf_forward" then
		local history = global.wiiuf_item_history[player.index]
		if history.position < #history.list then
			history.position = history.position + 1
		end
		identify(history.list[history.position], player)
	end
end)

script.on_event("inspect_item", function(event)
	local player = game.players[event.player_index]
	local flow = get_wiiuf_flow(player)
	if player.cursor_stack.valid_for_read then
		clear_history(player)
		identify_and_add_to_history(player.cursor_stack.name, player, true)
	else
		if flow.search_flow.search_bar_placeholder.search_bar_textfield then
			flow.search_flow.search_bar_placeholder.search_bar_textfield.destroy()
			if flow.search_flow.search_bar_placeholder.search_bar_scroll then
				flow.search_flow.search_bar_placeholder.search_bar_scroll.destroy()
			end
		else
			local text_field = flow.search_flow.search_bar_placeholder.add{
				type = "textfield", name = "search_bar_textfield"
			}
			text_field.focus()
		end
	end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
	if event.element.name == "search_bar_textfield" then
		local player = game.players[event.player_index]
		local flow = get_wiiuf_flow(player)
		if flow.search_flow.search_bar_placeholder.search_bar_scroll then
			flow.search_flow.search_bar_placeholder.search_bar_scroll.destroy()
		end
		
		if string.len(event.element.text) < 2 then return end
		
		local scroll_pane = flow.search_flow.search_bar_placeholder.add{
			type = "scroll-pane",
			name = "search_bar_scroll",
			style = "small_spacing_scroll_pane_style"
		}
		scroll_pane.style.maximal_height = 250
		local results_table = scroll_pane.add{
			type = "table",
			name = "results_table_"..math.random(100),
			column_count = 2,
			style = "row_table_style"
		}

		-- The first row of the table is regarded as the table headers and don't
		-- get the table style applied to them
		-- We don't want this however, so we fill it in with blanks.
		results_table.add{type = "label", name = "wiiuf_filler_label_1"}
		results_table.add{type = "label", name = "wiiuf_filler_label_2"}

		-- remove capitals, purge special characters, and replace spaces with -
		local text = event.element.text:lower()
		text = text:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
		text = text:gsub(" ", "%%-")

		for _, item in pairs(game.item_prototypes) do
			if item.name:lower():find(text) then
				results_table.add{
					type = "sprite",
					name = "wiiuf_item_sprite_" .. item.name,
					sprite = "item/"..item.name
				}
				local label = results_table.add{
					type = "label",
					name = "wiiuf_item_label_" .. item.name,
					caption = item.localised_name
				}
				label.style.minimal_height = 34
				label.style.minimal_width = 101
			end
		end
		for _, item in pairs(game.fluid_prototypes) do
			if item.name:lower():find(text) then
				results_table.add{
					type = "sprite",
					name = "wiiuf_fluid_" .. item.name,
					sprite = "fluid/"..item.name
				}
				local label = results_table.add{
					type = "label",
					name = "wiiuf_fluid_label_" .. item.name,
					caption = item.localised_name
				}
				label.style.minimal_height = 34
				label.style.minimal_width = 101
			end
		end
	end
end)

script.on_event(defines.events.on_gui_closed, function(event)
	-- If our window was the currently open window, we need to destroy it on
	-- close
	if event.gui_type == defines.gui_type.custom and event.element and
		event.element.name == "wiiuf_center_frame" then
		event.element.destroy()
	end
end)

-- vim:noet:ts=2
