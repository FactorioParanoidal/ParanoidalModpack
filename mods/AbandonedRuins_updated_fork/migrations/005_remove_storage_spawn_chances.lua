-- Removes spawn changes entirely from storage (persisted)
if storage.spawn_chances then
  storage.spawn_chances = nil
end
