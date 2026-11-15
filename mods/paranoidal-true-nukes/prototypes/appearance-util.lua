local function generateAppearance(thing)
  --  if not thing then
  --    return {icons = {}, pictures = {}}
  --  end
  local icons = nil
  local pictures = nil
  local lights = nil
  if(thing.appearance) then
    icons = thing.appearance.icons
    pictures = thing.appearance.pictures
    lights = thing.appearance.lights
  else
    if(thing.icons) then
      icons = thing.icons
    elseif(thing.icon) then
      icons = {thing.icon}
    end
    if(thing.pictures) then
      pictures = thing.pictures
    elseif(thing.picture) then
      pictures = {thing.picture}
    end
    if(thing.lights) then
      lights = thing.lights
    elseif(thing.light) then
      lights = {thing.light}
    end
  end
  local iconsFinal = {}
  local picturesFinal = {}
  if (icons) then
    for _,i in pairs(icons) do
      if(type(i) == "table") then
        if(i.size) then
          local tmp = table.deepcopy(i)
          tmp.icon_size = tmp.size
          table.insert(iconsFinal, tmp)
        else
          table.insert(iconsFinal, i)
        end
      else
        table.insert(iconsFinal, {icon = i, icon_size = 64})
      end
    end
    if(not pictures) then
      pictures = {}
      for _,i in pairs(iconsFinal) do
        if not i.special then
          table.insert(pictures, table.deepcopy(i))
        end
      end
      if(lights) then
        for _,l in pairs(lights) do
          local lightSetup = {}
          if(type(l) == "table") then
            if(l.icon) then
              local shift = {0, 0}
              if(l.shift) then
                shift = {l.shift[1]*0.01875, l.shift[2]*0.01875}
              end
              lightSetup = {filename = l.icon, size = l.icon_size or l.size or 64, scale = (l.scale or 32/(l.icon_size or l.size or 64))*32.0/(l.icon_size or l.size or 64), shift = shift, draw_as_light = true, flags = {"light"}, tint = l.tint}
            else
              lightSetup = l
            end
          else
            lightSetup = {filename = l, size = 64, scale = 0.25, draw_as_light = true, flags = {"light"}}
          end
          table.insert(pictures, lightSetup)
        end
      end
    end
  end
  if (pictures) then
    for _,p in pairs(pictures) do
      if(type(p) == "table") then
        if(p.icon) then
          local shift = {0, 0}
          if(p.shift) then
            shift = {p.shift[1]*0.01875, p.shift[2]*0.01875}
          end
          table.insert(picturesFinal, {filename = p.icon, size = p.icon_size or p.size or 64, scale = (p.scale or 32/(p.icon_size or p.size or 64))*32.0/(p.icon_size or p.size or 64), shift = shift, tint = p.tint, special = p.special})
        else
          table.insert(picturesFinal, p)
        end
      else
        table.insert(picturesFinal, {filename = p, size = 64, scale = 0.25})
      end
    end
  end
  return {icons = table.deepcopy(iconsFinal), pictures = table.deepcopy(picturesFinal)}
end


return generateAppearance
