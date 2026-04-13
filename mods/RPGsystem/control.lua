local mod_gui = require("__core__/lualib/mod-gui")
local potion_duration = 5 * 60 * 60
local potion_speed_bonus = 1.5
require("__core__/lualib/util")
require("particles")
--local modsprites = require("prototypes.sprites")

local format_number = util.format_number
local stg_magic_interval = 10
local stg_critical_interval = 1.5
--[[
  ** RPG SYSTEM **
by MFerrari
]]
function Log(what)
	helpers.write_file("rpg.log", serpent.block(what), true)
end

function in_list(list, obj)
	for k, obj2 in pairs(list) do
		if obj2 == obj then
			return k
		end
	end
	return nil
end

function short_number_string(number)
	local steps = {
		{ 1, "" },
		{ 1e3, "k" },
		{ 1e6, "m" },
		{ 1e9, "g" },
		{ 1e12, "t" },
	}
	for _, b in ipairs(steps) do
		if b[1] <= number + 1 then
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
	local result = 0
	if number then
		if number < 1000000000 then
			result = format_number(number)
		else
			result = short_number_string(number)
		end
	end
	return result
end

local colors = {
	white = { r = 1, g = 1, b = 1 },
	black = { r = 0, g = 0, b = 0 },
	darkgrey = { r = 0.25, g = 0.25, b = 0.25 },
	grey = { r = 0.5, g = 0.5, b = 0.5 },
	lightgrey = { r = 0.75, g = 0.75, b = 0.75 },

	red = { r = 1, g = 0, b = 0 },
	darkred = { r = 0.5, g = 0, b = 0 },
	lightred = { r = 1, g = 0.5, b = 0.5 },
	green = { r = 0, g = 1, b = 0 },
	darkgreen = { r = 0, g = 0.5, b = 0 },
	lightgreen = { r = 0.5, g = 1, b = 0.5 },
	blue = { r = 0, g = 0, b = 1 },
	darkblue = { r = 0, g = 0, b = 0.5 },
	lightblue = { r = 0.5, g = 0.5, b = 1 },

	orange = { r = 1, g = 0.55, b = 0.1 },
	yellow = { r = 1, g = 1, b = 0 },
	pink = { r = 1, g = 0, b = 1 },
	purple = { r = 0.6, g = 0.1, b = 0.6 },
	brown = { r = 0.6, g = 0.4, b = 0.1 },
}

--prototypes.sprites.charxpmod_space_suit.layers[2].tint = {1,0,0,0.5}

-- CUSTOM EVENT HANDLING --
--(remote interface is lower in the file, there I describe how to subscribe to my events)
-- if your mod alters the character bonus settings, then you should get_on_player_updated_status to make required adjusts to your mod, if necessary
local on_player_updated_status = script.generate_event_name() --uint
local on_player_level_up = script.generate_event_name() --uint

function printXP(player, XP)
	if player and player.valid then
		if
			settings.get_player_settings(player)["charxpmod_print_xp_user"].value
			and player.character
			and player.character.valid
		then
			rendering.draw_text({
				text = "+" .. RPG_format_number(XP) .. " XP",
				color = colors.yellow,
				surface = player.character.surface,
				target = { entity = player.character, offset = { -2 + math.random() * 4, -3 + math.random() * 2 } },
				time_to_live = 70,
			})
		end
	end
end

function ResetXPTables()
	local xp = settings.startup["charxpmod_xpinilevel"].value
	storage.xp_table = { [1] = xp }
	local mp = settings.startup["charxpmod_xpmult"].value
	local red = settings.startup["charxpmod_xp_mp_reductor"].value
	--local maxL = settings.startup["charxpmod_xp_maxlevel"].value

	local maxi = storage.setting_max_player_level

	local m
	for k = 2, maxi do
		m = mp - k * (red - red * k / maxi) -- (Multiplier - Level * (reductor-reductor*Level/100))
		xp = math.ceil(xp * m)
		if (xp / storage.xp_table[k - 1]) < 1.02 then
			xp = storage.xp_table[k - 1] * 1.02
		end
		xp = math.ceil(xp)
		storage.xp_table[k] = xp
	end
	storage.max_xp = xp
end

function SetForceValues(name)
	storage.kills_spawner[name] = 0
	storage.kills_units[name] = 0
	storage.kills_worms[name] = 0
	storage.XP[name] = 0
	storage.XP_GANHO[name] = 0
	storage.XP_TECH[name] = 0
	storage.XP_LEVEL[name] = 1
	storage.XP_LEVEL_MIN[name] = 0
	storage.XP_KILL_HP[name] = 0
	storage.XP_MAX_PLAYTIME[name] = 0
	storage.XP_AVG_PLAYTIME[name] = 0
end

function CheckAddPlayerStatus(name)
	storage.personalxp[name] = storage.personalxp[name] or {}
	for _, player in pairs(game.players) do
		storage.personalxp[name][player.name] = storage.personalxp[name][player.name] or 0
		--game.print(name .. player.name .. storage.personalxp[name][player.name])
	end
end

function VersionChange()
	CheckAddPlayerStatus("rocketsXP_count")
end

function SetupPlayer(player, ResetXP)
	local name = player.name

	if ResetXP then
		storage.personalxp.XP[name] = 0
		storage.personalxp.Death[name] = 0
		storage.personal_kill_units[name] = 0
		storage.personal_kill_spawner[name] = 0
		storage.personal_kill_turrets[name] = 0
	end

	storage.personalxp.Level[name] = 1
	storage.potion_effects[name] = {}
	Reset_Character_Bonuses(player.character)

	for k = 1, #storage.Player_Attributes do
		local attrib = storage.Player_Attributes[k]
		storage.personalxp[attrib][name] = 0
	end

	storage.personalxp.opt_Pick_Extender[name] = false

	UpdatePlayerLvStats(player)
end

function CheckPlayers()
	for _, player in pairs(game.players) do
		if not storage.personalxp.Level[player.name] then
			SetupPlayer(player, true)
		end

		if not storage.personal_kill_units[player.name] then
			storage.personal_kill_units[player.name] = 0
			storage.personal_kill_spawner[player.name] = 0
			storage.personal_kill_turrets[player.name] = 0
		end

		InitPlayerGui(player)
	end
end

function CheckPlayer(player)
	if not storage.personalxp.Level[player.name] then
		SetupPlayer(player, true)
	end
end

function ReadRunTimeSettings(event)
	storage.setting_print_critical = settings.global["charxpmod_print_critical"].value
	storage.setting_afk_time = settings.global["charxpmod_afk"].value
	storage.setting_time_ratio_xp = settings.global["charxpmod_time_ratio_xp"].value
	storage.setting_death_penal = settings.global["charxpmod_death_penal"].value

	storage.setting_allow_xp_by_tech = settings.global["charxpmod_allow_xp_by_tech"].value
	storage.setting_allow_xp_by_kill = settings.global["charxpmod_allow_xp_by_kill"].value
	storage.setting_allow_xp_by_rocket = settings.global["charxpmod_allow_xp_by_rocket"].value
	storage.setting_allow_xp_by_mining = settings.global["charxpmod_allow_xp_by_mining"].value

	if event and event.setting_type == "runtime-per-user" and event.setting == "charxpmod_hide_xp_panel" then
		local player = game.players[event.player_index]
		player.gui.top.chartopframe.visible = not settings.get_player_settings(player)["charxpmod_hide_xp_panel"].value
	end
end

function XPModSetup()
	storage.handle_respawn = storage.handle_respawn or {}
	storage.potion_effects = storage.potion_effects or {}
	storage.last_critical_effect_from = storage.last_critical_effect_from or {}
	storage.last_magical_effect_from = storage.last_magical_effect_from or {}

	storage.Player_Attributes = {
		"LV_Health_Bonus",
		"LV_Armor_Bonus",
		"LV_Damage_Bonus",
		"LV_Damage_Critical",
		"LV_Run_Speed",
		"LV_Magic",
		"LV_Craft_Speed",
		"LV_Mining_Speed",
		"LV_Inv_Bonus",
		"LV_InvTrash_Bonus",
		"LV_Robot_Bonus",
		"LV_Reach_Dist",
	}

	storage.XP_Mult = settings.startup["charxpmod_xp_multiplier_bonus"].value
	--storage.setting_allow_damage_attribs =  settings.startup["charxpmod_enable_damage_attribs"].value
	storage.setting_max_player_level = settings.startup["charxpmod_xp_maxlevel"].value
	storage.setting_max_level_ability = settings.startup["charxpmod_xp_maxlevel_ability"].value

	ReadRunTimeSettings()

	if storage.CharXPMOD == nil then
		storage.CharXPMOD = 1
		storage.kills_spawner = {}
		storage.kills_units = {}
		storage.kills_worms = {}
		storage.XP = {}
		storage.XP_GANHO = {}
		storage.XP_KILL_HP = {}
		storage.XP_TECH = {}
		storage.XP_LEVEL = {}
		storage.XP_LEVEL_MIN = {}
		storage.XP_MAX_PLAYTIME = {}
		storage.XP_AVG_PLAYTIME = {}

		storage.personalxp = {}
		storage.personalxp.Level = {}
		storage.personalxp.XP = {}
		storage.personalxp.Death = {}

		for k = 1, #storage.Player_Attributes do
			storage.personalxp[storage.Player_Attributes[k]] = {}
		end

		storage.personalxp.opt_Pick_Extender = {}

		for name, force in pairs(game.forces) do
			if name ~= "neutral" and name ~= "enemy" then
				SetForceValues(name)
			end
		end
	end

	ResetXPTables()

	storage.RPG_Bonus = {}
	for k = 1, #storage.Player_Attributes do
		local attrib = storage.Player_Attributes[k]
		storage.RPG_Bonus[attrib] = settings.startup["charxpmod_" .. attrib].value
		CheckAddPlayerStatus(attrib)
	end

	storage.personal_kill_units = storage.personal_kill_units or {}
	storage.personal_kill_spawner = storage.personal_kill_spawner or {}
	storage.personal_kill_turrets = storage.personal_kill_turrets or {}

	VersionChange()
	CheckPlayers()

	-- update rocket count for surface
	for pname, v in pairs(storage.personalxp.rocketsXP_count) do
		if type(v) == "number" then
			storage.personalxp.rocketsXP_count = { nauvis = v }
		end
	end
end

function ResetAll()
	ResetXPTables()
	for name, force in pairs(game.forces) do
		if name ~= "neutral" and name ~= "enemy" then
			SetForceValues(name)
		end
	end
	for _, player in pairs(game.players) do
		SetupPlayer(player, true)
		UpdatePanel(player)
	end
end

function ResetPointSpent()
	ResetXPTables()

	for _, player in pairs(game.players) do
		SetupPlayer(player, false)
	end
end

function InitPlayerGui(player)
	local name = player.name

	-- close main panel
	local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"]
	if frame then
		frame.destroy()
	end

	-- remove previous versions
	if player.gui.top.chartopframe then
		player.gui.top.chartopframe.destroy()
	end
	if player.gui.top.btcharxp then
		player.gui.top.btcharxp.destroy()
	end

	-- create new ones
	local Topframe = player.gui.top.add({
		name = "chartopframe",
		direction = "horizontal",
		type = "frame",
		style = mod_gui.frame_style,
	})
	Topframe.style.minimal_height = 30
	-- 	Topframe.style.maximal_height = 37
	Topframe.style.minimal_width = 150
	--	Topframe.style.maximal_width  = 250
	--snouz
	Topframe.style.margin = { 0, 10, 5, 10 }
	Topframe.style.padding = { 0, 9, 0, 0 }

	Topframe.add({
		name = "btcharxp",
		type = "sprite-button",
		sprite = "entity/character",
		tooltip = { "panel-title", player.name },
		style = mod_gui.top_button_style,
	}) -- "mod_gui_button"}

	local tabFrame = Topframe.add({ type = "table", name = "tabtopframexp", column_count = 1 })
	Level = storage.personalxp.Level[name]
	local pnivel = tabFrame.add({ type = "label", name = "chartoplvtxt", caption = { "actual_lv", Level } })
	pnivel.style.font = "charxpmod_font_17b"
	local TopXPbar = tabFrame.add({ type = "progressbar", name = "TopXPbar" })
	TopXPbar.style.width = 110
	UpdatePanel(player)
end

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

function RatioXP(player)
	local ratioXP = 1
	if storage.setting_time_ratio_xp and storage.XP_AVG_PLAYTIME[player.force.name] > 0 then
		ratioXP = player.online_time / storage.XP_AVG_PLAYTIME[player.force.name]
		if ratioXP >= 1.10 then
			ratioXP = 1.10
		elseif ratioXP < 0.05 then
			ratioXP = 0.05
		end
	end
	return ratioXP
end

function XP_Player_upd()
	for name, force in pairs(game.forces) do
		if name ~= "neutral" and name ~= "enemy" then
			local cp = #force.connected_players
			local afk = storage.setting_afk_time
			if cp > 0 then
				local XP = storage.XP[name] --math.ceil(storage.XP[name] / cp)

				if XP > 0 then
					for p, PL in pairs(force.connected_players) do
						if afk == 0 or PL.afk_time < afk * 3600 then
							local ratioXP = RatioXP(PL)
							XP = math.ceil(XP * ratioXP)
							storage.personalxp.XP[PL.name] = storage.personalxp.XP[PL.name] + XP
							printXP(PL, XP)
							UpdatePanel(PL)
						end
					end
				end
				storage.XP[name] = 0
			end
		end
	end
end

function XP_PlayerLv_upd()
	for _, player in pairs(game.players) do
		if player.connected then
			local name = player.name
			local Lv = storage.personalxp.Level[name]
			if storage.personalxp.XP[name] > storage.max_xp then
				storage.personalxp.Level[name] = storage.setting_max_player_level
			else
				for L = Lv, #storage.xp_table do
					if storage.personalxp.XP[name] < storage.xp_table[L] then
						storage.personalxp.Level[name] = L
						break
					end
				end
			end

			if storage.personalxp.Level[name] > Lv then
				--player.print({'player_lv_up',storage.personalxp.Level[name]})
				--mod_gui.get_button_flow(player).focus()
				--player.gui.top.chartopframe.focus()
				player.play_sound({ path = "player_level_up", volume_modifier = 0.85 })
				script.raise_event(
					on_player_level_up,
					{ player_index = player.index, player_level = storage.personalxp.Level[name] }
				)
			end
			UpdatePanel(player)
		end
	end
end

function XP_Time_upd()
	for name, force in pairs(game.forces) do
		if name ~= "neutral" and name ~= "enemy" then
			local PT
			local TT = 0
			local QP = 0

			for p, PL in pairs(force.players) do
				PT = PL.online_time
				if PT > storage.XP_AVG_PLAYTIME[name] / 20 then -- a player time count for avg if he has at least 5% of the avg time
					TT = TT + PT
					QP = QP + 1
				end

				if storage.XP_MAX_PLAYTIME[name] < PT then
					storage.XP_MAX_PLAYTIME[name] = PT
				end
			end
			if QP > 0 then
				storage.XP_AVG_PLAYTIME[name] = TT / QP
			end
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
	for k = 1, #storage.Player_Attributes do
		local attrib = storage.Player_Attributes[k]
		sum = sum + storage.personalxp[attrib][name]
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
	local Level = storage.personalxp.Level[name]
	local HP = 0

	local ptime = player.online_time
	local txtPTime = {
		"time-played",
		string.format(
			"%d:%02d:%02d",
			math.floor(ptime / 216000),
			math.floor(ptime / 3600) % 60,
			math.floor(ptime / 60) % 60
		),
	}

	local PontosXP = Level - 1 - SumPointSpent(name)
	if PontosXP < 0 then
		PontosXP = 0
	end

	frame.add({ type = "line" })

	local tabChar = frame.add({ type = "table", name = "tab_tbchar", column_count = 2 })

	local frametabChar = tabChar.add({ name = "frametabChar", type = "frame", style = mod_gui.frame_style })
	if player.character and player.character.valid then
		HP = math.ceil(player.character.health)

		local cam = frametabChar.add({ type = "entity-preview", name = "rpg_player_preview" })

		--local cam = frametabChar.add({ type="camera", name="rpg_player_preview", position = player.position, zoom = 0.75 })

		cam.style.width = 110
		cam.style.height = 110
		cam.entity = player.character
		cam.style.padding = { 0, -10, 0, -10 }
		cam.style.margin = { 5, 0, -5, 0 }
	else
		local rpgportrait = frametabChar.add({ type = "sprite", sprite = "charxpmod_space_suit" })
		rpgportrait.style.padding = { 0, -10, 0, -10 }
		rpgportrait.style.margin = { 5, 0, -5, 0 }
		--rpgportrait.style.width = 44.8
		--rpgportrait.style.height = 84
		--rpgportrait.style.margin = {2,25,4,20}
	end

	local tabScroll = tabChar.add({
		type = "scroll-pane",
		name = "tabScroll2",
		vertical_scroll_policy = "auto",
		horizontal_scroll_policy = "auto",
	})

	--tabScroll.style.height = 120
	tabScroll.style.padding = { -5, 0, 5, 10 }

	local tabPName = tabScroll.add({ type = "table", name = "tab_pname", column_count = 1 })

	local pnivel = tabPName.add({ type = "label", name = "ocharlevel", caption = { "actual_lv", Level } })
	pnivel.style.font = "charxpmod_font_30"
	--pnivel.style.font_color = player.color
	pnivel.style.bottom_padding = -5

	-- XP RATIO
	local ratioXP = RatioXP(player)
	ratioXP = math.floor(ratioXP * 100)

	local tabStats = tabScroll.add({ type = "table", name = "tabStats", column_count = 1 })

	local wd = 160
	tabStats.add({ type = "label", name = "STT1", caption = txtPTime }).style.width = wd
	tabStats.add({ type = "label", name = "STT3", caption = { "xp_ratio", ratioXP } }) --.style.width = wd
	tabStats.add({ type = "label", name = "STT2", caption = { "xp_deaths", storage.personalxp.Death[name] } }).style.width =
		wd
	tabStats.add({ type = "label", name = "STT5", caption = "HP: " .. format_number(HP) }).style.width = wd

	local pbvalue = CalculateXP_PB(player.name)
	local XP = storage.personalxp.XP[name]
	local NextLevel = storage.xp_table[Level]

	local NextLtxt = RPG_format_number(NextLevel)
	if XP >= storage.max_xp then
		NextLtxt = "MAX"
	end

	frame.add({ type = "line" })

	---------------XP NUMBERS

	local flowXP = frame.add({ type = "flow", direction = "horizontal" })
	flowXP.style.width = 450
	local currXP = flowXP.add({ type = "label", name = "lbxpatual", caption = "XP: " .. RPG_format_number(XP) }) --.style.font="charxpmod_font_17"
	currXP.style.font = "default-bold"
	local stretchableFlow = flowXP.add({ type = "flow", direction = "horizontal" })
	stretchableFlow.style.horizontally_stretchable = true
	local flownextXP = flowXP.add({ type = "flow", direction = "horizontal" })
	flownextXP.style.horizontal_align = "right"
	flownextXP.style.width = 200
	local nextXP = flownextXP.add({ type = "label", caption = { "next_lv", NextLtxt } }) --.style.font="charxpmod_font_17"

	----------------XP BAR

	local tabBar = frame.add({ type = "table", column_count = 1 })

	local bar =
		tabBar.add({ type = "progressbar", value = pbvalue, name = "tab_XPbar", style = "achievement_progressbar" })
	bar.style.width = 444

	frame.add({ type = "line" })

	frame.add({ type = "label", name = "lbxPAGastar", caption = { "xp_points", PontosXP } }).style.font =
		"charxpmod_font_20"

	-- LEVELS / UPGRADES
	local tabUpgrades = frame.add({ type = "table", name = "tabUpgrades", column_count = 6 })
	tabUpgrades.style.horizontal_spacing = 10
	tabUpgrades.style.vertical_spacing = 10

	local Max = storage.setting_max_level_ability
	local custo = 1
	local vchar
	local at_level
	local attrib
	local bonus, Tbonus

	for A = 1, #storage.Player_Attributes do
		attrib = storage.Player_Attributes[A]
		local enabled = true
		--[[if (attrib=="LV_Armor_Bonus" or attrib=="LV_Damage_Bonus" or attrib=="LV_Damage_Critical")
		and (not storage.setting_allow_damage_attribs) then enabled = false end]]

		if storage.RPG_Bonus[attrib] == 0 then
			enabled = false
		end

		if enabled then
			vchar = "global.personalxp." .. attrib
			at_level = storage.personalxp[attrib][name]
			bonus = storage.RPG_Bonus[attrib]
			Tbonus = at_level * bonus

			local tabAttrib = tabUpgrades.add({ type = "table", column_count = 1 })
			tabAttrib.style.horizontal_align = "center"

			local framebtAttributetext = tabAttrib.add({ direction = "horizontal", type = "frame" })
			framebtAttributetext.style.width = 67 --67
			framebtAttributetext.style.horizontal_align = "center"
			framebtAttributetext.style.margin = { 0, 0, -5, 0 }
			framebtAttributetext.style.padding = { 0, 0, -5, 0 }
			local btAttributetext = framebtAttributetext.add({ type = "label", caption = { vchar } })
			btAttributetext.style.font = "charxpmod_font_12"
			btAttributetext.style.width = 60 --57
			btAttributetext.style.horizontal_align = "center"
			btAttributetext.style.margin = { 0, 0, 0, 0 }
			btAttributetext.style.padding = { 0, 0, 0, 0 }
			local btAttribute = tabAttrib.add({
				type = "sprite-button",
				sprite = attrib .. "_sprite",
				style = "rounded_button",
				name = "btLVU_" .. vchar,
				tooltip = { "xp_hint_" .. vchar, format_number(bonus), format_number(Tbonus) },
			})
			btAttribute.style.font = "charxpmod_font_icons"
			btAttribute.style.width = 67
			btAttribute.style.height = 67
			btAttribute.style.margin = { 0, 0, 0, 0 }
			btAttribute.style.padding = { 0, 0, 0, 0 }
			btAttribute.style.horizontal_align = "center"
			local frametxtAttLv = tabAttrib.add({ direction = "horizontal", type = "frame" })
			frametxtAttLv.style.width = 67
			frametxtAttLv.style.margin = { -5, 0, 0, 0 }
			frametxtAttLv.style.padding = { -5, 0, 0, 0 }
			frametxtAttLv.style.horizontal_align = "center"
			local txtAttLv = frametxtAttLv.add({ type = "label", caption = at_level })
			txtAttLv.style.font = "charxpmod_font_17"
			txtAttLv.style.width = 57
			txtAttLv.style.horizontal_align = "center"
			txtAttLv.style.margin = { 0, 0, 0, 0 }
			txtAttLv.style.padding = { 0, 0, 0, 0 }

			btAttribute.enabled = PontosXP >= custo and at_level < Max
		end
	end

	frame.add({ type = "line" })
	local pickbutton = frame.add({
		type = "checkbox",
		name = "cb_pick_extender",
		caption = { "xp_opt_Pick_Extender" },
		state = storage.personalxp.opt_Pick_Extender[name],
	})
	frame.add({ type = "line" })
end

function create_gui_box(player, caption)
	local frame = player.gui.left["rpg-list"]
	if frame then
		frame.destroy()
	end
	frame = player.gui.left.add({
		type = "frame",
		name = "rpg-list",
		direction = "vertical",
		style = mod_gui.frame_style,
		caption = caption,
	})
	local scroll = frame.add({
		type = "scroll-pane",
		name = "list-scroll",
		vertical_scroll_policy = "auto",
		horizontal_scroll_policy = "auto",
	})
	local bt_destroy_my_parent =
		frame.add({ type = "button", caption = { "close" }, name = "bt_destroy_my_parent", style = "back_button" })
	return scroll
end

function ListAll(player)
	local scroll = create_gui_box(player, { "players-list" })
	local force = player.force
	local tabpllst = scroll.add({ type = "table", name = "tabpllst", column_count = 3 })
	for p, PL in pairs(force.players) do
		local ptime = PL.online_time
		local txtPTime = string.format("%d:%02d", math.floor(ptime / 216000), math.floor(ptime / 3600) % 60)
		local ratioXP = math.floor(RatioXP(PL) * 100)
		tabpllst.add({
			type = "label",
			name = "pllstname" .. p,
			caption = PL.name .. " " .. storage.personalxp.Level[PL.name] .. " (" .. txtPTime .. " " .. ratioXP .. "%)",
		})
	end
end

function ListXPTable(player)
	local scroll = create_gui_box(player, "XP Level Table:")
	for k = 1, #storage.xp_table do
		local txt = "Level " .. k .. " - " .. storage.xp_table[k]
		scroll.add({ type = "label", caption = txt })
	end
end

function CalculateXP_PB(plname)
	local Level = storage.personalxp.Level[plname]
	local XP = storage.personalxp.XP[plname]
	if XP > storage.max_xp then
		XP = storage.max_xp
	end
	local NextLevel = storage.xp_table[Level]
	if not NextLevel then
		return
	end
	local XP_ant
	if Level == 1 then
		XP_ant = 0
	else
		XP_ant = storage.xp_table[Level - 1]
	end
	local Interval_XP = NextLevel - XP_ant
	local pbvalue = (XP - XP_ant) / Interval_XP
	return pbvalue
end

function CalculateXP_GAIN_LV(playername)
	local pbvalue = CalculateXP_PB(playername)
	local Level = storage.personalxp.Level[playername]
	local NextLevel = storage.xp_table[Level]
	if not NextLevel then
		return
	end
	local XP = storage.personalxp.XP[playername]

	local xp_to_next_level = NextLevel - XP
	local next_partial = 0

	if Level < storage.setting_max_player_level then
		next_partial = math.ceil((storage.xp_table[Level + 1] - NextLevel) * pbvalue)
	end

	return xp_to_next_level + next_partial
end

function CalculateXP_PERCENT_CURRENT_LV(playername, Perc)
	local Level = storage.personalxp.Level[playername]
	local GainXP = 0

	if Level < storage.setting_max_player_level then
		local NextLevel = storage.xp_table[Level]
		local PriorLVXP = 0
		if Level > 1 then
			PriorLVXP = storage.xp_table[Level - 1]
		end
		GainXP = math.ceil((NextLevel - PriorLVXP) * Perc)
	end

	return GainXP
end

function UpdatePanel(player, focus)
	-- BARRA DE XP  tabtopframexp
	local TopXPbar = player.gui.top.chartopframe.tabtopframexp.TopXPbar
	local txtlv = player.gui.top.chartopframe.tabtopframexp.chartoplvtxt

	local Level = storage.personalxp.Level[player.name]
	local pbvalue = CalculateXP_PB(player.name)

	txtlv.caption = { "actual_lv", Level }
	TopXPbar.value = pbvalue or 0

	local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"]
	if frame then
		expand_char_gui(player)
	end
end

function close_char_panel(player)
	local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"]
	if frame then
		frame.destroy()
	end
end

function reopen_char_panel(player)
	close_char_panel(player)
	expand_char_gui(player)
end

function open_close_char_gui(player)
	local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"]
	if frame then
		close_char_panel(player)
	else
		expand_char_gui(player)
	end
end

function expand_char_gui(player)
	local wid = 470
	local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"]
	if not frame then
		frame = player.gui.screen.add({
			type = "frame",
			name = "char-panel",
			direction = "vertical",
			style = mod_gui.frame_style,
		})
		frame.auto_center = true
		frame.style.minimal_height = 430
		--frame.style.maximal_height = 430
		frame.style.minimal_width = wid
		frame.style.maximal_width = 485

		local title_table =
			frame.add({ type = "table", name = "title_table", column_count = 4, draw_horizontal_lines = false })
		title_table.style.horizontally_stretchable = true
		title_table.style.column_alignments[1] = "left"
		title_table.style.column_alignments[2] = "right"
		title_table.style.column_alignments[3] = "right"
		title_table.style.column_alignments[4] = "right"
		title_table.drag_target = frame
		local title_frame = title_table.add({
			type = "frame",
			name = "title_frame",
			caption = { "panel-title", player.name },
			style = "ic_title_frame",
		}) --
		title_frame.ignored_by_interaction = true

		local tagfield =
			title_table.add({ type = "textfield", name = "ctag_field", text = player.tag, icon_selector = true })
		tagfield.style.width = 200
		tagfield.visible = false

		local edittag = title_table.add({
			name = "rpg_bt_edittag",
			type = "sprite-button",
			sprite = "utility/rename_icon",
			style = "shortcut_bar_button_small",
			tooltip = { "player_tag" },
		})
		local closeb = title_table.add({
			name = "rpg_bt_close",
			type = "sprite-button",
			sprite = "utility/close_black",
			style = "shortcut_bar_button_small",
		})
	end

	if frame.tabcharScroll then
		frame.tabcharScroll.destroy()
	end
	local tabcharScroll = frame.add({
		type = "scroll-pane",
		name = "tabcharScroll",
		vertical_scroll_policy = "auto",
		horizontal_scroll_policy = "auto",
	})
	tabcharScroll.style.minimal_height = 400
	--tabcharScroll.style.maximal_height = 1000
	tabcharScroll.style.minimal_width = wid - 15
	tabcharScroll.style.maximal_width = wid - 15

	update_char_panel(player)
end

function UpdatePlayerLvStats(player, skip_inv)
	local name = player.name

	if player.character then
		player.character.character_crafting_speed_modifier = player.character.character_crafting_speed_modifier
			+ storage.personalxp.LV_Craft_Speed[name] * storage.RPG_Bonus["LV_Craft_Speed"] / 100
		player.character.character_mining_speed_modifier = player.character.character_mining_speed_modifier
			+ storage.personalxp.LV_Mining_Speed[name] * storage.RPG_Bonus["LV_Mining_Speed"] / 100
		player.character.character_running_speed_modifier = player.character.character_running_speed_modifier
			+ storage.personalxp.LV_Run_Speed[name] * storage.RPG_Bonus["LV_Run_Speed"] / 100

		player.character.character_build_distance_bonus = player.character.character_build_distance_bonus
			+ storage.personalxp.LV_Reach_Dist[name] * storage.RPG_Bonus["LV_Reach_Dist"]
		player.character.character_reach_distance_bonus = player.character.character_reach_distance_bonus
			+ storage.personalxp.LV_Reach_Dist[name] * storage.RPG_Bonus["LV_Reach_Dist"]
		player.character.character_item_drop_distance_bonus = player.character.character_item_drop_distance_bonus
			+ storage.personalxp.LV_Reach_Dist[name] * storage.RPG_Bonus["LV_Reach_Dist"]
		player.character.character_resource_reach_distance_bonus = player.character.character_resource_reach_distance_bonus
			+ storage.personalxp.LV_Reach_Dist[name] * storage.RPG_Bonus["LV_Reach_Dist"]

		if not skip_inv then
			player.character.character_inventory_slots_bonus = player.character.character_inventory_slots_bonus
				+ storage.personalxp.LV_Inv_Bonus[name] * storage.RPG_Bonus["LV_Inv_Bonus"]
		end
		player.character.character_trash_slot_count_bonus = player.character.character_trash_slot_count_bonus
			+ storage.personalxp.LV_InvTrash_Bonus[name] * storage.RPG_Bonus["LV_InvTrash_Bonus"]
		player.character.character_maximum_following_robot_count_bonus = player.character.character_maximum_following_robot_count_bonus
			+ storage.personalxp.LV_Robot_Bonus[name] * storage.RPG_Bonus["LV_Robot_Bonus"]
		player.character.character_health_bonus = player.character.character_health_bonus
			+ storage.personalxp.LV_Health_Bonus[name] * storage.RPG_Bonus["LV_Health_Bonus"]

		if storage.personalxp.opt_Pick_Extender[name] then
			player.character.character_item_pickup_distance_bonus = player.character.character_reach_distance_bonus
			player.character.character_loot_pickup_distance_bonus = player.character.character_reach_distance_bonus
		end
	end
end

local p_attribs = {
	"character_crafting_speed_modifier",
	"character_mining_speed_modifier",
	"character_running_speed_modifier",
	"character_reach_distance_bonus",
	"character_item_drop_distance_bonus",
	"character_resource_reach_distance_bonus",
	"character_inventory_slots_bonus",
	"character_trash_slot_count_bonus",
	"character_maximum_following_robot_count_bonus",
	"character_health_bonus",
	"character_item_pickup_distance_bonus",
}

function Reset_Character_Bonuses(character)
	if character and character.valid then
		for a = 1, #p_attribs do
			character[p_attribs[a]] = 0
		end
	end
end

function CopyPlayerStats(name)
	local player = game.players[name]
	if player and player.valid then
		local character_attribs = {}

		if player.character and player.character.valid then
			for a = 1, #p_attribs do
				table.insert(character_attribs, player.character[p_attribs[a]])
			end
		end

		local rpg_stats = {
			storage.personalxp.Level[name],
			storage.personalxp.XP[name],
			storage.personalxp.Death[name],
			storage.personalxp.opt_Pick_Extender[name],
			storage.personal_kill_units[name],
			storage.personal_kill_spawner[name],
			storage.personal_kill_turrets[name],
		}
		for k = 1, #storage.Player_Attributes do
			local attrib = storage.Player_Attributes[k]
			table.insert(rpg_stats, storage.personalxp[attrib][name])
		end
		return { character_attribs = character_attribs, rpg_stats = rpg_stats }
	end
end

function PastePlayerStats(name, status)
	local player = game.players[name]
	if player and player.valid and status then
		local character_attribs = status.character_attribs

		if player.character and player.character.valid then
			for a = 1, #p_attribs do
				player.character[p_attribs[a]] = character_attribs[a]
			end
		end

		local rpg_stats = status.rpg_stats
		storage.personalxp.Level[name] = rpg_stats[1]
		storage.personalxp.XP[name] = rpg_stats[2]
		storage.personalxp.Death[name] = rpg_stats[3]
		storage.personalxp.opt_Pick_Extender[name] = rpg_stats[4]
		storage.personal_kill_units[name] = rpg_stats[5]
		storage.personal_kill_spawner[name] = rpg_stats[6]
		storage.personal_kill_turrets[name] = rpg_stats[7]

		for k = 1, #storage.Player_Attributes do
			local attrib = storage.Player_Attributes[k]
			storage.personalxp[attrib][name] = rpg_stats[k + 7]
		end
		UpdatePanel(player)
	end
end

-- this will calculate the stat using sum, instead of replacing the value
-- used for compatibility with other mods
function AdjustPlayerStat(player, stat)
	local name = player.name

	if player.character ~= nil then
		if stat == "character_crafting_speed_modifier" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_Craft_Speed[name] * storage.RPG_Bonus["LV_Craft_Speed"] / 100
		elseif stat == "character_mining_speed_modifier" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_Mining_Speed[name] * storage.RPG_Bonus["LV_Mining_Speed"] / 100
		elseif stat == "character_running_speed_modifier" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_Run_Speed[name] * storage.RPG_Bonus["LV_Run_Speed"] / 100
		elseif stat == "character_build_distance_bonus" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_Reach_Dist[name] * storage.RPG_Bonus["LV_Reach_Dist"]
		elseif stat == "character_reach_distance_bonus" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_Reach_Dist[name] * storage.RPG_Bonus["LV_Reach_Dist"]
		elseif stat == "character_item_drop_distance_bonus" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_Reach_Dist[name] * storage.RPG_Bonus["LV_Reach_Dist"]
		elseif stat == "character_resource_reach_distance_bonus" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_Reach_Dist[name] * storage.RPG_Bonus["LV_Reach_Dist"]
		elseif stat == "character_inventory_slots_bonus" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_Inv_Bonus[name] * storage.RPG_Bonus["LV_Inv_Bonus"]
		elseif stat == "character_trash_slot_count_bonus" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_InvTrash_Bonus[name] * storage.RPG_Bonus["LV_InvTrash_Bonus"]
		elseif stat == "character_maximum_following_robot_count_bonus" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_Robot_Bonus[name] * storage.RPG_Bonus["LV_Robot_Bonus"]
		elseif stat == "character_health_bonus" then
			player.character[stat] = player.character[stat]
				+ storage.personalxp.LV_Health_Bonus[name] * storage.RPG_Bonus["LV_Health_Bonus"]
		elseif stat == "character_item_pickup_distance_bonus" then
			if storage.personalxp.opt_Pick_Extender[name] then
				player.character[stat] = player.character[stat]
					+ storage.personalxp.LV_Reach_Dist[name] * storage.RPG_Bonus["LV_Reach_Dist"]
			end
		elseif stat == "character_loot_pickup_distance_bonus" then
			if storage.personalxp.opt_Pick_Extender[name] then
				player.character[stat] = player.character[stat]
					+ storage.personalxp.LV_Reach_Dist[name] * storage.RPG_Bonus["LV_Reach_Dist"]
			end
		end
	end
end

function LevelUPPlayer(player, btname)
	local name = player.name

	for A = 1, #storage.Player_Attributes do
		local attrib = storage.Player_Attributes[A]

		if btname == "btLVU_global.personalxp." .. attrib then
			storage.personalxp[attrib][name] = storage.personalxp[attrib][name] + 1

			if btname == "btLVU_global.personalxp.LV_Craft_Speed" then
				player.character.character_crafting_speed_modifier = player.character.character_crafting_speed_modifier
					+ storage.RPG_Bonus[attrib] / 100
			end
			if btname == "btLVU_global.personalxp.LV_Mining_Speed" then
				player.character.character_mining_speed_modifier = player.character.character_mining_speed_modifier
					+ storage.RPG_Bonus[attrib] / 100
			end
			if btname == "btLVU_global.personalxp.LV_Run_Speed" then
				player.character.character_running_speed_modifier = player.character.character_running_speed_modifier
					+ storage.RPG_Bonus[attrib] / 100
			end

			if btname == "btLVU_global.personalxp.LV_Reach_Dist" then
				player.character.character_build_distance_bonus = player.character.character_build_distance_bonus
					+ storage.RPG_Bonus[attrib]
				player.character.character_reach_distance_bonus = player.character.character_reach_distance_bonus
					+ storage.RPG_Bonus[attrib]
				player.character.character_item_drop_distance_bonus = player.character.character_item_drop_distance_bonus
					+ storage.RPG_Bonus[attrib]
				player.character.character_resource_reach_distance_bonus = player.character.character_resource_reach_distance_bonus
					+ storage.RPG_Bonus[attrib]
			end

			if btname == "btLVU_global.personalxp.LV_Inv_Bonus" then
				player.character.character_inventory_slots_bonus = player.character.character_inventory_slots_bonus
					+ storage.RPG_Bonus[attrib]
			end

			if btname == "btLVU_global.personalxp.LV_InvTrash_Bonus" then
				player.character.character_trash_slot_count_bonus = player.character.character_trash_slot_count_bonus
					+ storage.RPG_Bonus[attrib]
			end

			if btname == "btLVU_global.personalxp.LV_Robot_Bonus" then
				player.character.character_maximum_following_robot_count_bonus = player.character.character_maximum_following_robot_count_bonus
					+ storage.RPG_Bonus[attrib]
			end

			if btname == "btLVU_global.personalxp.LV_Health_Bonus" then
				player.character.character_health_bonus = player.character.character_health_bonus
					+ storage.RPG_Bonus[attrib]
			end

			script.raise_event(
				on_player_updated_status,
				{ player_index = player.index, player_level = storage.personalxp.Level[name], attribute = attrib }
			)

			break
		end
	end

	if storage.personalxp.opt_Pick_Extender[name] then
		player.character.character_item_pickup_distance_bonus =
			math.min(player.character.character_reach_distance_bonus, 320)
		player.character.character_loot_pickup_distance_bonus =
			math.min(player.character.character_reach_distance_bonus, 320)
	else
		player.character.character_item_pickup_distance_bonus = 0
		player.character.character_loot_pickup_distance_bonus = 0
	end
end

script.on_nth_tick(60 * 5, function(event)
	XP_UPDATE_tick()
	check_respawned_players()
	check_potion_effect()
end)

function check_potion_effect()
	for _, player in pairs(game.players) do
		if storage.potion_effects[player.name] and player.character and player.character.valid then
			if
				storage.potion_effects[player.name]["craft"]
				and storage.potion_effects[player.name]["craft"] < game.tick
			then
				player.character.character_crafting_speed_modifier =
					math.max(0, player.character.character_crafting_speed_modifier - potion_speed_bonus)
				storage.potion_effects[player.name]["craft"] = nil
			end
			if
				storage.potion_effects[player.name]["speed"]
				and storage.potion_effects[player.name]["speed"] < game.tick
			then
				player.character.character_running_speed_modifier =
					math.max(0, player.character.character_running_speed_modifier - potion_speed_bonus)
				storage.potion_effects[player.name]["speed"] = nil
			end
		end
	end
end

function check_respawned_players()
	for name, died in pairs(storage.handle_respawn) do
		if died then
			if
				game.players[name]
				and game.players[name].valid
				and game.players[name].character
				and game.players[name].character.valid
			then
				storage.handle_respawn[name] = false
				UpdatePlayerLvStats(game.players[name])
			end
		end
	end
end

function Cria_Player(event)
	local player = game.players[event.player_index]
	SetupPlayer(player, true)
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
script.on_event(defines.events.on_force_created, on_force_created)
script.on_configuration_changed(on_configuration_changed)
script.on_init(On_Init)
script.on_event("key-I", function(event)
	open_close_char_gui(game.players[event.player_index])
end)

-- closes panel when player open inventory E
script.on_event(defines.events.on_gui_opened, function(event)
	if event.gui_type and event.gui_type == defines.gui_type.controller then
		close_char_panel(game.players[event.player_index])
	end
end)

local function on_gui_click(event)
	local player = game.players[event.element.player_index]
	local element = event.element
	if element and element.valid then
		local name = element.name
		local frame = player.gui.center["char-panel"] or player.gui.screen["char-panel"]

		if name == "btcharxp" then
			open_close_char_gui(player)
		elseif name == "rpg_bt_edittag" then
			local tagfield = element.parent.ctag_field
			local text = tagfield.text

			if tagfield.visible then
				tagfield.visible = false
				element.sprite = "utility/rename_icon"
				if player.tag ~= text then
					if string.find(text, "%[item=") then
						text = string.gsub(text, "%[item=", "[img=item/")
					end
					if string.find(text, "%[fluid=") then
						text = string.gsub(text, "%[fluid=", "[img=fluid/")
					end
					if string.find(text, "%[virtual-signal=") then
						text = string.gsub(text, "%[virtual-signal=", "[img=virtual-signal/")
					end
					if string.find(text, "%[entity=") then
						text = string.gsub(text, "%[entity=", "[img=entity/")
					end
					if string.find(text, "%[recipe=") then
						text = string.gsub(text, "%[recipe=", "[img=recipe/")
					end

					player.tag = text
					player.print({ "", { "player_tag" }, ": ", text })
				end
			else
				tagfield.visible = true
				element.sprite = "utility/check_mark_green"
			end
		elseif string.sub(name, 1, 6) == "btLVU_" then
			if player.character and player.character.valid then
				LevelUPPlayer(player, name)
				expand_char_gui(player)
			end
		elseif name == "cb_pick_extender" then
			if player.character == nil then
				frame.tabcharScroll.cb_pick_extender.state = storage.personalxp.opt_Pick_Extender[player.name]
				return
			end
			local cb_pick_extender = frame.tabcharScroll.cb_pick_extender.state
			storage.personalxp.opt_Pick_Extender[player.name] = cb_pick_extender

			if cb_pick_extender then
				player.character.character_item_pickup_distance_bonus = player.character.character_reach_distance_bonus
				player.character.character_loot_pickup_distance_bonus = player.character.character_reach_distance_bonus
			else
				player.character.character_item_pickup_distance_bonus = 0
				player.character.character_loot_pickup_distance_bonus = 0
			end
		elseif name == "bt_destroy_my_parent" then
			if element and element.parent then
				element.parent.destroy()
			end
		elseif name == "rpg_bt_close" then
			element.parent.parent.destroy()
		end
	end
end
script.on_event(defines.events.on_gui_click, on_gui_click)

script.on_event(defines.events.on_player_respawned, function(event)
	local player = game.players[event.player_index]
	storage.handle_respawn[player.name] = false
	UpdatePlayerLvStats(player)
end)

script.on_event(defines.events.on_pre_player_died, function(event)
	local player = game.players[event.player_index]
	local name = player.name
	storage.potion_effects[name] = {}
	local XP = storage.personalxp.XP[name]
	local Level = storage.personalxp.Level[name]
	local NextLevel = storage.xp_table[Level]
	if not NextLevel then
		return
	end

	local XP_ant
	if Level == 1 then
		XP_ant = 0
	else
		XP_ant = storage.xp_table[Level - 1]
	end
	local Interval_XP = NextLevel - XP_ant
	local Penal = math.floor((XP - XP_ant) * storage.setting_death_penal / 100)
	storage.personalxp.Death[name] = storage.personalxp.Death[name] + 1
	storage.handle_respawn[name] = true
	if Penal > 0 then
		storage.personalxp.XP[name] = storage.personalxp.XP[name] - Penal
		player.print({ "", { "xp_lost" }, RPG_format_number(Penal) }, colors.lightred)
	end
end)

function GetXPByKill(entity, killer, force)
	if force then
		if storage.setting_allow_xp_by_kill then
			if not storage.last_overkill or (storage.last_overkill and storage.last_overkill ~= entity) then
				if entity and entity.valid then
					local XP = entity.prototype.get_max_health()
					local player, plname

					if killer and killer.valid then
						if killer.is_player() then
							player = killer
						else
							if killer.type and killer.type == "character" then
								player = killer.player
								force = killer.force
							end
						end
					end

					if player then
						plname = player.name
					end

					local nforce = force.name

					if force ~= entity.force and (not force.get_friend(entity.force)) then
						if entity.type == "character" then
							XP = XP * 4
						elseif entity.type == "unit" then
							storage.kills_units[nforce] = storage.kills_units[nforce] + 1
							if player then
								storage.personal_kill_units[plname] = storage.personal_kill_units[plname] + 1
							end
						elseif entity.type == "unit-spawner" then
							XP = XP * 2
							storage.kills_spawner[nforce] = storage.kills_spawner[nforce] + 1
							if player then
								storage.personal_kill_spawner[plname] = storage.personal_kill_spawner[plname] + 1
							end
						elseif entity.type == "turret" then
							storage.kills_worms[nforce] = storage.kills_worms[nforce] + 1
							if player then
								storage.personal_kill_turrets[plname] = storage.personal_kill_turrets[plname] + 1
							end
							XP = XP * 1.5
						end

						--	if XP > 999999 then XP=999999 end
						XP = math.ceil((1 + force.get_evolution_factor(entity.surface)) * storage.XP_Mult * XP / 3)

						local teamxp = true
						if plname then
							if storage.personalxp.XP[plname] then
								storage.personalxp.XP[plname] = storage.personalxp.XP[plname] + XP
								printXP(player, XP)
								teamxp = false
							end

							if
								not storage.last_magical_effect_from[player.name]
								or storage.last_magical_effect_from[player.name] + 60 * stg_magic_interval
									< game.tick
							then
								CheckRPGMagic(player, entity)
							end
						end

						if teamxp and storage.XP_KILL_HP[nforce] then
							XP = math.ceil(XP / 3)
							storage.XP_KILL_HP[nforce] = storage.XP_KILL_HP[nforce] + XP
							storage.XP[nforce] = storage.XP[nforce] + XP
						end
					end
				end
			end
		end
		storage.last_overkill = nil
	end
end

function distance(pos1, pos2)
	local dx = pos2.x - pos1.x
	local dy = pos2.y - pos1.y
	return (math.sqrt(dx * dx + dy * dy))
end

function CheckRPGMagic(player, entity)
	if
		player.character
		and player.character.valid
		and player.character.surface == entity.surface
		and player.controller_type == defines.controllers.character
	then -- new because of remote view
		local LV = storage.personalxp.LV_Magic[player.name]
		if LV > 0 then
			local chance = 10 + (storage.RPG_Bonus.LV_Magic * LV)
			if math.random(100) <= chance then
				local weap = { "rpg-magic-shock" } --,,'explosive-rocket','grenade
				if LV > 3 then
					table.insert(weap, "slowdown-capsule")
				end
				if LV > 6 then
					table.insert(weap, "poison-capsule")
				end
				if LV > 12 then
					table.insert(weap, "rpg_hadouken")
				end
				if LV > 15 then
					table.insert(weap, "rpg_fireaball")
				end

				if LV > 5 then
					table.insert(weap, "defender")
				end
				if LV > 10 then
					table.insert(weap, "distractor")
				end
				if LV > 17 then
					table.insert(weap, "destroyer")
				end

				local d = distance(entity.position, player.position)
				local w = weap[math.random(#weap)]
				if w == "rpg-magic-shock" then
					ShockNear(entity, player, LV)
				else
					local po = player.position
					if in_list({ "defender", "distractor", "destroyer" }, w) then
						po = entity.position
					end
					player.surface.create_entity({
						name = w,
						target = entity,
						target_position = entity.position,
						position = po,
						force = player.force,
						speed = 0.5,
					}) --0.4
					storage.last_magical_effect_from[player.name] = game.tick - (LV * 60 / 2)
				end
			end
		end
	end
end

function ShockNear(entity, player, LV)
	local others = entity.surface.find_entities_filtered({
		position = entity.position,
		radius = 15,
		limit = 30,
		force = entity.force,
	})
	for k = #others, 1, -1 do
		if
			((others[k].name == "entity-ghost") or (others[k].type == "entity-ghost") or not others[k].destructible)
			or not others[k].health
		then
			table.remove(others, k)
		end
	end
	if #others > 0 then
		for x = 1, math.random(math.min(LV, 20)) + 1 do
			local target = others[math.random(#others)]
			if entity.valid then
				if target.type == "unit" then
					target.surface.create_entity({
						name = "stun-sticker",
						target = target,
						position = target.position,
						duration = 35 + LV,
					})
				end
				target.surface.create_entity({
					name = "electric-beam",
					position = entity.position,
					source = entity.position,
					target = target,
					duration = 35 + LV,
				})
				if entity.valid and player.character.surface == entity.surface then
					entity.damage(5 + LV * 5, player.force, "electric", player.character)
				end
			end
		end
	end
end

--- XP FOR KILL
script.on_event(defines.events.on_entity_died, function(event)
	if not event.force then
		return
	end

	local force = event.force -- force that kill
	local killer = event.cause
	--if event.entity.force.name == 'enemy' and force~='neutral' and force~='enemy' then --aliens
	if killer and killer.valid and storage.kills_units[force.name] and event.entity.force ~= game.forces.neutral then
		if
			event.entity.prototype
			and event.entity.prototype.get_max_health()
			and (not force.get_friend(event.entity.force))
		then
			if killer.type == "car" then
				if killer.get_driver() and killer.get_driver().valid then
					killer = killer.get_driver()
				elseif killer.get_passenger() and killer.get_passenger().valid then
					killer = killer.get_passenger()
				end
			end
			GetXPByKill(event.entity, killer, force)
		end
	end

	if not killer then
		if storage.kills_units[force.name] and event.entity.force ~= game.forces.neutral then
			GetXPByKill(event.entity, killer, force)
		end
	end
end, {
	{ filter = "type", type = "unit" },
	{ filter = "type", type = "unit-spawner" },
	{ filter = "type", type = "spider-vehicle" },
	{ filter = "type", type = "car" },
	{ filter = "type", type = "electric-turret" },
	{ filter = "type", type = "artillery-turret" },
	{ filter = "type", type = "ammo-turret" },
	{ filter = "type", type = "fluid-turret" },
	{ filter = "type", type = "turret" },
	{ filter = "type", type = "character" },
	{ filter = "type", type = "character" },
	{ filter = "type", type = "segmented-unit" },
}) -- event filters

function create_crithit_effect(entity, level, damage)
	if string.find(entity.name, "electric") then
		create_electronic_particles(entity.surface, level * 2, entity.position, 1 + level / 10)
	elseif string.find(entity.type, "unit") or entity.type == "character" or entity.type == "turret" then
		create_blood_particles(entity.surface, 300 + level * 10, entity.position, 2 + level / 10)
		create_guts_particles(entity.surface, 40 + level * 2, entity.position, 2 + level / 10)
	else
		create_remnants_particles(entity.surface, level, entity.position, 1 + level / 10)
	end
	entity.surface.play_sound({ path = "utility/axe_fighting", position = entity.position, volume_modifier = 1 })
	if storage.setting_print_critical then
		local p = entity.position
		rendering.draw_text({
			text = "[img=utility/ammo_damage_modifier_constant] " .. math.ceil(damage), --
			color = colors.red,
			surface = entity.surface,
			target = p,
			time_to_live = 120,
			use_rich_text = true,
			scale = 2,
		})
	end
end

--if settings.startup["charxpmod_enable_damage_attribs"].value then
-- damage bonus,  criticals , natural armor
script.on_event(defines.events.on_entity_damaged, function(event)
	local entity = event.entity
	local damage_type = event.damage_type
	local original_damage_amount = event.original_damage_amount
	local cause = event.cause
	local final_dmg = event.final_damage_amount

	if
		cause
		and cause.valid
		and entity
		and entity.valid
		and entity.health > 0
		and damage_type
		and original_damage_amount
	then
		-- NATURAL ARMOR
		if final_dmg > 0 and entity.type == "character" then
			local player = entity.player
			if player and player.valid then
				local armor_lv = storage.personalxp.LV_Armor_Bonus[player.name]
				if armor_lv > 0 then
					local bonus = (storage.RPG_Bonus.LV_Armor_Bonus * armor_lv)
					local recover = final_dmg * bonus / 100
					entity.health = entity.health + recover
				end
			end
		end

		-- DAMAGE BONUS
		if cause.type == "character" and damage_type.name ~= "poison" and damage_type.name ~= "cold" then
			local player = cause.player
			if player and player.valid then
				local dmg_lv = storage.personalxp.LV_Damage_Bonus[player.name]
				local critical_lv = storage.personalxp.LV_Damage_Critical[player.name]
				local new_damage = original_damage_amount
				if dmg_lv > 0 then
					local bonus = 1 + (storage.RPG_Bonus.LV_Damage_Bonus * dmg_lv / 100)
					new_damage = original_damage_amount * bonus
				end

				-- CRITICAL HITS
				if
					critical_lv > 0
					and (
						string.find(entity.type, "unit")
						or string.find(entity.type, "turret")
						or entity.type == "car"
						or entity.type == "character"
						or entity.type == "spider-vehicle"
					)
				then
					local proba = 100
					if damage_type.name == "fire" then
						proba = proba * 60
					end --because damage per tick
					if math.random(proba) <= critical_lv * storage.RPG_Bonus["LV_Damage_Critical"] then
						new_damage = math.ceil(new_damage * (5 + critical_lv / 2))

						if
							not storage.last_critical_effect_from[player.name]
							or storage.last_critical_effect_from[player.name] + 60 * stg_critical_interval
								< game.tick
						then
							storage.last_critical_effect_from[player.name] = game.tick
							create_crithit_effect(entity, critical_lv, new_damage)
						end
					end
				end

				if new_damage > original_damage_amount then
					local dif = new_damage - original_damage_amount
					if entity.health < dif then -- give kill xp to player because the extra damage will kill entity
						GetXPByKill(entity, cause, cause.force)
						storage.last_overkill = entity
					end
					if entity.valid then
						entity.health = entity.health + final_dmg
						entity.damage(new_damage, player.force, damage_type)
						---- this does not fire the event again	  according api
						----damage(damage, force, type?, source?, cause?)
					end
				end
			end
		end
	end
end, {
	{ filter = "type", type = "unit" },
	{ filter = "type", type = "unit-spawner" },
	{ filter = "type", type = "wall" },
	{ filter = "type", type = "gate" },
	{ filter = "type", type = "spider-vehicle" },
	{ filter = "type", type = "car" },
	{ filter = "type", type = "electric-turret" },
	{ filter = "type", type = "artillery-turret" },
	{ filter = "type", type = "ammo-turret" },
	{ filter = "type", type = "fluid-turret" },
	{ filter = "type", type = "turret" },
	{ filter = "type", type = "character" },
}) -- event filters
--end

-- XP by research
script.on_event(defines.events.on_research_finished, function(event)
	if storage.setting_allow_xp_by_tech and game.tick > 3600 * 2 then
		if event.research.force then
			local force = event.research.force.name
			if force ~= "neutral" and force ~= "enemy" then
				if storage.XP_TECH[force] then
					local ing = #event.research.research_unit_ingredients
					local cost = event.research.research_unit_count * 5
					local techXP = cost * (ing ^ 1.5)
					techXP = math.ceil(storage.XP_Mult * techXP)
					storage.XP_TECH[force] = storage.XP_TECH[force] + techXP
					storage.XP[force] = storage.XP[force] + techXP
				end
			end
		end
	end
end)

-- XP by Rocket  - max 4 times
script.on_event(defines.events.on_rocket_launched, function(event)
	if storage.setting_allow_xp_by_rocket then
		local rocket = event.rocket
		local force = rocket.force
		local where = rocket.surface.name
		local XP
		for p, PL in pairs(force.connected_players) do
			storage.personalxp.rocketsXP_count[PL.name] = storage.personalxp.rocketsXP_count[PL.name] or {}
			local r_count = storage.personalxp.rocketsXP_count[PL.name][where] or 0
			if r_count < 4 then -- max 4 times
				XP = math.ceil(storage.XP_Mult * storage.personalxp.XP[PL.name] / (25 + (r_count * 15))) --4% first
				storage.personalxp.XP[PL.name] = storage.personalxp.XP[PL.name] + XP
				printXP(PL, XP)
				storage.personalxp.rocketsXP_count[PL.name][where] = r_count + 1
			end
		end
	end
end)

--- XP FOR Mining rocks, trees
function XPByMiningRT(player, ent)
	local XP = 0

	if ent.type == "tree" then
		XP = 1
	else
		XP = 2
	end

	if XP > 0 then
		local plname = player.name
		XP = math.ceil(XP * storage.personalxp.Level[plname] * storage.XP_Mult)
		storage.personalxp.XP[plname] = storage.personalxp.XP[plname] + XP
		printXP(player, XP)
	end
end

script.on_event(defines.events.on_player_mined_entity, function(event)
	if storage.setting_allow_xp_by_mining then
		local player = game.players[event.player_index]
		if not player.valid then
			return
		end

		local ent = event.entity
		local name = ent.name

		if ent.type == "tree" or (ent.type == "simple-entity" and name:find("rock")) then
			XPByMiningRT(player, ent)
		end
	end
end, { { filter = "type", type = "tree" }, { filter = "type", type = "simple-entity" } })

-- Potions
script.on_event(defines.events.on_player_used_capsule, function(event)
	local player = game.players[event.player_index]
	local item = event.item

	if item.name == "rpg_small_xp_potion" then
		--remote.call("RPG","PlayerXPPerc",player.name,15)
		remote.call("RPG", "PlayerXPPercCurrentBar", player.name, 0.3)
		player.print({ "feel_better" }, colors.yellow)
	elseif item.name == "rpg_big_xp_potion" then
		remote.call("RPG", "PlayerXPPercCurrentBar", player.name, 0.6)

		-- remote.call("RPG","PlayerXPPerc",player.name,25)
		player.print({ "feel_better" }, colors.yellow)
	elseif item.name == "rpg_level_up_potion" then
		remote.call("RPG", "PlayerGainLevel", player.name)
		player.print({ "feel_better" }, colors.yellow)
	elseif item.name == "rpg_amnesia_potion" then
		local XP = math.ceil(storage.personalxp.XP[player.name] * 0.7)
		SetupPlayer(player)
		storage.personalxp.XP[player.name] = XP
		XP_UPDATE_tick()
		player.print({ "feel_strange" }, colors.lightgreen)
	elseif item.name == "rpg_speed_potion" then
		player.print({ "feel_faster" }, colors.lightgreen)
		storage.potion_effects[player.name] = storage.potion_effects[player.name] or {}
		if storage.potion_effects[player.name]["speed"] then
			storage.potion_effects[player.name]["speed"] = storage.potion_effects[player.name]["speed"]
				+ potion_duration
		else
			storage.potion_effects[player.name]["speed"] = game.tick + potion_duration
			player.character.character_running_speed_modifier = player.character.character_running_speed_modifier
				+ potion_speed_bonus
		end
	elseif item.name == "rpg_crafting_potion" then
		player.print({ "feel_faster" }, colors.lightgreen)
		storage.potion_effects[player.name] = storage.potion_effects[player.name] or {}
		if storage.potion_effects[player.name]["craft"] then
			storage.potion_effects[player.name]["craft"] = storage.potion_effects[player.name]["craft"]
				+ potion_duration
		else
			storage.potion_effects[player.name]["craft"] = game.tick + potion_duration
			player.character.character_crafting_speed_modifier = player.character.character_crafting_speed_modifier
				+ potion_speed_bonus
		end
	elseif item.name == "rpg_curse_cure_potion" then
		remote.call("death_curses", "RemoveCurse", player.name)
	end
end)

-- INTERFACE  --
--------------------------------------------------------------------------------------
-- /c remote.call("RPG","TeamXP","player",1150)
local interface = {}

-- Give XP to Team (may be negative)
function interface.TeamXP(forcename, XP)
	storage.XP[forcename] = storage.XP[forcename] + XP
	XP_UPDATE_tick()
end

-- Give XP to a player (may be negative)
function interface.PlayerXP(playername, XP)
	storage.personalxp.XP[playername] = storage.personalxp.XP[playername] + XP
	printXP(game.players[playername], XP)
	XP_UPDATE_tick()
end

-- Give a fixed XP multiplyed by player level (may be negative)
function interface.PlayerXPPerLevel(playername, XP)
	storage.personalxp.XP[playername] = storage.personalxp.XP[playername] + (XP * storage.personalxp.Level[playername])
	XP_UPDATE_tick()
end

-- Player gain one level
function interface.PlayerGainLevel(playername)
	if storage.personalxp.XP[playername] then
		local XP = CalculateXP_GAIN_LV(playername)
		storage.personalxp.XP[playername] = storage.personalxp.XP[playername] + XP
		XP_UPDATE_tick()
	end
end

-- Give player XP % of his current XP level bar   - perc=0 to 1, eg 0.25
function interface.PlayerXPPercCurrentBar(playername, Perc)
	if storage.personalxp.XP[playername] then
		local XP = CalculateXP_PERCENT_CURRENT_LV(playername, Perc)
		storage.personalxp.XP[playername] = storage.personalxp.XP[playername] + XP
		printXP(game.players[playername], XP)
		XP_UPDATE_tick()
	end
end

-- Give player XP % of his own XP
function interface.PlayerXPPerc(playername, Perc)
	local XP = math.ceil(storage.personalxp.XP[playername] * Perc / 100)
	storage.personalxp.XP[playername] = storage.personalxp.XP[playername] + XP
	printXP(game.players[playername], XP)
	XP_UPDATE_tick()
end

-- Penalty XP for a % of his own XP
function interface.PlayerXPPenalPerc(playername, Perc)
	storage.personalxp.XP[playername] = storage.personalxp.XP[playername]
		- math.ceil(storage.personalxp.XP[playername] * Perc / 100)
	XP_UPDATE_tick()
end

-- Give all force players a XP% of his own XP
function interface.TeamXPPerc(forcename, Perc)
	local XP
	for p, PL in pairs(game.forces[forcename].connected_players) do
		XP = math.ceil(storage.personalxp.XP[PL.name] * Perc / 100)
		storage.personalxp.XP[PL.name] = storage.personalxp.XP[PL.name] + XP
		printXP(PL, XP)
	end
	XP_UPDATE_tick()
end

-- Used only for compatibility with other mods
function interface.OtherEventsByPlayer(player, event_name, parameter)
	if event_name == "mine_rock" then
		XPByMiningRT(player.name, parameter)
	end
	if event_name == "adjust_player_stats" then
		AdjustPlayerStat(player, parameter)
	end
end

function interface.ResetAll()
	ResetAll()
end

interface.CopyPlayerStats = CopyPlayerStats
function interface.PastePlayerStats(playername, stats)
	PastePlayerStats(playername, stats)
end

commands.add_command(
	"rpg-reset-points",
	"Reconstruct XP table and reset all habilities to zero. Players can spent all points again",
	function(event)
		local player = game.players[event.player_index]
		if player.admin then
			ResetPointSpent()
			game.print({ "xp_reset_altert" })
		end
	end
)
commands.add_command(
	"rpg-reset-all",
	"Reconstruct XP table and reset everything to zero, as a new game",
	function(event)
		local player = game.players[event.player_index]
		if player.admin then
			ResetAll()
			game.print({ "xp_reset_altert" })
		end
	end
)
commands.add_command("rpg-players-list", "List all players", function(event)
	local player = game.players[event.player_index]
	ListAll(player)
end)
commands.add_command("rpg-listXPTable", "List XP table", function(event)
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
--[[
function interface.on_character_swapped(event)
--local new_unit_number = event.new_unit_number
--local old_unit_number = event.old_unit_number
local new_character = event.new_character
local old_character = event.old_character
if new_character and new_character.valid then
	local player = new_character.player
	if player and player.valid then

		UpdatePlayerLvStats(player, true)

		if storage.potion_effects[player.name] and storage.potion_effects[player.name]['speed'] then
			player.character.character_running_speed_modifier = player.character.character_running_speed_modifier + potion_speed_bonus
			end
		end
	end
end

removed: Toggling the jetpack will now preserve any character bonuses set by other mods (e.g. running speed, mining speed, crafting speed, reach, inventory slots...)
​ ​Previously, only the health bonus was preserved.
]]

function interface.get_potions_list()
	local pot_table = {
		"rpg_amnesia_potion",
		"rpg_level_up_potion",
		"rpg_small_xp_potion",
		"rpg_big_xp_potion",
		"rpg_crafting_potion",
		"rpg_speed_potion",
		"rpg_small_healing_potion",
		"rpg_big_healing_potion",
	}
	if script.active_mods["death_curses"] then
		table.insert(pot_table, "rpg_curse_cure_potion")
	end
	return pot_table
end

remote.add_interface("RPG", interface)
