-- storage.allowAchievements: nil (never set) or true = allowed, false after cheat mode was seen.
-- True Nukes wrote it at file load (a storage write outside events); it is read as "not false" now.
local function allowed()
  return storage.allowAchievements ~= false
end







local function checkAllowAchievements()
  if(allowed())then
    for _,player in pairs(game.players) do
      if(player.cheat_mode) then
        storage.allowAchievements = false;
        game.print("Включён режим читов: достижения True Nukes для этого сохранения отключены.")
      end
    end
  end
end
script.on_event(defines.events.on_console_command, checkAllowAchievements)


local function buildingDamaged(e)
  checkAllowAchievements();
  if(e.force and allowed()) then
    for _,player in pairs(e.force.players) do
      player.unlock_achievement("shoot-fusion")
    end
  end
end

script.on_event(defines.events.on_entity_damaged, buildingDamaged, {{filter="name",name="fusion-test-site"}, {filter="damage-type", mode = "and", type = "physical"}})

local function buildingDied(e)
  checkAllowAchievements();
  if(e.cause and e.cause.type == "character" and e.cause.player and
    allowed() and e.entity.crafting_progress>0 and e.entity.get_recipe().name == "detonation-atomic-2-stage-1Gt-1") then
    e.cause.player.unlock_achievement("stop-1Gt")
  end
end

script.on_event(defines.events.on_entity_died, buildingDied, {{filter="name",name="fusion-test-site"}})

local function buildingMined(e)
  checkAllowAchievements();
  if(allowed() and e.entity.crafting_progress>0 and e.entity.get_recipe().name == "detonation-atomic-2-stage-1Gt-1") then
    game.players[e.player_index].unlock_achievement("stop-1Gt")
  end
end

script.on_event(defines.events.on_pre_player_mined_item, buildingMined, {{filter="name",name="fusion-test-site"}})

local function building_detonated(building, warhead)
  checkAllowAchievements();
  if(building.force and allowed()) then
    local name = warhead.name
    local achievements = {}
    if(name == "-atomic-15kt") then
      table.insert(achievements, "test-15kt")
      -- Paranoidal 9.0.0: 150 hours of play instead of 15 (the build's pace)
      if(game.tick<=60*60*60*150) then
        table.insert(achievements, "15kt-15hrs")
      end
    elseif (name == "-atomic-20t")then
      table.insert(achievements, "test-20t")
    elseif (name == "-atomic-2-stage-1Gt")then
      table.insert(achievements, "detonate-1Gt")
    end
    for _, achievement in pairs(achievements) do
      for _,player in pairs(building.force.players) do
        player.unlock_achievement(achievement)
      end
    end
  end
end

local function nukedEverything(force)
  checkAllowAchievements();
  if(allowed()) then
    for _,p in pairs(force.players) do
      p.unlock_achievement("destroy-everything")
    end
  end
end


local function checkInvForNukes(event)
  local player = game.players[event.player_index]
  if(player.get_main_inventory()) then
  for _,stack in pairs(player.get_main_inventory().get_contents()) do
    local name = stack.name -- 2.x get_contents() is an array of {name, count, quality}
    if(string.match(name, "TN-warhead.*") or string.match(name, ".*-atomic-.*")) then
      player.unlock_achievement("lose-nuke")
      return;
    end
  end
  end
end
script.on_event(defines.events.on_pre_player_died, checkInvForNukes)



return {
  building_detonated = building_detonated,
  checkAllowAchievements = checkAllowAchievements,
  nukedEverything = nukedEverything
}
