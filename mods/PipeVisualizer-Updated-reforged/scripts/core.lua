-- Visualization state and drawing. No event registration and no LuaPlayer access here: control.lua
-- translates player actions into calls of this module.

local protos = require("__PipeVisualizer-Updated-reforged__.scripts.protos")

local core = {}

local MAX_ORDER = protos.MAX_ORDER
local DEFAULT_COLOR = protos.DEFAULT_COLOR
local DEFAULT_SYSTEM = { color = DEFAULT_COLOR, order = MAX_ORDER }
local palette = protos.palette
local fluid_color = protos.fluid_color
local fluid_order = protos.fluid_order
local info_of = protos.info

local floor = math.floor
local bor = bit32.bor

local NORTH, EAST, SOUTH, WEST =
  defines.direction.north, defines.direction.east, defines.direction.south, defines.direction.west
local DIR_BIT = { [NORTH] = 1, [EAST] = 2, [SOUTH] = 4, [WEST] = 8 }
local ORIENTATION = { [NORTH] = 0, [EAST] = 0.25, [SOUTH] = 0.5, [WEST] = 0.75 }
local OPPOSITE = { [NORTH] = SOUTH, [EAST] = WEST, [SOUTH] = NORTH, [WEST] = EAST }
local PIPE_SPRITE, PIPE_CHART_SPRITE = {}, {}
for mask = 0, 15 do
  PIPE_SPRITE[mask] = "pv-pipe-connections-" .. mask
  PIPE_CHART_SPRITE[mask] = "pv-pipe-connections-" .. mask .. "-chart"
end
local ARROW_SPRITE = {
  input = "pv-fluid-arrow-input",
  output = "pv-fluid-arrow-output",
  ["input-output"] = "pv-fluid-arrow-input-output",
}

-- Underground dashes repeat the former per-tile sprite: two 0.1875-tile dashes per tile, centred
-- 0.25 tile from the tile centre, between the two pipe-to-ground ends. On the map the former sprites
-- were 4x larger and overlapped into one dash per tile.
local UG_DASH, UG_GAP, UG_INSET = 0.1875, 0.3125, 0.65625
local UG_MAP_DASH, UG_MAP_GAP, UG_MAP_OUTSET = 0.75, 0.25, 0.375

-- Reused argument tables: the API copies them, so one table per kind avoids allocations.
local box_target, pipe_target, arrow_target = { x = 0, y = 0 }, { x = 0, y = 0 }, { x = 0, y = 0 }
local box_args = { sprite = "pv-entity-box", render_layer = "192", target = box_target, x_scale = 1, y_scale = 1 }
local box_map_args = {
  sprite = "pv-entity-box", render_layer = "arrow", render_mode = "chart", target = box_target, x_scale = 1, y_scale = 1,
}
local pipe_args = { render_layer = "194", target = pipe_target, x_scale = 1, y_scale = 1 }
local pipe_map_args = { render_layer = "arrow", render_mode = "chart", target = pipe_target, x_scale = 1, y_scale = 1 }
local arrow_args = { render_layer = "195", target = arrow_target, orientation = 0 }
local arrow_map_args = {
  render_layer = "arrow", render_mode = "chart", target = arrow_target, orientation = 0, x_scale = 4, y_scale = 4,
}
local line_from, line_to, map_from, map_to = { x = 0, y = 0 }, { x = 0, y = 0 }, { x = 0, y = 0 }, { x = 0, y = 0 }
local line_args = { width = 5, from = line_from, to = line_to, dash_length = UG_DASH, gap_length = UG_GAP }
local line_map_args = {
  width = 24, from = map_from, to = map_to, dash_length = UG_MAP_DASH, gap_length = UG_MAP_GAP, render_mode = "chart",
}
local scan_area = { left_top = { x = 0, y = 0 }, right_bottom = { x = 0, y = 0 } }
local scan_filter = { area = scan_area, name = protos.fluid_name_list, force = 0 }

--- Called when the set of needed event handlers may have changed. Set by control.lua.
local notify = function() end

--- @param fn fun()
function core.set_notify(fn)
  notify = fn
end

-- State ------------------------------------------------------------------------------------------

--- @class PvSystem
--- @field color Color
--- @field order integer Lower wins when an entity belongs to several systems.
--- @field hover boolean Shown by mouse-over (removed when the cursor leaves) rather than pinned.
--- @field members table<uint, true>? Units drawn for this system (systems mode only).

--- @class PvRecord
--- @field entity LuaEntity
--- @field surface uint
--- @field shape LuaRenderObject
--- @field map LuaRenderObject?
--- @field mask integer? Pipe connection mask.
--- @field segs table<uint, true>? Systems drawn on this entity (systems mode only).
--- @field objs table? Arrows and dashes: per system lists in systems mode, one flat list in the overlay.
--- @field ug table<uint, true>? Partner units this entity drew an underground line to.
--- @field chunk integer? Overlay chunk key.

--- @class PvOverlay
--- @field surface uint
--- @field surf LuaSurface
--- @field force uint
--- @field kx integer Half width in chunks (excluding the centre chunk).
--- @field ky integer
--- @field cx integer? Centre chunk.
--- @field cy integer?
--- @field background LuaRenderObject
--- @field map_background LuaRenderObject?
--- @field chunks table<integer, uint[]> Scanned chunks -> units found there.
--- @field sq integer[] Chunks waiting for a scan.
--- @field sfirst integer
--- @field slast integer
--- @field rq integer[] Chunks waiting for removal.
--- @field rfirst integer
--- @field rlast integer
--- @field rmark table<integer, true>

--- @class PvViewer
--- @field index uint
--- @field players uint[]? Render visibility.
--- @field mode "systems"|"overlay"|nil
--- @field systems table<uint, PvSystem>
--- @field entities table<uint, PvRecord>
--- @field qe LuaEntity[] Queue of entities to draw.
--- @field qu uint[] Their units.
--- @field qfirst integer
--- @field qlast integer
--- @field queued table<uint, true|integer> Queued units (overlay: their chunk key).
--- @field redraw table<uint, true> Queued units to draw from scratch.
--- @field next_color integer
--- @field overlay PvOverlay?
--- @field mouseover boolean
--- @field by_system boolean
--- @field show_map boolean
--- @field color_pumps boolean

function core.init()
  storage.viewers = storage.viewers or {}
  storage.active = storage.active or {}
  storage.blacklist = storage.blacklist or {}
  storage.pipelist = storage.pipelist or {}
  storage.complexlist = storage.complexlist or {}
end

--- @param index uint
--- @return PvViewer
function core.viewer(index)
  local V = storage.viewers[index]
  if not V then
    V = {
      index = index,
      players = { index },
      systems = {},
      entities = {},
      qe = {},
      qu = {},
      qfirst = 1,
      qlast = 0,
      queued = {},
      redraw = {},
      next_color = 0,
      mouseover = false,
      by_system = false,
      show_map = true,
      color_pumps = true,
    }
    storage.viewers[index] = V
  end
  return V
end

--- @param V PvViewer
local function activate(V)
  local active = storage.active
  if not active[V.index] then
    active[V.index] = true
    notify()
  end
end

--- @param V PvViewer
--- @param mode "systems"|"overlay"|nil
local function set_mode(V, mode)
  if V.mode ~= mode then
    V.mode = mode
    notify()
  end
end

--- @param V PvViewer
--- @param entity LuaEntity
--- @param unit uint
--- @param tag true|integer
local function push(V, entity, unit, tag)
  local last = V.qlast + 1
  V.qlast = last
  V.qe[last] = entity
  V.qu[last] = unit
  V.queued[unit] = tag
  activate(V)
end

--- Queues an entity to be drawn from scratch.
--- @param V PvViewer
--- @param entity LuaEntity
--- @param unit uint
--- @param tag true|integer
local function push_redraw(V, entity, unit, tag)
  V.redraw[unit] = true
  if not V.queued[unit] then
    push(V, entity, unit, tag)
  end
end

--- @param list LuaRenderObject[]
local function destroy_list(list)
  for i = 1, #list do
    list[i].destroy()
  end
end

--- @param rec PvRecord
local function destroy_objects(rec)
  rec.shape.destroy()
  local map = rec.map
  if map then
    map.destroy()
  end
  local objs = rec.objs
  if objs then
    if rec.segs then
      for _, list in pairs(objs) do
        destroy_list(list)
      end
    else
      destroy_list(objs)
    end
  end
end

--- @param V PvViewer
--- @param unit uint
--- @param rec PvRecord
local function remove_record(V, unit, rec)
  destroy_objects(rec)
  local segs = rec.segs
  if segs then
    local systems = V.systems
    for seg in pairs(segs) do
      local sys = systems[seg]
      if sys then
        sys.members[unit] = nil
      end
    end
  end
  V.entities[unit] = nil
end

--- @param V PvViewer
local function reset_queue(V)
  V.qe, V.qu, V.qfirst, V.qlast, V.queued, V.redraw = {}, {}, 1, 0, {}, {}
end

--- Removes everything drawn for the viewer, including the overlay.
--- @param V PvViewer
function core.clear_all(V)
  for _, rec in pairs(V.entities) do
    destroy_objects(rec)
  end
  V.entities = {}
  V.systems = {}
  V.next_color = 0
  reset_queue(V)
  local O = V.overlay
  if O then
    O.background.destroy()
    if O.map_background then
      O.map_background.destroy()
    end
    V.overlay = nil
  end
  storage.active[V.index] = nil
  set_mode(V, nil)
  notify()
end

--- Forgets the state without destroying render objects (after rendering.clear).
--- @param V PvViewer
function core.forget_all(V)
  V.entities = {}
  V.systems = {}
  V.next_color = 0
  V.overlay = nil
  V.mode = nil
  reset_queue(V)
end

--- @param V PvViewer
--- @param seg uint
--- @param fb LuaFluidBox A fluidbox of the segment.
--- @param index uint
--- @param hover boolean?
--- @return PvSystem
local function new_system(V, seg, fb, index, hover)
  local color, order = DEFAULT_COLOR, MAX_ORDER
  if V.by_system then
    local n = V.next_color + 1
    V.next_color = n
    color, order = palette[(n - 1) % #palette + 1], n
  else
    local contents = fb.get_fluid_segment_contents(index)
    local name = contents and next(contents)
    if name then
      color, order = fluid_color[name] or DEFAULT_COLOR, fluid_order[name] or MAX_ORDER
    end
  end
  local sys = { color = color, order = order, hover = hover or false }
  if V.mode ~= "overlay" then
    sys.members = {}
  end
  V.systems[seg] = sys
  return sys
end

--- Collects the fluid segments an entity touches: the segments of its fluidboxes and, for fluidboxes
--- outside any segment (pumps), the segments on the other side of their connections.
--- @param entity LuaEntity
--- @param fbs table<uint, LuaFluidBox> Out: segment -> a fluidbox of it.
--- @param idxs table<uint, uint> Out: segment -> that fluidbox index.
--- @return boolean found
local function collect_segments(entity, fbs, idxs)
  local fb = entity.fluidbox
  local found = false
  for i = 1, #fb do
    local seg = fb.get_fluid_segment_id(i)
    if seg then
      if not fbs[seg] then
        fbs[seg], idxs[seg], found = fb, i, true
      end
    else
      local conns = fb.get_pipe_connections(i)
      for c = 1, #conns do
        local conn = conns[c]
        local target = conn.target
        if target then
          local ti = conn.target_fluidbox_index
          local tseg = target.get_fluid_segment_id(ti)
          if tseg and not fbs[tseg] then
            fbs[tseg], idxs[tseg], found = target, ti, true
          end
        end
      end
    end
  end
  return found
end
core.collect_segments = collect_segments

-- Drawing ----------------------------------------------------------------------------------------

--- @param objs table?
--- @param overlay boolean
--- @param seg uint
--- @param obj LuaRenderObject
--- @return table
local function add_object(objs, overlay, seg, obj)
  if not objs then
    objs = {}
  end
  if overlay then
    objs[#objs + 1] = obj
  else
    local list = objs[seg]
    if not list then
      list = {}
      objs[seg] = list
    end
    list[#list + 1] = obj
  end
  return objs
end

--- Draws an entity, or extends its drawing with systems shown since. In systems mode it also queues
--- neighbours of shown systems that are not drawn yet.
--- @param V PvViewer
--- @param entity LuaEntity
--- @param unit uint
--- @param force boolean? Draw from scratch.
--- @param chunk integer? Overlay chunk key.
local function process(V, entity, unit, force, chunk)
  local entities = V.entities
  local overlay = V.mode == "overlay"
  local rec = entities[unit]
  if rec then
    if force then
      remove_record(V, unit, rec)
      rec = nil
    elseif overlay then
      return
    end
  end
  local info = info_of(entity.name)
  if not info or info.black then
    return
  end
  local fb = entity.fluidbox
  local n = #fb
  if n == 0 then
    return
  end

  local systems = V.systems
  local queued = V.queued
  local players = V.players
  local show_map = V.show_map
  local is_pipe = info.pipe
  local old = rec and rec.segs
  local objs = rec and rec.objs
  local ug = rec and rec.ug
  local mask = rec and rec.mask or 0
  local surface = overlay and V.overlay.surface or entity.surface_index
  local added = nil
  local own_segment = false

  for i = 1, n do
    local seg = fb.get_fluid_segment_id(i)
    local conns = nil
    if seg then
      own_segment = true
      if not (old and old[seg]) then
        local sys = systems[seg]
        if not sys and overlay then
          sys = new_system(V, seg, fb, i)
        end
        if sys then
          added = added or {}
          added[seg] = sys
          conns = fb.get_pipe_connections(i)
        end
      end
    else
      conns = fb.get_pipe_connections(i)
    end

    if conns then
      for c = 1, #conns do
        local conn = conns[c]
        local target = conn.target
        if target then
          local s, sys = seg, nil
          if s then
            sys = added[s]
          else
            local ti = conn.target_fluidbox_index
            s = target.get_fluid_segment_id(ti)
            if s and not (old and old[s]) then
              sys = systems[s]
              if not sys and overlay then
                sys = new_system(V, s, target, ti)
              end
              if sys then
                added = added or {}
                added[s] = sys
              end
            end
          end

          if sys then
            local owner = nil
            local kind = conn.connection_type
            if kind ~= "linked" then
              local p, t = conn.position, conn.target_position
              local px, py, tx, ty = p.x, p.y, t.x, t.y
              local dir
              if py > ty then
                dir = NORTH
              elseif px < tx then
                dir = EAST
              elseif py < ty then
                dir = SOUTH
              else
                dir = WEST
              end

              if is_pipe then
                mask = bor(mask, DIR_BIT[dir])
              else
                local flow = conn.flow_direction
                local sprite = ARROW_SPRITE[flow]
                if flow ~= "input-output" then
                  owner = target.owner
                  local oinfo = info_of(owner.name)
                  if not (oinfo and oinfo.pipe) then
                    sprite = "pv-fluid-arrow"
                  end
                  if flow == "input" then
                    dir = OPPOSITE[dir]
                  end
                end
                arrow_target.x, arrow_target.y = (px + tx) * 0.5, (py + ty) * 0.5
                local color, orientation = sys.color, ORIENTATION[dir]
                arrow_args.sprite, arrow_args.tint, arrow_args.orientation = sprite, color, orientation
                arrow_args.surface, arrow_args.players = surface, players
                objs = add_object(objs, overlay, s, rendering.draw_sprite(arrow_args))
                if show_map then
                  arrow_map_args.sprite, arrow_map_args.tint, arrow_map_args.orientation = sprite, color, orientation
                  arrow_map_args.surface, arrow_map_args.players = surface, players
                  objs = add_object(objs, overlay, s, rendering.draw_sprite(arrow_map_args))
                end
              end

              if kind == "underground" then
                -- Drawn once per pair, by the end that is drawn second.
                owner = owner or target.owner
                local ounit = owner.unit_number
                local orec = ounit and entities[ounit]
                if orec and (overlay or orec.segs[s]) and not (orec.ug and orec.ug[unit]) then
                  local pc = target.get_pipe_connections(conn.target_fluidbox_index)[conn.target_pipe_connection_index]
                  local q = pc and pc.position
                  if q then
                    local dx, dy = q.x - px, q.y - py
                    local len = math.sqrt(dx * dx + dy * dy)
                    if len >= 2 then
                      local ux, uy = dx / len, dy / len
                      local color = sys.color
                      line_from.x, line_from.y = px + ux * UG_INSET, py + uy * UG_INSET
                      line_to.x, line_to.y = q.x - ux * UG_INSET, q.y - uy * UG_INSET
                      line_args.color, line_args.surface, line_args.players = color, surface, players
                      objs = add_object(objs, overlay, s, rendering.draw_line(line_args))
                      if show_map then
                        map_from.x, map_from.y = px - ux * UG_MAP_OUTSET, py - uy * UG_MAP_OUTSET
                        map_to.x, map_to.y = q.x + ux * UG_MAP_OUTSET, q.y + uy * UG_MAP_OUTSET
                        line_map_args.color, line_map_args.surface, line_map_args.players = color, surface, players
                        objs = add_object(objs, overlay, s, rendering.draw_line(line_map_args))
                      end
                      ug = ug or {}
                      ug[ounit] = true
                    end
                  end
                end
              end
            end

            if not overlay then
              owner = owner or target.owner
              local ounit = owner.unit_number
              if ounit and not queued[ounit] then
                local orec = entities[ounit]
                if not (orec and orec.segs[s]) then
                  local oinfo = info_of(owner.name)
                  if oinfo and not oinfo.black then
                    push(V, owner, ounit, true)
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  if not added then
    if rec or not overlay then
      return
    end
  end

  -- Main colour: the system with the lowest order. Entities outside every segment (pumps) are grey
  -- unless the player enabled coloured pumps.
  local best = DEFAULT_SYSTEM
  if own_segment or V.color_pumps then
    if added then
      for _, sys in pairs(added) do
        if sys.order < best.order then
          best = sys
        end
      end
    end
    if old then
      for seg in pairs(old) do
        local sys = systems[seg]
        if sys and sys.order < best.order then
          best = sys
        end
      end
    end
  end
  local color = best.color

  if rec then
    -- Extension in systems mode.
    rec.shape.color = color
    if rec.map then
      rec.map.color = color
    end
    if is_pipe and mask ~= rec.mask then
      rec.mask = mask
      rec.shape.sprite = PIPE_SPRITE[mask]
      if rec.map then
        rec.map.sprite = PIPE_CHART_SPRITE[mask]
      end
    end
  else
    rec = { entity = entity, surface = surface }
    entities[unit] = rec
    if is_pipe then
      local pos = entity.position
      local w, h = info.w, info.h
      if w ~= h then
        local d = entity.direction
        if d == EAST or d == WEST then
          w, h = h, w
        end
      end
      pipe_target.x, pipe_target.y = pos.x, pos.y
      pipe_args.sprite, pipe_args.tint, pipe_args.x_scale, pipe_args.y_scale = PIPE_SPRITE[mask], color, w, h
      pipe_args.surface, pipe_args.players = surface, players
      rec.shape = rendering.draw_sprite(pipe_args)
      if show_map then
        pipe_map_args.sprite, pipe_map_args.tint, pipe_map_args.x_scale, pipe_map_args.y_scale =
          PIPE_CHART_SPRITE[mask], color, w, h
        pipe_map_args.surface, pipe_map_args.players = surface, players
        rec.map = rendering.draw_sprite(pipe_map_args)
      end
      rec.mask = mask
    else
      local box = entity.selection_box
      local lt, rb = box.left_top, box.right_bottom
      local w, h = rb.x - lt.x - 0.2, rb.y - lt.y - 0.2
      box_target.x, box_target.y = (lt.x + rb.x) * 0.5, (lt.y + rb.y) * 0.5
      box_args.tint, box_args.x_scale, box_args.y_scale = color, w, h
      box_args.surface, box_args.players = surface, players
      rec.shape = rendering.draw_sprite(box_args)
      if show_map then
        box_map_args.tint, box_map_args.x_scale, box_map_args.y_scale = color, w, h
        box_map_args.surface, box_map_args.players = surface, players
        rec.map = rendering.draw_sprite(box_map_args)
      end
    end
    if overlay then
      rec.chunk = chunk
    end
  end
  rec.objs = objs
  rec.ug = ug

  if not overlay and added then
    local segs = old or {}
    rec.segs = segs
    for seg, sys in pairs(added) do
      segs[seg] = true
      sys.members[unit] = true
    end
  end
end

-- Systems mode -----------------------------------------------------------------------------------

--- Shows the systems of an entity that are not shown yet.
--- @param V PvViewer
--- @param entity LuaEntity
--- @param hover boolean
--- @param fbs table<uint, LuaFluidBox>? Precomputed collect_segments result.
--- @param idxs table<uint, uint>?
--- @param only uint? Show only this segment.
--- @return boolean added
local function request(V, entity, hover, fbs, idxs, only)
  if V.mode == "overlay" then
    return false
  end
  local unit = entity.unit_number
  if not unit then
    return false
  end
  local info = info_of(entity.name)
  if not info or info.black then
    return false
  end
  if not fbs then
    fbs, idxs = {}, {}
    collect_segments(entity, fbs, idxs)
  end
  local systems = V.systems
  local added = false
  for seg, fb in pairs(fbs) do
    if not systems[seg] and (not only or seg == only) then
      if not added then
        set_mode(V, "systems")
        added = true
      end
      new_system(V, seg, fb, idxs[seg], hover)
    end
  end
  if added and not V.queued[unit] then
    push(V, entity, unit, true)
  end
  return added
end
core.request = request

--- Removes one system; entities that stay in other systems are redrawn.
--- @param V PvViewer
--- @param seg uint
function core.clear_system(V, seg)
  local systems = V.systems
  local sys = systems[seg]
  if not sys then
    return
  end
  systems[seg] = nil
  if not next(systems) then
    core.clear_all(V)
    return
  end
  local entities = V.entities
  for unit in pairs(sys.members) do
    local rec = entities[unit]
    if rec then
      rec.segs[seg] = nil
      local keep = next(rec.segs) ~= nil
      remove_record(V, unit, rec)
      if keep then
        local entity = rec.entity
        if entity.valid then
          push_redraw(V, entity, unit, true)
        end
      end
    end
  end
end

--- @param V PvViewer
function core.clear_hovered(V)
  local hovered = {}
  for seg, sys in pairs(V.systems) do
    if sys.hover then
      hovered[#hovered + 1] = seg
    end
  end
  for i = 1, #hovered do
    core.clear_system(V, hovered[i])
  end
end

--- Y: pin hovered systems of the entity, else show its systems, else hide them. Nothing selected
--- clears everything.
--- @param V PvViewer
--- @param entity LuaEntity?
function core.toggle_selected(V, entity)
  if V.mode == "overlay" then
    return
  end
  if not entity then
    core.clear_all(V)
    return
  end
  if not entity.unit_number then
    return
  end
  local info = info_of(entity.name)
  if not info or info.black then
    return
  end
  local fbs, idxs = {}, {}
  if not collect_segments(entity, fbs, idxs) then
    return
  end
  local systems = V.systems
  local pinned = false
  for seg in pairs(fbs) do
    local sys = systems[seg]
    if sys and sys.hover then
      sys.hover = false
      pinned = true
    end
  end
  if pinned or request(V, entity, false, fbs, idxs) then
    return
  end
  for seg in pairs(fbs) do
    core.clear_system(V, seg)
  end
end

--- Mouse-over: keeps the hovered systems while the cursor is over their entities or over entities
--- without fluid; removes them on empty ground or on another fluid system.
--- @param V PvViewer
--- @param entity LuaEntity?
function core.hover(V, entity)
  if V.mode == "overlay" then
    return
  end
  if not entity then
    core.clear_hovered(V)
    return
  end
  if not entity.unit_number then
    return
  end
  local info = info_of(entity.name)
  if not info or info.black then
    return
  end
  local fbs, idxs = {}, {}
  if not collect_segments(entity, fbs, idxs) then
    return
  end
  local stale = {}
  for seg, sys in pairs(V.systems) do
    if sys.hover and not fbs[seg] then
      stale[#stale + 1] = seg
    end
  end
  for i = 1, #stale do
    core.clear_system(V, stale[i])
  end
  request(V, entity, true, fbs, idxs)
end

--- Draws the shown systems again (new colours or settings).
--- @param V PvViewer
function core.rebuild_systems(V)
  if V.mode ~= "systems" then
    return
  end
  local seeds = {}
  for seg, sys in pairs(V.systems) do
    for unit in pairs(sys.members) do
      local rec = V.entities[unit]
      if rec and rec.entity.valid then
        seeds[#seeds + 1] = { entity = rec.entity, seg = seg, hover = sys.hover }
        break
      end
    end
  end
  core.clear_all(V)
  for i = 1, #seeds do
    local seed = seeds[i]
    request(V, seed.entity, seed.hover, nil, nil, seed.seg)
  end
end

-- Overlay ----------------------------------------------------------------------------------------

local function chunk_key(cx, cy)
  return cx * 65536 + cy
end

local function chunk_xy(key)
  local cx = floor((key + 32768) / 65536)
  return cx, key - cx * 65536
end

--- @param O PvOverlay
local function chunk_visible(O, key)
  local cx, cy = chunk_xy(key)
  return cx >= O.cx - O.kx and cx <= O.cx + O.kx and cy >= O.cy - O.ky and cy <= O.cy + O.ky
end

--- @param V PvViewer
--- @param O PvOverlay
--- @param key integer
local function scan_chunk(V, O, key)
  if O.chunks[key] or not chunk_visible(O, key) then
    return
  end
  local cx, cy = chunk_xy(key)
  local list = {}
  O.chunks[key] = list
  local lt, rb = scan_area.left_top, scan_area.right_bottom
  lt.x, lt.y, rb.x, rb.y = cx * 32, cy * 32, cx * 32 + 32, cy * 32 + 32
  scan_filter.force = O.force
  local found = O.surf.find_entities_filtered(scan_filter)
  local entities, queued = V.entities, V.queued
  for i = 1, #found do
    local entity = found[i]
    local pos = entity.position
    if floor(pos.x / 32) == cx and floor(pos.y / 32) == cy then
      local unit = entity.unit_number
      if unit and not entities[unit] and not queued[unit] then
        list[#list + 1] = unit
        push(V, entity, unit, key)
      end
    end
  end
end

--- Queues chunks of the new view that were not in the old one, nearest first.
--- @param O PvOverlay
local function queue_new_chunks(O, ox1, ox2, oy1, oy2)
  local cx, cy, kx, ky = O.cx, O.cy, O.kx, O.ky
  local x1, x2, y1, y2 = cx - kx, cx + kx, cy - ky, cy + ky
  local sq = O.sq
  local function add(x, y)
    if x >= x1 and x <= x2 and y >= y1 and y <= y2 and not (ox1 and x >= ox1 and x <= ox2 and y >= oy1 and y <= oy2) then
      local last = O.slast + 1
      O.slast = last
      sq[last] = chunk_key(x, y)
    end
  end
  for d = 0, math.max(kx, ky) do
    if d == 0 then
      add(cx, cy)
    else
      for x = cx - d, cx + d do
        add(x, cy - d)
        add(x, cy + d)
      end
      for y = cy - d + 1, cy + d - 1 do
        add(cx - d, y)
        add(cx + d, y)
      end
    end
  end
end

--- @param V PvViewer
--- @param position MapPosition
function core.overlay_move(V, position)
  local O = V.overlay
  if not O then
    return
  end
  local cx, cy = floor(position.x / 32), floor(position.y / 32)
  if cx == O.cx and cy == O.cy then
    return
  end
  local target = { x = cx * 32 + 16, y = cy * 32 + 16 }
  O.background.target = target
  if O.map_background then
    O.map_background.target = target
  end
  local ox1, ox2, oy1, oy2
  if O.cx then
    ox1, ox2, oy1, oy2 = O.cx - O.kx, O.cx + O.kx, O.cy - O.ky, O.cy + O.ky
  end
  O.cx, O.cy = cx, cy
  local rq, rmark = O.rq, O.rmark
  for key in pairs(O.chunks) do
    if not rmark[key] and not chunk_visible(O, key) then
      rmark[key] = true
      local last = O.rlast + 1
      O.rlast = last
      rq[last] = key
    end
  end
  queue_new_chunks(O, ox1, ox2, oy1, oy2)
  activate(V)
end

--- Opens the overlay: a dark background and every fluid entity of the force within w x h tiles
--- around the position (both multiples of 64 plus 32, so the view is whole chunks).
--- @param V PvViewer
--- @param surface LuaSurface
--- @param position MapPosition
--- @param w integer
--- @param h integer
--- @param force uint
--- @param opacity number
function core.overlay_open(V, surface, position, w, h, force, opacity)
  core.clear_all(V)
  local tint = { r = 0, g = 0, b = 0, a = opacity }
  local background = rendering.draw_sprite({
    sprite = "pv-overlay-box",
    tint = tint,
    render_layer = "191",
    target = position,
    surface = surface,
    players = V.players,
    x_scale = w,
    y_scale = h,
  })
  local map_background = nil
  if V.show_map then
    map_background = rendering.draw_sprite({
      sprite = "pv-overlay-box",
      tint = tint,
      render_layer = "arrow",
      render_mode = "chart",
      target = position,
      surface = surface,
      players = V.players,
      x_scale = w,
      y_scale = h,
    })
  end
  V.overlay = {
    surface = surface.index,
    surf = surface,
    force = force,
    kx = (w - 32) / 64,
    ky = (h - 32) / 64,
    background = background,
    map_background = map_background,
    chunks = {},
    sq = {},
    sfirst = 1,
    slast = 0,
    rq = {},
    rfirst = 1,
    rlast = 0,
    rmark = {},
  }
  set_mode(V, "overlay")
  core.overlay_move(V, position)
end

--- Removes chunks that left the view, up to `budget` entities.
--- @param V PvViewer
--- @param O PvOverlay
--- @param budget integer
local function remove_chunks(V, O, budget)
  local rq, entities = O.rq, V.entities
  while budget > 0 and O.rfirst <= O.rlast do
    local first = O.rfirst
    local key = rq[first]
    rq[first] = nil
    O.rfirst = first + 1
    O.rmark[key] = nil
    local list = O.chunks[key]
    if list and not chunk_visible(O, key) then
      for i = 1, #list do
        local unit = list[i]
        local rec = entities[unit]
        if rec and rec.chunk == key then
          remove_record(V, unit, rec)
        end
      end
      O.chunks[key] = nil
      budget = budget - #list
    end
  end
end

-- Work loop --------------------------------------------------------------------------------------

--- Runs queued work for one viewer.
--- @param V PvViewer
--- @param budget integer Entities to draw this tick.
--- @return boolean more Work remains.
function core.work(V, budget)
  local O = V.overlay
  if O and O.rfirst <= O.rlast then
    remove_chunks(V, O, budget * 8)
  end
  local qe, qu, queued, redraw = V.qe, V.qu, V.queued, V.redraw
  while budget > 0 do
    local first = V.qfirst
    if first <= V.qlast then
      local entity, unit = qe[first], qu[first]
      qe[first], qu[first] = nil, nil
      V.qfirst = first + 1
      local tag = queued[unit]
      queued[unit] = nil
      local force = redraw[unit]
      redraw[unit] = nil
      if entity.valid then
        if O then
          if O.chunks[tag] then
            process(V, entity, unit, force, tag)
          end
        else
          process(V, entity, unit, force)
        end
      end
      budget = budget - 1
    elseif O and O.sfirst <= O.slast then
      local key = O.sq[O.sfirst]
      O.sq[O.sfirst] = nil
      O.sfirst = O.sfirst + 1
      scan_chunk(V, O, key)
      budget = budget - 1
    else
      break
    end
  end
  return V.qfirst <= V.qlast or (O ~= nil and (O.sfirst <= O.slast or O.rfirst <= O.rlast))
end

-- Changes in the world ---------------------------------------------------------------------------

--- An entity is about to be removed: drop its drawing.
--- @param V PvViewer
--- @param unit uint
function core.forget(V, unit)
  local rec = V.entities[unit]
  if rec then
    remove_record(V, unit, rec)
  end
end

--- An entity was built, rotated or lost a neighbour: bring its drawing up to date.
--- @param V PvViewer
--- @param entity LuaEntity
function core.refresh(V, entity)
  local unit = entity.unit_number
  if not unit then
    return
  end
  local mode = V.mode
  if mode == "overlay" then
    local O = V.overlay
    if entity.surface_index ~= O.surface or entity.force_index ~= O.force then
      return
    end
    local pos = entity.position
    local key = chunk_key(floor(pos.x / 32), floor(pos.y / 32))
    local list = O.chunks[key]
    if not list then
      return -- Not scanned yet: the scan will find it.
    end
    if not V.entities[unit] and not V.queued[unit] then
      list[#list + 1] = unit
    end
    push_redraw(V, entity, unit, key)
  elseif mode == "systems" then
    local fbs, idxs = {}, {}
    collect_segments(entity, fbs, idxs)
    local rec = V.entities[unit]
    if rec then
      local changed = nil
      for seg in pairs(rec.segs) do
        if not fbs[seg] then
          changed = changed or {}
          changed[#changed + 1] = seg
        end
      end
      if changed then
        -- The engine gave the network a new segment id (merge or split): draw it again from here.
        for i = 1, #changed do
          local sys = V.systems[changed[i]]
          if sys then
            local hover = sys.hover
            core.clear_system(V, changed[i])
            request(V, entity, hover, fbs, idxs)
          end
        end
      else
        push_redraw(V, entity, unit, true)
      end
    else
      for seg in pairs(fbs) do
        if V.systems[seg] then
          push(V, entity, unit, true)
          break
        end
      end
    end
  end
end

--- A surface was deleted: its render objects are gone.
--- @param V PvViewer
--- @param surface_index uint
function core.drop_surface(V, surface_index)
  if V.overlay and V.overlay.surface == surface_index then
    core.clear_all(V)
    return
  end
  for unit, rec in pairs(V.entities) do
    if rec.surface == surface_index then
      remove_record(V, unit, rec)
    end
  end
end

return core
