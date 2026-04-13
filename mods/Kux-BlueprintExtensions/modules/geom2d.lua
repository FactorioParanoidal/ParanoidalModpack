local Geom2D = {}


local tau = 2*math.pi
local sin = math.sin
local cos = math.cos
local floor = math.floor
local ceil = math.ceil


-- Generate transforms for rotations
local d = defines.direction

local rotations = {
    [d.north]     = { 1,  0,  0,  1 },   -- Keine Änderung
    [d.northeast] = {-1,  0,  0,  1 },   -- Spiegelung an der X-Achse
    [d.east]      = { 0, -1,  1,  0 },   -- 90° Drehung
    [d.southeast] = { 0, -1, -1,  0 },   -- 90° Drehung und Spiegelung
    [d.south]     = {-1,  0,  0, -1 },   -- 180° Drehung
    [d.southwest] = { 1,  0,  0, -1 },   -- Spiegelung an der Y-Achse
    [d.west]      = { 0,  1, -1,  0 },   -- 270° Drehung
    [d.northwest] = { 0,  1,  1,  0 }    -- 270° Drehung und Spiegelung
}

Geom2D.rotations = rotations

local Rect = {}
do
    --local almost_one = 0.99999999999999
    local almost_one = 1

    Rect.__mt = { __index = Rect }


    function Rect:clone(into)
        --log(serpent.line(self))
        if not into then
            into = {}
        end
        for k, v in pairs(self) do
            into[k] = v
        end
        setmetatable(into, self.__mt)
        return into
    end


    function Rect.from_box(box, t)
        local x1 = box.left_top.x
        local x2 = box.right_bottom.x
        local y1 = box.left_top.y
        local y2 = box.right_bottom.y
        local orientation = box.orientation or 0
        local dir = nil

        if t == nil then
            t = { 1, 2, 3, 4, 5, 6, 7, 8, xmin = nil, xmax = nil, ymin = nil, ymax = nil, orientation = orientation }
            setmetatable(t, Rect.__mt)
        else
            t.orientation = orientation
        end

        if orientation == 0.75 then
            dir = d.west
        elseif orientation == 0.50 then
            dir = d.south
        elseif orientation == 0.25 then
            dir = d.east
        elseif orientation == 0 then
            dir = d.north
        end

        if dir ~= nil then
            t[1], t[2] = x1, y1
            t[3], t[4] = x2, y1
            t[5], t[6] = x2, y2
            t[7], t[8] = x1, y2
            t.right = true
            t.xmin, t.xmax = x1, x2
            t.ymin, t.ymax = y1, y2
            return t:rotate(dir)
        else
            t.right = false
        end

        local xo = (x1 + x2) / 2
        local yo = (y1 + y2) / 2
        x1, x2, y1, y2 = x1 - xo, x2 - xo, y1 - yo, y2 - yo

        local theta = orientation * tau
        local sin_theta = sin(theta)
        local cos_theta = cos(theta)
        local xmin, xmax, ymin, ymax

        local function _r(i, x, y)
            x, y = xo + x * cos_theta - y * sin_theta, yo + x * sin_theta + y * cos_theta
            if i == 1 then
                xmin, xmax = x, x
                ymin, ymax = y, y
            else
                if xmin > x then
                    xmin = x
                end
                if ymin > y then
                    ymin = y
                end
                if xmax < x then
                    xmax = x
                end
                if ymax < y then
                    ymax = y
                end
            end
            t[i], t[i + 1] = x, y
        end
        _r(1, x1, y1)
        _r(3, x2, y1)
        _r(5, x2, y2)
        _r(7, x1, y2)
        t.xmin, t.xmax = xmin, xmax
        t.ymin, t.ymax = ymin, ymax
        return t
    end


    function Rect:rotate(dir)
        local xx, xy, yx, yy = table.unpack(rotations[dir])
        local x, y

        local xmin, ymin, xmax, ymax

        for i = 1, 7, 2 do
            x = self[i]
            y = self[i+1]
            x, y = x*xx + y*xy, x*yx + y*yy
            if i == 1 then
                xmin, xmax = x, x
                ymin, ymax = y, y
            else
                if xmin > x then xmin = x end
                if ymin > y then ymin = y end
                if xmax < x then xmax = x end
                if ymax < y then ymax = y end
            end
            self[i], self[i+1] = x, y
        end

        self.xmin, self.xmax = xmin, xmax
        self.ymin, self.ymax = ymin, ymax

        return self
    end


    function Rect:translate(x, y)
        self.xmin = self.xmin + x
        self.xmax = self.xmax + x
        self.ymin = self.ymin + y
        self.ymax = self.ymax + y
        for i = 1, 7, 2 do
            self[i] = self[i] + x
            self[i+1] = self[i+1] + y
        end

        return self
    end

    local function _extents(ax, ay, rect)
        local n, px, py, dot, min, max
        local divisor = ax*ax+ay*ay
        for i = 1, 8, 2 do
            n = (rect[i]*ax + rect[i+1]*ay) / divisor
            dot = n*ax*ax + n*ay*ay

            if i == 1 then
                min, max = dot, dot
            else
                if min > dot then min = dot end
                if max < dot then max = dot end
            end
        end
        return min, max
    end

    local function _extents2(ax, ay, x, y)
        local n, px, py, dot, min, max
        local divisor = ax*ax+ay*ay

        for xp = 0, 1 do
            for yp = 0, 1 do
                n = ((x+(xp*almost_one))*ax + (y+(yp*almost_one))*ay) / divisor
                dot = n*ax*ax + n*ay*ay
                if min == nil then
                    min, max = dot, dot
                else
                    if min > dot then min = dot end
                    if max < dot then max = dot end
                end
            end
        end
        return min, max
    end


    function Rect:overlaps(other)
        if not (self.xmax >= other.xmin and other.xmax >= self.xmin and self.ymax >= other.ymin and other.ymax >= self.ymin) then
            return false
        end

        local function check_axis(ax, ay)
            local amin, amax = _extents(ax, ay, self)
            local bmin, bmax = _extents(ax, ay, other)
            return (bmax >= amin and amax >= bmin)
        end

        return (
                check_axis(self[3] - self[1], self[4] - self[2])
                        and check_axis(self[3] - self[5], self[4] - self[6])
                        and check_axis(other[3] - other[1], other[4] - other[2])
                        and check_axis(other[3] - other[5], other[4] - other[6])
        )
    end


    function Rect:tiles(result, tile_name)
        tile_name = tile_name or true
        if not result then
            result = {}
            setmetatable(result, { __index = function(t, k) local v = {}; t[k] = v; return v end })
        end

        if self.right then
            for x = floor(self.xmin), ceil(self.xmax - 1) do
                for y = floor(self.ymin), ceil(self.ymax - 1) do
                    result[x][y] = tile_name
                end
            end
            return result
        end

        local function check_axis(ax, ay, x, y)
            local amin, amax = _extents(ax, ay, self)
            local bmin, bmax = _extents2(ax, ay, x, y)
            return (bmax >= amin and amax >= bmin)
        end

        -- {0, 0, 0, 1, 1, 1, 1, 0 }
        --game.print(serpent.line(self))
        for x = floor(self.xmin), ceil(self.xmax) do
            for y = floor(self.ymin), ceil(self.ymax) do
                if (
                        check_axis(self[3] - self[1], self[4] - self[2], x, y)
                        and check_axis(self[3] - self[5], self[4] - self[6], x, y)
                        and check_axis(0, almost_one, x, y)
                        and check_axis(-almost_one, 0, x, y)
                ) then
                    result[x][y] = tile_name
                end
            end
        end

        return result
    end
end


Geom2D.Rect = Rect

local area_to_rectangle, is_overlapping_rectangle, get_overlapping_tiles
do
    -- It's not shameless theft if I stole it from my own mod.
    -- Adapted from math shown at:
    -- https://www.gamedev.net/articles/programming/general-and-gameplay-programming/2d-rotated-rectangle-collision-r2604/
    local tau = 2*math.pi
    local sin = math.sin
    local cos = math.cos
    local floor = math.floor
    local ceil = math.ceil
    local almost_one = 1.0

    function area_to_rectangle(box, t)
        local x1 = box.left_top.x
        local x2 = box.right_bottom.x
        local y1 = box.left_top.y
        local y2 = box.right_bottom.y

        if not t then
            -- No table to reuse, so create a new one.
            t = {1, 2, 3, 4, 5, 6, 7, 8, xmin=nil, xmax=nil, ymin=nil, ymax=nil, orientation=(box.orientation or 0)}
        end

        if (not box.orientation) or (box.orientation == 0) then
            t[1], t[2] = x1, y1
            t[3], t[4] = x2, y1
            t[5], t[6] = x2, y2
            t[7], t[8] = x1, y2
            t.xmin, t.xmax = x1, x2
            t.ymin, t.ymax = y1, y2
            return t
        end

        local xo = (x1 + x2) / 2
        local yo = (y1 + y2) / 2
        x1, x2, y1, y2 = x1 - xo, x2 - xo, y1 - yo, y2 - yo

        local theta = box.orientation * tau
        local sin_theta = sin(theta)
        local cos_theta = cos(theta)
        local xmin, xmax, ymin, ymax

        local function _r(i, x, y)
            x, y = xo + x*cos_theta - y*sin_theta, yo + x*sin_theta + y*cos_theta
            if i == 1 then
                xmin, xmax = x, x
                ymin, ymax = y, y
            else
                if xmin > x then xmin = x end
                if ymin > y then ymin = y end
                if xmax < x then xmax = x end
                if ymax < y then ymax = y end
            end
            t[i], t[i+1] = x, y
        end
        _r(1, x1, y1)
        _r(3, x2, y1)
        _r(5, x2, y2)
        _r(7, x1, y2)
        t.xmin, t.xmax = xmin, xmax
        t.ymin, t.ymax = ymin, ymax
        return t
    end

    local function _extents(ax, ay, rect)
        local n, px, py, dot, min, max
        local divisor = ax*ax+ay*ay
        for i = 1, 8, 2 do
            --x, y = unpack(rect[i])
            n = (rect[i]*ax + rect[i+1]*ay) / divisor
            --px = n*ax
            --py = n*ay
            --dot = px*ax + py*ay
            dot = n*ax*ax + n*ay*ay

            if i == 1 then
                min, max = dot, dot
            else
                if min > dot then min = dot end
                if max < dot then max = dot end
            end
        end
        return min, max
    end

    local function _extents2(ax, ay, x, y)
        local n, px, py, dot, min, max
        local divisor = ax*ax+ay*ay

        for xp = 0, 1 do
            for yp = 0, 1 do
                n = ((x+(xp*almost_one))*ax + (y+(yp*almost_one))*ay) / divisor
                dot = n*ax*ax + n*ay*ay
                if min == nil then
                    min, max = dot, dot
                else
                    if min > dot then min = dot end
                    if max < dot then max = dot end
                end
            end
        end
        --
        --n = (x*ax + y*ay) / divisor
        --min = n*ax*ax + n*ay*ay
        --n = ((x+almost_one)*ax + (y+almost_one*ay)) / divisor
        --max = n*ax*ax + n*ay*ay
        --
        --if max < min then
        --    return max, min
        --else
        --    return min, max
        --end
        return min, max
    end

    function is_overlapping_rectangle(a, b)
        if not (a.xmax >= b.xmin and b.xmax >= a.xmin and a.ymax >= b.ymin and b.ymax >= a.ymin) then
            return false
        end

        local function check_axis(ax, ay)
            local amin, amax = _extents(ax, ay, a)
            local bmin, bmax = _extents(ax, ay, b)
            return (bmax >= amin and amax >= bmin)
        end

        return (
                check_axis(a[3] - a[1], a[4] - a[2])
                and check_axis(a[3] - a[5], a[4] - a[6])
                and check_axis(b[3] - b[1], b[4] - b[2])
                and check_axis(b[3] - b[5], b[4] - b[6])
        )
    end

    function get_overlapping_tiles(rect, result, tile)
        tile = tile or true
        if not result then
            result = {}
            setmetatable(result, { __index = function(t, k) local v = {}; t[k] = v; return v end })
        end

        if not rect.orientation or rect.orientation == 0 then
            for x = floor(rect.left_top.x), ceil(rect.right_bottom.x - 1) do
                for y = floor(rect.left_top.y), ceil(rect.right_bottom.y - 1) do
                    result[x][y] = tile
                end
            end
            return result
        end

        local rect = area_to_rectangle(rect)  -- Convert to box

        local function check_axis(ax, ay, x, y)
            local amin, amax = _extents(ax, ay, rect)
            local bmin, bmax = _extents2(ax, ay, x, y)
            return (bmax >= amin and amax >= bmin)
        end

        -- {0, 0, 0, 1, 1, 1, 1, 0 }

        for x = floor(rect.xmin), ceil(rect.xmax) do
            for y = floor(rect.ymin), ceil(rect.ymax) do
                if (
                        check_axis(rect[3] - rect[1], rect[4] - rect[2], x, y)
                        and check_axis(rect[3] - rect[5], rect[4] - rect[6], x, y)
                        and check_axis(0, almost_one, x, y)
                        and check_axis(-almost_one, 0, x, y)
                ) then
                    result[x][y] = tile
                end
            end
        end

        return result
    end


end
Geom2D.get_overlapping_tiles = get_overlapping_tiles
Geom2D.is_overlapping_rectangle = is_overlapping_rectangle
Geom2D.area_to_rectangle = area_to_rectangle


return Geom2D
