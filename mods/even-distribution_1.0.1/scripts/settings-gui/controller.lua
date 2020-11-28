-- Controller for the Even Distribution settings GUI

local this = {}
local util = scripts.util
local gui = scripts["gui-tools"]
local templates = scripts["settings-gui.gui-templates"].templates

local helpers = scripts.helpers
local _ = helpers.on

function this.on_init()
	for player_index,player in pairs(game.players) do
		local player = _(player); if player:isnot("valid player") then return end
		this.destroyGUI(player)
		this.buildButton(player)
	end
end

this.on_configuration_changed = this.on_init

function this.on_player_created(event)
	local player = _(game.players[event.player_index]); if player:isnot("valid player") then return end
	this.destroyGUI(player)
	this.buildButton(player)
end

function this.on_runtime_mod_setting_changed(event)
	if event.setting == "disable-distribute" or
	   event.setting == "disable-inventory-cleanup" then

		local player = _(game.players[event.player_index])
		if player:is("valid player") then
			this.buildGUI(player)
		end
	end
end

function this.buildGUI(player)
	gui.create(player, templates.settingsWindow, { })
end

function this.destroyGUI(player)
	gui.destroy(player, templates.settingsWindow)
end

function this.buildButton(player)
	gui.create(player, templates.settingsButton, { })
end

function this.destroyButton(player)
	gui.destroy(player, templates.settingsButton)
end

return this