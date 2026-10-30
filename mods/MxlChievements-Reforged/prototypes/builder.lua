-- Builds all achievements of the mod in data-final-fixes, when products, qualities and the base
-- achievements are final:
--   base-series.lua  ladders that continue base game achievements, with quality variants
--   catalog.lua      production series of MxlChievements
--   content/*.lua    new achievements by theme, see kinds.lua for the entry kinds
--   scripted.lua     achievements unlocked by control.lua
-- Achievements are an addition to the game: a missing target, a broken entry or a name taken by
-- another mod only skips that entry with a log line and never stops the game from loading.

local util = require("prototypes.util")
local kinds = require("prototypes.kinds")
local naming = require("prototypes.naming")

local LOG_PREFIX = "MxlChievements-Reforged: "

-- Quality variants of the base series, in display order. Missing or hidden qualities are skipped.
local QUALITY_VARIANTS = {"uncommon", "rare", "epic", "legendary"}

-- Catalog series without explicit amounts: 1M / 1G / 1T.
local DEFAULT_AMOUNTS = {1e6, 1e9, 1e12}

local skipped = {}

-- Optional flavor line under the generated condition: "mxlr-flavor.<achievement name>". The locale
-- value starts with "\n"; a language without the key shows the condition only.
local function add_flavor(achievement)
  if not achievement.localised_description then return end
  achievement.localised_description = {"", achievement.localised_description,
    {"?", {"mxlr-flavor." .. achievement.name}, ""}}
end

local function skip(name, reason)
  table.insert(skipped, name .. " (" .. tostring(reason) .. ")")
end

-- Sets the product with its quality filter, the quality badge and name prefix, and the description.
local function finish(achievement, product, quality, badge_shift)
  local family = product.type == "fluid" and "fluid" or "item"
  if family == "fluid" then
    achievement.fluid_product = product.name
  elseif quality then
    achievement.item_product = {name = product.name, quality = quality}
  else
    achievement.item_product = product.name
  end
  if quality then
    local badge = util.quality_badge(quality, badge_shift)
    if badge then table.insert(achievement.icons, badge) end
    achievement.localised_name = {"", "[img=quality/" .. quality .. "] ",
      achievement.localised_name or {"achievement-name." .. achievement.name}}
  end
  local key = achievement.type == "produce-per-hour-achievement" and "mxlr.produce-per-hour" or "mxlr.produce"
  achievement.localised_description = {key, util.number_text(achievement.amount),
    util.text_of(product, family, quality)}
  add_flavor(achievement)
  if achievement.type == "produce-achievement" and achievement.limited_to_one_game == nil then
    achievement.limited_to_one_game = false
  end
end

local function tier_name(series, tier)
  if tier == 1 and series.unsuffixed_first then return series.name end
  return series.name .. "-" .. tier
end

-- A base-game ladder: base tiers are updated in place, extra tiers and quality variants are new.
local function build_series(series, context, output)
  local product = util.item(series.item)
  local existing = data.raw[series.type]
  if not (util.available(product) and existing) then return skip(series.name, "product or type missing") end

  local tiers = {}
  for tier = 1, series.base_tiers do
    local base = existing[tier_name(series, tier)]
    if not base then return skip(series.name, "base ladder changed by another mod") end
    tiers[tier] = {base = base, amount = base.amount,
      name = base.localised_name or {"achievement-name." .. base.name}}
  end
  for index, amount in ipairs(series.extra) do
    local tier = series.base_tiers + index
    if amount <= tiers[tier - 1].amount then
      log(string.format("%s%s tier %d (%s) is not above tier %d (%s)", LOG_PREFIX,
        series.name, tier, amount, tier - 1, tiers[tier - 1].amount))
    end
    tiers[tier] = {amount = amount, name = {"mxlr.tier", {"mxlr-series." .. series.name}, tostring(tier)}}
  end

  for tier, info in ipairs(tiers) do
    -- variant 1 is the plain ladder (normal quality when quality exists), then quality variants
    for variant = 1, #context.qualities + 1 do
      local quality = variant == 1 and context.normal or context.qualities[variant - 1]
      local achievement = variant == 1 and info.base or {type = series.type}
      achievement.name = variant == 1 and tier_name(series, tier) or series.name .. "-" .. tier .. "-" .. quality
      achievement.amount = info.amount
      achievement.icon, achievement.icon_size = nil, nil
      achievement.icons = {{icon = string.format(series.icon, (tier - 1) % series.base_tiers + 1), icon_size = 128}}
      if tier > series.base_tiers then
        local marker = math.min(math.ceil(tier / series.base_tiers), 3)
        table.insert(achievement.icons,
          {icon = util.GRAPHICS .. "tier-" .. marker .. ".png", icon_size = 128, shift = series.marker_shift})
      end
      achievement.order = string.format("%s-%s%s", series.order, util.letter(tier), util.letter(variant))
      achievement.localised_name = table.deepcopy(info.name)
      finish(achievement, product, quality, series.badge_shift)
      if achievement ~= info.base then table.insert(output, achievement) end
    end
  end
end

local function catalog_icons(entry, tier, product)
  if entry[3] then
    return {{icon = util.GRAPHICS .. string.format(entry[3], tier) .. ".png", icon_size = 128}}
  end
  local inner
  if entry.product_icon then
    inner = {{icon = util.GRAPHICS .. entry.product_icon.file, icon_size = entry.product_icon.size,
      scale = 64 / entry.product_icon.size * 0.7, draw_background = false}}
  else
    inner = product and util.icon_layers(product, product.type == "fluid" and "fluid" or "item")
  end
  return util.framed(tier, inner)
end

-- One line of catalog.lua: a series of produce, produce-per-hour or train-path achievements.
local function build_catalog_entry(entry, index, context, output)
  local prefix = entry[1]
  local order = string.format("z[mxl]-%03d-", index)

  if entry.train then
    for tier, distance in ipairs(entry.train) do
      table.insert(output, {
        type = "train-path-achievement",
        name = prefix .. "-" .. tier,
        minimum_distance = distance,
        order = order .. util.letter(tier),
        icons = catalog_icons(entry, tier),
        localised_description = {"mxlr.train-path", util.number_text(distance)},
      })
      add_flavor(output[#output])
    end
    return
  end

  local product = entry.fluid and util.fluid(entry.fluid) or util.item(entry[2] or prefix)
  if not util.available(product) then return skip(prefix, "product missing or hidden") end

  local quality = entry.quality
  if quality and not context.normal then
    if quality ~= "normal" then return skip(prefix, "quality mod is off") end
    quality = nil
  end
  if quality and not util.available(util.quality(quality)) then return skip(prefix, "quality missing") end

  for tier, amount in ipairs(entry.amounts or DEFAULT_AMOUNTS) do
    local achievement = {
      type = entry.per_hour and "produce-per-hour-achievement" or "produce-achievement",
      name = entry.single and prefix or prefix .. "-" .. tier,
      amount = amount,
      order = order .. util.letter(tier),
      icons = catalog_icons(entry, tier, product),
    }
    finish(achievement, product, quality)
    table.insert(output, achievement)
  end
end

local function missing_mods(entry)
  for _, mod in ipairs(entry.mods or {}) do
    if not mods[mod] then return mod end
  end
end

-- One entry of content/*.lua or scripted.lua.
local function build_content_entry(entry, order, output)
  local kind = kinds[entry.kind]
  if not kind then return skip(entry.id, "unknown kind " .. tostring(entry.kind)) end
  local mod = missing_mods(entry)
  if mod then return skip(entry.id, "mod " .. mod .. " is off") end
  local target, reason = kind.resolve(entry)
  if not target then return skip(entry.id, reason) end

  local amounts = naming.amounts(entry)
  local tiered = naming.tiered(entry)
  local inner = kinds.icon_layers(entry, target)
  local name_label = entry.name_key and target.name_label
  if entry.name_key and entry.name_from_quality then name_label = util.name_of(util.quality(entry.quality), "quality") end
  local name_key = "mxlr-name." .. (entry.name_key or entry.id)
  local description_key = "mxlr-description." .. (entry.description or entry.name_key or entry.id)

  for tier, amount in ipairs(amounts) do
    local achievement = {type = kind.type, name = naming.name(entry, tier), order = order .. util.letter(tier)}
    kind.apply(achievement, entry, target, amount)

    if entry.icon and entry.icon.picture then
      achievement.icons = {{icon = util.GRAPHICS .. string.format(entry.icon.picture, tier) .. ".png", icon_size = 128}}
    else
      achievement.icons = util.framed(entry.frames and entry.frames[tier] or entry.frame or tier, inner)
    end
    if entry.quality and entry.quality ~= "normal" then
      local badge = util.quality_badge(entry.quality)
      if badge then table.insert(achievement.icons, badge) end
    end

    local base_name = name_label and {name_key, name_label} or {name_key}
    achievement.localised_name = tiered and {"mxlr.tier", base_name, tostring(tier)} or base_name
    local amount_text = kind.amount_text and kind.amount_text(amount) or util.number_text(amount)
    achievement.localised_description = kind.describe and not entry.description and kind.describe(entry, target, amount)
      or {description_key, amount_text, target.label or ""}
    add_flavor(achievement)

    if kind.fight or entry.fight then achievement.allowed_without_fight = false end
    table.insert(output, achievement)
  end
end

local function quality_variants()
  local result = {}
  for _, name in ipairs(QUALITY_VARIANTS) do
    if util.available(util.quality(name)) then table.insert(result, name) end
  end
  return result
end

-- Runs one builder step; an error inside it is logged and the step is skipped.
local function protected(name, fn, ...)
  local ok, err = pcall(fn, ...)
  if not ok then skip(name, "error: " .. tostring(err)) end
end

local builder = {}

-- themes: array of {key, entries} in display order.
function builder.build(base_series, catalog, themes)
  local qualities = quality_variants()
  local context = {qualities = qualities, normal = #qualities > 0 and "normal" or nil}

  local output = {}
  for _, series in ipairs(base_series) do
    protected(series.name, build_series, series, context, output)
  end
  for index, entry in ipairs(catalog) do
    protected(tostring(entry[1]), build_catalog_entry, entry, index, context, output)
  end
  for theme_index, theme in ipairs(themes or {}) do
    for index, entry in ipairs(theme.entries) do
      local order = string.format("z[mxlr]-%s[%s]-%03d-", util.letter(theme_index), theme.key, index)
      protected(tostring(entry.id), build_content_entry, entry, order, output)
    end
  end

  local accepted = {}
  for _, achievement in ipairs(output) do
    if util.achievement_exists(achievement.name) then
      skip(achievement.name, "name already used")
    else
      util.mark_achievement(achievement.name)
      table.insert(accepted, achievement)
    end
  end
  data:extend(accepted)

  log(LOG_PREFIX .. #accepted .. " achievements added, " .. #skipped .. " entries skipped")
  if #skipped > 0 then log(LOG_PREFIX .. "skipped: " .. table.concat(skipped, "; ")) end
end

return builder
