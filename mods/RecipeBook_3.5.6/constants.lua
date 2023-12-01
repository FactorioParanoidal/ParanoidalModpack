local table = require("__flib__.table")

local constants = {}

constants.burner_classes = {
  "entity",
  "equipment",
}

constants.category_all_match = {
  science_pack = true,
}

constants.category_classes = {
  "entity_type",
  "equipment_category",
  "fuel_category",
  "group",
  "item_type",
  "recipe_category",
  "resource_category",
  "science_pack",
}

constants.category_class_plurals = {
  entity_type = "entity_types",
  equipment_category = "equipment_categories",
  fuel_category = "fuel_categories",
  group = "groups",
  item_type = "item_types",
  recipe_category = "recipe_categories",
  resource_category = "resource_categories",
  science_pack = "science_packs",
}

constants.classes = {
  "entity",
  "entity_type",
  "equipment",
  "equipment_category",
  "fluid",
  "fuel_category",
  "group",
  "item",
  "item_type",
  "recipe",
  "recipe_category",
  "resource",
  "resource_category",
  "science_pack",
  "technology",
}

constants.class_to_font_glyph = {
  entity = "E",
  entity_type = "G",
  equipment_category = "G",
  equipment = "H",
  fluid = "B",
  fuel_category = "G",
  group = "G",
  item = "C",
  item_type = "G",
  recipe_category = "G",
  recipe = "D",
  resource_category = "G",
  resource = "F",
  science_pack = "G",
  technology = "A",
}

constants.class_to_type = {
  entity = "entity",
  entity_type = false,
  equipment_category = false,
  equipment = "equipment",
  fluid = "fluid",
  fuel_category = false,
  group = "item-group",
  item = "item",
  item_type = false,
  recipe_category = false,
  recipe = "recipe",
  resource_category = false,
  resource = "entity",
  science_pack = "item",
  technology = "technology",
}

constants.component_states = {
  "normal",
  "collapsed",
  "hidden",
}

constants.colors = {
  error = {
    str = "255, 90, 90",
    tbl = { 255, 90, 90 },
  },
  green = {
    str = "210, 253, 145",
    tbl = { 210, 253, 145 },
  },
  heading = {
    str = "255, 230, 192",
    tbl = { 255, 230, 192 },
  },
  info = {
    str = "128, 206, 240",
    tbl = { 128, 206, 240 },
  },
  invisible = {
    str = "0, 0, 0, 0",
    tbl = { 0, 0, 0, 0 },
  },
  yellow = {
    str = "255, 240, 69",
    tbl = { 255, 240, 69 },
  },
  unresearched = {
    str = "255, 142, 142",
    tbl = { 255, 142, 142 },
  },
}

constants.default_max_rows = 8

constants.type_to_class = {
  ["entity"] = "entity",
  ["equipment-category"] = "equipment_category",
  ["equipment"] = "equipment",
  ["fluid"] = "fluid",
  ["fuel-category"] = "fuel_category",
  ["item-group"] = "group",
  ["item"] = "item",
  ["recipe-catgory"] = "recipe_category",
  ["recipe"] = "recipe",
  ["resource-catgory"] = "resource_category",
  ["resource"] = "resource",
  ["rocket-silo"] = "entity",
  ["spider-vehicle"] = "entity",
  ["technology"] = "technology",
}

constants.disabled_categories = {
  entity_type = {},
  equipment_category = {},
  fuel_category = {},
  group = {
    -- Editor extensions
    ["ee-tools"] = true,
  },
  item_type = {
    ["blueprint"] = true,
    ["blueprint-book"] = true,
    ["copy-paste-tool"] = true,
    ["deconstruction-item"] = true,
    ["selection-tool"] = true,
    ["upgrade-item"] = true,
  },
  -- Dictionary category -> modifier
  -- `0` - Disabled by default, does not affect object availability
  -- `1` - Disabled by default
  recipe_category = {
    -- Creative mod
    ["creative-mod_free-fluids"] = 1,
    ["creative-mod_energy-absorption"] = 1,
    -- Editor extensions
    ["ee-testing-tool"] = 1,
    -- Deep storage unit
    ["deep-storage-item"] = 0,
    ["deep-storage-fluid"] = 0,
    ["deep-storage-item-big"] = 0,
    ["deep-storage-fluid-big"] = 0,
    ["deep-storage-item-mk2/3"] = 0,
    ["deep-storage-fluid-mk2/3"] = 0,
    -- Krastorio 2
    ["void-crushing"] = 0, -- This doesn't actually exist yet, but will soon!
    -- Mining drones
    ["mining-depot"] = 0,
    -- Pyanodon's
    ["py-incineration"] = 1,
    ["py-runoff"] = 1,
    ["py-venting"] = 1,
    -- Reverse factory
    ["recycle-intermediates"] = 0,
    ["recycle-productivity"] = 0,
    ["recycle-products"] = 0,
    ["recycle-with-fluids"] = 0,
    -- Transport drones
    ["fuel-depot"] = 0,
    ["transport-drone-request"] = 0,
    ["transport-fluid-request"] = 0,
  },
  resource_category = {},
  science_pack = {},
}

constants.fake_fluid_fuel_category = "burnable-fluid"

constants.general_settings = {
  content = {
    show_disabled = {
      type = "bool",
      has_tooltip = true,
      default_value = false,
    },
    show_hidden = {
      type = "bool",
      has_tooltip = true,
      default_value = false,
    },
    show_unresearched = {
      type = "bool",
      has_tooltip = false,
      default_value = true,
    },
    show_made_in_in_quick_ref = {
      type = "bool",
      has_tooltip = false,
      default_value = false,
    },
  },
  captions = {
    show_internal_names = {
      type = "bool",
      has_tooltip = true,
      default_value = false,
    },
    show_glyphs = {
      type = "bool",
      has_tooltip = false,
      default_value = true,
    },
  },
  tooltips = {
    show_alternate_name = {
      type = "bool",
      has_tooltip = true,
      default_value = false,
    },
    show_descriptions = {
      type = "bool",
      has_tooltip = false,
      default_value = true,
    },
    show_detailed_tooltips = {
      type = "bool",
      has_tooltip = true,
      default_value = true,
    },
    show_interaction_helps = {
      type = "bool",
      has_tooltip = false,
      default_value = true,
    },
  },
  search = {
    default_gui_type = {
      type = "enum",
      options = {
        "textual",
        "visual",
      },
      has_tooltip = true,
      default_value = "textual",
    },
    fuzzy_search = {
      type = "bool",
      has_tooltip = true,
      default_value = false,
    },
    show_fluid_temperatures = {
      type = "enum",
      options = {
        "off",
        "absolute_only",
        "all",
      },
      has_tooltip = true,
      default_value = "all",
    },
    search_type = {
      type = "enum",
      options = {
        "localised",
        "internal",
        "both",
      },
      has_tooltip = true,
      default_value = "localised",
    },
  },
  interface = {
    open_info_relative_to_gui = {
      type = "bool",
      has_tooltip = true,
      default_value = true,
    },
    attach_search_results = {
      type = "bool",
      has_tooltip = true,
      default_value = true,
    },
    close_search_gui_after_selection = {
      type = "bool",
      has_tooltip = false,
      default_value = false,
      dependencies = {
        { category = "interface", name = "attach_search_results", value = false },
      },
    },
    search_gui_location = {
      type = "enum",
      options = {
        "top_left",
        "center",
      },
      has_tooltip = true,
      default_value = "top_left",
    },
  },
}

constants.global_history_size = 30

constants.gui_strings = {
  accepted_equipment = { "gui.rb-accepted-equipment" },
  accepted_modules = { "gui.rb-accepted-modules" },
  affects_recipes = { "gui.rb-affects-recipes" },
  alt_click = { "gui.rb-alt-click" },
  attach_search_results = { "gui.rb-attach-search-results" },
  base_pollution_desc = { "gui.rb-base-pollution-desc" },
  base_pollution = { "gui.rb-base-pollution" },
  beacon = { "gui.rb-beacon" },
  buffer_capacity = { "gui.rb-buffer-capacity" },
  burned_in = { "gui.rb-burned-in" },
  burnt_result = { "gui.rb-burnt-result" },
  burnt_result_of = { "gui.rb-burnt-result-of" },
  can_burn = { "gui.rb-can-burn" },
  can_craft = { "gui.rb-can-craft" },
  can_mine = { "gui.rb-can-mine" },
  captions = { "gui.rb-captions" },
  catalyst_abbrev = { "gui.rb-catalyst-abbrev" },
  catalyst_amount = { "gui.rb-catalyst-amount" },
  category = { "gui.rb-category" },
  charging_energy = { "gui.rb-charging-energy" },
  click = { "gui.rb-click" },
  close_search_gui_after_selection = { "gui.rb-close-search-gui-after-selection" },
  close_search_when_moving_info_pages = { "gui.rb-close-search-when-moving-info-pages" },
  construction_radius = { "gui.rb-construction-radius" },
  consumption_bonus = { "description.consumption-bonus" },
  content = { "gui.rb-content" },
  control_click = { "gui.rb-control-click" },
  crafter = { "gui.rb-crafter" },
  crafting_speed = { "description.crafting-speed" },
  crafting_time_desc = { "gui.rb-crafting-time-desc" },
  crafting_time = { "gui.rb-crafting-time" },
  default_gui_type = { "gui.rb-default-gui-type" },
  default_state = { "gui.rb-default-state" },
  default_temperature = { "gui.rb-default-temperature" },
  disabled_abbrev = { "gui.rb-disabled-abbrev" },
  disabled = { "entity-status.disabled" },
  distribution_effectivity = { "gui.rb-distribution-effectivity" },
  effect_area = { "gui.rb-effect-area" },
  energy_consumption = { "gui.rb-energy-consumption" },
  energy_per_shield_point = { "gui.rb-energy-per-shield-point" },
  energy_production = { "gui.rb-energy-production" },
  entities = { "gui.rb-entities" },
  entity = { "gui.rb-entity" },
  entity_type = { "gui.rb-entity-type" },
  equipment_categories = { "gui.rb-equipment-categories" },
  equipment_category = { "gui.rb-equipment-category" },
  equipment = { "gui.rb-equipment" },
  equipment_properties = { "gui.rb-equipment-properties" },
  expected_resources = { "gui.rb-expected-resources" },
  fixed_recipe = { "gui.rb-fixed-recipe" },
  fluid_consumption = { "gui.rb-fluid-consumption" },
  fluid = { "gui.rb-fluid" },
  fluids = { "gui.rb-fluids" },
  format_amount = { "gui.rb-format-amount" },
  format_area = { "gui.rb-format-area" },
  format_degrees = { "format-degrees-c-compact" },
  format_percent = { "format-percent" },
  format_seconds_parenthesis = { "gui.rb-format-seconds-parenthesis" },
  format_seconds = { "time-symbol-seconds" },
  fuel_categories = { "gui.rb-fuel-categories" },
  fuel_category = { "gui.rb-fuel-category" },
  fuel_pollution = { "description.fuel-pollution" },
  fuel_value = { "description.fuel-value" },
  fuzzy_search = { "gui.rb-fuzzy-search" },
  gathered_from = { "gui.rb-gathered-from" },
  general = { "gui.rb-general" },
  generator = { "gui.rb-generator" },
  get_blueprint = { "gui.rb-get-blueprint" },
  go_backward = { "gui.rb-go-backward" },
  go_forward = { "gui.rb-go-forward" },
  go_to_the_back = { "gui.rb-go-to-the-back" },
  go_to_the_front = { "gui.rb-go-to-the-front" },
  group = { "gui.rb-group" },
  hidden_abbrev = { "gui.rb-hidden-abbrev" },
  hidden = { "gui.rb-hidden" },
  ingredient_in = { "gui.rb-ingredient-in" },
  ingredient_limit = { "gui.rb-ingredient-limit" },
  ingredients = { "gui.rb-ingredients" },
  inputs = { "gui.rb-inputs" },
  interface = { "gui.rb-interface" },
  item = { "gui.rb-item" },
  items = { "gui.rb-items" },
  item_type = { "gui.rb-item-type" },
  lab = { "gui.rb-lab" },
  list_box_label = { "gui.rb-list-box-label" },
  logistic_radius = { "gui.rb-logistic-radius" },
  made_in = { "gui.rb-made-in" },
  max_energy_production = { "gui.rb-max-energy-production" },
  maximum_temperature = { "gui.rb-maximum-temperature" },
  max_rows = { "gui.rb-max-rows" },
  middle_click = { "gui.rb-middle-click" },
  mined_by = { "gui.rb-mined-by" },
  mined_from = { "gui.rb-mined-from" },
  minimum_temperature = { "gui.rb-minimum-temperature" },
  mining_area = { "gui.rb-mining-area" },
  mining_drill = { "gui.rb-mining-drill" },
  mining_drills = { "gui.rb-mining-drills" },
  mining_speed = { "gui.rb-mining-speed" },
  mining_time = { "gui.rb-mining-time" },
  module_effects = { "gui.rb-module-effects" },
  modules = { "gui.rb-modules" },
  module_slots = { "gui.rb-module-slots" },
  movement_bonus = { "description.movement-speed-bonus" },
  offshore_pump = { "gui.rb-offshore-pump" },
  open_info_relative_to_gui = { "gui.rb-open-info-relative-to-gui" },
  open_in_technology_window = { "gui.rb-open-in-technology-window" },
  per_second_suffix = { "gui.rb-per-second-suffix" },
  place_as_equipment_result = { "gui.rb-place-as-equipment-result" },
  placed_by = { "gui.rb-placed-by" },
  placed_in = { "gui.rb-placed-in" },
  place_result = { "gui.rb-place-result" },
  pollution_bonus = { "description.pollution-bonus" },
  pollution_multiplier = { "gui.rb-pollution-multiplier" },
  prerequisite_of = { "gui.rb-prerequisite-of" },
  prerequisites = { "gui.rb-prerequisites" },
  preserve_search_query = { "gui.rb-preserve-search-query" },
  productivity_bonus = { "description.productivity-bonus" },
  product_of = { "gui.rb-product-of" },
  products = { "gui.rb-products" },
  pumped_by = { "gui.rb-pumped-by" },
  pumping_speed = { "description.pumping-speed" },
  recipe_categories = { "gui.rb-recipe-categories" },
  recipe_category = { "gui.rb-recipe-category" },
  recipe = { "gui.rb-recipe" },
  recipes = { "gui.rb-recipes" },
  required_fluid = { "gui.rb-required-fluid" },
  required_units = { "gui.rb-required-units" },
  researched_in = { "gui.rb-researched-in" },
  research_ingredients_per_unit = { "gui.rb-research-ingredients-per-unit" },
  research_speed_desc = { "gui.rb-research-speed-desc" },
  research_speed = { "description.research-speed" },
  resource_categories = { "gui.rb-resource-categories" },
  resource_category = { "gui.rb-resource-category" },
  resource = { "gui.rb-resource" },
  resources = { "gui.rb-resources" },
  right_click = { "gui.rb-right-click" },
  robot_limit = { "gui.rb-robot-limit" },
  rocket_launch_product_of = { "gui.rb-rocket-launch-product-of" },
  rocket_launch_products = { "gui.rb-rocket-launch-products" },
  rocket_parts_required = { "gui.rb-rocket-parts-required" },
  science_pack = { "gui.rb-science-pack" },
  search_gui_location = { "gui.rb-search-gui-location" },
  search = { "gui.rb-search" },
  search_type = { "gui.rb-search-type" },
  session_history = { "gui.rb-session-history" },
  shield_points = { "gui.rb-shield-points" },
  shift_click = { "gui.rb-shift-click" },
  show_alternate_name = { "gui.rb-show-alternate-name" },
  show_descriptions = { "gui.rb-show-descriptions" },
  show_detailed_tooltips = { "gui.rb-show-detailed-tooltips" },
  show_disabled = { "gui.rb-show-disabled" },
  show_fluid_temperatures = { "gui.rb-show-fluid-temperatures" },
  show_glyphs = { "gui.rb-show-glyphs" },
  show_hidden = { "gui.rb-show-hidden" },
  show_interaction_helps = { "gui.rb-show-interaction-helps" },
  show_internal_names = { "gui.rb-show-internal-names" },
  show_made_in_in_quick_ref = { "gui.rb-show-made-in-in-quick-ref" },
  show_unresearched = { "gui.rb-show-unresearched" },
  si_joule = { "si-unit-symbol-joule" },
  si_watt = { "si-unit-symbol-watt" },
  size = { "gui.rb-size" },
  speed_bonus = { "description.speed-bonus" },
  stack_size = { "gui.rb-stack-size" },
  take_result = { "gui.rb-take-result" },
  tech_level_desc = { "gui.rb-tech-level-desc" },
  tech_level = { "gui.rb-tech-level" },
  technology = { "gui.rb-technology" },
  temperatures = { "gui.rb-temperatures" },
  time_per_unit_desc = { "gui.rb-time-per-unit-desc" },
  time_per_unit = { "gui.rb-time-per-unit" },
  toggle_completed = { "gui.rb-toggle-completed" },
  tooltips = { "gui.rb-tooltips" },
  unlocked_by = { "gui.rb-unlocked-by" },
  unlocks_entities = { "gui.rb-unlocks-entities" },
  unlocks_equipment = { "gui.rb-unlocks-equipment" },
  unlocks_fluids = { "gui.rb-unlocks-fluids" },
  unlocks_items = { "gui.rb-unlocks-items" },
  unlocks_recipes = { "gui.rb-unlocks-recipes" },
  unresearched = { "gui.rb-unresearched" },
  vehicle_acceleration = { "description.fuel-acceleration" },
  vehicle_top_speed = { "description.fuel-top-speed" },
  view_base_fluid = { "gui.rb-view-base-fluid" },
  view_details = { "gui.rb-view-details" },
  view_details_in_new_window = { "gui.rb-view-details-in-new-window" },
  view_fixed_recipe = { "gui.rb-view-fixed-recipe" },
  view_fluid = { "gui.rb-view-fluid" },
  view_ingredient_in = { "gui.rb-view-ingredient-in" },
  view_product_details = { "gui.rb-view-product-details" },
  view_product_of = { "gui.rb-view-product-of" },
  view_required_fluid = { "gui.rb-view-required-fluid" },
  view_technology = { "gui.rb-view-technology" },
}

constants.header_button_tooltips = {
  quick_ref_button = {
    selected = { "gui.rb-close-quick-ref-window" },
    unselected = { "gui.rb-open-quick-ref-window" },
  },
  favorite_button = {
    selected = { "gui.rb-remove-from-favorites" },
    unselected = { "gui.rb-add-to-favorites" },
  },
}

constants.ignored_info_ids = table.invert({
  "_active_id",
  "_next_id",
  "_relative_id",
  "_sticky_id", -- For legacy reasons
})

constants.ignored_cursor_inspection_types = {
  ["blueprint"] = true,
  ["blueprint-book"] = true,
  ["copy-paste-tool"] = true,
  ["deconstruction-item"] = true,
  ["selection-tool"] = true,
  ["upgrade-item"] = true,
}

-- NOTE: Modifiers must be in the order of "control", "shift" for those that are present
constants.interactions = {
  entity = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
  },
  entity_type = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
  },
  equipment_category = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
  },
  equipment = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
  },
  fluid = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
    {
      modifiers = { "control" },
      action = "view_source",
      label = "view_base_fluid",
      source = "base_fluid",
    },
  },
  fuel_category = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
  },
  group = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
  },
  item = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
  },
  item_type = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
  },
  recipe_category = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
  },
  recipe = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
    {
      modifiers = { "control" },
      action = "view_product_details",
      test = function(obj_data, _)
        return #obj_data.products == 1
      end,
    },
  },
  resource_category = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
  },
  resource = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
    {
      modifiers = { "control" },
      action = "view_source",
      label = "view_required_fluid",
      source = "required_fluid",
    },
  },
  technology = {
    { modifiers = {}, action = "view_details" },
    { button = "middle", modifiers = {}, action = "view_details_in_new_window" },
    {
      modifiers = { "shift" },
      action = "get_blueprint",
      test = function(_, options)
        return options.blueprint_result
      end,
    },
    { modifiers = { "control" }, action = "open_in_technology_window" },
  },
}

constants.input_sanitizers = {
  ["%%"] = "%%%%",
  ["%("] = "%%(",
  ["%)"] = "%%)",
  ["%.^[%*]"] = "%%.",
  ["%+"] = "%%+",
  ["%-"] = "%%-",
  ["^[%.]%*"] = "%%*",
  ["%?"] = "%%?",
  ["%["] = "%%[",
  ["%]"] = "%%]",
  ["%^"] = "%%^",
  ["%$"] = "%%$",
}

constants.interface_version = 4

constants.nav_event_properties = {
  ["rb-jump-to-front"] = { delta = 1, shift = true },
  ["rb-navigate-backward"] = { delta = -1 },
  ["rb-navigate-forward"] = { delta = 1 },
  ["rb-return-to-home"] = { delta = -1, shift = true },
}

constants.pages = {
  entity = {
    {
      type = "table",
      label = "general",
      hide_count = true,
      rows = {
        { type = "goto", source = "entity_type", options = { hide_glyph = true } },
        { type = "plain", source = "effect_area", formatter = "area" },
        { type = "plain", source = "distribution_effectivity", formatter = "percent" },
        { type = "plain", source = "module_slots", formatter = "number" },
        { type = "plain", source = "crafting_speed", formatter = "number" },
        { type = "goto", source = "fixed_recipe", options = { always_show = true, hide_glyph = true } },
        { type = "plain", source = "rocket_parts_required", formatter = "number" },
        { type = "plain", source = "ingredient_limit", formatter = "number" },
        { type = "plain", source = "fluid_consumption", formatter = "per_second" },
        { type = "plain", source = "maximum_temperature", formatter = "temperature" },
        { type = "plain", source = "max_energy_production", formatter = "energy" },
        {
          type = "plain",
          source = "base_pollution",
          label_tooltip = "base_pollution_desc",
          formatter = "per_second",
        },
        {
          type = "plain",
          source = "researching_speed",
          label = "research_speed",
          label_tooltip = "research_speed_desc",
          formatter = "number",
        },
        { type = "plain", source = "mining_speed", formatter = "per_second" },
        { type = "plain", source = "mining_area", formatter = "area" },
        { type = "plain", source = "pumping_speed", formatter = "per_second" },
        { type = "goto", source = "fluid", options = { always_show = true, hide_glyph = true } },
        { type = "plain", source = "size", formatter = "area" },
      },
    },
    { type = "list_box", source = "expected_resources" },
    { type = "list_box", source = "can_mine" },
    { type = "list_box", source = "resource_categories", default_state = "hidden" },
    { type = "list_box", source = "can_craft", max_rows = 10 },
    { type = "list_box", source = "recipe_categories", default_state = "hidden" },
    { type = "list_box", source = "inputs" },
    { type = "list_box", source = "can_burn" },
    { type = "list_box", source = "fuel_categories", default_state = "hidden" },
    { type = "list_box", source = "accepted_modules", default_state = "hidden" },
    { type = "list_box", source = "accepted_equipment", default_state = "collapsed" },
    { type = "list_box", source = "equipment_categories", default_state = "hidden" },
    { type = "list_box", source = "unlocked_by" },
    { type = "list_box", source = "placed_by" },
  },
  entity_type = {
    { type = "list_box", source = "entities", max_rows = 16 },
  },
  equipment_category = {
    { type = "list_box", source = "equipment" },
  },
  equipment = {
    {
      type = "table",
      label = "general",
      hide_count = true,
      rows = {
        { type = "goto", source = "take_result" },
        { type = "plain", source = "size", formatter = "area" },
      },
    },
    { type = "table", source = "equipment_properties" },
    { type = "list_box", source = "placed_in" },
    { type = "list_box", source = "can_burn" },
    { type = "list_box", source = "fuel_categories", default_state = "hidden" },
    { type = "list_box", source = "equipment_categories", default_state = "hidden" },
    { type = "list_box", source = "unlocked_by" },
  },
  fluid = {
    {
      type = "table",
      label = "general",
      hide_count = true,
      rows = {
        { type = "plain", source = "default_temperature", formatter = "temperature" },
        { type = "plain", source = "fuel_value", formatter = "fuel_value" },
        { type = "plain", source = "fuel_pollution", formatter = "percent" },
        { type = "goto", source = "fuel_category", options = { hide_glyph = true }, default_state = false },
        { type = "goto", source = "group", options = { hide_glyph = true }, default_state = false },
      },
    },
    { type = "list_box", source = "ingredient_in" },
    { type = "list_box", source = "product_of" },
    { type = "list_box", source = "mined_from" },
    { type = "list_box", source = "pumped_by" },
    { type = "list_box", source = "burned_in" },
    { type = "list_box", source = "unlocked_by" },
    { type = "list_box", source = "temperatures", use_pairs = true },
  },
  fuel_category = {
    { type = "list_box", source = "fluids" },
    { type = "list_box", source = "items" },
  },
  group = {
    { type = "list_box", source = "fluids" },
    { type = "list_box", source = "items" },
    { type = "list_box", source = "recipes" },
  },
  item = {
    {
      type = "table",
      label = "general",
      hide_count = true,
      rows = {
        { type = "goto", source = "item_type", options = { hide_glyph = true } },
        { type = "plain", source = "stack_size", formatter = "number" },
        { type = "plain", source = "fuel_value", formatter = "fuel_value" },
        {
          type = "plain",
          source = "fuel_emissions_multiplier",
          label = "fuel_pollution",
          formatter = "percent",
        },
        {
          type = "plain",
          source = "fuel_acceleration_multiplier",
          label = "vehicle_acceleration",
          formatter = "percent",
        },
        {
          type = "plain",
          source = "fuel_top_speed_multiplier",
          label = "vehicle_top_speed",
          formatter = "percent",
        },
        { type = "goto", source = "fuel_category", options = { hide_glyph = true }, default_state = false },
        { type = "goto", source = "burnt_result", options = { hide_glyph = true } },
        { type = "goto", source = "group", options = { hide_glyph = true }, default_state = false },
        { type = "goto", source = "place_result" },
        { type = "goto", source = "place_as_equipment_result" },
      },
    },
    { type = "table", source = "module_effects" },
    { type = "list_box", source = "ingredient_in" },
    { type = "list_box", source = "product_of" },
    { type = "list_box", source = "rocket_launch_product_of" },
    { type = "list_box", source = "rocket_launch_products" },
    { type = "list_box", source = "affects_recipes", default_state = "disabled" },
    { type = "list_box", source = "gathered_from" },
    { type = "list_box", source = "mined_from" },
    { type = "list_box", source = "researched_in" },
    { type = "list_box", source = "burned_in" },
    { type = "list_box", source = "burnt_result_of" },
    { type = "list_box", source = "accepted_equipment", default_state = "collapsed" },
    { type = "list_box", source = "equipment_categories", default_state = "hidden" },
    { type = "list_box", source = "unlocked_by" },
  },
  item_type = {
    { type = "list_box", source = "items", max_rows = 16 },
  },
  recipe_category = {
    { type = "list_box", source = "fluids" },
    { type = "list_box", source = "items" },
    { type = "list_box", source = "recipes" },
  },
  recipe = {
    {
      type = "table",
      label = "general",
      hide_count = true,
      rows = {
        { type = "goto", source = "recipe_category", options = { hide_glyph = true }, default_state = false },
        { type = "goto", source = "group", options = { hide_glyph = true }, default_state = false },
        {
          type = "plain",
          source = "energy",
          label = "crafting_time",
          label_tooltip = "crafting_time_desc",
          formatter = "seconds_from_ticks",
        },
        {
          type = "plain",
          source = "pollution_multiplier",
          formatter = "percent",
        },
      },
    },
    { type = "list_box", source = "ingredients", always_show = true },
    { type = "list_box", source = "products", always_show = true },
    { type = "list_box", source = "made_in" },
    { type = "list_box", source = "unlocked_by" },
    { type = "list_box", source = "accepted_modules", default_state = "collapsed" },
  },
  resource_category = {
    { type = "list_box", source = "resources" },
    { type = "list_box", source = "mining_drills" },
  },
  resource = {
    {
      type = "table",
      label = "general",
      hide_count = true,
      rows = {
        { type = "goto", source = "resource_category", options = { always_show = true, hide_glyph = true } },
        { type = "goto", source = "required_fluid", options = { always_show = true, hide_glyph = true } },
        { type = "plain", source = "mining_time", formatter = "seconds_from_ticks" },
      },
    },
    { type = "list_box", source = "products" },
    { type = "list_box", source = "mined_by" },
  },
  technology = {
    {
      type = "table",
      label = "general",
      hide_count = true,
      rows = {
        { type = "plain", source = "research_unit_count", label = "required_units", formatter = "number" },
        {
          type = "tech_level_selector",
          source = "research_unit_count_formula",
          label = "tech_level",
          label_tooltip = "tech_level_desc",
        },
        {
          type = "tech_level_research_unit_count",
          source = "research_unit_count_formula",
          label = "required_units",
          formatter = "number",
        },
        {
          type = "plain",
          source = "research_unit_energy",
          label = "time_per_unit",
          label_tooltip = "time_per_unit_desc",
          formatter = "seconds_from_ticks",
        },
      },
    },
    { type = "list_box", source = "research_ingredients_per_unit" },
    { type = "list_box", source = "unlocks_entities", default_state = "hidden" },
    { type = "list_box", source = "unlocks_equipment", default_state = "hidden" },
    { type = "list_box", source = "unlocks_fluids", default_state = "hidden" },
    { type = "list_box", source = "unlocks_items", default_state = "hidden" },
    { type = "list_box", source = "unlocks_recipes" },
    { type = "list_box", source = "prerequisites" },
    { type = "list_box", source = "prerequisite_of" },
  },
}

constants.pages_arr = {}
for name in pairs(constants.pages) do
  table.insert(constants.pages_arr, name)
end

constants.prototypes = {}

constants.prototypes.filtered_entities = {
  beacon = { { filter = "type", type = "beacon" } },
  character = { { filter = "type", type = "character" } },
  crafter = {
    { filter = "type", type = "assembling-machine" },
    { filter = "type", type = "furnace" },
    { filter = "type", type = "rocket-silo" },
  },
  generator = { { filter = "type", type = "generator" } },
  lab = { { filter = "type", type = "lab" } },
  entity = {
    { filter = "type", type = "boiler" },
    { filter = "type", type = "burner-generator" },
    { filter = "type", type = "car" },
    { filter = "type", type = "inserter" },
    { filter = "type", type = "locomotive" },
    { filter = "type", type = "pump" },
    { filter = "type", type = "radar" },
    { filter = "type", type = "reactor" },
    { filter = "type", type = "simple-entity" },
    { filter = "type", type = "spider-vehicle" },
    { filter = "type", type = "tree" },
  },
  mining_drill = { { filter = "type", type = "mining-drill" } },
  offshore_pump = { { filter = "type", type = "offshore-pump" } },
  resource = { { filter = "type", type = "resource" } },
}

constants.prototypes.straight_conversions = {
  "equipment",
  "equipment_category",
  "equipment_grid",
  "fluid",
  "fuel_category",
  "item",
  "item_group",
  "module_category",
  "recipe",
  "recipe_category",
  "resource_category",
  "technology",
}

constants.search_gui_top_left_location = {
  x = 10,
  y = 68,
}
constants.search_results_limit = 500
constants.search_results_visible_items = 15
constants.search_timeout = 30

constants.session_history_size = 20

constants.settings_gui_rows = 24

constants.tooltips = {
  entity = {
    { type = "plain", source = "effect_area", formatter = "area" },
    { type = "plain", source = "distribution_effectivity", formatter = "percent" },
    { type = "plain", source = "module_slots", formatter = "number" },
    { type = "plain", source = "crafting_speed", formatter = "number" },
    { type = "plain", source = "fixed_recipe", formatter = "object", options = { hide_glyph = true } },
    { type = "plain", source = "rocket_parts_required", formatter = "number" },
    { type = "plain", source = "ingredient_limit", formatter = "number" },
    { type = "plain", source = "research_speed", formatter = "number" },
    { type = "list", source = "inputs", formatter = "object", options = { hide_glyph = true } },
    { type = "plain", source = "mining_speed", formatter = "per_second" },
    { type = "plain", source = "mining_area", formatter = "area" },
    { type = "plain", source = "pumping_speed", formatter = "per_second" },
    {
      type = "plain",
      source = "fluid",
      formatter = "object",
      options = { always_show = true, hide_glyph = true },
    },
  },
  entity_type = {},
  equipment_category = {},
  equipment = {
    { type = "plain", source = "size", formatter = "area" },
    { type = "plain", source = "energy_consumption", formatter = "energy" },
    { type = "plain", source = "energy_production", formatter = "energy" },
  },
  fluid = {
    { type = "plain", source = "default_temperature", formatter = "temperature" },
    { type = "plain", source = "fuel_value", formatter = "fuel_value" },
    { type = "plain", source = "fuel_pollution", formatter = "percent" },
    { type = "plain", source = "group", formatter = "object", options = { hide_glyph = true } },
  },
  fuel_category = {},
  group = {},
  item = {
    { type = "plain", source = "stack_size", formatter = "number" },
    { type = "plain", source = "fuel_value", formatter = "fuel_value" },
    { type = "plain", source = "fuel_emissions_multiplier", label = "fuel_pollution", formatter = "percent" },
    {
      type = "plain",
      source = "fuel_acceleration_multiplier",
      label = "vehicle_acceleration",
      formatter = "percent",
    },
    { type = "plain", source = "fuel_top_speed_multiplier", label = "vehicle_top_speed", formatter = "percent" },
    { type = "plain", source = "group", formatter = "object", options = { hide_glyph = true } },
  },
  item_type = {},
  recipe_category = {},
  recipe = {
    { type = "plain", source = "group", formatter = "object", options = { hide_glyph = true } },
    { type = "plain", source = "energy", label = "crafting_time", formatter = "seconds_from_ticks" },
    { type = "list", source = "ingredients", formatter = "object", options = { always_show = true } },
    { type = "list", source = "products", formatter = "object", options = { always_show = true } },
  },
  resource = {
    {
      type = "plain",
      source = "required_fluid",
      formatter = "object",
      options = { always_show = true, hide_glyph = true },
    },
    { type = "plain", source = "mining_time", formatter = "seconds_from_ticks" },
    { type = "list", source = "products", formatter = "object" },
  },
  resource_category = {},
  technology = {
    { type = "plain", source = "research_unit_count", label = "required_units", formatter = "number" },
    { type = "plain", source = "research_unit_energy", label = "time_per_unit", formatter = "seconds_from_ticks" },
    {
      type = "list",
      source = "research_ingredients_per_unit",
      formatter = "object",
      options = { always_show = true },
    },
  },
}

return constants
