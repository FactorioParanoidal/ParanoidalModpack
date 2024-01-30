#Modding#

##Mods providing new characters##
"minime" will automatically scale the graphics of any character your mod may provide to the size set by the player in the startup settings. This will work without any action on your part. But you can also make your  character selectable during the game.

Make sure your don't overwrite data.raw.character["character"] immediately -- instead, store it under another name in data.lua, for example like this:

      data.raw.character["my-new-character"] = table.deepcopy(data.raw.character["my-new-character"])
      data.raw.character["my-new-character"].name = "my-new-character-name"

and rename it in data-final-fixes.lua:

    if not mods["minime"] then
      data.raw.character["character"] = data.raw.character["my-new-character"]
      data.raw.character["character"].name = "character"
      data.raw.character["my-new-character"] = nil
    end

Make sure your character's name will be recognized by "minime": characters with the string "skin" (case insensitive) somewhere in their name will be automatically added to the list of selectable characters. For example, I named the character from [I, Robot](https://mods.factorio.com/mod/IRobot) "IRobot_character_skin".

If you don't want to rename your character, use remote calls from control.lua if you want to add it to/remove it from the list of supported characters:

    -- Add a new character to the GUI
    if remote.interfaces["minime"] then
      remote.call('minime', 'register_character', name, loc_name)
      -- name: character.name (string value)
      -- loc_name (optional): character.localised_name, will use the value of "name" if not specified
    end

    -- Remove character from GUI
    if remote.interfaces["minime"] then
      remote.call('minime', 'unregister_character', name)
      -- name: character.name (string value)
    end


If you want to add or remove multiple characters, you should use these versions:

    -- Add several new characters to the GUI at once
    if remote.interfaces["minime"] then
      remote.call('minime', 'register_characters', { {name, loc_name}, {name, loc_name}, … })
      -- name: character.name (string value)
      -- loc_name (optional): character.localised_name, will use the value of "name" if not specified
    end

    -- Remove several characters from GUI at once
    if remote.interfaces["minime"] then
      remote.call('minime', 'unregister_characters', { name, name, … })
      -- name: character.name (string value)
    end

This is more efficient because the GUI will only be updated once, after all characters have been added to/removed from the list.

##Other character selector mods##
There are several mods out there that allow to change the player's character. If you are the author of such a mod, please inform "minime" when a player has used your mod to change to another character!

    -- Use this right *before* you exchange a character, so I can store whatever data I need to store
    if remote.interfaces["minime"] then
      remote.call('minime', 'make_character_backup', player)
      -- player: player.index or player entity
    end

    -- Use this *after* you've exchanged the character, so that I can update the player's GUI
    if remote.interfaces["minime"] then
      remote.call('minime', 'player_changed_character', player)
      -- player: player.index or player entity
    end
