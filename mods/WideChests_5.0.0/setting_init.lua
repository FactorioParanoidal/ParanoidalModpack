--- @alias setting_allowed_value
--- | 'none'
--- | 'chest'
--- | 'warehouse'
--- | 'chest-warehouse'
--- | 'trashdump'
--- | 'chest-trashdump'
--- | 'warehouse-trashdump'
--- | 'chest-warehouse-trashdump'

--- @alias register_options
--- | { disable_chest?: boolean, disable_warehouse?: boolean, disable_trashdump?: boolean }
--- | { default_value?: setting_allowed_value, order?: string }
--- | { size_settings?: boolean, inventory_settings?: boolean, threshold_setting?: boolean, circuit_connection_setting?: boolean }

--- Creates a mod setting for configuring how `chest_name` should be mergeable.
--- Also allows to configure other mod settings for each chest type separately.
--- @param chest_name string Name of the mergeable chest (for example 'wooden-chest', 'iron-chest' or 'steel-chest')
--- @param options register_options | nil
function MergingChests.create_mergeable_chest_setting(chest_name, options)
	options = options or {}

    local allowed_values = {
        'none'
    }
    if not options.disable_chest then
        table.insert(allowed_values, 'chest')
    end
    if not options.disable_warehouse then
        table.insert(allowed_values, 'warehouse')
    end
    if not options.disable_trashdump then
        table.insert(allowed_values, 'trashdump')
    end
    if not options.disable_chest and not options.disable_warehouse then
        table.insert(allowed_values, 'chest-warehouse')
    end
    if not options.disable_chest and not options.disable_trashdump then
        table.insert(allowed_values, 'chest-trashdump')
    end
    if not options.disable_warehouse and not options.disable_trashdump then
        table.insert(allowed_values, 'warehouse-trashdump')
    end
    if not options.disable_chest and not options.disable_warehouse and not options.disable_trashdump then
        table.insert(allowed_values, 'chest-warehouse-trashdump')
    end

    if table_size(allowed_values) <= 1 then
        error('All mergeable modes are disabled for '..chest_name)
    end

    local has_custom_settings = options.size_settings or options.inventory_settings or options.threshold_setting or options.circuit_connection_setting

    data:extend({
        {
            name = MergingChests.chest_specific_setting_name(MergingChests.setting_names.mergeable_chest, chest_name),
            type = 'string-setting',
            setting_type = 'startup',
            default_value = options.default_value or allowed_values[#allowed_values],
            allowed_values = allowed_values,
            order = (has_custom_settings and '99-' or '01-')..(options.order or chest_name)..'-01'
        }
    })

    if options.size_settings then
        data:extend({
            {
                name = MergingChests.chest_specific_setting_name(MergingChests.setting_names.max_width, chest_name),
                type = 'int-setting',
                setting_type = 'startup',
                minimum_value = 2,
                default_value = 10,
                order = '99-'..(options.order or chest_name)..'-02'
            },
            {
                name = MergingChests.chest_specific_setting_name(MergingChests.setting_names.max_height, chest_name),
                type = 'int-setting',
                setting_type = 'startup',
                minimum_value = 2,
                default_value = 10,
                order = '99-'..(options.order or chest_name)..'-03'
            },
            {
                name = MergingChests.chest_specific_setting_name(MergingChests.setting_names.max_area, chest_name),
                type = 'int-setting',
                setting_type = 'startup',
                minimum_value = 2,
                default_value = 100,
                order = '99-'..(options.order or chest_name)..'-04'
            },
            {
                name = MergingChests.chest_specific_setting_name(MergingChests.setting_names.whitelist, chest_name),
                type = 'string-setting',
                setting_type = 'startup',
                default_value = 'NxN',
                allow_blank = true,
                order = '99-'..(options.order or chest_name)..'-05'
            }
        })
    end

    if options.inventory_settings then
        data:extend({
            {
                name = MergingChests.chest_specific_setting_name(MergingChests.setting_names.inventory_size_multiplier, chest_name),
                type = 'double-setting',
                setting_type = 'startup',
                minimum_value = 0,
                default_value = 1.0,
                order = '99-'..(options.order or chest_name)..'-06'
            },
            {
                name = MergingChests.chest_specific_setting_name(MergingChests.setting_names.inventory_size_limit, chest_name),
                type = 'int-setting',
                setting_type = 'startup',
                minimum_value = 1,
                maximum_value = 65535,
                default_value = 1000,
                order = '99-'..(options.order or chest_name)..'-07'
            }
        })
    end

    if options.threshold_setting then
        data:extend({
            {
                name = MergingChests.chest_specific_setting_name(MergingChests.setting_names.warehouse_threshold, chest_name),
                type = 'int-setting',
                setting_type = 'startup',
                minimum_value = 2,
                default_value = 5,
                order = '99-'..(options.order or chest_name)..'-08'
            }
        })
    end

    if options.circuit_connection_setting then
        data:extend({
            {
                name = MergingChests.chest_specific_setting_name(MergingChests.setting_names.circuit_connector_position, chest_name),
                type = 'string-setting',
                setting_type = 'startup',
                default_value = 'center-center',
                allowed_values = {
                    'center-center',
                    'right-top',
                    'right-middle',
                    'right-bottom',
                    'left-top',
                    'left-middle',
                    'left-bottom',
                    'bottom-right',
                    'bottom-middle',
                    'bottom-left'
                },
                order = '99-'..(options.order or chest_name)..'-09'
            }
        })
    end
end

--- Deletes specified chest name settings. Useful for other mods which remove some type of chest
--- @param chest_name string
function MergingChests.delete_chest_name_settings(chest_name)
    data.raw['string-setting'][MergingChests.chest_specific_setting_name(MergingChests.setting_names.mergeable_chest, chest_name)] = nil
    data.raw['int-setting'][MergingChests.chest_specific_setting_name(MergingChests.setting_names.max_width, chest_name)] = nil
    data.raw['int-setting'][MergingChests.chest_specific_setting_name(MergingChests.setting_names.max_height, chest_name)] = nil
    data.raw['int-setting'][MergingChests.chest_specific_setting_name(MergingChests.setting_names.max_area, chest_name)] = nil
    data.raw['string-setting'][MergingChests.chest_specific_setting_name(MergingChests.setting_names.whitelist, chest_name)] = nil
    data.raw['int-setting'][MergingChests.chest_specific_setting_name(MergingChests.setting_names.inventory_size_limit, chest_name)] = nil
    data.raw['double-setting'][MergingChests.chest_specific_setting_name(MergingChests.setting_names.inventory_size_multiplier, chest_name)] = nil
    data.raw['int-setting'][MergingChests.chest_specific_setting_name(MergingChests.setting_names.warehouse_threshold, chest_name)] = nil
    data.raw['string-setting'][MergingChests.chest_specific_setting_name(MergingChests.setting_names.circuit_connector_position, chest_name)] = nil
end
