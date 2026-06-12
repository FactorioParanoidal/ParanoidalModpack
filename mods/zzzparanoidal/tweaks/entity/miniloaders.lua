if mods.miniloader and settings.startup["miniloader-energy-usage"].value then  --don't tweak energy usage, if it disabled
  local energy_multiplier = settings.startup["paranoidal-miniloader-energy-multiplier"].value or 4
  local energy_string = 2*energy_multiplier .. "kJ"
  for _,inserter in pairs(data.raw.inserter) do
    if string.find(inserter.name, "miniloader%-inserter$") then
      inserter.energy_per_movement = energy_string
      inserter.energy_per_rotation = energy_string
    end
  end
end

-- ── Синхронизация скоростей miniloader-redux со скоростями лент ───────────────
-- В 1.1 это делал beltentities.lua (блок `if mods.miniloader`); при порте на 2.0
-- перенесли только половину (ленты), и лоадеры уехали на сток-шкалу Bob's.
-- В miniloader-redux реальный throughput даёт ПРОТОТИП-ИНСЕРТЕР (rotation_speed/
-- stack_size_bonus, рантайм клонирует его inserter_pairs*2 раз — scripts/controller.lua).
-- speed_config.items_per_second идёт только в тултип + флаг highspeed (>240/полоса),
-- а loader-1x1.speed — визуальный сегмент ленты. Поэтому правим все три.
-- Throughput в линейной зоне ≈ 240 * rotation_speed при stack 0 / 1 паре
-- (родные точки мода: rot 0.125 -> 30/с, rot 0.25 -> 60/с); пары масштабируют линейно.
if mods["miniloader-redux"] and data.raw["mod-data"] and data.raw["mod-data"]["miniloader"] then
  local md = data.raw["mod-data"]["miniloader"]

  -- тир ленты -> минилоадер; rotation/stack/pairs подведены под скорость ленты.
  -- basic/yellow/fast уже совпадают с лентами, их инсертер не трогаем (только loader-сегмент).
  local tiers = {
    { belt = "bob-basic-transport-belt",      ml = "hps__ml-bob-basic-miniloader" },
    { belt = "transport-belt",                ml = "hps__ml-miniloader" },
    { belt = "fast-transport-belt",           ml = "hps__ml-fast-miniloader" },
    { belt = "express-transport-belt",        ml = "hps__ml-express-miniloader",      rotation = 0.25,  stack = 0, pairs = 1 },
    { belt = "turbo-transport-belt",          ml = "hps__ml-turbo-miniloader",    rotation = 0.375, stack = 0, pairs = 1 },
    { belt = "bob-ultimate-transport-belt",   ml = "hps__ml-bob-ultimate-miniloader", rotation = 0.375, stack = 0, pairs = 2 },
  }

  local f_open, f_close = "[font=default-semibold][color=255,230,192]", ":[/color][/font] "

  local function fmt(n)
    if n % 1 == 0 then return string.format("%d", n) end
    return tostring(n)
  end

  for _, t in ipairs(tiers) do
    local belt = data.raw["transport-belt"][t.belt]
    local entry = md.data[t.ml]
    if belt and entry and entry.speed_config then
      local ips = belt.speed * 480

      -- визуальный сегмент ленты минилоадера
      local loader = data.raw["loader-1x1"][t.ml .. "-l"]
      if loader then loader.speed = belt.speed end

      -- рантайм: число в тултипе + флаг highspeed
      entry.speed_config.items_per_second = ips

      -- рычаг throughput: прототип-инсертер (видимый + скрытый клон "-i")
      if t.rotation then
        entry.speed_config.inserter_pairs = t.pairs
        entry.speed_config.rotation_speed = t.rotation
        entry.speed_config.stack_size_bonus = t.stack
        for _, suffix in ipairs({ "", "-i" }) do
          local ins = data.raw["inserter"][t.ml .. suffix]
          if ins then
            ins.rotation_speed = t.rotation
            ins.extension_speed = t.rotation * 5
            ins.stack_size_bonus = t.stack
          end
        end
      end

      -- освежить число скорости в тултипе у видимой сущности
      local main = data.raw["inserter"][t.ml]
      if main then
        main.localised_description = { "",
          { "entity-description." .. t.ml }, "\n",
          f_open, { "description.belt-speed" }, f_close,
          fmt(ips), " ", { "description.belt-items" }, { "per-second-suffix" } }
      end
    end
  end

  -- turbo-минилоадер выпал в общую группу 'belt' вместо своего тира (сток-баг
  -- redux/reskins на turbo-rename) → ставим в bob-logistic-tier-4, как его лента.
  for _, kind in ipairs({ "item", "inserter" }) do
    local proto = data.raw[kind] and data.raw[kind]["hps__ml-turbo-miniloader"]
    if proto and proto.subgroup == "belt" then
      proto.subgroup = "bob-logistic-tier-4"
      proto.order = "d[a]-p"
    end
  end
end
