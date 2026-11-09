-- Table and array functions

---@class Core.Lib.Table
local lib = {}

local type = _G.type
local pairs = _G.pairs
local select = _G.select
local random = math.random
local setmetatable = _G.setmetatable
local getmetatable = _G.getmetatable

---An empty table enforced via metamethod.
local empty = setmetatable({}, { __newindex = function() end })
lib.empty = empty
lib.EMPTY = setmetatable({}, { __newindex = function() end })

---An empty table that will crash if anyone tries to write to it.
lib.EMPTY_STRICT = setmetatable({}, {
	__newindex = function() error("Attempt to write to EMPTY_STRICT table", 2) end,
})

---Shallowly compare two arrays using `==`
---@param A any[]
---@param B any[]
---@return boolean
function lib.a_eqeq(A, B)
	if #A ~= #B then return false end
	for i = 1, #A do
		if A[i] ~= B[i] then return false end
	end
	return true
end

---Recursively copy the contents of a table into a new table.
---@generic T
---@param tbl T The table to make a copy of.
---@param ignore_metatables boolean? If true, ignores metatables while copying.
---@return T
function lib.deep_copy(tbl, ignore_metatables)
	local lookup_table = {}
	local function _copy(_tbl)
		if type(_tbl) ~= "table" then
			return _tbl
		elseif lookup_table[_tbl] then
			return lookup_table[_tbl]
		end
		local new_table = {}
		lookup_table[_tbl] = new_table
		for index, value in pairs(_tbl) do
			new_table[_copy(index)] = _copy(value)
		end
		if ignore_metatables then
			return new_table
		else
			return setmetatable(new_table, getmetatable(_tbl))
		end
	end
	return _copy(tbl)
end

---Shallowly copies each given table into `dest`, returning `dest`.
---@generic K, V, T
---@param dest T extends {[K]: V} | table<K, V>
---@param ... {[K]: V} | table<K, V> | nil
---@return T dest
local function assign(dest, ...)
	local n = select("#", ...)
	if n == 0 then return dest end
	for i = 1, n do
		local src = select(i, ...)
		if type(src) == "table" then
			for k, v in pairs(src) do
				dest[k] = v
			end
		end
	end
	return dest
end
lib.assign = assign

---@generic T
---@param t T
---@return T
function lib.shallow_copy(t) return assign({}, t) end

---Concatenate all input arrays into a single new result array
---@generic T
---@param ... T[][]
---@return T[]
function lib.concat(...)
	local A = {}
	for i = 1, select("#", ...) do
		local B = select(i, ...)
		if B ~= nil then
			for j = 1, #B do
				A[#A + 1] = B[j]
			end
		end
	end
	return A
end

---Concatenate all input arrays into a single new result array, applying the
---given filter function to each element. Only elements for which the
---filter function returns true will be included in the result.
---@generic T
---@param f fun(value: T, index: integer): boolean
---@param ... T[][]
---@return T[]
function lib.concat_filter(f, ...)
	local A = {}
	for i = 1, select("#", ...) do
		local B = select(i, ...)
		if B ~= nil then
			for j = 1, #B do
				local value = B[j]
				if f(value, j) then A[#A + 1] = value end
			end
		end
	end
	return A
end

---Appends all non-`nil` args to the array `A`, returning `A`
---@generic T
---@param A T[]
---@param ... T?
---@return T[]
function lib.append(A, ...)
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value ~= nil then A[#A + 1] = value end
	end
	return A
end

---Filter an array by a predicate function.
---@generic T
---@param A T[]
---@param f fun(value: T, index: integer): boolean
---@return T[] #A new array containing all elements of `A` for which the predicate returned true.
local function filter(A, f)
	local B = {}
	for i = 1, #A do
		if f(A[i], i) then B[#B + 1] = A[i] end
	end
	return B
end
lib.filter = filter

---Split an array into two partitions based on a predicate function.
---@generic T
---@param A T[]
---@param f fun(value: T, index: integer): boolean
---@return T[] #an array containing all elements of `A` for which the predicate returned true.
---@return T[] #an array containing all elements of `A` for which the predicate returned false.
function lib.split(A, f)
	local T, F = {}, {}
	for i = 1, #A do
		if f(A[i], i) then
			T[#T + 1] = A[i]
		else
			F[#F + 1] = A[i]
		end
	end
	return T, F
end

---Map an array to an array. Non-nil results of the mapping function
---will be collected into a new result array.
---@generic I, O
---@param A I[]
---@param f fun(value: I, index: integer): O?
---@return O[]
function lib.map(A, f)
	local B = {}
	for i = 1, #A do
		local x = f(A[i], i)
		if x ~= nil then B[#B + 1] = x end
	end
	return B
end

---Map a numeric for loop into an array via a mapping function.
---@generic T
---@param min integer
---@param max integer
---@param step integer
---@param f fun(i: integer): T
---@return T[]
function lib.map_range(min, max, step, f)
	local A = {}
	for i = min, max, step do
		A[#A + 1] = f(i)
	end
	return A
end

---Run a function for each element in a table.
---@generic K, V
---@param T { [K]: V } | V[]
---@param f fun(value: V, key: K)
function lib.for_each(T, f)
	for k, v in pairs(T) do
		f(v, k)
	end
end

---Find the first entry in a table matching the given predicate.
---@generic K, V
---@param T {[K]: V}
---@param f fun(value: V, key: K): boolean?
---@return V? value The value of the first matching entry, or `nil` if none was found
---@return K? key The key of the first matching entry, or `nil` if none was found
function lib.find(T, f)
	for k, v in pairs(T) do
		if f(v, k) then return v, k end
	end
end

---Map a table into an array. Non-nil results of the mapping function
---will be collected into a new result array.
---@generic K, V, O
---@param T {[K] : V}
---@param f fun(value: V, key: K): O?
---@return O[]
function lib.t_map_a(T, f)
	local A = {}
	for k, v in pairs(T) do
		local x = f(v, k)
		if x ~= nil then A[#A + 1] = x end
	end
	return A
end

---Map a table into another table. The mapping function should return
---a key-value pair, or `nil` to omit the entry. The new table will be
---gathered from the returned pairs.
---@generic K, V, L, W
---@param T {[K]: V}
---@param f fun(key: K, value: V): L?, W?
---@return {[L]: W}
function lib.t_map_t(T, f)
	local U = {}
	for k, v in pairs(T) do
		local k2, v2 = f(k, v)
		if k2 ~= nil then U[k2] = v2 end
	end
	return U
end

---Map an array into a table. The mapping function should return
---a key-value pair, or `nil` to omit the entry. The new table will be
---gathered from the returned pairs.
---@generic T, K, V
---@param A T[]
---@param f fun(entry: T, index: integer): K?, V?
---@return {[K]: V}
function lib.a_map_t(A, f)
	local T = {}
	for i = 1, #A do
		local k2, v2 = f(A[i], i)
		if k2 ~= nil then T[k2] = v2 end
	end
	return T
end

---Reduce a table to a single value by applying a reducer function.
---@generic K, V, A
---@param T {[K]: V}
---@param initial A The initial accumulator value.
---@param reducer fun(acc: A, key: K, value: V): A The reducer function.
---@return A acc The final accumulated value.
function lib.t_reduce(T, initial, reducer)
	local acc = initial
	for k, v in pairs(T) do
		acc = reducer(acc, k, v)
	end
	return acc
end

---Map over the elements of an array, flattening out one level of arrays.
---@generic I, O
---@param A I[]
---@param f fun(x: I): O[]
---@return O[]
function lib.flat_map(A, f)
	local B = {}
	for i = 1, #A do
		local C = f(A[i])
		if C then
			for j = 1, #C do
				B[#B + 1] = C[j]
			end
		end
	end
	return B
end

---Return an array containing the keys of the given table.
---@generic K
---@param T { [K]: any }
---@return K[]
function lib.keys(T)
	local A = {}
	for k in pairs(T) do
		A[#A + 1] = k
	end
	return A
end

---Fisher-Yates shuffle an array in place.
---@generic T
---@param A T[]
---@return T[] A The shuffled array.
function lib.shuffle(A)
	for i = #A, 2, -1 do
		local j = random(i)
		A[i], A[j] = A[j], A[i]
	end
	return A
end

---Generates a stateless iterator for use with `for` that iterates over
---groups of items in an array. The array is assumed to consist of items
---pre-sorted on a particular key. The iterator returns subranges of the
---array with equal keys.
function lib.groups(A, key)
	return function(k, i)
		if i > #A then return nil end
		local start = i
		local current = A[i][k]
		while i <= #A and A[i][k] == current do
			i = i + 1
		end
		return i, start, i - 1
	end,
		key,
		1
end

---Group an array of objects by running a key-generating function on each object.
---Objects with the same key value will be collected into an array under that key.
---Objects for which the key function returns `nil` will be skipped.
---@generic T
---@param A T[]
---@param key_fn fun(value: T): string|number The key-generating function.
---@return table<string|number, T[]> #A table mapping from key values to arrays of objects with that key value.
function lib.group_by(A, key_fn)
	local result = {}
	for i = 1, #A do
		local obj = A[i]
		local k = key_fn(obj)
		if k ~= nil then
			local group = result[k]
			if group == nil then
				group = {}
				result[k] = group
			end
			group[#group + 1] = obj
		end
	end
	return result
end

---Given an array of objects pre-sorted on a given key, return an array
---of arrays of those objects grouped by the given key.
---@generic T, K
---@param A T[] The array of objects.
---@param key K The key to group by.
---@return T[][] #An array of arrays, where each sub-array contains objects with the same key.
function lib.sorted_group_by(A, key)
	local result = {}
	local i = 1
	while i <= #A do
		local group = {}
		local current = A
			[i]--[[@cast -?]]
			[key]
		while
			i <= #A and A
				[i]--[[@cast -?]]
				[key] == current
		do
			group[#group + 1] = A[i]
			i = i + 1
		end
		result[#result + 1] = group
	end
	return result
end

---Given an array of arrays, return a new array of arrays whose members are
---the original arrays, filtered by the given filter function, with empty
---inner arrays dropped.
---@generic T
---@param A T[][] The array of arrays.
---@param f fun(value: T, index: integer): boolean The filter function.
---@return T[][] #A new array of arrays, filtered by the given function.
function lib.filter_groups(A, f)
	local result = {}
	for i = 1, #A do
		local group = filter(A[i], f)
		if #group > 0 then result[#result + 1] = group end
	end
	return result
end

---@param a any[]
---@param i uint
local function irnext(a, i)
	i = i + 1
	if i <= #a then
		local r = a[#a - i + 1]
		return i, r
	else
		return nil, nil
	end
end

---Iterate an array in reverse
---@generic T
---@param a T[]
function lib.irpairs(a) return irnext, a, 0 end

---Filter an array in place, returning the array.
---@generic T
---@param A T[]
---@param f fun(value: T, index: integer): any If truthy, the value is kept; if falsy, it is removed.
---@return T[] A The filtered array.
function lib.filter_in_place(A, f)
	local j = 1
	for i = 1, #A do
		if f(A[i], i) then
			A[j] = A[i]
			j = j + 1
		end
	end
	for i = #A, j, -1 do
		A[i] = nil
	end
	return A
end

---Filter a table in place.
---@generic K, V
---@param T table<K, V>
---@param f fun(key: K, value: V): boolean?
---@return table<K, V> T The filtered table.
function lib.filter_table_in_place(T, f)
	for k, v in pairs(T) do
		if not f(k, v) then T[k] = nil end
	end
	return T
end

---Pairwise add a*T2 to T1, in-place.
---@generic K, V
---@param T1 {[K]: V}
---@param a V
---@param T2 {[K]: V}
function lib.vector_add(T1, a, T2)
	for k, v in pairs(T2) do
		T1[k] = (T1[k] or 0) + a * v
	end
end

---Pairwise sum two tables whose values are numerical. Computes
---`a * T1 + b * T2`
---@generic K, V
---@param a V
---@param T1 {[K]: V}
---@param b V
---@param T2 {[K]: V}
function lib.vector_sum(a, T1, b, T2)
	local result = {}
	for k, v in pairs(T1) do
		result[k] = a * v + b * (T2[k] or 0)
	end
	for k, v in pairs(T2) do
		if not T1[k] then result[k] = b * v end
	end
	return result
end

---Given a single value, return an iterator that returns that value once.
---Given an array, return an iterator that returns each element of the array.
---@generic T
---@param x T | T[]
---@return fun(val: T | T[], idx: integer): integer?, T?
---@return T | T[]
---@return integer
function lib.iter(x)
	if type(x) == "table" then
		---EmmyLua bug: doesnt understand multi return value passthrough
		---@diagnostic disable-next-line: missing-return-value
		return ipairs(x)
	else
		return function(val, idx)
			if idx == 0 then return 1, val end
			return nil
		end,
			x,
			0
	end
end

---Given tables representing sets (with keys as elements and `true` as values),
---union them onto the first input set, mutating that set in place.
---@param dest table<any, boolean> The destination set.
---@param ... table<any, boolean> The source sets.
---@return table<any, boolean> dest The destination set.
function lib.set_union(dest, ...)
	for i = 1, select("#", ...) do
		local src = select(i, ...)
		for k in pairs(src) do
			dest[k] = true
		end
	end
	return dest
end

---An iterator over table entries filtered by a predicate function.
---@generic K, V
---@param T {[K]: V}
---@param predicate fun(key: K, value: V): boolean?
---@return fun(t: {[K]: V}, k: K?): K?, V?
---@return {[K]: V}
---@return K?
function lib.filtered_pairs(T, predicate)
	local function iter(t, k)
		local v
		k, v = next(t, k)
		while k ~= nil and not predicate(k, v) do
			k, v = next(t, k)
		end
		return k, v
	end
	return iter, T, nil
end

return lib
