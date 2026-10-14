-- Builds achievement prototypes from the declarative tables in base-series.lua and catalog.lua.
-- Runs in data-final-fixes: products, qualities and the base achievements are final by then,
-- so existence checks and amounts read from other prototypes see the real mod set.

local GRAPHICS = "__MxlChievements-Reforged__/graphics/"

-- Quality variants of the base series, in display order. Missing or hidden qualities are skipped.
local QUALITY_VARIANTS = {"uncommon", "rare", "epic", "legendary"}

-- Catalog series without explicit amounts: 1M / 1G / 1T.
local DEFAULT_AMOUNTS = {1e6, 1e9, 1e12}

-- Tier frames of catalog series that show the product icon instead of an own picture.
local FRAMES = {"base.png", "base-silver.png", "base-gold.png"}
local FRAMED_PRODUCT_SCALE = 0.7

local NUMBER_UNITS = {{1e12, "trillion"}, {1e9, "billion"}, {1e6, "million"}, {1e3, "thousand"}}

local ITEM_TYPES = defines.prototypes and defines.prototypes.item or {
  ["item"] = 0, ["ammo"] = 0, ["armor"] = 0, ["blueprint"] = 0, ["blueprint-book"] = 0,
  ["capsule"] = 0, ["copy-paste-tool"] = 0, ["deconstruction-item"] = 0, ["gun"] = 0,
  ["item-with-entity-data"] = 0, ["item-with-inventory"] = 0, ["item-with-label"] = 0,
  ["item-with-tags"] = 0, ["module"] = 0, ["rail-planner"] = 0, ["repair-tool"] = 0,
  ["selection-tool"] = 0, ["space-platform-starter-pack"] = 0, ["spidertron-remote"] = 0,
  ["tool"] = 0, ["upgrade-item"] = 0,
}

local ACHIEVEMENT_TYPES = defines.prototypes and defines.prototypes.achievement or {
  ["achievement"] = 0, ["build-entity-achievement"] = 0, ["change-surface-achievement"] = 0,
  ["combat-robot-count-achievement"] = 0, ["complete-objective-achievement"] = 0,
  ["construct-with-robots-achievement"] = 0, ["create-platform-achievement"] = 0,
  ["deconstruct-with-robots-achievement"] = 0, ["deliver-by-robots-achievement"] = 0,
  ["deplete-resource-achievement"] = 0, ["destroy-cliff-achievement"] = 0,
  ["dont-build-entity-achievement"] = 0, ["dont-craft-manually-achievement"] = 0,
  ["dont-kill-manually-achievement"] = 0, ["dont-research-before-researching-achievement"] = 0,
  ["dont-use-entity-in-energy-production-achievement"] = 0, ["equip-armor-achievement"] = 0,
  ["group-attack-achievement"] = 0, ["kill-achievement"] = 0, ["module-transfer-achievement"] = 0,
  ["place-equipment-achievement"] = 0, ["player-damaged-achievement"] = 0,
  ["produce-achievement"] = 0, ["produce-per-hour-achievement"] = 0, ["research-achievement"] = 0,
  ["research-with-science-pack-achievement"] = 0, ["shoot-achievement"] = 0,
  ["space-connection-distance-traveled-achievement"] = 0, ["train-path-achievement"] = 0,
  ["use-entity-in-energy-production-achievement"] = 0, ["use-item-achievement"] = 0,
}

local function available(prototype)
  return prototype ~= nil and not prototype.hidden
end

local function achievement_exists(name)
  for type_name in pairs(ACHIEVEMENT_TYPES) do
    if data.raw[type_name] and data.raw[type_name][name] then return true end
  end
  return false
end

local function find_item(name)
  for type_name in pairs(ITEM_TYPES) do
    local prototype = data.raw[type_name] and data.raw[type_name][name]
    if prototype then return prototype end
  end
end

local function find_fluid(name)
  return data.raw.fluid and data.raw.fluid[name]
end

local function letter(index)
  return string.char(96 + index)
end

-- 2500000 -> {"mxlr-number.million", "2.5"}
local function number_text(amount)
  for _, unit in ipairs(NUMBER_UNITS) do
    if amount >= unit[1] then
      local mantissa = string.format("%.2f", amount / unit[1]):gsub("%.?0+$", "")
      return {"mxlr-number." .. unit[2], mantissa}
    end
  end
  return string.format("%d", amount)
end

local function product_name(product)
  if product.localised_name then return table.deepcopy(product.localised_name) end
  if product.type == "fluid" then return {"fluid-name." .. product.name} end
  local name = {"?", {"item-name." .. product.name}}
  if type(product.place_result) == "string" then
    table.insert(name, {"entity-name." .. product.place_result})
  end
  if type(product.place_as_equipment_result) == "string" then
    table.insert(name, {"equipment-name." .. product.place_as_equipment_result})
  end
  table.insert(name, product.name)
  return name
end

-- Rich-text icon and name of the product, with the quality when the achievement filters by it.
local function product_text(product, quality)
  if product.type == "fluid" then
    return {"", "[fluid=" .. product.name .. "] ", product_name(product)}
  end
  if not quality then
    return {"", "[item=" .. product.name .. "] ", product_name(product)}
  end
  local quality_prototype = data.raw.quality[quality]
  local quality_name = quality_prototype.localised_name and table.deepcopy(quality_prototype.localised_name)
    or {"quality-name." .. quality}
  return {"", "[item=" .. product.name .. ",quality=" .. quality .. "] ",
    {"mxlr.with-quality", product_name(product), quality_name}}
end

local function quality_badge(quality, shift)
  local quality_prototype = data.raw.quality[quality]
  local source = quality_prototype.icons and quality_prototype.icons[1] or quality_prototype
  local size = source.icon_size or 64
  return {icon = source.icon, icon_size = size, scale = 12 / size, shift = shift or {0, 26}}
end

local function scaled_shift(shift)
  if not shift then return nil end
  return {(shift[1] or shift.x) * FRAMED_PRODUCT_SCALE, (shift[2] or shift.y) * FRAMED_PRODUCT_SCALE}
end

local function framed_icons(tier, product, product_icon)
  local icons = {{icon = GRAPHICS .. FRAMES[tier], icon_size = 128, draw_background = false}}
  local layers = product_icon and {{icon = GRAPHICS .. product_icon.file, icon_size = product_icon.size}}
    or product.icons or {{icon = product.icon, icon_size = product.icon_size}}
  for _, source in ipairs(layers) do
    local layer = table.deepcopy(source)
    layer.icon_size = layer.icon_size or product.icon_size or 64
    layer.scale = (layer.scale or 64 / layer.icon_size) * FRAMED_PRODUCT_SCALE
    layer.shift = scaled_shift(layer.shift)
    layer.draw_background = false
    table.insert(icons, layer)
  end
  return icons
end

-- Sets the product with its quality filter, the quality badge and name prefix, and the description.
local function finish(achievement, product, quality, badge_shift)
  if product.type == "fluid" then
    achievement.fluid_product = product.name
  elseif quality then
    achievement.item_product = {name = product.name, quality = quality}
  else
    achievement.item_product = product.name
  end
  if quality then
    table.insert(achievement.icons, quality_badge(quality, badge_shift))
    achievement.localised_name = {"", "[img=quality/" .. quality .. "] ",
      achievement.localised_name or {"achievement-name." .. achievement.name}}
  end
  local key = achievement.type == "produce-per-hour-achievement" and "mxlr.produce-per-hour" or "mxlr.produce"
  achievement.localised_description = {key, number_text(achievement.amount), product_text(product, quality)}
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
  local product = find_item(series.item)
  local existing = data.raw[series.type]
  if not (available(product) and existing) then return end

  local tiers = {}
  for tier = 1, series.base_tiers do
    local base = existing[tier_name(series, tier)]
    if not base then return end -- the base ladder was changed by another mod: leave it alone
    tiers[tier] = {base = base, amount = base.amount,
      name = base.localised_name or {"achievement-name." .. base.name}}
  end
  for index, amount in ipairs(series.extra) do
    local tier = series.base_tiers + index
    if amount <= tiers[tier - 1].amount then
      log(string.format("MxlChievements-Reforged: %s tier %d (%s) is not above tier %d (%s)",
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
          {icon = GRAPHICS .. "tier-" .. marker .. ".png", icon_size = 128, shift = series.marker_shift})
      end
      achievement.order = string.format("%s-%s%s", series.order, letter(tier), letter(variant))
      achievement.localised_name = table.deepcopy(info.name)
      finish(achievement, product, quality, series.badge_shift)
      if achievement ~= info.base then table.insert(output, achievement) end
    end
  end
end

local function entry_icons(entry, tier, product)
  if entry[3] then
    return {{icon = GRAPHICS .. string.format(entry[3], tier) .. ".png", icon_size = 128}}
  end
  return framed_icons(tier, product, entry.product_icon)
end

-- One catalog line: a series of produce, produce-per-hour or train-path achievements.
local function build_entry(entry, index, context, output)
  local prefix = entry[1]
  local order = string.format("z[mxl]-%03d-", index)

  if entry.train then
    for tier, distance in ipairs(entry.train) do
      table.insert(output, {
        type = "train-path-achievement",
        name = prefix .. "-" .. tier,
        minimum_distance = distance,
        order = order .. letter(tier),
        icons = entry_icons(entry, tier),
        localised_description = {"mxlr.train-path", number_text(distance)},
      })
    end
    return
  end

  local product
  if entry.fluid then
    product = find_fluid(entry.fluid)
  else
    product = find_item(entry[2] or prefix)
  end
  if not available(product) then return end

  local quality = entry.quality
  if quality and not context.normal then
    if quality ~= "normal" then return end -- a quality-only achievement without the quality mod
    quality = nil
  end
  if quality and not available(data.raw.quality[quality]) then return end

  for tier, amount in ipairs(entry.amounts or DEFAULT_AMOUNTS) do
    local achievement = {
      type = entry.per_hour and "produce-per-hour-achievement" or "produce-achievement",
      name = entry.single and prefix or prefix .. "-" .. tier,
      amount = amount,
      order = order .. letter(tier),
      icons = entry_icons(entry, tier, product),
    }
    finish(achievement, product, quality)
    table.insert(output, achievement)
  end
end

local function quality_variants()
  local result = {}
  for _, name in ipairs(QUALITY_VARIANTS) do
    if available(data.raw.quality and data.raw.quality[name]) then table.insert(result, name) end
  end
  return result
end

local builder = {}

function builder.build(base_series, catalog)
  local qualities = quality_variants()
  local context = {qualities = qualities, normal = #qualities > 0 and "normal" or nil}

  local output = {}
  for _, series in ipairs(base_series) do
    build_series(series, context, output)
  end
  for index, entry in ipairs(catalog) do
    build_entry(entry, index, context, output)
  end

  local names = {}
  local accepted = {}
  for _, achievement in ipairs(output) do
    if names[achievement.name] then
      error("MxlChievements-Reforged: duplicate achievement name " .. achievement.name)
    end
    names[achievement.name] = true
    if achievement_exists(achievement.name) then
      log("MxlChievements-Reforged: skipped " .. achievement.name .. ", another mod already defines it")
    else
      table.insert(accepted, achievement)
    end
  end
  data:extend(accepted)
end

return builder
