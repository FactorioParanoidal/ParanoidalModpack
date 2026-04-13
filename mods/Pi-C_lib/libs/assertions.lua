PClib_log("Entered file " .. debug.getinfo(1).source)

local assert = {}
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                                LOCAL DEFINITIONS                               --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

return function(args)

  local common = _ENV[args.mod_shortname]
  --~ local common = {}

  -- Read definitions from the debugging library
  do
PClib_log("Reading debugging library!")
    local debugging = require("__Pi-C_lib__.libs.debugging")(args)
    local is_debug = debugging.is_debug
PClib_log(string.format("is_debug: %s", is_debug))

    local dummy_function = function() return "nil" end

    for key, value in pairs(debugging) do
      -- Debugging is on, copy the original definitions!
      if is_debug then
        assert[key] = value
        PClib_log(string.format("Added \"%s\": %s",
                              key,
                              type(value) == "function" and
                                "function" or serpent.block(value, {nocode = true})))

      -- Debugging is off, copy everything that is not a function!
      elseif type(value) ~= "function" then
        assert[key] = value
        PClib_log(string.format("Added \"%s\": %s",
                          key, serpent.block(value, {nocode = true})))

      -- Debugging is off, replace function with an empty dummy function, so we won't
      -- waste UPS on spamming the log file.
      else
        assert[key] = dummy_function
        PClib_log(string.format("Replaced function \"%s\" with empty function!", key))
      end
    end
  end

  --~ assert.enquote = function(text)
    --~ return string.format("\"%s\"", text == nil and "" or text)
  --~ end



  -- We can't use next() with custom tables, so we must make sure that it really
  -- contains no elements when checking whether it's empty!
  assert.is_custom_table_empty = function(tab)
    assert.entered_function({tab})
    local ret = true

    -- We want luacheck to ignore "loop is executed at most once"
    do
        -- luacheck: ignore

      -- If there is at least one element, the table is not empty!
      for e, element in pairs(tab) do
        ret = false
        break
      end
    end

    return ret
  end



  ----------------------------------------------------------------------------------
  -- Map default Factorio player colors to color names
  assert.colors = {
    default     = {r = 1.000, g = 0.630, b = 0.259},
    red         = {r = 1.000, g = 0.166, b = 0.141},
    green       = {r = 0.173, g = 0.824, b = 0.250},
    blue        = {r = 0.343, g = 0.683, b = 1.000},
    orange      = {r = 1.000, g = 0.630, b = 0.259},
    yellow      = {r = 1.000, g = 0.828, b = 0.231},
    pink        = {r = 1.000, g = 0.520, b = 0.633},
    purple      = {r = 0.821, g = 0.440, b = 0.998},
    white       = {r = 0.900, g = 0.900, b = 0.900},
    black       = {r = 0.500, g = 0.500, b = 0.500},
    gray        = {r = 0.700, g = 0.700, b = 0.700},
    brown       = {r = 0.757, g = 0.522, b = 0.371},
    cyan        = {r = 0.335, g = 0.918, b = 0.866},
    acid        = {r = 0.708, g = 0.996, b = 0.134},
    -- This is the default color for vehicles without an owner/locker in AD/GCKI!
    no_color    = {r = 0, g = 0, b = 0, a = 0.5}
  }

  if script then
    ----------------------------------------------------------------------------------
    -- Get the player from index, name or object
    assert.ascertain_player = function(player)
      assert.entered_function({player})

      local ret
      local p = type(player)
      if p == "userdata" then
        ret = (player.object_name == "LuaPlayer") and player
      elseif p == "number" or p == "string" then
        ret = game.get_player(player)
      end

      return ret
    end

    ----------------------------------------------------------------------------------
    -- Get the force from index, name or object
    assert.ascertain_force = function(force)
      assert.entered_function({force})

      local ret
      local f = type(force)
      if f == "userdata" then
        ret = (force.object_name == "LuaForce") and force or nil
      elseif f == "number" or f == "string" then
        ret = game.forces[force]
      end

      return ret
    end

    ----------------------------------------------------------------------------------
    -- Get the surface from index or name, or object
    assert.ascertain_surface = function(surface)
      assert.entered_function({surface})

      local ret
      local s = type(surface)
      if s == "userdata" then
        ret = (surface.object_name == "LuaSurface") and surface
      elseif s == "number" or s == "string" then
        ret = game.get_surface(surface)
      end

      return ret
    end

    ----------------------------------------------------------------------------------
    -- Get the technology from name or object
    assert.ascertain_technology = function(tech)
      assert.entered_function({tech})

      local ret
      local t = type(tech)
      if t == "userdata" then
        ret = (tech.object_name == "LuaTechnology") and tech
      elseif t == "string" then
        ret = prototypes.technology[tech]
      end

      return ret
    end

    ----------------------------------------------------------------------------------
    -- Get the item stack from name, table,  or object
    assert.ascertain_itemstack = function(stack)
      assert.entered_function({stack})

      assert.assert(stack, {"LuaItemStack", "table", "string"}, "item stack or name")

      local t = type(stack)

      local ret

      -- String means a full stack of the item
      if (t == "string") then
        ret = prototypes.item[stack] and {
          name = stack,
          count = prototypes.item[stack].stack_size,
          quality = "normal"
        }

      -- Table: simple stacks must have a name that resolves to an item,
      --        count defaults to 1
      elseif (t == "table") and stack.name and prototypes.item[stack.name] then
        ret = table.deepcopy(stack)
        ret.count = ret.count or 1
        ret.quality = ret.quality or "normal"

      elseif (t == "userdata") then
        ret = stack
      end

      return ret
    end
    assert.ascertain_item_stack = assert.ascertain_itemstack

    --------------------------------------------------------------------------------
    -- Get the rendering from ID or object
    assert.ascertain_rendering = function(id_or_object)
      assert.entered_function({id_or_object})

      local ret
      local t = type(id_or_object)
      if t == "userdata" then
        --~ ret = (id_or_object.object_name == "LuaRendering") and id_or_object
        ret = (id_or_object.object_name == "LuaRenderObject") and id_or_object
      elseif t == "number" then
        ret = rendering.get_object_by_id(id_or_object)
      end

      return ret
    end

    --------------------------------------------------------------------------------
    -- Get quality from name or object
    assert.ascertain_quality = function(id_or_object)
      assert.entered_function({id_or_object})

      local ret
      local t = type(id_or_object)
      if t == "userdata" then
        ret = (id_or_object.object_name == "LuaQualityPrototype") and id_or_object
      elseif t == "string" then
        ret = prototypes.quality[id_or_object]
      end

      return ret
    end

    --------------------------------------------------------------------------------
    -- Returns true if all given qualitiy specifiers refer to the same 'quality'
    -- prototype.
    assert.is_same_quality = function(a, b, ...)
      assert.entered_function({a, b, ...})

      assert.assert(a, {"LuaQualityPrototype", "string"},
                        "quality name or prototype")
      assert.assert(b, {"LuaQualityPrototype", "string"},
                        "quality name or prototype")

      local q_a = assert.ascertain_quality(a)
      if not q_a then
        assert.arg_err(a, "quality specification")
      end

      local function compare(x, y)
        -- First two arguments are identical
        if x == y then
assert.writeDebug("Identical arguments!")
          return true

        -- Args may refer to the same quality if one is a string and the other is a
        -- prototype!
        elseif type(x) ~= type(y) then
assert.writeDebug("Args differ, comparing quality prototypes!")
          return (q_a == assert.ascertain_quality(y))
        end
      end

      -- Compare the mandatory arguments (a and b)
      assert.writeDebugNewBlock("Do mandatory arguments refer to the same quality?")
      local ret = compare(a, b)

      -- We only check additional arguments if the first two args refer to the same
      -- quality prototype!
      if ret then
        assert.writeDebug("Yes: trying to compare additional args with first arg!")
        for _, arg in pairs({...}) do
          ret = compare(a, arg)
          if not ret then
            assert.writeDebug("Failed: %s and %s refer to different qualities!",
                              {a, arg})
            break
          end
        end
      else
        assert.writeDebug("Failed: first two args differ!")
      end

      assert.entered_function("leave")
      return ret
    end

    --------------------------------------------------------------------------------
    -- Returns true if both SignalIDs refer to the same signal. )
    assert.is_same_signal_id = function(a, b)
      assert.entered_function({a, b})

      assert.assert(a, "table", "table with signal data")
      assert.assert(b, "table", "table with signal data")

      local same_name = (a.name == b.name)
      -- When reading signal IDs, type will be nil instead of "item"!
      local same_type = (a.type or "item") == (b.type or "item")
      -- Quality may be given as string (quality name), or as LuaQualityPrototyp; it
      -- defaults to "normal".
      local same_qual = assert.is_same_quality(a.quality or "normal",
                                                b.quality or "normal")
assert.show("same_name", same_name)
assert.show("same_type", same_type)
assert.show("same_qual", same_qual)

      assert.entered_function("leave")
      return (same_name and same_type and same_qual) or false
    end

  end


  ----------------------------------------------------------------------------------
  -- Make sure that -0 is considered a negative number!
  assert.is_negative_number = function(x)
    assert.entered_function({x})

    local ret = false
assert.show("type(x)", type(x))
assert.show("tonumber(x)", tonumber(x))

    local n = tonumber(x)
assert.show("n", n)

    -- Input must resolve to a valid number!
    if n then
      if n < 0 then
        ret = true
      elseif n == 0 then
        local s = tostring(x)
assert.show("s", s)
        ret = s:sub(1, 1) == "-"
assert.show("ret",ret)
      end
    end

    assert.entered_function("leave")
    return ret
  end

  ----------------------------------------------------------------------------------
  -- Make sure that -0 is not considered a positive number!
  assert.is_positive_number = function(x)
    assert.entered_function({x})

    local ret = false
assert.show("type(x)", type(x))
assert.show("tonumber(x)", tonumber(x))

    local n = tonumber(x)
assert.show("n", n)

    -- Input must resolve to a valid number!
    if n then
      if n > 0 then
        ret = true
      elseif n == 0 then
        local s = tostring(x)
assert.show("s", s)
        ret = s:sub(1, 1) ~= "-"
assert.show("ret",ret)
      end
    end

    assert.entered_function("leave")
    return ret
  end


  ----------------------------------------------------------------------------------
  -- Get color from name, hex, or table
  assert.ascertain_color = function(color)
    assert.entered_function({color})

    assert.assert(color, {"table", "string", "nil"}, "color, string, or nil")

    local ret
    local c = type(color)
    -- Named colors or hex colors
    if c == "string" then
      ret = assert.colors[color] or
            (color:match("^#*[0-9a-fA-F]+$") and util.color(color))
assert.show("ret", ret)
      if ret then
        ret.a = 1
      end

    -- Lua color
    elseif c == "table" then
      -- Make sure we've got a table that only contains valid color data (empty table,
      -- named keys, or index 1…4)!
      if next(color) then
        -- Make a copy of the color table, then remove all valid keys from it
        local copy = table.deepcopy(color)
        for _, i in pairs({1, 2, 3, 4, "r", "g", "b", "a"}) do
          copy[i] = nil
        end

        -- If the copied table is not empty, the input wasn't a valid color!
        if next(copy) then
          assert.entered_function({}, "leave", "not a valid color")
          return
        end
      end

      ret = {
        r = color.r or color[1] or 0,
        g = color.g or color[2] or 0,
        b = color.b or color[3] or 0,
        a = color.a or color[4] or 1,
      }
    end

    return ret
  end

  -- Compare two colors. Returns true if the colors are the same
  assert.compare_colors = function(c1, c2)
    assert.entered_function({c1, c2})

    c1 = assert.ascertain_color(c1)
    c2 = assert.ascertain_color(c2)

    local ret = c1 and c2 and util.table.compare(c1, c2)
    assert.show("Colors are the same", ret and "yes" or "no")

    assert.entered_function("leave")
    return ret
  end


  ----------------------------------------------------------------------------------
  -- Throw an error if a wrong argument has been passed to a function
  assert.arg_err = function(arg, arg_type)
    error(string.format(
      "Wrong argument! %s is not %s!",
      assert.argprint(arg), (arg_type and "a valid "..arg_type or "valid")
    ))
  end

  ----------------------------------------------------------------------------------
  -- Rudimentary check of the arguments passed to a function
  assert.check_args = function(arg, expected_arg_type)
--~ assert.entered_function({arg, expected_arg_type})
    local ret = true
    local arg_type = type(arg)
    expected_arg_type = expected_arg_type and expected_arg_type:lower() or ""

    -- Special arguments: Entities, recipes etc. are stored in tables (data stage)
    --                    or as userdata (control)
    if data and arg_type == "table" then
      local object_type = arg.type and arg.type:lower()
      if expected_arg_type ~= object_type and expected_arg_type ~= "table" then
        ret = false
      end
    elseif arg_type == "userdata" then
      -- If expected_arg_type is not "userdata" it may be the type of a LuaObject!
      if expected_arg_type ~= arg_type then
        local object_type = arg.object_name and arg.object_name:lower()
        if expected_arg_type ~= object_type then
          ret = false
        end
      end

    -- Normal arguments: expected type must match type(arg)!
    elseif arg_type ~= expected_arg_type then
      ret = false
    end

    return ret
  end

  ----------------------------------------------------------------------------------
  -- Error when argument is not of expected type.
  -- arg:      The value we want to check
  -- arg_type: String or array of strings specifying the expected type(s)
  -- desc:     String (optional) with a description for arg_type. Will be ignored if
  --           arg_type is a table!
  --
  -- If only one type is acceptable for arg, arg_type and, optionally, desc must be
  -- strings:
  --      debugging.assert(arg, arg_type, desc)
  --
  -- If arg may be any of several types (e.g. number and nil), call this function
  -- with an array of strings specifying the names of acceptable arg_types, and
  -- optionally a description:
  --      debugging.assert(arg, {type_1, type_2, …}, desc)
  ----------------------------------------------------------------------------------
  assert.assert = function(arg, arg_type, desc)
--~ assert.entered_function({arg, arg_type, desc})
    local arg_types

    if arg_type == nil then
      arg_types = {"nil"}
    elseif type(arg_type) == "string" then
      arg_types = {arg_type}
    elseif type(arg_type) == "table" then
      for k, v in pairs(arg_type) do
        if type(v) ~= "string" then
          assert.arg_err(v, "argument type (string)")
        end
      end
      arg_types = arg_type
    else
      assert.arg_err(arg_type, "type (nil, string, or array of strings)")
    end

    local success

    for a, a_type in pairs(arg_types) do
      if assert.check_args(arg, a_type) then
        success = true
        break
      end
    end

    if not success then
      assert.arg_err(arg, desc)
    end
    return true
  end


  ----------------------------------------------------------------------------------
  -- Normalize position
  assert.normalize_position = function(position)
    assert.entered_function({position})
    local x, y

    if type(position) == "table" and table_size(position) == 2 then
      x = position.x or position[1]
      y = position.y or position[2]
    end

    assert.assert(x, "number", "x-coordinate")
    assert.assert(y, "number", "y-coordinate")

    return {x = x, y = y}
  end


  ----------------------------------------------------------------------------------
  -- Compare positions
  assert.is_same_position = function(pos_a, pos_b)
    assert.entered_function({pos_a, pos_b})

    pos_a = assert.normalize_position(pos_a)
    pos_b = assert.normalize_position(pos_b)

    assert.entered_function("leave")
    return (pos_a.x == pos_b.x) and (pos_a.y == pos_b.y)
  end


  ----------------------------------------------------------------------------------
  -- Translate map position to chunk position
  assert.get_chunk_pos = function(pos)
    assert.entered_function({pos})

    pos = assert.normalize_position(pos)

    return {x = math.floor(pos.x/32), y = math.floor(pos.y/32)}
  end


  --~ ----------------------------------------------------------------------------------
  --~ -- Greatly improved version check for mods (thanks to eradicator!)
  --~ assert.Version = {}
  --~ do
    --~ local V = assert.Version

    --~ local function parse_version(vstr) -- string "Major.Minor.Patch"
      --~ local err = function()
        --~ error('Invalid Version String: <'..vstr..'>')
      --~ end

      --~ local r = {vstr:match'^(%d+)%.(%d+)%.(%d+)$'}

      --~ if #r ~= 3 then
        --~ err()
      --~ end

      --~ for i=1, 3 do
        --~ r[i] = tonumber(r[i])
      --~ end

      --~ return r
    --~ end

    --~ V.gtr = function(verA, verB)
      --~ local a, b, c = unpack(parse_version(verA))
      --~ local x, y, z = unpack(parse_version(verB))
      --~ return (a > x) or (a == x and b > y) or (a == x and b == y and c > z)
    --~ end

    --~ local map = {
      --~ ['=' ] = function(A, B) return not (V.gtr(A, B)   or V.gtr(B, A)) end,
      --~ ['>' ] = V.gtr,
      --~ ['!='] = function(A, B) return (V.gtr(A, B)       or V.gtr(B, A)) end,
      --~ ['<='] = function(A, B) return V.gtr(B, A)        or (not V.gtr(A, B)) end,
      --~ ['>='] = function(A, B) return V.gtr(A, B)        or (not V.gtr(B, A)) end,
      --~ ['~='] = function(A, B) return (V.gtr(A, B)       or V.gtr(B, A)) end,
      --~ ['<' ] = function(A, B) return V.gtr(B, A) end,
    --~ }

    --~ assert.check_version = function(mod_name, operator, need_version)
      --~ assert.entered_function({mod_name, operator, need_version})
      --~ local mod_version = script and script.active_mods[mod_name] or
                           --~ mods and mods[mod_name]
--~ assert.show("mod_version", mod_version)
--~ assert.show("need_version", need_version)
      --~ return map[operator](mod_version, need_version)
    --~ end
  --~ end

  -- Improved version check for mods, using LuaHelper::compare_versions()
  -- (requires Factorio >=2.0.55)
  assert.check_version = function(mod_name, operator, need_version)
    assert.entered_function({mod_name, operator, need_version})

    local have_version = (mods and mods[mod_name]) or
                          (script and script.active_mods[mod_name]) or
                          assert.arg_err(mod_name, "mod")

    -- -1: first < second, 0: first == second, +1: first > second
    local result = helpers.compare_versions(have_version, need_version)

    -- Equal
    if operator == '=' or operator == '==' then
      return (result == 0)
    -- Not equal
    elseif operator == '!=' or operator == '~=' then
      return (result ~= 0)
    -- Greater
    elseif operator == '>' then
      return (result == 1)
    -- Greater or equal
    elseif operator == '>=' then
      return (result > -1)
    -- Smaller
    elseif operator == '<' then
      return (result == -1)
    -- Smaller or equal
    elseif operator == '<=' then
      return (result < 1)
    --Invalid operator
    else
      assert.arg_err(operator, "operator")
    end
  end


  ----------------------------------------------------------------------------------
  -- Look for matching pattern at start of a string
  assert.prefixed = function(look_in, find_at_start)
    assert.assert(look_in, "string")
    assert.assert(find_at_start, "string")
    return look_in:sub(1, #find_at_start) == find_at_start
  end


  ----------------------------------------------------------------------------------
  -- Extract a number from a string, given a variable pattern
  assert.number_from_string = function(look_in, find_pattern)
    assert.assert(look_in, "string", "string containing number")
    assert.assert(find_pattern, "string", "search pattern")
    return tonumber(look_in:match(find_pattern))
  end

  ----------------------------------------------------------------------------------
  --             Compare two values that may be either boolean or nil             --
  ----------------------------------------------------------------------------------
  assert.states_differ = function(a, b)
    assert.assert(a, {"boolean", "nil"}, "Boolean value or nil")
    assert.assert(b, {"boolean", "nil"}, "Boolean value or nil")
    return ((not a) ~= (not b))
  end


  ----------------------------------------------------------------------------------
  --                      Check whether table contains value                      --
  ----------------------------------------------------------------------------------
  assert.table_contains = function(tab, value)
    --~ assert.entered_function({tab, value})
    local ret

    local t = type(value)
    for k, v in pairs(tab or common.EMPTY_TAB) do
      if t == type(v) then
        if v == value or (t == "table" and util.table.compare(v, value)) then
          ret = k
          break
        end
      end
    end

    --~ assert.entered_function("leave")
    return ret
  end


  ----------------------------------------------------------------------------------
  --     Convert array to look-up list ({[key] = value} --> {[value] = true})     --
  ----------------------------------------------------------------------------------
  assert.array_to_lookup = function(tab)
    local ret = {}
    for k, v in pairs(tab or common.EMPTY_TAB) do
      ret[v] = true
    end
    return ret
  end


  ----------------------------------------------------------------------------------
  --       Convert array to dictionary ({[key] = value} --> {[value] = key})      --
  ----------------------------------------------------------------------------------
  assert.array_to_table = function(tab)
    local ret = {}
    for k, v in pairs(tab or common.EMPTY_TAB) do
      ret[v] = k
    end
    return ret
  end

  ----------------------------------------------------------------------------------
  -- Localize entity names for output routines
  -- (Returns localized entity name; falls back to entity name, or to default string)
  assert.loc_name = function(entity)
    return entity and entity.valid and (entity.localised_name or entity.name) or "nil"
  end



  ----------------------------------------------------------------------------------
  PClib_log("Leaving file " .. debug.getinfo(1).source)
  return assert
end
