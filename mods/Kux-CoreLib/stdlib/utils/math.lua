--- Extends Lua 5.2 math.
--- @class StdLib.Utils.Math : math
--- @seea math
--- @usage local math = require('__Kux-CoreLib__/stdlib/utils/math') --[[@as StdLib.Utils.Math]]
local Math = {}

Math.frexp = math.frexp
Math.sqrt = math.sqrt
Math.asin = math.asin
Math.random = math.random
Math.huge = math.huge
Math.abs = math.abs
Math.ldexp = math.ldexp
Math.exp = math.exp
Math.pow = math.pow
Math.pi = math.pi
Math.tan = math.tan
Math.acos = math.acos
Math.ceil = math.ceil
Math.atan2 = math.atan2
Math.tanh = math.tanh
Math.sin = math.sin
Math.min = math.min
Math.deg = math.deg
Math.sinh = math.sinh
Math.rad = math.rad
Math.random = math.random
Math.cosh = math.cosh
Math.modf = math.modf
Math.cos = math.cos
Math.atan = math.atan
Math.max = math.max
Math.log = math.log
Math.fmod = math.fmod
Math.floor = math.floor

for k, v in pairs(math) do if not Math[k] then Math[k] = v end end

local math_abs = math.abs
local math_floor = math.floor
local math_ceil = math.ceil
local math_min = math.min
local math_max = math.max
local math_huge = math.huge
local math_pi = math.pi
local math_log = math.log
local unpack = table.unpack

-- (( Math Constants
Math.DEG2RAD = math_pi / 180
Math.RAD2DEG = 180 / math_pi
Math.EPSILON = 1.401298e-45

Math.MAXINT8 = 128
Math.MININT8 = -128
Math.MAXUINT8 = 255

Math.MAX_INT8 = Math.MAXINT8
Math.MIN_INT8 = Math.MININT8
Math.MAX_UINT8 = Math.MAXUINT8

Math.MAXINT16 = 32768
Math.MININT16 = -32768
Math.MAXUINT16 = 65535
Math.MAX_INT16 = Math.MAXINT16
Math.MIN_INT16 = Math.MININT16
Math.MAX_UINT16 = Math.MAXUINT16

Math.MAXINT = 2147483648
Math.MAX_INT = Math.MAXINT
Math.MAXINT32 = Math.MAXINT
Math.MAX_INT32 = Math.MAXINT

Math.MAXUINT = 4294967296
Math.MAX_UINT = Math.MAXUINT
Math.MAXUINT32 = Math.MAXUINT
Math.MAX_UINT32 = Math.MAXUINT

Math.MININT = -2147483648
Math.MIN_INT = Math.MININT
Math.MININT32 = Math.MININT
Math.MIN_INT32 = Math.MININT

Math.MAXINT64 = 9223372036854775808
Math.MININT64 = -9223372036854775808
Math.MAXUINT64 = 18446744073709551615
Math.MAX_INT64 = Math.MAXINT64
Math.MIN_INT64 = Math.MININT64
Math.MAX_UINT64 = Math.MAXUINT64
-- ))

local function tuple(...)
    return type(...) == 'table' and ... or { ... }
end

function Math.log10(x)
    return math_log(x, 10)
end

--- Round a number.
--- @param x number
--- @return number the rounded number
function Math.round(x)
    return x >= 0 and math_floor(x + 0.5) or math_ceil(x - 0.5)
end

-- Returns the number x rounded to p decimal places.
--- @param x number
--- @param p int? [opt=0] the number of decimal places to round to
--- @return number rounded to p decimal spaces.
function Math.round_to(x, p)
    local e = 10 ^ (p or 0)
    return math_floor(x * e + 0.5) / e
end

-- Returns the number floored to p decimal spaces.
--- @param x number
--- @param p int? [opt=0] the number of decimal places to floor to
--- @return number floored to p decimal spaces.
function Math.floor_to(x, p)
    if (p or 0) == 0 then return math_floor(x) end
    local e = 10 ^ p
    return math_floor(x * e) / e
end

-- Returns the number ceiled to p decimal spaces.
--- @param x number
--- @param p int? [opt=0] the number of decimal places to ceil to
--- @return number ceiled to p decimal spaces.
function Math.ceil_to(x, p)
    local e = 10 ^ (p or 0)
    return math_ceil(x * e + 0.5) / e
end

-- Various average (means) algorithms implementation
-- See: http://en.wikipedia.org/wiki/Average

--- Calculates the sum of a sequence of values.
--- @param ... number a tuple of numbers
--- @return number #the sum
--- @overload fun(...: number): number
--- @overload fun(array: number[]): number
function Math.sum(...)
    local x = tuple(...)
    local s = 0
    for _, v in ipairs(x) do s = s + v end
    return s
end

--- Calculates the arithmetic mean of a set of values.
--- @param ... number an array of numbers
--- @return number #the arithmetic mean
--- @overload fun(...: number): number
--- @overload fun(array: number[]): number
function Math.arithmetic_mean(...)
    local x = tuple(...)
    return (Math.sum(x) / #x)
end

Math.avg = Math.arithmetic_mean
Math.average = Math.arithmetic_mean

--- Calculates the geometric mean of a set of values.
--- @param ... number an array of numbers
--- @return number the geometric mean
--- @overload fun(...: number): number
--- @overload fun(array: number[]): number
function Math.geometric_mean(...)
    local x = tuple(...)
    local prod = 1
    for _, v in ipairs(x) do prod = prod * v end
    return (prod ^ (1 / #x))
end

--- Calculates the harmonic mean of a set of values.
--- @param ... number an array of numbers
--- @return number #the harmonic mean
--- @overload fun(...: number): number
--- @overload fun(array: number[]): number
function Math.harmonic_mean(...)
    local x = tuple(...)
    local s = 0
    for _, v in ipairs(x) do s = s + (1 / v) end
    return (#x / s)
end

--- Calculates the quadratic mean of a set of values.
--- @param ... number an array of numbers
--- @return number #the quadratic mean
--- @overload fun(...: number): number
--- @overload fun(array: number[]): number
function Math.quadratic_mean(...)
    local x = tuple(...)
    local squares = 0
    for _, v in ipairs(x) do squares = squares + (v * v) end
    return math.sqrt((1 / #x) * squares)
end

--- Calculates the generalized mean (to a specified power) of a set of values.
--- @param p number power
--- @param ... number an array of numbers
--- @return number #the generalized mean
--- @overload fun(...: number): number
--- @overload fun(array: number[]): number
function Math.generalized_mean(p, ...)
    local x = tuple(...)
    local sump = 0
    for _, v in ipairs(x) do sump = sump + (v ^ p) end
    return ((1 / #x) * sump) ^ (1 / p)
end

--- Calculates the weighted mean of a set of values.
--- @param x number[] an array of numbers
--- @param w number[] an array of number weights for each value
--- @return number #the weighted mean
function Math.weighted_mean(x, w)
    local sump = 0
    for i, v in ipairs(x) do sump = sump + (v * w[i]) end
    return sump / Math.sum(w)
end

--- Calculates the midrange mean of a set of values.
--- @param ... number an array of numbers
--- @return number #the midrange mean
--- @overload fun(...: number): number
--- @overload fun(array: number[]): number
function Math.midrange_mean(...)
    local x = tuple(...)
    return 0.5 * (math_min(unpack(x)) + math_max(unpack(x)))
end

--- Calculates the energetic mean of a set of values.
--- @param ... number an array of numbers
--- @return number #the energetic mean
--- @overload fun(...: number): number
--- @overload fun(array: number[]): number
function Math.energetic_mean(...)
    local x = tuple(...)
    local s = 0
    for _, v in ipairs(x) do s = s + (10 ^ (v / 10)) end
    return 10 * Math.log10((1 / #x) * s)
end

--- Returns the number x clamped between the numbers min and max.
--- @param x number
--- @param min number? [opt=0]
--- @param max number? [opt=1]
--- @return number clamped between min and max
function Math.clamp(x, min, max)
    min, max = min or 0, max or 1
    return x < min and min or (x > max and max or x)
end

--- Linear interpolation or 2 numbers.
--- @param a number
--- @param b number
--- @param amount float
--- @return number
function Math.lerp(a, b, amount)
    return a + (b - a) * Math.clamp(amount, 0, 1)
end

--- Smooth.
--- @param a number
--- @param b number
--- @param amount float
--- @return number
function Math.smooth(a, b, amount)
    local t = Math.clamp(amount, 0, 1)
    local m = t * t * (3 - 2 * t)
    return a + (b - a) * m
end

--- Approximately the same
--- @param a number
--- @param b number
--- @return boolean
function Math.approximately(a, b)
    return math_abs(b - a) < math_max(1e-6 * math_max(math_abs(a), math_abs(b)), 1.121039e-44)
end

--- Is x a number.
--- @param x number
--- @return boolean
function Math.is_number(x)
    return x == x and x ~= math_huge
end

--- Is x an integer.
--- @param x number
--- @return boolean
function Math.is_integer(x)
    return x == math_ceil(x)
end

--- Is x unsigned.
--- @param x number
--- @return boolean
function Math.is_unsigned(x)
    return x >= 0
end

return Math
