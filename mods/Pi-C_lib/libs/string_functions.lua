PClib_log("Entered file " .. debug.getinfo(1).source)

return function(mod_args)
  local common = _ENV[mod_args.mod_shortname]

  local string_stuff = {}


  ----------------------------------------------------------------------------------
  -- Remove characters at beginning or end of a string
  string_stuff.trim_chars = function(remove_from, left, right)
    common.entered_function({remove_from, left, right})

    common.assert(remove_from, "string", "string to be trimmed")
    common.assert(left, "string", "characters to be trimmed on left side")
    common.assert(right, {"string", "nil",
                          "characters to be trimmed on right side, or nil"})
    --~ right = (type(right) == "string") and right or left
    right = right or left

    -- "*" returns the longest possible match, "-" the shortest
    local pattern = "^["..left.."]*(.-)["..right.."]*$"
    local ret = remove_from:match(pattern)

    common.entered_function("leave")
    return ret
  end



  ----------------------------------------------------------------------------------
  -- Append strings to a localized message
  string_stuff.add_to_msg = function(msg, strings)
    common.entered_function({msg, strings})

    common.assert(msg, "table", "localized message")
    common.assert(strings, {"table", "string"}, "string or array of strings to add")
    strings = (type(strings) == "table") and strings or {strings}

    for a, add in pairs(strings) do
      table.insert(msg, add)
    end

    common.entered_function("leave")
    return msg
  end


  ------------------------------------------------------------------------------------
  PClib_log("Leaving file "..debug.getinfo(1).source)
  return string_stuff
end
