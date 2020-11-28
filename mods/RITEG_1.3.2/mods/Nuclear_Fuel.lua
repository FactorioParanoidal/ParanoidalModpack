local mod_name = "__RITEG__"
local RTG = "RITEG-1"
local used_up_RTG = "used-up-RITEG-1"

if data.raw.item["breeder-fuel-cell"] and data.raw.item["used-up-breeder-fuel-cell"] then
  local tech = data.raw.technology["plutonium-breeding"]
  local recipe_name = RTG.."-from-".."used-up-breeder-fuel-cell"
  
  local enabled = true
  if tech then
    enabled = false
    local tech_effects = tech.effects
    table.insert (tech_effects, {recipe = recipe_name, type = "unlock-recipe"})
  end
  
  data:extend ({
    {
      enabled = enabled,
      energy_required = 60,
      icons = {{icon = mod_name.."/graphics/icons/"..RTG..".png"},
      {icon = mod_name.."/graphics/icons/recycling-orange.png", scale = 0.5, shift={-8,8}}}, icon_size = 32,
      ingredients = {
        {"used-up-breeder-fuel-cell", 1},
        {"breeder-fuel-cell", 10}, -- 10x 4 GJ!
        {used_up_RTG, 1}
      },
      name = recipe_name,
      result = RTG,
      type = "recipe"
    }
  })
  
end