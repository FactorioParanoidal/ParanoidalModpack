global.allowAchievements = true







local function checkAllowAchievements()
  if(game.active_mods["space-exploration"]) then
    global.allowAchievements = true
  end
  if(global.allowAchievements)then
    for _,player in pairs(game.players) do
      if(player.cheat_mode and not game.active_mods["space-exploration"]) then
        global.allowAchievements = false;
        game.print("Warning, cheat mode detected - achievements disabled for True-Nukes")
      end
    end
  end
end
script.on_event(defines.events.on_console_command, checkAllowAchievements)


local function buildingDamaged(e)
  checkAllowAchievements();
  if(e.force and global.allowAchievements) then
    for _,player in pairs(e.force.players) do
      player.unlock_achievement("shoot-fusion")
    end
  end
end

script.on_event(defines.events.on_entity_damaged, buildingDamaged, {{filter="name",name="fusion-test-site"}, {filter="damage-type", mode = "and", type = "physical"}})

local function buildingDied(e)
  checkAllowAchievements();
  if(e.cause and e.cause.type == "character" and e.cause.player and
    global.allowAchievements and e.entity.crafting_progress>0 and e.entity.get_recipe().name == "detonation-atomic-2-stage-1Gt-1") then
    e.cause.player.unlock_achievement("stop-1Gt")
  end
end

script.on_event(defines.events.on_entity_died, buildingDied, {{filter="name",name="fusion-test-site"}})

local function buildingMined(e)
  checkAllowAchievements();
  if(global.allowAchievements and e.entity.crafting_progress>0 and e.entity.get_recipe().name == "detonation-atomic-2-stage-1Gt-1") then
    game.players[e.player_index].unlock_achievement("stop-1Gt")
  end
end

script.on_event(defines.events.on_pre_player_mined_item, buildingMined, {{filter="name",name="fusion-test-site"}})

local function building_detonated(building, warhead)
  checkAllowAchievements();
  if(building.force and global.allowAchievements) then
    local name = warhead.name
    local achievements = {}
    if(name == "-atomic-15kt") then
      table.insert(achievements, "test-15kt")
      if(game.tick<=60*60*60*15) then
        table.insert(achievements, "15kt-15hrs")
      end
    elseif (name == "-atomic-20t")then
      table.insert(achievements, "test-20t")
    elseif (name == "-atomic-2-stage-1Gt")then
      table.insert(achievements, "detonate-1Gt")
    elseif (name=="-atomic-500t") then
      for _,f in pairs(game.forces) do
        if(f ~= building.force) then
          if (global.nuclearTests[f.index] and global.nuclearTests[f.index]["test-pack-atomic-500t-1"]) then
            table.insert(achievements, "multi-force-500t")
            for _,p in pairs(f.players) do
              p.unlock_achievement("multi-force-500t")
            end
          end
        end
      end
    end
    for _, achievement in pairs(achievements) do
      for _,player in pairs(building.force.players) do
        player.unlock_achievement(achievement)
      end
    end
  end
end

local function nukedSelf(player)
  checkAllowAchievements();
  if(global.allowAchievements) then
    player.unlock_achievement("nuke-self")
  end
end

local function nukedEverything(force)
  checkAllowAchievements();
  if(global.allowAchievements) then
    for _,p in pairs(force.players) do
      p.unlock_achievement("destroy-everything")
    end
  end
end


local function checkInvForNukes(event)
  local player = game.players[event.player_index]
  if(player.get_main_inventory()) then
  for name,count in pairs(player.get_main_inventory().get_contents()) do
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
  nukedSelf = nukedSelf,
  nukedEverything = nukedEverything
}
