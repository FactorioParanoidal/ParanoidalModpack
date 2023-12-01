--[[
  DESIGN NOTES:
  - Amount strings are not pre-processed, but are generated as part of the format call (allowing for locale differences)
  - Multiple caches:
    - Base caption
    - Base tooltip
    - Tooltip contents
    - Amount strings
    - Control hints
  - The output is assembled from these individual caches
    - Perhaps the final outputs should be cached as well?
    - The idea here is to avoid re-generating the entire caption and tooltip when just the amount or control hints are
      different
  - Consider moving the show / don't show logic to `util` instead of `formatter`, so it can be used elsewhere
  - Per-instance settings:
    - show_glyphs
    - show_tooltip_details
    - amount_only
    - is_label: show_glyphs = false, show_tooltip_details = false
]]

local flib_format = require("__flib__.format")
local math = require("__flib__.math")
local table = require("__flib__.table")

local constants = require("constants")

local database = require("scripts.database")

local caches = {}

local formatter = {}

local function build_cache_key(...)
  return table.concat(
    table.map({ ... }, function(v)
      return tostring(v)
    end),
    "."
  )
end

local function expand_string(source, ...)
  local arg = { ... }
  for i = 1, #arg do
    source = string.gsub(source, "__" .. i .. "__", arg[i])
  end
  return source
end

local function rich_text(key, value, inner)
  return "["
    .. key
    .. "="
    .. (key == "color" and constants.colors[value].str or value)
    .. "]"
    .. inner
    .. "[/"
    .. key
    .. "]"
end

local function sprite(class, name)
  return "[img=" .. class .. "/" .. name .. "]"
end

local function control(content, action)
  return "\n" .. rich_text("color", "info", rich_text("font", "default-semibold", content .. ":")) .. " " .. action
end

local function number(value)
  return flib_format.number(math.round(value, 0.01))
end

local function temperature(value, gui_translations)
  return expand_string(gui_translations.format_degrees, number(value))
end

local function area(value, gui_translations)
  if type(value) == "number" then
    local formatted = number(value)
    return expand_string(gui_translations.format_area, formatted, formatted)
  else
    return expand_string(gui_translations.format_area, number(value.width), number(value.height))
  end
end

local function energy(value, gui_translations)
  return flib_format.number(value * 60, true, 3) .. gui_translations.si_watt
end

local function energy_storage(value, gui_translations)
  return flib_format.number(value, true, 2) .. gui_translations.si_joule
end

local function fuel_value(value, gui_translations)
  return flib_format.number(value, true, 3) .. gui_translations.si_joule
end

local function percent(value, gui_translations)
  return expand_string(gui_translations.format_percent, number(value * 100))
end

local function seconds(value, gui_translations)
  return expand_string(gui_translations.format_seconds, number(value * 60))
end

local function seconds_from_ticks(value, gui_translations)
  return seconds(value / 60, gui_translations)
end

local function per_second(value, gui_translations)
  return number(value) .. " " .. gui_translations.per_second_suffix
end

local function object(obj, _, player_data, options)
  local obj_data = database[obj.class][obj.name]
  local obj_options = options and table.shallow_copy(options) or {}
  obj_options.amount_ident = obj.amount_ident
  local info = formatter(obj_data, player_data, obj_options)
  if info then
    return info.caption
  end
end

local function get_amount_string(amount_ident, player_data, options)
  local cache_key = build_cache_key(
    "amount_string",
    amount_ident.amount,
    amount_ident.amount_min,
    amount_ident.amount_max,
    amount_ident.catalyst_amount,
    amount_ident.probability,
    amount_ident.format,
    options.amount_only,
    options.rocket_parts_required
  )
  local cache = caches[player_data.player_index]
  local cached = cache[cache_key]
  if cached then
    return cached
  end

  local amount = amount_ident.amount
  local output
  if options.amount_only then
    output = amount_ident.amount and tostring(math.round(amount, 0.1))
      or "~" .. math.round((amount_ident.amount_min + amount_ident.amount_max) / 2, 0.1)
  else
    local gui_translations = player_data.translations.gui
    -- Amount
    local format_string = gui_translations[amount_ident.format]
    if amount then
      output = expand_string(format_string, number(amount))
    else
      output = expand_string(format_string, number(amount_ident.amount_min) .. " - " .. number(amount_ident.amount_max))
    end

    -- Catalyst amount
    local catalyst = amount_ident.catalyst_amount
    if catalyst then
      output = gui_translations.catalyst_abbrev .. "  " .. output
    end

    -- Probability
    local probability = amount_ident.probability
    if probability and probability < 1 then
      output = math.round(probability * 100, 0.01) .. "% " .. output
    end

    -- Rocket parts required
    -- Hardcoded to always use the `amount` formatter
    if options.rocket_parts_required then
      output = expand_string(gui_translations.format_amount, options.rocket_parts_required) .. "  " .. output
    end
  end

  cache[cache_key] = output
  return output
end

local function get_caption(obj_data, obj_properties, player_data, options)
  local settings = player_data.settings
  local gui_translations = player_data.translations.gui

  local prototype_name = obj_data.prototype_name
  local name = obj_data.name or prototype_name

  local cache = caches[player_data.player_index]
  local cache_key =
    build_cache_key("caption", obj_data.class, name, obj_properties.enabled, obj_properties.hidden, options.hide_glyph)
  local cached = cache[cache_key]
  if cached then
    return cached
  end

  local class = obj_data.class

  local before = ""
  if settings.general.captions.show_glyphs and not options.hide_glyph then
    before = rich_text(
      "font",
      "RecipeBook",
      constants.class_to_font_glyph[class] or constants.class_to_font_glyph[class]
    ) .. "  "
  end

  if obj_properties.hidden then
    before = before .. rich_text("font", "default-semibold", gui_translations.hidden_abbrev) .. "  "
  end
  if not obj_properties.enabled then
    before = before .. rich_text("font", "default-semibold", gui_translations.disabled_abbrev) .. "  "
  end

  local type = constants.class_to_type[class]
  if type then
    before = before .. sprite(type, prototype_name) .. "  "
  end

  local after
  if settings.general.captions.show_internal_names then
    after = name
  else
    after = player_data.translations[class][name] or name
  end

  local output = { before = before, after = after }
  cache[cache_key] = output
  return output
end

local function get_base_tooltip(obj_data, obj_properties, player_data, options)
  options = options or {}

  local settings = player_data.settings
  local gui_translations = player_data.translations.gui

  local show_internal_names = settings.general.captions.show_internal_names

  local prototype_name = obj_data.prototype_name
  local name = obj_data.name or prototype_name
  local class = obj_data.class
  local type = constants.class_to_type[class]

  local catalyst_amount = options.amount_ident and options.amount_ident.catalyst_amount or false

  local cache = caches[player_data.player_index]
  local cache_key = build_cache_key(
    "base_tooltip",
    obj_data.class,
    name,
    obj_properties.enabled,
    obj_properties.hidden,
    obj_properties.researched,
    catalyst_amount
  )
  local cached = cache[cache_key]
  if cached then
    return cached
  end

  local before
  if type then
    before = sprite(type, prototype_name) .. "  "
  else
    before = ""
  end

  local name_str
  if show_internal_names then
    name_str = name
  else
    name_str = player_data.translations[class][name]
  end

  local after = rich_text("font", "default-semibold", rich_text("color", "heading", name_str)) .. "\n"

  if settings.general.tooltips.show_alternate_name then
    local alternate_name
    if show_internal_names then
      alternate_name = player_data.translations[class][name]
    else
      alternate_name = name
    end
    after = after .. rich_text("color", "green", alternate_name) .. "\n"
  end

  if catalyst_amount then
    after = after
      .. rich_text("font", "default-semibold", gui_translations.catalyst_amount .. ":")
      .. "  "
      .. number(catalyst_amount)
      .. "\n"
  end

  if settings.general.tooltips.show_descriptions then
    local description = player_data.translations[class .. "_description"][name]
    if description then
      after = after .. description .. "\n"
    end
  end

  after = after .. rich_text("color", "info", gui_translations[class])

  if not obj_properties.researched then
    after = after .. "  |  " .. rich_text("color", "unresearched", gui_translations.unresearched)
  end

  if not obj_properties.enabled then
    after = after .. "  |  " .. gui_translations.disabled
  end

  if obj_properties.hidden then
    after = after .. "  |  " .. gui_translations.hidden
  end

  local output = { before = before, after = after }
  cache[cache_key] = output
  return output
end

local function get_tooltip_deets(obj_data, player_data)
  local gui_translations = player_data.translations.gui

  local cache = caches[player_data.player_index]
  local cache_key = build_cache_key("tooltip_deets", obj_data.class, obj_data.name or obj_data.prototype_name)
  local cached = cache[cache_key]
  if cached then
    return cached
  end

  local deets_structure = constants.tooltips[obj_data.class]

  local output = ""

  for _, deet in pairs(deets_structure) do
    if deet.source ~= "group" then
      local values
      local type = deet.type
      if type == "plain" then
        values = { obj_data[deet.source] }
      elseif type == "list" then
        values = table.array_copy(obj_data[deet.source] or {})
      end

      local values_output = ""
      for _, value in pairs(values) do
        local fmtr = deet.formatter
        if fmtr then
          value = formatter[fmtr](value, gui_translations, player_data, deet.options)
        end
        if value then
          if type == "plain" then
            values_output = values_output .. "  " .. value
          elseif type == "list" then
            values_output = values_output .. "\n    " .. value
          end
        end
      end

      if #values_output > 0 then
        output = output
          .. "\n"
          .. rich_text("font", "default-semibold", gui_translations[deet.label or deet.source] .. ":")
          .. values_output
      end
    end
  end

  cache[cache_key] = output
  return output
end

local function get_interaction_helps(obj_data, player_data, options)
  local gui_translations = player_data.translations.gui

  local show_interaction_helps = player_data.settings.general.tooltips.show_interaction_helps

  local cache = caches[player_data.player_index]
  local cache_key = build_cache_key(
    "interaction_helps",
    obj_data.class,
    obj_data.name or obj_data.prototype_name,
    options.blueprint_result and options.blueprint_result.name .. (options.blueprint_result.recipe or "") or nil
  )
  local cached = cache[cache_key]
  if cached then
    return cached
  end

  local helps_output = ""

  local interactions = constants.interactions[obj_data.class]

  local num_interactions = 0

  for _, interaction in pairs(interactions) do
    local test = interaction.test
    if not test or test(obj_data, options) then
      local source = interaction.source
      if not source or obj_data[source] then
        num_interactions = num_interactions + 1
        if show_interaction_helps then
          local action = gui_translations[interaction.label or interaction.action]
          local input_name = table.reduce(interaction.modifiers, function(acc, modifier)
            return acc .. modifier .. "_"
          end, "") .. "click"
          local button = interaction.button
          if button then
            button = button .. "_"
          else
            button = ""
          end
          local label = rich_text(
            "font",
            "default-semibold",
            rich_text("color", "info", gui_translations[button .. input_name] .. ": ")
          )
          helps_output = helps_output .. "\n" .. label .. action
        end
      end
    end
  end

  local output = { output = helps_output, num_interactions = num_interactions }
  cache[cache_key] = output
  return output
end

local function get_obj_properties(obj_data, player_data, options)
  -- Player data
  local force = player_data.force
  local player_settings = player_data.settings
  local show_hidden = player_settings.general.content.show_hidden
  local show_unresearched = player_settings.general.content.show_unresearched
  local show_disabled = player_settings.general.content.show_disabled

  -- Actually get object properties
  local researched
  if obj_data.enabled_at_start then
    researched = true
  elseif obj_data.researched_forces then
    researched = obj_data.researched_forces[force.index] or false
  else
    researched = true
  end
  local enabled = true
  -- We have to get the current enabled status from the object itself
  -- Recipes are unlocked by "enabling" them, so only check a recipe if it's researched
  if obj_data.class == "recipe" and researched then
    enabled = player_data.force_recipes[obj_data.prototype_name].enabled
  elseif obj_data.class == "technology" then
    enabled = player_data.force_technologies[obj_data.prototype_name].enabled
  elseif obj_data.enabled ~= nil then
    enabled = obj_data.enabled
  end
  local obj_properties = { hidden = obj_data.hidden or false, researched = researched, enabled = enabled }

  -- Determine if we should show this object
  local should_show = false
  if options.always_show then
    should_show = true
  elseif
    (show_hidden or not obj_properties.hidden)
    and (show_unresearched or obj_properties.researched)
    and (show_disabled or obj_properties.enabled)
  then
    -- Indexing the plurals table is much faster than looping through the canonical table
    if constants.category_class_plurals[obj_data.class] then
      -- Check if this category is enabled
      if player_settings.categories[obj_data.class][obj_data.prototype_name] then
        should_show = true
      end
    else
      -- Check categories
      local good_categories = 0
      local has_categories = 0
      for _, category in pairs(constants.category_classes) do
        local obj_category = obj_data[category]
        local obj_categories = obj_data[constants.category_class_plurals[category]]
        if obj_category then
          has_categories = has_categories + 1
          if player_settings.categories[category][obj_category.name] then
            good_categories = good_categories + 1
          end
        elseif obj_categories and #obj_categories > 0 then -- Empty category lists pass by default
          has_categories = has_categories + 1
          local category_settings = player_settings.categories[category]
          if constants.category_all_match[category] then
            -- All categories must be enabled
            local matched_all = true
            for _, category_ident in pairs(obj_categories) do
              if not category_settings[category_ident.name] then
                matched_all = false
                break
              end
            end
            if matched_all then
              good_categories = good_categories + 1
            end
          else
            -- At least one category must be enabled
            for _, category_ident in pairs(obj_categories) do
              if category_settings[category_ident.name] then
                good_categories = good_categories + 1
                break
              end
            end
          end
        end
      end
      if good_categories == has_categories then
        should_show = true
      end
    end
  end
  return should_show and obj_properties or false
end

--- @class FormatOptions
local available_options = {
  hide_glyphs = false,
  base_tooltip_only = false,
  label_only = true,
  is_label = false,
  --- @type AmountIdent|boolean
  amount_ident = false,
  --- @type number|boolean
  rocket_parts_required = false,
  amount_only = false,
}

--- @param options FormatOptions
function formatter.format(obj_data, player_data, options)
  options = table.deep_merge({ available_options, options or {} })

  if options.is_label then
    options.hide_glyph = true
    options.base_tooltip_only = true
  end

  local obj_properties = get_obj_properties(obj_data, player_data, options)
  if not obj_properties then
    return false
  end

  local amount_ident = options.amount_ident

  -- Caption
  local caption_output
  if amount_ident and options.amount_only then
    caption_output = get_amount_string(amount_ident, player_data, options)
  else
    local caption = get_caption(obj_data, obj_properties, player_data, options)
    if amount_ident then
      caption_output = caption.before
        .. rich_text("font", "default-semibold", get_amount_string(amount_ident, player_data, options))
        .. "  "
        .. caption.after
    else
      caption_output = caption.before .. caption.after
    end
  end

  -- Tooltip
  local base_tooltip = get_base_tooltip(obj_data, obj_properties, player_data, options)
  local tooltip_output
  if amount_ident and options.amount_only then
    tooltip_output = base_tooltip.before
      .. rich_text(
        "font",
        "default-bold",
        rich_text("color", "heading", get_amount_string(amount_ident, player_data, {}))
      )
      .. "  "
      .. base_tooltip.after
  else
    tooltip_output = base_tooltip.before .. base_tooltip.after
  end
  local settings = player_data.settings
  if settings.general.tooltips.show_detailed_tooltips and not options.base_tooltip_only then
    tooltip_output = tooltip_output .. get_tooltip_deets(obj_data, player_data)
  end
  local num_interactions = 0
  if not options.base_tooltip_only then
    local helps_output = get_interaction_helps(obj_data, player_data, options)
    tooltip_output = tooltip_output .. helps_output.output
    num_interactions = helps_output.num_interactions
  end

  return {
    caption = caption_output,
    disabled = not obj_properties.enabled,
    hidden = obj_properties.hidden,
    num_interactions = num_interactions,
    researched = obj_properties.researched,
    tooltip = tooltip_output,
  }
end

function formatter.create_cache(player_index)
  caches[player_index] = {}
end

function formatter.create_all_caches()
  for i in pairs(global.players) do
    caches[i] = {}
  end
end

function formatter.build_player_data(player, player_table)
  return {
    force = player.force,
    force_recipes = player.force.recipes,
    force_technologies = player.force.technologies,
    player_index = player.index,
    settings = player_table.settings,
    translations = player_table.translations,
  }
end

formatter.area = area
formatter.build_cache_key = build_cache_key
formatter.control = control
formatter.energy = energy
formatter.energy_storage = energy_storage
formatter.expand_string = expand_string
formatter.fuel_value = fuel_value
formatter.number = number
formatter.object = object
formatter.percent = percent
formatter.per_second = per_second
formatter.rich_text = rich_text
formatter.seconds_from_ticks = seconds_from_ticks
formatter.seconds = seconds
formatter.sprite = sprite
formatter.temperature = temperature

setmetatable(formatter, {
  __call = function(_, ...)
    return formatter.format(...)
  end,
})

return formatter
