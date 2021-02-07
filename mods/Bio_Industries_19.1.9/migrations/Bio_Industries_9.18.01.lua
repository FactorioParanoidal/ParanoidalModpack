local BioInd = require('__Bio_Industries__/common')('Bio_Industries')
--~ game.reload_script()


for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  for _, tech in ipairs({"bi-tech-coal-processing-2", "bi-tech-coal-processing-3"}) do
        -- Technology exists and has already been researched
BioInd.writeDebug("Checking tech: %s for force %s (Researched: %s)", {tech, force and force.name or "nil", technologies[tech] and technologies[tech].researched or "nil"})

    if game.technology_prototypes[tech] and technologies[tech].researched then
      -- Check if all prerequisite technologies have been researched
      local all_prereqs = true
      for pname, ptech in pairs(technologies[tech].prerequisites) do
        BioInd.writeDebug("pname: %s", {pname})
        BioInd.writeDebug("ptech: %s", {ptech})
        if not ptech.researched then
          all_prereqs = false
          break
        end
      end

      -- If not all prerequisite technologies have been researched, ...
      if not all_prereqs then
        game.print({"", "Not all prerequisite technologies for ", {"technology-name." .. tech}, " have been researched!"})
        -- reset all unlocked recipes and
        for _, effect in pairs(technologies[tech].effects) do
          if effect.type == "unlock-recipe" then
            game.print({"", "Disabling recipe \"", {"recipe-name." .. effect.recipe}, "\""})
            recipes[effect.recipe].enabled = false
            recipes[effect.recipe].reload()
          end
        end
        -- unresearch the technology
        game.print({"", "Disabling technology \"", {"technology-name." .. tech}, "\"" })
        technologies[tech].researched = false
        technologies[tech].reload()
      end
    end
  end
end
