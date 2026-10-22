-- Оптимизация атласов видеопамяти (аудит графики 2026-10-15). Меняются только графические поля
-- прототипов, механика не затрагивается. Данные (списки путей и прототипов) — graphics-atlas-data.lua,
-- он генерируется анализом дампа; подробности и цифры — README.md, раздел «Атласы графики».
-- Порядок: после всех правок, создающих и копирующих прототипы и иконки (меню, переработка,
-- Факториопедия), до research-evolution-icon (тот всегда последний).
local D = require("tweaks.custom.graphics-atlas-data")

local EMPTY = "__core__/graphics/empty.png" -- 64x64, полностью прозрачный
local ROLLING_STOCK = { "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon", "infinity-cargo-wagon" }
local stats = {}

local function inc(key, n)
	stats[key] = (stats[key] or 0) + (n or 1)
end

local function is_image(s)
	if type(s) ~= "string" then return false end
	local ext = (s:match("%.(%w+)$") or ""):lower()
	return ext == "png" or ext == "jpg" or ext == "jpeg"
end

-- 1. Анимации разложения трупов. Трупы врагов живут 20 с (rampantFixed--unitAndSpawnerFadeTime),
--    кадр разложения меняется раз в 6 с: из 24 кадров видно не больше 3-4, а атлас corpse-decay ~200 МБ.
for _, corpse in pairs(data.raw["corpse"] or {}) do
	if corpse.decay_animation then
		corpse.decay_animation = nil
		inc("decay_animation")
	end
end

-- 2. Нарисованные лучи фар (front_light_pictures): RGB без альфы, 98% чёрного, не обрезаются (~100 МБ).
--    Сам свет фар остаётся: front_light (конус света) не трогается.
for _, kind in ipairs(ROLLING_STOCK) do
	for _, prototype in pairs(data.raw[kind] or {}) do
		if prototype.front_light_pictures then
			prototype.front_light_pictures = nil
			inc("front_light_pictures")
		end
	end
end

-- 3. Пустая графика у скрытых недостижимых прототипов (список из анализа). Заглушка ставится,
--    только если прототип по-прежнему hidden: при другой настройке, открывающей его, графика остаётся.
local function stub_sprite(t)
	local n = (t.frame_count or 1) * (t.direction_count or 1) * (t.variation_count or 1)
	if type(t.frames) == "number" and t.frames > n then n = t.frames end
	if n > 4096 or (t.variation_count and (t.frame_count or 1) > 64) then
		inc("stub_skipped_sprite")
		return
	end
	t.filename = EMPTY
	t.filenames, t.stripes, t.lines_per_file, t.slice = nil, nil, nil, nil
	t.size, t.position, t.x, t.y = nil, nil, nil, nil
	t.width, t.height, t.line_length = 1, 1, 64
	t.dice, t.dice_x, t.dice_y, t.hr_version, t.mipmap_count = nil, nil, nil, nil, nil
	if type(t.frames) == "table" then t.frames = nil end
	inc("stub_sprites")
end

local function stub_node(node, seen)
	if type(node) ~= "table" or seen[node] then return end
	seen[node] = true
	if type(node.layers) == "table" and node.layers[1] then
		for _, layer in pairs(node.layers) do stub_node(layer, seen) end
		return
	end
	if is_image(node.filename) or (type(node.filenames) == "table" and is_image(node.filenames[1]))
		or (type(node.stripes) == "table" and node.stripes[1]) then
		stub_sprite(node)
		return
	end
	local icon_keys = {}
	for key, value in pairs(node) do
		if type(key) == "string" and is_image(value) and (key == "icon" or key:sub(-5) == "_icon") then
			icon_keys[#icon_keys + 1] = key
		elseif type(value) == "table" then
			stub_node(value, seen)
		end
	end
	for _, key in ipairs(icon_keys) do
		node[key] = EMPTY
		node[key == "icon" and "icon_size" or key .. "_size"] = 64
		inc("stub_icons")
	end
end

for _, entry in ipairs(D.stubs) do
	local prototype = (data.raw[entry[1]] or {})[entry[2]]
	if prototype and prototype.hidden then
		-- своя копия графики: таблицы могут быть общими с живыми прототипами
		for key, value in pairs(prototype) do
			if type(value) == "table" then prototype[key] = table.deepcopy(value) end
		end
		stub_node(prototype, {})
		inc("stub_prototypes")
	elseif prototype then
		inc("stub_kept_visible")
	end
end

-- 4. Слои анимаций с пиксельно одинаковыми кадрами: static — один кадр с repeat_count на ту же
--    длину цикла; prefix — уникальные кадры идут первыми, повтор через frame_sequence.
local function resolve(root, path)
	local node = root
	for _, key in ipairs(path) do
		if type(node) ~= "table" then return nil end
		node = node[key]
	end
	return type(node) == "table" and node or nil
end

for _, c in ipairs(D.compact) do
	local prototype = (data.raw[c[1]] or {})[c[2]]
	local t = prototype and resolve(prototype, c[3])
	if not t then
		inc("compact_missing")
	elseif t.run_mode and t.run_mode ~= "forward" then
		inc("compact_mismatch")
	elseif c[4] == "static" then
		if (t.frame_count or 1) == c[5] and (t.direction_count or 1) == c[6] and (t.repeat_count or 1) == c[7]
			and not t.frame_sequence then
			t.frame_count = 1
			t.repeat_count = c[5] * c[7]
			inc("compact_static")
		elseif t.frame_count == 1 and t.repeat_count == c[5] * c[7] then
			inc("compact_shared")
		else
			inc("compact_mismatch")
		end
	else
		if (t.frame_count or 1) == c[5] and (t.direction_count or 1) == 1 and not t.frame_sequence then
			t.frame_count = c[8]
			t.frame_sequence = table.deepcopy(c[9])
			inc("compact_prefix")
		elseif t.frame_count == c[8] and t.frame_sequence then
			inc("compact_shared")
		else
			inc("compact_mismatch")
		end
	end
end

-- 5. Один файл вместо пиксельно одинаковых копий и уменьшенные копии слишком крупных иконок.
local remap = {}
for old, target in pairs(D.file_remap) do
	if target[2] == "base" or target[2] == "core" or mods[target[2]] then
		remap[old] = target[1]
	end
end

local function fix_icon(t, key, size_key)
	local size = t[size_key] or 64
	local entry = D.icons[t[key] .. "|" .. size]
	if not entry then return end
	t[key] = entry[1]
	t[size_key] = entry[2]
	if key == "icon" and t.scale then
		t.scale = t.scale * size / entry[2]
	end
	inc("icons_downscaled")
end

local visited = {}
local function walk(t)
	if visited[t] then return end
	visited[t] = true
	local icon_keys
	for key, value in pairs(t) do
		local kind = type(value)
		if kind == "string" then
			local target = remap[value]
			if target then
				t[key] = target
				value = target
				inc("files_remapped")
			end
			if type(key) == "string" and (key == "icon" or key:sub(-5) == "_icon") and is_image(value) then
				icon_keys = icon_keys or {}
				icon_keys[#icon_keys + 1] = key
			end
		elseif kind == "table" then
			walk(value)
		end
	end
	if icon_keys then
		for _, key in ipairs(icon_keys) do
			fix_icon(t, key, key == "icon" and "icon_size" or key .. "_size")
		end
	end
end

for _, prototypes in pairs(data.raw) do
	for _, prototype in pairs(prototypes) do
		walk(prototype)
	end
end

local parts = {}
for key, value in pairs(stats) do parts[#parts + 1] = key .. "=" .. value end
table.sort(parts)
log("graphics-atlas: " .. table.concat(parts, ", "))
