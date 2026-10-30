-- Цветные пинги: GPS-ссылка игрока в обычном чате (так же уходит пинг карты) получает на карте кольцо
-- и ник цветом этого игрока, чтобы различать пинги при многих игроках. Сам значок пинга движка не
-- меняется: у него один общий спрайт и нет API.
-- Нагрузка: только on_console_chat (не каждый тик), 1–4 объекта rendering на ссылку; их удаляет сам
-- движок по time_to_live, а лишние метки игрока сверх лимита скрипт удаляет сразу.
local M = {}

local MAX_TAGS = 10 -- ссылок из одного сообщения, защита от сообщения из сотни тегов
local MAX_MESSAGE = 50 -- символов текста сообщения после ника

local function setting(name)
	return settings.global["paranoidal-ping-" .. name].value
end

local function marks()
	local s = storage.ping_color
	if not s then
		s = {}
		storage.ping_color = s
	end
	return s
end

local function destroy(mark)
	for _, object in pairs(mark) do
		if object.valid then object.destroy() end
	end
end

-- Метка жива, пока жив хотя бы один её объект.
local function alive(mark)
	for _, object in pairs(mark) do
		if object.valid then return true end
	end
	return false
end

-- Текст сообщения без тегов rich text, не длиннее MAX_MESSAGE символов UTF-8.
local function message_text(message)
	local text = message:gsub("%[[^%]]*%]", " "):gsub("%s+", " "):match("^%s*(.-)%s*$")
	local count, cut = 0, nil
	for position in text:gmatch("()[^\128-\191]") do
		count = count + 1
		if count > MAX_MESSAGE then
			cut = position
			break
		end
	end
	if cut then text = text:sub(1, cut - 1) .. "…" end
	return text
end

-- Кому видна метка: игроки, которые не выключили у себя «Показывать цветные пинги».
-- nil — без списка (видят все из forces, включая тех, кто зайдёт позже).
local function viewers(player, scope)
	local candidates = scope == "all" and game.players or player.force.players
	local list, everyone = {}, true
	for _, viewer in pairs(candidates) do
		if settings.get_player_settings(viewer)["paranoidal-ping-show"].value then
			list[#list + 1] = viewer
		else
			everyone = false
		end
	end
	if everyone then return nil end
	return list
end

local function draw(surface, position, text, rule)
	local mark = {}
	for _, mode in ipairs(rule.modes) do
		local function base(target)
			return {surface = surface, target = target or position, time_to_live = rule.ttl, render_mode = mode,
				forces = rule.forces, players = rule.players, blink_interval = rule.blink}
		end
		if rule.fill > 0 then
			local o = base()
			o.color, o.radius, o.filled = rule.fill_color, rule.radius, true
			mark[#mark + 1] = rendering.draw_circle(o)
		end
		if rule.ring then
			local o = base()
			o.color, o.radius, o.width, o.filled = rule.color, rule.radius, rule.width, false
			mark[#mark + 1] = rendering.draw_circle(o)
		end
		if rule.name then
			-- ник над кольцом (над заливкой, если кольца нет)
			local top = (rule.ring or rule.fill > 0) and rule.radius or 0
			local o = base({x = position.x, y = position.y - top - rule.offset})
			o.text, o.color, o.scale, o.scale_with_zoom, o.font = text, rule.color, rule.scale, rule.fixed, rule.font
			o.alignment, o.vertical_alignment = "center", "bottom"
			mark[#mark + 1] = rendering.draw_text(o)
		end
	end
	return mark
end

local function on_chat(event)
	if not event.player_index or not setting("mark") then return end
	local message = event.message
	if not (message and message:find("[gps=", 1, true)) then return end
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	local source = setting("color-source") == "chat" and player.chat_color or player.color
	local a = setting("opacity")
	local f = setting("ring-fill")
	local scope = setting("visibility")
	local players = viewers(player, scope)
	if players and not players[1] then return end -- все зрители выключили метки
	local font = setting("name-font")
	local rule = {
		ttl = math.max(1, math.floor(setting("duration") * 60 + 0.5)),
		blink = math.floor(setting("blink") * 60 + 0.5),
		color = {r = source.r * a, g = source.g * a, b = source.b * a, a = a},
		fill = f,
		fill_color = {r = source.r * f, g = source.g * f, b = source.b * f, a = f},
		ring = setting("ring"),
		radius = setting("ring-radius"),
		width = setting("ring-width"),
		name = setting("name"),
		scale = setting("name-scale"),
		fixed = setting("name-fixed-size"),
		offset = setting("name-offset"),
		font = font ~= "default" and font or nil,
		-- players задан — только этот список; forces nil при "all" — все силы
		forces = (not players and scope ~= "all") and {player.force} or nil,
		players = players,
		modes = setting("world") and {"chart", "game"} or {"chart"},
	}
	if not (rule.ring or rule.name or rule.fill > 0) then return end

	local text = player.name
	if setting("name-message") then
		local extra = message_text(message)
		if extra ~= "" then text = text .. ": " .. extra end
	end

	local s = marks()
	local own = s[player.index] or {}
	s[player.index] = own
	local limit = setting("per-player")
	local count = 0
	for x, y, surface_name in message:gmatch("%[gps=%s*(%-?[%d%.]+)%s*,%s*(%-?[%d%.]+)%s*,?([^%]]*)%]") do
		count = count + 1
		if count > MAX_TAGS then break end
		surface_name = surface_name:match("^%s*(.-)%s*$")
		-- без имени — поверхность игрока; несуществующая — пропуск
		local surface = player.surface
		if surface_name ~= "" then surface = game.get_surface(surface_name) end
		x, y = tonumber(x), tonumber(y)
		if surface and x and y then
			own[#own + 1] = draw(surface, {x = x, y = y}, text, rule)
		end
	end
	-- Сначала отбросить истёкшие, затем самые старые сверх лимита.
	local kept = {}
	for _, mark in ipairs(own) do
		if alive(mark) then kept[#kept + 1] = mark end
	end
	while #kept > limit do
		destroy(table.remove(kept, 1))
	end
	s[player.index] = kept[1] and kept or nil
end

local function on_player_removed(event)
	local s = storage.ping_color
	if s and s[event.player_index] then
		for _, mark in ipairs(s[event.player_index]) do destroy(mark) end
		s[event.player_index] = nil
	end
end

-- Сохранить ранее зарегистрированные обработчики zzz, как в соседних модулях.
local function on(event, callback)
	local previous = script.get_event_handler(event)
	script.on_event(event, function(e)
		if previous then previous(e) end
		callback(e)
	end)
end

function M.install()
	on(defines.events.on_console_chat, on_chat)
	on(defines.events.on_player_removed, on_player_removed)
end

return M
