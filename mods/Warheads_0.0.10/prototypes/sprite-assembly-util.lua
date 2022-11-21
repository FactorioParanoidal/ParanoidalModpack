
local tints = {
  californium = {a=1, b = 0.1, g = 1, r = 0.95, l=true},
  uraniumLive = {a=1, b = 0.1, g = 1, r = 0.3, l=true},
  uraniumDead = {a=1, b = 0.15, g = 0.4, r = 0.15},
  tritium = {a=1, b = 0.95, g = 0.95, r = 0.15, l=true},
  nothing = {a=1, b = 0.5, g = 0.5, r = 0.5},
  lightNothing = {a=1, b = 0.95, g = 0.95, r = 0.95},
  explosive = {a=1, b = 0.1, g = 0.1, r = 0.9},
  flamable = {a=1, b = 0.1, g = 0.4, r = 0.9},
}

local sprite_types = {
  artillery = {
    {
      base = "__base__/graphics/icons/artillery-shell.png"
    },
    {
      sections = {
        "__Warheads__/graphics/artillery/artillery-shell-tip.png",
      },
      lights = {
        "__Warheads__/graphics/artillery/artillery-shell-tip.png",
      },
      final = "__Warheads__/graphics/artillery/artillery-shell-base.png"
    },
    {
      base = "__Warheads__/graphics/artillery/artillery-shell-ring-1-base-left.png",
      sections = {
        "__Warheads__/graphics/artillery/artillery-shell-tip.png",
        "__Warheads__/graphics/artillery/artillery-shell-ring-1.png"
      },
      lights = {
        "__Warheads__/graphics/artillery/artillery-shell-tip.png",
        "__Warheads__/graphics/artillery/artillery-shell-ring-1.png"
      },
      final = "__Warheads__/graphics/artillery/artillery-shell-ring-1-base-right.png"
    },
    {
      base = "__Warheads__/graphics/artillery/artillery-shell-ring-2-base-left.png",
      sections = {
        "__Warheads__/graphics/artillery/artillery-shell-tip.png",
        "__Warheads__/graphics/artillery/artillery-shell-ring-1.png",
        "__Warheads__/graphics/artillery/artillery-shell-ring-2.png"
      },
      lights = {
        "__Warheads__/graphics/artillery/artillery-shell-tip.png",
        "__Warheads__/graphics/artillery/artillery-shell-ring-1.png",
        "__Warheads__/graphics/artillery/artillery-shell-ring-2.png"
      },
      final = "__Warheads__/graphics/artillery/artillery-shell-ring-2-base-right.png"
    },
    {
      base = "__Warheads__/graphics/artillery/artillery-shell-ring-fat-base-left.png",
      sections = {
        "__Warheads__/graphics/artillery/artillery-shell-tip.png",
        "__Warheads__/graphics/artillery/artillery-shell-ring-fat.png"
      },
      lights = {
        "__Warheads__/graphics/artillery/artillery-shell-tip.png",
        "__Warheads__/graphics/artillery/artillery-shell-ring-fat.png"
      },
      final = "__Warheads__/graphics/artillery/artillery-shell-ring-fat-base-right.png",
    },
  },
  cannon = {
    {
      base = "__Warheads__/graphics/cannon/cannon-shell-base.png"
    },
    {
      base = "__Warheads__/graphics/cannon/cannon-shell-base.png",
      sections = {
        "__Warheads__/graphics/cannon/cannon-shell-tip.png",
      },
      lights = {
        "__Warheads__/graphics/cannon/cannon-shell-tip.png",
      },
      final = "__Warheads__/graphics/cannon/cannon-shell-base-top.png"
    },
    {
      base = "__Warheads__/graphics/cannon/cannon-shell-base.png",
      sections = {
        "__Warheads__/graphics/cannon/cannon-shell-edge.png",
      },
      lights = {
        "__Warheads__/graphics/cannon/cannon-shell-edge.png",
      },
      final = "__Warheads__/graphics/cannon/cannon-shell-base-top.png"
    },
    {
      base = "__Warheads__/graphics/cannon/cannon-shell-base.png",
      sections = {
        "__Warheads__/graphics/cannon/cannon-shell-tip.png",
        "__Warheads__/graphics/cannon/cannon-shell-edge.png",
      },
      lights = {
        "__Warheads__/graphics/cannon/cannon-shell-tip.png",
        "__Warheads__/graphics/cannon/cannon-shell-edge.png",
      },
      final = "__Warheads__/graphics/cannon/cannon-shell-base-top.png"
    },
  },
  rocket = {
    {
      base = "__Warheads__/graphics/rockets/rocket.png"
    },
    {
      base = {
        "__Warheads__/graphics/rockets/rocket-fins.png",
      },
      sections = {
        "__Warheads__/graphics/rockets/rocket-tip.png",
      },
      lights = {
        "__Warheads__/graphics/rockets/rocket-tip-light.png",
      },
      final = {
        "__Warheads__/graphics/rockets/rocket-ring-1.png",
        "__Warheads__/graphics/rockets/rocket-ring-2.png",
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
        "__Warheads__/graphics/rockets/rocket-engine.png",
      },
    },
    {
      base = {
        "__Warheads__/graphics/rockets/rocket-fins.png",
      },
      sections = {
        "__Warheads__/graphics/rockets/rocket-tip.png",
        "__Warheads__/graphics/rockets/rocket-ring-1.png",
      },
      lights = {
        "__Warheads__/graphics/rockets/rocket-tip-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-1-light.png",
      },
      final = {
        "__Warheads__/graphics/rockets/rocket-ring-2.png",
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
        "__Warheads__/graphics/rockets/rocket-engine.png",
      },
    },
    {
      base = {
        "__Warheads__/graphics/rockets/rocket-fins.png",
      },
      sections = {
        "__Warheads__/graphics/rockets/rocket-tip.png",
        "__Warheads__/graphics/rockets/rocket-ring-1.png",
        "__Warheads__/graphics/rockets/rocket-ring-2.png",
      },
      lights = {
        "__Warheads__/graphics/rockets/rocket-tip-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-1-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-2-light.png",
      },
      final = {
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
        "__Warheads__/graphics/rockets/rocket-engine.png",
      },
    },
    {
      base = {
        "__Warheads__/graphics/rockets/rocket-fins.png",
      },
      sections = {
        "__Warheads__/graphics/rockets/rocket-tip.png",
        "__Warheads__/graphics/rockets/rocket-ring-1.png",
        "__Warheads__/graphics/rockets/rocket-ring-2.png",
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
      },
      lights = {
        "__Warheads__/graphics/rockets/rocket-tip-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-1-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-2-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
      },
      final = {
        "__Warheads__/graphics/rockets/rocket-engine.png",
      },
    },
    {
      base = "__Warheads__/graphics/rockets/rocket-fins.png",
      sections = {
        "__Warheads__/graphics/rockets/rocket-tip.png",
        "__Warheads__/graphics/rockets/rocket-ring-1.png",
        "__Warheads__/graphics/rockets/rocket-ring-2.png",
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
        "__Warheads__/graphics/rockets/rocket-engine.png",
      },
      lights = {
        "__Warheads__/graphics/rockets/rocket-tip-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-1-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-2-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
        "__Warheads__/graphics/rockets/rocket-engine.png",
      }
    },
  },
  rocket_big = {
    {
      base = {
        "__Warheads__/graphics/rockets/rocket-fins.png",
        {icon = "__Warheads__/graphics/rockets/rocket-tip.png", size = 64, tint = tints.nothing},
        {icon = "__Warheads__/graphics/rockets/rocket-ring-1.png", size = 64, tint = tints.nothing},
        {icon = "__Warheads__/graphics/rockets/rocket-ring-2.png", size = 64, tint = tints.nothing},
        {icon = "__Warheads__/graphics/rockets/rocket-ring-3.png", size = 64, tint = tints.nothing},
        {icon = "__Warheads__/graphics/rockets/rocket-engine.png", size = 64, tint = tints.explosive}
      }
    },
    {
      base = {
        "__Warheads__/graphics/rockets/rocket-fins.png",
      },
      sections = {
        "__Warheads__/graphics/rockets/rocket-tip.png",
      },
      lights = {
        "__Warheads__/graphics/rockets/rocket-tip-light.png",
      },
      final = {
        {icon = "__Warheads__/graphics/rockets/rocket-ring-1.png", size = 64, tint = tints.nothing},
        {icon = "__Warheads__/graphics/rockets/rocket-ring-2.png", size = 64, tint = tints.nothing},
        {icon = "__Warheads__/graphics/rockets/rocket-ring-3.png", size = 64, tint = tints.nothing},
        {icon = "__Warheads__/graphics/rockets/rocket-engine.png", size = 64, tint = tints.explosive}
      },
    },
    {
      base = {
        "__Warheads__/graphics/rockets/rocket-fins.png",
      },
      sections = {
        "__Warheads__/graphics/rockets/rocket-tip.png",
        "__Warheads__/graphics/rockets/rocket-ring-1.png",
      },
      lights = {
        "__Warheads__/graphics/rockets/rocket-tip-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-1-light.png",
      },
      final = {
        {icon = "__Warheads__/graphics/rockets/rocket-ring-2.png", size = 64, tint = tints.nothing},
        {icon = "__Warheads__/graphics/rockets/rocket-ring-3.png", size = 64, tint = tints.nothing},
        {icon = "__Warheads__/graphics/rockets/rocket-engine.png", size = 64, tint = tints.explosive}
      },
    },
    {
      base = {
        "__Warheads__/graphics/rockets/rocket-fins.png",
      },
      sections = {
        "__Warheads__/graphics/rockets/rocket-tip.png",
        "__Warheads__/graphics/rockets/rocket-ring-1.png",
        "__Warheads__/graphics/rockets/rocket-ring-2.png",
      },
      lights = {
        "__Warheads__/graphics/rockets/rocket-tip-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-1-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-2-light.png",
      },
      final = {
        {icon = "__Warheads__/graphics/rockets/rocket-ring-3.png", size = 64, tint = tints.nothing},
        {icon = "__Warheads__/graphics/rockets/rocket-engine.png", size = 64, tint = tints.explosive}
      },
    },
    {
      base = {
        "__Warheads__/graphics/rockets/rocket-fins.png",
      },
      sections = {
        "__Warheads__/graphics/rockets/rocket-tip.png",
        "__Warheads__/graphics/rockets/rocket-ring-1.png",
        "__Warheads__/graphics/rockets/rocket-ring-2.png",
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
      },
      lights = {
        "__Warheads__/graphics/rockets/rocket-tip-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-1-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-2-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
      },
      final = {
        {icon = "__Warheads__/graphics/rockets/rocket-engine.png", size = 64, tint = tints.explosive}
      },
    },
    {
      base = "__Warheads__/graphics/rockets/rocket-fins.png",
      sections = {
        "__Warheads__/graphics/rockets/rocket-tip.png",
        "__Warheads__/graphics/rockets/rocket-ring-1.png",
        "__Warheads__/graphics/rockets/rocket-ring-2.png",
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
        "__Warheads__/graphics/rockets/rocket-engine.png",
      },
      lights = {
        "__Warheads__/graphics/rockets/rocket-tip-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-1-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-2-light.png",
        "__Warheads__/graphics/rockets/rocket-ring-3.png",
        "__Warheads__/graphics/rockets/rocket-engine.png",
      }
    },
  },
  rounds = {
    {
      base = "__Warheads__/graphics/rounds/rounds-blank.png",
      sections = {
        "__Warheads__/graphics/rounds/rounds-end.png",
      },
      lights = {
        "__Warheads__/graphics/rounds/rounds-end.png",
      }
    },
    {
      base = "__Warheads__/graphics/rounds/rounds-blank.png",
      sections = {
        "__Warheads__/graphics/rounds/rounds-end.png",
        "__Warheads__/graphics/rounds/rounds-middle.png",
      },
      lights = {
        "__Warheads__/graphics/rounds/rounds-end.png",
        "__Warheads__/graphics/rounds/rounds-middle.png",
      }
    }
  },
  shotgun = {
    {
      sections = {
        "__Warheads__/graphics/shotgun/shotgun-shell.png",
      },
      final = "__Warheads__/graphics/shotgun/shotgun-base.png",
    },
    {
      sections = {
        "__Warheads__/graphics/shotgun/piercing-shotgun-shell.png",
        "__Warheads__/graphics/shotgun/piercing-top.png",
      },
      final = {
        "__Warheads__/graphics/shotgun/shotgun-under.png",
        "__Warheads__/graphics/shotgun/shotgun-base.png",
      },
    },
    {
      sections = {
        "__Warheads__/graphics/shotgun/piercing-shotgun-shell.png",
        "__Warheads__/graphics/shotgun/frag-top.png",
      },
      final = "__Warheads__/graphics/shotgun/shotgun-base.png",
    }
  },
  nuclear_core = {
    {
      base = "__Warheads__/graphics/warheads/sphere-1-base.png",
      sections = {
        "__Warheads__/graphics/warheads/sphere-1-top.png",
        "__Warheads__/graphics/warheads/sphere-1-ring-part-1.png",
        "__Warheads__/graphics/warheads/sphere-1-ring-part-2.png",
      },
      lights = {
        "__Warheads__/graphics/warheads/sphere-1-top-light.png",
        "__Warheads__/graphics/warheads/sphere-1-ring-part-1-light.png",
        "__Warheads__/graphics/warheads/sphere-1-ring-part-2-light.png",
      }
    }
  },
  can_1 = {
    {
      base = "__Warheads__/graphics/warheads/can-1-body-1.png",
    },
    {
      base = "__Warheads__/graphics/warheads/can-1-body-2.png",
      sections = {
        "__Warheads__/graphics/warheads/can-1-body-2.png",
        "__Warheads__/graphics/warheads/can-1-top.png"
      },
    },
    {
      base = "__Warheads__/graphics/warheads/can-1-body-3.png",
      sections = {
        "__Warheads__/graphics/warheads/can-1-ring-1.png"
      },
    },
    {
      base = "__Warheads__/graphics/warheads/can-1-body-4.png",
      sections = {
        "__Warheads__/graphics/warheads/can-1-top.png",
        "__Warheads__/graphics/warheads/can-1-ring-1.png"
      },
    },
    {
      base = "__Warheads__/graphics/warheads/can-1-body-5.png",
      sections = {
        "__Warheads__/graphics/warheads/can-1-ring-1.png",
        "__Warheads__/graphics/warheads/can-1-ring-2.png"
      },
    },
    {
      base = "__Warheads__/graphics/warheads/can-1-body-6.png",
      sections = {
        "__Warheads__/graphics/warheads/can-1-top.png",
        "__Warheads__/graphics/warheads/can-1-ring-1.png",
        "__Warheads__/graphics/warheads/can-1-ring-2.png"
      },
    },
  },
  can_2 = {
    {
      base = "__Warheads__/graphics/warheads/can-2-body-1.png"
    },
    {
      base = "__Warheads__/graphics/warheads/can-2-body-1.png",
      sections = {
        "__Warheads__/graphics/warheads/can-2-ring-1.png"
      },
      final = "__Warheads__/graphics/warheads/can-2-body-final.png",
    },
  },
  can_3 = {
    {
      base = "__Warheads__/graphics/warheads/can-3-body.png",
      sections = {
        "__Warheads__/graphics/warheads/can-3-ring.png"
      },
      final = "__Warheads__/graphics/warheads/can-3-final.png",
    },
  }
}

local function isolatePointer(thing)
  if(type(thing) == "table") then
    local section = table.deepcopy(thing)
    return section
  else
    return thing
  end
end

local function createAppearance(setup)
  local result = {}
  result.icons = {}
  result.lights = {}
  local sprites = setup.sprite_types or sprite_types
  local sprite_type = sprites[setup.type]
  local style = sprite_type[setup.style or 1]

  local text_location = setup.text_location or "__Warheads__/graphics/warheads/"

  if(style.base) then
    if(type(style.base) == "table" and not style.base.icon) then
      for _,s in pairs(style.base) do
        table.insert(result.icons, isolatePointer(s))
      end
    else
      table.insert(result.icons, isolatePointer(style.base))
    end
  end
  if(style.sections) then
    local styleLights = style.lights or style.sections
    for i,s in ipairs(style.sections) do
      if(setup.tints[i].l or setup.tints[i].light) then
        table.insert(result.lights, isolatePointer(styleLights[i]))
      end
      if(type(s) == "table") then
        local section = table.deepcopy(s)
        section.tint = setup.tints[i]
        table.insert(result.icons, section)
      else
        table.insert(result.icons, {
          icon = s,
          icon_size = 64,
          tint = setup.tints[i]
        })
      end
    end
  end
  if(style.final) then
    if(type(style.final) == "table" and not style.final.icon) then
      for _,s in pairs(style.final) do
        table.insert(result.icons, isolatePointer(s))
      end
    else
      table.insert(result.icons, isolatePointer(style.final))
    end
  end
  if(setup.text) then
    table.insert(result.icons, {
      icon_size = 128,
      icon = text_location .. "text_" .. setup.text .. ".png",
      scale = 0.25,
      shift = {0, -16},
      special = true
    })
    -- not a light, but kind of treated like one
    table.insert(result.lights, {
      size = 128,
      filename = text_location .. "text_" .. setup.text .. ".png",
      scale = 0.125,
      shift = {0, -0.5},
      special = true
    })
  end
  return result
end

local function setupWarheadsForWeapon(setup)
  local sprites = setup.sprite_types or sprite_types
  local sprite_type = sprites[setup.type]
  local weapontype = setup.weapon
  local text_location = setup.text_location or "__Warheads__/graphics/warheads/"

  for w,v in pairs(setup.warheads) do
    if(weaponTypes[weapontype]) then
      local style = sprite_type[v.style or 1]
      local result = createAppearance({sprite_types = sprites, type = setup.type, style = v.style, tints = v.tints, text = v.text})
      weaponTypes[weapontype].icons[w] = result.icons
      weaponTypes[weapontype].lights[w] = result.lights
    end
  end
end
--{type = "artillery", weapon = "artillery-shell", warheads = {}}
--warheads[a] = {style = 1, tints = {}}











return {tints = tints, createAppearance = createAppearance, setupWarheadsForWeapon = setupWarheadsForWeapon}





