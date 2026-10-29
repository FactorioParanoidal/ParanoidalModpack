-- Alt-mode labels over locomotives: "MU pair +N%" over paired locomotives, a grey "no pair" over a
-- locomotive of a two-way train that pulls in one direction only. Visible only to its force and only to players with the label setting on.
-- storage.labels: unit_number -> render object id. A label dies with its locomotive; the entry is
-- dropped by on_object_destroyed.
local shared = require("shared")

local M = {}

local PAIR_COLOR = {r = 1, g = 0.82, b = 0.25}
local SINGLE_COLOR = {r = 0.65, g = 0.65, b = 0.65}
local OFFSET = {0, -1.5}

local function look(label)
  if label.kind == "pair" then
    return {"", "[img=" .. shared.sprite .. "] ", {"mutc.label-pair", label.bonus}}, PAIR_COLOR
  end
  return {"mutc.label-single" .. (label.reason and ("-" .. label.reason) or "")}, SINGLE_COLOR
end

-- players list (nil = everyone of the force) and visibility for the labels of a force
local function audience(force, cache)
  local known = cache[force.index]
  if not known then
    local list, everyone = {}, true
    for _, player in pairs(force.players) do
      if player.mod_settings[shared.setting_labels].value then
        list[#list + 1] = player
      else
        everyone = false
      end
    end
    known = everyone and {players = nil, visible = true} or {players = list, visible = #list > 0}
    if #list == 0 then known.players = nil end
    cache[force.index] = known
  end
  return known.players, known.visible
end

local function object(unit)
  local id = storage.labels[unit]
  local label = id and rendering.get_object_by_id(id)
  if label and label.valid then return label end
  storage.labels[unit] = nil
end

-- Sets the labels of all locomotives of a train; wanted: unit_number -> label (see planner.plan).
function M.apply(train, wanted)
  local cache = {}
  for _, carriage in ipairs(train.carriages) do
    if carriage.type == "locomotive" then
      local unit = carriage.unit_number
      local label, current = wanted[unit], object(unit)
      if label then
        local text, color = look(label)
        if current then
          current.text = text
          current.color = color
        else
          local players, visible = audience(carriage.force, cache)
          storage.labels[unit] = rendering.draw_text({
            text = text, color = color, surface = carriage.surface,
            target = {entity = carriage, offset = OFFSET},
            forces = {carriage.force}, players = players, visible = visible,
            only_in_alt_mode = true, use_rich_text = true,
            alignment = "center", vertical_alignment = "middle",
          }).id
          script.register_on_object_destroyed(carriage)
        end
      elseif current then
        current.destroy()
        storage.labels[unit] = nil
      end
    end
  end
end

-- Re-applies the per-player label setting after it, a player or a force changed.
function M.refresh_audience()
  local cache = {}
  for unit in pairs(storage.labels) do
    local label = object(unit)
    local entity = label and label.target and label.target.entity
    if entity and entity.valid then
      local players, visible = audience(entity.force, cache)
      label.players = players
      label.visible = visible
    elseif label then
      label.destroy()
      storage.labels[unit] = nil
    end
  end
end

function M.forget(unit)
  storage.labels[unit] = nil
end

-- Drops entries whose render object is gone.
function M.cleanup()
  for unit in pairs(storage.labels) do object(unit) end
end

return M
