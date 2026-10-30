local util = require("util")

local name = "hidden-electric-resistance"
local consumption = settings.startup["electric-resistance-power-consumption"].value
-- control.lua changes the draw at runtime (power_usage) with the seasons; the input limit and the
-- buffer must fit the largest seasonal value as well as the setting.
local limit = consumption
for _, kw in pairs(require("seasons")) do limit = math.max(limit, kw) end

-- Невидимый потребитель, который скрипт ставит на каждый электростолб.
-- Тянет `consumption` кВт из той электросети, где стоит столб (UPS-free — считает движок).
data:extend({
  {
    type = "electric-energy-interface",
    name = name,
    icon = "__ElectricResistance2__/graphics/icons/" .. name .. ".png",
    icon_size = 32,
    flags = {
      "placeable-off-grid",
      "not-on-map",
      "not-blueprintable",
      "not-deconstructable",
      "not-selectable-in-game",
      "not-repairable",
      "not-flammable",
      "hide-alt-info",
    },
    collision_mask = { layers = {} }, -- 2.0-формат: без коллизий
    selectable_in_game = false,
    allow_copy_paste = false,
    gui_mode = "none",
    max_health = 100,
    energy_source = {
      type = "electric",
      -- буфер должен покрывать расход за тик (N кВт / 60 ≈ 16.7·N Дж), иначе
      -- interface тянет лишь buffer·60 Вт вместо N кВт (баг «столбов много, кВт мало»)
      buffer_capacity = (17 * limit) .. "J",
      input_flow_limit = limit .. "kW",
      output_flow_limit = "0kW",
      usage_priority = "primary-input",
      render_no_power_icon = false,
    },
    energy_usage = consumption .. "kW",
    energy_production = "0kW",
    picture = util.empty_sprite(), -- невидимо: скрытый потребитель, не рисуется на карте
  },
})
