-- The map settings, read once and again only after one of them changes, as the scripts ask for them constantly.
local config = {}

local prefix = "the-beast-"
local cache

-- Overrides for this save only, set by an admin or a test through the remote interface (configure), over the settings.
local function read()
  cache = {}
  for name, setting in pairs(settings.global) do
    if name:sub(1, #prefix) == prefix then cache[name:sub(#prefix + 1)] = setting.value end
  end
  local overrides = storage.the_beast and storage.the_beast.overrides
  for name, value in pairs(overrides or {}) do
    if cache[name] ~= nil and type(value) == type(cache[name]) then cache[name] = value end
  end
end

-- name (without the prefix) -> value, or nil to clear them all.
function config.configure(overrides)
  storage.the_beast = storage.the_beast or {}
  storage.the_beast.overrides = overrides
  cache = nil
end

function config.get(name)
  if not cache then read() end
  return cache[name]
end

function config.startup(name)
  return settings.startup[prefix .. name].value
end

-- Delays are divided by it, so a faster infection waits less.
function config.spread_ticks(ticks)
  return math.max(1, math.floor(ticks / config.get("spread-speed") + 0.5))
end

config.events =
{
  [defines.events.on_runtime_mod_setting_changed] = function(event)
    if event.setting:sub(1, #prefix) == prefix then cache = nil end
  end
}

return config
