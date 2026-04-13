---@type data.TechnologyPrototype?
local tech_to_unlock
for _, technology in pairs(data.raw.technology) do
    if technology.effects then			
        for index, effect in pairs(technology.effects) do
            if effect.type == "unlock-recipe" then
                if effect.recipe == "pipe" then
                  tech_to_unlock = technology

                  table.insert(tech_to_unlock.effects, index, {
                    type = "unlock-recipe",
                    recipe = "pipe-elbow"
                  })
                  table.insert(tech_to_unlock.effects, index, {
                    type = "unlock-recipe",
                    recipe = "pipe-junction"
                  })
                  table.insert(tech_to_unlock.effects, index, {
                    type = "unlock-recipe",
                    recipe = "pipe-straight"
                  })

                  break
                end
            end
        end
        if tech_to_unlock then break end
    end
end

data:extend(
{
  {
    type = "recipe",
    name = "pipe-elbow",
    energy_required = 0.2,
    ingredients =
    {
      {type = "item", name = "pipe", amount = 1}
    },
    results = {{type = "item", name = "pipe-elbow", amount = 1}},
    enabled = tech_to_unlock == nil,
  },
  {
    type = "recipe",
    name = "pipe-junction",
    energy_required = 0.2,
    ingredients =
    {
      {type = "item", name = "pipe", amount = 1}
    },
    results = {{type = "item", name = "pipe-junction", amount = 1}},
    enabled = tech_to_unlock == nil,
  },
  {
    type = "recipe",
    name = "pipe-straight",
    energy_required = 0.2,
    ingredients =
    {
      {type = "item", name = "pipe", amount = 1}
    },
    results = {{type = "item", name = "pipe-straight", amount = 1}},
    enabled = tech_to_unlock == nil,
  }
})