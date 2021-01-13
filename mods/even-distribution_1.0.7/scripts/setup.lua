-- Sets up the global table and parses settings

local setup = {}
local util = scripts.util
local metatables = scripts.metatables
local defaultTrash = require("default-trash")
local config = require("config")

local helpers = scripts.helpers
local _ = helpers.on

function setup.on_init()
	global.cache = global.cache or {}
	global.distrEvents = global.distrEvents or {}
	global.settings = global.settings or {}
	global.defaultTrash = setup.generateTrashItemList()
	global.lastCharts = {}
	global.lastCharacters = {}

	global.allowedEntities = _(game.entity_prototypes)
								:where(function(prototype)
									return util.hasInventory(prototype) and 
										   not config.ignoredEntities[prototype.type] and 
										   not config.ignoredEntities[prototype.name]
								end)
								:map(function(name)
									return name, true
								end)
								:toPlain()

	-- GUI events are saved in global.guiEvents["EVENT NAME"][PLAYER INDEX][GUI ELEMENT INDEX]
	global.guiEvents = global.guiEvents or 
	{ 
		onCheckedStateChanged   = {},
		onClicked               = {},
		onElementChanged        = {},
		onSelectionStateChanged = {},
		onTextChanged           = {},
		onValueChanged          = {},
		onConfirmed             = {},
		onSelectedTabChanged    = {},
		onSwitchStateChanged    = {},
		onLocationChanged       = {}, 
	}

	-- Fuel upgrade list (ascending fuel value)
	global.fuelList = _(game.item_prototypes)
						:where("fuel")
						:toArray()
						:groupBy("fuel_category")
						:sort(function(a,b)
							return a.fuel_value < b.fuel_value or
								   a.fuel_acceleration_multiplier < b.fuel_acceleration_multiplier or
								   a.fuel_top_speed_multiplier < b.fuel_top_speed_multiplier or
								   a.fuel_emissions_multiplier < b.fuel_emissions_multiplier
						end)
						:toPlain()

	-- Ammo upgrade list (ascending damage)
	global.ammoList = _(game.item_prototypes)
						:where("ammo")
						:toArray()
						:groupBy(function(__,prototype)
							return prototype.get_ammo_type().category
						end)
						:sort(function(a,b)
							return _(a):calculateDamage() < _(b):calculateDamage()
						end)
						:toPlain()
	
	for _,force in pairs(game.forces) do
		setup.enableLogisticsTab(force) 
	end

	for player_index,player in pairs(game.players) do
		setup.setupPlayer(player_index, player)
	end
end

setup.on_configuration_changed = setup.on_init

function setup.on_player_created(event)
	setup.setupPlayer(event.player_index)
end

function setup.setupPlayer(player_index, player)
	player = _(player or game.players[player_index])
	setup.createPlayerCache(player_index)
	setup.migrateSettings(player)			
end

function setup.createPlayerCache(index)
	global.cache[index] = global.cache[index] or {}
	global.cache[index].items = global.cache[index].items or {}
	global.cache[index].markers = global.cache[index].markers or {}
	metatables.use(global.cache[index].markers, "entityAsIndex")
	global.cache[index].entities = global.cache[index].entities or {}
	metatables.use(global.cache[index].entities, "entityAsIndex")
end

function setup.migrateSettings(player)
	local settings = global.settings[player.index] or {}
	global.settings[player.index] = settings
	local character = _(player.character or player.cutscene_character)

	-- default values
	if settings.distributionMode == nil             then settings.distributionMode = "distribute" end
	if settings.fuelLimit == nil             		then settings.fuelLimit = 0.5 end
	if settings.fuelLimitType == nil         		then settings.fuelLimitType = "stacks" end
	if settings.ammoLimit == nil             		then settings.ammoLimit = 0.5 end
	if settings.ammoLimitType == nil         		then settings.ammoLimitType = "stacks" end

	if settings.enableDragDistribute == nil         then settings.enableDragDistribute = true end
	if settings.dragUseFuelLimit == nil             then settings.dragUseFuelLimit = true end
	if settings.dragUseAmmoLimit == nil             then settings.dragUseAmmoLimit = true end
	if settings.takeFromInventory == nil            then settings.takeFromInventory = true end
	if settings.takeFromCar == nil                  then settings.takeFromCar = true end
	if settings.replaceItems == nil                 then settings.replaceItems = true end
	if settings.distributionDelay == nil            then settings.distributionDelay = 0.9 end

	if settings.enableInventoryCleanupHotkey == nil then settings.enableInventoryCleanupHotkey = true end
	if settings.cleanupRequestOverflow == nil       then settings.cleanupRequestOverflow = true end
	if settings.dropTrashToChests == nil       		then settings.dropTrashToChests = true end
	if settings.dropTrashToOutput == nil       		then settings.dropTrashToOutput = true end
	if settings.cleanupUseFuelLimit == nil       	then settings.cleanupUseFuelLimit = true end
	if settings.cleanupUseAmmoLimit == nil       	then settings.cleanupUseAmmoLimit = true end
	if settings.cleanupDropRange == nil       		then settings.cleanupDropRange = 30 end

	if settings.ignoredEntities == nil       		then settings.ignoredEntities = {} end

	-- migrate settings from old mod versions
	if settings.version == nil then
		settings.version                = "1.0.0"
		settings.enableDragDistribute   = player.mod_settings["enable-ed"].value
		settings.takeFromCar            = player.mod_settings["take-from-car"].value
		settings.cleanupRequestOverflow = player.mod_settings["cleanup-logistic-request-overflow"].value
		settings.dropTrashToChests      = player.mod_settings["drop-trash-to-chests"].value
		settings.distributionDelay      = player.mod_settings["distribution-delay"].value
		settings.cleanupDropRange       = player.mod_settings["max-inventory-cleanup-drop-range"].value

		-- move custom trash to logistic slots
		if settings.customTrash and character:is("valid") then

			local slotCount = character.request_slot_count
			local slots = character:logisticSlots()
			if _(slots):is("empty") then slotCount = 0 end
			
			_(settings.customTrash)
				:wherepair(function(item) -- {item,count}
							return slots[item[1]] == nil and global.defaultTrash[item[1]] ~= item[2]
						end, 
						function(item,count)
							character.set_personal_logistic_slot(slotCount + 1, {
								name = item,
								min = 0,
								max = count,
							})
							slotCount = slotCount + 1
						end)

			settings.customTrash = nil
		end

		dlog("Player ("..player.name..") settings migrated from none to 1.0.0")
	end

	-- Add default logistic slot configuration
	if settings.version == "1.0.0" then
		settings.version = "1.0.2"

		dlog("Player ("..player.name..") settings migrated from 1.0.0 to 1.0.2")
	end

	if settings.version == "1.0.2" then
		settings.version = "1.0.3"

		if settings.dropTrashToChests == nil then 
			settings.dropTrashToChests = settings.dropTrashTFueloChests
		end
		settings.dropTrashTFueloChests = nil

		global.lastCharacters[player.index] = character:toPlain()
		if character:is("valid") then 
			setup.addDefaultLogisticSlots(player, character, character:logisticSlots())
		end

		dlog("Player ("..player.name..") settings migrated from 1.0.2 to 1.0.3")
	end

	--if settings.version == "0.3.x" then
		-- ...
	-- end
end

-- Detects when player gets new character assigned (hacky but works)
function setup.on_chunk_charted(event)
	local force          = event.force
	local lastCharts     = global.lastCharts
	local lastChart      = lastCharts[force.index]
	local lastCharacters = global.lastCharacters

	if lastChart == nil or lastChart ~= event.tick  then
		lastCharts[force.index] = event.tick

		for __,player in pairs(force.players) do
			player = _(player)
			local character = _(player.character or player.cutscene_character)
			-- dlog("char",lastCharacters[player.index],character:toPlain(), "same:",lastCharacters[player.index] == character:toPlain())

			if player:is("valid player") and player:setting("enableInventoryCleanupHotkey") and
			   character:is("valid") and lastCharacters[player.index] ~= character:toPlain() then
				
				local slots = character:logisticSlots()
				if _(slots):is("empty") then
					setup.addDefaultLogisticSlots(player, character, slots)
				end
			end
			global.lastCharacters[player.index] = character:toPlain()
		end
	end
end

function setup.on_player_respawned(event)
	local player = game.players[event.player_index]
	global.lastCharacters[event.player_index] = player.character or player.cutscene_character
end

function setup.addDefaultLogisticSlots(player, character, slots)
	local slotCount = character.request_slot_count
	if _(slots):is("empty") then slotCount = 0 end
	
	_({
		["wood"]               = 1,
		["coal"]               = 0,
		["stone"]              = 1,
		["iron-plate"]         = 4,
		["copper-plate"]       = 4,
		["steel-plate"]        = 4,
		["electronic-circuit"] = 2,
		["advanced-circuit"]   = 2,
	})
		:wherepair(
			function(item) -- {item,count}
				return slots[item[1]] == nil and 
						global.defaultTrash[item[1]] ~= item[2] and
						game.item_prototypes[item[1]]
			end, 
			function(item,count)
				character.set_personal_logistic_slot(slotCount + 1, {
					name = item,
					min = 0,
					max = count * game.item_prototypes[item].stack_size,
				})
				slotCount = slotCount + 1
			end)

	settings.customTrash = nil

	if not util.hasRobotsEnabled(character.force) then
		character.character_personal_logistic_requests_enabled = false
	end
end

function setup.on_research_finished(event)
	if util.enablesRobots(event.research) then
		for __,player in pairs(event.research.force.players) do
			if _(player):is("valid player") then
				local character = _(player.character or player.cutscene_character)
				if character:is("valid") then
					character.character_personal_logistic_requests_enabled = true
				end
			end
		end
	end
end

function setup.on_force_created(event)
	setup.enableLogisticsTab(event.force or event.destination)
end

setup.on_forces_merged = setup.on_force_created
setup.on_technology_effects_reset = setup.on_force_created

function setup.enableLogisticsTab(force)
 if force.technologies["enable-logistics-tab"] then
        force.technologies["enable-logistics-tab"].researched = true
    end
end

function setup.generateTrashItemList()
	local items = {}
	
	for name,item in pairs(game.item_prototypes) do
		if not (item.place_result or item.place_as_equipment_result or item.has_flag("hidden")) then -- or item.place_as_tile_result
			local default = defaultTrash[name] or defaultTrash[item.subgroup.name] or defaultTrash[item.group.name]
			
			if default and default ~= "ignore" then
				if item.fuel_category and not defaultTrash[name] then -- fuels default to 2 stacks as desired amount
					items[name] = 2 * item.stack_size
				else
					items[name] = default * item.stack_size
				end
			end
		end
	end
	
	return items
end

function setup.on_load()
	metatables.refresh(global)
end

return setup
