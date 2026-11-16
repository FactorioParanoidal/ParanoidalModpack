--- Additional utilities for working with tables. For arrays, see the `array` module.
--- ```lua
--- local flib_table: = require("__flib__.table")
--- ```
--- @class flib_table
local flib_table = {}

--- Checks that the predicate is true for all values of the table.
--- @generic K, V
--- @param tbl table<K, V>
--- @param predicate fun(value: V, key: K): boolean
--- @return boolean
function flib_table.all_of(tbl, predicate)
  for k, v in pairs(tbl) do
    if not predicate(v, k) then
      return false
    end
  end
  return true
end

--- Checks that the predicate is true at least one entry of the table.
--- @generic K, V
--- @param tbl table<K, V>
--- @param predicate fun(value: V, key: K): boolean
--- @return boolean
function flib_table.any_of(tbl, predicate)
  for k, v in pairs(tbl) do
    if predicate(v, k) then
      return true
    end
  end
  return false
end

--- Recursively compares two tables for inner equality. Does not compare metatables.
--- @generic T: table
--- @param tbl1 T
--- @param tbl2 T
--- @return boolean
function flib_table.deep_compare(tbl1, tbl2)
  if tbl1 == tbl2 then
    return true
  end
  for k, v in pairs(tbl1) do
    if type(v) == "table" and type(tbl2[k]) == "table" then
      if not flib_table.deep_compare(v, tbl2[k]) then
        return false
      end
    else
      if v ~= tbl2[k] then
        return false
      end
    end
  end
  for k in pairs(tbl2) do
    if tbl1[k] == nil then
      return false
    end
  end
  return true
end

--- Recursively copies the contents of a table into a new table. Does not create new copies of Factorio objects.
--- @generic T
--- @param tbl T
--- @return T
function flib_table.deep_copy(tbl)
  local lookup_table = {}
  local function _copy(tbl)
    if type(tbl) ~= "table" then
      return tbl
    elseif lookup_table[tbl] then
      return lookup_table[tbl]
    end
    local new_table = {}
    lookup_table[tbl] = new_table
    for index, value in pairs(tbl) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(tbl))
  end
  return _copy(tbl)
end

--- Recursively merges two or more tables.
---
--- Values from earlier tables are overwritten by values from later tables, unless both values are tables, in which case
--- they are recursively merged.
---
--- Non-merged tables are deep-copied, so the result is brand-new.
---
--- ### Examples
---
--- ```lua
--- local tbl = {foo = "bar"}
--- log(tbl.foo) -- logs "bar"
--- log (tbl.bar) -- errors (key is nil)
--- tbl = table.merge{tbl, {foo = "baz", set = 3}}
--- log(tbl.foo) -- logs "baz"
--- log(tbl.set) -- logs "3"
--- ```
--- @generic K, V
--- @param tables table<K, V>[] An array of tables to merge.
--- @return table<K, V>
function flib_table.deep_merge(tables)
  local output = {}
  for _, tbl in ipairs(tables) do
    for k, v in pairs(tbl) do
      if type(v) == "table" then
        if type(output[k] or false) == "table" then
          output[k] = flib_table.deep_merge({ output[k], v })
        else
          output[k] = flib_table.deep_copy(v)
        end
      else
        output[k] = v
      end
    end
  end
  return output
end

--- Finds the first key of the given element in the table. The search order is determined by the `pairs()` function.
---
--- ### Examples
---
--- ```lua
--- local tbl = {"foo", "bar"}
--- local key_of_foo = table.find(tbl, "foo") -- 1
--- local key_of_baz = table.find(tbl, "baz") -- nil
--- ```
--- @generic K, V
--- @param tbl table<K, V> The table to search.
--- @param value V The value to match. Must have an `eq` metamethod set, otherwise will error.
--- @return K? key The first key corresponding to `value`, if any.
function flib_table.find(tbl, value)
  for k, v in pairs(tbl) do
    if v == value then
      return k
    end
  end
end

--- Retrieves the value at the key, or inserts the default value.
--- @generic K, V
--- @param table table<K, V>
--- @param key K
--- @param default_value V
--- @return V
function flib_table.get_or_insert(table, key, default_value)
  local value = table[key]
  if not value then
    table[key] = default_value
    return default_value
  end
  return value
end

--- Retrieves the value at the key, or inserts the default value provided by the callback.
--- @generic K, V
--- @param table table<K, V>
--- @param key K
--- @param callback fun(): V
--- @return V
function flib_table.get_or_insert_with(table, key, callback)
  local value = table[key]
  if not value then
    value = callback()
    table[key] = value
  end
  return value
end

--- Returns a new table with the keys and values of the source table inverted. Non-unique values are overwritten based
--- on the ordering from `pairs()`.
---
--- ### Examples
---
--- ```lua
--- local tbl = {"foo", "bar", "baz", set = "baz"}
--- local inverted = table.inverted(tbl) -- {foo = 1, bar = 2, baz = "set"}
--- ```
--- @generic K, V
--- @param tbl table<K, V>
--- @return table<V, K>
function flib_table.inverted(tbl)
  local inverted = {}
  for k, v in pairs(tbl) do
    inverted[v] = k
  end
  return inverted
end

--- Transforms the values of the table in-place according to the predicate.
--- @generic K, V, N
--- @param tbl table<K, V>
--- @param predicate fun(value: V, key: V): N?
--- @return table<K, N> # The input table.
function flib_table.map(tbl, predicate)
  for k, v in pairs(tbl) do
    tbl[k] = predicate(v, k)
  end
  return tbl
end

--- Returns a new table with the values transformed according to the predicate.
---
--- ### Examples
---
--- ```lua
--- local tbl = {1, 2, 3, 4, 5}
--- local tbl_times_ten = table.mapped(tbl, function(v) return v * 10 end) -- {10, 20, 30, 40, 50}
--- ```
--- @generic K, V, N
--- @param tbl table<K, V>
--- @param predicate fun(value: V, key: V): N?
--- @return table<K, N>
function flib_table.mapped(tbl, predicate)
  local output = {}
  for k, v in pairs(tbl) do
    output[k] = predicate(v, k)
  end
  return output
end

--- "Reduce" a table's values into a single output value, using the results of a reducer function.
---
--- Calls `reducer(accumulator, value, key)` on each element in the table, returning a single accumulated output value.
---
--- ### Examples
---
--- ```lua
--- local tbl = {10, 20, 30, 40, 50}
--- local sum = table.reduce(tbl, function(acc, v) return acc + v end)
--- local sum_minus_ten = table.reduce(tbl, function(acc, v) return acc + v end, -10)
--- ```
--- @generic K, V, R
--- @param tbl table<K, V>
--- @param reducer fun(acc: R, value: V, key: K): R
--- @param initial_value R? The initial value for the accumulator. If not provided or is falsy, the first value in the table will be used as the initial `accumulator` value and skipped as `key`. Calling `reduce()` on an empty table without an `initial_value` will cause a crash.
--- @return R
function flib_table.reduce(tbl, reducer, initial_value)
  local accumulator = initial_value
  for key, value in pairs(tbl) do
    if accumulator then
      accumulator = reducer(accumulator, value, key)
    else
      accumulator = value
    end
  end
  return accumulator
end

--- Removes all elements from the table for which the predicate returns true.
--- @generic K, V
--- @param tbl table<K, V>
--- @param predicate fun(value: V, key: K): boolean
function flib_table.remove_if(tbl, predicate)
  for k, v in pairs(tbl) do
    if predicate(v, k) then
      tbl[k] = nil
    end
  end
end

--- Shallowly copies the contents of a table into a new table.
--- The parent table will have a new table reference, but any subtables within it will still have the same table reference.
--- Does not copy metatables.
--- @generic T
--- @param tbl T
--- @param use_rawset boolean? Use rawset to set the values (ignores metamethods).
--- @return T The copied table.
function flib_table.shallow_copy(tbl, use_rawset)
  local output = {}
  for k, v in pairs(tbl) do
    if use_rawset then
      rawset(output, k, v)
    else
      output[k] = v
    end
  end
  return output
end

--- Shallowly merge two or more tables.
--- Unlike `table.deep_merge`, this will only combine the top level of the tables.
--- @param tables table[]
--- @return table
function flib_table.shallow_merge(tables)
  local output = {}
  for _, tbl in pairs(tables) do
    for key, value in pairs(tbl) do
      output[key] = value
    end
  end
  return output
end

return flib_table
