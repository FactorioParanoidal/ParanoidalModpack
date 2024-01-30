require ("util")
local AnimationDB = require('__erm_zerg_hd_assets__/animation_db')

local ENTITYPATH = NE_Common.zentitypath_unit
local shadow_tint = { r = 0, g = 0, b = 0, a = 192 }

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  ---- devourer  - Breeder_Units
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  --- Attack
  function zerg_devourer_attackanimation(name, scale, tint1)
    local animation =  AnimationDB.get_layered_animations('units', 'devourer', 'attack', scale / 2)
    tint1 = util.table.deepcopy(tint1)
    tint1.a = tint1.a * 0.5
    tint1.r = tint1.r * 0.5
    tint1.g = tint1.g * 0.5
    tint1.b = tint1.b * 0.5
    animation = AnimationDB.alter_team_color(animation, tint1)
    return animation
  end

  --- Run
  function zerg_devourer_runanimation(name, scale, tint1)
    local animation =  AnimationDB.get_layered_animations('units', 'devourer', 'run', scale / 2)
    tint1 = util.table.deepcopy(tint1)
    tint1.a = tint1.a * 0.5
    tint1.r = tint1.r * 0.5
    tint1.g = tint1.g * 0.5
    tint1.b = tint1.b * 0.5
    animation = AnimationDB.alter_team_color(animation, tint1)
    return animation
  end
  
  
--- DIE
function zerg_devourer_dieanimation(name, scale, tint1)
  local animation =  AnimationDB.get_single_animation('units', 'devourer', 'corpse', 'main', scale / 2.2)
  return animation
end


  

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  ---- hydralisk  - Fire_Units
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  --- Attack
  function zerg_hydralisk_attackanimation(name, scale, tint1)
    local animation =  AnimationDB.get_layered_animations('units', 'hydralisk', 'attack', scale)
    tint1 = util.table.deepcopy(tint1)
    tint1.a = tint1.a * 0.5
    tint1.r = tint1.r * 0.5
    tint1.g = tint1.g * 0.5
    tint1.b = tint1.b * 0.5
    animation = AnimationDB.alter_team_color(animation, tint1)
    return animation
  end

  --- Run
  function zerg_hydralisk_runanimation(name, scale, tint1)
    local animation =  AnimationDB.get_layered_animations('units', 'hydralisk', 'run', scale)
    tint1 = util.table.deepcopy(tint1)
    tint1.a = tint1.a * 0.5
    tint1.r = tint1.r * 0.5
    tint1.g = tint1.g * 0.5
    tint1.b = tint1.b * 0.5
    animation = AnimationDB.alter_team_color(animation, tint1)
    return animation
  end
  
  --- DIE
  function zerg_hydralisk_dieanimation(name, scale, tint1)
    local animation =  AnimationDB.get_single_animation('units', 'hydralisk', 'corpse', 'main', scale)
    return animation
  end



  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  ---- overlord  - Mine Spitter (Pink)
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  --- Attack
  function zerg_overlord_attackanimation(name, scale, tint1)
    local animation = AnimationDB.get_layered_animations('units', 'overlord', 'run', scale / 2)
    tint1 = util.table.deepcopy(tint1)
    tint1.a = tint1.a * 0.5
    tint1.r = tint1.r * 0.5
    tint1.g = tint1.g * 0.5
    tint1.b = tint1.b * 0.5
    animation = AnimationDB.alter_team_color(animation, tint1)
    return animation
  end

  --- Run
  function zerg_overlord_runanimation(name, scale, tint1)
    local animation =  AnimationDB.get_layered_animations('units', 'overlord', 'run', scale / 2)
    tint1 = util.table.deepcopy(tint1)
    tint1.a = tint1.a * 0.5
    tint1.r = tint1.r * 0.5
    tint1.g = tint1.g * 0.5
    tint1.b = tint1.b * 0.5
    animation = AnimationDB.alter_team_color(animation, tint1)
    return animation
  end
  
  --- DIE
  function zerg_overlord_dieanimation(name, scale, tint1)
    local animation =  AnimationDB.get_single_animation('units', 'overlord', 'corpse', 'main', scale / 2)
    return animation
  end


    ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  ---- queen  - Unit Launcher Spitter (Green)
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  --- Attack
  function zerg_queen_attackanimation(name, scale, tint1)
      local animation =  AnimationDB.get_layered_animations('units', 'queen', 'attack', scale / 2)
      tint1 = util.table.deepcopy(tint1)
      tint1.a = tint1.a * 0.5
      tint1.r = tint1.r * 0.5
      tint1.g = tint1.g * 0.5
      tint1.b = tint1.b * 0.5
      animation = AnimationDB.alter_team_color(animation, tint1)
      return animation
  end

  --- Run
  function zerg_queen_runanimation(name, scale, tint1, tint2)
    local animation =  AnimationDB.get_layered_animations('units', 'queen', 'run', scale / 2)
    tint1 = util.table.deepcopy(tint1)
    tint1.a = tint1.a * 0.5
    tint1.r = tint1.r * 0.5
    tint1.g = tint1.g * 0.5
    tint1.b = tint1.b * 0.5
    animation = AnimationDB.alter_team_color(animation, tint1)
    return animation
  end
  
  --- DIE
  function zerg_queen_dieanimation(name, scale, tint1)
    local animation =  AnimationDB.get_single_animation('units', 'queen', 'corpse', 'main', scale / 2)
    return animation
  end