if not fli then
    fli = {}
end

flientities = 
{
  "fluid-level-indicator",
  "fluid-level-indicator-straight",
}

require("fli/fli_gui")

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
  if globalcontainer ~= nil then
    globalcontainer.destroy()
  end
end


function removedfli(removed_entity)
  if removed_entity == nil then
    return
  end
  for _, entityname in ipairs(flientities) do
    if removed_entity.name == entityname then
      storage.flis[removed_entity.unit_number] = nil
      storage.flitype[removed_entity.unit_number] = nil
      if settings.startup["font-picker"].value=="sprite" then
        destroyit(storage.flidig1[removed_entity.unit_number])
        destroyit(storage.flidig10[removed_entity.unit_number])
        destroyit(storage.flidig100[removed_entity.unit_number])
        destroyit(storage.flidigpc[removed_entity.unit_number])
        
        storage.flidig1[removed_entity.unit_number] = nil
        storage.flidig10[removed_entity.unit_number] = nil
        storage.flidig100[removed_entity.unit_number] = nil
        storage.flidigpc[removed_entity.unit_number] = nil
      else
        destroyit(storage.flitexts[removed_entity.unit_number])
        storage.flitexts[removed_entity.unit_number] = nil
      end
    end
  end
end


local function move_textbox(fli)
  if settings.startup['font-picker'].value == 'sprite' then
      if storage.flidig100[fli.unit_number] then
          storage.flidig100[fli.unit_number].target = { fli.position.x - 0.29, fli.position.y - 0.06 }
      end
      if storage.flidig10[fli.unit_number] then
          storage.flidig10[fli.unit_number].target = { fli.position.x - 0.12, fli.position.y - 0.06 }
      end
      if storage.flidig1[fli.unit_number] then
          storage.flidig1[fli.unit_number].target = { fli.position.x + 0.1, fli.position.y - 0.06 }
      end
      if storage.flidigpc[fli.unit_number] then
          storage.flidigpc[fli.unit_number].target = { fli.position.x + 0.28, fli.position.y - 0.06 }
      end
  elseif settings.startup['font-picker'].value == 'default' then
      if storage.flitexts[fli.unit_number] then
          storage.flitexts[fli.unit_number].target = { fli.position.x, fli.position.y - 0.34 }
      end
  else
      if storage.flitexts[fli.unit_number] then
          storage.flitexts[fli.unit_number].target = { fli.position.x + 0.03, fli.position.y - 0.32 }
      end
  end
end


local function fli_update()

  if not next(storage.flis) then return end

  for _ = 0, settings.global["number_of_units_to_check_per_update"].value do
    storage.fliindex, fli = next(storage.flis, storage.fliindex)
    if not fli then return end

    if fli.valid then
      local surface = fli.surface
      local unit_number = fli.unit_number
      storage.flitype[unit_number] = storage.flitype[unit_number] or 1
      local fluid_count = 0
      local fluidbox = fli.fluidbox[1]

      if fluidbox~=nil and fluidbox.amount > 0 then
        local fluid_count_actual = fli.get_fluid_count(fluidbox)
        local capacity = fli.fluidbox.get_prototype(1).volume
        fluid_count = (fluid_count_actual / capacity) * 100
      end

      local color = {1, 1, 1, 1}
      color = calc_color(fluid_count, storage.flitype[fli.unit_number])
      if settings.startup["font-picker"].value=="sprite" then
        if storage.flidig100[fli.unit_number] ~= nil then
          if storage.flidig100[fli.unit_number].target ~= { fli.position.x - 0.29, fli.position.y - 0.06 } then 
            move_textbox(fli)
          end
        end
        storage.flidig1[storage.fliindex].sprite = get_digit(tostring(string.format("%.f",fluid_count)),1)
        storage.flidig10[storage.fliindex].sprite = get_digit(tostring(string.format("%.f",fluid_count)),2)
        storage.flidig100[storage.fliindex].sprite = get_digit(tostring(string.format("%.f",fluid_count)),3)
        storage.flidigpc[storage.fliindex].sprite = "flinumberpc"
        storage.flidig1[fli.unit_number].color = color
        storage.flidig10[fli.unit_number].color = color
        storage.flidig100[fli.unit_number].color = color
        storage.flidigpc[fli.unit_number].color = color
      else
        if storage.flitexts[fli.unit_number].target ~= { fli.position.x, fli.position.y - 0.34 } then
          move_textbox(fli)
        end
        storage.flitexts[fli.unit_number].text = tostring(string.format("%.f",fluid_count)).."%"
        storage.flitexts[fli.unit_number].color = color
      end
    else
      if settings.startup["font-picker"].value=="sprite" then
        destroyit(storage.flidig1[storage.fliindex])
        destroyit(storage.flidig10[storage.fliindex])
        destroyit(storage.flidig100[storage.fliindex])
        destroyit(storage.flidigpc[storage.fliindex])
        storage.flidig1[storage.fliindex] = nil
        storage.flidig10[storage.fliindex] = nil
        storage.flidig100[storage.fliindex] = nil
        storage.flidigpc[storage.fliindex] = nil
        storage.flis[storage.fliindex] = nil
      else
        destroyit(storage.flitexts[storage.fliindex])
        storage.flitexts[storage.fliindex] = nil
        storage.flis[storage.fliindex] = nil
      end
    end
  end
end


local function create_textbox(fli, surface)

  if settings.startup["font-picker"].value=="sprite" then
    storage.flidig100[fli.unit_number] = rendering.draw_sprite(
    {
      sprite = "flinumber ",
      target = {fli.position.x-0.29,fli.position.y-0.06},
      surface = surface,
      tint = {r=1.0,  g=0.0,  b=0.0, a=0.9},
      x_scale = 0.05,
      y_scale = 0.05,
    })
    storage.flidig10[fli.unit_number] = rendering.draw_sprite(
    {
      sprite = "flinumber ",
      target = {fli.position.x-0.12,fli.position.y-0.06},
      surface = surface,
      tint = {r=1.0,  g=0.0,  b=0.0, a=0.9},
      x_scale = 0.05,
      y_scale = 0.05,
    })
    storage.flidig1[fli.unit_number] = rendering.draw_sprite(
    {
      sprite = "flinumber0",
      target = {fli.position.x+0.1,fli.position.y-0.06},
      surface = surface,
      tint = {r=1.0,  g=0.0,  b=0.0, a=0.9},
      x_scale = 0.05,
      y_scale = 0.05,
    })
    storage.flidigpc[fli.unit_number] = rendering.draw_sprite(
    {
      sprite = "flinumberpc",
      target = {fli.position.x+0.28,fli.position.y-0.06},
      surface = surface,
      tint = {r=1.0,  g=0.0,  b=0.0, a=0.9},
      x_scale = 0.05,
      y_scale = 0.05,
    })
  elseif settings.startup["font-picker"].value=="default" then
    storage.flitexts[fli.unit_number] = rendering.draw_text(
    {
      text = "0%",
      surface = surface,
      target = {fli.position.x,fli.position.y-0.34},
      color = {r=1,g=0,b=0,a=0.9},
      scale = 0.90,
      font = settings.startup["font-picker"].value,
      alignment = "center",
      vertical_alignment = "top",
      time_to_live = 0
    })
  else
    storage.flitexts[fli.unit_number] = rendering.draw_text(
    {
      text = "0%",
      surface = surface,
      target = {fli.position.x+0.03,fli.position.y-0.32},
      color = {r=1,g=0,b=0,a=0.9},
      scale = 1,
      font = settings.startup["font-picker"].value,
      alignment = "center",
      vertical_alignment = "top",
      time_to_live = 0
    })
  end
end


function flion_tick(event)

  if players_present then
    if game.tick % settings.global["update_every_x_tick"].value == 0 then
      fli_update()
    end
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
      for _,fli in pairs(surface.find_entities_filtered{name = name}) do
        if fli.unit_number~=nil then
          storage.flis[fli.unit_number] = fli
          if storage.flitype[fli.unit_number] == nil then
            storage.flitype[fli.unit_number] = 1
          end
          create_textbox(fli, surface)
          storage.fliindex = fli.unit_number
        end
      end
    end
  end
  if next(storage.flis)~= nil then
    storage.fliindex, fli = next(storage.flis, nil)
  end
end