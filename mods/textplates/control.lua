local default_symbol = "blank"
local MOD_NAME = "textplates"
local textplates = require("textplates")

local event_filter = {{filter="type", type="simple-entity-with-force"}}
local event_filter_with_ghosts = {{filter="type", type="simple-entity-with-force"},
                                  {mode="or", filter="ghost_type", type="simple-entity-with-force"}}

-- utility
local function symbol_from_char(char)
  return char and storage.characters_for_symbols[string.lower(char)] or default_symbol
end

-- GUI

local function show_gui(player, plate_type)

    local player_index = player.index
    local selected_type_name = storage.player_selected_type[player_index]

    -- same gui already present
    if selected_type_name and selected_type_name == plate_type.name then
        return
    end

    if player.gui.left.textplates then
        player.gui.left.textplates.destroy()
    end

    -- add the desired plate type UI
    local plate_frame = player.gui.left.add{type = "frame", name = 'textplates', caption = {"textplates.ui-title"}, direction = "vertical"}
    local plates_table = plate_frame.add{type ="table", name = "textplates_table", column_count  = 8, style = "textplates-table"}

    for _, symbol in pairs(plate_type.symbols) do
        local sprite = "item/"..plate_type.name.."-"..symbol
        local name = "textplates-symbol-" .. symbol
        local style = symbol == default_symbol and "textplates-button-active" or "textplates-button"
        plates_table.add{type = "sprite-button", name = name, sprite = sprite, style = style, tooltip = {"textplates.left-pad", {"textplates." .. symbol}}}
    end

    local plates_input_label = plate_frame.add{type ="label", name = "textplates_input_label", caption={"textplates.input-label"}}
    local plates_input_flow = plate_frame.add{type ="flow", name = "plates_input_flow", direction="horizontal"}
    local plates_input = plates_input_flow.add{type ="textfield", name = "textplates_input"}
    -- you can actually click anywhere to exit
    local plates_input_button = plates_input_flow.add{type ="sprite-button", name = "textplates_input_button", tooltip={"textplates.confirm"},
      -- style="edit_label_button", -- size to 28
      sprite="utility/confirm_slot"}
    plates_input_button.style.width = 28
    plates_input_button.style.height = 28

    storage.player_selected_type[player_index] = plate_type.name
    if not storage.player_next_symbol[player_index] then
      storage.player_next_symbol[player_index] = default_symbol
    else
      plates_table["textplates-symbol-blank"].style = "textplates-button"
      if plates_table["textplates-symbol-" .. storage.player_next_symbol[player_index]] then
        plates_table["textplates-symbol-" .. storage.player_next_symbol[player_index]].style = "textplates-button-active"
      end
    end
end

local function hide_gui(player)
    if player.gui.left.textplates then
        player.gui.left.textplates.destroy()
    end
    storage.player_selected_type[player.index] = nil
end


local function on_player_cursor_stack_changed(event)
    local player = game.players[event.player_index]
    if player.cursor_stack and player.cursor_stack.valid and player.cursor_stack.valid_for_read and storage.types[player.cursor_stack.name] then
        show_gui(player, storage.types[player.cursor_stack.name])
    elseif player.cursor_ghost and player.cursor_ghost.name and player.cursor_ghost.name.name and storage.types[player.cursor_ghost.name.name] then
        show_gui(player, storage.types[player.cursor_ghost.name.name])
    else
        hide_gui(player)
    end
end

local function on_gui_click(event)
  local element = event.element
  local name = element.name
  if not name then return end
  local ok, symbol = string.match(name, "^(textplates%-symbol%-)(.*)$")
  if not ok then
      return
  end

  local parent = element.parent
  local player_index = event.player_index
  local next_symbol = storage.player_next_symbol[player_index]

  parent["textplates-symbol-" .. next_symbol].style = "textplates-button"
  element.style = "textplates-button-active"

  storage.player_next_symbol[player_index] = symbol
  parent.parent.plates_input_flow.textplates_input.text = ""
end

local function prepare_next_symbol(player_index, cut)
  local player = game.players[player_index]
  local gui = player.gui.left.textplates

  if gui then
    local next_symbol = storage.player_next_symbol[player_index]

    local name = "textplates-symbol-" .. next_symbol

    local text = gui.plates_input_flow.textplates_input.text
    if cut then
        text = string.sub(text, 2)
        gui.plates_input_flow.textplates_input.text = text
    end
    local first_char = string.sub(text, 1, 1)
    if first_char and first_char ~= "" then
      gui.textplates_table[name].style = "textplates-button"
      next_symbol = symbol_from_char(first_char)
      gui.textplates_table['textplates-symbol-' .. next_symbol].style = "textplates-button-active"
      storage.player_next_symbol[player_index] = next_symbol
    end
  end
end

local function on_gui_text_changed(event)
    if event.element.name == "textplates_input" then
         prepare_next_symbol(event.player_index, false)
    end
end

-- This is missing `event` as a parameter. Would fixing this break other mods?
local function replace_ghost(entity, plate_type, symbol)
    local surface = entity.surface
    local position = entity.position
    local force = entity.force
    entity.destroy()

    local variation = plate_type.symbol_indexes[symbol]

    local new_entity = surface.create_entity{
        name = "entity-ghost",
        inner_name = plate_type.name,
        position = position,
        --variation = variation - 1,
        variation = variation, -- ghosts are offset?
        force = force,
        expires = false,
    }

    if event then
        event.textplates_handled = true
        event.entity = new_entity
        local original_mod = event.mod
        event.mod = MOD_NAME

        script.raise_event(defines.events.on_built_entity, event)

        -- restore, is this needed?
        event.mod = original_mod
        event.textplates_handled = nil
        event.entity = entity
    end

    return new_entity
end

local function check_and_handle_fast_replacement(event)
  local fast_replaced_entity = storage.fast_replaced_entity
  local is_fast_replace = fast_replaced_entity and fast_replaced_entity.tick == event.tick
    and fast_replaced_entity.position.x == event.entity.position.x and fast_replaced_entity.position.y == event.entity.position.y
    and storage.types[event.entity.name]
  if is_fast_replace then
    event.entity.graphics_variation = fast_replaced_entity.graphics_variation
  end
  storage.fast_replaced_entity = nil
  return is_fast_replace
end

local function on_build_ghost(player_index, plate_type, entity, event)
    replace_ghost(entity, plate_type, storage.player_next_symbol[player_index], event)
    prepare_next_symbol(player_index, true)
end

local function on_built_entity (event)
    -- skip calls by ourself or ght-bluebuild
    if event.mod and (event.mod == MOD_NAME or event.mod == "ght-bluebuild" or event.mod == "Nanobots") then return end

    local player_index = event.player_index
    local entity = event.entity
    if not (player_index and entity and entity.valid) then return end

    if check_and_handle_fast_replacement(event) then return end

    local plate_type = storage.types[storage.player_selected_type[player_index]]
    if plate_type then
      if entity.name == "entity-ghost" and entity.ghost_name == plate_type.name then
        return on_build_ghost(player_index, plate_type, entity, event)
      end
      local next_symbol = storage.player_next_symbol[player_index]
      if next_symbol ~= "blank" then -- Do not override graphics_variation on "blank", aka wildcard.
        entity.graphics_variation = plate_type.symbol_indexes[next_symbol]
      end
      prepare_next_symbol(player_index, true)
    end
end

local function on_robot_built_entity(event)
  -- We only handle fast-replacing here. Regular robot building over a ghost will already keep the graphics_variation of the ghost.
  if event.entity.valid then
    check_and_handle_fast_replacement(event)
  end
end

---@param event EventData.on_pre_ghost_upgraded
local function on_pre_ghost_upgraded(event)
  if event.target and storage.types[event.target.name] and event.ghost and event.ghost.graphics_variation then
    replace_ghost(event.ghost, storage.types[event.target.name], storage.types[event.target.name].symbols[event.ghost.graphics_variation])
  end
  -- If there ever is an event added that triggers *after* ghost upgrading, then this is where we could handle fast_replacement just like in on_mined -> on_built,
  -- instead of destroying the ghost and creating a new ghost entity.
  -- Request thread: https://forums.factorio.com/viewtopic.php?f=28&t=108606&p=590189
end

local function on_mined_entity(event)
  -- Keep track of any mined text plate's graphics_variation, in case it is being fast-replaced and we need to apply the graphics_variation to the new text plate.
  if event.entity.valid and storage.types[event.entity.name] then
    storage.fast_replaced_entity = {tick = event.tick, position = event.entity.position, graphics_variation = event.entity.graphics_variation}
  end
end

local function on_player_pipette (event)
  local player = game.players[event.player_index]
  if player and player.connected then
    if player.selected and player.selected.type == "simple-entity-with-force" then
      local plate_type = storage.types[player.selected.name]
      if plate_type then
        local symbol = plate_type.symbols[player.selected.graphics_variation]
        storage.player_next_symbol[event.player_index] = symbol
      end
    elseif player.selected and player.selected.type == "entity-ghost" and ((player.cursor_stack and player.cursor_stack.valid) or (player.cursor_ghost and player.cursor_ghost.valid)) then
      local plate_type = storage.types[player.selected.ghost_name]
      if plate_type then
        local symbol = plate_type.symbols[player.selected.graphics_variation]
        storage.player_next_symbol[event.player_index] = symbol
      end
    end
  end
end

script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
script.on_event(defines.events.on_gui_text_changed, on_gui_text_changed)
script.on_event(defines.events.on_built_entity, on_built_entity, event_filter_with_ghosts)
script.on_event(defines.events.on_robot_built_entity, on_robot_built_entity, event_filter)
script.on_event(defines.events.on_player_pipette, on_player_pipette)
script.on_event(defines.events.on_pre_ghost_upgraded, on_pre_ghost_upgraded)
script.on_event(defines.events.on_player_mined_entity, on_mined_entity, event_filter)
script.on_event(defines.events.on_robot_mined_entity, on_mined_entity, event_filter)

script.on_init(function()

  textplates.build()
  storage.characters_for_symbols = {}
  storage.types = {}
  storage.player_next_symbol = {}
  storage.player_selected_type = {}

  get_textplates_types()
  get_characters_for_symbols()
end)

function get_textplates_types()
  storage.types = {}
  for interface, functions in pairs(remote.interfaces) do
    if functions["textplates_add_types"] then
      local added_types = remote.call(interface, "textplates_add_types")
      for _, type_data in pairs(added_types) do
        if type_data.name and type_data.symbols and #type_data.symbols > 0 then
          if not storage.types[type_data.name] then
            storage.types[type_data.name] = {
              name = type_data.name,
              symbols = {}
            }
          end
          for index, symbol in pairs(type_data.symbols) do
            if not storage.types[type_data.name].symbols[index] or interface == "textplates" then
              storage.types[type_data.name].symbols[index] = symbol
            end
          end
        end
      end
    end
  end
  for _, type in pairs(storage.types) do
    type.symbol_indexes = {}
    for index, symbol in pairs(textplates.symbols) do
      type.symbol_indexes[symbol] = index
    end
  end
  --log( "textplate types:" )
  --log( serpent.block( storage.types, {comment = false, numformat = '%1.8g' } ) )
end

function get_characters_for_symbols()
  storage.characters_for_symbols = {}
  for interface, functions in pairs(remote.interfaces) do
    if functions["textplates_add_characters_for_symbols"] then
      local added_mappings = remote.call(interface, "textplates_add_characters_for_symbols")
      for character, symbol in pairs(added_mappings) do
        if not storage.characters_for_symbols[character] or interface == "textplates" then
          storage.characters_for_symbols[character] = symbol
        end
      end
    end
  end
  --log( "textplate character-symbol mappings:" )
  --log( serpent.block( storage.characters_for_symbols, {comment = false, numformat = '%1.8g' } ) )
end

script.on_configuration_changed(function()
    -- clear storage
    for k,v in pairs(storage) do
      storage[k] = nil
    end

    textplates.build()

    storage.characters_for_symbols = {}
    storage.types = {}
    storage.player_next_symbol = {}
    storage.player_selected_type = {}

    get_textplates_types()
    get_characters_for_symbols()

end)

-- Remote interfaces. Other mods can add these too.
remote.add_interface("textplates", {
  textplates_add_types = function()
    -- return dictionary with type_name = {symbols = {index dictionary or symbols}}
    --[[
    return {
      {
        name = "textplate-large-gold", -- same for entity, item, and item.."-"..symbol items
        symbols = { 1 = "a", 2 = "b", 3 = "c", 80 = "tilde"}
      },
      {
        name = "textplate-huge-gold", -- same for entity, item, and item.."-"..symbol items
        symbols = { 1 = "a", 2 = "b", 3 = "c", 80 = "tilde"}
      },
    }]]--
    return textplates.types
  end,
  textplates_add_characters_for_symbols = function()
    -- return dictionary of caracters and their symbol names
    --return {"~" = "tilde", "¬" = "thingywing"}
    return textplates.symbol_by_char
  end,
})
