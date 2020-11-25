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
		setup.setupPlayerGlobalTable(player_index, player)
	end
end

setup.on_configuration_changed = setup.on_init

function setup.on_player_created(event)
	setup.setupPlayerGlobalTable(event.player_index)
end

function setup.setupPlayerGlobalTable(player_index, player)
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

	-- default values
	if settings.distributionMode == nil                     then settings.distributionMode = "distribute" end
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
	if settings.dropTrashToChests == nil       		then settings.dropTrashTFueloChests = true end
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
		if settings.customTrash and 
		   player:has("valid", "character") and 
		   player.character_personal_logistic_requests_enabled then

			local slotCount = player.character.request_slot_count
			local slots = _(player.character):logisticSlots()
			
			_(settings.customTrash)
				:where(function(item,count)
							return slots[item] == nil and global.defaultTrash[item] ~= count
						end, 
						function(item,count)
							player.set_personal_logistic_slot(slotCount + 2, {
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
	--if settings.version == "0.3.x" then
		-- ...
	-- end
end

function setup.on_force_created(event)
	setup.enableLogisticsTab(event.force or event.destination)
end

setup.on_forces_merged = setup.on_force_created
setup.on_technology_effects_reset = setup.on_force_created

function setup.enableLogisticsTab(force)
	force.technologies["enable-logistics-tab"].researched = true
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
					items[name] = default
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