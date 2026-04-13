PClib_log("Entered file "..debug.getinfo(1).source)

local debugging = {}

local debug_default = false


-- Header separators for the different output functions
local FILE_SEP = string.rep("*", 100)
local FUNC_SEP = string.rep("-", 100)
local COMM_SEP = string.rep(":", 100)
local EVEN_SEP = string.rep("=", 100)


return function(mod_args)

  -- We'll need this to prefix names of debugging command names and locale keys!
  local prefix = mod_args.mod_shortname

  local common = _ENV[prefix]

  ------------------------------------------------------------------------------------
  -- Enable writing to log file until startup options are set, so debugging output
  -- from the start of a game session can be logged. This depends on a locally
  -- installed dummy mod to allow debugging output during development without
  -- spamming real users.
  -- If you don't have this mod or don't want to activate it, you can also change
  -- the value of debug_default!
  local debug_log_setting = mod_args.debug_log_setting
  local debug_game_setting = mod_args.debug_game_setting
PClib_log(string.format("debug_log_setting: %s", debug_log_setting))
PClib_log(string.format("debug_game_setting: %s", debug_game_setting))
PClib_log(string.format("mods[_debug]: %s", mods and mods["_debug"]))
PClib_log(string.format("script.active_mods[_debug]: %s", script and script.active_mods["_debug"]))

  -- Always enable logging if the dummy mod is active
  if (mods and mods["_debug"]) or (script and script.active_mods["_debug"]) then
    debugging.debug_in_log = true

  -- There may be a setting (passed on with the mod data) that we must check
  elseif debug_log_setting then
    --~ -- There are no 'settings' yet when this is called during the settings stage!
    --~ debugging.debug_in_log = settings and settings.startup[debug_log_setting] and
                                          --~ settings.startup[debug_log_setting].value

    -- There are no 'settings' yet when this is called during the settings stage!
    -- Always enable debugging in this case.
    if not settings then
      debugging.debug_in_log = true

    -- Data or control stage: use value from setting!
    else
      debugging.debug_in_log = settings.startup[debug_log_setting] and
                                settings.startup[debug_log_setting].value
    end

  -- If neither dummy mod nor setting exist, fall back to the default value set at
  -- the top of this file!
  else
    debugging.debug_in_log = debug_default
  end
PClib_log(string.format("debugging.debug_in_log: %s", debugging.debug_in_log))

  -- Log to game console? This only makes sense in the control stage, where table
  -- 'script' is available
  if script and debug_game_setting then
    debugging.debug_in_game = settings.startup[debug_game_setting] and
                              settings.startup[debug_game_setting].value
  end
PClib_log(string.format("debugging.debug_in_game: %s", debugging.debug_in_game))

  debugging.is_debug = debugging.debug_in_log or debugging.debug_in_game
PClib_log(string.format("debugging.is_debug: %s", debugging.is_debug))


  -- Allow the mod requiring the lib to toggle logging on the fly
  debugging.set_debug_state = function(debug_state)
    if type(debug_state) ~= "boolean" then
      error(string.format("Not a boolean value: %s!", debug_state))
    end

    -- We only change debug_state if logging is allowed at all (depending on presence
    -- of mod "_debug" or setting)
    if (debugging.debug_in_log or debugging.debug_in_game) then
      debugging.is_debug = debug_state
    end
  end


  -- Allow the mod requiring the lib to read the current state of logging
  debugging.get_debug_state = function()
    return debugging.is_debug
  end


  ------------------------------------------------------------------------------------
  --                               DEBUGGING FUNCTIONS                              --
  ------------------------------------------------------------------------------------

  local function make_reverse_list(name, tab)
    tab = tab or defines

    local ret = {}
    for element, index in pairs(tab[name] or common.EMPTY_TAB) do
      ret[index] = element
    end

    return next(ret) and ret
  end

  ------------------------------------------------------------------------------------
  -- Make a reverse look-up list for event names
  if script then
    debugging.event_names = make_reverse_list("events")
    debugging.event_names["on_load"] = "on_load"
    debugging.event_names["on_init"] = "on_init"
    debugging.event_names["on_configuration_changed"] = "on_configuration_changed"
    debugging.event_names["on_nth_tick"] = "on_nth_tick"
  end

  ------------------------------------------------------------------------------------
  -- Make a reverse look-up list for controller names
  if script then
    debugging.controller_names = make_reverse_list("controllers")
  end

  ------------------------------------------------------------------------------------
  -- Make a reverse look-up list for mouse-button names
  if script then
    debugging.mouse_button_names = make_reverse_list("mouse_button_type")
  end

  ------------------------------------------------------------------------------------
  -- Make a reverse look-up list for entity status names
  if script then
    debugging.entity_status = make_reverse_list("entity_status")
  end

  ------------------------------------------------------------------------------------
  -- Make a reverse look-up list for acceleration/direction of riding_state
  if script then
    local rs = defines.riding
    debugging.riding_state = {}
    debugging.riding_state.acceleration = make_reverse_list("acceleration", rs)
    debugging.riding_state.direction = make_reverse_list("direction", rs)
  end

  ------------------------------------------------------------------------------------
  -- Make a reverse look-up list for gui_types
  if script then
    debugging.gui_types = make_reverse_list("gui_type")
  end

  ------------------------------------------------------------------------------------
  -- Make a reverse look-up list for logistic_mode
  if script then
    debugging.logistic_modes = make_reverse_list("logistic_mode")
  end

  ------------------------------------------------------------------------------------
  -- Make a reverse look-up list for logistic_section_type
  if script then
    debugging.logistic_section_types = make_reverse_list("logistic_section_type")
  end

  ------------------------------------------------------------------------------------
  -- A simple reverse look-up list for inventory wouldn't work as the same values
  -- are used for different keys in defines.inventory. But as of Factorio 2.0.48, we
  -- can get the key directly by reading LuaInventory::name!


  ------------------------------------------------------------------------------------
  -- Output debugging text
  debugging.writeDebug = function(msg, tab, print_line)
    if not debugging.is_debug then
      return
    end
    local args = {}
    print_line = print_line and print_line:lower()

    -- Use serpent.line instead of serpent.block if this is true!
    local line = print_line and (print_line == "line" or print_line == "l") and
                  true or false

    if type(tab) ~= "table" then
      tab = { tab }
    end

    local v
    for k = 1, #tab do
      v = tab[k]
      -- NIL
      if v == nil then
        args[#args + 1] = "NIL"
      -- EMPTY STRING
      elseif v == "" then
        args[#args + 1] = common.quote..common.quote
      -- TABLE
      elseif type(v) == "table" then
        args[#args + 1] = line and serpent.line(v, {nocode = true}) or
                                    serpent.block(v, {nocode = true})
      -- OTHER VALUE
      else
        args[#args + 1] = v
      end
    end
    if #args == 0 then
      args[1] = "nil"
    end
    args.n = #args

    --~ local output = string.format(tostring(msg), table.unpack(args))
    --~ if debugging.debug_in_log then
      --~ -- log(string.format(tostring(msg), table.unpack(args)))
      --~ log(output)
    --~ end

    --~ if debugging.debug_to_game and game then
      --~ -- game.print(string.format(tostring(msg), table.unpack(args)))
      --~ game.print(output)
    --~ end
    do
      local in_game = debugging.debug_to_game and game and true
      local output = (debugging.debug_in_log or in_game) and
                      string.format(tostring(msg), table.unpack(args))
      if output and debugging.debug_in_log then
        log(output)
      end

      if output and in_game then
        game.print(output)
      end
    end

  end

  ------------------------------------------------------------------------------------
  -- Simple helper to show a single value with descriptive text
  debugging.show = function(desc, term, line)
    if debugging.is_debug then
      -- Protect against crashing by making sure that 'line' actually is a string
      -- and that 'line:lower()' resolves to 'l' or 'line'!
      -- (While writeDebug expects 'term' to be wrapped in a table, this function is
      -- meant to show a single value without much effort. This may break if we want
      -- to show the result of a function call that returns a list: 'term' would get
      -- the first return value, 'line' would snatch the second – which could cause
      --  problems in writeDebug when we use it with string.lower().)
      if line then
        local l = (type(line) == "string") and line:lower()
        if not l or (l ~= "line" and l ~= "l") then
          term = {term, line}
          line = nil
        end
      end
      local t = type(term)
      --~ debugging.writeDebug(tostring(desc)..": %s",
                            --~ (t == "userdata" and
                              --~ { debugging.argprint(term) }) or
                              --~ -- (t == "table"  and { term }) or
                              --~ -- term,
                              --~ { term },
                            --~ line)
      if (t == "userdata") then
        term = { debugging.argprint(term) }
      elseif (t == "table") then
        term = { term }
      end
      debugging.writeDebug(tostring(desc)..": %s", term, line)
    end
  end

  ------------------------------------------------------------------------------------
  -- Simple helper to set off a block of messages by adding an empty line
  debugging.writeDebugNewBlock = function(msg, ...)
    if msg then
      debugging.writeDebug("")
      debugging.writeDebug(msg, ...)
    end
  end

  ------------------------------------------------------------------------------------
  -- Print "entityname (id)"
  debugging.print_name_id = function(entity)
    local id
    local name = "unknown entity"

    if entity and entity.valid then
    -- Stickers don't have an index or unit_number!
      id = (entity.object_name == "LuaPlayer" and entity.index) or
            (entity.type == "sticker" and entity.type) or
            entity.unit_number or entity.object_name

      name = entity.name
    end

    return string.format("%s (%s)", name, id)
  end

  ------------------------------------------------------------------------------------
  -- Print "entityname"
  debugging.print_name = function(entity)
    return entity and entity.valid and entity.name or "nil"
  end


  ------------------------------------------------------------------------------------
  -- Print message if something has been created
  --~ debugging.created_msg = function(proto)
  debugging.created_msg = function(object)
    --~ local proto_name = proto and proto.name or debugging.arg_err(proto)
    --~ local proto_type = proto and proto.type or debugging.arg_err(proto)


    --~ local err_msg = (not proto and "argument") or
                    --~ (not proto.name and "object name") or
                    --~ (not proto.type and "object type")

    local t = type(object)
    local tab_or_userdata = (t == "table") or (t == "userdata")
    local err_msg = (not object and "argument") or
                    (tab_or_userdata and (not object.name) and "object name") or
                    (tab_or_userdata and (not object.type) and "object type")

    if err_msg then
      error(string.format(
        "Wrong argument! %s is not a valid %s!",
        debugging.argprint(object),
        err_msg
      ))
    end

    --~ debugging.writeDebug("Created %s \"%s\".", {proto_type, proto_name})
    debugging.writeDebug("Created %s.", {debugging.argprint(object)})
  end

  ------------------------------------------------------------------------------------
  -- Print message if data for additional prototypes have been read
  -- data:      Prototype data
  -- list:      List of the subtables in data that we must check
  -- name:      Name of the thing that has been changed
  -- list_name: The type of list (settings, triggers etc.)
  debugging.readdata_msg = function(data, list, name, list_name)
    local read_data = false

    if list then
      for t, tab in pairs(list) do
        if next(data[tab]) then
          read_data = true
          break
        end
      end
    elseif next(data) then
      read_data = true
    end

    if read_data then
      debugging.writeDebug("Read data for %s%s.",
                            {name, list_name and " ("..list_name..")" or ""})
    else
      debugging.writeDebug("No data for %s read.", {name})
    end
  end


  ------------------------------------------------------------------------------------
  -- Print message if something has been modified
  -- desc:      Description of the changed thing (e.g. "ingredients", "localization")
  -- proto:     Prototype that has been changed
  -- mode:      What happened to the prototype (e.g. "Changed", "Replaced")
  debugging.modified_msg = function(desc, proto, mode)
--~ debugging.entered_function({desc, proto, mode})
    common.assert(desc, {"string", "table"},
                          "description")
--~ common.show("type(proto)", type(proto))
    common.assert(proto, {"table", "userdata"}, "prototype or object")

    mode = (type(mode) == "string") and mode or "Changed"
    local lc = mode:lower()
    local preposition = (lc == "added") and "to" or
                        (lc == "removed") and "from" or
                        "of"
    debugging.writeDebug("%s property \"%s\" %s %s.",
                          {mode, desc, preposition, debugging.argprint(proto)})
  end


  ------------------------------------------------------------------------------------
  --   Function to print info when a file/function/event script is entered or left  --
  ------------------------------------------------------------------------------------
  local function print_on_entered(data)
    if data then
      local args = data.args
      local leave = data.leave
      local bail_out = data.bail_out
      local file = data.file or {}
      local f_name = data.f_name or "NIL"
      local description = data.description
      local sep = data.sep
      local is_event = data.is_event
      local is_file = data.is_file

      local msg, format_string

      -- Function could have been called with short form function(leave, bail_out),
      -- so we must adjust the values of "args" and "leave"
      if args and type(args) ~= "table" and not leave then
        args = {}
        leave = true
      elseif not args then
        args = {}
      end
      leave = leave and "Leaving" or "Entered"

      -- Preserve nil/false (normal exit) and strings (reason for leaving early)
      if bail_out and type(bail_out) ~= "string" then
        bail_out = ""
      end
      bail_out = bail_out and
                  (bail_out ~= "" and " early: "..bail_out or " early!") or
                  ""

      -- Pretty-format the arguments
      local arg_list = ""
      for k, v in pairs(args) do
        arg_list = type(k) == "number" and arg_list..debugging.argprint(v) or
                                            arg_list..k.." = "..debugging.argprint(v)
        arg_list = next(args, k) and arg_list..", " or arg_list
      end

      -- Unlike function arguments, event data will be listed on their own line!
      if is_event and arg_list ~= "" then
        arg_list = "\nEvent data: "..arg_list
      -- Files won't have any arguments!
      elseif is_file then
         arg_list = ""
      end

      format_string =
        is_event and    "%s %s %s%s%s\n(%s: %s)" or
        is_file and     "%s %s %s%s%s" or
                        "%s %s %s(%s)%s\n(%s: %s)"


      msg = { leave, description, f_name, arg_list, bail_out, file.source, file.currentline }
      if is_event then
        msg[4] = bail_out
        msg[5] = arg_list
      end
      msg = string.format(format_string, table.unpack(msg))

      -- Output the formatted text
      debugging.writeDebug("\n%s\n%s\n%s\n", {sep, msg, sep})

    end
  end


   ------------------------------------------------------------------------------------
  -- File has been entered
  debugging.entered_file = function(leave, bail_out)
    -- Skip all the string casting unless we really want to log something!
    if debugging.is_debug then
      --~ local sep = string.rep("*", 100)
      local sep = FILE_SEP

      local f_name = debug.getinfo(2)
      f_name = f_name and f_name.source or "NIL"

      print_on_entered({
        leave = leave, bail_out = bail_out,
        f_name = f_name, description = "file", sep = sep,
        is_file = true
      })
    end
  end


  ------------------------------------------------------------------------------------
  -- Function has been entered
  debugging.entered_function = function(args, leave, bail_out)
    -- Skip all the string casting unless we really want to log something!
    if debugging.is_debug then

      local leaving = leave or (args and type(args) ~= "table")

      local info = debug.getinfo(2)
      local file = info and {
        source = info.source,
        currentline = leaving and info.currentline or info.linedefined
      } or {}

      local f_name = info.name or "NIL"
      --~ local sep = string.rep("-", 100)
      local sep = FUNC_SEP

      print_on_entered({
        args = args, leave = leave, bail_out = bail_out,
        file = file, f_name = f_name, description = "function", sep = sep
      })
    end
  end


  ------------------------------------------------------------------------------------
  -- Function for a /command has been entered
  if script then
    debugging.entered_command = function(args, leave, bail_out)
      -- Skip all the string casting unless we really want to log something!
      if debugging.is_debug then

        local file = debug.getinfo(2)
        local f_name = args and (args.name or args[1]) and
                        util.table.deepcopy(args.name or args[1])
        --~ local sep = string.rep(":", 100)
        local sep = COMM_SEP

        file = file and {source = file.source, currentline = file.currentline} or {}

        -- If we have only args[1], that will be the command name. We don't want that!
        args = (args and args[1] and not next(args, 1)) and {} or
                                                            util.table.deepcopy(args)
        args.name = nil

        print_on_entered({
            args = args, leave = leave, bail_out = bail_out,
            file = file, f_name = f_name, description = "function for command",
            sep = sep
        })
      end
    end
  end


  ------------------------------------------------------------------------------------
  -- Event script has been entered
  if script then
    debugging.entered_event = function(event, leave, bail_out)
      -- Skip all the string casting unless we really want to log something!
      if debugging.is_debug then

        local info = debug.getinfo(2)
        local file = info and {
          source = info.source,
          currentline = leave and info.currentline or info.linedefined
        } or {}
        --~ local sep = string.rep("=", 100)
        local sep = EVEN_SEP
        local args, f_name

        if event then
          --~ f_name = event.name and debugging.event_names[event.name]
          -- We may have stored the literal event name in our list of events, …
          f_name = (event.name and common.event_names[event.name]) or
                    -- … or it could be the name of a custom-input (requires that
                    -- prototype.action == "lua")
                    event.input_name
          args = util.table.deepcopy(event)
          args.name = nil
        end
        if not (args and next(args)) then
          --~ args = {}
          args = {tick = game and game.tick}
        end

        print_on_entered({
          args = args, leave = leave, bail_out = bail_out,
          file = file, f_name = f_name or "unnamed event",
          description = "event script for", sep = sep,
          is_event = true
        })
      end
    end
  end


  ------------------------------------------------------------------------------------
  -- File or function has been entered, but there's nothing to do
  debugging.nothing_to_do = function(sep)
    --~ sep = string.rep(sep or "-", 100)
    sep = sep or FUNC_SEP

    local file = debug.getinfo(2)
    local function_name = debug.getinfo(2, "n").name
    local msg = function_name and
                  --~ function_name.."\n("..file.source..": ".. file.currentline..")" or
                  string.format("%s\n(%s: %s)",
                                function_name, file.source, file.currentline) or
                  file.source
    debugging.writeDebug("\n%s\nNothing to do in %s\n%s\n", {sep, msg, sep})
  end



  ------------------------------------------------------------------------------------
  -- Output a different message if arg is not valid
  local function is_invalid(arg)
    return not (arg and arg.valid) and
            string.format("%s (invalid)", arg.object_name)
  end

  ------------------------------------------------------------------------------------
  -- Output arguments a function was called with
  debugging.argprint = function(arg)
    local arg_type = type(arg)

    -- Default: no debugging or arg is nil
    local ret = "nil"

    -- Debugging must be on, and arg must not be nil
    if debugging.is_debug and arg ~= nil then

      -- Argument was a string
      if arg_type == "string" then
        ret = common.enquote(arg)

      -- Argument was a function
      elseif arg_type == "function" then
        ret = "function"

      -- Argument was a table
      elseif arg_type == "table" then

        -- Data stage: prototype defined in data.raw
        if data and arg.type and arg.name then
            ret = string.format("%s %s", arg.type, common.enquote(arg.name))

        -- Argument was some other table
        else
          ret = serpent.line(arg, {nocode = true})
        end

      -- Argument was a Lua object (only in control stage!)
      elseif arg_type == "userdata" then

        -- Argument was a Lua prototype (e.g. LuaEntityPrototype, LuaItemPrototype)
        --~ if arg.object_name and arg.object_name:match("^Lua%u%a+Prototype$") then
        if arg.object_name:match("^Lua%u%a+Prototype$") then
          ret = is_invalid(arg) or
                string.format("%s %s", arg.object_name, common.enquote(arg.name))

        -- Argument was a player
        elseif arg.object_name == "LuaPlayer" then
          ret = is_invalid(arg) or
                string.format("%s %s (%s)", arg.object_name, arg.index, common.enquote(arg.name))

        -- Argument was a force
        elseif arg.object_name == "LuaForce" then
          ret = is_invalid(arg) or
                string.format("%s %s (%s)", arg.object_name, arg.index, common.enquote(arg.name))

        -- Argument was a surface
        elseif arg.object_name == "LuaSurface" then
          ret = is_invalid(arg) or
                string.format("%s %s (%s)", arg.object_name, arg.index, common.enquote(arg.name))

        -- Argument was a recipe
        elseif arg.object_name == "LuaRecipe" then
          ret = is_invalid(arg) or
                string.format("%s %s", arg.object_name, common.enquote(arg.name))

        -- Argument was an entity
        elseif arg.object_name == "LuaEntity" then
          ret = is_invalid(arg) or
                string.format("%s %s (%s)", arg.type, common.enquote(arg.name), arg.unit_number)

        -- Argument was a technology
        elseif arg.object_name == "LuaTechnology" then
          ret = is_invalid(arg) or
                string.format("%s %s", arg.object_name, common.enquote(arg.name))

        -- Argument was an inventory
        elseif arg.object_name == "LuaInventory" and arg.valid then
          local owner, inv_name
          if arg.mod_owner then
            owner = "from mod "..common.enquote(arg.mod_owner)
            inv_name = arg.index
          else
            owner = arg.entity_owner or arg.equipment_owner or arg.player_owner
            inv_name = (owner and owner.valid) and
                        owner.get_inventory_name(arg.index) or arg.index
          end
          ret = string.format("Inventory %s (%s, %s slots)",
                              inv_name, owner or "unknown owner", #arg)

        -- Argument was an item stack
        elseif arg.object_name == "LuaItemStack" and arg.valid then
          local name = arg.valid_for_read and arg.name or "empty"
          local count = arg.valid_for_read and arg.count or 0
          local quality = arg.valid_for_read and arg.quality and
                            arg.quality.name or "normal"
          ret = string.format("%s %s (%s, %s)",
                              arg.object_name, common.enquote(name), count, quality)

        -- Argument was a GUI element
        elseif arg.object_name == "LuaGuiElement" then
          ret = is_invalid(arg) or
                string.format("%s %s %s",
                              arg.object_name, arg.type, common.enquote(arg.name))

        -- Argument was a style
        elseif arg.object_name == "LuaStyle" then
          ret = is_invalid(arg) or
                string.format("%s %s", arg.object_name, common.enquote(arg.name))

        -- Argument was an equipment grid
        elseif arg.object_name == "LuaEquipmentGrid" then
          ret = is_invalid(arg) or
                string.format("%s %s (%s x %s)",
                              arg.object_name, arg.unique_id, arg.width, arg.height)

        -- Argument was an equipment (placed in equipment grids)
        elseif arg.object_name == "LuaEquipment" then
          ret = is_invalid(arg) or
                string.format("%s %s (%s)", arg.object_name, arg.name, arg.type)

        -- Argument was a logistic network
        elseif arg.object_name == "LuaLogisticNetwork" then
          ret = is_invalid(arg) or
                string.format("%s (%s providers, %s requesters, %s con-bots/%s log-bots)",
                              arg.object_name, #arg.providers, #arg.requesters,
                              arg.all_construction_robots, arg.all_logistic_robots)

        -- Argument was a logistic point
        elseif arg.object_name == "LuaLogisticPoint" then
          local network
          if arg.valid and arg.logistic_network then
            network = arg.logistic_network.valid and
                        "network "..arg.logistic_network.network_id or
                        "invalid network"
          elseif arg.valid then
            network = "no network"
          end
          ret = is_invalid(arg) or
                string.format("%s %s (%s, %s of %s, %s sections, %s, %s)",
                              arg.object_name, arg.logistic_member_index, network,
                              debugging.logistic_modes[arg.mode],
                              debugging.argprint(arg.owner),
                              arg.sections_count,
                              arg.trash_not_requested and "autotrash" or
                                                          "no autotrash",
                              arg.enabled and "enabled" or "disabled")

        -- Argument was a logistic section
        elseif arg.object_name == "LuaLogisticSection" then
          ret = is_invalid(arg) or
                string.format("%s %s of %s (%s, %s, %s filters, %s)",
                              arg.object_name, arg.index,
                              debugging.argprint(arg.owner),
                              arg.group == "" and
                                "no group" or "group "..common.enquote(arg.group),
                              debugging.logistic_section_types[arg.type],
                              arg.filters_count,
                              arg.active and "active" or "not active")

        -- Argument was a train
        elseif arg.object_name == "LuaTrain" then
          local locos = #arg.locomotives.front_movers + #arg.locomotives.back_movers
          ret = is_invalid(arg) or
                string.format("%s %s (%s locomotives, %s wagons)",
                              arg.object_name, arg.id, locos, #arg.carriages - locos)

        -- Argument was a chart tag
        elseif arg.object_name == "LuaCustomChartTag" then
          ret = is_invalid(arg) or
                string.format("%s %s on \"%s\"",
                              arg.object_name, arg.tag_number,
                              arg.surface and arg.surface.valid and arg.surface.name)

        -- Argument was a rendering
        --~ elseif arg.object_name == "LuaRendering" then
        elseif arg.object_name == "LuaRenderObject" then
          ret = is_invalid(arg) or
                string.format("%s %s %s", arg.object_name, arg.type, arg.id)

        -- Argument was a tile
        elseif arg.object_name == "LuaTile" then
          ret = is_invalid(arg) or
                string.format("%s \"%s\" on \"%s\"",
                              arg.object_name, arg.name, arg.surface.name)

        -- Argument was something else
        else
          ret = serpent.line(arg, {nocode = true})
        end

      -- Argument was something else
      else
        ret = serpent.line(arg, {nocode = true})
      end
    end

    return ret
  end



  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  --                              Debugging commands                              --
  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  if script and debugging.is_debug then
    local debugging_commands = {}

    local mod_string = {"mod-name."..script.mod_name}
debugging.show("mod_string", mod_string)

    --------------------------------------------------------------------------------
    -- Print error messages for invalid commands
    debugging.command_err = function(player, msg)
      debugging.entered_function({player, msg})

      player = common.ascertain_player(player)

      if player and player.valid then
        --~ local output = {prefix.."-command-errors.error", msg}
        local output = {"PiClib-command-errors.error", msg}
        player.print(output)
        log({"", "Command error (player \"", player.name, "\")\n", output})
      end

      -- debugging.entered_function("leave")
    end

    --------------------------------------------------------------------------------
    --                Show all events we're currently listening to                --
    --------------------------------------------------------------------------------
    debugging_commands["show-active-events"] = function(command)
      debugging.entered_command(command)

      local player = common.ascertain_player(command.player_index)
      local events = {}

      local bootstrap = {
        on_init = true,
        on_load = true,
        on_configuration_changed = true,
        on_nth_tick = true,
      }

      for event, event_name in pairs(common.event_names) do
        -- Ignore on_init, on_load, and on_configuration_changed
        if not bootstrap[event_name] and script.get_event_handler(event) then
          events[#events + 1] = string.format("%s: %s", event, event_name)
        end
      end

      local msg
      if next(events) then
        --~ msg = {prefix.."-command-output.show-active-events", serpent.block(events)}
        msg = {
          "PiClib-command-output.show-active-events",
          mod_string, serpent.block(events)
        }
      else
        --~ msg = {prefix.."-command-output.show-active-events-no-events"}
        msg = {"PiClib-command-output.show-active-events-no-events", mod_string}
      end
      player.print(msg)
      log(msg)

      debugging.entered_command(command, "leave")
    end


    --------------------------------------------------------------------------------
    --                    Do we listen to the specified event?                    --
    --------------------------------------------------------------------------------
    debugging_commands["is-event-active"] = function(command)
      debugging.entered_command(command)

      local player = common.ascertain_player(command.player_index)
      local id = tonumber(command.parameter)
      local name = command.parameter

      local event, err_msg

      -- We have an ID, so we can check directly whether the specified event exists.
      if id then
        -- Valid event ID
        if common.event_names[id] then
          event = script.get_event_handler(id)
          name = common.event_names[id]
        -- Error: No event with given ID exists.
        else
          --~ err_msg = {prefix.."-command-errors.is-event-active-invalid-event", id}
          err_msg = {"PiClib-command-errors.is-event-active-invalid-event", id}
        end

      -- We have a name
      elseif name then
        -- Ignore fake events where ID and name are the same (on_load etc.)
        if common.event_names[name] then
          id = name

        -- Try to find event name by going over the complete list
        else
          for event_id, event_name in pairs(common.event_names) do
            if name == event_name then
              event = script.get_event_handler(event_id)
              id = event_id
              break
            end
          end

          -- Error: No event with given name exists, so id is still unset.
          if not id then
            --~ err_msg = {prefix.."-command-errors.is-event-active-invalid-event", name}
            err_msg = {"PiClib-command-errors.is-event-active-invalid-event", name}
          end
        end

      -- Error: We have neither name nor ID
      else
        --~ err_msg = {prefix.."-command-errors.is-event-active-no-args"}
        err_msg = {"PiClib-command-errors.is-event-active-no-args"}
      end
  debugging.show("event", event)
  debugging.show("name", name)
  debugging.show("id", id)
  debugging.show("err_msg", err_msg)

      -- Output error message (command_err() will highlight it with color and prefix)
      if err_msg then
        debugging.command_err(player, err_msg)

      -- Everything was OK, print/log the command result!
      else
        local state = event and "true" or "false"
        --~ local msg = {prefix.."-command-output.is-event-active-"..state, name, id}
        local msg = {
          "PiClib-command-output.is-event-active-"..state,
          mod_string, name, id
        }

        player.print(msg)
        log(msg)
      end

      debugging.entered_command(command, "leave")
    end




    --------------------------------------------------------------------------------
    --                         Register debugging commands                        --
    --------------------------------------------------------------------------------
    do
      local name

      --~ for c_name, command in pairs(debugging_commands) do
        --~ name = prefix.."-"..c_name
        --~ if not commands.commands[name] then
          --~ commands.add_command(name,
                                --{prefix.."-commands.command-"..name.."-help", name},
                                --~ {"PiClib-commands.command-"..name.."-help", name},
                                --~ command)
          --~ debugging.writeDebug("Added debugging mode command \"%s\".", {name})
        --~ end
      --~ end
      local help_string
      for c_name, command in pairs(debugging_commands) do
        name = prefix.."-"..c_name
        if not commands.commands[name] then
          help_string = {"PiClib-commands.command-"..c_name.."-help", name}
          commands.add_command(name,
                                --~ {prefix.."-commands.command-"..name.."-help", name},
                                --~ {"PiClib-commands.command-"..name.."-help", name},
                                help_string,
                                command)
          debugging.writeDebug("Added debugging mode command \"%s\".", {name})
        end
      end
    end
  end


  ------------------------------------------------------------------------------------
  PClib_log("Leaving file "..debug.getinfo(1).source)
  return debugging

end
