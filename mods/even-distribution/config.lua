local config = {}

config.defaultLogisticSlots = -- in stacks, gets added to logistics slots in new games
{
    ["wood"]               = 1,
    ["coal"]               = 0,
    ["stone"]              = 1,
    ["iron-plate"]         = 4,
    ["copper-plate"]       = 4,
    ["steel-plate"]        = 4,
    ["electronic-circuit"] = 2,
    ["advanced-circuit"]   = 2,
}

config.colors = -- flying text colors
{
	insufficientItems = { r = 1, g = 0, b = 0 }, -- red
	targetFull = { r = 1, g = 1, b = 0 }, -- yellow
	default = { r = 1, g = 1, b = 1 }, -- white
}

config.ignoredEntities = -- entity type or name
{ 
    ["player"] = true, 
    ["character"] = true, 
    ["character-corpse"] = true, 
    ["factory-overlay-controller"] = true,

    ["transport-belt"] = true, 
    ["underground-belt"] = true, 
    ["splitter"] = true, 
    ["loader"] = true, 
    ["logistic-robot"] = true, 
    ["construction-robot"] = true, 
    ["simple-entity"] = true, 
    ["simple-entity-with-force"] = true, 
    ["simple-entity-with-owner"] = true,
}

config.rangeMultiplier = 3 -- inventory cleanup drop range multiplier

config.fuelLimitProfiles = 
{
    name          = "fuel_drag_limit",
    -- enableSetting = "enableDragFuelLimit",
    typeSetting   = "fuelLimitType",
    valueSetting  = "fuelLimit",
    typeLocale    = "fuel-limit-type",
    tooltipLocale = "fuel-limit-tooltip",

    stacks = {
        min  = 0,
        max  = 1,
        step = 0.1,
        next = "items",
    },
    items = {
        min  = 0,
        max  = 200,
        step = 1,
        next = "mj",
    },
    mj = {
        min  = 0,
        max  = 1000,
        step = 1,
        next = "stacks",
    },
}

config.ammoLimitProfiles = 
{
    name          = "ammo_drag_limit",
    -- enableSetting = "enableDragAmmoLimit",
    typeSetting   = "ammoLimitType",
    valueSetting  = "ammoLimit",
    typeLocale    = "ammo-limit-type",
    tooltipLocale = "ammo-limit-tooltip",

    stacks = {
        min  = 0,
        max  = 1,
        step = 0.1,
        next = "items",
    },
    items = {
        min  = 0,
        max  = 200,
        step = 1,
        next = "stacks",
    },
}

return config