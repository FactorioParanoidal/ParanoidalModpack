-- Visibility of other mods' settings, as in Beta 8. Defaults belong to zzzparanoidal.
-- forced: fixes the value regardless of mod-settings.dat (only where the build depends on it).
local function hide_setting(setting_type, name, forced)
	local setting = data.raw[setting_type] and data.raw[setting_type][name]
	if not setting then
		log("zzzparanoidal-settings: setting not found: " .. name)
		return
	end
	setting.hidden = true
	if forced == nil then return end
	if setting_type == "bool-setting" then
		setting.forced_value = forced
	else
		setting.default_value = forced
		setting.allowed_values = { forced }
	end
end

-- HeroTurretRedux: Beta 8 hid every setting of heroturrets; Redux additions are hidden too.
if mods["HeroTurretRedux"] then
	-- Ranked items stay visible in their own "Hero Turrets" tab, as in Beta 8.
	hide_setting("bool-setting", "heroturrets-hide-ranked-from-ghost-cursor", false)
	-- Ranks are generated in data-final-fixes, after zzzparanoidal sets the final turret stats.
	hide_setting("string-setting", "heroturrets-setting-run-in-updates", "False")
	for _, name in ipairs({
		"heroturrets-setting-level-up-modifier", "heroturrets-setting-level-buff-modifier",
		"heroturrets-setting-ammo-turret-kill-multiplier", "heroturrets-setting-fluid-turret-kill-multiplier",
		"heroturrets-setting-electric-turret-kill-multiplier", "heroturrets-setting-artillery-turret-kill-multiplier",
	}) do hide_setting("int-setting", name) end
	for _, name in ipairs({
		"heroturrets-allow-ghost-rank", "heroturrets-allow-artillery-turrets", "heroturrets-allow-blueprint-rank",
		"heroturrets-use-csv", "heroturrets-use-csv-kills", "heroturrets-use-csv-damage", "heroturrets-use-csv-buff",
		"heroturrets-use-csv-health-buff", "heroturrets-use-csv-range-buff", "heroturrets-use-csv-firerate-buff",
		"heroturrets-use-csv-attack-speed-buff", "heroturrets-use-csv-turret-rotation-buff",
		"heroturrets-max-health-on-rank", "heroturrets-update-ammo-ranges",
	}) do hide_setting("bool-setting", name) end
	for _, name in ipairs({
		"heroturrets-kill-counter", "heroturrets-damage-counter", "heroturrets-allow-damage", "heroturrets-csv-names",
		"heroturrets-csv-kill", "heroturrets-csv-damage", "heroturrets-csv-buff", "heroturrets-csv-health-buff",
		"heroturrets-csv-range-buff", "heroturrets-csv-firerate-buff", "heroturrets-csv-attack-speed-buff",
		"heroturrets-csv-turret-rotation-buff",
	}) do hide_setting("string-setting", name) end
end
