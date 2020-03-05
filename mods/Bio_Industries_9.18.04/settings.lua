data:extend(
{

	-- A
   {
    type = "bool-setting",
    name = "BI_Solar_Additions",
    setting_type = "startup",
    default_value = true,
	order = "a[modifier]-a[Solar_Farm]",
    per_user = false,
  },
  	-- B
  {
    type = "bool-setting",
    name = "BI_Bio_Fuel",
    setting_type = "startup",
    default_value = true,
	order = "b[modifier]-b[Bio_Fuel]",
    per_user = false,
  },

  	-- C
  {
    type = "bool-setting",
    name = "BI_Bio_Cannon",
    setting_type = "startup",
    default_value = true,
	order = "c[modifier]-c[Bio_Cannon]",
    per_user = false,
  },
 
   	-- D1
  {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Emissions_Multiplier",
    setting_type = "startup",
    default_value = true,
	order = "d[modifier]-d1[Game_Tweaks]",
    per_user = true,
  }, 

  
	-- D2
  {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Stack_Size",
    setting_type = "startup",
    default_value = true,
	order = "d[modifier]-d2[Game_Tweaks]",
    per_user = false,
  },

	-- D3
  {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Recipe",
    setting_type = "startup",
    default_value = true,
	order = "d[modifier]-d3[Game_Tweaks]",
    per_user = false,
  },
  
 	-- D4
  {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Tree",
    setting_type = "startup",
    default_value = true,
	order = "d[modifier]-d4[Game_Tweaks]",
    per_user = false,
  },
  
  	-- D5
  {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Disassemble",
    setting_type = "startup",
    default_value = true,
	order = "d[modifier]-d5[Game_Tweaks]",
    per_user = false,
  },
  
  -- D6
  {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Player",
    setting_type = "startup",
    default_value = false,
	order = "d[modifier]-d6[Game_Tweaks]",
    per_user = false,
  },
  

  
   	-- D7
  {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Bot",
    setting_type = "startup",
    default_value = false,
	order = "d[modifier]-d7[Game_Tweaks]",
    per_user = false,
  }, 

  

  


--[[
Types of settings:
	• startup - game must be restarted if changed (such a setting may affect prototypes' changes)
	• runtime-global - per-world setting
	• runtime-per-user - per-user setting

Types of values:
	• bool-setting
	• double-setting
	• int-setting
	• string-setting

Files being processed by the game:
	• settings.lua
	• settings-updates.lua
	• settings-final-fixes.lua
	
Using in DATA.lua:
data:extend({
   {
      type = "int-setting",
      name = "setting-name1",
      setting_type = "runtime-per-user",
      default_value = 25,
      minimum_value = -20,
      maximum_value = 100,
      per_user = true,
   },
   {
      type = "bool-setting",
      name = "setting-name2",
      setting_type = "runtime-per-user",
      default_value = true,
      per_user = true,
   },
   {
      type = "double-setting",
      name = "setting-name3",
      setting_type = "runtime-per-user",
      default_value = -23,
      per_user = true,
   },
   {
      type = "string-setting",
      name = "setting-name4",
      setting_type = "runtime-per-user",
      default_value = "Hello",
      allowed_values = {"Hello", "foo", "bar"},
      per_user = true,
   },
})

Using in LOCALE.cfg:
	[mod-setting-name]
	setting-name1=Seting name
	[mod-setting-description]
	setting-name1=Seting description

Using in CONTROL.lua and in other code for reading:
	EVENT: on_runtime_mod_setting_changed - called when a player changed its setting
		event.player_index
		event.setting
	GET: settings.startup["setting-name"].value - current value of startup setting; can be used in DATA.lua
	GET: settings.global["setting-name"].value - current value of per-world setting
	GET: set = settings.get_player_settings(LuaPlayer) - current values for per-player settings; then use set["setting-name"].value
	GET: settings.player - default values
]]

}
)


