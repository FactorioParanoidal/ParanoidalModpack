---cSpell:ignore upvalue, upval, upvals, userdata, funcs, nups, funccapture, simhelper, metatable, metatables

---@class TableField
---@field key Value
---@field value Value

---@class Upvalue
---@field value Value
---@field upval_index integer|nil
---the expression to get this upvalue
---@field upval_id string

---@class Value
---@field type '"nil"'|'"number"'|'"string"'|'"boolean"'|'"table"'|'"function"'|'"custom"'
---for everything except functions, tables and _ENV
---@field value any
---for functions
---@field func function
---for functions
---@field upvals Upvalue[]
---for tables
---@field metatable Value|nil
---for tables; nil when `is_env`
---@field fields TableField[]|nil
---for tables
---@field is_env boolean
---for tables and functions
---@field ref_index integer|nil
---the expression to get this table or function
---@field ref_id string
---index to resume at for an unfinished table due to not yet generated reference values as keys
---@field resume_at integer|nil
---for custom
---@field custom_expr string

local step_ignore = __DebugAdapter and __DebugAdapter.stepIgnore
if step_ignore then
  local f = function()
  end
  if f ~= step_ignore(f) then
    step_ignore = nil
  end
end
if not step_ignore then
  step_ignore = function(func)
    return func
  end
end

-- NOTE: tables and functions as keys are currently not supported,
-- though with some work at least _some_ of them could be supported.
-- specifically those where the keys also exist as values somewhere in _ENV
-- which is honestly not even that likely if someone was using
-- tables or functions as keys to begin with
local supported_key_types = {
  ["string"] = true,
  ["number"] = true,
  ["boolean"] = true
}

local generate_expr =
  step_ignore(
  function(keys)
    local result = {"_ENV"}
    for i, value in ipairs(keys) do
      local value_type = type(value)
      if not supported_key_types[value_type] then
        error("Expressions indexing into '_ENV' can only use strings, numbers and booleans as keys.")
      end
      result[i + 1] = "[" .. (value_type == "string" and string.format("%q", value) or tostring(value)) .. "]"
    end
    return table.concat(result)
  end
)

if __DebugAdapter and __DebugAdapter.defineGlobal then
  __DebugAdapter.defineGlobal("__simhelper_funccapture")
end
__simhelper_funccapture = {
  tables_to_ignore = setmetatable({}, {__mode = "k"}), -- weak keys
  next_func_id = 0,
  c_func_lut_cache = nil,
  number_cache = {
    -- preload inf and -inf because they print %a as "inf" and "-inf"
    [1 / 0] = "1/0",
    [-1 / 0] = "-1/0"
  }
}

local ensure_is_table =
  step_ignore(
  function(tab)
    assert(type(tab) == "table", "Can only ignore values of type 'table'.")
  end
)

local ignore_table_in_env =
  step_ignore(
  function(tab)
    ensure_is_table(tab)
    __simhelper_funccapture.tables_to_ignore[tab] = true
  end
)

local un_ignore_table_in_env =
  step_ignore(
  function(tab)
    ensure_is_table(tab)
    __simhelper_funccapture.tables_to_ignore[tab] = nil
  end
)

ignore_table_in_env(__simhelper_funccapture)
-- ignore `data` by default, because it's a giant nested table that doesn't contain any c functions
if data then
  ignore_table_in_env(data)
end

local get_c_func_lut =
  step_ignore(
  function()
    if __simhelper_funccapture.c_func_lut_cache then
      return __simhelper_funccapture.c_func_lut_cache
    end
    local ignored = __simhelper_funccapture.tables_to_ignore
    local c_func_lut = {}
    local visited = {}
    local key_stack = {}
    local walk
    walk =
      step_ignore(
      function(value, depth)
        local value_type = type(value)
        if value_type == "function" then
          local info = debug.getinfo(value, "S")
          if info.what == "C" then
            c_func_lut[value] = generate_expr(key_stack)
          end
          return
        end
        if value_type ~= "table" then
          return
        end
        if visited[value] or ignored[value] then
          return
        end
        visited[value] = true
        for k, v in pairs(value) do
          if supported_key_types[type(k)] then
            key_stack[depth] = k
            walk(v, depth + 1)
            key_stack[depth] = nil
          end
        end
      end
    )
    walk(_ENV, 1)
    __simhelper_funccapture.c_func_lut_cache = c_func_lut
    return c_func_lut
  end
)

local capture =
  step_ignore(
  function(main_func, custom_restorers)
    local custom_restore_lut = {}
    if custom_restorers then
      for _, custom_restorer in pairs(custom_restorers) do
        local name = custom_restorer.upvalue_name
        if custom_restore_lut[name] then
          error("Duplicate custom restorer registered for upvalue_name '" .. name .. "'")
        end
        custom_restore_lut[name] = {
          type = "custom",
          custom_expr = generate_expr(custom_restorer.restore_as_global)
        }
      end
    end

    ---@type table<userdata, Upvalue>
    local upvals = {}
    local upval_count = 0
    ---@type table<function|table, Value>
    local ref_values = {}
    local tables_with_metatables = {}
    local tables_with_metatables_count = 0

    local add_upval

    local add_basic =
      step_ignore(
      function(type, value)
        return {
          type = type,
          value = value
        }
      end
    )

    local add_value
    do
      local cases = {
        ["nil"] = step_ignore(
          function(value)
            return add_basic("nil", value)
          end
        ),
        ["number"] = step_ignore(
          function(value)
            return add_basic("number", value)
          end
        ),
        ["string"] = step_ignore(
          function(value)
            return add_basic("string", value)
          end
        ),
        ["boolean"] = step_ignore(
          function(value)
            return add_basic("boolean", value)
          end
        ),
        ["table"] = step_ignore(
          function(value)
            if value == _ENV then
              local result = {
                type = "table",
                is_env = true
              }
              ref_values[value] = result
              return result
            end
            local result = {
              type = "table",
              fields = {}
            }
            ref_values[value] = result
            local metatable = debug.getmetatable(value)
            if metatable then
              result.metatable = add_value(metatable)
              tables_with_metatables_count = tables_with_metatables_count + 1
              tables_with_metatables[tables_with_metatables_count] = result
            end
            local field_count = 0
            for k, v in next, value do -- no pairs to bypass metatable
              field_count = field_count + 1
              result.fields[field_count] = {
                key = add_value(k),
                value = add_value(v)
              }
            end
            return result
          end
        ),
        ["function"] = step_ignore(
          function(value)
            local data = debug.getinfo(value, "S")
            if data.what == "C" then
              local lut = get_c_func_lut()
              local expr = lut[value]
              if not expr then
                error(
                  "Unable to capture unknown C function. Did you remove it from \z
              _ENV or use and store the result of gmatch or ipairs or similar?"
                )
              end
              return {
                type = "custom",
                custom_expr = expr
              }
            end
            -- non c function
            local result = {
              type = "function",
              func = value,
              upvals = {}
            }
            ref_values[value] = result
            local info = debug.getinfo(value, "u")
            for i = 1, info.nups do
              result.upvals[i] = add_upval(value, i)
            end
            return result
          end
        ),
        ["thread"] = step_ignore(
          function()
            error("How did you even get a 'thread' object?")
          end
        ),
        ["userdata"] = step_ignore(
          function()
            error("Cannot have a 'userdata' upvalue for a simulation function.")
          end
        )
      }
      add_value =
        step_ignore(
        function(value)
          if ref_values[value] then
            return ref_values[value]
          end
          return cases[type(value)](value)
        end
      )
    end

    add_upval =
      step_ignore(
      function(func, upval_index)
        local id = debug.upvalueid(func, upval_index)
        if upvals[id] then
          return upvals[id]
        end
        local name, raw_value = debug.getupvalue(func, upval_index)
        local value = custom_restore_lut[name] or add_value(raw_value)
        upval_count = upval_count + 1
        local upval = {
          value = value,
          upval_index = upval_count,
          upval_id = "upvals[" .. upval_count .. "]"
        }
        upvals[id] = upval
        return upval
      end
    )

    local main_value = add_value(main_func)

    -- util functions for generating

    local is_reference_type =
      step_ignore(
      function(value)
        return value.type == "table" or value.type == "function"
      end
    )

    local unfinished_tables = {}
    local unfinished_tables_count = 0

    local back_reference_tables = {}
    local back_reference_fields = {}
    local back_references_count = 0

    local result = {}
    local rc = 0
    local generate_value
    do
      local number_cache = __simhelper_funccapture.number_cache
      local cases = {
        ["nil"] = step_ignore(
          function(value, use_reference_ids)
            rc = rc + 1
            result[rc] = "nil"
          end
        ),
        ["number"] = step_ignore(
          function(value, use_reference_ids)
            local number_str = number_cache[value.value]
            if not number_str then
              if value.value ~= value.value then -- nan
                number_str = "0/0"
              else
                -- %a prints a double as hexadecimal, or so
                number_str = string.format("%a", value.value)
                number_cache[value.value] = number_str
              end
            end
            rc = rc + 1
            result[rc] = number_str
          end
        ),
        ["string"] = step_ignore(
          function(value, use_reference_ids)
            rc = rc + 1
            result[rc] = string.format("%q", value.value)
          end
        ),
        ["boolean"] = step_ignore(
          function(value, use_reference_ids)
            rc = rc + 1
            result[rc] = tostring(value.value)
          end
        ),
        ["table"] = step_ignore(
          function(value, use_reference_ids)
            if use_reference_ids then
              rc = rc + 1
              result[rc] = value.ref_id
              return
            end
            if value.is_env then
              rc = rc + 1
              result[rc] = "_ENV"
            else
              -- this part is used for 2 things:
              -- 1) create the table for a ref value
              -- 2) finish the creation of an already created but unfinished ref value (table ofc)
              -- if value.ref_id is not present, we are doing the former
              local create_new_table = not value.ref_id
              if create_new_table then
                rc = rc + 1
                result[rc] = "{"
              end
              for i, field in next, value.fields, value.resume_at and value.resume_at ~= 1 and (value.resume_at - 1) or
                nil do
                if is_reference_type(field.key) and not field.key.ref_id then
                  value.resume_at = i
                  unfinished_tables_count = unfinished_tables_count + 1
                  unfinished_tables[unfinished_tables_count] = value
                  break
                end
                if not create_new_table then
                  rc = rc + 1
                  result[rc] = "\n" .. value.ref_id
                end
                rc = rc + 1
                result[rc] = "["
                generate_value(field.key, true)
                rc = rc + 1
                result[rc] = "]="
                if is_reference_type(field.value) and not field.value.ref_id then
                  assert(
                    create_new_table, -- debug assert
                    "When finishing the generation of a table, all other references should be generated already"
                  )
                  rc = rc + 1
                  result[rc] = "0," -- back reference
                  back_references_count = back_references_count + 1
                  back_reference_tables[back_references_count] = value
                  back_reference_fields[back_references_count] = field
                else
                  generate_value(field.value, true)
                  if create_new_table then
                    rc = rc + 1
                    result[rc] = ","
                  end
                end
              end
              if create_new_table then
                rc = rc + 1
                result[rc] = "}"
              end
            end
          end
        ),
        ["function"] = step_ignore(
          function(value, use_reference_ids)
            if use_reference_ids then
              rc = rc + 1
              result[rc] = value.ref_id
              return
            end
            rc = rc + 1
            result[rc] = string.format("assert(load(%q,nil,'b'))", string.dump(value.func))
          end
        ),
        ["custom"] = step_ignore(
          function(value, use_reference_ids)
            rc = rc + 1
            result[rc] = value.custom_expr
          end
        )
      }
      generate_value =
        step_ignore(
        function(value, use_reference_ids)
          cases[value.type](value, use_reference_ids)
        end
      )
    end

    -- prepare result cache
    local result_id = "__funccapture_result" .. __simhelper_funccapture.next_func_id
    __simhelper_funccapture.next_func_id = __simhelper_funccapture.next_func_id + 1
    rc = rc + 1
    result[rc] = "do\n"
    rc = rc + 1
    result[rc] = "  local result = rawget(_ENV,'" .. result_id .. "')\n"
    rc = rc + 1
    result[rc] = "  if result then return result(...) end\n"
    rc = rc + 1
    result[rc] = "end\n"

    -- generate reference values

    rc = rc + 1
    result[rc] = "local ref_values={}"
    do
      local i = 0
      for _, value in pairs(ref_values) do
        i = i + 1
        value.ref_index = i
        local ref_id = "ref_values[" .. i .. "]"
        rc = rc + 1
        result[rc] = "\n" .. ref_id .. "="
        generate_value(value)
        value.ref_id = ref_id
      end
    end

    -- finish unfinished tables

    rc = rc + 1
    result[rc] = "\n"
    for _, value in pairs(unfinished_tables) do
      generate_value(value)
    end

    -- finish back references

    rc = rc + 1
    result[rc] = "\n\n"
    for i = 1, back_references_count do
      local tab = back_reference_tables[i]
      local field = back_reference_fields[i]
      rc = rc + 1
      result[rc] = tab.ref_id .. "["
      generate_value(field.key, true)
      rc = rc + 1
      result[rc] = "]="
      generate_value(field.value, true)
      rc = rc + 1
      result[rc] = "\n"
    end

    -- restore metatables

    rc = rc + 1
    result[rc] = "\n"
    for _, value in pairs(tables_with_metatables) do
      rc = rc + 1
      result[rc] = "setmetatable(" .. value.ref_id .. "," .. value.metatable.ref_id .. ")\n"
    end

    -- generate dummy functions for upvalue joining

    rc = rc + 1
    result[rc] = "\nlocal upvals={}"
    for _, upval in pairs(upvals) do
      rc = rc + 1
      result[rc] = "\ndo local value="
      generate_value(upval.value, true)
      rc = rc + 1
      result[rc] = " " .. upval.upval_id .. "=function()return value end end"
    end
    rc = rc + 1
    result[rc] = "\n\nlocal upvaluejoin=debug.upvaluejoin\n\n"

    -- restore upvals

    for _, value in pairs(ref_values) do
      if value.type == "function" then
        for upval_index, upval in pairs(value.upvals) do
          rc = rc + 1
          result[rc] = "upvaluejoin(" .. value.ref_id .. "," .. upval_index .. "," .. upval.upval_id .. ",1)\n"
        end
      end
    end

    -- store in result cache and return

    rc = rc + 1
    result[rc] = "\nrawset(_ENV,'" .. result_id .. "'," .. main_value.ref_id .. ")"
    rc = rc + 1
    result[rc] = "\nreturn " .. main_value.ref_id .. "(...)"

    local result_string = table.concat(result)
    return result_string
  end
)

return {
  capture = capture,
  ignore_table_in_env = ignore_table_in_env,
  un_ignore_table_in_env = un_ignore_table_in_env
}
