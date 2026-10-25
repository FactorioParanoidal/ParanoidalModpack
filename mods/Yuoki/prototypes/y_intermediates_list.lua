--[[Yuoki intermediates script
Copyright joshrick (Codec) © August 2020
adds Yuoki intermediate products to the vanilla intermediates list--]]
local productivity_item_list = {
	"y_slag_brick_burn",
	"y_slag_brick",
	"y_slag_granulate",
	"y_hps_steel",
	"y_hps_purecopper",
	"y_hps_pureiron",
	"y-basic-t2-mf",
	"y_chip_plate",
	"y-chip-1",
	"y-chip-2",
	"yi_magnetron",
	"y-battery-single-use1",
	"y-battery-single-use2",
	"y-battery-single-use3",
	"y_blocked_capa",
	"y-crystal-cnd",
	"y-quantrinum",
	"y-fuel-reactor",
	"y-infused-mud",
	"y-infused-uca2",
	"y_mud2solidfuel",
	"y_mixedfuel2rocketfuel",
	"y-mixfuel-load",
	"y-pure-copper",
	"y-pure-iron",
	"y-refined-copper",
	"y-refined-iron",
	"y-wash-dirt",
	"y-mixing-rich",
	"y-press-richdust",
	"y-orange-stuff",
	"y-smelt-crush-res1",
	"y-smelt-crush-res2",
	"y_quantrinum_infusion",
	"y_mox1fuel",
	"y_mox1mixed",
	"y_mox2fuel",
	"y_mox2mixed",
	"y_mox2fuelsplited",
	"y_structure_element",
	"y-bluegear",
	"y_structure_vessel",
	"y-basic-t1-mf",
	"y_chip_plate",
	"y_dotzetron",
	"y_structure_electric",
	"y-heat-pipe",
	"y-heat-pipe",
	"y-conductive-coil-1",
	"y-conductive-wire-1",
	"y-crush-unicomp-raw",
	"y-crush-fuel-raw",
	"y_slag_granulate",
	"y_steinmehl",
	"y-coal-dust",
	"y_granulate_wood",
	"y-unicomp-raw",
	"y-raw-fuelnium",
	"y-bullet-case",
	"y_ammo_case",
	"yi_graphite",
	"y_data_crystal",
	"y_gauge_analog",
}

--[[
or _, module in pairs(data.raw.module) do
  if module.effect and module.limitation then
    for effect_name in pairs(module.effect) do
      if effect_name == "productivity"then
    for _, item in pairs( productivity_item_list) do
                table.insert(module.limitation,    item)
    end
        break
      end
    end
  end
end
]]
--

--for productivity_item_list, recipe in pairs(data.raw.recipe) do
--			recipe.allow_productivity = true
--end

for k, v in pairs(productivity_item_list) do
	if data.raw.recipe[v] then
		data.raw.recipe[v].allow_productivity = true
	--data.raw.recipe["y-inserter-s4"].order = "c"
	else
		log("This isnt a recipe " .. v)
	end
end
