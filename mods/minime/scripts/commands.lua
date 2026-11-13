minime.entered_file()

local minime_commands = {}


------------------------------------------------------------------------------------
--                                Console commands                                --
------------------------------------------------------------------------------------

-- Prepare to uninstall the mod!
minime_commands.uninstall = function(args)
  minime.entered_command(args)

  -- Will be nil if command was issued from server console!
  if args.player_index then
    local player = minime.ascertain_player(args.player_index)
minime.show("player", player)
    if not player.admin then
      player.print({"minime-command-errors.uninstall-not-admin"})
      minime.entered_command({}, "leave", "эту команду могут использовать только администраторы")
      return
    end
  end


  -- All players that are not in god/editor mode should switch to the default
  -- character!
  minime.writeDebugNewBlock("Поиск игроков с персонажем!")
  local passon_flags = {keep_opened = true}
  for p, p_data in pairs(mod.player_data) do
minime.show(p, p_data)

    -- Switch character?
    minime.writeDebugNewBlock("Сменить персонажа игрока %s на персонажа по умолчанию?", {p})
    if p_data.last_character ~= "" and p_data.last_character ~= "character" then
      minime.writeDebug("Да: переключаемся с \"%s\" на \"%s\"!",
                        {p_data.last_character, "character"})
      p_data.last_character = "character"
      minime_character.switch_characters(p, passon_flags)
    else
      minime.writeDebug("No: %s!", {
        p_data.last_character == "" and
          (p_data.god_mode and "режим бога" or "режим редактора") or
          "игрок уже использует персонажа по умолчанию"
      })
    end

    -- Remove player (includes GUI)!
    minime.writeDebugNewBlock("Trying to remove player %s!", {p})
    minime_player.remove_player({player_index = p})
  end

  -- Move all character corpses to default-character corpses
  minime.writeDebugNewBlock("Попытка заменить трупы персонажей трупами персонажа по умолчанию!")
  local default = "character-corpse"
  for char_id, corpses in pairs(mod.minime_corpses) do
minime.show("char_id", char_id)
    for c, c_data in pairs(corpses) do
minime.show(c, c_data)
      -- Replace corpse if a valid corpse still exists, if it is a modded corpse, …
      minime.writeDebugNewBlock("Заменить %s трупом персонажа по умолчанию?",
                                {minime.argprint(c_data.entity)})
      if c_data.entity and c_data.entity.valid and c_data.name ~= default and
          -- … and if it expires never or in the future.
          (not c_data.corpse_expires_on_tick or
            c_data.corpse_expires_on_tick > game.tick) then

        minime.writeDebug("Да!")
        minime_corpse.replace_corpse(c_data, default, c_data.entity)
      else
        minime.writeDebug("Нет: труп %s!", {
          (c_data.entity and c_data.valid and "стандартный") or
          (c_data.entity and "недействителен" or "no")
        })
      end

      minime.writeDebugNewBlock("Remove script inventory?")
      if c_data.inventory and c_data.inventory.valid then
        minime.writeDebug("Да!")
        c_data.inventory.destroy()
      else
        minime.writeDebug("Нет: инвентарь %s!",
                          {c_data.inventory and "недействителен" or "no"})
      end
    end
  end


  -- Remove all preview surfaces!
  minime.writeDebugNewBlock("Removing all preview surfaces!")
  for c_name, c_data in pairs(mod.minime_characters or minime.EMPTY_TAB) do
    minime.writeDebugNewBlock("Remove previews of %s!", {minime.enquote(c_name)})
    if c_data.preview and c_data.preview.surface and
                          c_data.preview.surface.valid then
      minime.writeDebug("Да!")
      minime_surfaces.delete_surface(c_data.preview.surface)
    else
      minime.writeDebug("No: no %s!", {
        (not c_data.preview and "данных предварительного просмотра") or
        (not c_data.preview.surface and "surface") or
        "действительная поверхность"
      })
    end
  end

  -- Remove dummy surface!
  minime.writeDebugNewBlock("Removing dummy surface!")
  minime_surfaces.delete_surface(minime.dummy_surface)

  -- Detach event handlers!
  minime.writeDebugNewBlock("Detaching normal event handlers!")
  minime_events.detach_events()

  minime.writeDebugNewBlock("Looking for optional events!")
  for event_list, e in pairs(mod.optional_events or {}) do
    minime.writeDebug("Отключаем события %s!", {event_list})
    minime_events.detach_events(minime.optional_events[event_list])
  end

  -- Empty storage!
  minime.writeDebugNewBlock("Удаление всех данных из глобальной таблицы 'storage'!")
  storage = {}

  minime.entered_command(args, "leave")
end


-- Add commands
local command, help_text, name
for c_name, c_func in pairs(minime_commands) do
minime.show(c_name, c_func)
  name = c_name:gsub("_", "-")
  command = minime.command_prefix..name
  help_text = {minime.command_prefix.."commands.command-"..command.."-help", name}
minime.show("name", name)
minime.show("command", command)
minime.show("help_text", help_text)

  minime.writeDebug("Добавить команду %s?", {name})
  if not commands.commands[name] then
    minime.writeDebug("Да!")
    commands.add_command(command, help_text, c_func)
  else
    minime.writeDebug("Нет: команда уже существует!")
  end
end


------------------------------------------------------------------------------------
minime.entered_file("leave")
