--- @type MigrationsTable
local migrations = {
    ["7.3.0"] = function()
        -- Update the format of the ModuleConfig list for all presets

        local function entry_matches_module(entry, module)
            if not entry then return false end
            if not entry.module or not module then
                if not entry.module and not module then
                    return true
                else
                    return false
                end
            end
            return entry.module.name == module.name and entry.module.quality == module.quality
        end

        local function fix_config(config)
            local new_list = {}
            local index = 0
            for _, module in pairs(config.module_list) do
                if not module then module = nil end -- normalize
                index = index + 1
                local entry = new_list[index]
                if not entry_matches_module(entry, module) then
                    -- Add a new entry
                    entry = {
                        count = 1,
                        module = module,
                    }
                    table.insert(new_list, entry)
                else
                    -- Just increment the count of the last entry
                    entry.count = entry.count + 1
                end
            end
            config.module_list = new_list
        end

        local function fix_preset(preset)
            for _, config in pairs(preset.default.configs) do
                fix_config(config)
            end
            for _, row in pairs(preset.rows) do
                for _, config in pairs(row.module_configs.configs) do
                    fix_config(config)
                end
            end
        end

        for _, player in pairs(game.players) do
            local pdata = storage._pdata[player.index]
            for _, preset in pairs(pdata.saved_presets) do
                fix_preset(preset)
            end
        end
        for _, work in pairs(storage.delayed_work) do
            fix_preset(work.preset)
        end
    end,
}

return migrations
