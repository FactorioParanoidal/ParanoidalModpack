-- What a technology gives besides unlocked recipes, its cost and research time, as texts built from the
-- engine's own locale ([modifier-description]) so names match the vanilla research screen.
local M = {}

-- Modifier types whose value is a fraction shown in percent; the other numeric ones are plain numbers.
local PERCENT = {["ammo-damage"]=true, ["gun-speed"]=true, ["turret-attack"]=true, ["laboratory-speed"]=true,
  ["laboratory-productivity"]=true, ["mining-drill-productivity-bonus"]=true, ["train-braking-force-bonus"]=true,
  ["worker-robot-speed"]=true, ["worker-robot-battery"]=true, ["character-crafting-speed"]=true,
  ["character-mining-speed"]=true, ["character-running-speed"]=true, ["follower-robot-lifetime"]=true,
  ["artillery-range"]=true, ["beacon-distribution"]=true, ["change-recipe-productivity"]=true}

local function whole(v) return math.abs(v - math.floor(v + 0.5)) < 1e-6 end

local function number(v, percent)
  if percent then
    local x = v * 100
    if whole(x) then return string.format("%d%%", math.floor(x + 0.5)) end
    return string.format("%.1f%%", x)
  end
  if whole(v) then return string.format("%d", math.floor(v + 0.5)) end
  return string.format("%.2f", v)
end
M.number = number

-- Locale key of a modifier in [modifier-description]; damage, speed and turret bonuses are named by category.
local function key_of(e)
  if e.type == "ammo-damage" and e.ammo_category then return e.ammo_category .. "-damage-bonus" end
  if e.type == "gun-speed" and e.ammo_category then return e.ammo_category .. "-shooting-speed-bonus" end
  if e.type == "turret-attack" and e.turret_id then return e.turret_id .. "-attack-bonus" end
  return e.type
end

local function icon_of(e)
  local sprite = "utility/" .. string.gsub(e.type, "-", "_") .. "_modifier_icon"
  if helpers.is_valid_sprite_path(sprite) then return sprite end
  return nil
end

local function named(kind, name, proto)
  if not proto then return name or "" end
  return {"", "[" .. kind .. "=" .. name .. "] ", proto.localised_name}
end

-- Effects other than unlocked recipes: list of {sprite = path or nil, text = LocalisedString}.
-- A key missing in the locale falls back to the plain effect type with its value ({"?", ...}).
function M.bonuses(t)
  local list = {}
  for _, e in ipairs(t.prototype.effects or {}) do
    local text
    if e.hidden or e.type == "unlock-recipe" then
      text = nil
    elseif e.type == "nothing" then
      text = e.effect_description
    elseif e.type == "give-item" then
      text = {"ptt.effect-give-item", named("item", e.item, prototypes.item[e.item]), e.count or 1}
    elseif e.type == "change-recipe-productivity" then
      text = {"modifier-description.change-recipe-productivity",
        named("recipe", e.recipe, prototypes.recipe[e.recipe]), "+" .. number(e.change or 0, true)}
    elseif e.type == "unlock-quality" then
      text = {"modifier-description.unlock-quality", named("quality", e.quality, prototypes.quality[e.quality])}
    elseif e.type == "unlock-space-location" then
      text = {"modifier-description.space-location-discovery", e.space_location or ""}
    elseif type(e.modifier) == "number" then
      local value = number(e.modifier, PERCENT[e.type])
      text = {"?", {"modifier-description." .. key_of(e), value}, {"", e.type, ": +", value}}
    else
      text = {"?", {"modifier-description." .. e.type}, e.type}
    end
    if text then list[#list + 1] = {sprite = icon_of(e), text = text} end
  end
  return list
end

function M.recipes(t)
  local list = {}
  for _, e in ipairs(t.prototype.effects or {}) do
    if e.type == "unlock-recipe" and prototypes.recipe[e.recipe] then list[#list + 1] = e.recipe end
  end
  return list
end

-- Seconds for one lab of speed 1 with the force's research speed bonus.
function M.seconds(force, t)
  if t.prototype.research_trigger then return 0 end
  local base = (t.research_unit_count or 0) * (t.research_unit_energy or 0) / 60
  return base / (1 + math.max(0, force.laboratory_speed_modifier or 0))
end

function M.duration(seconds)
  seconds = math.floor(seconds + 0.5)
  local h, m, s = math.floor(seconds / 3600), math.floor(seconds % 3600 / 60), seconds % 60
  if h > 0 then return {"ptt.time-hm", h, m} end
  if m > 0 then
    if s > 0 then return {"ptt.time-ms", m, s} end
    return {"ptt.time-m", m}
  end
  return {"ptt.time-s", s}
end

-- Cost as rich text for tooltips: "[item=…] 50 [item=…] 50" (totals for all units).
function M.cost_text(t)
  if t.prototype.research_trigger then return nil end
  local parts = {}
  for _, i in ipairs(t.research_unit_ingredients or {}) do
    parts[#parts + 1] = "[item=" .. i.name .. "] " .. number(i.amount * (t.research_unit_count or 0)) .. "  "
  end
  if #parts == 0 then return nil end
  return table.concat(parts)
end

-- Unlocked recipes as icons for tooltips (at most `limit`, with a "+N" tail).
function M.recipes_text(t, limit)
  local list = M.recipes(t)
  if #list == 0 then return nil end
  local parts = {}
  for i = 1, math.min(#list, limit) do parts[#parts + 1] = "[recipe=" .. list[i] .. "]" end
  if #list > limit then parts[#parts + 1] = " +" .. (#list - limit) end
  return table.concat(parts)
end

return M
