require ("util")
local AnimationDB = require('__erm_zerg_hd_assets__/animation_db')

local ENTITYPATH = NE_Common.zentitypath_unit
local shadow_tint = { r = 0, g = 0, b = 0, a = 192 }


  ---- broodling - Breeder Biter (Spwans Units on Death) 
  --- Attack
function zerg_broodling_attackanimation(name, scale, tint1)
  local animation = AnimationDB.get_layered_animations('units', 'broodling', 'attack', scale)
      --- Apply 50% alpha strength, alpha 0 = blend_mode: additive
      --- I also multiply RGB by 0.5 as well to prevent the tint to look like neon light. But that's up to you.
      tint1 = util.table.deepcopy(tint1)
      tint1.a = tint1.a * 0.5
      tint1.r = tint1.r * 0.5
      tint1.g = tint1.g * 0.5
      tint1.b = tint1.b * 0.5
      --- This is the function call to tint a unit. Here is the link to the function https://github.com/heyqule/erm_libs/blob/main/prototypes/animation_db.lua#L133C36-L133C36
      animation = AnimationDB.alter_team_color(animation, tint1)

      --- This will disable the team color mask if you prefer original white.
      ---  animation = AnimationDB.alter_team_color(animation, nil, true)

      --- This change the blend_mode to "additive-soft".
      --- animation = AnimationDB.alter_team_color(animation, nil, true, true)

      --- If you find the animation is too slow, you can adjust with the following function.
      --- animation = AnimationDB.change_animation_speed(animation, 1)
      ---
      --- AnimationDB use 24 frames / s for most things and 12f/s for some death animations.
      --- 1 = 60fps, 0.5 = 30fps, 0.4 = 24fps, 0.2 = 12fps
      --- another way to adjust running animation speed is by distance_per_frame in unit prototype
      --- In my mods, I usually use distance_per_frame = 0.16 for 24fps


      --- For other adjustments, you can adjust the animation table directly
      --- animation['property_name'] = something
      ---
      --- use this to view the table structure
      --- log(serpent.block(animation))
  return animation
end

--- Run
function zerg_broodling_runanimation(name, scale, tint1)
    local animation = AnimationDB.get_layered_animations('units', 'broodling', 'run', scale)
    tint1 = util.table.deepcopy(tint1)
    tint1.a = tint1.a * 0.5
    tint1.r = tint1.r * 0.5
    tint1.g = tint1.g * 0.5
    tint1.b = tint1.b * 0.5
    animation = AnimationDB.alter_team_color(animation, tint1)
    return animation
end


--- DIE
function zerg_broodling_dieanimation(name, scale, tint1)
    --- Subtype for corpse animation are usually "main". when you use scale, you can do one of the following
    --- single_animation usually can't be tint.
    --- AnimationDB.get_single_animation('units', 'broodling', 'corpse', 'main', 2)
    --- AnimationDB.get_single_animation('units', 'broodling', 'corpse', nil, 2)
   local animation = AnimationDB.get_single_animation('units', 'broodling', 'corpse', 'main', scale)
    return animation
end

  

  ---- defiler
--- Attack
function zerg_defiler_attackanimation(name, scale, tint1)
      local animation = AnimationDB.get_layered_animations('units', 'defiler', 'run', scale)
      tint1 = util.table.deepcopy(tint1)
      tint1.a = tint1.a * 0.5
      tint1.r = tint1.r * 0.5
      tint1.g = tint1.g * 0.5
      tint1.b = tint1.b * 0.5
      animation = AnimationDB.alter_team_color(animation, tint1)
      return animation
end

  --- Run
function zerg_defiler_runanimation(name, scale, tint1)
      local animation = AnimationDB.get_layered_animations('units', 'defiler', 'run', scale)
      tint1 = util.table.deepcopy(tint1)
      tint1.a = tint1.a * 0.5
      tint1.r = tint1.r * 0.5
      tint1.g = tint1.g * 0.5
      tint1.b = tint1.b * 0.5
      animation = AnimationDB.alter_team_color(animation, tint1)
      return animation
end
  

  ---- devourer
  --- Attack
function zerg_devourer_attackanimation(name, scale, tint1)
      local animation =AnimationDB.get_layered_animations('units', 'devourer', 'attack')
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
      local animation = AnimationDB.get_layered_animations('units', 'devourer', 'run')
      tint1 = util.table.deepcopy(tint1)
      tint1.a = tint1.a * 0.5
      tint1.r = tint1.r * 0.5
      tint1.g = tint1.g * 0.5
      tint1.b = tint1.b * 0.5
      animation = AnimationDB.alter_team_color(animation, tint1)
      return animation
end
  

  
  ---- ultralisk (Tank)
  --- Attack
function zerg_ultralisk_attackanimation(name, scale, tint1)
      local animation = AnimationDB.get_layered_animations('units', 'ultralisk', 'attack', scale / 2)
      tint1 = util.table.deepcopy(tint1)
      tint1.a = tint1.a * 0.5
      tint1.r = tint1.r * 0.5
      tint1.g = tint1.g * 0.5
      tint1.b = tint1.b * 0.5
      animation = AnimationDB.alter_team_color(animation, tint1)
      return animation
end

  --- Run
function zerg_ultralisk_runanimation(name, scale, tint1)
      local animation = AnimationDB.get_layered_animations('units', 'ultralisk', 'run', scale / 2)
      tint1 = util.table.deepcopy(tint1)
      tint1.a = tint1.a * 0.5
      tint1.r = tint1.r * 0.5
      tint1.g = tint1.g * 0.5
      tint1.b = tint1.b * 0.5
      animation = AnimationDB.alter_team_color(animation, tint1)
      return animation
end

  --- DIE
function zerg_ultralisk_dieanimation(name, scale, tint1)
      local animation = AnimationDB.get_single_animation('units', 'ultralisk', 'corpse',  'main', scale / 2)
      return animation
end

  