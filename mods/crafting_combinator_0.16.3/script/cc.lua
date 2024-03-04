local util = require 'script.util'
local gui = require 'script.gui'
local settings_parser = require 'script.settings-parser'
local recipe_selector = require 'script.recipe-selector'
local config = require 'config'
local signals = require 'script.signals'


local _M = {}
local combinator_mt = {__index = _M}


local CHEST_POSITION_NAMES = {'behind', 'left', 'right', 'behind-left', 'behind-right'}
local CHEST_POSITIONS = {}; for key, name in pairs(CHEST_POSITION_NAMES) do CHEST_POSITIONS[name] = key; end
local CHEST_DIRECTIONS = {
	[CHEST_POSITIONS.behind] = 180,
	[CHEST_POSITIONS.right] = 90,
	[CHEST_POSITIONS.left] = -90,
	[CHEST_POSITIONS['behind-right']] = 135,
	[CHEST_POSITIONS['behind-left']] = -135,
}

local STATUS_SIGNALS = {}
for name, signal in pairs(config.MACHINE_STATUS_SIGNALS) do
	if defines.entity_status[name] then
		STATUS_SIGNALS[defines.entity_status[name]] = signal
	end
end


_M.settings_parser = settings_parser {
	chest_position = {'c', 'int'},
	mode = {'m', 'string'},
	discard_items = {'d', 'bool'},
	discard_fluids = {'f', 'bool'},
	empty_inserters = {'i', 'bool'},
	craft_until_zero = {'z', 'bool'},
	read_recipe = {'r', 'bool'},
	read_speed = {'s', 'bool'},
	read_machine_status = {'st', 'bool'},
	wait_for_output_to_clear = {'wo', 'bool'},
}


-- General housekeeping

function _M.init_global()
	global.cc = global.cc or {}
	global.cc.data = global.cc.data or {}
	global.cc.ordered = global.cc.ordered or {}
	global.cc.inserter_empty_queue = {}
end

function _M.on_load()
	for _, combinator in pairs(global.cc.data) do setmetatable(combinator, combinator_mt); end
end


-- Lifecycle events

function _M.create(entity)
	local combinator = setmetatable({
		entity = entity,
		control_behavior = entity.get_or_create_control_behavior(),
		module_chest = entity.surface.create_entity {
			name = config.MODULE_CHEST_NAME,
			position = entity.position,
			force = entity.force,
			create_build_effect_smoke = false,
		},
		settings = _M.settings_parser:read_or_default(entity, util.deepcopy(config.CC_DEFAULT_SETTINGS)),
		inventories = {},
		items_to_ignore = {},
		last_flying_text_tick = -config.FLYING_TEXT_INTERVAL,
		enabled = true,
		last_recipe = false,
	}, combinator_mt)
	
	combinator.module_chest.destructible = false
	combinator.inventories.module_chest = combinator.module_chest.get_inventory(defines.inventory.chest)
	
	global.cc.data[entity.unit_number] = combinator
	table.insert(global.cc.ordered, combinator)
	combinator:find_assembler()
	combinator:find_chest()
	
	-- Other combinators can use the module chest as overflow output, so let them know it's there
	_M.update_chests(entity.surface, combinator.module_chest)
end

function _M.mark_for_deconstruction(entity)
	local combinator = global.cc.data[entity.surface.find_entity(config.CC_NAME, entity.position).unit_number]
	combinator.enabled = false
	combinator:update()
end
function _M.cancel_deconstruction(entity)
	local combinator = global.cc.data[entity.surface.find_entity(config.CC_NAME, entity.position).unit_number]
	combinator.enabled = true
	combinator:update()
end
function _M.fix_undo_deconstruction(entity, player_index)
	local combinator = global.cc.data[entity.unit_number]
	local player = player_index and game.get_player(player_index)
	local force = player and player.force or entity.force
	entity.cancel_deconstruction(force, player)
	combinator.module_chest.order_deconstruction(force, player)
end

function _M.destroy_by_robot(entity)
	local combinator_entity = entity.surface.find_entity(config.CC_NAME, entity.position)
	if not combinator_entity then return; end
	_M.destroy(combinator_entity)
	combinator_entity.destroy()
end

function _M.destroy(entity, player_index)
	local unit_number = entity.unit_number
	local combinator = global.cc.data[unit_number]
	
	if player_index then
		local inventory = combinator.inventories.module_chest
		if not inventory.is_empty() then
			local target = player_index and game.get_player(player_index).get_inventory(defines.inventory.character_main)
			for i = 1, #inventory do
				local stack = inventory[i]
				if stack.valid_for_read then
					local r = target and target.insert(stack) or 0
					if r < stack.count then
						stack.count = stack.count - r
						-- Clone the entity as replacement and tell the player the inventory is full
						game.get_player(player_index).print{'inventory-restriction.player-inventory-full', stack.prototype.localised_name}
						
						-- Replace the entity if a player was trying to pick it up
						local old_entity = combinator.entity
						local old_cb = combinator.control_behavior
						combinator.entity = old_entity.clone{position = old_entity.position}
						combinator.control_behavior = combinator.entity.get_or_create_control_behavior()
						
						global.cc.data[unit_number] = nil
						global.cc.data[combinator.entity.unit_number] = combinator
						
						for _, connection in pairs(old_entity.circuit_connection_definitions) do
							combinator.entity.connect_neighbour(connection)
						end
						
						old_entity.destroy()
						return true -- Inidcate that the original entity was destroyed
					else stack.clear(); end
				end
			end
		end
	end
	
	-- Notify other combinators that the chest was destroyed
	_M.update_chests(entity.surface, combinator.module_chest, true)
	if player_index then combinator.module_chest.destroy(); end
	settings_parser.destroy(entity)
	signals.cache.drop(entity)
	
	global.cc.data[unit_number] = nil
	for k, v in pairs(global.cc.ordered) do
		if v.entity.unit_number == unit_number then
			table.remove(global.cc.ordered, k)
			break
		end
	end
end

function _M.update_assemblers(surface, assembler, ignore)
	local combinators = surface.find_entities_filtered {
		area = util.area(assembler.prototype.selection_box):expand(config.ASSEMBLER_SEARCH_DISTANCE) + assembler.position,
		name = config.CC_NAME,
	}
	for _, entity in pairs(combinators) do global.cc.data[entity.unit_number]:find_assembler(ignore and assembler or nil); end
end

function _M.update_chests(surface, chest, ignore)
	local combinators = surface.find_entities_filtered {
		area = util.area(chest.prototype.selection_box):expand(config.CHEST_SEARCH_DISTANCE) + chest.position,
		name = config.CC_NAME,
	}
	for _, entity in pairs(combinators) do global.cc.data[entity.unit_number]:find_chest(ignore and chest or nil); end
end

function _M:update()
	local params = {}
	if self.enabled and self.assembler and self.assembler.valid then
		self.assembler.active = true
		
		if self.settings.mode == 'w' then
			self:set_recipe()
		end
		if self.settings.mode == 'r' then
			if self.settings.read_recipe then self:read_recipe(params); end
			if self.settings.read_speed then self:read_speed(params); end
			if self.settings.read_machine_status then self:read_machine_status(params); end
		end
	end
	
	self.control_behavior.parameters = params
end


function _M:open(player_index)
	local root = gui.entity(self.entity, {
		title_elements = {
			gui.button('open-module-chest'),
			gui.dropdown('chest-position', CHEST_POSITION_NAMES, self.settings.chest_position, {tooltip=true}),
		},
		
		gui.section {
			name = 'mode',
			gui.radio('w', self.settings.mode, {locale='mode-write', tooltip=true}),
			gui.radio('r', self.settings.mode, {locale='mode-read', tooltip=true}),
		},
		gui.section {
			name = 'misc',
			gui.checkbox('wait-for-output-to-clear', self.settings.wait_for_output_to_clear, {tooltip = true}),
			gui.checkbox('discard-items', self.settings.discard_items),
			gui.checkbox('discard-fluids', self.settings.discard_fluids),
			gui.checkbox('empty-inserters', self.settings.empty_inserters),
			gui.checkbox('craft-until-zero', self.settings.craft_until_zero, {tooltip = true}),
			gui.checkbox('read-recipe', self.settings.read_recipe),
			gui.checkbox('read-speed', self.settings.read_speed),
			gui.checkbox('read-machine-status', self.settings.read_machine_status),
		}
	}):open(player_index)
	
	self:update_disabled_checkboxes(root)
end

function _M:on_checked_changed(name, state, element)
	local category, name = name:gsub(':.*$', ''), name:gsub('^.-:', ''):gsub('-', '_')
	if category == 'mode' then
		self.settings.mode = name
		for _, el in pairs(element.parent.children) do
			if el.type == 'radiobutton' then
				local _, _, el_name = gui.parse_entity_gui_name(el.name)
				el.state = el_name == 'mode:'..name
			end
		end
	end
	if category == 'misc' then self.settings[name] = state; end
	if name == 'craft_until_zero' and self.settings.craft_until_zero then
		self.last_recipe = nil
	end
	
	self:update_disabled_checkboxes(gui.get_root(element))
	
	self.settings_parser:update(self.entity, self.settings)
end

function _M:update_disabled_checkboxes(root)
	self:disable_checkbox(root, 'misc:discard-items', 'w')
	self:disable_checkbox(root, 'misc:discard-fluids', 'w')
	self:disable_checkbox(root, 'misc:empty-inserters', 'w')
	self:disable_checkbox(root, 'misc:craft-until-zero', 'w')
	self:disable_checkbox(root, 'misc:wait-for-output-to-clear', 'w')
	self:disable_checkbox(root, 'misc:read-recipe', 'r')
	self:disable_checkbox(root, 'misc:read-speed', 'r')
	self:disable_checkbox(root, 'misc:read-machine-status', 'r')
end

function _M:disable_checkbox(root, name, mode)
	local checkbox = gui.find_element(root, gui.name(self.entity, name))
	checkbox.enabled = self.settings.mode == mode
end

function _M:on_selection_changed(name, selected)
	if name == 'title:chest-position:value' then
		self.settings.chest_position = selected
		self.settings_parser:update(self.entity, self.settings)
		self:find_chest()
	end
end

function _M:on_click(name, element)
	if name == 'title:open-module-chest' then
		game.get_player(element.player_index).opened = self.module_chest
	end
end


-- Other stuff

function _M:read_recipe(params)
	local recipe = self.assembler.get_recipe()
	if recipe then
		table.insert(params, {
			signal = recipe_selector.get_signal(recipe.name),
			count = 1,
			index = 1,
		})
	end
end

function _M:read_speed(params)
	local count = self.assembler.crafting_speed * 100
	table.insert(params, {
		signal = {type = 'virtual', name = config.SPEED_SIGNAL_NAME},
		count = count,
		index = 2,
	})
end

function _M:read_machine_status(params)
	local signal = STATUS_SIGNALS[self.assembler.status or "A dummy string to avoid indexing by nil"]
	if signal == nil then return end
	table.insert(params, {
		signal = {type = 'virtual', name = signal},
		count = 1,
		index = 3,
	})
end

function _M:set_recipe()
	local changed, recipe
	if self.settings.craft_until_zero then
		if not self.last_recipe or not signals.signal_present(self.entity) then
			local highest = signals.watch_highest_presence(self.entity)
			if highest then recipe = self.entity.force.recipes[highest.signal.name]
			else recipe = nil; end
			self.last_recipe = recipe
		else recipe = self.last_recipe; end
	else
		changed, recipe = recipe_selector.get_recipe(self.entity, nil, self.last_recipe and self.last_recipe.name)
		if changed then self.last_recipe = recipe
		else recipe = self.last_recipe; end
	end
	
	if recipe and (recipe.hidden or not recipe.enabled) then recipe = nil; end
	
	local a_recipe = self.assembler.get_recipe()
	
	-- Move items if necessary
	if a_recipe and ((not recipe) or recipe ~= a_recipe) then
		local success, error = self:move_items()
		if not success then return self:on_chest_full(error); end
		if self.settings.empty_inserters then
			success, error = self:empty_inserters()
			if not success then return self:on_chest_full(error); end
			
			local tick = game.tick + config.INSERTER_EMPTY_DELAY
			global.cc.inserter_empty_queue[tick] = global.cc.inserter_empty_queue[tick] or {}
			table.insert(global.cc.inserter_empty_queue[tick], self)
		end
		
		-- Clear fluidboxes
		if self.settings.discard_fluids then
			for i=1, #self.assembler.fluidbox do self.assembler.fluidbox[i] = nil; end
		end
	end
	
	if recipe ~= a_recipe then
		 -- Move modules if necessary
		if recipe then self:move_modules(recipe); end
		
		-- Finally attempt to switch the recipe
		self.assembler.set_recipe(recipe)
		local new_recipe = self.assembler.get_recipe()
		if new_recipe and new_recipe ~= recipe then self.assembler.set_recipe(nil); end --TODO: Some notification?
	end
	
	-- Move modules and items back into the machine
	self:insert_modules()
	self:insert_items()
	
	return true
end

function _M:move_modules(recipe)
	local target = self.inventories.module_chest
	local inventory = self.inventories.assembler.modules
	for i = 1, #inventory do
		local stack = inventory[i]
		if stack.valid_for_read then
			local limitations = util.module_limitations()[stack.name]
			--TODO: Deal with not enough space in the chest
			if limitations and not limitations[recipe.name] then target.insert(stack); end
		end
	end
end

function _M:insert_modules()
	local inventory = self.inventories.module_chest
	if inventory.is_empty() then return; end
	local target = self.inventories.assembler.modules
	
	for i = 1, #inventory do
		local stack = inventory[i]
		if stack.valid_for_read then
			local r = target.insert(stack)
			if r < stack.count then stack.count = stack.count - r
			else stack.clear(); end
		end
	end
end

function _M:insert_items()
	local inventory = self.inventories.chest
	if not inventory or not inventory.valid or inventory.is_empty() then return; end
	local target = self.inventories.assembler.input
	
	for i = 1, #inventory do
		local stack = inventory[i]
		if stack.valid_for_read then
			local r = target.insert(stack)
			if r < stack.count then stack.count = stack.count - r
			else stack.clear(); end
		end
	end
end

function _M:move_items()
	if self.settings.wait_for_output_to_clear and not self.inventories.assembler.output.is_empty() then
		return false, 'waiting-for-output'
	end
	
	if self.settings.discard_items then return true; end
	
	local target = self:get_chest_inventory()
	
	-- Compensate for half-finished crafts
	-- Do this first to avoid losing a lot of items
	if self.assembler.crafting_progress > 0 then
		local success = true
		for _, ing in pairs(self.assembler.get_recipe().ingredients) do
			if ing.type == 'item' then
				if not target then return false, 'no-chest'; end
				local r = target.insert{name = ing.name, count = ing.amount}
				if r < ing.amount then success = false; end
			end
		end
		self.assembler.crafting_progress = 0
		if not success then return false, 'chest-full'; end
	end
	
	-- Clear the assembler inventories
	-- This may become somewhat problematic if the input items can be moved, but the output can't, since inserters will
	-- continue to replace the items that were removed. I guess that's up to the player to deal with tho...
	for _, inventory in pairs{self.inventories.assembler.input, self.inventories.assembler.output} do
		for i=1, #inventory do
			local stack = inventory[i]
			if stack.valid_for_read then
				if not target then return false, 'no-chest'; end
				local r = target.insert(stack)
				if r < stack.count then
					stack.count = stack.count - r -- Make sure the items don't get duplicated
					return false, 'chest-full'
				end
				inventory[i].clear()
			end
		end
	end
	
	return true
end

function _M:on_chest_full(error)
	-- Prevent the assembler from crafting any more shit
	self.assembler.active = false
	if game.tick - self.last_flying_text_tick >= config.FLYING_TEXT_INTERVAL then
		self.last_flying_text_tick = game.tick
		self.entity.surface.create_entity {
			name = 'flying-text',
			position = self.entity.position,
			text = {'crafting_combinator_gui.switching-stuck:'..(error or 'chest-full')},
			color = {255, 0, 0},
		}
	end
end

function _M:empty_inserters()
	local target = self:get_chest_inventory()
	
	for _, inserter in pairs(self.assembler.surface.find_entities_filtered {
				area = util.area(self.assembler.prototype.selection_box):expand(config.INSERTER_SEARCH_RADIUS) + self.assembler.position,
				type = 'inserter',
			}) do
		if inserter.drop_target == self.assembler then
			local stack = inserter.held_stack
			if stack.valid_for_read and not self.settings.discard_items then
				if not target then return false, 'no-chest'; end
				local r = target.insert(stack)
				if r < stack.count then
					stack.count = stack.count - r
					return false, 'chest-full'
				end
				stack.clear()
			else stack.clear(); end
		end
	end
	return true
end

function _M:find_assembler(assembler_to_ignore)
	self.assembler = self.entity.surface.find_entities_filtered {
		position = util.position(self.entity.position):shift(self.entity.direction, config.ASSEMBLER_DISTANCE),
		type = 'assembling-machine',
	}[1]
	if self.assembler and (self.assembler == assembler_to_ignore or self.assembler.prototype.fixed_recipe) then
		self.assembler = nil
	end
	
	if self.assembler then
		self.inventories.assembler = {
			output = self.assembler.get_inventory(defines.inventory.assembling_machine_output),
			input = self.assembler.get_inventory(defines.inventory.assembling_machine_input),
			modules = self.assembler.get_inventory(defines.inventory.assembling_machine_modules),
		}
	else self.inventories.assembler = {}; end
end

function _M:find_chest(chest_to_ignore)
	local direction = util.direction(self.entity.direction):rotate(CHEST_DIRECTIONS[self.settings.chest_position])
	self.chest = self.entity.surface.find_entities_filtered {
		position = util.position(self.entity.position):shift(direction, config.CHEST_DISTANCE),
		type = {'container', 'logistic-container'},
	}[1]
	if self.chest == chest_to_ignore then self.chest = nil; end
	self.inventories.chest = self.chest and self.chest.get_inventory(defines.inventory.chest)
end

function _M:get_chest_inventory()
	local inventory = self.inventories.chest
	if not inventory or inventory.valid then return inventory; end
	self:find_chest()
	return self.inventories.chest
end


function _M:update_inner_positions()
	settings_parser.move_entity(self.entity, self.module_chest.position)
	self.module_chest.teleport(self.entity.position)
end


function _M:copy(source)
	self.inventories.module_chest.set_bar(source.inventories.module_chest.get_bar())
end


return _M
