#Modding#

##Mods providing new characters##
"minime" will automatically scale the graphics of any character your mod may provide to the size set by the player in the startup settings. This will work without any action on your part. But you can also make your character selectable during the game.

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

    -- Add one or more new characters to the GUI
    if remote.interfaces.minime and remote.interfaces.minime['register_characters'] then
      remote.call('minime', 'register_characters', name)
      -- name: character.name (string value) or array of character names: {name_1, name_2, …}
    end

    -- Remove one or more characters from the GUI
    if remote.interfaces.minime and remote.interfaces.minime['unregister_characters'] then
      remote.call('minime', 'unregister_characters', name)
      -- name: character.name (string value) or array of character names: {name_1, name_2, …}
    end


##Other character selector mods##
There are several mods out there that allow to change the player's character. If you are the author of such a mod, please inform "minime" when a player has used your mod to change to another character!

    -- Use this right *before* you exchange a character, so I can store whatever data I need to store.
    if remote.interfaces.minime and remote.interfaces.minime['pre_player_changed_character'] then
      remote.call('minime', 'pre_player_changed_character', player)
      -- player: player.index or player entity
    end

    -- Use this *after* you've exchanged the character, so that I can update the player's GUI
    if remote.interfaces.minime and remote.interfaces.minime['player_changed_character'] then
      remote.call('minime', 'player_changed_character', player)
      -- player: player.index or player entity
    end

You'll probably need to act when a character has been exchanged with "minime". In this case, you should listen to an event raised by "minime":

    local player_changed_character = remote.interfaces['minime'] and
                                     remote.interfaces['minime']['get_minime_event_id'] and
                                     remote.call('minime', 'get_minime_event_id')
    if player_changed_character then
      script.on_event(player_changed_character, your_event_handler)
    end
    -- Returns: {player_index = player.index, old_character = old_char, new_character = new_char}
    --          old_character, new_character: character entities

You can also get the list of characters "minime" knows about to complete your own:

    if remote.interfaces.minime and remote.interfaces.minime['get_character_list'] then
      remote.call('minime', 'get_character_list')
      -- Returns: { ["character_name"] = character.localised_name or character.name, … }
    end
