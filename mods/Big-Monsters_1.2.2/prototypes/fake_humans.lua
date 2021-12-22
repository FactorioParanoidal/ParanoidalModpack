--[[
	 * * * FAKE HUMAN PROTOTYPES * * * 
								by MFerrari 

v 1.61 10/07/2021 - hidden from bonus gui
]]
local sounds = require("__base__/prototypes/entity/sounds.lua")
require "utils"

if not data.raw.unit.tc_fake_human_machine_gunner then 


local hp_multiplier = settings.startup["bm-enemy-hp-multiplier"].value 
local dmg_multiplier = settings.startup["bm-enemy-damage-multiplier"].value 
local base_name = 'tc_fake_human_'


local yellow = {r = 0.9, g = 0.9, b = 0}
local red = {r = 1, g = 0.5, b = 0.5}
local character = util.copy(data.raw.character.character)

local human_corpse = table.deepcopy(data.raw["character-corpse"]["character-corpse"])
--human_corpse.type = "corpse"
human_corpse.selectable_in_game = false
human_corpse.selection_box = nil
human_corpse.render_layer = "remnants"
human_corpse.armor_picture_mapping = nil
human_corpse.subgroup="corpses"
human_corpse.pictures = {
        layers =
        {
              {
      filename = "__base__/graphics/entity/character/level1_dead.png",
      width = 58,
      height = 58,
      shift = util.by_pixel(-7.0,-5.0),
      frame_count = 2,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_dead.png",
        width = 114,
        height = 112,
        shift = util.by_pixel(-7.0,-5.5),
        frame_count = 2,
        scale = 0.5
      },
		}}}


-- sniper beam
local beam_base = util.copy(data.raw.beam["laser-beam"])
beam_base.damage_interval = 60*5
beam_base.action=nil
beam_base.working_sound=nil
beam_base.random_target_offset = true
beam_base.name =  'sniper-beam'	
hack_tint(beam_base, colors.yellow)
hack_scale(beam_base, 0.5)
data:extend{beam_base}


local function make_beam_attack(damage_modifier,beam)
 return   {
      type = "beam",
      cooldown = 20, --40
      range = 15 + damage_modifier/2 ,
      source_direction_count = 64,
      source_offset = {0, -3.423489 / 4},
      damage_modifier = damage_modifier * dmg_multiplier,
      ammo_type =
      {
        category = "laser",
        energy_consumption = "1000kJ",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "beam",
            beam = beam,
            max_length = 16+ damage_modifier/2,
            duration = 20, --30
            source_offset = {0, -1}
          }
        }
      }
    }
end


local sound_melee={
  {
    filename = "__base__/sound/walking/sand-01.ogg",
    volume = 1
  },
  {
    filename = "__base__/sound/walking/dirt-1-03.ogg",
    volume = 1
  },
  {
    filename = "__base__/sound/walking/dirt-02.ogg",
    volume = 1
  },  {
    filename = "__base__/sound/walking/concrete-02.ogg",
    volume = 1
  },

}

local sound_gun={
  {
    filename = "__base__/sound/fight/gun-turret-gunshot-01.ogg",
    volume = 0.4
  },
  {
    filename = "__base__/sound/fight/gun-turret-gunshot-02.ogg",
    volume = 0.4
  },
  {
    filename = "__base__/sound/fight/gun-turret-gunshot-03.ogg",
    volume = 0.4
  },
  {
    filename = "__base__/sound/fight/gun-turret-gunshot-04.ogg",
    volume = 0.4
  }
}

local sound_sniper={
  {
    filename = "__base__/sound/fight/gun-turret-gunshot-01.ogg",
    volume = 1
  },
  {
    filename = "__base__/sound/fight/gun-turret-gunshot-02.ogg",
    volume = 1
  },
  {
    filename = "__base__/sound/fight/gun-turret-gunshot-03.ogg",
    volume = 1
  },
  {
    filename = "__base__/sound/fight/gun-turret-gunshot-04.ogg",
    volume = 1
  }
}




local function make_sniper_attack(damage,range,cooldown,beam)
 return   {
      type = "projectile",
	  sound = sound_sniper,
--	  data.raw["ammo-turret"]["gun-turret"].attack_parameters.sound,
      cooldown = cooldown, 
      range = range,
      source_direction_count = 64,
      source_offset = {0, -3.423489 / 4},
      damage_modifier = 1,
      ammo_type =
      {
        category = "bullet",
        --energy_consumption = "1000kJ",
		target_type = "entity",
        action =
        {
          type = "direct",
          action_delivery =
          {
            {
              type = "instant",
				source_effects =
				{
				type = "create-explosion",
				entity_name = "explosion-gunshot-small"
				},			  
              target_effects =
              {
              {
                type = "create-entity",
                entity_name = "explosion-hit"
              },			  
                {
                  type = "damage",
                  damage = {amount = damage * dmg_multiplier, type = "physical"}
                }
              }
            },		  
		   {
            type = "beam",
            beam = beam,
            max_length = range,
            duration = 10, --30
            source_offset = {0, -1.31439 },
			target_offset = {0, -4}
           }
		  }
        }
      }
    }
end





-- cool 90 range 25   "explosive-cannon-projectile",
local function make_cannon_attack(projectile,damage_modifier,range,cooldown)
 return   {
      type = "projectile",
	  sound = sounds.tank_gunshot,
      cooldown = cooldown, 
      range = range,
	  flags = {"not-on-map"},
	  ammo_category = "cannon-shell",
      warmup = 10,
	  min_range = 10,
	  damage_modifier = damage_modifier,
      ammo_type =
      {
        category = "cannon-shell",
        target_type = "entity",
        action =
        {
          type = "direct",
          action_delivery =
          {
            {
          type = "projectile",
          projectile = projectile,
          starting_speed = 1,
		  source_offset = {0, -10},
          source_effects =
          {
            type = "create-entity",
            entity_name = "explosion-hit",
          },
            }
          }
        }
      },
    }

end







local function make_smg_attack(damage,range,cooldown)
return   {
      type = "projectile",
	  sound = sound_gun,
      ammo_category = "bullet",
      warmup = 10,
      cooldown = cooldown,
      range = range,
      ammo_type =
      {
        category = "bullet",
        target_type = "entity",
        action =
        {
          type = "direct",
          action_delivery =
          {
            {
              type = "instant",
				source_effects =
				{
				type = "create-explosion",
				entity_name = "explosion-gunshot-small"
				},			  
              target_effects =
              {
              {
                type = "create-entity",
                entity_name = "explosion-hit"
              },			  
                {
                  type = "damage",
                  damage = {amount = damage *dmg_multiplier, type = "physical"}
                }
              }
            }
          }
        }
      },
    }
end



local function make_rocket_attack(damage_modifier,range,cooldown,projectile,min_range)
return   {
      type = "projectile",
      ammo_category = "rocket",
      warmup = 20,
      cooldown = cooldown,
      range = range,
	  min_range = min_range,
	  damage_modifier = damage_modifier,
      ammo_type =
      {
        category = "rocket",
        target_type = "entity",
        action =
        {
          type = "direct",
          action_delivery =
          {
            {
          type = "projectile",
          projectile = projectile,
          starting_speed = 0.1,
		  source_offset = {0, -5},
          source_effects =
          {
            type = "create-entity",
            entity_name = "explosion-hit",
          },
            }
          }
        }
      },
    }
end


local function make_grenade_attack(damage_modifier,range,cooldown,projectile,min_range)
return   {
      type = "projectile",
      ammo_category = "grenade",
      warmup = 20,
      cooldown = cooldown,
      range = range,
	  min_range = min_range,
	  damage_modifier = damage_modifier,
	  projectile_creation_distance = 0.6,	  
      ammo_type =
      {
         category = "grenade",
         target_type = "position",
		 activation_type = "throw",
          action =
          {
            {
              type = "direct",
              action_delivery =
              {
                type = "projectile",
                projectile = projectile,
                starting_speed = 0.3
              }
            },
            {
              type = "direct",
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "play-sound",
                    sound = sounds.throw_projectile
                  }
                }
              }
            }
          }
      }
    }
end


local function make_melee_attack(damage)
 return   {
      type = "projectile",
      damage_modifier = dmg_multiplier,
      range = 0.5,
      cooldown = 40,
      ammo_category = "melee",
      ammo_type = make_unit_melee_ammo_type(damage),
	  sound = sound_melee,  
    }
end

function create_fake_human(surname,level,armor, set_color, scale,attack_parameters, hp_mp )
local color = table.deepcopy(set_color)
if not hp_mp then hp_mp=1 end
local att_anim = table.deepcopy(character.animations[armor].idle_with_gun)
if attack_parameters.ammo_category and attack_parameters.ammo_category == "melee" then 
	att_anim = table.deepcopy(character.animations[armor].mining_with_tool) end

local name = base_name..surname
  local fake_human = table.deepcopy(data.raw.unit["medium-biter"])
  fake_human.flags = {"hidden", "placeable-player", "placeable-enemy", "placeable-off-grid", "breaths-air", "not-repairable"}
  fake_human.name=name..'_'..level
  fake_human.localised_name = {"",{"entity-name.fake_human_" ..surname},' '..level}
  fake_human.selection_box = scale_box(table.deepcopy(character.selection_box),scale)
  fake_human.sticker_box   = scale_box(table.deepcopy(character.sticker_box),scale)
	fake_human.icon = path.. "graphics/fake_human.png"
	fake_human.icon_size = 64
    fake_human.icon_mipmaps = 4 

  fake_human.map_color = color
  fake_human.enemy_map_color = {r = 1}
  fake_human.max_health = 200*level*hp_mp*hp_multiplier
  fake_human.resistances = {}
 --fake_human.move_while_shooting = true  --- se ativar ele foge do alvo -flee
  fake_human.affected_by_tiles = true
  fake_human.can_open_gates = true
  fake_human.attack_parameters = attack_parameters
  fake_human.attack_parameters.animation = att_anim
  fake_human.run_animation = table.deepcopy(character.animations[armor].running)
  fake_human.pollution_to_join_attack = 10 + level * 10
  fake_human.corpse = fake_human.name.."-corpse"
  fake_human.has_belt_immunity = true
  fake_human.rotation_speed = 0.05
  fake_human.vision_distance = 100
  fake_human.movement_speed = 0.05 + level/100
 -- fake_human.dying_sound = nil
  fake_human.working_sound = nil 
  fake_human.destroy_when_commands_fail = false
  fake_human.hide_resistances = false
  fake_human.ai_settings = {destroy_when_commands_fail = true}
  
  hack_tint(fake_human, color, true)
  if scale ~= 1 then hack_scale(fake_human, scale) end

  fake_human.light =
    {
      {
        minimum_darkness = 0.3,
        intensity = 0.4,
        size = 15,
        color = {r=1.0, g=1.0, b=1.0}
      },
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "extra-high",
          flags = { "light" },
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {0, -7},
        size = 1,
        intensity = 0.6,
        color = {r=1.0, g=1.0, b=1.0}
      }
    }
    fake_human.running_sound_animation_positions = {5, 16}
    fake_human.walking_sound = {
      aggregation =
      {
        max_count = 2,
        remove = true
      },
      variations = data.raw.tile["sand-1"].walking_sound
    }


-- tint


  local corpse = table.deepcopy(human_corpse)
  corpse.name = fake_human.name.."-corpse"
  corpse.order = "zzz-"..name
  hack_scale(corpse, scale) --1+ scale/2)
  hack_tint(corpse, color, true)


  data:extend
  {
    fake_human,
    corpse
  }

--if not string.find(surname, "boss") then 
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[fake_human.name], level) 

end


for k=1,10 do 
local armor = 1
if k>=7 then armor = 3 elseif k>=4 then armor = 2 end
local scale=1
create_fake_human('melee',k,armor,colors.white,scale,make_melee_attack(5+k*2)) -- damage
create_fake_human('machine_gunner',k,armor,colors.brown,scale,make_smg_attack(8+k*2,20+k,2)) -- damage,range,cooldown
create_fake_human('pistol_gunner',k,armor,colors.yellow,scale,make_smg_attack(8+k*2,20+k,20-k/2)) -- damage,range,cooldown
create_fake_human('sniper',k,armor,colors.green,scale,make_sniper_attack(150+k*10,80+k,60*5,'sniper-beam')) -- damage,range,cooldown
create_fake_human('laser',k,armor,colors.purple,scale,make_beam_attack(1 + k/5,"laser-beam")) -- damage,range,cooldown
create_fake_human('electric',k,armor,colors.blue,scale,make_beam_attack(1+ k/4,'electric-beam')) -- damage,range,cooldown
create_fake_human('rocket',k,armor,colors.yellow,scale, make_rocket_attack(1+ k/5,30+k,60-k,"rocket")) -- damage,range,cooldown
create_fake_human('erocket',k,armor,colors.red,scale, make_rocket_attack(1+ k/5,30+k,60-k,"explosive-rocket",30)) -- damage,range,cooldown
create_fake_human('grenade',k,armor,colors.lightgrey,scale, make_grenade_attack(1+ k/5,30+k,120-k,"grenade",30)) -- damage,range,cooldown
create_fake_human('cluster_grenade',k,armor,colors.brown,scale, make_grenade_attack(1+ k/5,35+k,120-k,"cluster-grenade",30)) -- damage,range,cooldown
create_fake_human('nuke_rocket',k,armor,colors.magenta,scale, make_rocket_attack(1+ k/5,40+k,60*10,"bm-small-atomic-rocket",30)) -- damage,range,cooldown

create_fake_human('cannon',k,armor,colors.orange,scale, make_cannon_attack("cannon-projectile",1+ k/5,30+k,90-k)) -- (projectile,damage_modifier,range,cooldown)
create_fake_human('cannon_explosive',k,armor,colors.orange,scale, make_cannon_attack("explosive-cannon-projectile",1+ k/5,35+k,90-k)) -- (projectile,damage_modifier,range,cooldown)
end


--Human Bosses
local weakness = {"physical","laser","fire","explosion"}
local x=0

for k=1,10 do 
x=x+1
if x>#weakness then x=1 end

local armor = 3
local scale = 1.5 + k/3
local boss_hpmp =  200 * k
--create_fake_human('boss_melee',k,armor,colors.white,scale,make_melee_attack(20+k*10),boss_hpmp) -- damage
 --table.insert(data.raw.unit['tc_fake_human_boss_melee_'..k].attack_parameters.ammo_type.action,
--		 make_biter_area_damage((20+k*10),6+k))	
create_fake_human('boss_machine_gunner',k,armor,colors.brown,scale,make_smg_attack(80+k*10,40+k,2),boss_hpmp) -- damage,range,cooldown
create_fake_human('boss_pistol_gunner',k,armor,colors.yellow,scale,make_smg_attack(80+k*10,30+k,20-k/2),boss_hpmp) -- damage,range,cooldown
create_fake_human('boss_sniper',k,armor,colors.green,scale,make_sniper_attack(200+k*30,89+k,60*5,'sniper-beam'),boss_hpmp) -- damage,range,cooldown
create_fake_human('boss_laser',k,armor,colors.purple,scale,make_beam_attack(8 + k*2,"laser-beam"),boss_hpmp) -- damage,range,cooldown
create_fake_human('boss_electric',k,armor,colors.blue,scale,make_beam_attack(10 + k*2,'electric-beam'),boss_hpmp) -- damage,range,cooldown
create_fake_human('boss_rocket',k,armor,colors.yellow,scale, make_rocket_attack(2+ k/2,40+k,60-k,"rocket"),boss_hpmp) -- (damage_modifier,range,cooldown,projectile,min_range)
create_fake_human('boss_erocket',k,armor,colors.red,scale, make_rocket_attack(1+ k/2,40+k,60-k,"explosive-rocket"),boss_hpmp) -- (damage_modifier,range,cooldown,projectile,min_range)

create_fake_human('boss_grenade',k,armor,colors.lightgrey,scale, make_grenade_attack(3+ k/5,50+k,120-k,"grenade",35),boss_hpmp) -- damage,range,cooldown
create_fake_human('boss_cluster_grenade',k,armor,colors.brown,scale, make_grenade_attack(3+ k/5,55+k,120-k,"cluster-grenade",35),boss_hpmp) -- damage,range,cooldown
create_fake_human('boss_nuke_rocket',k,armor,colors.magenta,scale, make_rocket_attack(3+ k/5,50+k,60*10,"bm-small-atomic-rocket",35),boss_hpmp) -- (damage_modifier,range,cooldown,projectile,min_range)

create_fake_human('boss_cannon_explosive',k,armor,colors.orange,scale, make_cannon_attack("explosive-cannon-projectile", 3+ k/5,50+k,60-k),boss_hpmp) -- (projectile,damage_modifier,range,cooldown)




local res=5+k*2
--JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_melee_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_machine_gunner_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_pistol_gunner_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_sniper_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_laser_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_electric_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_rocket_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_erocket_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_grenade_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_cluster_grenade_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_nuke_rocket_'..k], res,weakness[x])
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'boss_cannon_explosive_'..k], res,weakness[x])
end

-- ultimates
create_fake_human('ultimate_boss_cannon',20,3,colors.white,3, make_cannon_attack("explosive-cannon-projectile", 5,80,20),4000) -- (projectile,damage_modifier,range,cooldown)
JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[base_name..'ultimate_boss_cannon_20'], 35)

end