local function get_all_player_xp()
  local personalxp = storage.personalxp
  if type(personalxp) ~= "table" or type(personalxp.XP) ~= "table" then return nil end

  local result = {}
  for player_name, xp in pairs(personalxp.XP) do
    result[player_name] = xp
  end
  return result
end

remote.add_interface("RPGsystemMigration", {
  get_all_player_xp = get_all_player_xp,
})
