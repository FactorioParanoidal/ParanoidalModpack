local Convert = {}


function Convert.convert(player, blueprint_string)
	local replacements = {
		["curved-rail"]="lecacy-curved-rail"
	}
	local missing_entities = {}
	local missing_icons = {}
	local missing_tiles = {}
	local replaced_entities = {}
	if not blueprint_string:match("^[01]") then return nil, "Invalid blueprint string format: Missing leading 0 or 1."	end
	local base64_string = blueprint_string:sub(2)
	local decoded_string = helpers.decode_string(base64_string)
	if not decoded_string then game.player.print("Failed to decode blueprint string.") return end
	local decoded_blueprint = helpers.json_to_table(decoded_string)
	if not decoded_blueprint then game.player.print("Failed to read blueprint string.") return end
	local blueprint = decoded_blueprint.blueprint

	-- Entitäten prüfen und ersetzen
	if blueprint.entities then
		for _, entity in pairs(blueprint.entities) do
			local replacement = replacements[entity.name]
			if(replacement) then
				entity.name = replacement
				replaced_entities[entity.name] = (replaced_entities[entity.name] or 0) + 1
			end
			if not prototypes.entity[entity.name] then
				missing_entities[entity.name] = true
			end
		end
	end

	if blueprint.tiles then
		for _, tile in pairs(blueprint.tiles) do
			if not prototypes.tile[tile.name] then
				missing_tiles[tile.name] = true
			end
		end
	end

	-- Icons prüfen und ersetzen
	if blueprint.icons then
		for _, icon in pairs(blueprint.icons) do
			if not prototypes.item[icon.signal.name] then
				missing_icons[icon.signal.name] = true
			end
		end
	end
	local report = {
		replaced_entities = {},
		missing_entities = {},
		missing_tiles = {},
		missing_icons = {}
	}
	for key,_ in pairs(replaced_entities) do table.insert(report.replaced_entities, key) end
	for key,_ in pairs(missing_entities) do table.insert(report.missing_entities, key) end
	for key,_ in pairs(missing_tiles) do table.insert(report.missing_tiles, key) end
	for key,_ in pairs(missing_icons) do table.insert(report.missing_icons, key) end

	player.print("report" .. serpent.line(report))

	-- Blueprint wieder kodieren
	--local new_blueprint_string = helpers.encode_string(decoded_blueprint)
	--player.print("Updated blueprint: " .. new_blueprint_string)
	
	if player.gui.screen.blueprint_editor_frame then
		player.gui.screen.blueprint_editor_frame.destroy()
	end
end

-- <ui> -------------------------
local ui = {}

function ui.on_gui_click(event)
	-- Prüfen, ob der richtige Button geklickt wurde
	if event.element.name ~= "process_blueprint_button" then return end
	local player = game.players[event.player_index]
	local frame = player.gui.screen.blueprint_editor_frame

	if frame and frame.blueprint_textbox then
		local blueprint_string = frame.blueprint_textbox.text
		Convert.convert(player, blueprint_string)
	end
end

function ui.on_gui_closed(event)
	if not event.element or event.element.name ~= "blueprint_editor_frame" then return end
	event.element.destroy()
end

function ui.create_blueprint_editor_gui(player)
	if player.gui.screen.blueprint_editor_frame then
		player.gui.screen.blueprint_editor_frame.destroy()
	end

	local frame = player.gui.screen.add { type = "frame", name = "blueprint_editor_frame", caption = "Blueprint Editor", direction = "vertical" }
	frame.auto_center = true

	-- Textbox für den Blueprint-String
	frame.add { type = "text-box", name = "blueprint_textbox", text = "", style = "stretchable_textfield" }.style.minimal_width = 400

	-- Verarbeitungsbutton
	frame.add { type = "button", name = "process_blueprint_button", caption = "Process Blueprint" }

	player.opened = frame
end

Events.on_event(defines.events.on_gui_click, ui.on_gui_click)
Events.on_event(defines.events.on_gui_closed, ui.on_gui_closed)
-- </ui> -------------------------

commands.add_command("convert-blueprint", "Opens the bluprint converter", function(event)
	local player = game.players[event.player_index]
	if not player then return end
	ui.create_blueprint_editor_gui(player)
end)

return Convert