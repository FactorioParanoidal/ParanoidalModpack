-- Sets up the global table and parses settings

local setup = {}
local util = scripts.util
local metatables = scripts.metatables
local defaultTrash = require("default-trash")
local config = require("config")

local helpers = scripts.helpers
local _ = helpers.on

function setup.on_init()
	storage.cache = storage.cache or {}
	storage.distrEvents = storage.distrEvents or {}
	storage.settings = storage.settings or {}
	storage.defaultTrash = setup.generateTrashItemList()
	
	storage.remoteIgnoredEntities = storage.remoteIgnoredEntities or {}
	storage.allowedEntities = _(prototypes.entity)
								:where(function(prototype)
									return util.hasInventory(prototype) and 
										   not config.ignoredEntities[prototype.type] and 
										   not config.ignoredEntities[prototype.name]
								end)
								:map(function(name)
									return name, true
								end)
								:toPlain()

	-- GUI events are saved in storage.guiEvents["EVENT NAME"][PLAYER INDEX][GUI ELEMENT INDEX]
	storage.guiEvents = storage.guiEvents or 
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
	storage.fuelList = _(prototypes.item)
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
	storage.ammoList = _(prototypes.item)
						:where("ammo")
						:toArray()
						:groupBy(function(__,prototype)
							return prototype.ammo_category.name
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
	storage.cache[index] = storage.cache[index] or {}
	storage.cache[index].items = storage.cache[index].items or {}
	storage.cache[index].markers = storage.cache[index].markers or {}
	metatables.use(storage.cache[index].markers, "entityAsIndex")
	storage.cache[index].entities = storage.cache[index].entities or {}
	metatables.use(storage.cache[index].entities, "entityAsIndex")
end

function setup.migrateSettings(player)
	local settings = storage.settings[player.index] or {}
	storage.settings[player.index] = settings

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

		if player:is("valid") then
			local logisticPoint = _(player:requesterPoint())

			-- move custom trash to logistic slots
			if settings.customTrash and logisticPoint:is("valid") then
				
				local section = logisticPoint.add_section("Even Distribution (migrated settings)")
				local slotCount = 1
				
				_(settings.customTrash)
					:wherepair(function(item) -- {item,count}
								return storage.defaultTrash[item[1]] ~= item[2]
							end, 
							function(item,count)
								section.set_slot(slotCount, {
									name = item,
									min = 0,
									max = count,
								})
								slotCount = slotCount + 1
							end)

				settings.customTrash = nil
			end

			-- add default logistic slots
			if player:setting("enableInventoryCleanupHotkey") and _(player:logisticSlots()):is("empty") then 
				setup.addDefaultLogisticSlots(player)
			end
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

		dlog("Player ("..player.name..") settings migrated from 1.0.2 to 1.0.3")
	end

	if settings.version == "1.0.3" then
		settings.version = "1.0.8"

		storage.lastCharts = nil
		storage.lastCharacters = nil

		dlog("Player ("..player.name..") settings migrated from 1.0.3 to 1.0.8")
	end

	--if settings.version == "0.3.x" then
		-- ...
	-- end
end

function setup.addDefaultLogisticSlots(player)
	local logisticPoint = _(player:requesterPoint())
	
	if logisticPoint:is("valid") then
		local slotCount = 1
		local section = logisticPoint.add_section("Even Distribution (default settings)")
		-- section.active = false
		logisticPoint.enabled = false

		_(config.defaultLogisticSlots)
			:wherepair(
				function(item) -- {1=item,2=count}
					local prototype = prototypes.item[item[1]]
					return prototype and storage.defaultTrash[item[1]] ~= item[2] * prototype.stack_size
				end,
				function(item,count)
					section.set_slot(slotCount, {
						value = item,
						min = 0,
						max = count * prototypes.item[item].stack_size,
					})
					slotCount = slotCount + 1
				end)
	end
end

function setup.on_force_created(event)
	setup.enableLogisticsTab(event.force or event.destination)
end

setup.on_forces_merged = setup.on_force_created
setup.on_technology_effects_reset = setup.on_force_created

function setup.on_runtime_mod_setting_changed(event)
	if event.setting == "disable-inventory-cleanup" then

		for _,force in pairs(game.forces) do
			setup.enableLogisticsTab(force) 
		end

		-- -- add default logistic slots when enabling shift+c (if all slots are empty)
		-- if settings.global["disable-inventory-cleanup"].value == false then
			
		-- 	for __,player in pairs(game.players) do
		-- 		local player = _(player)
		-- 		if player:is("valid") and 
		-- 		   player:setting("enableInventoryCleanupHotkey") and 
		-- 		   _(player:logisticSlots()):is("empty") then 

		-- 			setup.addDefaultLogisticSlots(player)
		-- 		end
		-- 	end
		-- end
	end
end

function setup.on_research_finished(event)
	setup.enableLogisticsTab(event.research.force)
end

setup.on_research_reversed = setup.on_research_finished
setup.on_research_started  = setup.on_research_finished

function setup.enableLogisticsTab(force)
 	if force.technologies["enable-logistics-tab"] and not setup.hasLogisticSlots(force) then
		local enabled = not settings.global["disable-inventory-cleanup"].value
        force.technologies["enable-logistics-tab"].researched = enabled
    end
end

function setup.hasLogisticSlots(force)
	for _,tech in pairs(force.technologies) do
		if tech.researched and tech.name ~= "enable-logistics-tab" then
			for _,effect in pairs(tech.prototype.effects) do
				if effect.type == "character-logistic-requests" then
					if effect.modifier then return true end
				end
			end
		end
	end

	return false
end

function setup.generateTrashItemList()
	local items = {}
	
	for name,item in pairs(prototypes.item) do
		if not (item.place_result or item.place_as_equipment_result or item.hidden) then -- or item.place_as_tile_result
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
	metatables.refresh(storage)
end

return setup
