---@param array table
---@param element any
---@param remove boolean?
---@return boolean
function contains(array, element, remove)
  for i, value in pairs(array) do
    if value == element then
      if remove then table.remove(array, i) end
      return true
    end
  end
  return false
end

function contains_key(array, element, remove)
  for key, _ in pairs(array) do
    if key == element then
      if remove then table.remove(array, key) end
      return true
    end
  end
  return false
end

function content_equals(table1, table2)
  table2 = table.deepcopy(table2)
  for item_name, count1 in pairs(table1) do
    local count2 = table2[item_name] or 0
    if count1 ~= count2 then
      return false
    end
    table2[item_name] = nil
  end

  return next(table2) == nil
end

function table_equals(table1, table2)
  table2 = table.deepcopy(table2)
  for index, contents1 in pairs(table1) do
    local contents2 = table2[index] or {}
    if not content_equals(contents1, contents2) then
      return false
    end
    table2[index] = nil
  end
  return next(table2) == nil
end

--- From https://github.com/factoriolib/flib/blob/ae2c608f53cbafd29f683703734eea421e6e35fb/table.lua#L266. See docs there.
--- @generic K, V, C
--- @param tbl table<K, V> The table to iterate over.
--- @param from_k K The key to start iteration at, or `nil` to start at the beginning of `tbl`. If the key does not exist in `tbl`, it will be treated as `nil`, _unless_ a custom `_next` function is used.
--- @param n number The number of items to iterate.
--- @param callback fun(value: V, key: K):C,boolean,boolean Receives `value` and `key` as parameters.
--- @param _next? fun(tbl: table<K, V>, from_k: K):K,V A custom `next()` function. If not provided, the default `next()` will be used.
--- @return K? next_key Where the iteration ended. Can be any valid table key, or `nil`. Pass this as `from_k` in the next call to `for_n_of` for `tbl`.
--- @return table<K, C> results The results compiled from the first return of `callback`.
--- @return boolean reached_end Whether or not the end of the table was reached on this iteration.
function for_n_of(tbl, from_k, n, callback, _next)
  -- Bypass if a custom `next` function was provided
  if not _next then
    -- Verify start key exists, else start from scratch
    if from_k and not tbl[from_k] then
      from_k = nil
    end
    -- Use default `next`
    _next = next
  end

  local delete
  local prev
  local abort
  local result = {}

  -- Run `n` times
  for _ = 1, n, 1 do
    local v
    if not delete then
      prev = from_k
    end
    from_k, v = _next(tbl, from_k)
    if delete then
      tbl[delete] = nil
    end

    if from_k then
      result[from_k], delete, abort = callback(v, from_k)
      if delete then
        delete = from_k
      end
      if abort then
        break
      end
    else
      return from_k, result, true
    end
  end

  if delete then
    tbl[delete] = nil
    from_k = prev
  elseif abort then
    from_k = prev
  end
  return from_k, result, false
end
