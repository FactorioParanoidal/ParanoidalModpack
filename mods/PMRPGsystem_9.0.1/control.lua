local mod_gui = require("mod-gui")

require "util"
require "particles"
--local modsprites = require("prototypes.sprites")

local format_number = util.format_number
local stg_critical_interval = 1.5
--[[  
  ** RPG SYSTEM **
by ProjectMakers (Fork from MFerrari)  
]]

function shortnumberstring(number)
    local steps = {
        {1,""},
        {1e3,"k"},
        {1e6,"m"},
        {1e9,"g"},
        {1e12,"t"},
    }
    for _,b in ipairs(steps) do
        if b[1] <= number+1 then
            steps.use = _
        end
    end
    local result = string.format("%.1f", number / steps[steps.use][1])
    if tonumber(result) >= 1e3 and steps.use < #steps then
        steps.use = steps.use + 1
        result = string.format("%.1f", tonumber(result) / 1e3)
    end
    return result .. steps[steps.use][2]
end

function RPG_format_number(number)
local result 
if number < 1000000000 then result=format_number(number)
	else result=shortnumberstring(number) end
return result
end



function Log(what)
game.write_file("myrpg.log", serpent.block(what), true)
end


local colors = {
	white = {r = 1, g = 1, b = 1},
	black = {r = 0, g = 0, b = 0},
	darkgrey = {r = 0.25, g = 0.25, b = 0.25},
	grey = {r = 0.5, g = 0.5, b = 0.5},
	lightgrey = {r = 0.75, g = 0.75, b = 0.75},

	red = {r = 1, g = 0, b = 0},
	darkred = {r = 0.5, g = 0, b = 0},
	lightred = {r = 1, g = 0.5, b = 0.5},
	green = {r = 0, g = 1, b = 0},
	darkgreen = {r = 0, g = 0.5, b = 0},
	lightgreen = {r = 0.5, g = 1, b = 0.5},
	blue = {r = 0, g = 0, b = 1},
	darkblue = {r = 0, g = 0, b = 0.5},
	lightblue = {r = 0.5, g = 0.5, b = 1},

	orange = {r = 1, g = 0.55, b = 0.1},
	yellow = {r = 1, g = 1, b = 0},
	pink = {r = 1, g = 0, b = 1},
	purple = {r = 0.6, g = 0.1, b = 0.6},
	brown = {r = 0.6, g = 0.4, b = 0.1},
}

--prototypes.sprites.charxpmod_space_suit.layers[2].tint = {1,0,0,0.5}


-- CUSTOM EVENT HANDLING --
--(remote interface is lower in the file, there I describe how to subscribe to my events)
-- if your mod alters the character bonus settings, then you should get_on_player_updated_status to make required adjusts to your mod, if necessary
local on_player_updated_status = script.generate_event_name() --uint
local on_player_level_up = script.generate_event_name() --uint



function printXP(player,XP)
if player and player.valid then
if settings.get_player_settings(player)["charxpmod_print_xp_user"].value then
	player.surface.create_entity{name = "flying-text", position = player.position, text = "+" .. RPG_format_number(XP) ..' XP', color = colors.yellow}
	end
end
end


function ResetXPTables()
local xp = 1500
global.xp_table = {[1] = xp}
local mp = 1.6
local red = 0.018
--local maxL = settings.startup["charxpmod_xp_maxlevel"].value

local maxi = global.setting_max_player_level

local m
for k=2,maxi do
    m = mp - k*(red-red*k/ maxi)  -- (Multiplier - Level * (reductor-reductor*Level/100))
	xp = math.ceil(xp * m)
	if (xp / global.xp_table[k-1]) < 1.02 then 
		xp = global.xp_table[k-1] * 1.02
		end
	xp= math.ceil(xp)
	global.xp_table[k] = xp
	end
global.max_xp = xp	
end


function SetForceValues(name)
	global.kills_spawner[name] = 0
	global.kills_units[name] = 0
	global.kills_worms[name] = 0
	global.XP[name] = 0
	global.XP_GANHO[name] = 0
	global.XP_TECH[name] = 0
	global.XP_LEVEL[name] = 1
	global.XP_LEVEL_MIN[name] = 0
	global.XP_KILL_HP[name] = 0
	global.XP_MAX_PLAYTIME[name] = 0
	global.XP_AVG_PLAYTIME[name] = 0
end



function CheckAddPlayerStatus(name)
global.personalxp[name] = global.personalxp[name] or {}
	for _, player in pairs(game.players) do
		global.personalxp[name][player.name] = global.personalxp[name][player.name] or 0
		--game.print(name .. player.name .. global.personalxp[name][player.name])
	end
end


function VersionChange()

if global.personalxp.opt_Pick_Extender == nil then
	global.personalxp.opt_Pick_Extender = {}
	for _, player in pairs(game.players) do
		global.personalxp.opt_Pick_Extender[player.name] = false
	end
end

if global.XP_MAX_PLAYTIME == nil then 
	global.XP_MAX_PLAYTIME={} 
		for name, force in pairs (game.forces) do
			if name~='neutral' and name~='enemy' then
			global.XP_MAX_PLAYTIME[name] = 0
			end
		end
	end
	
if global.XP_AVG_PLAYTIME == nil then 
	global.XP_AVG_PLAYTIME={} 
		for name, force in pairs (game.forces) do
			if name~='neutral' and name~='enemy' then
			global.XP_AVG_PLAYTIME[name] = 0
			end
		end
	end	

CheckAddPlayerStatus('rocketsXP_count')

end


function SetupPlayer(player,ResetXP)
local name= player.name
	
	if ResetXP then
		global.personalxp.XP[name] = 0
		global.personalxp.Death[name] = 0
		global.personal_kill_units[name] = 0
		global.personal_kill_spawner[name] = 0
		global.personal_kill_turrets[name] = 0
		end

	global.personalxp.Level[name] = 1
	Reset_Character_Bonuses(player.character)

	for k=1,#global.Player_Attributes do
		local attrib = global.Player_Attributes[k]
		global.personalxp[attrib][name]= 0
		end

	global.personalxp.opt_Pick_Extender[name] = false
	
UpdatePlayerLvStats(player)	
end

function CheckPlayers()
	for _, player in pairs(game.players) do
		if not (global.personalxp.Level[player.name]) then
			SetupPlayer(player,true)
			end 
			
		if not global.personal_kill_units[player.name] then
			global.personal_kill_units[player.name] = 0
			global.personal_kill_spawner[player.name] = 0
			global.personal_kill_turrets[player.name] = 0
			end
			
		InitPlayerGui(player)
		end
end		

function CheckPlayer(player)
	if not (global.personalxp.Level[player.name]) then
		SetupPlayer(player,true)
	end 
end	




function ReadRunTimeSettings(event)
global.setting_print_critical   =  false	
global.setting_afk_time         =  15
global.setting_time_ratio_xp    =  true
global.setting_death_penal      =  30

if event and event.setting_type=='runtime-per-user' and event.setting=='charxpmod_hide_xp_panel' then
	local player = game.players[event.player_index]
	player.gui.top.chartopframe.visible = not settings.get_player_settings(player)["charxpmod_hide_xp_panel"].value
	end
end



	
function XPModSetup()
global.handle_respawn = global.handle_respawn or {}
global.last_critical_effect_from = global.last_critical_effect_from or {}

global.Player_Attributes = {
	"LV_Health_Bonus",
	"LV_Armor_Bonus",
	"LV_Damage_Bonus",
	"LV_Damage_Critical",
	"LV_Run_Speed",
	"LV_Craft_Speed",
	"LV_Mining_Speed",
	"LV_Inv_Bonus",
	"LV_InvTrash_Bonus",
	"LV_Robot_Bonus",
	"LV_Reach_Dist",	
	}

global.setting_allow_xp_by_tech   =  true	
global.setting_allow_xp_by_kill   =  true	
global.setting_allow_xp_by_rocket =  true
global.setting_allow_xp_by_mining =  true
global.XP_Mult                    =  1
global.setting_allow_damage_attribs =  false	
global.setting_max_player_level   =  200	
global.setting_max_level_ability  =  50



ReadRunTimeSettings()



if global.CharXPMOD == nil then 
	global.CharXPMOD = 1
	global.kills_spawner={}
	global.kills_units={}
	global.kills_worms={}
	global.XP={}
	global.XP_GANHO={}
	global.XP_KILL_HP={}
	global.XP_TECH={}
	global.XP_LEVEL={}
	global.XP_LEVEL_MIN={}
	global.XP_MAX_PLAYTIME={}
	global.XP_AVG_PLAYTIME={}	
	
	global.personalxp = {}
	global.personalxp.Level = {}
	global.personalxp.XP = {}
	global.personalxp.Death = {}



	for k=1,#global.Player_Attributes do
		global.personalxp[global.Player_Attributes[k]]= {} 
		end
	
	global.personalxp.opt_Pick_Extender = {}

	for name, force in pairs (game.forces) do
		if name~='neutral' and name~='enemy' then
			SetForceValues(name)
			end
		end
	end
	
ResetXPTables()


mySettingsrpg = {
	charxpmod_LV_Health_Bonus = {
	  value = 10, 
	},
	charxpmod_LV_Armor_Bonus = {
	  value = 1, 
	},
	charxpmod_LV_Run_Speed = {
	  value = 3, 
	},
	charxpmod_LV_Damage_Bonus = {
		value = 2, 
	  },
	  charxpmod_LV_Damage_Critical = {
		value = 1, 
	  },
	  charxpmod_LV_Craft_Speed = {
		value = 5, 
	  },
	  charxpmod_LV_Mining_Speed = {
		value = 5, 
	  },
	  charxpmod_LV_Reach_Dist = {
		value = 1, 
	  },
	  charxpmod_LV_Inv_Bonus = {
		value = 1, 
	  },
	  charxpmod_LV_InvTrash_Bonus = {
		value = 1, 
	  },
	  charxpmod_LV_Robot_Bonus = {
		value = 1, 
	  },
	 
  }

global.RPG_Bonus = {}
	for k=1,#global.Player_Attributes do
		local attrib = global.Player_Attributes[k]
		global.RPG_Bonus[attrib]= mySettingsrpg ["charxpmod_"..attrib].value
		CheckAddPlayerStatus(attrib)
		end
	
global.personal_kill_units = global.personal_kill_units or {}
global.personal_kill_spawner = global.personal_kill_spawner or {}
global.personal_kill_turrets = global.personal_kill_turrets or {}	
	
VersionChange()
CheckPlayers()
end


function ResetAll()
ResetXPTables()
	for name, force in pairs (game.forces) do
		if name~='neutral' and name~='enemy' then
			SetForceValues(name)
			end
		end
	for _, player in pairs(game.players) do
		SetupPlayer(player,true)
		UpdatePanel(player)
		end
end


function ResetPointSpent()
ResetXPTables()

	for _, player in pairs(game.players) do
		SetupPlayer(player,false)
		end
end



function InitPlayerGui(player)

local name = player.name

-- close main panel
local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"] 
if frame then frame.destroy() end

-- remove previous versions
if player.gui.top.chartopframe then  player.gui.top.chartopframe.destroy() end	
if player.gui.top.btcharxp then  player.gui.top.btcharxp.destroy() end
	
-- create new ones	
local Topframe = player.gui.top.add{name="chartopframe", direction = "horizontal", type="frame", style=mod_gui.frame_style, visible = false}
 	Topframe.style.minimal_height = 30
-- 	Topframe.style.maximal_height = 37
	Topframe.style.minimal_width = 150
--	Topframe.style.maximal_width  = 250
	--snouz
	Topframe.style.margin = {0,10,5,10}
	Topframe.style.padding = {0,9,0,0}

Topframe.add{name="btcharxp", type="sprite-button", sprite = "entity/character", tooltip = {"panel-title", player.name}, style = mod_gui.top_button_style, visible = false} -- "mod_gui_button"}

local tabFrame = Topframe.add{type = "table", name = "tabtopframexp", column_count = 1, visible = false}
Level = global.personalxp.Level[name]
local pnivel = tabFrame.add{type="label", name='chartoplvtxt', caption={'actual_lv',Level}, visible = false}
    pnivel.style.font="charxpmod_font_17b"
local TopXPbar = tabFrame.add{type = "progressbar", name = "TopXPbar", visible = false}
TopXPbar.style.width=110
UpdatePanel(player)
end


----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------


function RatioXP(player)
local ratioXP = 1
	if global.setting_time_ratio_xp and global.XP_AVG_PLAYTIME[player.force.name]>0 then
		ratioXP = player.online_time/global.XP_AVG_PLAYTIME[player.force.name]
		if ratioXP >= 1.10 then ratioXP = 1.10
			elseif ratioXP < 0.05 then ratioXP = 0.05 end
		end	
return ratioXP
end


function XP_Player_upd()

 	for name, force in pairs (game.forces) do
	if name~='neutral' and name~='enemy' then

		local cp = #force.connected_players
		local afk = global.setting_afk_time
		if cp>0 then
			local XP = global.XP[name]   --math.ceil(global.XP[name] / cp)
			
			if XP>0 then
			for p, PL in pairs (force.connected_players) do 
				if afk==0 or PL.afk_time<afk*3600 then
				local ratioXP = RatioXP(PL)
				XP = math.ceil(XP*ratioXP)	
				global.personalxp.XP[PL.name] = global.personalxp.XP[PL.name] + XP
				printXP(PL,XP)
				UpdatePanel(PL)
				end
				end
			end	
		global.XP[name]=0	
		end
	end
	end
end


function XP_PlayerLv_upd()

	for _, player in pairs(game.players) do
		if player.connected then
			local name = player.name
			local Lv = global.personalxp.Level[name]
			if global.personalxp.XP[name]>global.max_xp then 
			   global.personalxp.Level[name]=global.setting_max_player_level
			   else
			
			for L=Lv, #global.xp_table do
				if global.personalxp.XP[name]< global.xp_table[L] then
					global.personalxp.Level[name]=L
					break
				end
			end end
			
			if global.personalxp.Level[name] > Lv then
				--player.print({'player_lv_up',global.personalxp.Level[name]})
				--mod_gui.get_button_flow(player).focus()
				--player.gui.top.chartopframe.focus()
				player.play_sound{path = 'player_level_up',volume_modifier=0.85}
				script.raise_event(on_player_level_up, {player_index = player.index, player_level = global.personalxp.Level[name]})
				end
			UpdatePanel(player)
		end
	end
end


function XP_Time_upd()
 	for name, force in pairs (game.forces) do
	if name~='neutral' and name~='enemy' then
	local PT
	local TT=0
	local QP=0

		for p, PL in pairs (force.players) do 
			PT = PL.online_time
			if PT > global.XP_AVG_PLAYTIME[name]/20 then  -- a player time count for avg if he has at least 5% of the avg time
				TT = TT + PT
				QP = QP + 1
				end

			if global.XP_MAX_PLAYTIME[name] < PT then
				global.XP_MAX_PLAYTIME[name] = PT
				end
			end
	if QP>0 then global.XP_AVG_PLAYTIME[name] = TT/QP end
	end
	end
end


function XP_UPDATE_tick()

XP_Time_upd()
XP_Player_upd()
XP_PlayerLv_upd()


end





function SumPointSpent(name)
local sum = 0
for k=1,#global.Player_Attributes do
	local attrib = global.Player_Attributes[k]
	sum = sum + global.personalxp[attrib][name]
	end
return sum	
end


-- MAIN RPG CHARACTER GUI
function update_char_panel(player)
XP_Time_upd() 
 
local force = player.force.name
local painel = player.gui.center["char-panel"] or player.gui.screen["char-panel"]
local frame = painel.tabcharScroll
local name = player.name
local Level = global.personalxp.Level[name] 
local HP = 0
--local playercolor = player.color
--modsprites.charxpmod_space_suit_mask.tint = playercolor


local ptime = player.online_time
local txtPTime = {"time-played", string.format("%d:%02d:%02d", math.floor(ptime / 216000), math.floor(ptime / 3600) % 60, math.floor(ptime / 60) % 60)}

local PontosXP = Level - 1 - SumPointSpent(name)
if PontosXP<0 then PontosXP=0 end

frame.add{type = "line"}

local tabChar = frame.add{type = "table", name = "tab_tbchar", column_count = 2}

local frametabChar = tabChar.add{name="frametabChar", type="frame", style=mod_gui.frame_style}
	if player.character and player.character.valid then 
		HP = math.ceil(player.character.health)
		
		local cam = frametabChar.add{type = "entity-preview", name='rpg_player_preview'}
		
		--local cam = frametabChar.add({ type="camera", name="rpg_player_preview", position = player.position, zoom = 0.75 })
		
		cam.style.width = 110 cam.style.height = 110	
		cam.entity=player.character	
			cam.style.padding = {0,-10,0,-10}
			cam.style.margin = {5,0,-5,0}		
		else
		
			local rpgportrait = frametabChar.add{type = "sprite", sprite = "charxpmod_space_suit"}
			rpgportrait.style.padding = {0,-10,0,-10}
			rpgportrait.style.margin = {5,0,-5,0}
			--rpgportrait.style.width = 44.8
			--rpgportrait.style.height = 84
			--rpgportrait.style.margin = {2,25,4,20}
		end



	local tabScroll = tabChar.add{type = "scroll-pane", name = "tabScroll2", vertical_scroll_policy = "auto", horizontal_scroll_policy = "auto"}

		--tabScroll.style.height = 120
		tabScroll.style.padding = {-5,0,5,10}

		local tabPName = tabScroll.add{type = "table", name = "tab_pname", column_count = 1}

		local pnivel = tabPName.add{type="label", name='ocharlevel', caption={'actual_lv',Level}} 
			pnivel.style.font = "charxpmod_font_30"
			--pnivel.style.font_color = player.color
			pnivel.style.bottom_padding = -5



-- XP RATIO	
local ratioXP = RatioXP(player)
ratioXP = math.floor(ratioXP*100)


		local tabStats = tabScroll.add{type = "table", name = "tabStats", column_count = 1}


			local wd = 160
			tabStats.add{type="label", name='STT1', caption=txtPTime}.style.width = wd
			tabStats.add{type="label", name='STT3', caption={'xp_ratio',ratioXP}} --.style.width = wd
			tabStats.add{type="label", name='STT2', caption={'xp_deaths',global.personalxp.Death[name]}}.style.width = wd
			tabStats.add{type="label", name='STT5', caption='HP: '.. format_number(HP)}.style.width = wd




local pbvalue = CalculateXP_PB(player.name)
local XP = global.personalxp.XP[name] 
local NextLevel = global.xp_table[Level]

local NextLtxt = RPG_format_number(NextLevel)
if XP >= global.max_xp then NextLtxt = 'MAX' end


frame.add{type = "line"}

---------------XP NUMBERS


local flowXP = frame.add{type = "flow", direction="horizontal"}
	flowXP.style.width = 450
	local currXP = flowXP.add{type="label", name='lbxpatual', caption='XP: ' .. RPG_format_number( XP ) } --.style.font="charxpmod_font_17"
    currXP.style.font='default-bold'
	local stretchableFlow = flowXP.add{type = "flow", direction="horizontal"}
		stretchableFlow.style.horizontally_stretchable = true
	local flownextXP = flowXP.add{type = "flow", direction="horizontal"}
		flownextXP.style.horizontal_align = "right"
		flownextXP.style.width = 200
		local nextXP = flownextXP.add{type="label", caption={'next_lv', NextLtxt}} --.style.font="charxpmod_font_17"

		
----------------XP BAR

local btAttribute2 = frame.add{type="sprite-button", sprite = "info11", name="info22", tooltip = { "xp_hint_global.personalxp.LV_Info" } }

btAttribute2.style.width = 70
btAttribute2.style.height = 70
btAttribute2.style.margin = {0,0,0,0}
btAttribute2.style.padding = {0,0,0,0}

local tabBar = frame.add{type = "table", column_count = 1}
	
	local bar = tabBar.add{type = "progressbar", value = pbvalue, name = "tab_XPbar", style="achievement_progressbar"}
	bar.style.width = 450


frame.add{type = "line"}


frame.add{type = "label", name = 'lbxPAGastar', caption={'xp_points',PontosXP}}.style.font="charxpmod_font_20"   

-- LEVELS / UPGRADES
local tabUpgrades = frame.add{type = "table", name = "tabUpgrades", column_count = 6}
	tabUpgrades.style.horizontal_spacing = 10
	tabUpgrades.style.vertical_spacing = 10


local Max = global.setting_max_level_ability
local custo = 1
local vchar 
local at_level
local attrib
local bonus, Tbonus


for A=1,#global.Player_Attributes do
	attrib = global.Player_Attributes[A]
	local enabled = true
	if (attrib=="LV_Armor_Bonus" or attrib=="LV_Damage_Bonus" or attrib=="LV_Damage_Critical") 
		and (not global.setting_allow_damage_attribs) then enabled = false end
	
	if global.RPG_Bonus[attrib]==0 then enabled = false end 
	
	if enabled then

		vchar    = 'global.personalxp.'..attrib
		at_level = global.personalxp[attrib][name]
		bonus    = global.RPG_Bonus[attrib]
		Tbonus   = at_level * bonus
		

	local tabAttrib = tabUpgrades.add{type = "table", column_count = 1}
	tabAttrib.style.horizontal_align = "center"
		
		local framebtAttributetext = tabAttrib.add{direction = "horizontal", type="frame"}
		framebtAttributetext.style.width = 67 --67
		framebtAttributetext.style.horizontal_align = "center"
		framebtAttributetext.style.margin = {0,0,-5,0}
		framebtAttributetext.style.padding = {0,0,-5,0}
			local btAttributetext = framebtAttributetext.add{type="label", caption={vchar}}
			btAttributetext.style.font = "charxpmod_font_12"
			btAttributetext.style.width = 60 --57
			btAttributetext.style.horizontal_align = "center"
			btAttributetext.style.margin = {0,0,0,0}
			btAttributetext.style.padding = {0,0,0,0}
		local btAttribute = tabAttrib.add{type="sprite-button", sprite = attrib .. "_sprite", style = 'rounded_button', name='btLVU_'..vchar, tooltip={'xp_hint_'..vchar,format_number(bonus),format_number(Tbonus)}}
		btAttribute.style.font = "charxpmod_font_icons"
		btAttribute.style.width = 67
		btAttribute.style.height = 67
		btAttribute.style.margin = {0,0,0,0}
		btAttribute.style.padding = {0,0,0,0}
		btAttribute.style.horizontal_align = "center"
		local frametxtAttLv = tabAttrib.add{direction = "horizontal", type="frame"}
		frametxtAttLv.style.width = 67
		frametxtAttLv.style.margin = {-5,0,0,0}
		frametxtAttLv.style.padding = {-5,0,0,0}
		frametxtAttLv.style.horizontal_align = "center"
			local txtAttLv = frametxtAttLv.add{type="label", caption=at_level}
			txtAttLv.style.font = "charxpmod_font_17"
			txtAttLv.style.width = 57
			txtAttLv.style.horizontal_align = "center"
			txtAttLv.style.margin = {0,0,0,0}
			txtAttLv.style.padding = {0,0,0,0}
			
			btAttribute.enabled = PontosXP>=custo and at_level<Max
	end
end

frame.add{type = "line"}


local pickbutton = frame.add{type = "checkbox", name = "cb_pick_extender", caption={'xp_opt_Pick_Extender'}, state = global.personalxp.opt_Pick_Extender[name]}

--frame.add{type="label", name='blankL4', caption=' '}
frame.add{type = "line"}

--[[TAG 
local frametag = frame.add{type="flow", name="char_frametag", direction = "horizontal"} 

	local tabtag = frametag.add{type = "table", name = "tabchartag", column_count = 3}
	tabtag.style.top_margin = 5
		tabtag.add{type="label", name="lab_ctag", caption={'player_tag'}}
		tabtag.add{type="textfield", name="ctag_field", text=player.tag}


	local btTagOK = tabtag.add{name="btTagCharOK", type="button", style = 'rounded_button', caption='OK'}
		btTagOK.style.width = 64
]]
	--local btColors= tabtag.add{name="btColorsChar", type="button", style = 'confirm_double_arrow_button', caption={'panel-colors-title'}}
end


function create_gui_box(player, caption)
local frame = player.gui.left["rpg-list"]
if frame then frame.destroy() end
frame = player.gui.left.add{type="frame", name="rpg-list", direction = "vertical", style=mod_gui.frame_style, caption=caption} 
local scroll = frame.add{type = "scroll-pane", name= "list-scroll", vertical_scroll_policy="auto", horizontal_scroll_policy="auto"}
local bt_destroy_my_parent = frame.add{type = "button", caption ={'close'}, name = "bt_destroy_my_parent", style = "back_button"}
return scroll
end

function ListAll(player)
local scroll = create_gui_box(player, {"players-list"})
local force = player.force
local tabpllst = scroll.add{type = "table", name = "tabpllst", column_count = 3}
for p,PL in pairs (force.players) do
	local ptime = PL.online_time
	local txtPTime = string.format("%d:%02d", math.floor(ptime / 216000), math.floor(ptime / 3600) % 60)
	local ratioXP = math.floor(RatioXP(PL) * 100)
	tabpllst.add{type="label", name='pllstname'..p, caption=PL.name .. ' '..global.personalxp.Level[PL.name] .. ' (' ..txtPTime.. ' '..ratioXP..'%)'}
	end
end  
  

function ListXPTable(player)
local scroll = create_gui_box(player, 'XP Level Table:')
for k=1,#global.xp_table do
	local txt = 'Level '.. k .. ' - ' .. global.xp_table[k]
	scroll.add{type="label", caption=txt}
	end
end
  
  
function CalculateXP_PB(plname)
local Level = global.personalxp.Level[plname] 
local XP = global.personalxp.XP[plname] 
if XP > global.max_xp then XP = global.max_xp end
local NextLevel = global.xp_table[Level]
if not NextLevel then return end
local XP_ant
if Level==1 then XP_ant = 0 else XP_ant = global.xp_table[Level-1] end
local Interval_XP = NextLevel - XP_ant
local pbvalue = (XP-XP_ant)/Interval_XP
return pbvalue
end


function CalculateXP_GAIN_LV(playername)
 
local pbvalue = CalculateXP_PB(playername)
local Level = global.personalxp.Level[playername] 
local NextLevel = global.xp_table[Level]
if not NextLevel then return end
local XP = global.personalxp.XP[playername] 

local xp_to_next_level = NextLevel - XP
local next_partial = 0

if Level<global.setting_max_player_level then
    next_partial = math.ceil((global.xp_table[Level+1] - NextLevel) * pbvalue)
	end
	
return xp_to_next_level + next_partial
end


function CalculateXP_PERCENT_CURRENT_LV(playername,Perc)

local Level = global.personalxp.Level[playername] 
local GainXP = 0

if Level<global.setting_max_player_level then
	local NextLevel = global.xp_table[Level]
	local PriorLVXP = 0
	if Level>1 then PriorLVXP = global.xp_table[Level-1] end
	GainXP = math.ceil((NextLevel - PriorLVXP) * Perc)
	end

return GainXP
end


  
function UpdatePanel(player, focus)
-- BARRA DE XP  tabtopframexp
local TopXPbar = player.gui.top.chartopframe.tabtopframexp.TopXPbar
local txtlv    = player.gui.top.chartopframe.tabtopframexp.chartoplvtxt

local Level = global.personalxp.Level[player.name] 
local pbvalue = CalculateXP_PB(player.name)

txtlv.caption={'actual_lv',Level}
TopXPbar.value=pbvalue

local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"] 
if frame then expand_char_gui(player) end

end


function close_char_panel(player)
local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"]
if frame then frame.destroy() end
end

function reopen_char_panel(player)
close_char_panel(player)
expand_char_gui(player)
end

function open_close_char_gui(player)
local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"]
if frame then close_char_panel(player) else expand_char_gui(player) end
end



function expand_char_gui(player)
local  wid = 470
local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"]
if not frame then
	frame = player.gui.screen.add{type="frame", name="char-panel", direction = "vertical", style=mod_gui.frame_style} 
	frame.auto_center  = true
	frame.style.minimal_height = 430
	--frame.style.maximal_height = 430
	frame.style.minimal_width = wid
	frame.style.maximal_width = 485
	
	
	local title_table = frame.add{type="table", name="title_table", column_count=4, draw_horizontal_lines=false}
			title_table.style.horizontally_stretchable = true
			title_table.style.column_alignments[1] = "left"
			title_table.style.column_alignments[2] = "right"
			title_table.style.column_alignments[3] = "right"
			title_table.style.column_alignments[4] = "right"			
			title_table.drag_target = frame
			local title_frame = title_table.add{type="frame", name="title_frame",  caption={"panel-title", player.name}, style="ic_title_frame"} --
			title_frame.ignored_by_interaction = true
	
	local tagfield = title_table.add{type="textfield", name="ctag_field", text=player.tag}
	tagfield.style.width=200
	tagfield.visible=false
	
	local edittag = title_table.add{name="rpg_bt_edittag",  type="sprite-button", sprite = "utility/rename_icon_normal", style = "shortcut_bar_button_small", tooltip={'player_tag'}}
	local closeb = title_table.add{name="rpg_bt_close",  type="sprite-button", sprite = "utility/close_black", style = "shortcut_bar_button_small"}
	end

if frame.tabcharScroll then frame.tabcharScroll.destroy() end
local tabcharScroll = frame.add{type = "scroll-pane", name= "tabcharScroll", vertical_scroll_policy="auto", horizontal_scroll_policy="auto"}
tabcharScroll.style.minimal_height = 400
--tabcharScroll.style.maximal_height = 1000
tabcharScroll.style.minimal_width = wid - 15
tabcharScroll.style.maximal_width = wid - 15

update_char_panel(player) 
end



function UpdatePlayerLvStats(player, skip_inv)
local name=player.name

if player.character then

		player.character.character_crafting_speed_modifier = player.character.character_crafting_speed_modifier +  global.personalxp.LV_Craft_Speed[name] * global.RPG_Bonus['LV_Craft_Speed']/100 
		player.character.character_mining_speed_modifier   = player.character.character_mining_speed_modifier + global.personalxp.LV_Mining_Speed[name] * global.RPG_Bonus['LV_Mining_Speed']/100 
		player.character.character_running_speed_modifier  = player.character.character_running_speed_modifier + global.personalxp.LV_Run_Speed[name] * global.RPG_Bonus['LV_Run_Speed']/100 

		player.character.character_build_distance_bonus = player.character.character_build_distance_bonus+ global.personalxp.LV_Reach_Dist[name] * global.RPG_Bonus['LV_Reach_Dist']
		player.character.character_reach_distance_bonus = player.character.character_reach_distance_bonus+ global.personalxp.LV_Reach_Dist[name] * global.RPG_Bonus['LV_Reach_Dist'] 
		player.character.character_item_drop_distance_bonus = player.character.character_item_drop_distance_bonus+ global.personalxp.LV_Reach_Dist[name] * global.RPG_Bonus['LV_Reach_Dist'] 
		player.character.character_resource_reach_distance_bonus = player.character.character_resource_reach_distance_bonus+ global.personalxp.LV_Reach_Dist[name] * global.RPG_Bonus['LV_Reach_Dist']

	if not skip_inv then
		player.character.character_inventory_slots_bonus = player.character.character_inventory_slots_bonus + global.personalxp.LV_Inv_Bonus[name] * global.RPG_Bonus['LV_Inv_Bonus'] 
		end
		player.character.character_trash_slot_count_bonus = player.character.character_trash_slot_count_bonus + global.personalxp.LV_InvTrash_Bonus[name] * global.RPG_Bonus['LV_InvTrash_Bonus']
		player.character.character_maximum_following_robot_count_bonus = player.character.character_maximum_following_robot_count_bonus + global.personalxp.LV_Robot_Bonus[name] * global.RPG_Bonus['LV_Robot_Bonus']
		player.character.character_health_bonus = player.character.character_health_bonus+ global.personalxp.LV_Health_Bonus[name] * global.RPG_Bonus['LV_Health_Bonus']

	if global.personalxp.opt_Pick_Extender[name] then 
		player.character.character_item_pickup_distance_bonus = player.character.character_reach_distance_bonus
		player.character.character_loot_pickup_distance_bonus = player.character.character_reach_distance_bonus
		end
		
end
end


local p_attribs = { 'character_crafting_speed_modifier',
					'character_mining_speed_modifier',
					'character_running_speed_modifier',
					'character_reach_distance_bonus',
					'character_item_drop_distance_bonus',
					'character_resource_reach_distance_bonus',
					'character_inventory_slots_bonus',
					'character_trash_slot_count_bonus',
					'character_maximum_following_robot_count_bonus',
					'character_health_bonus',
					'character_item_pickup_distance_bonus'}

function Reset_Character_Bonuses(character)
if character and character.valid then
	for a=1,#p_attribs do character[p_attribs[a]]=0 end
	end
end


function CopyPlayerStats(name)
local player = game.players[name]
if player and player.valid then
	local character_attribs = {}
	
	if player.character and player.character.valid then
		for a=1,#p_attribs do 
		table.insert(character_attribs,player.character[p_attribs[a]]) end
	end
	
	local rpg_stats = {global.personalxp.Level[name],
					   global.personalxp.XP[name],
					   global.personalxp.Death[name],
					   global.personalxp.opt_Pick_Extender[name],
					   global.personal_kill_units[name],
					   global.personal_kill_spawner[name],
					   global.personal_kill_turrets[name],
						}
	for k=1,#global.Player_Attributes do
		local attrib = global.Player_Attributes[k]
		table.insert(rpg_stats, global.personalxp[attrib][name] )
		end
	return {character_attribs=character_attribs, rpg_stats=rpg_stats}
	end
end


function PastePlayerStats(name,status)
local player = game.players[name]
if player and player.valid and status then
	local character_attribs = status.character_attribs
	
	if player.character and player.character.valid then
		for a=1,#p_attribs do  player.character[p_attribs[a]]=character_attribs[a] end
	end
	
	local rpg_stats = status.rpg_stats
	global.personalxp.Level[name] = rpg_stats[1]
    global.personalxp.XP[name]    = rpg_stats[2]
    global.personalxp.Death[name] = rpg_stats[3]
    global.personalxp.opt_Pick_Extender[name] = rpg_stats[4]
    global.personal_kill_units[name] = rpg_stats[5]
    global.personal_kill_spawner[name] = rpg_stats[6]
    global.personal_kill_turrets[name] = rpg_stats[7]
				
	for k=1,#global.Player_Attributes do
		local attrib = global.Player_Attributes[k]
		global.personalxp[attrib][name] = rpg_stats[k+7]
		end
	UpdatePanel(player)
	end
end


-- this will calculate the stat using sum, instead of replacing the value
-- used for compatibility with other mods
function AdjustPlayerStat(player,stat)
local name=player.name

if player.character ~= nil then
if     stat=='character_crafting_speed_modifier' then 
   player.character[stat] = player.character[stat] + global.personalxp.LV_Craft_Speed[name] * global.RPG_Bonus['LV_Craft_Speed']/100 
elseif stat=='character_mining_speed_modifier' then
   player.character[stat] = player.character[stat] + global.personalxp.LV_Mining_Speed[name] * global.RPG_Bonus['LV_Mining_Speed']/100 
elseif stat=='character_running_speed_modifier' then
   player.character[stat] = player.character[stat] + global.personalxp.LV_Run_Speed[name] * global.RPG_Bonus['LV_Run_Speed']/100 
elseif stat=='character_build_distance_bonus' then
   player.character[stat] = player.character[stat] + global.personalxp.LV_Reach_Dist[name]* global.RPG_Bonus['LV_Reach_Dist']
elseif stat=='character_reach_distance_bonus' then
   player.character[stat] = player.character[stat] + global.personalxp.LV_Reach_Dist[name]* global.RPG_Bonus['LV_Reach_Dist']
elseif stat=='character_item_drop_distance_bonus' then
   player.character[stat] = player.character[stat] + global.personalxp.LV_Reach_Dist[name]* global.RPG_Bonus['LV_Reach_Dist']
elseif stat=='character_resource_reach_distance_bonus' then
   player.character[stat] = player.character[stat] + global.personalxp.LV_Reach_Dist[name]* global.RPG_Bonus['LV_Reach_Dist']
elseif stat=='character_inventory_slots_bonus' then
   player.character[stat] = player.character[stat] +  global.personalxp.LV_Inv_Bonus[name] * global.RPG_Bonus['LV_Inv_Bonus'] 
elseif stat=='character_trash_slot_count_bonus' then
   player.character[stat] = player.character[stat] + global.personalxp.LV_InvTrash_Bonus[name]* global.RPG_Bonus['LV_InvTrash_Bonus'] 
elseif stat=='character_maximum_following_robot_count_bonus' then
   player.character[stat] = player.character[stat] + global.personalxp.LV_Robot_Bonus[name]* global.RPG_Bonus['LV_Robot_Bonus'] 
elseif stat=='character_health_bonus' then
   player.character[stat] = player.character[stat] + global.personalxp.LV_Health_Bonus[name]* global.RPG_Bonus['LV_Health_Bonus'] 
elseif stat=='character_item_pickup_distance_bonus' then
	 if global.personalxp.opt_Pick_Extender[name] then 
        player.character[stat] = player.character[stat] + global.personalxp.LV_Reach_Dist[name]* global.RPG_Bonus['LV_Reach_Dist'] end
elseif stat=='character_loot_pickup_distance_bonus' then
	 if global.personalxp.opt_Pick_Extender[name] then 
        player.character[stat] = player.character[stat] + global.personalxp.LV_Reach_Dist[name]* global.RPG_Bonus['LV_Reach_Dist'] end
	end
   
end
 	
end



function LevelUPPlayer(player,btname)

local name=player.name

for A=1,#global.Player_Attributes do
	local attrib = global.Player_Attributes[A]
	
	if btname=='btLVU_global.personalxp.'.. attrib then 
		global.personalxp[attrib][name] = global.personalxp[attrib][name] + 1
		
		if btname=='btLVU_global.personalxp.LV_Craft_Speed' then
			player.character.character_crafting_speed_modifier = player.character.character_crafting_speed_modifier + global.RPG_Bonus[attrib]/100 end 
		if btname=='btLVU_global.personalxp.LV_Mining_Speed' then
			player.character.character_mining_speed_modifier = player.character.character_mining_speed_modifier + global.RPG_Bonus[attrib]/100 end 
		if btname=='btLVU_global.personalxp.LV_Run_Speed' then
			player.character.character_running_speed_modifier = player.character.character_running_speed_modifier + global.RPG_Bonus[attrib]/100 end 

		if btname=='btLVU_global.personalxp.LV_Reach_Dist' then
			player.character.character_build_distance_bonus = player.character.character_build_distance_bonus + global.RPG_Bonus[attrib]
			player.character.character_reach_distance_bonus = player.character.character_reach_distance_bonus + global.RPG_Bonus[attrib]
			player.character.character_item_drop_distance_bonus = player.character.character_item_drop_distance_bonus + global.RPG_Bonus[attrib]
			player.character.character_resource_reach_distance_bonus = player.character.character_resource_reach_distance_bonus + global.RPG_Bonus[attrib] end
			
		if btname=='btLVU_global.personalxp.LV_Inv_Bonus' then
			player.character.character_inventory_slots_bonus = player.character.character_inventory_slots_bonus + global.RPG_Bonus[attrib] end 

		if btname=='btLVU_global.personalxp.LV_InvTrash_Bonus' then
			player.character.character_trash_slot_count_bonus = player.character.character_trash_slot_count_bonus + global.RPG_Bonus[attrib] end 

		if btname=='btLVU_global.personalxp.LV_Robot_Bonus' then
			player.character.character_maximum_following_robot_count_bonus = player.character.character_maximum_following_robot_count_bonus + global.RPG_Bonus[attrib] end 

		if btname=='btLVU_global.personalxp.LV_Health_Bonus' then
			player.character.character_health_bonus = player.character.character_health_bonus + global.RPG_Bonus[attrib] end 

		script.raise_event(on_player_updated_status, {player_index = player.index, player_level = global.personalxp.Level[name], attribute=attrib})
		
		break
		end
	end
	


if global.personalxp.opt_Pick_Extender[name] then 
	player.character.character_item_pickup_distance_bonus = math.min(player.character.character_reach_distance_bonus,320)
	player.character.character_loot_pickup_distance_bonus = math.min(player.character.character_reach_distance_bonus,320)
	else 
	player.character.character_item_pickup_distance_bonus = 0
	player.character.character_loot_pickup_distance_bonus = 0
	end
	
	
end




script.on_nth_tick(60 * 5,function (event)
XP_UPDATE_tick()
check_respawned_players()
end)




function check_respawned_players()
for name,died in pairs (global.handle_respawn) do
    if died then 
		if game.players[name] and game.players[name].valid and game.players[name].character and game.players[name].character.valid then
			global.handle_respawn[name]=false
			UpdatePlayerLvStats(game.players[name]) 
			end
		end
	end
end

function Cria_Player(event) 
local player = game.players[event.player_index]
SetupPlayer(player,true)
end


function on_force_created(event) 
local name = event.force.name
SetForceValues(name)
end


function onPlayerJoin(event)
local player = game.players[event.player_index]
CheckPlayer(player)
InitPlayerGui(player)
end


function On_Init() 
XPModSetup()
end


function on_configuration_changed(data)
XPModSetup()
end

script.on_event(defines.events.on_player_created, Cria_Player)
script.on_event(defines.events.on_player_joined_game, onPlayerJoin)
script.on_event(defines.events.on_runtime_mod_setting_changed, ReadRunTimeSettings)

--script.on_event(defines.events.on_tick, on_tick )
script.on_event(defines.events.on_force_created,on_force_created)
script.on_configuration_changed(on_configuration_changed)
script.on_init(On_Init)
script.on_event("key-I", function(event) open_close_char_gui(game.players[event.player_index]) end)


-- closes panel when player open inventory E
script.on_event(defines.events.on_gui_opened, function(event)
if event.gui_type and event.gui_type ==defines.gui_type.controller then
	close_char_panel(game.players[event.player_index])
	end
end)






local function on_gui_click(event)
local player = game.players[event.element.player_index]
local element = event.element
if element and element.valid then 
local name = element.name
local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"] 

    if (name == "btcharxp") then open_close_char_gui(player)
    elseif (name == "rpg_bt_edittag")then

		local tagfield = element.parent.ctag_field
		local text =tagfield.text
		
		if tagfield.visible then
			tagfield.visible = false
			element.sprite = "utility/rename_icon_normal"
			if player.tag~=text then 
				player.tag = text
				player.print({"",{'player_tag'}, ': ', text})
				end
			else
			tagfield.visible = true
			element.sprite = "utility/check_mark_green"
			end
	
	elseif string.sub(name,1,6)=='btLVU_' then
		if player.character and player.character.valid then
		LevelUPPlayer(player,name)
		expand_char_gui(player)
		end

	elseif name == "cb_pick_extender" then
		if player.character == nil then
			frame.tabcharScroll.cb_pick_extender.state = global.personalxp.opt_Pick_Extender[player.name]
			return
			end
		local cb_pick_extender = frame.tabcharScroll.cb_pick_extender.state
		global.personalxp.opt_Pick_Extender[player.name] = cb_pick_extender
		
		if cb_pick_extender then
			player.character.character_item_pickup_distance_bonus = player.character.character_reach_distance_bonus
			player.character.character_loot_pickup_distance_bonus = player.character.character_reach_distance_bonus
		else 
			player.character.character_item_pickup_distance_bonus = 0
			player.character.character_loot_pickup_distance_bonus = 0
		end
	
	elseif name == "bt_destroy_my_parent" then if element and element.parent then element.parent.destroy() end
	elseif name == "rpg_bt_close" then element.parent.parent.destroy()
	
	end
end
end
script.on_event(defines.events.on_gui_click, on_gui_click)



script.on_event(defines.events.on_player_respawned, function(event)
local player = game.players[event.player_index]
global.handle_respawn[player.name]=false
UpdatePlayerLvStats(player)
end)


script.on_event(defines.events.on_pre_player_died, function(event)
local player = game.players[event.player_index]
local name = player.name
local XP = global.personalxp.XP[name] 
local Level = global.personalxp.Level[name] 
local NextLevel = global.xp_table[Level]
local XP_ant
if Level==1 then XP_ant = 0 else XP_ant = global.xp_table[Level-1] end
local Interval_XP = NextLevel - XP_ant
local Penal = math.floor((XP-XP_ant)*global.setting_death_penal/100)
global.personalxp.Death[name] = global.personalxp.Death[name]+1
global.handle_respawn[name]=true
if Penal>0 then 
global.personalxp.XP[name] = global.personalxp.XP[name]-Penal
player.print({"", {'xp_lost'}, RPG_format_number(Penal)},colors.lightred)
end

end)




function GetXPByKill(entity,killer,force)
if force then
if global.setting_allow_xp_by_kill then
if not global.last_overkill or (global.last_overkill and global.last_overkill~=entity) then

if entity and entity.valid then
local XP = entity.prototype.max_health
local player , plname

if killer and killer.valid then 
	if killer.is_player() then player=killer 
	else
		if killer.type and killer.type == 'character' then
			player=killer.player  
			force=killer.force
			end
		end
	end

if player then plname=player.name end

local nforce=force.name

if force ~= entity.force and (not force.get_friend(entity.force)) then

if entity.type == 'character' then XP = XP * 4
	elseif entity.type == 'unit' then
		global.kills_units[nforce] = global.kills_units[nforce] + 1
		if player then global.personal_kill_units[plname]=global.personal_kill_units[plname]+1 end
		elseif entity.type == 'unit-spawner' then
		XP = XP * 3
		global.kills_spawner[nforce] = global.kills_spawner[nforce] +1
		if player then global.personal_kill_spawner[plname]=global.personal_kill_spawner[plname]+1 end
		elseif entity.type == 'turret' then
		global.kills_worms[nforce] = global.kills_worms[nforce] +1
		if player then global.personal_kill_turrets[plname]=global.personal_kill_turrets[plname]+1 end
		XP = XP * 2
		end
	
--	if XP > 999999 then XP=999999 end
	XP = math.ceil((1+force.evolution_factor) * global.XP_Mult * XP/3) 
	if XP<1 then XP=1 end

	local teamxp = true
		if plname then
			if global.personalxp.XP[plname] then
				global.personalxp.XP[plname] = global.personalxp.XP[plname] + XP
				printXP(player,XP)
				teamxp = false
				end			
			end

		if teamxp and global.XP_KILL_HP[nforce] then
			XP=math.ceil(XP/3)
			global.XP_KILL_HP[nforce] = global.XP_KILL_HP[nforce] +XP
			global.XP[nforce] = global.XP[nforce] + XP
			end

end
end
end
end
global.last_overkill=nil
end
end


--- XP FOR KILL
script.on_event(defines.events.on_entity_died, function(event)
if not event.force then return end


local force=event.force  -- force that kill
local killer=event.cause


--if event.entity.force.name == 'enemy' and force~='neutral' and force~='enemy' then --aliens
if killer and killer.valid and global.kills_units[force.name] and event.entity.force~=game.forces.neutral then
	if event.entity.prototype and event.entity.prototype.max_health and (not force.get_friend(event.entity.force)) then

		if killer.type=='car' then 
			if killer.get_driver() and killer.get_driver().valid then 
				killer = killer.get_driver() 
				elseif killer.get_passenger() and killer.get_passenger().valid then 
				killer = killer.get_passenger() 
				end
			end
		GetXPByKill(event.entity,killer,force)
		end
	end

if not killer then
   if global.kills_units[force.name] and event.entity.force~=game.forces.neutral then
   GetXPByKill(event.entity,killer,force)
   end end

end,
 {{filter = "type", type = "unit"}, {filter = "type", type = "unit-spawner"}, 
		{filter = "type", type = "spider-vehicle"},
		{filter = "type", type = "car"},{filter = "type", type = "electric-turret"}, 
		{filter = "type", type = "artillery-turret"}, {filter = "type", type = "ammo-turret"},  
		{filter = "type", type = "fluid-turret"}, {filter = "type", type = "turret"}, 
		{filter = "type", type = "character"}}
		) -- event filters 



function create_crithit_effect(entity,level,damage)
if string.find(entity.type, 'unit') or entity.type == 'character' or entity.type == 'turret' then
	create_blood_particles(entity.surface, 300+level*10, entity.position,2+level/10)
	create_guts_particles(entity.surface, 40 + level*2, entity.position,2+level/10)
	else
	create_remnants_particles(entity.surface, level, entity.position,1+level/10)
	end
entity.surface.play_sound{path='utility/axe_fighting',position=entity.position,volume_modifier=1}
if global.setting_print_critical then
entity.surface.create_entity{name = "flying-text", position = entity.position, text = math.ceil(damage), color = colors.red}
end
end

local crit = false
if crit == true then 
-- damage bonus,  criticals , natural armor
script.on_event(defines.events.on_entity_damaged, function(event)
local entity = event.entity
local damage_type = event.damage_type
local original_damage_amount = event.original_damage_amount
local cause = event.cause


if cause and cause.valid and entity and entity.valid and entity.health>0 and damage_type and original_damage_amount then
	
	-- NATURAL ARMOR
	if event.final_damage_amount>0 and entity.type == 'character' then
		local player = entity.player
		if player and player.valid then
			local armor_lv = global.personalxp.LV_Armor_Bonus[player.name]
			if armor_lv>0 then
				local bonus = (global.RPG_Bonus.LV_Armor_Bonus * armor_lv)
				local recover = event.final_damage_amount*bonus/100
				entity.health = entity.health + recover
				end
			end
		end

	-- DAMAGE BONUS 
	if cause.type == 'character' and damage_type.name~='poison' and damage_type.name~='cold' then
		local player = cause.player
		if player and player.valid then
		local dmg_lv = global.personalxp.LV_Damage_Bonus[player.name]	
		local critical_lv = global.personalxp.LV_Damage_Critical[player.name]
		local new_damage = original_damage_amount
		if dmg_lv>0 then
			local bonus = 1+ (global.RPG_Bonus.LV_Damage_Bonus * dmg_lv/100)
			new_damage = original_damage_amount * bonus
			end
		
		-- CRITICAL HITS
		if critical_lv>0 and (string.find(entity.type, 'unit') or string.find(entity.type, 'turret') or entity.type=='car' 
			or entity.type=='character' or entity.type=='spider-vehicle')  then
		local proba = 100
		if damage_type.name=='fire' then proba=proba*60 end --because damage per tick
		if math.random(proba)<=critical_lv * global.RPG_Bonus['LV_Damage_Critical'] then
			new_damage = math.ceil(new_damage * (5 + critical_lv/2))
			
			if (not global.last_critical_effect_from[player.name]) or global.last_critical_effect_from[player.name]+60*stg_critical_interval<game.tick then
				global.last_critical_effect_from[player.name]=game.tick 
				create_crithit_effect(entity,critical_lv,new_damage)
				end
			end
			end
		
		if new_damage > original_damage_amount then 
			local dif = new_damage - original_damage_amount
			if entity.health < dif then  -- give kill xp to player because the extra damage will kill entity
				GetXPByKill(entity,cause,cause.force)
				global.last_overkill = event.entity
				end
			if entity.valid then 
				entity.health = entity.health + event.final_damage_amount
				entity.damage(new_damage,player.force,damage_type.name)	-- this fires the event again	
				end
			end
		end
		end
	
	end
	

end,  {{filter = "type", type = "unit"}, {filter = "type", type = "unit-spawner"}, 
		{filter = "type", type = "wall"}, {filter = "type", type = "gate"}, {filter = "type", type = "spider-vehicle"},
		{filter = "type", type = "car"},{filter = "type", type = "electric-turret"}, 
		{filter = "type", type = "artillery-turret"}, {filter = "type", type = "ammo-turret"},  
		{filter = "type", type = "fluid-turret"}, {filter = "type", type = "turret"}, 
		{filter = "type", type = "character"}}) -- event filters 
end



-- XP by research
script.on_event(defines.events.on_research_finished, function(event)
if global.setting_allow_xp_by_tech and game.tick > 3600 * 2 then

if event.research.force then
	local force = event.research.force.name
	if force~='neutral' and force~='enemy' then
	if global.XP_TECH[force] then
		local techXP = event.research.research_unit_count * #event.research.research_unit_ingredients
		techXP = math.ceil(global.XP_Mult * techXP * (1+ (6*game.forces["enemy"].evolution_factor)))		
		global.XP_TECH[force] = global.XP_TECH[force]  +techXP
		global.XP[force] = global.XP[force]  +techXP 
		end
	end
	end
end
end)



-- XP by Rocket
script.on_event(defines.events.on_rocket_launched, function(event)
if global.setting_allow_xp_by_rocket then
local rocket = event.rocket
local force = rocket.force
local XP

	for p, PL in pairs (force.connected_players) do 
		local r_count = global.personalxp.rocketsXP_count[PL.name]
		if r_count == nil then r_count=0 end
		XP = math.ceil(global.XP_Mult * global.personalxp.XP[PL.name]/(5+(r_count*2))) --20% inicial
		global.personalxp.XP[PL.name] = global.personalxp.XP[PL.name] + XP
		printXP(PL,XP)
		global.personalxp.rocketsXP_count[PL.name] = r_count+1
	end
end
end)


--- XP FOR Mining rocks, trees
function XPByMiningRT(player,ent)
local XP = 0

	
if  ent.prototype.max_health then 
	XP=ent.prototype.max_health
	if ent.type=='tree' then XP=XP/100 else XP=XP/400 end
	end


if XP>0 then
   local plname = player.name
   XP = math.ceil(XP * global.personalxp.Level[plname] * global.XP_Mult)
   global.personalxp.XP[plname] = global.personalxp.XP[plname] + XP
   printXP(player,XP)
   end

end


script.on_event(defines.events.on_player_mined_entity, function(event)
if global.setting_allow_xp_by_mining then
local player = game.players[event.player_index]	
if not player.valid then return end

local ent = event.entity
local name= ent.name

if ent.type=='tree' or (ent.type=='simple-entity' and name:find('rock')) then 
	XPByMiningRT(player,ent)
	end
end
end,
 {{filter = "type", type = "tree"}, {filter = "type", type = "simple-entity"}}
)













-- INTERFACE  --
--------------------------------------------------------------------------------------
-- /c remote.call("RPG","TeamXP","player",1150)
local interface = {}

-- Give XP to Team (may be negative)
function interface.TeamXP(forcename,XP)
global.XP[forcename] = global.XP[forcename] + XP
XP_UPDATE_tick()
end

-- Give XP to a player (may be negative)
function interface.PlayerXP(playername,XP)
global.personalxp.XP[playername] = global.personalxp.XP[playername] + XP
printXP(game.players[playername],XP)
XP_UPDATE_tick()
end

-- Give a fixed XP multiplyed by player level (may be negative)
function interface.PlayerXPPerLevel(playername,XP)
global.personalxp.XP[playername] = global.personalxp.XP[playername] + (XP * global.personalxp.Level[playername])
XP_UPDATE_tick()
end

-- Player gain one level
function interface.PlayerGainLevel(playername)
if global.personalxp.XP[playername] then
	local XP = CalculateXP_GAIN_LV(playername)
	global.personalxp.XP[playername] = global.personalxp.XP[playername] + XP
	XP_UPDATE_tick()
end
end


-- Give player XP % of his current XP level bar   - perc=0 to 1, eg 0.25
function interface.PlayerXPPercCurrentBar(playername,Perc)
if global.personalxp.XP[playername] then
	local XP = CalculateXP_PERCENT_CURRENT_LV(playername,Perc)
	global.personalxp.XP[playername] = global.personalxp.XP[playername] + XP
	printXP(game.players[playername],XP)
	XP_UPDATE_tick()
end
end



-- Give player XP % of his own XP
function interface.PlayerXPPerc(playername,Perc)
local XP = math.ceil(global.personalxp.XP[playername]*Perc/100) 
global.personalxp.XP[playername] = global.personalxp.XP[playername] + XP
printXP(game.players[playername],XP)
XP_UPDATE_tick()
end

-- Penalty XP for a % of his own XP
function interface.PlayerXPPenalPerc(playername,Perc)
global.personalxp.XP[playername] = global.personalxp.XP[playername] - math.ceil(global.personalxp.XP[playername]*Perc/100) 
XP_UPDATE_tick()
end


-- Give all force players a XP% of his own XP
function interface.TeamXPPerc(forcename,Perc)
local XP
	for p, PL in pairs (game.forces[forcename].connected_players) do 
		XP = math.ceil(global.personalxp.XP[PL.name]*Perc/100) 
		global.personalxp.XP[PL.name] = global.personalxp.XP[PL.name] + XP
		printXP(PL,XP)
	end
XP_UPDATE_tick()
end

-- Used only for compatibility with other mods
function interface.OtherEventsByPlayer(player,event_name,parameter)
if event_name=='mine_rock' then 
   XPByMiningRT(player.name,parameter) 
   end
if event_name=='adjust_player_stats' then 
   AdjustPlayerStat(player,parameter) 
   end
end


function interface.ResetAll()
ResetAll()
end


interface.CopyPlayerStats = CopyPlayerStats
function interface.PastePlayerStats(playername,stats)
PastePlayerStats(playername,stats)
end











commands.add_command('rpg-reset-points', 'Reconstruct XP table and reset all habilities to zero. Players can spent all points again', function(event)
local player = game.players[event.player_index]
if player.admin then 
	ResetPointSpent()
	game.print({'xp_reset_altert'})
	end
end)
commands.add_command('rpg-reset-all', 'Reconstruct XP table and reset everything to zero, as a new game', function(event)
local player = game.players[event.player_index]
if player.admin then
	ResetAll()
	game.print({'xp_reset_altert'})
	end
end)
commands.add_command('rpg-players-list', 'List all players', function(event)
local player = game.players[event.player_index]
ListAll(player)
end)
commands.add_command('rpg-listXPTable', 'List XP table', function(event)
local player = game.players[event.player_index]
ListXPTable(player) 
end)











--[[ HOW TO subscribe to my 2 events below:
	script.on_event(remote.call("RPG", "get_on_player_updated_status"), function(event)
		--do your stuff
	end)
	WARNING: this has to be done within on_init and on_load, otherwise the game will error about the remote.call
	
	if your dependency on my mod is optional, remember to check if the remote interface exists before calling it:
	if remote.interfaces["RPG"] then
		--interface exists
	end]]
	
function interface.get_on_player_updated_status()
return on_player_updated_status
end
		-- Returns :
		-- event.player_index = Index of the player that upgraded an attribute
		-- event.level        = Player current XP Level 
		-- event.attribute    = The attribute that was upgraded

function interface.get_on_player_level_up()
return on_player_level_up
end
		-- Returns :
		-- event.player_index = Index of the player that has just leveled up
		-- event.level        = Player current XP Level 


--other mods
--jetpack
function interface.on_character_swapped(event)
--local new_unit_number = event.new_unit_number
--local old_unit_number = event.old_unit_number
local new_character = event.new_character
local old_character = event.old_character
if new_character and new_character.valid then 
	local player = new_character.player
	if player and player.valid then 
		
		UpdatePlayerLvStats(player, true) 
		
		
		end
	end
end




remote.add_interface("RPG", interface )
