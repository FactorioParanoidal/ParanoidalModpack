-- Match the actual noise owner; require a new forecast anchor and nonempty charted field resources.
local M = {}
local event = script.generate_event_name()
function M.get_event() return event end
local function chunk_key(x, y) return math.floor(x / 32) .. ":" .. math.floor(y / 32) end
local function force_table(name, surface, force)
  storage[name] = storage[name] or {}
  local all = storage[name];all[surface] = all[surface] or {};all[surface][force] = all[surface][force] or {}
  return all[surface][force]
end
local function index(anchors, key, site, observation)
  site.anchors = site.anchors or {}
  local observation_key = chunk_key(observation.x, observation.y)
  site.anchors[observation_key] = observation
  anchors[observation_key] = anchors[observation_key] or {};anchors[observation_key][key] = true
end
function M.remember(surface, force, site, mark_key, info)
  local ci, cj = info.prefix .. "ci", info.prefix .. "cj"
  local owner = surface.calculate_tile_properties({ci, cj}, {{site.x, site.y}})
  if not (owner[ci] and owner[cj]) then return end
  local i, j = math.floor(owner[ci][1] + 0.5), math.floor(owner[cj][1] + 0.5)
  local key = i .. ":" .. j
  local pending = force_table("survey_pending", surface.index, force)
  local value = pending[key] or {ci = i, cj = j, x = site.x, y = site.y, radius = site.radius,
    resource = site.name, partner = site.partner}
  pending[key] = value
  index(force_table("survey_anchors", surface.index, force), key, value, {x = site.x, y = site.y, mark_key = mark_key})
end
function M.clear(surface)
  if storage.survey_pending then storage.survey_pending[surface] = nil end
  if storage.survey_anchors then storage.survey_anchors[surface] = nil end
end
function M.merge(e)
  for _, name in ipairs({"survey_pending", "survey_anchors"}) do
    for _, forces in pairs(storage[name] or {}) do forces[e.source_index] = nil end
  end
end
local function finish(pending, anchors, key, site, surface, force)
  if not (site.confirmed_anchor and site.verified_resource) then return end
  pending[key] = nil -- consume all matching forecasts before callbacks
  local marks = storage.forecasts and storage.forecasts[surface]
  for anchor_key, observation in pairs(site.anchors) do
    local group = anchors[anchor_key]
    if group then group[key] = nil;if next(group) == nil then anchors[anchor_key] = nil end end
    local forces = marks and marks[observation.mark_key]
    local label = forces and forces[force]
    if label then
      if label.valid then label.destroy() end
      forces[force] = nil;if next(forces) == nil then marks[observation.mark_key] = nil end
    end
  end
  script.raise_event(event, {force_index = force, surface_index = surface,
    resource = site.verified_resource, field_x = site.confirmed_anchor.x, field_y = site.confirmed_anchor.y})
end
function M.chart(e, surface, info)
  local force, si = e.force.index, e.surface_index
  local by_force = storage.survey_pending and storage.survey_pending[si]
  local pending = by_force and by_force[force]
  if not (info and pending and next(pending)) then return end
  local anchors = force_table("survey_anchors", si, force)
  local current_key = e.position.x .. ":" .. e.position.y
  for key in pairs(anchors[current_key] or {}) do
    local site = pending[key]
    if site then site.confirmed_anchor = site.anchors[current_key];finish(pending, anchors, key, site, si, force) end
    if not surface.valid or not e.force.valid or by_force[force] ~= pending then return end
  end
  if next(pending) == nil then return end
  local positions, resources = {}, {}
  for _, entity in ipairs(surface.find_entities_filtered{area = e.area, type = "resource"}) do
    local p = entity.position
    if entity.amount > 0 and p.x >= e.area.left_top.x and p.x < e.area.right_bottom.x
      and p.y >= e.area.left_top.y and p.y < e.area.right_bottom.y then
      resources[#resources + 1] = entity;positions[#positions + 1] = p
    end
  end
  if #positions == 0 then return end
  local ci, cj = info.prefix .. "ci", info.prefix .. "cj"
  local owners = surface.calculate_tile_properties({ci, cj}, positions)
  if not (owners[ci] and owners[cj]) then return end
  for i, entity in ipairs(resources) do
    if not surface.valid or not e.force.valid or by_force[force] ~= pending then return end
    local key = math.floor(owners[ci][i] + 0.5) .. ":" .. math.floor(owners[cj][i] + 0.5)
    local site = pending[key]
    local name = entity.valid and entity.amount > 0 and entity.name
    if site and name and (name == site.resource or name == site.partner or name == "infinite-" .. site.resource
      or (site.partner and name == "infinite-" .. site.partner)) then
      site.verified_resource = name
      finish(pending, anchors, key, site, si, force)
    end
  end
end
return M
