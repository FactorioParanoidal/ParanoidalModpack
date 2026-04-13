---@meta

---@alias Position  MapPosition -- TODO maybe also TilePosition or ChunkPosition, need deeper check

--TODO: verify memebers generated with ChatGPT

--- math class
--- @class math
--- @field pi number The mathematical constant pi (≈ 3.14159).
--- @field radianConversion number The conversion factor from degrees to radians.
--- @field sqrt fun(x: number): number Returns the square root of `x`.
--- @field abs fun(x: number): number Returns the absolute value of `x`.
--- @field acos fun(x: number): number Returns the arc cosine of `x` (in radians).
--- @field asin fun(x: number): number Returns the arc sine of `x` (in radians).
--- @field atan fun(x: number): number Returns the arc tangent of `x` (in radians).
--- @field atan2 fun(y: number, x: number): number Returns the arc tangent of the quotient `y/x` (in radians).
--- @field ceil fun(x: number): number Returns the smallest integer greater than or equal to `x`.
--- @field cos fun(x: number): number Returns the cosine of `x` (in radians).
--- @field deg fun(x: number): number Converts `x` from radians to degrees.
--- @field exp fun(x: number): number Returns `e` raised to the power of `x`.
--- @field floor fun(x: number): number Returns the largest integer less than or equal to `x`.
--- @field fmod fun(x: number, y: number): number Returns the remainder of `x` divided by `y`.
--- @field frexp fun(x: number): number, number Returns the mantissa and exponent of `x`.
--- @field log fun(x: number, base: number?): number Returns the logarithm of `x` to the given `base` (natural logarithm if `base` is not provided).
--- @field log10 fun(x: number): number Returns the base-10 logarithm of `x`.
--- @field max fun(...:number): number Returns the largest value among the arguments.
--- @field min fun(...:number): number Returns the smallest value among the arguments.
--- @field modf fun(x: number): number, number Returns the integral and fractional parts of `x`.
--- @field rad fun(x: number): number Converts `x` from degrees to radians.
--- @field random fun(a: number?, b: number?): number Returns a random number between `a` and `b` (inclusive) or between 0 and 1 if no arguments are provided.
--- @field sin fun(x: number): number Returns the sine of `x` (in radians).
--- @field sinh fun(x: number): number Returns the hyperbolic sine of `x`.
--- @field tan fun(x: number): number Returns the tangent of `x` (in radians).
--- @field tanh fun(x: number): number Returns the hyperbolic tangent of `x`.
--- @field todegrees fun(x: number): number Converts `x` from radians to degrees.
--- @field toradians fun(x: number): number Converts `x` from degrees to radians.


--TODO: verify members generated with ChatGPT

--- string type
--- @class string
--- @field byte fun(s: string, i: number?, j: number?): number, number Returns the internal byte values of the characters in `s` from position `i` to `j`.
--- @field char fun(...:number): string Converts one or more numbers to characters and returns them as a string.
--- @field dump fun(s: string, option?: boolean): string Returns a string containing a bytecode dump of a string (for debugging).
--- @field find fun(s: string, pattern: string, init?: number, plain?: boolean): number, number Finds the first match of `pattern` in `s` and returns its start and end positions.
--- @field format fun(f: string, ...): string Returns a formatted string, similar to `sprintf` in C.
--- @field gmatch fun(s: string, pattern: string): fun() Returns an iterator function that matches the `pattern` in `s`.
--- @field gsub fun(s: string, pattern: string, repl: string, n?: number): string, number Replaces occurrences of `pattern` in `s` with `repl`, and optionally limits the number of replacements.
--- @field len fun(s: string): number Returns the length of the string `s`.
--- @field lower fun(s: string): string Converts `s` to lowercase.
--- @field match fun(s: string, pattern: string): string Matches the first occurrence of `pattern` in `s` and returns it.
--- @field rep fun(s: string, n: number): string Repeats the string `s`, `n` times.
--- @field reverse fun(s: string): string Reverses the string `s`.
--- @field sub fun(s: string, i: number, j: number?): string Returns the substring of `s` from position `i` to `j`.
--- @field upper fun(s: string): string Converts `s` to uppercase.
--- @field trim fun(s: string): string Trims whitespace from both ends of `s`.
--- @field split fun(s: string, pattern: string): table Splits `s` into a table using the given `pattern` as a delimiter.

---TODO: verify members generated with ChatGPT

---table  type
---@class table
---@field insert fun(list: table, pos: integer|nil, value: any) Inserts a value at the end or at a specified position in the table.
---@field remove fun(list: table, pos: integer|nil): any Removes the value at a specified index and returns it.
---@field concat fun(list: table, sep: string|nil, i: integer|nil, j: integer|nil): string Concatenates the values in a table into a string, with optional separator, start, and end indices.
---@field sort fun(list: table, comp: function|nil) Sorts the values in the table in ascending order or based on a provided comparator function.
---@field unpack fun(list: table, i: integer|nil, j: integer|nil): ... Returns all elements from a table within an optional range.
---@field move fun(a1: table, f: integer, e: integer, t: integer, a2: table|nil): table Moves a range of elements from a source table to a target table or within the same table.
---@field pack fun(...: any): table Packs all given arguments into a table with an `n` field indicating the count of arguments.
---@field clear fun(t: table) Clears all elements from a table (available only in LuaJIT).
---@field foreach fun(t: table, f: function) Applies a function to each key-value pair in a table (deprecated in Lua 5.1 and later).
---@field foreachi fun(t: table, f: function) Applies a function to each numeric key in a table (deprecated in Lua 5.1 and later).
---@field getn fun(t: table): integer Returns the number of elements in a table (deprecated, use `#t` instead).
---@field maxn fun(t: table): integer Returns the highest numeric index in a table (deprecated).

---@alias array any[]

---@alias anyevent table