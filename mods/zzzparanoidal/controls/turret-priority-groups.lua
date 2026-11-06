-- Приоритет турели по группам врагов (ПР-072, решение пользователя 2026-11-06): панель справа от окна турели,
-- свёрнута по умолчанию, раскрытие запоминается у каждого игрока. Фильтры «Кто» (категории вкладки «Враги»:
-- tweaks/custom/enemies-tab.lua и ряды robotarmy-citadel) и «Фракция» (фракции Rampant, стихии Bob) работают вместе;
-- «Добавить в приоритет», «Убрать», «Очистить список» меняют список приоритетных целей самой турели (его переносят
-- копирование настроек, чертежи и смена ранга HeroTurretRedux). Копии вожаков и боссов RampantFixed (скрытые
-- прототипы) идут вместе со своим врагом. «Не стрелять по летунам»: летуны уходят из списка, все остальные враги
-- добавляются, включается «Стрелять только по приоритетным целям»; повторное нажатие возвращает как было (записи,
-- добавленные после этого вручную, остаются).
-- Нагрузка: только окно турели, кнопки панели, копирование настроек и замена ранга; без on_tick.
local M = {}

local PREFIX = "pd_tpg_"
local TYPES = {["ammo-turret"] = true, ["electric-turret"] = true, ["fluid-turret"] = true}
-- Категории вкладки «Враги» (буква подгруппы paranoidal-enemies-<буква>-NNN).
local CATEGORIES = {"a", "b", "c", "d", "e", "f", "g", "h", "i"}
local FLYERS = "c"
-- Фракции Rampant в порядке RampantFixed, затем стихии Bob без пары у Rampant.
local FACTIONS = {"neutral", "acid", "laser", "fire", "inferno", "wasp", "spawner", "electric", "physical", "troll",
	"poison", "suicide", "nuclear", "energy-thief", "fast", "juggernaut", "arachnids", "piercing", "explosive"}
local RAMPANT_KINDS = {"super-hive", "biter-spawner", "spitter-spawner", "hive", "biter", "spawn", "spitter", "flyer",
	"worm"}
local BOB_ELEMENTS = {"piercing", "electric", "acid", "explosive", "poison", "fire"}

---------------------------------------------------------------------------------------------------
-- Группы: только из прототипов, поэтому кэш вне storage одинаков у всех участников мультиплеера.

local groups = nil

local function escape(s)
	return (s:gsub("%-", "%%-"))
end

local function faction_of(name, category)
	for _, kind in ipairs(RAMPANT_KINDS) do
		local faction = name:match("^(.-)%-" .. escape(kind) .. "%-v%d+%-t%d+%-rampant$")
		if faction then return faction end
	end
	local source = name:match("^(.-)%-%a+%-v%d+%-t%d+%-drone%-rampant$")
	if source then return source:match("^(.-)%-worm$") or source end
	if name:match("^crystal%-v%d+%-drain%-rampant$") then return "energy-thief" end
	if (category == "a" or category == "b" or category == "d" or category == "e")
		and not (name:sub(1, 3) == "maf" or name:sub(1, 3) == "bm-" or name:sub(1, 3) == "bm_") then
		for _, element in ipairs(BOB_ELEMENTS) do
			if name:find("-" .. element .. "-", 1, true) then return element end
		end
		return "neutral"
	end
	return nil
end

local function load_groups()
	if groups then return groups end
	local entries, by_name = {}, {}
	for name, prototype in pairs(prototypes.entity) do
		local subgroup = (not prototype.hidden) and prototype.subgroup
		local category = subgroup and subgroup.name:match("^paranoidal%-enemies%-(%a)%-%d+$")
		if category then
			local entry = {name = name, category = category, faction = faction_of(name, category), copies = {},
				key = subgroup.order .. "|" .. (prototype.order or "") .. "|" .. name}
			entries[#entries + 1] = entry
			by_name[name] = entry
		end
	end
	table.sort(entries, function(a, b) return a.key < b.key end)
	for name, prototype in pairs(prototypes.get_entity_filtered({{filter = "type", type = "unit"}})) do
		local base = prototype.hidden and (name:match("^(.+)%-champion%-from%-") or name:match("^(.+)%-hour%-boss%-from%-"))
		local entry = base and by_name[base]
		if entry then entry.copies[#entry.copies + 1] = name end
	end
	local categories, factions = {}, {}
	for _, entry in ipairs(entries) do
		table.sort(entry.copies)
		categories[entry.category] = true
		if entry.faction then factions[entry.faction] = true end
	end
	local present_categories, present_factions = {}, {}
	for _, c in ipairs(CATEGORIES) do if categories[c] then present_categories[#present_categories + 1] = c end end
	for _, f in ipairs(FACTIONS) do if factions[f] then present_factions[#present_factions + 1] = f end end
	groups = {entries = entries, categories = present_categories, factions = present_factions}
	return groups
end

-- Записи под выбор игрока: {names = имена в порядке вкладки (враг, затем его копии), enemies, copies}.
local function matching(choice, predicate)
	local names, enemies, copies = {}, 0, 0
	for _, entry in ipairs(load_groups().entries) do
		local ok
		if predicate then
			ok = predicate(entry)
		else
			ok = (not next(choice.categories) or choice.categories[entry.category])
				and (not next(choice.factions) or (entry.faction and choice.factions[entry.faction]))
		end
		if ok then
			names[#names + 1] = entry.name
			enemies = enemies + 1
			for _, copy in ipairs(entry.copies) do
				names[#names + 1] = copy
				copies = copies + 1
			end
		end
	end
	return {names = names, enemies = enemies, copies = copies}
end

local function flyers()
	return matching(nil, function(entry) return entry.category == FLYERS end).names
end

local function not_flyers()
	return matching(nil, function(entry) return entry.category ~= FLYERS end).names
end

local function set_of(names)
	local set = {}
	for _, name in ipairs(names) do set[name] = true end
	return set
end

---------------------------------------------------------------------------------------------------
-- Список приоритетов турели.

local function state()
	local s = storage.turret_priority_groups
	if not s then
		s = {players = {}, air = {}}
		storage.turret_priority_groups = s
	end
	return s
end

local function is_turret(entity)
	return entity and entity.valid and TYPES[entity.type] and entity.unit_number ~= nil
end

local function read_list(turret)
	local names = {}
	for i, prototype in ipairs(turret.priority_targets) do names[i] = prototype.name end
	return names
end

-- Записывает список: записи с первого отличия снимаются с конца и пишутся заново (без повторов по ходу записи).
local function write_list(turret, names)
	local old = read_list(turret)
	local first = 1
	while first <= #names and names[first] == old[first] do first = first + 1 end
	for i = #old, first, -1 do turret.set_priority_target(i, nil) end
	for i = first, #names do turret.set_priority_target(i, names[i]) end
end

local function without(list, set)
	local result = {}
	for _, name in ipairs(list) do
		if not set[name] then result[#result + 1] = name end
	end
	return result
end

local function append(list, names)
	local present = set_of(list)
	local added = {}
	for _, name in ipairs(names) do
		if not present[name] then
			present[name] = true
			list[#list + 1] = name
			added[#added + 1] = name
		end
	end
	return added
end

local function add_names(turret, names)
	local list = read_list(turret)
	append(list, names)
	write_list(turret, list)
end

local function remove_names(turret, names)
	write_list(turret, without(read_list(turret), set_of(names)))
end

local function forget_air(turret)
	state().air[turret.unit_number] = nil
end

-- Всегда своя копия записи: у двух турелей в storage нет общих таблиц.
local function remember_air(turret, record)
	local kept, removed = {}, {}
	for i, name in ipairs(record.kept) do kept[i] = name end
	for i, name in ipairs(record.removed) do removed[i] = name end
	state().air[turret.unit_number] = {kept = kept, removed = removed, ignore = record.ignore}
	script.register_on_object_destroyed(turret)
end

-- Запись кнопки «летуны» (storage, по unit_number): kept — не-летуны, которые уже были в списке (их отмена не
-- убирает), removed — убранные летуны, ignore — прежнее «Стрелять только по приоритетным целям». Добавленное
-- кнопкой не хранится (сотни имён на турель): это все не-летуны, кроме kept.
-- Включено: есть запись или (после чертежа) список без летунов, со всеми остальными врагами, и галка.
local function air_on(turret)
	if state().air[turret.unit_number] then return true end
	if not turret.ignore_unprioritised_targets then return false end
	local list = set_of(read_list(turret))
	for _, name in ipairs(flyers()) do if list[name] then return false end end
	for _, name in ipairs(not_flyers()) do if not list[name] then return false end end
	return true
end

local function toggle_air(turret)
	local s = state()
	if air_on(turret) then
		local record = s.air[turret.unit_number]
		local list = read_list(turret)
		if record then
			local added = set_of(not_flyers())
			for _, name in ipairs(record.kept) do added[name] = nil end
			list = without(list, added)
			append(list, record.removed)
			write_list(turret, list)
			turret.ignore_unprioritised_targets = record.ignore
		else
			write_list(turret, without(list, set_of(not_flyers())))
			turret.ignore_unprioritised_targets = false
		end
		forget_air(turret)
	else
		local list = read_list(turret)
		local flying = set_of(flyers())
		local removed = {}
		for _, name in ipairs(list) do if flying[name] then removed[#removed + 1] = name end end
		list = without(list, flying)
		local ground = set_of(not_flyers())
		local kept = {}
		for _, name in ipairs(list) do if ground[name] then kept[#kept + 1] = name end end
		append(list, not_flyers())
		write_list(turret, list)
		remember_air(turret, {kept = kept, removed = removed, ignore = turret.ignore_unprioritised_targets})
		turret.ignore_unprioritised_targets = true
	end
end

---------------------------------------------------------------------------------------------------
-- Панель.

local function player_state(index)
	local s = state()
	local p = s.players[index]
	if not p then
		p = {expanded = false, categories = {}, factions = {}}
		s.players[index] = p
	end
	return p
end

local function opened_turret(player)
	local entity = player.opened
	if player.opened_gui_type == defines.gui_type.entity and is_turret(entity) then return entity end
	return nil
end

local function frame_of(player)
	return player.gui.relative[PREFIX .. "frame"]
end

local function find(element, name)
	if element.name == name then return element end
	for _, child in pairs(element.children) do
		local found = find(child, name)
		if found then return found end
	end
	return nil
end

local function toggle_table(parent, name, keys, chosen, label_prefix, tooltip)
	local t = parent.add({type = "table", name = PREFIX .. name, column_count = 4})
	t.style.horizontal_spacing = 2
	t.style.vertical_spacing = 2
	local all = t.add({type = "button", name = PREFIX .. name .. "_all", caption = {"paranoidal-turret-groups.all"},
		tooltip = tooltip, toggled = not next(chosen)})
	all.style.width = 116
	for _, key in ipairs(keys) do
		local b = t.add({type = "button", name = PREFIX .. name .. "_" .. key, caption = {label_prefix .. key},
			tooltip = tooltip, toggled = chosen[key] == true, tags = {key = key}})
		b.style.width = 116
	end
end

local function update(player)
	local frame = frame_of(player)
	if not (frame and frame.valid) then return end
	local p = player_state(player.index)
	local turret = opened_turret(player)
	frame.visible = turret ~= nil
	if not turret then return end
	local title = find(frame, PREFIX .. "title")
	title.caption = {p.expanded and "paranoidal-turret-groups.title-expanded" or "paranoidal-turret-groups.title-collapsed"}
	local body = find(frame, PREFIX .. "body")
	body.visible = p.expanded
	if not p.expanded then return end
	local g = load_groups()
	for _, pair in ipairs({{"who", g.categories, p.categories}, {"faction", g.factions, p.factions}}) do
		local t = find(body, PREFIX .. pair[1])
		t[PREFIX .. pair[1] .. "_all"].toggled = not next(pair[3])
		for _, key in ipairs(pair[2]) do t[PREFIX .. pair[1] .. "_" .. key].toggled = pair[3][key] == true end
	end
	local m = matching(p)
	find(body, PREFIX .. "count").caption = {"paranoidal-turret-groups.count", m.enemies, m.copies}
	find(body, PREFIX .. "size").caption = {"paranoidal-turret-groups.size", #turret.priority_targets}
	find(body, PREFIX .. "air").toggled = air_on(turret)
end

local function build(player)
	local old = frame_of(player)
	if old then old.destroy() end
	local frame = player.gui.relative.add({type = "frame", name = PREFIX .. "frame", direction = "vertical",
		anchor = {gui = defines.relative_gui_type.turret_gui, position = defines.relative_gui_position.right}})
	frame.style.maximal_width = 520
	frame.add({type = "button", name = PREFIX .. "title", caption = {"paranoidal-turret-groups.title-collapsed"},
		tooltip = {"paranoidal-turret-groups.title-tooltip"}})
	local body = frame.add({type = "flow", name = PREFIX .. "body", direction = "vertical"})
	local p = player_state(player.index)
	local g = load_groups()
	body.add({type = "label", caption = {"paranoidal-turret-groups.who"}, style = "caption_label"})
	toggle_table(body, "who", g.categories, p.categories, "paranoidal-turret-groups.cat-",
		{"paranoidal-turret-groups.who-tooltip"})
	body.add({type = "label", caption = {"paranoidal-turret-groups.faction"}, style = "caption_label"})
	toggle_table(body, "faction", g.factions, p.factions, "paranoidal-turret-groups.fac-",
		{"paranoidal-turret-groups.faction-tooltip"})
	body.add({type = "label", name = PREFIX .. "count"})
	local actions = body.add({type = "flow", direction = "horizontal"})
	actions.add({type = "button", name = PREFIX .. "add", caption = {"paranoidal-turret-groups.add"},
		tooltip = {"paranoidal-turret-groups.add-tooltip"}})
	actions.add({type = "button", name = PREFIX .. "remove", caption = {"paranoidal-turret-groups.remove"},
		tooltip = {"paranoidal-turret-groups.remove-tooltip"}})
	actions.add({type = "button", name = PREFIX .. "clear", caption = {"paranoidal-turret-groups.clear"},
		tooltip = {"paranoidal-turret-groups.clear-tooltip"}})
	body.add({type = "line"})
	body.add({type = "button", name = PREFIX .. "air", caption = {"paranoidal-turret-groups.air"},
		tooltip = {"paranoidal-turret-groups.air-tooltip"}})
	body.add({type = "label", name = PREFIX .. "size"})
	update(player)
end

local function ensure(player)
	local frame = frame_of(player)
	if not (frame and frame.valid) then build(player) end
end

local function choose(set, key)
	if key then
		set[key] = (not set[key]) or nil
	else
		for k in pairs(set) do set[k] = nil end
	end
end

function M.on_click(event)
	local element = event.element
	if not (element and element.valid) or element.name:sub(1, #PREFIX) ~= PREFIX then return end
	local player = game.get_player(event.player_index)
	local p = player_state(player.index)
	local name = element.name:sub(#PREFIX + 1)
	if name == "title" then
		p.expanded = not p.expanded
	elseif name:sub(1, 4) == "who_" then
		choose(p.categories, name ~= "who_all" and element.tags.key or nil)
	elseif name:sub(1, 8) == "faction_" then
		choose(p.factions, name ~= "faction_all" and element.tags.key or nil)
	else
		local turret = opened_turret(player)
		if not turret then return end
		if name == "add" then
			add_names(turret, matching(p).names)
		elseif name == "remove" then
			remove_names(turret, matching(p).names)
		elseif name == "clear" then
			write_list(turret, {})
			forget_air(turret)
		elseif name == "air" then
			toggle_air(turret)
		end
	end
	update(player)
end

-- Окно турели другого вида (если движок тоже покажет панель) получает её скрытой.
function M.on_opened(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local player = game.get_player(event.player_index)
	if is_turret(event.entity) then ensure(player) end
	update(player)
end

-- Копирование настроек (Shift+ПКМ/ЛКМ, copy_settings): список и галку движок переносит сам, также между турелями
-- разных типов (пулемётная → лазерная, огнемётная; автотест enemies-panel); запись кнопки «летуны» переходит здесь.
function M.on_pasted(event)
	local source, destination = event.source, event.destination
	if not (is_turret(source) and is_turret(destination)) then return end
	local record = state().air[source.unit_number]
	if record then
		remember_air(destination, record)
	else
		forget_air(destination)
	end
end

-- HeroTurretRedux меняет ранг, пересоздавая турель в том же вызове (script_raised_destroy, затем
-- script_raised_built на том же месте): запись кнопки «летуны» переходит на новую турель.
-- Только между этими двумя событиями одного тика, поэтому не в storage: устаревшее значение с другим тиком
-- не применяется (у подключившегося игрока его нет).
local moving = nil

function M.on_script_destroy(event)
	local entity = event.entity
	if not is_turret(entity) then return end
	local record = state().air[entity.unit_number]
	if record then
		moving = {tick = event.tick, surface = entity.surface.index, x = entity.position.x, y = entity.position.y,
			record = record}
	end
end

function M.on_script_built(event)
	local entity = event.entity
	local m = moving
	moving = nil
	if not (m and m.tick == event.tick and is_turret(entity)) then return end
	if entity.surface.index == m.surface and entity.position.x == m.x and entity.position.y == m.y then
		remember_air(entity, m.record)
	end
end

function M.on_destroyed(event)
	if event.type == defines.target_type.entity and event.useful_id then
		local s = storage.turret_priority_groups
		if s then s.air[event.useful_id] = nil end
	end
end

function M.on_configuration_changed()
	groups = nil
	for _, player in pairs(game.players) do
		local frame = frame_of(player)
		if frame then frame.destroy() end
	end
	local s = storage.turret_priority_groups
	if s then
		-- выбор, которого больше нет в сборке, сбрасывается
		local g = load_groups()
		local categories, factions = set_of(g.categories), set_of(g.factions)
		for _, p in pairs(s.players) do
			for key in pairs(p.categories) do if not categories[key] then p.categories[key] = nil end end
			for key in pairs(p.factions) do if not factions[key] then p.factions[key] = nil end end
		end
	end
end

function M.on_player_removed(event)
	local s = storage.turret_priority_groups
	if s then s.players[event.player_index] = nil end
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
	on(defines.events.on_gui_click, M.on_click)
	on(defines.events.on_gui_opened, M.on_opened)
	on(defines.events.on_entity_settings_pasted, M.on_pasted)
	on(defines.events.script_raised_destroy, M.on_script_destroy)
	on(defines.events.script_raised_built, M.on_script_built)
	on(defines.events.on_object_destroyed, M.on_destroyed)
	on(defines.events.on_player_removed, M.on_player_removed)
	-- Крючок диагностического мода локальных тестов: события GUI скрипт не вызывает, тест зовёт те же обработчики
	-- с настоящими элементами. Регистрируется только при активном моде pd-port21-diag.
	if script.active_mods["pd-port21-diag"] then
		remote.add_interface("paranoidal-turret-groups-test", {
			open = function(index, entity)
				local player = game.get_player(index)
				player.opened = entity
				M.on_opened({player_index = index, gui_type = defines.gui_type.entity, entity = entity})
				return frame_of(player) ~= nil and frame_of(player).visible
			end,
			why = function(index)
				local player = game.get_player(index)
				local opened = player.opened
				return {opened = opened and opened.object_name == "LuaEntity" and opened.name or tostring(opened),
					gui_type = player.opened_gui_type, controller = player.controller_type,
					surface = player.surface.name, connected = player.connected, frame = frame_of(player) ~= nil}
			end,
			click = function(index, name)
				local frame = frame_of(game.get_player(index))
				local element = frame and find(frame, PREFIX .. name)
				if not element then return false end
				M.on_click({element = element, player_index = index})
				return true
			end,
			caption = function(index, name)
				local frame = frame_of(game.get_player(index))
				local element = frame and find(frame, PREFIX .. name)
				return element and {visible = element.visible, toggled = element.type == "button" and element.toggled or nil,
					caption = element.caption} or nil
			end,
			groups = function()
				local g = load_groups()
				local copies = 0
				for _, entry in ipairs(g.entries) do copies = copies + #entry.copies end
				return {entries = #g.entries, copies = copies, categories = g.categories, factions = g.factions,
					flyers = #flyers(), not_flyers = #not_flyers()}
			end,
			list = function(turret) return read_list(turret) end,
			air_record = function(turret)
				local record = state().air[turret.unit_number]
				return record and {kept = #record.kept, removed = #record.removed, ignore = record.ignore} or nil
			end,
		})
	end
end

return M
