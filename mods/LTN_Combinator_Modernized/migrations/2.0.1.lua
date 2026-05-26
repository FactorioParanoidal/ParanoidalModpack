local config = require("script.config")

-- Find all the combinators and create an entry in storage
local combinator_count = 0
for _, surface in pairs(game.surfaces) do
  local entities = surface.find_entities_filtered({name = "ltn-combinator"})
  if not string.match(surface.name, "^secret") then
    combinator_count = combinator_count + #entities
  end
  for _, entity in pairs(entities) do
    --- @type CombinatorData
    local cd = { provider = true, requester = true}
    local ctl = entity.get_control_behavior()
    --- @cast ctl LuaConstantCombinatorControlBehavior
    -- If depot is set, all provider and requester signals are ignored.
    -- Disable requester and provider and clear requester provider signals
    local sig = ctl.get_signal(config.ltn_signals["ltn-depot"].slot)
    if sig.signal and sig.signal.name == "ltn-depot" and sig.count > 0 then
      cd = { provider = false, requester = false }
      for signal_name, details in pairs(config.ltn_signals) do
        if details.group == "provider" or details.group == "requester" then
          ctl.set_signal(details.slot, nil)
        end
      end
      goto continue
    end

    -- Not a depot, save non-zero thresholds into storage
    for _, service in ipairs{ "provider", "requester" } do
      -- First check if service is "disabled" from high threshold
      -- The high threshold used in pre-2.0 combinator was 50000000
      local name = "ltn-" .. service .. "-threshold"
      local sig = ctl.get_signal(config.ltn_signals[name].slot)
      -- If threshold is above <old_high_threshold> set the service to off
      -- and set the new high threshold
      if sig.signal and sig.signal.name == name then
        if sig.count >= config.old_high_threshold then
          cd[service] = false
          ctl.set_signal(config.ltn_signals[name].slot, {
            signal = { name = name, type = "virtual" },
            count = config.high_threshold
          })
        else
          --- @type int
          cd[name] = sig.count
        end
      end

      -- Store the stack threshold in storage if one exists.
      name = "ltn-" .. service .. "-stack-threshold"
      sig = ctl.get_signal(config.ltn_signals[name].slot)
      -- If stack threshold is set, save it in storage
      -- If the service is "disabled" (high value set in non-stack threshold
      -- make sure actual stack-threshold signal is removed
      if sig.signal and sig.signal.name == name and sig.count ~= 0 then
        --- @type integer
        cd[name] = sig.count
        if not cd[service] then
          ctl.set_signal(config.ltn_signals[name].slot, nil)
        end
      end
    end

    ::continue::
    storage.combinators[entity.unit_number] = cd
  end
end
if combinator_count > 0 then
  game.print({"ltnc.migrated-combinators", combinator_count})
end
