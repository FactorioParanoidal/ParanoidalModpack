--~ log("Entered minime control script!")

require("util")
local minime = require("__minime_temp__/common")("minime_temp")

local minime_gui = require("gui")
--~ local minime_gui = minime.minime_character_selector and require("gui")


------------------------------------------------------------------------------------
-- If the mod is added to an existing game, script.on_init() will be run before
-- the migration script, and script.on_configuration_changed will be run after it.
-- We only need to run the initialization once, so we set a flag once that's done.
local game_initialized = false

------------------------------------------------------------------------------------
-- script.on_load() won't call init(), so we set separate flags if events and
-- remote interface have been attached
local events_attached = false
local interface_attached = false

------------------------------------------------------------------------------------
-- Compile list of characters
local function make_character_list()
  local f_name = "make_character_list"
  minime.dprint("Entered function " .. f_name .. "().")

  local chars = game.get_filtered_entity_prototypes({ {filter = "type", type = "character"} })
  minime.dprint("Game characters after get_filtered_entity_prototypes: " .. serpent.block(chars))

  ------------------------------------------------------------------------------------
  -- Initialise list of characters with base character
  global.minime_characters = {
    ["character"] = {"", chars["character"].localised_name or chars["character"].name},
  }

  minime.dprint("global.minime_characters: " .. serpent.block(global.minime_characters))

  for c, char in pairs(chars) do
      if string.find( string.upper(c or ""), minime.pattern ) then
        global.minime_characters[c] = minime.loc_name(char)
        minime.dprint("ADDED character " .. serpent.line(c) .. ".")
      else
        minime.dprint("IGNORED character " .. serpent.line(c) .. ".")
      end
  end

  minime.dprint("End of function " .. f_name .. ".")
end


------------------------------------------------------------------------------------
--                               Switch characters!                               --
------------------------------------------------------------------------------------
local function switch_characters(player, restore)
  local f_name = "switch_characters"
  minime.dprint("Entered function " .. f_name .. "(" .. tostring(player) .. ")")

  player = player and type(player) == "number" and game.players[player] or player

  if not (player and player.valid and player.is_player()) then
    error(serpent.block(player) .. " is not a valid player!")
  end

  -- Only act in default mode and god mode!
  if (player.controller_type == defines.controllers.character or
      player.controller_type == defines.controllers.god) then

    global.player_data[player.index].dummy = global.player_data[player.index].dummy or
                                             minime.make_dummy(player)
    local backup = global.player_data[player.index].dummy

    local old_char = player.character
    local new_char

    -- Does the player have on open character GUI?
    local opened_GUI = player.opened_gui_type

    -- GUI must be of a valid type. These types are not valid
    local invalid_GUI = { [defines.gui_type.item] = true, }

    opened_GUI = invalid_GUI[opened_GUI] and 0 or opened_GUI

    -- We already have a character
    if old_char and old_char.valid then

      -- Restore: Player has already switched characters with another mod,
      --          we just need to restore inventories/settings!
      if restore then
        minime.dprint("Restore mode: not exchanging characters!")
        new_char = old_char

      -- We have to exchange the characters!
      else
        -- Detach old character so we can create the new one
        player.character = nil

        -- Create new character
        player.create_character(global.player_data[player.index].last_character)
        new_char = player.character
        minime.dprint("Created new character " .. serpent.line(minime.loc_name(new_char)) ..
                      " for player " .. serpent.line(player.name))

        -- Copy inventory and settings from old to new character
        minime.copy_character(old_char, new_char)
        minime.dprint("Copied inventories and settings from " .. serpent.line(minime.loc_name(old_char)) ..
                      " to " .. serpent.line(minime.loc_name(new_char)))

        -- Backup inventory and settings from old character
        minime.copy_character(old_char, backup)
        minime.dprint("Copied inventories and settings from " .. serpent.line(minime.loc_name(old_char)) ..
                      " to " .. serpent.line(minime.loc_name(backup)))

        -- Remove old character
        old_char.destroy()
        minime.dprint("Removed old character!")
      end

    -- We don't have a character yet!
    else
      -- Create character
      player.create_character(global.player_data[player.index].last_character)
      new_char = player.character
      minime.dprint("Created new character for player " .. serpent.line(player.name))
    end


    -- Last character may have had a smaller inventory than the current one, and we
    -- may be able to restore them from the backup
    if backup then
      minime.copy_character(backup, new_char)
    end
    minime.dprint("Restored character inventories and settings of character " ..
                  serpent.line(minime.loc_name(new_char)) .. " from backup.")

    -- Open the GUI again if it was closed by exchanging characters
    player.opened = opened_GUI
    minime.dprint("Restored player GUI: " .. player.opened_gui_type)
  end

  minime.dprint("End of function " .. f_name .. "(" .. player.name .. ")")
end


------------------------------------------------------------------------------------
--                              GUI-ACTION DETECTED!                              --
------------------------------------------------------------------------------------
local function on_gui_click(event)
  local f_name = "on_gui_click"
  minime.dprint("Entered function " .. f_name .. " (" .. serpent.line(event) .. ")!")

  local button = event.element.name

  if not minime.prefixed(button, "minime") then
    minime.dprint("Nothing to do -- leaving early!")
    return
  end

  local player = game.players[event.player_index]
  -- Toggle button was clicked
  if button == "minime_toggle_list" then
    minime.dprint(player.name .. " toggled the selection list.")
    minime_gui.gui_toggle(player)

  -- A button from the character list was clicked
  -- --~ elseif minime.prefixed(button, "minime_characters_") then
  -- Prevent changing to empty character for now!
  elseif minime.prefixed(button, "minime_characters_")  and not (button == "minime_characters_") then
    minime.dprint(player.name .. " clicked button " .. serpent.line(button))
    minime_gui.select_character(player, button)
    switch_characters(player)
  end

  minime.dprint("End of function " .. f_name .. " (" .. serpent.line(event) .. ")!")
end



------------------------------------------------------------------------------------
--                                 REMOVE PLAYER!                                 --
------------------------------------------------------------------------------------
local function remove_player(event)
  local f_name = "remove_player"
  minime.dprint("Entered function " .. f_name .. "(" .. serpent.block(event) .. ")")

  -- We only need to act if there are characters to choose from
  if table_size(global.minime_characters) > 1 then
    local p = event.player_index
    local player = global.player_data[p] or {}

    minime_gui.remove_gui(p)
  end
  global.player_data[p] = nil
  minime.dprint("Removed GUI and data of player " .. game.players[p] .. "!")

  minime.dprint("End of function " .. f_name .. "(" .. serpent.block(event) .. ")")
end


------------------------------------------------------------------------------------
--                            INITIALIZE A NEW PLAYER!
-- table: { player = player_arg, remove_character = remove_arg, restore = restore_arg }                    --
-- player_arg:                  player_index (number) OR player (entity)
-- remove_arg (optional):       anything (Will be passed on to init_gui()!)
-- restore_arg (optional):      anything
------------------------------------------------------------------------------------
local function init_player(event)
  local f_name = "init_player"
  minime.dprint("Entered function " .. f_name .. "(" .. serpent.line(event) .. ")")

  if not (event and type(event) == "table") then
    error("Invalid argument: " .. serpent.line(event))
  end

  -- Mandatory argument
  local player = (type(event.player) == "table" and event.player) or
                 (type(event.player) == "number" and game.players[event.player])
  if not (player and player.valid and player.is_player()) then
    error(serpent.line(event) .. " contains no valid player data!")
  end

  -- Only proceed if player is connected!
  if not player.connected then
    minime.dprint("Player " .. player.name .. "(" .. player.index .. ")" ..
                  " is not connected -- nothing to do!")
    return
  else
    minime.dprint("Player " .. player.name .. "(" .. player.index .. ")" ..
                  " is connected -- proceeding with initialization!")
  end

  -- Optional arguments
  local remove_character = event.remove_character
  local restore = event.restore


  minime.dprint("global.minime_characters (" .. table_size(global.minime_characters) .. "):" ..
                serpent.block(global.minime_characters))

  local p = player.index


  -- Initialize player data
  local player_data = global.player_data and global.player_data[p] or {}

  -- Check if the character that was used last still exists in the game, otherwise
  -- fall back to the current character, or to god mode
  player_data.last_character =
      -- The character used last time still exists
      (player_data.last_character and global.minime_characters[player_data.last_character] and
        player_data.last_character) or
      -- The character currently in use (e.g. if minime was loaded into an existing game)
      (player.character and player.character.name) or
      -- The player doesn't have a character (e.g. in god mode) --> empty string!
      ""

  -- If last_character is an unknown character, count it together with the names on the list
  -- when deciding whether to create a GUI.
  local name_cnt = 0
  if not global.minime_characters[player_data.last_character] then
    name_cnt = 1
  end

  player_data.dummy = player_data.dummy or minime.make_dummy(game.players[p])


  -- Copy player_data to global table for long-term storage
  global.player_data[p] = player_data
  minime.dprint("Initialised player_data: " .. serpent.block(global.player_data[p]))

  global.player_data[p].show_character_list = global.player_data[p].show_character_list  or false


  -- Characters could have been deleted from or added the game by mod changes.
  -- So, let's remove an existing GUI!
  minime_gui.remove_gui(p)
  minime.dprint("Removed GUI of player " .. p)

  -- We only want a GUI if there are characters to choose from
  if table_size(global.minime_characters) + name_cnt > 1 then
    minime_gui.init_gui(p, remove_character and true or false)
    minime.dprint("Made GUI for player " .. p)
  else
    minime.dprint("Only " .. tostring(table_size(global.minime_characters) + name_cnt) ..
                  " characters are available -- no GUI is needed!")
  end

  minime.dprint("Current character: " .. serpent.line(player.character and player.character.name) ..
                "\nLast character: " .. serpent.line(player_data.last_character))
  -- If we are not in god mode, and if the character has changed (default), switch
  -- to the stored character! If any value has been passed to init, this will also
  -- call switch_characters(), so we can restore the inventory if we react to a
  -- character change by another mod.
  if (player_data.last_character ~= "") and
     ((player_data.last_character ~= (player.character and player.character.name)) or restore) then

    minime.dprint("Switching characters: " .. tostring(player.character and player.character.name) ..
                  " --> " .. player_data.last_character)
    switch_characters(p, restore and true or false)

    -- Otherwise just make a backup of the current character
  elseif player.character then
    -- Copy inventory and settings from old to new character
    minime.dprint("No need to switch characters, backing up old character!")
    minime.copy_character(player.character, global.player_data[p].dummy)
  end

  minime.dprint("End of function " .. f_name .. "(" .. serpent.line(event) .. ")")
end


------------------------------------------------------------------------------------
--                             INITIALIZE A NEW GAME!                             --
------------------------------------------------------------------------------------
local function init()
  local f_name = "init"
  minime.dprint("Entered function " .. f_name .. "().")

  -- We need to initialize the game only once -- return if init() was already run!
  if game_initialized then
    minime.dprint("Function " .. f_name .. "() has already been run -- nothing to do!")
    return
  end

  ------------------------------------------------------------------------------------
  -- Learned that from eradicator: It basically checks that there are no undefined
  -- global variables
  setmetatable(_ENV,{
    __newindex=function (self,key,value) --locked_global_write
      error('\n\n[ER Global Lock] Forbidden global *write*:\n' ..
          serpent.line{key=key or '<nil>',value=value or '<nil>'} .. '\n')
      end,
    __index   =function (self,key) --locked_global_read
      error('\n\n[ER Global Lock] Forbidden global *read*:\n' ..
          serpent.line{key=key or '<nil>'} .. '\n')
      end
  })
  ------------------------------------------------------------------------------------

  global = global or {}
  global.player_data = global.player_data or {}

  -- The character list will be rebuilt each time, but we need to store it in the
  -- global table so we can access it from gui.lua
  global.minime_characters = {}
  make_character_list()

  -- Create surface for placing dummy characters
  if not game.surfaces[minime.dummy_surface] then
    game.create_surface(minime.dummy_surface, {width = 1, height = 1})
    minime.dprint("Created dummy surface " .. serpent.line(minime.dummy_surface))
  else
    minime.dprint("Dummy surface already exists!")
  end

  -- Initialize players
minime.dprint("Players: " .. serpent.block(game.players[1]))
  for p, player in pairs(game.players) do
minime.dprint("Before calling init_player for " .. player.name )
    init_player({ player = p })
  end

  -- Mark game as initialized,
  game_initialized = true

  minime.dprint("End of function "  .. f_name .. "().")
end


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--                           REGISTER REMOTE INTERFACES!                          --
------------------------------------------------------------------------------------
local function attach_interfaces()
  local f_name = "attach_interfaces"
  log("Entered function " .. f_name .. "().")

  -- Need to attach interfaces
  if interface_attached then
    --~ log("Already attached remote interface -- nothing to do!")
    --~ return
  else
    interface_attached = true

    --~ log("Adding remote interface \"minime\".")
    remote.add_interface('minime', {
      -- Add a new character to the GUI
      -- name: character.name (string value);
      -- loc_name (optional): character.localised_name (defaults to name if not given)
      register_character = function(name, loc_name)
        if not (name and type(name) == "string") then
          error(serpent.line(name) .. " is not a valid name!")
        elseif (loc_name and type(loc_name) ~= "table") then
          error(serpent.line(loc_name) .. " is not a localised name!")
        end
    --~ log("Registering character " .. name)
        global.minime_characters[name] = loc_name or name
        for p, player in pairs(game.players) do
          init_player({ player = player })
        end
      end,


      -- Add several new characters to the GUI (GUI will be rebuilt just once)
      -- table: { {name = name, loc_name = loc_name}, {name = name, loc_name = loc_name}, …}
      -- name: character.name (string value);
      -- loc_name (optional): character.localised_name (defaults to name if not given)
      register_characters = function(table)
        if not table then
          error(serpent.line(table) .. " is not a valid name!")
        end

        for _, char in pairs(table) do
          if not (char.name and type(char.name) == "string") then
            error(serpent.line(char.name) .. " is not a valid name!")
          elseif (char.loc_name and type(char.loc_name) ~= "table") then
            error(serpent.line(char.loc_name) .. " is not a localised name!")
          end
      minime.dprint("Registering character " .. char.name)
          global.minime_characters[char.name] = char.loc_name or char.name
        end

        for p, player in pairs(game.players) do
          init_player({ player = player })
        end
      end,


      -- Remove character from GUI
      -- name: character.name (string value)
      unregister_character = function(name)
        if not (name and type(name) == "string") then
          error(serpent.line(name) .. " is not a valid name!")
        end
    minime.dprint("Removing character " .. name)
        global.minime_characters[name] = nil
        for p, player in pairs(game.players) do
          init_player({ player = player, remove_character = true })
        end
      end,


      -- Remove several characters from GUI (GUI will be rebuilt just once)
      -- table: { name1, name2, …}
      -- name: character.name (string value)
      unregister_characters = function(table)
        if not table then
          error(serpent.line(table) .. " is not a valid name!")
        end

        for _, name in pairs(table) do
          if not (name and type(name) == "string") then
              error(serpent.line(name) .. " is not a valid name!")
          end
          global.minime_characters[name] = nil
        end

        for p, player in pairs(game.players) do
          init_player({ player = player, remove_character = true })
        end
      end,

      -- A player's character will be changed -- make a backup!
      make_character_backup = function(player)
        player = player and type(player) == "number" and game.players[player] or player
        if not (player and player.valid and player.is_player()) then
          error(serpent.line(player) .. " is not a valid player!")
        end

        local char = player.character
        minime.dprint("Make backup of character " .. tostring(char) .. " for player " .. player.name .. "!")

        if char then
          local dummy = global.player_data[player.index].dummy or minime.make_dummy(player.index)
          minime.copy_character(char, dummy)
        end
      end,


      -- A player's character has changed
      player_changed_character = function(player)
        player = player and type(player) == "number" and game.players[player] or player
        if not (player and player.valid and player.is_player()) then
          error(serpent.line(player) .. " is not a valid player!")
        end

        local char = player.character and player.character.name
        minime.dpriint("Player changed character to " .. tostring(char))
        if char and not global.minime_characters[char] then
          global.minime_characters[char] = minime.loc_name(char)
        end
        init_player({ player = player, restore = true })
      end,


      -- Debugging: Dump contents of dummy inventory
      dump = function(player, inventory_list)
        minime.dprint("Entered function dump(" .. serpent.line(player) .. ", " .. serpent.line(inventory_list))
        player = player and type(player) == "number" and game.players[player] or player
        if not (player and player.valid and player.is_player()) then
          error(serpent.line(player) .. " is not a valid player!")
        end
        local inventory_list = inventory_list and (
                                  (type(inventory_list) == "string" and {inventory_list}) or
                                  (type(inventory_list) == "table" and inventory_list)
                               ) or minime.inventory_list

        for i, inventory in pairs(inventory_list) do
          minime.dprint("Inventory " .. serpent.line(inventory) .. ":")
          local inv = defines.inventory["character_" .. inventory]
          local slots = global.player_data[player.index].dummy.get_inventory(inv)
          for x = 1, #slots do
            local test = slots[x].valid_for_read
            minime.dprint(x .. ":\t" .. serpent.line(test and slots[x].name or "NOT VALID FOR READ") ..
                               " (" .. serpent.line(test and slots[x].count or  "NOT VALID FOR READ") .. ")")
          end
        end
        minime.dprint("End of function dump(" .. serpent.line(player) .. ", " .. serpent.line(inventory_list))
      end
    })

    for f, _ in pairs(remote.interfaces["minime"]) do
       --~ log("Added function " .. serpent.line(f) .. " to remote interface \"minime\".")
    end

  end
  log("End of function " .. f_name .. "().")
end


------------------------------------------------------------------------------------
--                          UNREGISTER REMOTE INTERFACES!                         --
------------------------------------------------------------------------------------
local function detach_interfaces()
  local f_name = "detach_interfaces"
  minime.dprint("Entered function " .. f_name .. "().")

  -- Need to attach interfaces
  local del = remote.remove_interface('minime')
  if del then
    local msg = "Removed remote interface!"
    if game then
      minime.dprint(msg)
    elseif del then
      log(msg)
    end
  end

  interface_attached = false

  minime.dprint("End of function " .. f_name .. "().")
end


------------------------------------------------------------------------------------
--                            REGISTER EVENT HANDLERS!                            --
------------------------------------------------------------------------------------
local function attach_events()
  local f_name = "attach_events"
  log("Entered function " .. f_name .. "().")

  if events_attached then
    --~ log("Already attached events -- nothing to do!")
  else
    events_attached = true

    ------------------------------------------------------------------------------------
    -- GUI-related events
    ------------------------------------------------------------------------------------
    -- If a new player joins the game or respawns, initialize GUI and data!
    --~ log("Registering event handlers \"on_player_joined_game\", \"on_player_respawned\"")
    script.on_event({defines.events.on_player_joined_game,
                     defines.events.on_player_respawned}, function(event)
      local f_name = (event.name == defines.events.on_player_joined_game and "on_player_joined_game") or
                     (event.name == defines.events.on_player_respawned and "on_player_respawned")
      minime.dprint("Entered event script: " .. f_name .. " (" .. serpent.line(event) .. ").")

      init_player({ player = event.player_index })

      minime.dprint("End of event script: "  .. f_name .. " (" .. serpent.line(event) .. ").")
    end)

    ------------------------------------------------------------------------------------
    -- Before a player dies, make a backup of the character!
    --~ log("Registering event handlers \"on_pre_player_died\", \"on_pre_player_left_game\"")
    script.on_event({defines.events.on_pre_player_died,
                     defines.events.on_pre_player_left_game}, function(event)
      local f_name = (event.name == defines.events.on_pre_player_died and "on_pre_player_died") or
                     (event.name == defines.events.on_pre_player_left_game and "on_pre_player_left_game")
      minime.dprint("Entered event script: " .. f_name .. " (" .. serpent.line(event) .. ").")

      local p = event.player_index
      local player = game.players[p]

      if player and player.character and global.player_data[p].dummy then
        minime.copy_character(game.players[p].character, global.player_data[p].dummy)
        minime.dprint("Made backup of character for player " .. serpent.line(player.name) .. ".")
      end
      minime.dprint("End of event script: "  .. f_name .. " (" .. serpent.line(event) .. ").")
    end)

    ------------------------------------------------------------------------------------
    -- If a player is removed from the game, remove his GUI and data!
    --~ log("Registering event handler \"on_pre_player_removed\"")
    script.on_event(defines.events.on_pre_player_removed, function(event)
      local f_name = "on_pre_player_removed"
      minime.dprint("Entered event script: " .. f_name .. " (" .. serpent.line(event) .. ").")

        remove_player(event)

      minime.dprint("End of event script: "  .. f_name .. " (" .. serpent.line(event) .. ").")
    end)

    ------------------------------------------------------------------------------------
    -- If a player leaves the game, remove just the GUI!
    --~ log("Registering event handler \"on_player_left_game\"")
    script.on_event(defines.events.on_player_left_game, function(event)
      local f_name = "on_player_left_game"
      minime.dprint("Entered event script: " .. f_name .. " (" .. serpent.line(event) .. ").")

      minime_gui.remove_gui(event)

      minime.dprint("End of event script: "  .. f_name .. " (" .. serpent.line(event) .. ").")
    end)

    ------------------------------------------------------------------------------------
    -- React to GUI clicks
    --~ log("Registering event handler \"on_gui_click\"")
    script.on_event(defines.events.on_gui_click, function(event)
      local f_name = "on_gui_click"
      minime.dprint("Entered event script: " .. f_name .. " (" .. serpent.line(event) .. ").")

      on_gui_click(event)

      minime.dprint("End of event script: "  .. f_name .. " (" .. serpent.line(event) .. ").")
    end)
  end
  log("End of function " .. f_name .. "().")
end


------------------------------------------------------------------------------------
--                           UNREGISTER EVENT HANDLERS!                           --
------------------------------------------------------------------------------------
local function detach_events()
  local f_name = "detach_events"
  minime.dprint("Entered function " .. f_name .. "().")

  local events = {
    "on_player_joined_game",
    "on_player_respawned",
    "on_pre_player_died",
    "on_pre_player_left_game",
    "on_player_left_game",
    "on_gui_click",
  }

  for e, event in ipairs(events) do
    script.on_event(defines.events[event], nil)
    local msg = "Detached event " .. event .. "."
    if game then
      minime.dprint(msg)
    else
      log(msg)
    end
  end

  events_attached = false

  minime.dprint("End of function " .. f_name .. "().")
end

------------------------------------------------------------------------------------
--            Check if we need to attach event handlers and interfaces!           --
------------------------------------------------------------------------------------
local function must_attach()
  local f_name = "must_attach"
  minime.dprint("Entered function " .. f_name .. "()")

  local attach = false
  -- We have access to 'game', so we can poll players directly -- if they exist yet!
  -- In that case, they will have been initialized, so we could just check if they
  -- have a GUI.
  if game then
minime.dprint("We've access to 'game' -- polling players directly!")
    for p, player in pairs(game.players) do
minime.show(player.name, "Player " .. p)
      if player.gui.top["minime_gui"] then
minime.dprint("Player has GUI!")
        attach = true
        break
      end
    end
  end

  -- Players may not exist yet if this was called from on_init or on_cutscene_cancelled,
  -- or this was called from on_load, where we don't have access to 'game'.
  -- Perhaps we can use stored player data?
  if not attach then
    minime.dprint("Using stored player data!")

    -- Check how many characters are registered
    local char_list = {}
    for name, char in pairs(global.minime_characters or {}) do
      char_list[name] = true
    end

    -- Do we have enough already?
    if table_size(char_list) > 1 then
      attach = true
    else
minime.dprint("global.minime_characters: " .. serpent.block(global.minime_characters))
      for p, player in pairs(global.player_data or {}) do
minime.show(player, "Player " .. p)
        if player.last_character then
minime.show(player.last_character, "player.last_character")
          char_list[player.last_character] = true
          if table_size(char_list) > 1 then
minime.dprint("We've " .. table_size(char_list) .. "characters -- attach events!")
            attach = true
            break
          end
        end
      end
    end

minime.show(char_list, "char_list")
  end
minime.show(global.player_data, "global.player_data")

  minime.dprint("Must attach events and interfaces: " .. tostring(attach))
  minime.dprint("End of function " .. f_name .. "()")
  return attach
end

------------------------------------------------------------------------------------
--                    EVENTS RELATED TO STARTING/LOADING A GAME                   --
------------------------------------------------------------------------------------
-- New game
script.on_init(function()
  local f_name = "on_init"
  minime.dprint("Entered script." .. f_name .. "()")

  -- Factorio <1.0.0 has no cutscene, so new games must be initialized in on_init
  if minime.check_mod_version_less("base", "1.0.0") then
    minime.dprint("Factorio version is less than 1.0.0 -- should try to init game!")
    -- Only do stuff if the GUI has been requested
    if minime.minime_character_selector then
      minime.dprint("Character selector is enabled -- will initialize game!")

      init()

      -- Only listen to events if GUI may be needed
      if must_attach() then
        attach_events()
        attach_interfaces()
      -- Single player: Explicitly detach events and interfaces again!
      else
        detach_events()
        detach_interfaces()
      end
    else
      minime.dprint("Character selector is disabled -- check if any players have a GUI.")
      for p, player in pairs(game.players) do
        minime_gui.remove_gui(player)
      end
    end
  else
minime.dprint("Factorio version should start with a cutscene -- delaying initialization!")
  end

  minime.dprint("End of script." .. f_name .. "()")
end)

------------------------------------------------------------------------------------
-- While the cutscene introduced with Factorio 1.0 is running, the player is not
-- connected to a character. So, in factorio 1.0, we'll init the game after the
-- cutscene has finished!
------------------------------------------------------------------------------------
--~ minime.show(minime.check_mod_version_ge("base", "1.0.0"), "minime.check_mod_version_ge(\"base\", \"1.0.0\")")
if minime.check_mod_version_ge("base", "1.0.0") then

  log("Registering event handler \"on_cutscene_cancelled\"")
  script.on_event(defines.events.on_cutscene_cancelled, function()
    local f_name = "on_cutscene_cancelled"
    minime.dprint("Entered event script: " .. f_name .. " ().")

    -- In vanilla Factorio, the cutscene runs only once. Mods may introduce more cut-
    -- scenes, though, so we want to make sure this code won't be run repeatedly!
    if not global.cutscene_cancelled then
      global.cutscene_cancelled = true
      -- Only do stuff if the GUI has been requested
      if minime.minime_character_selector then
        minime.dprint("Character selector is enabled -- trying to initialize game!")

        init()
        -- Only listen to events if GUI may be needed.
        --~ if table_size(global.minime_characters) > 1 then
        if must_attach() then
          minime.dprint("Will attach event handlers and interfaces!")
          attach_events()
          attach_interfaces()
        -- Explicitly detach events and interfaces again!
        else
          detach_events()
          detach_interfaces()
          minime.dprint("Won't attach event handlers and interfaces!")
        end

      else
        minime.dprint("Character selector is disabled -- check if any players have a GUI.")
        for p, player in pairs(game.players) do
          minime_gui.remove_gui(player)
        end
      end
    end
    minime.dprint("End of event script: "  .. f_name .. " ().")
  end)
  log("Done.")
end

--------------------------------------------------------------------------------------------
-- Configuration changed
script.on_configuration_changed(function(event)
  local f_name = "on_configuration_changed"
  minime.dprint("Entered script." .. f_name .. "(" .. serpent.line(event) .. ")")

  -- Check if GUI setting has been changed.
  if event.mod_startup_settings_changed then
    minime.minime_character_selector = settings.startup["minime_character-selector"].value
    minime.dprint("Re-read startup setting. User has " ..
                  tostring(minime.minime_character_selector and "requested" or "not requested") .. " a GUI.")
  end

  if minime.minime_character_selector then
    minime.dprint("Character selector is enabled -- trying to initialize the game!")
    init()

    minime.dprint("Check if we need to attach events and interfaces!")


    -- Attach events and interfaces only if more characters than one are available!
    if must_attach() then
      minime.dprint("Attaching event handlers and interfaces!")
      attach_events()
      attach_interfaces()
    -- Explicitly detach events and interfaces again! (Doing this in multiplayer will desync!)
    elseif not game.is_multiplayer() then
      detach_events()
      detach_interfaces()
    end
  -- Check if players already have a GUI
  else
    minime.dprint("Character selector is disabled -- check if any players have a GUI.")
    for p, player in pairs(game.players) do
      minime_gui.remove_gui(player)
      --~ if player.gui.top.minime_gui then
        --~ minime.dprint("Player " .. player.name .. " (" .. p .. ") has a GUI!")
        --~ player.gui.top.minime_gui.destroy()
        --~ minime.dprint("Removed GUI of player " .. p)
      --~ end
    end
    minime.dprint("Done!")
  end

  minime.dprint("End of script." .. f_name .. "(" .. serpent.line(event) .. ")")
end)


--------------------------------------------------------------------------------------------
-- Loaded existing game
script.on_load(function()
  --~ log("Entered script.on_load()")

  if minime.minime_character_selector and must_attach() then
    attach_events()
    attach_interfaces()
  -- Explicitly detach events and interfaces again!
  else
    detach_events()
    detach_interfaces()
  end

  --~ log("End of script.on_load()")
end)
