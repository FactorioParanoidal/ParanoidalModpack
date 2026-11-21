local M = {}
local PIN = {{0.35, 0.78, 1}, {0.55, 0.90, 0.38}}
local MATCH = {0.53, 0.95, 0.36}
local CANDIDATE = {0.32, 0.79, 1}
local OTHER = {1, 0.46, 0.24}
local SHADE = {0, 0, 0, 0.55}
local OUTLINE_PAD = 0.12
local WINDOW_PAD = 0.45 -- Leave some room for sprite overhang beyond the collision box.

local function views()
    return storage.factory_specialization_inspections
end

-- Keep visual data out of the factory table returned to other mods by the remote API.
local function floor_view(id, create)
    local floors = storage.factory_specialization_inspection_floors
    if not floors and create then
        floors = {}
        storage.factory_specialization_inspection_floors = floors
    end
    local floor = floors and floors[id]
    if not floor and create then
        floor = {players = {}}
        floors[id] = floor
    end
    return floor
end

function M.has_snapshot(factory)
    local floor = floor_view(factory.id)
    return floor and floor.snapshot ~= nil
end

local function destroy(object)
    if object and object.valid then object.destroy() end
end

local function clear_mask(view)
    destroy(view.mask)
    view.mask, view.mask_area, view.mask_snapshot = nil, nil, nil
end

function M.drop(index)
    local sessions = views()
    local view = sessions and sessions[index]
    if not view then return end
    for _, mark in pairs(view.marks) do destroy(mark.object) end
    clear_mask(view)
    destroy(view.border)
    local floor = floor_view(view.id)
    if floor then floor.players[index] = nil end
    sessions[index] = nil
end

function M.clear(factory)
    local floor = floor_view(factory.id)
    if not floor then return end
    for index in pairs(floor.players) do M.drop(index) end
    storage.factory_specialization_inspection_floors[factory.id] = nil
end

function M.reset()
    for index in pairs(views() or {}) do M.drop(index) end
    storage.factory_specialization_inspection_floors = nil
end

function M.at_factory(player, factory)
    return player and player.valid and factory and player.force == factory.force
        and player.surface == factory.inside_surface and player.render_mode ~= defines.render_mode.chart
        and remote_api.find_surrounding_factory(player.surface, player.position) == factory
end

-- The caller has resolved and checked any selected marker. This does not perform scans or draw anything.
function M.select(player, factory, row, click)
    local index = player.index
    local sessions = views()
    local view = sessions and sessions[index]
    if view and factory and view.id ~= factory.id then M.drop(index); view = nil end
    if not view then
        if not row then return false end
        sessions = sessions or {}
        storage.factory_specialization_inspections = sessions
        view = {id = factory.id, marks = {}}
        sessions[index] = view
        floor_view(factory.id, true).players[index] = true
    end
    if click then
        if view.pin == row then
            view.pin, view.hover, view.suppressed = nil, nil, row
        else
            view.pin, view.hover, view.suppressed = row, row, nil
        end
        return true
    end
    if view.suppressed == row and row then return false end
    local changed = view.hover ~= row or view.suppressed ~= nil
    view.hover, view.suppressed = row, nil
    return changed
end

local function quad(vertices, x1, y1, x2, y2)
    local a = {x1, y1}
    -- Degenerate triangles connect adjacent strips without painting a diagonal between them.
    local n = #vertices
    if n > 0 then vertices[n + 1], vertices[n + 2] = vertices[n], a end
    n = #vertices
    vertices[n + 1], vertices[n + 2], vertices[n + 3], vertices[n + 4] = a, {x1, y2}, {x2, y1}, {x2, y2}
end

local function shade_vertices(area, holes)
    local x1, y1 = area[1][1], area[1][2]
    local x2, y2 = area[2][1], area[2][2]
    local cuts, switches, active, vertices = {x1, x2}, {}, {}, {}
    local function switch_at(x)
        local list = switches[x]
        if not list then
            list = {}
            switches[x] = list
            if x > x1 and x < x2 then cuts[#cuts + 1] = x end
        end
        return list
    end
    for _, box in ipairs(holes) do
        local l, t = math.max(x1, box[1]), math.max(y1, box[2])
        local r, b = math.min(x2, box[3]), math.min(y2, box[4])
        if l < r and t < b then
            local span = {t, b}
            local begin, finish = switch_at(l), switch_at(r)
            begin[#begin + 1], finish[#finish + 1] = span, span
        end
    end
    table.sort(cuts)
    for i = 1, #cuts - 1 do
        local l, r = cuts[i], cuts[i + 1]
        for _, span in ipairs(switches[l] or {}) do active[span] = not active[span] or nil end
        local spans = {}
        for span in pairs(active) do spans[#spans + 1] = span end
        table.sort(spans, function(a, b) return a[1] < b[1] end)
        local top = y1
        for _, span in ipairs(spans) do
            if span[1] > top then quad(vertices, l, top, r, span[1]) end
            top = math.max(top, span[2])
        end
        if top < y2 then quad(vertices, l, top, r, y2) end
    end
    return vertices
end

local function update_marks(view, factory, snapshot, row, viewers, area)
    local marks, changed = {}, false
    local lo, hi = area[1], area[2]
    for i, entity in ipairs(snapshot.machines) do
        if entity.valid and entity.surface == factory.inside_surface and entity.force == factory.force then
            local p = entity.position
            if p.x >= lo[1] and p.x < hi[1] and p.y >= lo[2] and p.y < hi[2] then
                local unit, box = entity.unit_number, entity.bounding_box
                local tl, br = box.left_top, box.right_bottom
                local l, t, r, b = tl.x - p.x, tl.y - p.y, br.x - p.x, br.y - p.y
                local flags = snapshot.matches[i]
                local leader = row == 1 and flags % 2 == 1 or row == 2 and flags >= 2
                local color = leader and (snapshot.tiers[row] > 0 and MATCH or CANDIDATE) or OTHER
                local mark = view.marks[unit]
                local window = mark and mark.window
                local x1, y1, x2, y2 = tl.x - WINDOW_PAD, tl.y - WINDOW_PAD, br.x + WINDOW_PAD, br.y + WINDOW_PAD
                if not (window and window[1] == x1 and window[2] == y1 and window[3] == x2 and window[4] == y2) then
                    window, changed = {x1, y1, x2, y2}, true
                end
                if not (mark and mark.object.valid and mark.l == l and mark.t == t and mark.r == r and mark.b == b) then
                    if mark then destroy(mark.object) end
                    local object = rendering.draw_rectangle {
                        surface = factory.inside_surface, players = viewers, color = color, width = 2.5,
                        left_top = {entity = entity, offset = {l - OUTLINE_PAD, t - OUTLINE_PAD}},
                        right_bottom = {entity = entity, offset = {r + OUTLINE_PAD, b + OUTLINE_PAD}},
                    }
                    mark = {object = object, l = l, t = t, r = r, b = b, color = color}
                elseif mark.color ~= color then
                    mark.object.color, mark.color = color, color
                end
                view.marks[unit] = nil
                marks[unit] = mark
                mark.window = window
            end
        end
    end
    for _, mark in pairs(view.marks) do
        destroy(mark.object)
        changed = true
    end
    view.marks, view.paint_snapshot, view.paint_row = marks, snapshot, row
    return changed
end

local function same_area(a, b)
    return a and a[1][1] == b[1][1] and a[1][2] == b[1][2] and a[2][1] == b[2][1] and a[2][2] == b[2][2]
end

local function update_mask(view, factory, viewers, area, changed)
    -- A new bonus snapshot may change only the outline colours. In that case keep the polygon.
    if not changed and same_area(view.mask_area, area) and (not view.mask or view.mask.valid) then return end
    clear_mask(view)
    local holes = {}
    for _, mark in pairs(view.marks) do holes[#holes + 1] = mark.window end
    local vertices = shade_vertices(area, holes)
    if #vertices > 0 then
        view.mask = rendering.draw_polygon {
            surface = factory.inside_surface, players = viewers, color = SHADE, vertices = vertices,
        }
    end
    view.mask_area = area
end

local function has_marker(state, row, selected)
    local marker = row and state.rows and state.rows[row] and state.rows[row].marker
    return marker and marker.valid and marker == selected
end

function M.redraw(player)
    local sessions = views()
    local view = sessions and sessions[player.index]
    if not view then return end
    local factory = storage.factories[view.id]
    local state = factory and factory.specialization
    if not state or not M.at_factory(player, factory) then M.drop(player.index); return end
    if not has_marker(state, view.hover, player.selected) then view.hover = nil end
    if not has_marker(state, view.suppressed, player.selected) then view.suppressed = nil end
    local pin = view.pin and state.rows and state.rows[view.pin]
    if not (pin and pin.marker.valid) then pin, view.pin = nil, nil end
    local row = view.hover or view.pin
    if not row then
        if not view.suppressed then M.drop(player.index); return end
        for _, mark in pairs(view.marks) do destroy(mark.object) end
        view.marks, view.paint_snapshot, view.paint_row = {}, nil, nil
    end
    local viewers = {player.index}
    if view.border_marker ~= (pin and pin.marker) or (pin and not (view.border and view.border.valid)) then
        destroy(view.border)
        view.border, view.border_marker = nil, pin and pin.marker
        if pin then
            view.border = rendering.draw_rectangle {
                surface = factory.inside_surface, players = viewers, color = PIN[view.pin], width = 3,
                left_top = {entity = pin.marker, offset = {-9, -1}},
                right_bottom = {entity = pin.marker, offset = {9, 1}},
            }
        end
    end
    local floor = floor_view(view.id)
    local snapshot = floor and floor.snapshot
    local repaint = row and snapshot and (view.paint_snapshot ~= snapshot or view.paint_row ~= row)
    local hover = view.hover and snapshot
    local area = (repaint or hover) and factorissimo.factory_interior_area(factory)
    local changed = repaint and update_marks(view, factory, snapshot, row, viewers, area)
    if hover then
        update_mask(view, factory, viewers, area, changed)
    else
        clear_mask(view)
    end
end

function M.update(factory, machines, matches, speed, efficiency)
    local floor = floor_view(factory.id, true)
    floor.snapshot = {machines = machines, matches = matches, tiers = {speed, efficiency}}
    for index in pairs(floor.players) do
        local player = game.get_player(index)
        if player and player.valid then M.redraw(player) else M.drop(index) end
    end
end

function M.position_changed(event)
    local sessions = views()
    local view = sessions and sessions[event.player_index]
    if view and not M.at_factory(game.get_player(event.player_index), storage.factories[view.id]) then M.drop(event.player_index) end
end

return M
