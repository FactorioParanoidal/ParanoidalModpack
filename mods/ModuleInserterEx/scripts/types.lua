--- @class (exact) GlobalData
--- @field delayed_work DelayedWorkData[]
--- @field type_to_slot_bonus {[string]:int} Entity types to their highest module slot bonus from quality
--- @field name_to_slot_count {[string]:int} Name of all entities mapped to their module slot count
--- @field min_slot_count int Number of slots the entity with the fewest has
--- @field max_slot_count int Number of slots the entity with the most has (used for default config slot count)
--- @field use_slot_count_target boolean Whether the slot count target is available (disabled when everything has the same number of slots)
--- @field module_entities string[] all entities that have valid module slots
--- @field _pdata {[int]:PlayerConfig}
--- @field nth_tick_registered int? The tick that the on_nth_tick delayed_creation listener is registered for, or nil if not registered

--- @class (exact) PlayerConfig
--- @field active_config PresetConfig One of the presets in saved_presets (reference to the same table)
--- @field saved_presets SavedPresets
--- @field gui PlayerGui
--- @field naming PresetConfig? preset currently being renamed
--- @field closing boolean? Is the main window currently closing?
--- @field pinned boolean Is the gui pinned
--- @field cursor boolean True when the module inserter item is in this players cursor

--- @alias SavedPresets PresetConfig[]

--- @alias ConfigByEntity {[string]: ModuleConfigSet}

--- @class (exact) PlayerGui
--- @field main PlayerGuiMain
--- @field presets PlayerGuiPresets
--- @field import PlayerGuiImport?

--- @class (exact) PlayerGuiMain
--- @field window LuaGuiElement
--- @field pin_button LuaGuiElement
--- @field scroll LuaGuiElement
--- @field module_config_table LuaGuiElement
--- @field default_checkbox LuaGuiElement
--- @field default_module_set LuaGuiElement
--- @field default_module_set_holder LuaGuiElement

--- @class (exact) PlayerGuiPresets
--- @field preset_pane LuaGuiElement

--- @class (exact) PlayerGuiImport
--- @field textbox LuaGuiElement
--- @field window LuaGuiElement


--- @class (exact) PresetConfig
--- @field name string This presets name
--- @field default ModuleConfigSet
--- @field use_default boolean
--- @field rows RowConfig[]

--- @class (exact) RowConfig
--- @field target TargetConfig Target entities to apply these modules to
--- @field module_configs ModuleConfigSet set of module configs for this row

--- @class (exact) TargetConfig Requires at least one entity or recipe. If both are specified, then both must match to be included.
--- @field show_details boolean Whether to show all config options for this target in the GUI
--- @field entities string[] List of entities (assemblers) to apply the config to
--- @field recipes PrototypeWithQuality[] List of recipes to apply the config to
--- @field slot_count int? Only machines with this number of module slots

--- @class (exact) ModuleConfigSet
--- @field configs ModuleConfig[]

--- @class (exact) ModuleConfig
--- @field module_list ModuleConfigEntry[] array of modules in this config
--- @field categories {[string]: string} category to module prototype name of modules contained in the config
--- @field effects {[string]: string} positive effects to module prototype name of modules contained in the config

--- @class (exact) ModuleConfigEntry
--- @field count int number of this module
--- @field module BlueprintItemIDAndQualityIDPair? Module info, or nil for no module (empty slot)

--- @class (exact) MiEventInfo
--- @field event flib.GuiEventData
--- @field player LuaPlayer
--- @field pdata PlayerConfig

--- @class (exact) DelayedWorkData
--- @field preset PresetConfig
--- @field entities LuaEntity[]
--- @field player_index int
--- @field clear boolean If true, remove all current modules
--- @field result_messages {[LocalisedString]: LocalisedString}
--- @field entity_recipe_to_config_cache {[string]: ModuleConfig|true|false}

--- @class (exact) ModuleRowTags
--- @field row_index int index of the row, 0 is the default row
--- @field module_row_index int index of the module row this is part of

--- @class (exact) ModuleButtonTags
--- @field row_index int index of the row, 0 is the default row
--- @field module_row_index int index of the module row this is part of
--- @field slot_index int index of the slot

--- @class (exact) GroupedModuleInputTags
--- @field row_index int index of the row, 0 is the default row
--- @field module_row_index int index of the module row this is part of
--- @field group_index int index of the group

--- @class (exact) TargetFrameTags
--- @field row_index int index of the row, 0 is the default row

--- @class (exact) TargetButtonTags
--- @field row_index int index of the row, 0 is the default row
--- @field slot_index int index of the slot

--- @class (exact) PresetRowTags
--- @field preset_index int index of the preset

local types = {}


--- @param name string
--- @return PresetConfig
function types.make_preset_config(name)
    --- @type PresetConfig
    return {
        name = name,
        use_default = false,
        default = types.make_module_config_set(),
        rows = {
            types.make_row_config()
        },
    }
end

--- @return RowConfig
function types.make_row_config()
    --- @type RowConfig
    return {
        target = types.make_target_config(),
        module_configs = types.make_module_config_set(),
    }
end

--- @return TargetConfig
function types.make_target_config()
    --- @type TargetConfig
    return {
        show_details = false,
        entities = {},
        recipes = {},
    }
end

--- @return ModuleConfigSet
function types.make_module_config_set()
    --- @type ModuleConfigSet
    return {
        configs = { types.make_module_config() },
    }
end

--- @return ModuleConfig
function types.make_module_config()
    --- @type ModuleConfig
    return {
        module_list = {},
        categories = {},
        effects = {},
    }
end

--- @return ModuleConfigEntry
function types.make_module_config_entry()
    --- @type ModuleConfigEntry
    return {
        count = 0,
        module = nil,
    }
end

return types
