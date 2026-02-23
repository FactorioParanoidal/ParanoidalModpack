BioInd = require("__" .. script.mod_name .. "__.common")(script.mod_name)
-- Presets for Milestones mod
local function milestones_preset_addons()
local grouped_milestones = {}


  grouped_milestones["resorces"] = {
    { type = "group", name = "Resources" },
    { type = "item", name = "bi-woodpulp", quantity = 1 },
    { type = "item", name = "bi-woodpulp", quantity = 1000, next = "x10", hidden = true },
    { type = "item", name = "bi-ash", quantity = 1, next = "x10" },
    { type = "item", name = "bi-ash", quantity = 1000, next = "x10", hidden = true },
    { type = "item", name = "stone-crushed", quantity = 1 },
    { type = "item", name = "stone-crushed", quantity = 1000, next = "x10", hidden = true },
    { type = "item", name = "fertilizer", quantity = 1 },
    { type = "item", name = "fertilizer", quantity = 1000, next = "x10", hidden = true },
    { type = "item", name = "bi-adv-fertilizer", quantity = 1 },
    { type = "item", name = "bi-adv-fertilizer", quantity = 1000, next = "x10", hidden = true },
    }

grouped_milestones["progress"] = {
	{type = "group", name = "Progress" },
    {type="item", name="bi-bio-farm",       quantity=1},
    {type="item", name="bi-bio-greenhouse", quantity=1},
	{type="item", name="bi-bio-garden", quantity=1},
	{type="item", name="bi-bio-garden-large", quantity=1},
	{type="item", name="bi-bio-garden-huge", quantity=1},
	
	
	}

    --script.active_mods["Bio_Industries_2"] and { type = "item", name = "bob-beacon-2", quantity = 1 } or nil,        
    

if BioInd.get_startup_setting("BI_Bio_Cannon") then
grouped_milestones["Bio_Cannon"] = {
	{type = "group", name = "Bio Cannon" },
    {type="item", name="bi-bio-cannon",       quantity=1},
   -- {type="ammo", name="bi-bio-cannon-proto-ammo", quantity=1},
--	{type = "ammo", name = "bi-bio-cannon-proto-ammo", quantity = 1000, next = "x10", hidden = true },
	}
end

if BioInd.get_startup_setting("BI_Bio_Fuel") then
grouped_milestones["Bio_Fuel"] = {
	{type = "group", name = "Bio Fuel" },
    {type="item", name="bi-bio-reactor",       quantity=1},
    {type="item", name="bi-bio-boiler",       quantity=1},
	}
end



  local milestones = {}
  for group_name, group_milestones in pairs(grouped_milestones) do
    for _, milestone in pairs(group_milestones) do
      table.insert(milestones, milestone)
    end
  end


  return {
    ["Bio Industries"] = {
      required_mods = { "Bio_Industries_2" },
	  forbidden_mods = {},
      milestones = milestones,
    },
  }
end

remote.add_interface("Bio_Industries_2", {
  milestones_preset_addons = milestones_preset_addons,
})
