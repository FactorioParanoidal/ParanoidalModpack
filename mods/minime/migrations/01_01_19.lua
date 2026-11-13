minime.entered_file()

------------------------------------------------------------------------------------
--                   Preview characters overlap if scaled >300%.                  --
-- Remove preview characters from the preview surfaces, so they will be recreated --
-- with wider gaps! (game.delete_surface() doesn't work because the surface will  --
-- be removed on a future tick. It still exists while on_configuration_changed is --
-- running, but it won't exist anymore when the game has been initialized, so the --
-- GUI will show just the buttons, not the preview characters!                    --
------------------------------------------------------------------------------------
minime.show("minime.preview_surface_name_prefix", minime.preview_surface_name_prefix)
--~ local chars

local removed_previews
for s, surface in pairs(game.surfaces) do
minime.show(surface.name.." соответствует шаблону minime%%-preview%%-.+", surface.name:match("minime%-preview%-.+"))
minime.show(surface.name.." matches "..minime.preview_surface_name_prefix,
            surface.name:match(minime.preview_surface_name_prefix))
  removed_previews = 0
  if surface.name:match("minime%-preview%-.+") or
      surface.name:match(minime.preview_surface_name_prefix) then

    minime.writeDebug("Ищу персонажей для предварительного просмотра на %s!",
                      {minime.argprint(surface)})
    for e, entity in pairs(surface.find_entities()) do
      if entity.valid then
minime.writeDebug("Уничтожаю %s!", minime.argprint(entity))
        entity.destroy()
        removed_previews = removed_previews + 1
      end
    end
    minime.writeDebug("Удалено персонажей preview_characters: %s.", {removed_previews})
  end
end


-- Put up a flag indicating that we must rebuild the preview characters when
-- on_configuration_changed is run!
storage.rebuild_preview_characters = true

------------------------------------------------------------------------------------
--  There could still be an obsolete surface for the dummy characters. Remove it! --
------------------------------------------------------------------------------------
local old_dummy_surface = game.surfaces["dummy_dungeon"]
if old_dummy_surface and old_dummy_surface.valid then
  minime.writeDebug("Удаляю устаревшую поверхность %s!", {minime.argprint(old_dummy_surface)})

  -- Set flag so that we'll ignore on_surface_deleted and don't restore things!
  storage.deleted_surfaces = storage.deleted_surfaces or {}
  storage.deleted_surfaces[old_dummy_surface.index] = old_dummy_surface.name

  game.delete_surface(old_dummy_surface)
end

minime.entered_file("leave")
