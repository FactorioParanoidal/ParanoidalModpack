-- RuNames-reforged: русские имена для станций, локомотивов, лабораторий, радаров и дронстанций.
-- Объединяет Namelists, RussianStations2 и Renamer: автоимя при постройке, Ctrl+N и окно Ctrl+R.

local sets = require("sets")

-- Типы с backer_name в Factorio 2.0 (LuaEntity::backer_name).
local NAMED_TYPES = {
  ["train-stop"] = true,
  ["locomotive"] = true,
  ["lab"] = true,
  ["radar"] = true,
  ["roboport"] = true,
}

-- Сколько раз перевыбирать имя, если оно уже выдавалось.
local MAX_TRIES = 10

-- Списки собираются при загрузке скрипта из файлов наборов; в storage хранится только выданное.
-- Элемент списка: строка или {строка, вес}. В строке "{@пул}" заменяется словом из pools набора,
-- "{@^пул}" — тем же словом с заглавной буквы, "{N-M}" — числом от N до M (с ведущими нулями,
-- если N записано с нулём впереди).
local compiled = {}
for _, set in ipairs(sets) do
  if set.module then
    local source = require(set.module)
    local lists = {}
    for entity_type in pairs(NAMED_TYPES) do
      local list = source[entity_type]
      if list and #list > 0 then
        local items, cumulative, total = {}, {}, 0
        for index, entry in ipairs(list) do
          local text, weight = entry, 1
          if type(entry) == "table" then
            text, weight = entry[1], entry[2]
          end
          total = total + weight
          items[index] = text
          cumulative[index] = total
        end
        lists[entity_type] = {
          items = items,
          cumulative = cumulative,
          total = total,
          uniform = (total == #items),
          pools = source.pools or {},
        }
      end
    end
    compiled[set.id] = lists
  end
end

-- Заглавные буквы для первой буквы слова (string.upper не меняет кириллицу).
local UPPER = {}
do
  local lower_chars, upper_chars = {}, {}
  for char in ("абвгдеёжзийклмнопрстуфхцчшщъыьэюя"):gmatch("[\192-\255][\128-\191]*") do
    lower_chars[#lower_chars + 1] = char
  end
  for char in ("АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"):gmatch("[\192-\255][\128-\191]*") do
    upper_chars[#upper_chars + 1] = char
  end
  for index, char in ipairs(lower_chars) do
    UPPER[char] = upper_chars[index]
  end
end

local function capitalize(word)
  local first, rest = word:match("^([\192-\255][\128-\191]*)(.*)$")
  if first and UPPER[first] then
    return UPPER[first] .. rest
  end
  return word:sub(1, 1):upper() .. word:sub(2)
end

local function expand(text, pools)
  if not text:find("{", 1, true) then
    return text
  end
  text = text:gsub("{@(%^?)([%w_]+)}", function(caret, pool_name)
    local pool = pools[pool_name]
    local word = pool[math.random(#pool)]
    if caret ~= "" then
      return capitalize(word)
    end
    return word
  end)
  text = text:gsub("{(%d+)%-(%d+)}", function(low, high)
    local value = math.random(tonumber(low), tonumber(high))
    if #low > 1 and low:sub(1, 1) == "0" then
      return string.format("%0" .. #low .. "d", value)
    end
    return tostring(value)
  end)
  return text
end

local function random_backer_name()
  local names = game.backer_names
  return names[math.random(#names)]
end

local function roll(set, entity_type)
  if set.backer then
    return random_backer_name()
  end
  local list = compiled[set.id][entity_type]
  local index
  if list.uniform then
    index = math.random(#list.items)
  else
    local target = math.random(list.total)
    local low, high = 1, #list.cumulative
    while low < high do
      local middle = math.floor((low + high) / 2)
      if list.cumulative[middle] < target then
        low = middle + 1
      else
        high = middle
      end
    end
    index = low
  end
  return expand(list.items[index], list.pools)
end

local function enabled_sets(entity_type)
  local result = {}
  for _, set in ipairs(sets) do
    if settings.global["runames-set-" .. set.id].value and (set.backer or compiled[set.id][entity_type]) then
      result[#result + 1] = set
    end
  end
  return result
end

-- Каждый включённый набор, где есть список для типа, выбирается с равным шансом.
-- Возвращает nil, если подходящих наборов нет.
local function pick_name(entity_type)
  local candidates = enabled_sets(entity_type)
  if #candidates == 0 then
    return nil
  end
  local used = storage.used
  local name
  for _ = 1, MAX_TRIES do
    name = roll(candidates[math.random(#candidates)], entity_type)
    if not used[name] then
      break
    end
  end
  used[name] = true
  return name
end

local function inner_type(entity)
  if entity.type == "entity-ghost" then
    return entity.ghost_type
  end
  return entity.type
end

local backer_lookup = nil
local function is_backer_name(name)
  if not backer_lookup then
    backer_lookup = {}
    for _, backer in pairs(game.backer_names) do
      backer_lookup[backer] = true
    end
  end
  return backer_lookup[name] == true
end

-- Призрак получает имя, только если оно пустое: имена из чертежей и отмены сохраняются,
-- а робот строит сущность уже с именем призрака. Готовая сущность переименовывается,
-- только если движок выдал ей имя спонсора.
local function auto_name(entity, from_script)
  if not (entity and entity.valid) then
    return
  end
  local entity_type = inner_type(entity)
  if not NAMED_TYPES[entity_type] then
    return
  end
  if entity.type == "entity-ghost" then
    if entity.backer_name ~= "" then
      return
    end
  elseif not is_backer_name(entity.backer_name) then
    return
  elseif from_script and settings.global["runames-set-backer"].value then
    return
  end
  local name = pick_name(entity_type)
  if name then
    entity.backer_name = name
  end
end

local function init_storage()
  storage.used = storage.used or {}
  storage.renamer = storage.renamer or {}
end

script.on_init(init_storage)
script.on_configuration_changed(init_storage)

local built_filters = {}
local script_filters = {}
for entity_type in pairs(NAMED_TYPES) do
  built_filters[#built_filters + 1] = {filter = "type", type = entity_type}
  built_filters[#built_filters + 1] = {filter = "ghost_type", type = entity_type}
  script_filters[#script_filters + 1] = {filter = "type", type = entity_type}
end

script.on_event(defines.events.on_built_entity, function(event)
  auto_name(event.entity, false)
end, built_filters)

-- Сущности, созданные скриптами других модов: движок выдал им имя спонсора.
script.on_event(defines.events.script_raised_built, function(event)
  auto_name(event.entity, true)
end, script_filters)

-- Ctrl+N: новое случайное имя для сущности под курсором.
script.on_event("runames-random-name", function(event)
  local player = game.get_player(event.player_index)
  local entity = player and player.selected
  if entity and entity.valid and entity.supports_backer_name() then
    entity.backer_name = pick_name(inner_type(entity)) or random_backer_name()
  end
end)

-- Ctrl+R: окно переименования (бывший мод Renamer).
local function close_gui(player)
  local frame = player.gui.screen.runames_frame
  if frame then
    frame.destroy()
  end
  storage.renamer[player.index] = nil
end

local function target_of(player)
  local target = storage.renamer[player.index]
  if target and target.valid then
    return target
  end
end

local function textfield_of(player)
  local frame = player.gui.screen.runames_frame
  return frame and frame.runames_content_flow.runames_textfield
end

local function open_gui(player, entity)
  close_gui(player)
  storage.renamer[player.index] = entity
  local frame = player.gui.screen.add{type = "frame", name = "runames_frame", direction = "vertical"}
  frame.style.bottom_padding = 4
  local title = frame.add{type = "flow", name = "runames_titlebar_flow", style = "runames_titlebar_flow"}
  local label = title.add{type = "label", style = "frame_title", caption = {"runames-gui.title"}}
  label.drag_target = frame
  local filler = title.add{type = "empty-widget", style = "draggable_space_header"}
  filler.style.horizontally_stretchable = true
  filler.style.natural_height = 24
  filler.style.right_margin = 7
  filler.style.left_margin = 7
  filler.drag_target = frame
  title.add{type = "sprite-button", name = "runames_cancel", sprite = "utility/close",
    style = "frame_action_button", tooltip = {"runames-gui.cancel"}}
  local content = frame.add{type = "flow", name = "runames_content_flow"}
  content.style.vertical_align = "center"
  local shuffle = content.add{type = "sprite-button", name = "runames_random", sprite = "utility/shuffle",
    style = "tool_button", tooltip = {"runames-gui.random"}}
  shuffle.style.top_margin = 1
  local reset = content.add{type = "sprite-button", name = "runames_reset", sprite = "utility/refresh",
    style = "tool_button", tooltip = {"runames-gui.reset"}}
  reset.style.top_margin = 1
  local textfield = content.add{type = "textfield", name = "runames_textfield", style = "stretchable_textfield",
    icon_selector = true, text = entity.backer_name}
  local commit = content.add{type = "sprite-button", name = "runames_commit", sprite = "utility/enter",
    style = "item_and_count_select_confirm", tooltip = {"runames-gui.commit"}}
  commit.style.top_margin = 1
  textfield.select_all()
  textfield.focus()
  frame.force_auto_center()
  player.opened = textfield
end

local function commit_rename(player)
  local target = target_of(player)
  local textfield = textfield_of(player)
  if target and textfield then
    target.backer_name = textfield.text
  end
  close_gui(player)
end

local function set_text(player, text)
  local textfield = textfield_of(player)
  if not textfield then
    return
  end
  if text then
    textfield.text = text
  end
  textfield.select_all()
  textfield.focus()
end

script.on_event("runames-rename", function(event)
  local player = game.get_player(event.player_index)
  if not player then
    return
  end
  close_gui(player)
  local entity = player.selected
  if entity and entity.valid and entity.supports_backer_name() then
    open_gui(player, entity)
  end
end)

script.on_event(defines.events.on_gui_confirmed, function(event)
  if event.element.name == "runames_textfield" then
    commit_rename(game.get_player(event.player_index))
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.valid and event.element.name == "runames_textfield" then
    close_gui(game.get_player(event.player_index))
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local name = event.element.name
  if name:sub(1, 8) ~= "runames_" then
    return
  end
  local player = game.get_player(event.player_index)
  if name == "runames_cancel" then
    close_gui(player)
  elseif name == "runames_commit" then
    commit_rename(player)
  elseif name == "runames_reset" then
    local target = target_of(player)
    set_text(player, target and target.backer_name)
  elseif name == "runames_random" then
    local target = target_of(player)
    set_text(player, target and (pick_name(inner_type(target)) or random_backer_name()))
  end
end)

script.on_event(defines.events.on_player_removed, function(event)
  storage.renamer[event.player_index] = nil
end)
