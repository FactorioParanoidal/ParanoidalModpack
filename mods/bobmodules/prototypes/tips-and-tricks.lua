if mods["quality"] then
  data.raw["tips-and-tricks-item"]["quality-probabilities"].simulation = {
    init_update_count = 120,
    init = [[
      player = game.simulation.create_test_player{name = "Quality Manager"}
      player.teleport({-7.5, 0})
      game.simulation.camera_player = player
      game.simulation.camera_position = {0, 0.5}
      game.simulation.camera_alt_info = true
      game.simulation.camera_player_cursor_position = player.position
      game.simulation.hide_cursor = true
      player.character.direction = defines.direction.south

      game.surfaces[1].create_entities_from_blueprint_string
      {
        string = "0eNp9UV9vgyAQ/y73jE2tYjq+ymIM6sVeBocD7WYM331Y13QvLuHl+P09WKE1M46eeAK1AnWOA6j3FQINrM12x9oiKNAhoG0N8ZBZ3d2IMSsgCiDu8RtUHmsByBNNhLvDY1ganm2LPhHEv04CRheS2PGWuRmeLycpYAFVnGTK8djRuMnJO84G1D77uiEaeELN56xNSkwUdt7qDaEJ7d6G+j+7/DIz6/rZPPfYqYnJDfE9tXd+2aWvqRQQJt19gDpHcYDkh8jlECliHdOp9xqp4etXBNzRh8e7XK55eS1kVVWllG8yxh9sPJXs",
        position = {-8, 2}
      }

      show_probabilities = function()

        local quality_prototypes = prototypes.quality
        local quality_levels = {}
        local current_quality = prototypes.quality["normal"];
        while true do
           table.insert(quality_levels, current_quality);
           current_quality = current_quality.next;
           if current_quality == nil then
             break
           end
        end

        local frame = game.players[1].gui.screen.add{type = "frame", caption = {"tips-and-tricks-simulation.quality-calculation"}, direction = "vertical"}
        frame.auto_center = true
        local inner = frame.add{type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical"}
        -- Factorio 2.1: chances from the engine roll (LuaQualityPrototype::get_roll_chances), as in the 2.1 vanilla
        -- simulation; the 2.0 code multiplied the module effect by next_probability of every tier.
        local quality_table = inner.add{type = "table", column_count = table_size(quality_levels) + 1, style = "bordered_table"}
        quality_table.add{type = "label", caption = {"tips-and-tricks-simulation.input"}, style = "bold_label"}

        for k, quality in pairs (quality_levels) do
          quality_table.add{type = "label", caption = {"tips-and-tricks-simulation.chance", "[item=iron-gear-wheel,quality=" .. quality.name .. "]"}, style = "bold_label"}
        end

        local quality_effect = prototypes.item["bob-quality-module-5"].get_module_effects("normal").quality * 6
        local row_header = string.rep("[item=bob-quality-module-5]", 6)
        for k, base_quality in pairs (quality_levels) do
          quality_table.add{type = "label", caption = row_header.. " [item=iron-plate,quality="..base_quality.name.."]"}
          local chances = base_quality.get_roll_chances(quality_effect)
          for j, output_quality in pairs(quality_levels) do
            if chances[output_quality.name] and chances[output_quality.name] > 0 then
              quality_table.add{type = "label", caption = string.format("%.2f%%", chances[output_quality.name] * 100)}
            else
              quality_table.add{type = "label", caption = ""}
            end
          end
        end
      end

      show_probabilities()
    ]],
  }
end
