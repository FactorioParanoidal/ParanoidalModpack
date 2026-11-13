-- Графика и точки вылета одной модели: заменять вместе со спрайтами этой папки.
local GFX = "__zzzparanoidal__/graphics/anti-air-turret/"
-- Кадры 320x320, 64 направления; покой и сложенное состояние имеют отдельные атласы.
local SCALE = 0.56
local TINTS = {{1, 0.68, 0.18}, {0.92, 0.25, 0.20}, {0.20, 0.58, 1}}
-- Общая точка у среза блока стволов модели из render.py (в игровых тайлах).
local MUZZLE_DISTANCE = 1.65
local MUZZLE_HEIGHT = 1.26

local function sprite(extra)
	local animation = {
		priority = "medium",
		width = 320,
		height = 320,
		scale = SCALE,
	}
	for key, value in pairs(extra) do animation[key] = value end
	return animation
end

local function shooting(frame_count, layer, tint)
	local filenames = {}
	for i = 0, 7 do
		filenames[#filenames + 1] = GFX .. (frame_count == 1 and "prepared" or "shooting")
			.. (layer and "-" .. layer or "") .. "-" .. i .. ".png"
	end
	return sprite({
		filenames = filenames,
		lines_per_file = 8,
		line_length = frame_count,
		direction_count = 64,
		frame_count = frame_count,
		draw_as_shadow = layer == "shadow",
		tint = layer == "shadow" and {1, 1, 1, 0.35} or tint,
	})
end

local function raising(frame_count, tint, extra)
	local layers = {}
	for _, suffix in ipairs({"", "-mask", "-shadow"}) do
		local layer = sprite({
			filename = GFX .. (frame_count == 1 and "folded" or "raising") .. suffix .. ".png",
			line_length = frame_count,
			direction_count = 4,
			frame_count = frame_count,
			draw_as_shadow = suffix == "-shadow",
			tint = suffix == "-shadow" and {1, 1, 1, 0.35} or suffix == "-mask" and tint or nil,
		})
		for key, value in pairs(extra or {}) do layer[key] = value end
		layers[#layers + 1] = layer
	end
	return {layers = layers}
end

-- Графика ----------------------------------------------------------------------------------------------------
local gunshot = require("__base__.prototypes.entity.sounds").gun_turret_gunshot

local function apply_graphics(turret, tier)
	local tint = TINTS[tier]
	turret.folded_animation = raising(1, tint)
	turret.preparing_animation = raising(6, tint)
	turret.folding_animation = raising(6, tint, {run_mode = "backward"})
	turret.prepared_animation = {layers = {shooting(1), shooting(1, "mask", tint), shooting(1, "shadow")}}
	turret.attacking_animation = {layers = {shooting(2), shooting(2, "mask", tint), shooting(2, "shadow")}}
	turret.graphics_set = {base_visualisation = {animation = {layers = {
		sprite({filename = GFX .. "base-" .. tier .. ".png"}),
		sprite({filename = GFX .. "base-shadow.png", draw_as_shadow = true, tint = {1, 1, 1, 0.35}}),
	}}}}
	turret.drawing_box_vertical_extension = 1
	turret.attack_parameters.sound = table.deepcopy(gunshot)
	-- Одна общая точка у среза блока стволов; штатное вращение и проекция движка.
	turret.attack_parameters.projectile_creation_offsets = nil
	turret.attack_parameters.projectile_center = {0, -MUZZLE_HEIGHT}
	turret.attack_parameters.projectile_creation_distance = MUZZLE_DISTANCE
	turret.attack_parameters.projectile_creation_parameters = nil
	turret.attack_parameters.apply_projection_to_projectile_creation_position = true
end

local function technology(tech, tier)
	local icons = table.deepcopy(tech.icons or {{icon = tech.icon, icon_size = tech.icon_size}})
	local markers = {}
	for i = #icons, 1, -1 do
		local layer = icons[i]
		if layer.icon:find("/icons/tiers/", 1, true) then
			table.insert(markers, 1, table.remove(icons, i))
		else
			local shift = layer.shift or {0, 0}
			layer.scale = (layer.scale or 128 / (layer.icon_size or tech.icon_size)) * 0.52
			layer.shift = {(shift[1] or shift.x or 0) * 0.52 - 28, (shift[2] or shift.y or 0) * 0.52 - 22}
		end
	end
	icons[#icons + 1] = {icon = GFX .. "technology-" .. tier .. ".png", icon_size = 512, scale = 0.26, shift = {9, 7}}
	for _, marker in ipairs(markers) do icons[#icons + 1] = marker end
	tech.icon = nil
	tech.icons = icons
end

return {
	apply = apply_graphics,
	icon = function(tier) return {icon = GFX .. "icon-" .. tier .. ".png", icon_size = 128} end,
	technology = technology,
}
