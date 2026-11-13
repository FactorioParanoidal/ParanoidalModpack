--GUI

function spriteCheck(guiLeft, spritePath)
	game.print(spritePath)
	if guiLeft.gui.is_valid_sprite_path(spritePath) then
		return spritePath
	else
		return "utility/questionmark"
	end
end

function addRow(EMC_table, tag, note, spritePath, buttonsStyle)
	EMC_table.add{type="sprite-button", name=tag, tooltip=note, sprite=spritePath, style="entity_style"}
	EMC_table.add{type="button", name=tag.."c", style=buttonsStyle}
end

function legendDropdown(guiLeft)
	local steam = false
	local tech = game.forces.player.technologies
	guiLeft.add{type="frame", name="EMC_frame", caption="Цвет сущности", direction="vertical", style="frame"}.add{type="table", name="EMC_table", column_count=2, style="EMC_table_style"}
	local table = guiLeft.EMC_frame.EMC_table
	if tech["logistics"] and tech["logistics"].researched then --entity is data.raw and item is data.raw.item
		addRow(table,
					"belt1",
					"Все жёлтые конвейеры, разделители и подземные конвейеры",
					spriteCheck(guiLeft,"entity/transport-belt"),
					"map_color_graphic_basic")
	end
	if tech["logistics-2"] and tech["logistics-2"].researched then
		addRow(table,
					"belt2",
					"Все красные конвейеры, разделители и подземные конвейеры",
					spriteCheck(guiLeft,"entity/fast-transport-belt"),
					"map_color_graphic_fast")
	end
	if tech["logistics-3"] and tech["logistics-3"].researched then
		addRow(table,
					"belt3",
					"Все синие конвейеры, разделители и подземные конвейеры",
					spriteCheck(guiLeft,"entity/express-transport-belt"),
					"map_color_graphic_express")
	end
	for modName,_ in pairs(script.active_mods) do
		if modName == "Visible_Bots" then
			if tech["construction-robotics"] and tech["construction-robotics"].researched then
				addRow(table,
					"construction robot",
					"строительный дрон",
					spriteCheck(guiLeft,"entity/construction-robot"),
					"visible_bots_construction")
			end
			if tech["logistic-robotics"] and tech["logistic-robotics"].researched then
				addRow(table,
					"logistic robot",
					"логистический дрон",
					spriteCheck(guiLeft,"entity/logistic-robot"),
					"visible_bots_logistic")
			end
		end
		if modName == "boblogistics" then
			if tech["logistics-4"] and tech["logistics-4"].researched then -------conflict between bobs and 5dim?
				addRow(table,
					"belt4",
					"Все фиолетовые конвейеры, разделители и подземные конвейеры Bobs",
					spriteCheck(guiLeft,"item/turbo-transport-belt"),
					"map_color_graphic_bob_logistics_4")
			end
			if tech["logistics-5"] and tech["logistics-5"].researched then
				addRow(table,
					"belt5",
					"Все зелёные конвейеры, разделители и подземные конвейеры Bobs",
					spriteCheck(guiLeft,"item/ultimate-transport-belt"),
					"map_color_graphic_bob_logistics_5")
			end
		end
		if modName == "5dim_transport" then
			if tech["logistics-4"] and tech["logistics-4"].researched then
				addRow(table,
					"5dbelt4",
					"Все зелёные конвейеры, разделители и подземные конвейеры 5Dim",
					spriteCheck(guiLeft,"item/5d-mk4-transport-belt"),
					"map_color_graphic_5dim_transport_4")
			end
			if tech["logistics-5"] and tech["logistics-5"].researched then
				addRow(table,
							"5dbelt5",
							"Все белые конвейеры, разделители и подземные конвейеры 5Dim",
							spriteCheck(guiLeft,"item/5d-mk5-transport-belt"),
							"map_color_graphic_5dim_transport_5")
			end
		end
		if modName == "UraniumPower" then
			if tech["uranium-processing"] and tech["uranium-processing"].researched then
				addRow(table,
							"Uranium Power",
							"Урановая энергетика",
							spriteCheck(guiLeft,"technology/uranium-processing"),
							"map_color_graphic_steam")
				steam = true
			end
		end
	end
	if settings.startup["Use-Mod-Color-for-pipes"].value then
		if tech["fluid-handling"] and tech["fluid-handling"].researched then
			addRow(table,
						"tank",
						"Все трубы, подземные трубы и резервуары",
						spriteCheck(guiLeft,"entity/storage-tank"),
						"map_color_graphic_ptg")
		else
			addRow(table,
						"pipe",
						"Все трубы, подземные трубы и резервуары",
						spriteCheck(guiLeft,"entity/pipe"),
						"map_color_graphic_ptg")
		end
	end
	if tech["logistic-robotics"] and tech["logistic-robotics"].researched or tech["construction-robotics"] and tech["construction-robotics"].researched then
		if settings.startup["Use-Mod-Color-for-roboports"].value then
			addRow(table,
					"Roboports",
					"Roboports",
					spriteCheck(guiLeft,"entity/roboport"),
					"map_color_graphic_port")
		end
	end
		addRow(table,
					"Radar",
					"Radar",
					spriteCheck(guiLeft,"entity/radar"),
					"map_color_graphic_radar")
	if tech["electric-energy-distribution-2"] and tech["electric-energy-distribution-2"].researched then
		addRow(table,
					"substation",
					"Все электрические опоры",
					spriteCheck(guiLeft,"entity/substation"),
					"map_color_graphic_medium")
	elseif tech["electric-energy-distribution-1"] and tech["electric-energy-distribution-1"].researched then
		addRow(table,
					"poles",
					"Все электрические опоры",
					spriteCheck(guiLeft,"entity/medium-electric-pole"),
					"map_color_graphic_medium")
	else
		addRow(table,
					"pole",
					"Все электрические опоры",
					spriteCheck(guiLeft,"entity/small-electric-pole"),
					"map_color_graphic_medium")
	end
	if tech["solar-energy"] and tech["solar-energy"].researched then
		addRow(table,
					"solar",
					"Солнечные панели",
					spriteCheck(guiLeft,"entity/solar-panel"),
					"map_color_graphic_solar")
	elseif not steam then
		if settings.startup["Use-Mod-Color-for-steam-generators"].value then
			addRow(table,
						"Steam Power",
						"Энергия пара",
						spriteCheck(guiLeft,"entity/steam-engine"),
						"map_color_graphic_steam")
		end
	end
	guiLeft.EMC_frame.add{type="button", name="close", caption="Закрыть", style="button"}
end
