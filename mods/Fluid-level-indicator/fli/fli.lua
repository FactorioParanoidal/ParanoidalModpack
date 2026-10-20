if not fli then
    fli = {}
end

flientities = 
{
  "fluid-level-indicator",
  "fluid-level-indicator-straight",
}

require("fli/fli_gui")

-- Runtime settings are cached per load; control.lua calls fli_refresh_settings on change.
local update_interval, units_per_update
function fli_refresh_settings()
  update_interval = math.max(1, settings.global["update_every_x_tick"].value)
  units_per_update = settings.global["number_of_units_to_check_per_update"].value
end

local font_setting = settings.startup["font-picker"].value
local sprite_font = font_setting == "sprite"

-- Fluidbox volume per prototype name: constant for the session, read once instead of per update.
local capacity_by_name = {}

local function players_present()

    local players_present = false
  for _, player in pairs(game.players) do
    if player.connected then
      players_present = true
      break
    end
   end
   return players_present
end


local function get_digit(num, digit)

  local length = #num
  if digit < 1 or digit > length then
    return "flinumber "
  end
  return ("flinumber"..string.sub(num, length - digit + 1, length - digit + 1))
end


local function set_color(unit, fluid_count)

  rendering.set_color(unit, 
  {
    r=0.8*math.max(0, fluid_count < 50 and 1 or (100 - fluid_count) / 50),  
    g=0.8*math.max(0, tonumber((fluid_count >= 50 and fluid_count <= 100) and 1 or ((fluid_count >= 0 and fluid_count < 50) and fluid_count / 50 or 0))),
    b=0
  })
end


local function calc_color(fluid_count, fli_type)

  b = 0
  a = 1
  if fli_type == 1 then
    -- normal color
    r=0.8*math.max(0, fluid_count < 50 and 1 or (100 - fluid_count) / 50)
    g=0.8*math.max(0, tonumber((fluid_count >= 50 and fluid_count <= 100) and 1 or ((fluid_count >= 0 and fluid_count < 50) and fluid_count / 50 or 0)))
  elseif fli_type == 2 then
    g = 0.8 * math.max(0, ((fluid_count > 25 and fluid_count < 75) and 1 or (((fluid_count <= 25 and (fluid_count / 25)) or (fluid_count >= 75 and math.abs(50-fluid_count/50)) and (-(fluid_count-100) / 25) or 0))))
    r = 0.8* ((fluid_count < 25 or fluid_count > 75) and 1 or 2*math.abs(50 - fluid_count) / 50)
  elseif fli_type == 3 then
    r=0.8*math.max(0, tonumber((fluid_count >= 50 and fluid_count <= 100) and 1 or ((fluid_count >= 0 and fluid_count < 50) and fluid_count / 50 or 0)))
    g=0.8*math.max(0, fluid_count < 50 and 1 or (100 - fluid_count) / 50)
  else
    r = 0.2
    g = 0.65
    b = 1
  end
  local color = {r, g, b, a}
  return color
end


local function destroyit(globalcontainer)
  if globalcontainer ~= nil and globalcontainer.valid then
    globalcontainer.destroy()
  end
end


function removedfli(removed_entity)
  if removed_entity == nil then
    return
  end
  for _, entityname in ipairs(flientities) do
    if removed_entity.name == entityname then
      local unit_number = removed_entity.unit_number
      storage.flis[unit_number] = nil
      storage.flitype[unit_number] = nil
      -- A cleared key must not stay the `next` cursor of the update loop.
      if storage.fliindex == unit_number then
        storage.fliindex = nil
      end
      if sprite_font then
        destroyit(storage.flidig1[unit_number])
        destroyit(storage.flidig10[unit_number])
        destroyit(storage.flidig100[unit_number])
        destroyit(storage.flidigpc[unit_number])

        storage.flidig1[unit_number] = nil
        storage.flidig10[unit_number] = nil
        storage.flidig100[unit_number] = nil
        storage.flidigpc[unit_number] = nil
      else
        destroyit(storage.flitexts[unit_number])
        storage.flitexts[unit_number] = nil
      end
    end
  end
end


-- Render objects are attached to the indicator entity (target with offset): they follow it
-- without per-update moves and the engine removes them together with the entity.
local function create_textbox(fli, surface)

  local unit_number = fli.unit_number
  if sprite_font then
    storage.flidig100[unit_number] = rendering.draw_sprite(
    {
      sprite = "flinumber ",
      target = {entity = fli, offset = {-0.29, -0.06}},
      surface = surface,
      tint = {r=1.0,  g=0.0,  b=0.0, a=0.9},
      x_scale = 0.05,
      y_scale = 0.05,
    })
    storage.flidig10[unit_number] = rendering.draw_sprite(
    {
      sprite = "flinumber ",
      target = {entity = fli, offset = {-0.12, -0.06}},
      surface = surface,
      tint = {r=1.0,  g=0.0,  b=0.0, a=0.9},
      x_scale = 0.05,
      y_scale = 0.05,
    })
    storage.flidig1[unit_number] = rendering.draw_sprite(
    {
      sprite = "flinumber0",
      target = {entity = fli, offset = {0.1, -0.06}},
      surface = surface,
      tint = {r=1.0,  g=0.0,  b=0.0, a=0.9},
      x_scale = 0.05,
      y_scale = 0.05,
    })
    storage.flidigpc[unit_number] = rendering.draw_sprite(
    {
      sprite = "flinumberpc",
      target = {entity = fli, offset = {0.28, -0.06}},
      surface = surface,
      tint = {r=1.0,  g=0.0,  b=0.0, a=0.9},
      x_scale = 0.05,
      y_scale = 0.05,
    })
  elseif font_setting == "default" then
    storage.flitexts[unit_number] = rendering.draw_text(
    {
      text = "0%",
      surface = surface,
      target = {entity = fli, offset = {0, -0.34}},
      color = {r=1,g=0,b=0,a=0.9},
      scale = 0.90,
      font = font_setting,
      alignment = "center",
      vertical_alignment = "top",
      time_to_live = 0
    })
  else
    storage.flitexts[unit_number] = rendering.draw_text(
    {
      text = "0%",
      surface = surface,
      target = {entity = fli, offset = {0.03, -0.32}},
      color = {r=1,g=0,b=0,a=0.9},
      scale = 1,
      font = font_setting,
      alignment = "center",
      vertical_alignment = "top",
      time_to_live = 0
    })
  end
end


local function fli_update()

  local flis = storage.flis
  if not next(flis) then return end
  local flitype = storage.flitype

  for _ = 0, units_per_update do
    local index, fli = next(flis, storage.fliindex)
    storage.fliindex = index
    if not fli then return end

    if fli.valid then
      local fli_type = flitype[index] or 1
      flitype[index] = fli_type
      local fluid_count = 0
      local fluidbox = fli.fluidbox[1]

      if fluidbox~=nil and fluidbox.amount > 0 then
        local capacity = capacity_by_name[fli.name]
        if not capacity then
          capacity = fli.fluidbox.get_prototype(1).volume
          capacity_by_name[fli.name] = capacity
        end
        fluid_count = (fluidbox.amount / capacity) * 100
      end

      local color = calc_color(fluid_count, fli_type)
      local digits = string.format("%.f", fluid_count)
      if sprite_font then
        local dig1 = storage.flidig1[index]
        if not (dig1 and dig1.valid) then
          create_textbox(fli, fli.surface)
          dig1 = storage.flidig1[index]
        end
        local dig10, dig100, digpc = storage.flidig10[index], storage.flidig100[index], storage.flidigpc[index]
        dig1.sprite = get_digit(digits, 1)
        dig10.sprite = get_digit(digits, 2)
        dig100.sprite = get_digit(digits, 3)
        dig1.color = color
        dig10.color = color
        dig100.color = color
        digpc.color = color
      else
        local text = storage.flitexts[index]
        if not (text and text.valid) then
          create_textbox(fli, fli.surface)
          text = storage.flitexts[index]
        end
        text.text = digits.."%"
        text.color = color
      end
    else
      -- Entity gone without an event: drop the record and restart the cursor safely.
      if sprite_font then
        destroyit(storage.flidig1[index])
        destroyit(storage.flidig10[index])
        destroyit(storage.flidig100[index])
        destroyit(storage.flidigpc[index])
        storage.flidig1[index] = nil
        storage.flidig10[index] = nil
        storage.flidig100[index] = nil
        storage.flidigpc[index] = nil
      else
        destroyit(storage.flitexts[index])
        storage.flitexts[index] = nil
      end
      flitype[index] = nil
      flis[index] = nil
      storage.fliindex = nil
    end
  end
end


function flion_tick(event)

  if not update_interval then fli_refresh_settings() end
  if event.tick % update_interval ~= 0 then return end
  if not storage.fli_attached_targets then
    -- Older saves: render objects were placed by position and moved on every update.
    register_flis()
  end
  if players_present() then
    fli_update()
  end
end


function placedfli(placed_entity)

  local surface = placed_entity.surface
  for _, entityname in ipairs(flientities) do
    if placed_entity.name == entityname then
      storage.flis[placed_entity.unit_number] = placed_entity
      create_textbox(placed_entity, surface)
      storage.fliindex = placed_entity.unit_number
      storage.flitype[placed_entity.unit_number] = 1
    end
  end
end


function register_flis()
  rendering.clear("Fluid-level-indicator")
  for _,surface in pairs(game.surfaces) do
    for _, name in pairs(flientities) do
      for _,found in pairs(surface.find_entities_filtered{name = name}) do
        if found.unit_number~=nil then
          storage.flis[found.unit_number] = found
          if storage.flitype[found.unit_number] == nil then
            storage.flitype[found.unit_number] = 1
          end
          create_textbox(found, surface)
          storage.fliindex = found.unit_number
        end
      end
    end
  end
  storage.fliindex = nil
  storage.fli_attached_targets = true
end
