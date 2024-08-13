-- mod must either not use event filters, or be prepared to receive unfiltered events
-- mod must handle having an empty `global` in on_load or have it transplanted to `level.__modloader[modname]`

-- you can't *call* remote at file load time, but you can check if an interface exists
-- but there's not really anything useful to call for later either
local loaded = function()
  return true
end
local modloader = {
  env = { _ENV=_ENV },
  remote = {},
}
remote.add_interface("modloader",modloader.remote)

function modloader.load(modname)
  if modname == "level" then
    error("Cannot wrap `level`")
  end
  local modevents = {
    events = {},
    on_nth_tick = {},
  }
  local env = _ENV
  local package = env.package

  local modpackages = {}
  local sandbox
  local function sandbox_require(require_name,withpackage)
  
    -- just skip all the hooking and return cached results directly:
    do
      local cached = modpackages[require_name]
      if cached then
        return cached
      end
    end

    -- check for an existing hook:
    local oldhook,oldmask,oldcount = debug.gethook()
    -- this hook is only a call hook, which means losing a few line events,
    -- but only between here and the start of the main chunk of the required file
    -- there are no return hooks in that time, and the two call hooks are
    -- passed on to the original hook handler via tailcall
    local function hook(event)
      local info = debug.getinfo(2,"fu")
      -- skip the call to require itself...
      if info.func == require then
        if oldhook and oldmask and oldmask:match("c") then
          -- tailcall the original hook to preserve call event
          return oldhook(event)
        end
        return
      end
      -- on the main chunk, replace it's _ENV upval with sandbox
      local f = info.func
      for i = 1,info.nups do -- this *should* always be upval 1 but just to be sure...
        local name = debug.getupvalue(f,i)
        if name == "_ENV" then
          -- replace its _ENV with the sandbox
          debug.upvaluejoin(f,i,function() return sandbox end,1)
          break
        end
      end
  
      -- then restore previous hook and pass along the event
      debug.sethook(oldhook,oldmask,oldcount)
      if oldhook and oldmask and oldmask:match("c") then
        -- and tailcall the original hook to preserve call event
        return oldhook(event)
      end
    end
    
    local realpackage = package.loaded
    if withpackage then
      package.loaded = modpackages
    end
    debug.sethook(hook,"c")
    local result = require(require_name)
    if withpackage then
      package.loaded = realpackage
    end
    return result
  end

  -- on_event needs to be redirected to the events table, print warning when ignoring filters
  local function on_event(event,f,filters)
    local etype = type(event)
    if etype == "number" then
      if filters then
        log("ignored filters") --TODO: print something more useful
      end
      modevents.events[event] = f
    elseif etype == "string" then
      modevents.events[event] = f
    elseif etype == "table" then
      for _,e in pairs(event) do
        on_event(e,f)
      end
    else
      error({"","Invalid Event type ",etype},2)
    end
  end
  sandbox = setmetatable({
    script = setmetatable({
      -- on_init/on_load need redirect, mod needs to handle possibly being added by on_load the first time if added in an update!
      on_init = function(f)
        modevents.on_init = f
      end,
      on_load = function(f)
        modevents.on_load = f
      end,
      on_event = on_event,
      -- on_nth_tick needs to be redirected to events table
      on_nth_tick = function(n,f)
        modevents.on_nth_tick[n] = f
      end,
      on_configuration_changed = function(f)
        modevents.on_configuration_changed = f
      end,
      get_event_handler = function (event)
        return modevents.events[event]
      end,
    },{
      __debugline = "<modloader script proxy for "..modname..">",
      __debugtype = "modloader.LuaBootstrap",
      __index = script,
    }),
    -- reduce arg list and tailcall sandbox_require with only the name
    require = function(name) return sandbox_require(name) end,
    package = setmetatable({loaded = modpackages},{__index = package})
  },{
    __debugline = "<modloader _ENV for "..modname..">",
    __index = function(t,k)
      if k == "global" then
        local global = env.global
        local mods = global.__modloader
        if not mods then
          mods = {}
          global.__modloader = mods
        end
        local mod = mods[modname]
        if not mod then
          mod = {}
          mods[modname] = mod
        end
        return mod
      else
        return env[k]
      end
    end,
    __newindex = function(t,k,v)
      if k == "global" then
        local global = env.global
        local mods = global.__modloader
        if not mods then
          mods = {}
          global.__modloader = mods
        end
        mods[modname] = v
      else
        rawset(t,k,v)
      end
    end,
  })
  modloader.env[modname] = sandbox
  
  sandbox_require("__"..modname.."__/control.lua",true)
  modloader.remote[modname] = loaded
  return modevents
end

return modloader