-- Version 1.1.1 includes radical changes to the recipes and moves inlaid
-- lamps behind "steel-processing". If the new version is loaded into an existing
-- game, we should make sure that all prerequisites have already been researched,
-- or reset the research state of our techs.

script.on_configuration_changed(function(event)
  local techs = { "flat-lamp-t", }
  local tech

  -- Check our technologies
  for f, force in pairs(game.forces) do
    for t, technology in pairs(techs) do
      tech = force.technologies[technology]

      -- If tech has been researched, make sure all its prerequisites have
      -- been researched as well
      if tech and tech.researched then
        for p, prereq in pairs(tech.prerequisites) do

          -- Unresearch tech if a prerequisite is still missing
          if not (force.technologies[p] and force.technologies[p].researched) then
            log(string.format("Unresearching technology %s because prerequiste %s has not been researched! (Force: %s)", technology, p, f))
            tech.researched = false
            break
          end
        end
      end
    end
    force.reset_technology_effects()
    log("Reset technology effects for force " .. f)
  end
end)


------------------------------------------------------------------------------------
--          FIND LOCAL VARIABLES THAT ARE USED GLOBALLY         --
--                (Thanks to eradicator!)               --
------------------------------------------------------------------------------------
setmetatable(_ENV,{
  __newindex=function (self,key,value) --locked_global_write
  error('\n\n[ER Global Lock] Forbidden global *write*:\n'
    .. serpent.line{key=key or '<nil>',value=value or '<nil>'}..'\n')
  end,
  __index   =function (self,key) --locked_global_read
  error('\n\n[ER Global Lock] Forbidden global *read*:\n'
    .. serpent.line{key=key or '<nil>'}..'\n')
  end ,
  })
