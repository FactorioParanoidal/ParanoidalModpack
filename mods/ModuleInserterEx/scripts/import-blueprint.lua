local import_blueprint = {}

local flib_table = require("__flib__.table")

local util = require("scripts.util")
local types = require("scripts.types")


--- @class (exact) ImportRow
--- @field target ImportTargetConfig Target entities to apply these modules to
--- @field modules ImportModuleList set of module configs for this row

--- @class (exact) ImportTargetConfig
--- @field entities string[]
--- @field recipes PrototypeWithQuality[]
--- @field slots int

--- @alias ImportModuleList [BlueprintItemIDAndQualityIDPair?]

local function is_module_inventory(inventory)
    return inventory == defines.inventory.crafter_modules or
        inventory == defines.inventory.beacon_modules or
        inventory == defines.inventory.lab_modules or
        inventory == defines.inventory.mining_drill_modules
end

--- @param a BlueprintItemIDAndQualityIDPair?
--- @param b BlueprintItemIDAndQualityIDPair?
--- @return boolean
local function are_modules_equal(a, b)
    if (a == nil) ~= (b == nil) then return false end
    if a ~= nil and b ~= nil then
        if a.name ~= b.name or a.quality ~= b.quality then
            return false
        end
    end
    return true
end

--- @param table any
--- @param value any
--- @return boolean
local function table_contains_value(table, value)
    for _, entry in ipairs(table) do
        if type(entry) ~= "table" then
            if entry == value then
                return true
            end
        elseif flib_table.deep_compare(entry, value) then
            return true
        end
    end
    return false
end

--- @param base table
--- @param additions table add contents of this not already in base to base
local function combine_tables(base, additions)
    for _, item in ipairs(additions) do
        if not table_contains_value(base, item) then
            table.insert(base, item)
        end
    end
end

--- @param modules ImportModuleList
--- @param slots int
--- @return ModuleConfig
local function normalize_module_list(modules, slots)
    local conf = types.make_module_config()
    for i = 1, slots do
        local entry = types.make_module_config_entry()
        entry.count = 1
        entry.module = modules[i]
        table.insert(conf.module_list, entry)
    end
    util.normalize_module_config(slots, conf)
    return conf
end

--- @param a ImportRow
--- @param b ImportRow
--- @return boolean
local function are_row_config_modules_compatible(a, b)
    local slots = math.min(a.target.slots, b.target.slots)
    a = a.modules
    b = b.modules
    for i = 1, slots do
        if not are_modules_equal(a[i], b[i]) then
            return false
        end
    end
    return true
end

--- @param preset ImportRow[]
--- @param new_row ImportRow
local function add_row_config(preset, new_row)
    for _, row in ipairs(preset) do
        -- Combine with existing row if same entity and modules
        if row.target.entities[1] == new_row.target.entities[1] and are_row_config_modules_compatible(row, new_row) then
            combine_tables(row.target.recipes, new_row.target.recipes)
            if new_row.target.slots > row.target.slots then
                row.modules = new_row.modules
                row.target.slots = new_row.target.slots
            end
            return
        end
    end
    table.insert(preset, new_row)
end

--- @param preset ImportRow[]
local function combine_compatible_rows(preset)
    -- Combine rows with compatible modules and no recipes
    -- Could combine some rows with recipes, but that could get complicated
    for i = #preset, 1, -1 do
        local config = preset[i]
        if #config.target.recipes == 0 then
            for j = i - 1, 1, -1 do
                local other = preset[j]
                if #other.target.recipes == 0 and are_row_config_modules_compatible(config, other) then
                    combine_tables(other.target.entities, config.target.entities)
                    if config.target.slots > other.target.slots then
                        other.modules = config.modules
                        other.target.slots = config.target.slots
                    end
                    table.remove(preset, i)
                    goto continue
                end
            end
        end
        ::continue::
    end
end

--- @param preset ImportRow[]
local function remove_extraneous_recipes(preset)
    local entity_map = {}
    for i, row in ipairs(preset) do
        if next(row.target.entities) ~= nil then
            local arr = entity_map[row.target.entities[1]] or {}
            table.insert(arr, i)
            entity_map[row.target.entities[1]] = arr
        end
    end

    for _, indexes in pairs(entity_map) do
        if #indexes == 1 then
            preset[indexes[1]].target.recipes = {}
        else
            local max_count = 0
            local index_to_clear = 1
            for _, index in ipairs(indexes) do
                local recipe_count = #preset[index].target.recipes
                if recipe_count == 0 then
                    goto continue
                end
                if recipe_count > max_count then
                    max_count = recipe_count
                    index_to_clear = index
                end
            end
            preset[index_to_clear].target.recipes = {}
            ::continue::
        end
    end
end

--- @param preset ImportRow[]
local function reorder_rows(preset)
    -- Go from botton to top, moving any rows with recipes to the top
    local offset = 0
    for i = #preset, 1, -1 do
        local index = i + offset
        if #preset[index].target.recipes > 0 then
            local old = table.remove(preset, index)
            table.insert(preset, 1, old)
            offset = offset + 1
        end
    end
end

--- @param player LuaPlayer
--- @return PresetConfig|string
--- @nodiscard
function import_blueprint.import_blueprint(player)
    local name
    local ents
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.item then
        local bp = stack.item
        if bp then
            name = bp.label
            ents = bp.get_blueprint_entities()
        end
    elseif player.cursor_record and player.cursor_record.valid then
        --name = ??? Can't get the label for a record?
        ents = player.cursor_record.get_blueprint_entities()
    end

    if not ents then return "Invalid blueprint" end

    name = name or util.generate_random_name()
    --[[@type ImportRow[] ]]
    local import_preset = {}
    for _, ent in ipairs(ents) do
        local slots = storage.name_to_slot_count[ent.name]
        if slots ~= nil then
            --[[@type ImportRow]]
            local row_config = {
                target = {
                    entities = { ent.name },
                    recipes = {},
                    slots = slots,
                },
                modules = {},
            }
            if ent.recipe then
                table.insert(row_config.target.recipes, {
                    name = ent.recipe,
                    quality = ent.recipe_quality or "normal",
                })
            end

            if ent.items ~= nil then
                for _, item in ipairs(ent.items) do
                    for _, inv in ipairs(item.items.in_inventory) do
                        if is_module_inventory(inv.inventory) then
                            local inv_index = inv.stack + 1
                            row_config.modules[inv_index] = item.id
                            row_config.modules[inv_index].quality = row_config.modules[inv_index].quality or "normal"
                        end
                    end
                end
            end

            add_row_config(import_preset, row_config)
        end
    end

    remove_extraneous_recipes(import_preset)
    combine_compatible_rows(import_preset)

    reorder_rows(import_preset)

    local preset = types.make_preset_config(name)
    for i, row in ipairs(import_preset) do
        local row_config = types.make_row_config()
        row_config.target.entities = row.target.entities
        row_config.target.recipes = row.target.recipes
        row_config.module_configs.configs[1] = normalize_module_list(row.modules, row.target.slots)
        table.insert(preset.rows, row_config)
    end
    util.normalize_preset_config(preset)
    return preset
end

return import_blueprint
