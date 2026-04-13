-- Log activity of this
--~ PClib_must_log = (mods and mods["_debug"]) or
                  --~ (script and script.active_mods["_debug"])
PClib_must_log = false

PClib_log = function(msg)
  if PClib_must_log then
    log(msg)
  end
end

------------------------------------------------------------------------------------

PClib_log("Entered file " .. debug.getinfo(1).source)
require("util")


local common, mod_prefix


-- Settings will be extended to data.raw. In the settings stage, data.raw will be
-- either empty (if no other mods have defined settings yet), or contain just data
-- for the setting types. If we find at least one other type in data.raw, we must
-- be in the data stage!
local is_settings_stage
do
  -- Data or settings stage?
  if data and data.raw then
    is_settings_stage = true

    -- We may be in settings stage even if data.raw is not empty!
    if next(data.raw) then
      local setting_types = {
        ["bool-setting"] = true,
        ["color-setting"] = true,
        ["double-setting"] = true,
        ["int-setting"] = true,
        ["string-setting"] = true,
      }
      for k, v in pairs(data.raw) do
        PClib_log("Checking data.raw[\""..k.."\"].")
        if not setting_types[k] then
          PClib_log("Found key that is not a setting: "..k..". We're in data stage!")
          is_settings_stage = false
          break
        else
          PClib_log("It's a setting!")
        end
      end
    end
  end
end


return function(mod_args)
  PClib_log(string.format("mod_args: %s", serpent.block(mod_args, {nocode = true})))
  local include_other = {}

  do
    local arg

    if type(mod_args) ~= "table" or not next(mod_args) then
      error("No arguments!")
    end

    local function is_valid_arg(arg_type)
      if not mod_args[arg] then
        error(string.format("Missing argument: '%s'!", arg))
      elseif type(mod_args[arg]) ~= arg_type then
        error(string.format("'%s' is not a %s: %s!",
                            arg, arg_type, serpent.line(mod_args[arg])))
      end
      return true
    end


    -- Name of single other lib or array of names of other libs we want to load in
    -- addition to assertions.lua and debugging.lua!
    arg = "include"
    PClib_log("Checking mod_args["..arg.."]!")
    if mod_args[arg] then

      --~ if is_settings_stage() then
      if is_settings_stage then
        PClib_log("Won't include optional libs in settings stage!")
      else
        local v = mod_args[arg]
        local t = type(v)
        if t == "string" then
          PClib_log(string.format("Must include single file %s!", v))
          include_other = {v}

        elseif t == "table" then
          PClib_log(string.format("Must include files %s!", serpent.line(v)))
          include_other = v

        else
          error(string.format("Not a file name or array of file names: %s",
                              serpent.line(v)))
        end
      end
    end

    -- Mod name must be passed on in data stage!
    if data and not include_other then
      arg = "mod_name"
      PClib_log("Checking mod_args["..arg.."]!")
      is_valid_arg("string")
    end

    -- Short version of mod name, used as
    --  - global table holding the defined data, e.g. minime.show() or AD.assert()
    --  - prefix for command names and locale keys
    arg = "mod_shortname"
    PClib_log("Checking mod_args["..arg.."]!")
    if mod_args[arg] then
      is_valid_arg("string")
    end
    mod_prefix = mod_args[arg]

    -- Name of setting that enables debugging to log file (optional)
    arg = "debug_log_setting"
    PClib_log("Checking mod_args["..arg.."]!")
    if mod_args[arg] then
      is_valid_arg("string")
    end

    -- Type of setting that enables debugging to log file (optional)
    arg = "debug_log_setting_type"
    PClib_log("Checking mod_args["..arg.."]!")
    if mod_args[arg] then
      is_valid_arg("string")
    end

    -- Name of setting that enables debugging in game (optional)
    arg = "debug_game_setting"
    PClib_log("Checking mod_args["..arg.."]!")
    if mod_args[arg] then
      is_valid_arg("string")
    end

    -- Type of setting that enables debugging in game file (optional)
    arg = "debug_log_setting_type"
    PClib_log("Checking mod_args["..arg.."]!")
    if mod_args[arg] then
      is_valid_arg("string")
    end
  end



  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  --                           Variables and tables                               --
  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  PClib_log("mod_prefix: "..tostring(mod_prefix))
  _ENV[mod_prefix] = {}
  common = _ENV[mod_prefix]
  local libs = "__Pi-C_lib__.libs."



  ----------------------------------------------------------------------------------
  -- Get mod name and path to mod
  common.modName = mod_args.mod_name or (script and script.active_mod)
  if common.modName == nil and not include_other then
    error("Missing argument 'mod_name'!")

  elseif type(common.modName) ~= "string" then
    local msg = "Wrong argument 'mod_name'!\nExpected: string\nGot: %s"
    error(string.format( msg, serpent.line(common.modName, {nocode = true}) ))
  end
  PClib_log("common.modName: "..tostring(common.modName or "nil"))

  common.modRoot = "__"..common.modName.."__"


  if common.modName then
    common.EMPTY_TAB = {}
    common.quote = "\""
  end


  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  --                           Load data from libraries                           --
  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------


  ----------------------------------------------------------------------------------
  -- Import data from libraries
  --~ local function import_from_file(add_to_tab, file_name)
  common.import_from_file = function(add_to_tab, file_name)
    PClib_log(string.format("Entered function import_from_file(%s, %s)",
                            add_to_tab, file_name))
    local t_a = type(add_to_tab)
    local t_f = type(file_name)
    PClib_log(string.format("t_a: %s", t_a))
    PClib_log(string.format("t_f: %s", t_f))

    -- Shortcut: If add_to_tab is a string and there is no file_name, add data from
    --           file to common table.
    if t_a == "string" and file_name == nil then
      PClib_log("No file_name and add_to_tab is string!")
      file_name = add_to_tab
      add_to_tab = common

    -- Fall back to 'common' if add_to_tab is nil
    elseif t_a == "nil" then
      PClib_log("add_to_tab is nil!")
      add_to_tab = common

    -- Error if add_to_tab is not a table
    elseif t_a ~= "table" then
      PClib_log("add_to_tab is not a table!")
      error("No table to include data!")
    end
    PClib_log(string.format("add_to_tab: %s", add_to_tab))
    PClib_log(string.format("file_name: %s", file_name))

    -- Error if file_name is missing
    if type(file_name) ~= "string" or file_name == "" then
      error("Missing library name!")
    end

    -- Read lib. This will return either a function we must call, or a table.
    local imported = require(file_name)
    PClib_log("\nGot table or function?")
    if type(imported) == "function" then
      PClib_log("Calling function to get data!")
      imported = imported(mod_args)
    else
      PClib_log("Using data from table!")
    end
    PClib_log(string.format("imported: %s",
                            serpent.block(imported,{nocode = true})))

    -- Copy data from lib to common!
    for key, value in pairs(imported) do
      --~ add_to_tab[key] = value
      add_to_tab[key] = util.table.deepcopy(value)
      PClib_log(string.format("Added \"%s\": %s",
                        key, type(value) == "function" and
                          "function" or serpent.block(value, {nocode = true})))
    end
  end


  do
    local lib

    -- Load assertions (pulling in debugging functions, if needed) if we have been
    -- called with mod_name!
    if mod_args.mod_name ~= nil then
      PClib_log(string.format("Initializing data for mod \"%s\": loading assertions!",
                        mod_args.mod_name))

      lib = libs.."assertions"
      PClib_log(string.format("\nImporting data from %s!\n", lib))
      common.import_from_file(lib)
    end


    -- Load data from optional libraries? We don't need this in the settings stage!
    PClib_log("Load optional libraries?")
    if is_settings_stage then
      PClib_log("No: we're in settings stage!")

    elseif not next(include_other) then
      PClib_log("No: no optional libraries requested!")

    else
      PClib_log("Yes!")
      local file
      for f, file_name in pairs(include_other) do
        PClib_log(string.format("%s: %s", f, file_name))
--~ common.show(f, file_name)
        file = file_name:gsub(".lua$", "")
        if file then
          lib = libs..file
          PClib_log(string.format("\nImporting data from %s!\n", lib))
          common[file] = common[file] or {}
          common.import_from_file(common[file], lib)
        end
      end
    end
  end


  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  --                                   Functions                                  --
  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  if mod_args.mod_name ~= nil then
    PClib_log(string.format("Initializing data for mod \"%s\"!", mod_args.mod_name))

    --------------------------------------------------------------------------------
    --                    ALL: Enclose text in quotation marks                    --
    --------------------------------------------------------------------------------
    common.enquote = function(text)
      local t = type(text)
      return string.format("\"%s\"",
                            (t == "nil" and "") or
                            (t == "string" and text) or
                            serpent.line(text, {nocode = true}))
    end


    --------------------------------------------------------------------------------
    --                     ALL: Check whether a mod is active                     --
    --------------------------------------------------------------------------------
    common.check_mods = function(mod_name)
      return (mods and mods[mod_name]) or (script and script.active_mods[mod_name])
    end


    --------------------------------------------------------------------------------
    --           ALL: Swap values of 'a' and 'b' if 'condition' is true           --
    --------------------------------------------------------------------------------
    common.swap_args = function(a, b, condition)
      common.entered_function({a, b, condition})

      if a and condition and b == nil then
        b, a = a, nil
        common.show("a", a)
        common.show("b", b)
      end

      common.entered_function("leave")
      return a, b
    end



    --------------------------------------------------------------------------------
    --                  ALL: Get value of a setting (by setting)                  --
    --------------------------------------------------------------------------------
    common.get_setting_value = function(setting)
      return setting and setting.value
    end

    --------------------------------------------------------------------------------
    --                ALL: Get value of a startup setting (by name)                 --
    --------------------------------------------------------------------------------
    common.get_startup_setting = function(name)
      common.assert(name, {"string", "nil"}, "setting name or nil")
      return name and common.get_setting_value(settings.startup[name])
    end


    --------------------------------------------------------------------------------
    --              CONTROL: Get value of a global setting (by name)              --
    --------------------------------------------------------------------------------
    if script then
      common.get_global_setting = function(name)
        common.assert(name, {"string", "nil"}, "setting name")
        --~ return settings.global[name] and settings.global[name].value
        return name and common.get_setting_value(settings.global[name])
      end
    end


    --------------------------------------------------------------------------------
    --  CONTROL: Remote calls made easy (check for remote interface and function) --
    --------------------------------------------------------------------------------
    if script then
      common.remote_call = function(interface, func, ...)
        common.entered_function({interface, func, ...})

        common.assert(interface, "string")
        common.assert(func, "string")

        local args = {...}

        local ret = common.EMPTY_TAB

        if remote.interfaces[interface] and remote.interfaces[interface][func] then
          common.writeDebug("Calling function %s of interface %s!",
                            {func, interface})
          -- Make ret a table to catch all values returned by the remote call!
          ret = {remote.call(interface, func, table.unpack(args))}
common.show("Returned by remote call", ret)
        else
          common.writeDebug("Remote %s doesn't exist!", {
            remote.interfaces[interface] and "function "..common.enquote(func) or
                                             "interface "..common.enquote(interface)
          })
        end

        common.entered_function("leave")
        -- Return nil if we didn't call the remote function, or all values returned
        -- by the function call (0 or more).
        return table.unpack(ret)
      end
    end

  else
    PClib_log("Skipped adding functions: loaded for importing optional libs!")
  end

  ----------------------------------------------------------------------------------
  PClib_log("End of common.lua!")
  return common
end
