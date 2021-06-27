if not (mods["angelsaddons-storage"] and angelsmods.addons.storage.warehouses) then return end

-- Check whether we're using legacy inventories
local legacy = settings.startup["extangels-legacy-inventory-sizes"].value

-- Inventory size adjustments
local inventory_sizes = {
    [1] = {
        warehouse = legacy and 1728 or 768,
        passive_provider = legacy and 1900 or 418,
        active_provider = legacy and 1900 or 512,
        storage = legacy and 1900 or 768,
        buffer = legacy and 1900 or 512,
        requester = legacy and 1900 or 418,
    },
    [2] = {
        warehouse = legacy and 3072 or 884,
        passive_provider = legacy and 3378 or 480,
        active_provider = legacy and 3378 or 588,
        storage = legacy and 3378 or 884,
        buffer = legacy and 3378 or 588,
        requester = legacy and 3378 or 480,
    },
    [3] = {
        warehouse = legacy and 4416 or 1148,
        passive_provider = legacy and 4856 or 624,
        active_provider = legacy and 4856 or 766,
        storage = legacy and 4856 or 1148,
        buffer = legacy and 4856 or 766,
        requester = legacy and 4856 or 624,
    },
    [4] = {
        warehouse = legacy and 6035 or 1664,
        passive_provider = legacy and 6336 or 906,
        active_provider = legacy and 6336 or 1110,
        storage = legacy and 6336 or 1664,
        buffer = legacy and 6336 or 1110,
        requester = legacy and 6336 or 906,
    }
}

-- Override the inventory size of the standard warehouses
if data.raw["container"]["angels-warehouse"] then
    data.raw["container"]["angels-warehouse"].inventory_size = inventory_sizes[1].warehouse
end

if data.raw["logistic-container"]["angels-warehouse-passive-provider"] then
    data.raw["logistic-container"]["angels-warehouse-passive-provider"].inventory_size = inventory_sizes[1].passive_provider
end

if data.raw["logistic-container"]["angels-warehouse-active-provider"] then
    data.raw["logistic-container"]["angels-warehouse-active-provider"].inventory_size = inventory_sizes[1].active_provider
end

if data.raw["logistic-container"]["angels-warehouse-storage"] then
    data.raw["logistic-container"]["angels-warehouse-storage"].inventory_size = inventory_sizes[1].storage
end

if data.raw["logistic-container"]["angels-warehouse-requester"] then
    data.raw["logistic-container"]["angels-warehouse-requester"].inventory_size = inventory_sizes[1].requester
end

if data.raw["logistic-container"]["angels-warehouse-buffer"] then
    data.raw["logistic-container"]["angels-warehouse-buffer"].inventory_size = inventory_sizes[1].buffer
end

local tint = angelsmods.addons.storage.number_tint

local warehouse_buildings = {
    -- STANDARD WAREHOUSES
    -- Warehouse 2
    ["warehouse-mk2"] = {
        source = "angels-warehouse",
        type = "container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse.png",
        tier = 2,
        order = "a[warehouse-mk2]",
        subgroup = "angels-warehouses-2",
        next_upgrade = "warehouse-mk3",
        inventory_size = inventory_sizes[2].warehouse,
    },

    -- Warehouse 3
    ["warehouse-mk3"] = {
        source = "angels-warehouse",
        type = "container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse.png",
        tier = 3,
        order = "a[warehouse-mk3]",
        subgroup = "angels-warehouses-3",
        next_upgrade = "warehouse-mk4",
        inventory_size = inventory_sizes[3].warehouse,
    },

    -- Warehouse 4
    ["warehouse-mk4"] = {
        source = "angels-warehouse",
        type = "container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse.png",
        tier = 4,
        order = "a[warehouse-mk4]",
        subgroup = "angels-warehouses-4",
        inventory_size = inventory_sizes[4].warehouse,
    },

    -- LOGISTIC WAREHOUSES
    -- Warehouse passive provider 2
    ["warehouse-passive-provider-mk2"] = {
        source = "angels-warehouse-passive-provider",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-pprovider.png",
        tier = 2,
        order = "b[warehouse-passive-provider-mk2]",
        subgroup = "angels-warehouses-2",
        next_upgrade = "warehouse-passive-provider-mk3",
        inventory_size = inventory_sizes[2].passive_provider,
    },

    -- Warehouse passive provider 3
    ["warehouse-passive-provider-mk3"] = {
        source = "angels-warehouse-passive-provider",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-pprovider.png",
        tier = 3,
        order = "b[warehouse-passive-provider-mk3]",
        subgroup = "angels-warehouses-3",
        next_upgrade = "warehouse-passive-provider-mk4",
        inventory_size = inventory_sizes[3].passive_provider,
    },

    -- Warehouse passive provider 4
    ["warehouse-passive-provider-mk4"] = {
        source = "angels-warehouse-passive-provider",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-pprovider.png",
        tier = 4,
        order = "b[warehouse-passive-provider-mk4]",
        subgroup = "angels-warehouses-4",
        inventory_size = inventory_sizes[4].passive_provider,
    },

    -- Warehouse active provider 2
    ["warehouse-active-provider-mk2"] = {
        source = "angels-warehouse-active-provider",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-aprovider.png",
        tier = 2,
        order = "c[warehouse-active-provider-mk2]",
        subgroup = "angels-warehouses-2",
        next_upgrade = "warehouse-active-provider-mk3",
        inventory_size = inventory_sizes[2].active_provider,
    },

    -- Warehouse active provider 3
    ["warehouse-active-provider-mk3"] = {
        source = "angels-warehouse-active-provider",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-aprovider.png",
        tier = 3,
        order = "c[warehouse-active-provider-mk3]",
        subgroup = "angels-warehouses-3",
        next_upgrade = "warehouse-active-provider-mk4",
        inventory_size = inventory_sizes[3].active_provider,
    },

    -- Warehouse active provider 4
    ["warehouse-active-provider-mk4"] = {
        source = "angels-warehouse-active-provider",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-aprovider.png",
        tier = 4,
        order = "c[warehouse-active-provider-mk4]",
        subgroup = "angels-warehouses-4",
        inventory_size = inventory_sizes[4].active_provider,
    },

    -- Warehouse storage 2
    ["warehouse-storage-mk2"] = {
        source = "angels-warehouse-storage",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-storage.png",
        tier = 2,
        order = "d[warehouse-storage-mk2]",
        subgroup = "angels-warehouses-2",
        next_upgrade = "warehouse-storage-mk3",
        inventory_size = inventory_sizes[2].storage,
    },

    -- Warehouse storage 3
    ["warehouse-storage-mk3"] = {
        source = "angels-warehouse-storage",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-storage.png",
        tier = 3,
        order = "d[warehouse-storage-mk3]",
        subgroup = "angels-warehouses-3",
        next_upgrade = "warehouse-storage-mk4",
        inventory_size = inventory_sizes[3].storage,
    },

    -- Warehouse storage 4
    ["warehouse-storage-mk4"] = {
        source = "angels-warehouse-storage",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-storage.png",
        tier = 4,
        order = "d[warehouse-storage-mk4]",
        subgroup = "angels-warehouses-4",
        inventory_size = inventory_sizes[4].storage,
    },

    -- Warehouse requester 2
    ["warehouse-requester-mk2"] = {
        source = "angels-warehouse-requester",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-requester.png",
        tier = 2,
        order = "f[warehouse-requester-mk2]",
        subgroup = "angels-warehouses-2",
        next_upgrade = "warehouse-requester-mk3",
        inventory_size = inventory_sizes[2].requester,
    },

    -- Warehouse requester 3
    ["warehouse-requester-mk3"] = {
        source = "angels-warehouse-requester",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-requester.png",
        tier = 3,
        order = "f[warehouse-requester-mk3]",
        subgroup = "angels-warehouses-3",
        next_upgrade = "warehouse-requester-mk4",
        inventory_size = inventory_sizes[3].requester,
    },

    -- Warehouse requester 4
    ["warehouse-requester-mk4"] = {
        source = "angels-warehouse-requester",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-requester.png",
        tier = 4,
        order = "f[warehouse-requester-mk4]",
        subgroup = "angels-warehouses-4",
        inventory_size = inventory_sizes[4].requester,
    },

    -- Warehouse buffer 2
    ["warehouse-buffer-mk2"] = {
        source = "angels-warehouse-buffer",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-buffer.png",
        tier = 2,
        order = "e[warehouse-buffer-mk2]",
        subgroup = "angels-warehouses-2",
        next_upgrade = "warehouse-buffer-mk3",
        inventory_size = inventory_sizes[2].buffer,
    },

    -- Warehouse buffer 3
    ["warehouse-buffer-mk3"] = {
        source = "angels-warehouse-buffer",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-buffer.png",
        tier = 3,
        order = "e[warehouse-buffer-mk3]",
        subgroup = "angels-warehouses-3",
        next_upgrade = "warehouse-buffer-mk4",
        inventory_size = inventory_sizes[3].buffer,
    },

    -- Warehouse buffer 4
    ["warehouse-buffer-mk4"] = {
        source = "angels-warehouse-buffer",
        type = "logistic-container",
        icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-buffer.png",
        tier = 4,
        order = "e[warehouse-buffer-mk4]",
        subgroup = "angels-warehouses-4",
        inventory_size = inventory_sizes[4].buffer,
    },
}

for name, params in pairs(warehouse_buildings) do
    -- Check for source entity
    local source_entity = data.raw[params.type][params.source]
    if not source_entity then goto continue end

    -- Fetch the icon with numeral overlay
    local icons = extangels.numeral_tier({icon = params.icon, icon_size = params.icon_size or 32}, params.tier, params.tint or tint)

    data:extend({
        -- Create the item
        {
            type = "item",
            name = name,
            icons = icons,
            subgroup = params.subgroup or nil,
            order = params.order,
            place_result = name,
            stack_size = params.stack_size or 10,
        },

        -- Create the entity
        util.merge{source_entity, {
            name = name,
            minable = {result = name},
            next_upgrade = params.next_upgrade or nil,
            inventory_size = params.inventory_size,
            subgroup = params.subgroup,
        }},
    })

    -- Set entity icon
    data.raw[params.type][name].icons = icons

    -- Continue
    ::continue::
end

-- ANGEL FIXES
local base_warehouses = {
    ["angels-warehouse"] = {icon = "__angelsaddons-storage__/graphics/icons/warehouse.png", type = "container"},
    ["angels-warehouse-passive-provider"] = {icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-pprovider.png", type = "logistic-container"},
    ["angels-warehouse-active-provider"] = {icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-aprovider.png", type = "logistic-container"},
    ["angels-warehouse-storage"] = {icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-storage.png", type = "logistic-container"},
    ["angels-warehouse-requester"] = {icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-requester.png", type = "logistic-container"},
    ["angels-warehouse-buffer"] = {icon = "__angelsaddons-storage__/graphics/icons/warehouse-log-buffer.png", type = "logistic-container"},
}

for name, params in pairs(base_warehouses) do
    local item = data.raw.item[name]
    local entity = data.raw[params.type][name]

    if item then
        item.icons = extangels.numeral_tier({icon = params.icon, icon_size = 32}, 1, tint)
    end

    if entity then
        entity.icons = extangels.numeral_tier({icon = params.icon, icon_size = 32}, 1, tint)
    end
end







