minime.entered_file()

local minime_forces = {}

------------------------------------------------------------------------------------
-- Some settings won't exist until a specific tech has been researched. We check  --
-- whether a force has researched at least one of the necessary techs!            --
------------------------------------------------------------------------------------
local required_techs = {
  ["logistic-robotics"] = true,
}


------------------------------------------------------------------------------------
--                              INITIALIZE FORCE DATA                             --
------------------------------------------------------------------------------------
minime_forces.init_force_data = function(force)
  minime.entered_function({force})

  force = minime.ascertain_force(force)
minime.show("force", force)
  if not (force and force.valid) then
    minime.entered_function({}, "leave", "no valid force")
    return
  end

  local force_string = minime.argprint(force)

  mod.force_data = mod.force_data or {}
  local f_data = mod.force_data
  local has_players
  do
    local suspended = f_data[force.name] and f_data[force.name].suspended_players
minime.show("suspended", suspended)
    has_players = (suspended or next(force.players)) and true
  end
minime.show("f_data", f_data)
minime.show("has_players", has_players)

  mod.researched_by = mod.researched_by or {}
  mod.researched_by[force.name] = {}

  -- We only want to store data for forces with players or suspended players!
  -- (Suspended players are on another force only temporarily, e.g. because they've
  -- moved to a surfacee/force from Blueprint Sandboxes. They will return …)
  minime.writeDebugNewBlock("Are any (suspended) players on %s?",
                            {force_string})
  if has_players then
    minime.writeDebug("Yes: initializing force data!")
    f_data[force.name] = f_data[force.name] or {}

    minime.writeDebug("Checking whether required techs have been researched!")
    local techs = force.technologies or {}
    for tech, t in pairs(required_techs) do
      mod.researched_by[force.name][tech] = techs[tech] and
                                            techs[tech].researched or nil
    end
minime.show("mod.researched_by[\""..force.name.."\"]", mod.researched_by[force.name])

    -- Remove empty tables
    minime.writeDebugNewBlock("Has %s researched relevant techs?", {force})
    if next(mod.researched_by[force.name]) then
      minime.writeDebug("Yes!")
    else
      minime.writeDebug("No: removing empty table mod.researched_by[%s]!",
                        {force.name})
      mod.researched_by[force.name] = nil
    end


    -- Hide our surfaces from this force!
    minime.writeDebugNewBlock("Hiding our surfaces from %s!", {force_string})
    minime_surfaces.hide_surface(nil, force)  -- No surface name: all our surfaces

  -- No players/suspended players on that force!
  else
    minime.writeDebug("No: removing empty table mod.researched_by[%s]!",
                      {force.name})
    mod.researched_by[force.name] = nil
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                         FORCE HAS BEEN CREATED OR RESET                        --
------------------------------------------------------------------------------------
minime_forces.on_force_created_or_reset = function(event)
  minime.entered_function({event})

  local e_name = minime.event_names[event.name]
  local reset = (e_name == "on_force_reset")

  minime.writeDebugNewBlock("%s force: %s data!",
    {reset and "Reset" or "New", reset and "reinitializing" or "initializing"})
  minime_forces.init_force_data(event.force)

  minime.entered_function("leave")
end

------------------------------------------------------------------------------------
--                             FORCES HAVE BEEN MERGED                            --
------------------------------------------------------------------------------------
minime_forces.on_forces_merged = function(event)
  minime.entered_function({event})

  mod.researched_by = mod.researched_by or {}

  local src = event.source_name
  local dst = event.destination

  -- Remove data of destroyed force
  if mod.researched_by[src] then
    mod.researched_by[src] = nil
    minime.writeDebug("Removed mod.researched_by[%s]!", {src})
  end

  -- Not sure whether the remaining force would inherit researched techs from
  -- the destroyed force, so better update the data!
  minime_forces.init_force_data(dst)

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                   CHECK WHETHER FORCE HAS RESEARCHED A TECH!                   --
------------------------------------------------------------------------------------
minime_forces.is_tech_researched = function(force, techs)
  minime.entered_function({force, techs})

  -- We'll need a valid force!
  force = minime.ascertain_force(force)
  if not (force and force.valid) then
    minime.arg_err(force, "force specification")
  end

  -- List of required techs may not be empty!
  minime.assert(techs, "table", "table of technology names")
  if not next(techs) then
    minime.arg_err(techs, "non-empty table")
  end

  local force_researched = mod.researched_by and
                            mod.researched_by[force.name]
  local ret

  if force_researched and next(force_researched) then
    for t, tech in pairs(techs) do
      if force_researched[tech] then
        ret = true
        minime.writeDebug("%s has researched tech \"%s\"!",
                          {minime.argprint(force), tech})
        break
      end
    end
  end
minime.show("ret", ret)

  minime.entered_function("leave")
end



------------------------------------------------------------------------------------
--                            A FORCE RESEARCHED/RESET A TECH!
------------------------------------------------------------------------------------
minime_forces.tech_changed = function(event)
  minime.entered_function({event})

  local e_name = minime.event_names[event.name] or "nil"
  local tech, force

  -- A tech we need has been researched.
  if e_name == "on_research_finished" then
    tech = event.research
    force = tech and tech.force
minime.show("tech.level", tech.level)
    --~ if minime.required_techs[tech.name] and force and force.valid and next(force.players) then
    if required_techs[tech.name] and force and force.valid and next(force.players) then
      mod.researched_by[force.name] = mod.researched_by[force.name] or {}
      mod.researched_by[force.name][tech.name] = true
      minime.writeDebug("Added tech \"%s\" to researched techs of force \"%s\".", {tech.name, force.name})
    else
      minime.writeDebug("Nothing to do!")
    end

  -- If a tech was unresearched, remove it from list of researched techs!
  elseif e_name == "on_research_reversed" then
    tech = event.research
    force = tech and tech.force and tech.force.name

    if mod.researched_by[force] and mod.researched_by[force][tech.name] then
      mod.researched_by[force][tech.name] = nil
      minime.writeDebug("Removed \"%s\" from list of techs researched by force \"%s\".", {tech.name, force})

      if not next(mod.researched_by[force]) then
        mod.researched_by[force] = nil
        minime.writeDebug("Removed mod.researched_by[\"%s\"]!", {force})
      end
    else
      minime.writeDebug("Nothing to do!")
    end

  --~ -- If there was a force_reset, remove all techs from lists of players in that force!
  --~ elseif e_name == "on_force_reset" then
    --~ force = event.force
--~ minime.show("force", force)
    --~ if mod.researched_by[force.name] then
      --~ mod.researched_by[force.name] = nil
      --~ minime.writeDebug("Removed list of researched techs for force %s.", {force.name})
    --~ else
      --~ minime.writeDebug("Nothing to do!")
    --~ end

  -- Apparently we've got here by mistake!
  else
    minime.writeDebug("Nothing to do for event \"%s\"!", {e_name})
  end

  minime.entered_function("leave")
end




-- Remove player's GUI and recreate it with vehicles of the new force, if the new
-- force already has researched the unlock tech
minime_forces.on_player_changed_force = function(event)
  minime.entered_function({event})

  local player = game.get_player(event.player_index)
  local p_data = mod.player_data[player.index]

  local old_force = event.force
  local old_force_data = mod.force_data[old_force.name]

  local new_force = player.force
  local new_force_data = mod.force_data[new_force.name]

  ----------------------------------------------------------------------------------
  -- Players entering a "Blueprint Sandboxes" will be moved to a special force, and
  -- return to their original force on leaving the sandbox. If the new force has
  -- been created by "Blueprint Sandboxes", the player will be suspended: There's no
  -- need to update the GUIs, but we'll hide all GUIs of the player.
  -- If the old force has been created by "Blueprint Sandboxes", the player returned
  -- from sandbox mode and we'll unhide the hidden GUIs again.
  ----------------------------------------------------------------------------------
  minime.writeDebugNewBlock("Is BP_SANDBOXES active?")
  if BP_SANDBOXES then
    minime.writeDebug("Yes! Did player enter/leave Blueprint Sandbox?")
    local prefix = "bpsb-sb-f-"
    local reason

    -- Player entered sandbox. Hide GUIs!
    if minime.prefixed(new_force.name, prefix) then
      reason = "changed to"
      minime.writeDebug("Hiding GUIs of %s!", {minime.argprint(player)})
      minime_gui.disable_guis(player)

      -- Mark player as suspended: won't be able to use the GUI!
      if p_data then
        p_data.suspended = true
        minime.writeDebug("Marked %s as suspended!", {minime.argprint(player)})
      end

      -- Add player to list of suspended players in data of original force, so that
      -- its data will be kept if next(f_data) returns nil
      if old_force_data then
        old_force_data.suspended_players = old_force_data.suspended_players or {}
        old_force_data.suspended_players[player.index] = true
        minime.writeDebug("Added %s to list of players suspended by %s!",
                          {minime.argprint(player), minime.argprint(old_force)})
      end

    -- Player left sandbox. Unhide GUIs!
    elseif minime.prefixed(old_force.name, prefix) then
      reason = "returned from"
      minime.writeDebug("Unhiding GUIs of %s!", {minime.argprint(player)})
      minime_gui.enable_guis(player)

      -- Remove suspended mark from player data!
      if p_data and p_data.suspended then
        p_data.suspended = nil
        minime.writeDebug("%s is no longer suspended!", {minime.argprint(player)})
      end

      -- Remove player from list of suspended players in data of original force
      if new_force_data and new_force_data.suspended_players then
        new_force_data.suspended_players[player.index] = nil
        minime.writeDebug("Removed %s from list of players suspended by %s!",
                          {minime.argprint(player), minime.argprint(old_force)})

        if not next(new_force_data.suspended_players) then
          new_force_data.suspended_players = nil
          minime.writeDebug("Removed mod.force_data[%s].suspended_players!",
                            {minime.enquote(new_force.name)})
        end
      end
    end

    -- Leave early?
    if reason then
      local msg = string.format("%s %s special force of \"blueprint-sandboxes\"",
                                minime.argprint(player or "nil"), reason)
      minime.entered_event(event, "leave", msg)
      return
    end

  else
    minime.writeDebug("No!")
  end
  ----------------------------------------------------------------------------------

  -- Initialize force_data for new force, if necessary
  minime.writeDebugNewBlock("Create mod.force_data[%s]!",
                            {minime.enquote(new_force.name)})
  if new_force_data then
    minime.writeDebug("No: already exists!")
  else
    minime.writeDebug("Yes!")
    mod.force_data[new_force.name] = {}
  end

  -- Remove force_data of old force, if necessary
  minime.writeDebugNewBlock("Remove mod.force_data[%s]?",
                            {minime.enquote(old_force.name)})
  if old_force_data and #old_force.players == 0 and
      not old_force_data.suspended_players then
    minime.writeDebug("Yes!")
    mod.force_data[old_force.name] = nil

  else
    minime.writeDebug("No: %s!", {
      (not old_force_data and "no data stored") or
      (#old_force.players > 0 and "force still has players") or
      (old_force_data.suspended_players and "force has suspended players") or
      "unknown reason"
    })
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
minime.entered_file("leave")
return minime_forces
