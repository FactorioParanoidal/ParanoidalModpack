for _,force in pairs(game.forces) do
  if(force.technologies["fusion-weapons"]) then
    force.technologies["fusion-weapons"].researched = (force.technologies["compact-fusion-weapons"] and force.technologies["compact-fusion-weapons"].researched)
      or force.technologies["fusion-weapons"].researched
  end


  if(force.technologies["compact-full-fission-weapons"]) then
    force.technologies["compact-full-fission-weapons"].researched = (force.technologies["fusion-weapons"] and force.technologies["fusion-weapons"].researched)
      or force.technologies["compact-full-fission-weapons"].researched
  end


  if(force.technologies["full-fission-atomics"]) then
    force.technologies["full-fission-atomics"].researched = (force.technologies["compact-full-fission-weapons"] and force.technologies["compact-full-fission-weapons"].researched)
      or force.technologies["full-fission-atomics"].researched
  end


  if(force.technologies["compact-californium-weapons"]) then
    force.technologies["compact-californium-weapons"].researched = (force.technologies["compact-full-fission-weapons"] and force.technologies["compact-full-fission-weapons"].researched)
      or force.technologies["compact-californium-weapons"].researched
  end

  if(force.technologies["artillery-atomics"]) then
    force.technologies["artillery-atomics"].researched = (force.technologies["compact-full-fission-weapons"] and force.technologies["compact-full-fission-weapons"].researched)
      or force.technologies["artillery-atomics"].researched
  end


  if(force.technologies["californium-weapons"]) then
    force.technologies["californium-weapons"].researched = (force.technologies["compact-californium-weapons"] and force.technologies["compact-californium-weapons"].researched)
      or (force.technologies["californium-processing"] and force.technologies["californium-processing"].researched)
      or force.technologies["californium-weapons"].researched
  end

  if(force.technologies["expanded-atomics"]) then
    force.technologies["expanded-atomics"].researched = (force.technologies["artillery-atomics"] and force.technologies["artillery-atomics"].researched)
      or (force.technologies["californium-weapons"] and force.technologies["californium-weapons"].researched)
      or (force.technologies["full-fission-atomics"] and force.technologies["full-fission-atomics"].researched)
      or force.technologies["expanded-atomics"].researched
  end

  force.technologies["atomic-bomb"].researched = (force.technologies["expanded-atomics"] and force.technologies["expanded-atomics"].researched)
    or force.technologies["atomic-bomb"].researched

  if(force.technologies["basic-atomic-weapons"]) then
    force.technologies["basic-atomic-weapons"].researched = force.technologies["atomic-bomb"].researched
      or force.technologies["basic-atomic-weapons"].researched
  end
end
