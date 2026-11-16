--- Utilities for working with arrays. An array is defined as a table with sequentially numbered keys starting at 1.
--- Many functions in this module have similar counterparts in the `table` module. In these cases, the array functions
--- are specifically optimized for arrays and should be used in place of the generic table functions whenever possible.
--- ```lua
--- local flib_array = require("__flib__.array")
--- ```
--- @class flib.array
local flib_array = {}

--- Checks that the predicate is true for all elements of the array.
--- @generic T
--- @param array T[]
--- @param predicate fun(element: T, i: integer): boolean
--- @return boolean
function flib_array.all_of(array, predicate)
  for i = 1, #array do
    if not predicate(array[i], i) then
      return false
    end
  end
  return true
end

--- Checks that the predicate is true for at least one element of the array.
--- @generic T
--- @param array T[]
--- @param predicate fun(element: T, i: integer): boolean
--- @return boolean
function flib_array.any_of(array, predicate)
  return flib_array.find_if(array, predicate) ~= nil
end

--- Performs a binary search of the array using the given comparator function. The array must be sorted in a manner
--- compatible with the comparator and must not be modified during the search. The comparator should return `0` if the
--- element matches the target, a negative number if the element precedes the target, or a positive number if the
--- element succeeds the target.
---
--- ### Example
---
--- ```lua
--- local nums = {1, 3, 4, 8, 20, 69}
--- local looking_for = 20
--- local i, match = flib_array.binary_search(nums, function(elem) return looking_for - elem end)
--- assert(i == 5)
--- assert(match == looking_for)
--- ```
--- @generic T
--- @param array T[]
--- @param comparator fun(elem: T): integer
--- @return integer? The index of the matched element.
--- @return T? The matched element.
function flib_array.binary_search(array, comparator)
  local low, high = 1, #array
  while low <= high do
    local i = low + math.floor((high - low) / 2)
    local elem = array[i]
    assert(elem, "Во время двоичного поиска обнаружен элемент nil; массив изменён или недопустим.")
    local res = comparator(elem)
    if res < 0 then
      high = i - 1
    elseif res > 0 then
      low = i + 1
    else
      return i, array[i]
    end
  end
end

--- Checks whether the array contains the given element.
--- @generic T
--- @param array T[]
--- @param element T
--- @return boolean
function flib_array.contains(array, element)
  return flib_array.find(array, element) ~= nil
end

--- Shallow compares two arrays for inner equality. Does not compare metatables.
--- @generic T
--- @param arr1 T[]
--- @param arr2 T[]
--- @return boolean
function flib_array.eq(arr1, arr2)
  local len = #arr1
  if len ~= #arr2 then
    return false
  end
  for i = 1, #len do
    if arr1[i] ~= arr2[i] then
      return false
    end
  end
  return true
end

--- Finds the first index of the given element in the array if it is present.
--- @generic T
--- @param array T[]
--- @param element T
--- @return integer?
function flib_array.find(array, element)
  for i = 1, #array do
    if array[i] == element then
      return i
    end
  end
end

--- Finds the index of the first element in the array for which the predicate returns true.
--- @generic T
--- @param array T[]
--- @param predicate fun(element: T, i: integer): boolean
--- @return T? # The element of the match, if any.
--- @return integer? # The index of the match, if any.
function flib_array.find_if(array, predicate)
  for i = 1, #array do
    local element = array[i]
    if predicate(element, i) then
      return element, i
    end
  end
end

--- Flattens the given arrays into a single top-level array.
--- @generic T
--- @param arrays T[][]
--- @return T[] # The merged arrays.
function flib_array.flatten(arrays)
  local output = {}
  local i = 0
  for j = 1, #arrays do
    local array = arrays[j]
    for k = 1, #array do
      i = i + 1
      output[i] = array[k]
    end
  end
  return output
end

--- Transforms the elements of the array in-place according to the predicate.
--- The predicate MUST NOT return `nil`, as that will introduce a gap and break the array.
--- To remove elements, use `flib_array.remove_if`.
--- @generic T, U
--- @param array T[]
--- @param predicate fun(element: T, i: integer): U
function flib_array.map(array, predicate)
  for i = 1, #array do
    local new_value = predicate(array[i], i)
    if new_value == nil then
      error(
        "Предикат flib_array.map вернул nil. Чтобы удалить элементы из массива, используйте flib_table.remove_if."
      )
    end
    array[i] = new_value
  end
end

--- Returns a new array with the elements transformed according to the predicate.
--- The predicate MUST NOT return `nil`, as that will introduce a gap and break the array.
--- To remove elements, use `flib_array.remove_if`.
--- @generic T, U
--- @param array T[]
--- @param predicate fun(element: T, i: integer): U
--- @return U[]
function flib_array.mapped(array, predicate)
  local output = {}
  for i = 1, #array do
    local new_value = predicate(array[i], i)
    if new_value == nil then
      error("Предикат flib_array.mapped вернул nil.")
    end
    output[i] = new_value
  end
  return output
end

--- Removes all elements from the array for which the predicate returns true.
--- The array will be iterated in reverse order.
--- @generic T
--- @param array T[]
--- @param predicate fun(element: T, i: integer): boolean
function flib_array.remove_if(array, predicate)
  for i = #array, 1, -1 do
    if predicate(array[i], i) then
      table.remove(array, i)
    end
  end
end

--- Shallow copies an array.
--- @generic T
--- @param array T[]
--- @return T[] # The copied array.
function flib_array.shallow_copy(array)
  local new_arr = {}
  for i = 1, #array do
    new_arr[i] = array[i]
  end
  return new_arr
end

--- Returns a shallow copy of a portion of an array, selected from `start` to `end` inclusive.
---
--- The original array **will not** be modified.
---
--- ### Examples
---
--- ```lua
--- local arr = {10, 20, 30, 40, 50, 60, 70, 80, 90}
--- local sliced = table.slice(arr, 3, 7) -- {30, 40, 50, 60, 70}
--- log(serpent.line(arr)) -- {10, 20, 30, 40, 50, 60, 70, 80, 90} (unchanged)
--- ```
--- @generic T
--- @param array T[]
--- @param start number? default: `1`
--- @param stop number? Stop at this index. If zero or negative, will stop `n` items from the end of the array (default: `#arr`).
--- @return T[] # A new array with the copied values.
function flib_array.slice(array, start, stop)
  local output = {}
  local n = #array

  start = start or 1
  stop = stop or n
  stop = stop <= 0 and (n + stop) or stop

  if start < 1 or start > n then
    return {}
  end

  local k = 1
  for i = start, stop do
    output[k] = array[i]
    k = k + 1
  end
  return output
end

--- Excises and returns a portion of an array, selected from `start` to `end` inclusive.
--
--- The original array **will** be modified.
---
--- ### Examples
---
--- ```lua
--- local arr = {10, 20, 30, 40, 50, 60, 70, 80, 90}
--- local spliced = table.splice(arr, 3, 7) -- {30, 40, 50, 60, 70}
--- log(serpent.line(arr)) -- {10, 20, 80, 90} (values were removed)
--- ```
--- @generic T
--- @param array T[]
--- @param start number default: `1`
--- @param stop number? Stop at this index. If zero or negative, will stop `n` items from the end of the array (default: `#arr`).
--- @return T[] # A new array with the extracted values.
function flib_array.splice(array, start, stop)
  local output = {}
  local n = #array

  start = start or 1
  stop = stop or n
  stop = stop <= 0 and (n + stop) or stop

  if start < 1 or start > n then
    return {}
  end

  local k = 1
  for _ = start, stop do
    output[k] = table.remove(array, start)
    k = k + 1
  end
  return output
end

return flib_array
