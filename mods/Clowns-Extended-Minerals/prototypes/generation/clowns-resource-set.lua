local special_vanilla = clowns.special_vanilla
--------------------------------------------------
-- define bare minimum (special vanilla tables) --
--------------------------------------------------
local ap_dat={
	["clowns-resource1"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["clowns-resource2"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	--["clowns-resource3"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	--["clowns-resource4"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	--["clowns-resource5"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["infinite-clowns-resource2"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["infinite-clowns-resource1"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
}
local resource_dat = {
  ["clowns-resource1"] = {--[[stage="clowns-resource1",]]ore_sheet = "__Clowns-Extended-Minerals__/graphics/entity/alluvium",	order = "c-k",	mining_time = 1*0.2,	tint = {r = 0.9, g = 0.7, b = 0.7}, frame_c = 4, var_c= 8, acid = "clowns-liquid-phosphoric-acid",icon_size=32},
  ["clowns-resource2"] = {--[[stage="clowns-resource2",]]ore_sheet = "__Clowns-Extended-Minerals__/graphics/entity/oil-sands",	order = "c-l",	mining_time = 1*0.5,	tint = {r = 0.2, g = 0.25, b = 0.25}, frame_c = 4, var_c = 8, acid = "steam",icon_size=32},
}
---------------------------------------------
-- Create ores and auto-plate for each ore --
---------------------------------------------
for ore_name in pairs(resource_dat) do
local build_tab =  {
    name = ore_name,
    order = resource_dat[ore_name].order,
    sheet = {
      filename = resource_dat[ore_name].ore_sheet .. ".png",
      priority = "extra-high",
      --tint = input.tint,
      width = 63,
      height = 63,
      --line_length = resource_dat[ore_name].frame_c,
      frame_count = resource_dat[ore_name].frame_c,
      variation_count = resource_dat[ore_name].var_c,
      hr_version = {
        filename = resource_dat[ore_name].ore_sheet .. "-hr.png",
        priority = "extra-high",
        --tint = input.tint,
        width = 128,
        height = 128,
        --line_length = resource_dat[ore_name].frame_c,
        frame_count = resource_dat[ore_name].frame_c,
        variation_count = resource_dat[ore_name].var_c,
        scale = 0.5,
      }
    },
    infinite = false,
    map_color = resource_dat[ore_name].tint,
    tint = resource_dat[ore_name].tint,
    mining_time = resource_dat[ore_name].mining_time,
    type = "item",
    output_name = ore_name,
    output_min = 1,
    output_max = 1,
    icon = "__Clowns-Extended-Minerals__/graphics/icons/"..ore_name..".png",
    icon_size = resource_dat[ore_name].icon_size,
    autoplace = {
      starting_area = ap_dat[ore_name].starting_area,
      base_density = ap_dat[ore_name].base_density,
      regular_rq_factor_multiplier = ap_dat[ore_name].regular_rq_factor_multiplier,
      starting_rq_factor_multiplier = ap_dat[ore_name].starting_rq_factor_multiplier
    }
  }
  angelsmods.functions.add_resource("make",build_tab)
  if mods["angelsinfiniteores"] then
    local num=string.match(ore_name,"%d+")
    if settings.startup["enableinfiniteclownsresource"..num].value then
      local build_tab = {
        name = "infinite-"..ore_name,
        get = ore_name,
        order = "a"..resource_dat[ore_name].order, --place inf ores at the top of the list
        sheet = {
          filename = resource_dat[ore_name].ore_sheet .. ".png",
          priority = "extra-high",
          --tint = input.tint,
          width = 64,
          height = 64,
          --line_length = resource_dat[ore_name].frame_c,
          frame_count = resource_dat[ore_name].frame_c,
          variation_count = resource_dat[ore_name].var_c,
          hr_version = {
            filename = resource_dat[ore_name].ore_sheet .. "-hr.png",
            priority = "extra-high",
            --tint = input.tint,
            width = 128,
            height = 128,
            --line_length = resource_dat[ore_name].frame_c,
            frame_count = resource_dat[ore_name].frame_c,
            variation_count = resource_dat[ore_name].var_c,
            scale = 0.5,
          }
        },
        infinite = true,
        glow = true,
        var = 6,
        map_color = resource_dat[ore_name].tint,
        tint = resource_dat[ore_name].tint,
        mining_time = resource_dat[ore_name].mining_time,
        type = "item",
        minimum = angelsmods.ores.yield,
        normal = 1500,
        maximum = 6000,
        acid_to_mine = resource_dat[ore_name].acid,
        output_name = ore_name,
        output_min = 1,
        output_max = 1,
        output_probability = angelsmods.ores.loweryield,
        autoplace = {
          starting_area = false,
          resource_index = "z"..resource_dat[ore_name].order,
          base_density = ap_dat[ore_name].base_density/10,--tenth the density
          regular_rq_factor_multiplier = ap_dat[ore_name].regular_rq_factor_multiplier,
          starting_rq_factor_multiplier = ap_dat[ore_name].starting_rq_factor_multiplier
        },
      }
      angelsmods.functions.add_resource("make",build_tab)
      
    end
  end
end