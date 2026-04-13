local Util = require("modules/util")
local actions = require("modules/actions")
local Blueprint = require("modules/Blueprint")

local min, max = math.min, math.max


local Snap = {
    SNAPS = {
        ["n"] = { nil, 1 },
        ["s"] = { nil, 0 },
        ["w"] = { 1, nil },
        ["e"] = { 0, nil },
        ["center"] = { 0.5, 0.5 },
        ["nw"] = { 1, 1 },
        ["ne"] = { 0, 1 },
        ["sw"] = { 1, 0 },
        ["se"] = { 0, 0 },
    },
    NUDGES = {
        ["n"] = { 0, -1 },
        ["s"] = { 0, 1 },
        ["w"] = { -1, 0 },
        ["e"] = { 1, 0 },
        ["nw"] = { -1, -1 },
        ["ne"] = { 1, -1 },
        ["sw"] = { -1, 1 },
        ["se"] = { 1, 1 },
    },
    ALIGNMENT_OVERRIDES = {
        ['straight-rail'] = 2,
        ['curved-rail'] = 2,
        ['train-stop'] = 2,
		['rail-signal'] = 2
    },
	ALIGNMENT_OVERRIDES_GROUP = { --prototypes.entity[].fast_replaceable_group
        ['rail'] = 2,
		['rail-signal'] = 2,
    },
    ROTATIONS = {
        [defines.direction.north] = { 1, 2, 3, 4 },
        [defines.direction.northeast] = { 3, 2, 1, 4 },
        [defines.direction.east] = { 4, 1, 2, 3 },
        [defines.direction.southeast] = { 2, 1, 4, 3 },
        [defines.direction.south] = { 3, 4, 1, 2 },
        [defines.direction.southwest] = { 1, 4, 3, 2 },
        [defines.direction.west] = { 2, 3, 4, 1 },
        [defines.direction.northwest] = { 4, 3, 2, 1 },
    },
}

function Snap.on_nudge_action(player, event, action)
	Log.trace("Snap.on_nudge_action")
    local bp = Util.get_blueprint(player)
    if not bp then return nil end

    local xdir, ydir = table.unpack(Snap.NUDGES[action.data])
    return Snap.nudge_blueprint(bp, xdir, ydir)
end


function Snap.on_snap_action(player, event, action)
	Log.trace("Snap.on_snap_action")
    local bp = Util.get_blueprint(player)
    if not bp then return nil end

    local player_settings = player.mod_settings
    local center = (player_settings["Kux-BlueprintExtensions_cardinal-center"].value and 0.5) or nil
    local xdir, ydir = table.unpack(Snap.SNAPS[action.data])
    if xdir == nil then
        xdir = center
    elseif player_settings["Kux-BlueprintExtensions_horizontal-invert"].value then
        xdir = 1-xdir
    end
    if ydir == nil then
        ydir = center
    elseif player_settings["Kux-BlueprintExtensions_vertical-invert"].value then
        ydir = 1-ydir
    end
    return Snap.align_blueprint(bp, xdir, ydir)
end


local function update_bounds(bound, point, min_edge, max_edge)
    min_edge = point + min_edge
    max_edge = point + max_edge
    if bound.min == nil then
        bound.min = point
        bound.max = point
        bound.min_edge = min_edge
        bound.max_edge = max_edge
        return
    end
    bound.min = min(bound.min, point)
    bound.max = max(bound.max, point)
    bound.min_edge = min(bound.min_edge, min_edge)
    bound.max_edge = max(bound.max_edge, max_edge)
end

function Snap.getAlign(entity)
	local align = Snap.ALIGNMENT_OVERRIDES[entity.name] or 1
	if align > 1 then return align end

	local fast_replaceable_group=prototypes.entity[entity.name].fast_replaceable_group
	for name, value in ipairs(Snap.ALIGNMENT_OVERRIDES_GROUP) do
		if fast_replaceable_group == name then return value end
	end
	return 1
end

function Snap.blueprint_bounds(bp)
	Log.trace("Snap.blueprint_bounds")
    local prototypes = prototypes.entity

    local bounds = {
        x = { min_edge = nil, min = nil, mid = nil, max_edge = nil, max = nil },
        y = { min_edge = nil, min = nil, mid = nil, max_edge = nil, max = nil },
    }
    local align = 1

    local rect = {}  -- Reduce GC churn by declaring this here and updating it in the loop rather than reinitializing
    -- every pass

    for _, entity in pairs(bp.get_blueprint_entities() or {}) do
        local rot = Snap.ROTATIONS[entity.direction or 0]
        local box = prototypes[entity.name].selection_box
        rect[1] = box.left_top.x
        rect[2] = box.left_top.y
        rect[3] = box.right_bottom.x
        rect[4] = box.right_bottom.y

        local x1 = rect[rot[1]]
        local y1 = rect[rot[2]]
        local x2 = rect[rot[3]]
        local y2 = rect[rot[4]]

        if x1 > x2 then
            x1, x2 = -x1, -x2
        end
        if y1 > y2 then
            y1, y2 = -y1, -y2
        end

        update_bounds(bounds.x, entity.position.x, x1, x2)
        update_bounds(bounds.y, entity.position.y, y1, y2)
        if align == 1 then align = max(align, Snap.getAlign(entity) or align) end
	end

    for _, tile in pairs(bp.get_blueprint_tiles() or {}) do
        update_bounds(bounds.x, tile.position.x, -0.5, 0.5)
        update_bounds(bounds.y, tile.position.y, -0.5, 0.5)
    end

    -- return math.floor(xmin), math.floor(ymin), math.ceil(xmax), math.ceil(ymax), align
    return bounds, align
end

function Snap.offset_blueprint(bp, xoff, yoff, align)
	local bpt = Blueprint.exportToTable(bp)
	--print("INPUT:",serpent.block(bpt))
	Blueprint.offset(bpt, xoff, yoff)
	bpt.blueprint["snap-to-grid"] = {x=align,y=align}
	bpt.blueprint["absolute-snapping"] = true
	bpt.blueprint["position-relative-to-grid"] = nil -- {x=0,y=0}
	--print("OUTPUT:",serpent.block(bpt))
	local result = Blueprint.importFromTable(bp, bpt)
	--TODO result
end

local function calculate_offset(dir, bound, align)
    local o = (dir ~= nil and math.floor(((-bound.min_edge - (dir * (bound.max_edge-bound.min_edge)))/ align)) * align) or 0
    if dir == 1 then
        -- The math works out to offset by the total width/height if we're aligning to max, but we want the max to
        -- end up under the cursor.
        return o+align
    end
    return o
end

function Snap.align_blueprint(bp, xdir, ydir)
	Log.trace("Snap.align_blueprint")
    local bounds, align = Snap.blueprint_bounds(bp)
--    game.print("bounds.x=" .. serpent.line(bounds.x))
--    game.print("bounds.y=" .. serpent.line(bounds.y))
--    game.print("align=" .. align)

    local xoff = calculate_offset(xdir, bounds.x, align)
    local yoff = calculate_offset(ydir, bounds.y, align)

--    game.print("xoff=" .. xoff .. ", yoff=" .. yoff)

    return Snap.offset_blueprint(bp, xoff, yoff, align)
end


function Snap.nudge_blueprint(bp, xdir, ydir)
	Log.trace("Snap.nudge_blueprint")
    local align = 1

    for _, entity in pairs(bp.get_blueprint_entities() or {}) do
        if align == 1 then align = max(align, Snap.getAlign(entity) or align) end
    end

    xdir = xdir * align
    ydir = ydir * align

    return Snap.offset_blueprint(bp, xdir, ydir, align)
end


for k,_ in pairs(Snap.SNAPS) do
    actions["Kux-BlueprintExtensions_snap-" .. k].handler = Snap.on_snap_action
end
for k,_ in pairs(Snap.NUDGES) do
    actions["Kux-BlueprintExtensions_nudge-" .. k].handler = Snap.on_nudge_action
end


return Snap
