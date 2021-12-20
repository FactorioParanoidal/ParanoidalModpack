
function addHonkSoundGroup(group, locos)
  -- Add this group to list of available sounds
  data.raw["string-setting"]["honk-groups"].default_value = data.raw["string-setting"]["honk-groups"].default_value..","..group

  -- Add this group to list of allowed default sounds
  table.insert(data.raw["string-setting"]["honk-default-sound"].allowed_values, group)
  if not data.raw["string-setting"]["honk-default-sound"].default_value then
    data.raw["string-setting"]["honk-default-sound"].default_value = group
  end

  data:extend{
    {
      type = "double-setting",
      name = "honk-sound-range-"..group,
      localised_name = {"mod-setting-name.honk-sound-range",{"string-mod-setting.honk-default-sound-"..group}},
      localised_description = {"mod-setting-description.honk-sound-range"},
      setting_type = "startup",
      default_value = 10,
      minimum_value = 1,
      maximum_value = 100,
      order = "h-"..group.."-ab"
    },
    {
      type = "double-setting",
      name = "honk-sound-volume-"..group,
      localised_name = {"mod-setting-name.honk-sound-volume",{"string-mod-setting.honk-default-sound-"..group}},
      localised_description = {"mod-setting-description.honk-sound-volume"},
      setting_type = "startup",
      default_value = 1.5,
      minimum_value = 0,
      maximum_value = 10,
      order = "h-"..group.."-ac"
    },
    {
      type = "string-setting",
      name = "honk-sound-start-"..group,
      localised_name = {"mod-setting-name.honk-sound-start",{"string-mod-setting.honk-default-sound-"..group}},
      setting_type = "runtime-global",
      default_value = "honk-double-"..group,
      allowed_values = {"honk-double-"..group, "honk-single-"..group, "none"},
      order = "h-"..group.."-ba"
    },
    {
      type = "string-setting",
      name = "honk-sound-station-"..group,
      localised_name = {"mod-setting-name.honk-sound-station",{"string-mod-setting.honk-default-sound-"..group}},
      setting_type = "runtime-global",
      default_value = "honk-single-"..group,
      allowed_values = {"honk-double-"..group, "honk-single-"..group, "none"},
      order = "h-"..group.."-bb"
    },
    {
      type = "string-setting",
      name = "honk-sound-signal-"..group,
      localised_name = {"mod-setting-name.honk-sound-signal",{"string-mod-setting.honk-default-sound-"..group}},
      setting_type = "runtime-global",
      default_value = "none",
      allowed_values = {"honk-double-"..group, "honk-single-"..group, "none"},
      order = "h-"..group.."-bc"
    },
    {
      type = "string-setting",
      name = "honk-sound-lost-"..group,
      localised_name = {"mod-setting-name.honk-sound-lost",{"string-mod-setting.honk-default-sound-"..group}},
      localised_description = {"mod-setting-description.honk-sound-lost"},
      setting_type = "runtime-global",
      default_value = "none",
      allowed_values = {"honk-double-"..group, "honk-single-"..group, "none"},
      order = "h-"..group.."-bd"
    },
    {
      type = "string-setting",
      name = "honk-sound-manual-"..group,
      localised_name = {"mod-setting-name.honk-sound-manual",{"string-mod-setting.honk-default-sound-"..group}},
      localised_description = {"mod-setting-description.honk-sound-manual"},
      setting_type = "runtime-global",
      default_value = "auto",
      allowed_values = {"auto","honk-double-"..group, "honk-single-"..group, "none"},
      order = "h-"..group.."-be"
    },
    {
      type = "string-setting",
      name = "honk-sound-manual-alt-"..group,
      localised_name = {"mod-setting-name.honk-sound-manual-alt",{"string-mod-setting.honk-default-sound-"..group}},
      setting_type = "runtime-global",
      default_value = "honk-single-"..group,
      allowed_values = {"honk-double-"..group, "honk-single-"..group, "none"},
      order = "h-"..group.."-bf"
    },
  }

  local loco_list = ""
  if locos then
    if #locos > 0 then
      loco_list = locos[1]
      if #locos > 1 then
        for i=2,#locos do
          loco_list = loco_list..","..locos[i]
        end
      end
    end
  end
  data:extend{
    {
      type = "string-setting",
      name = "honk-sound-locos-"..group,
      localised_name = {"mod-setting-name.honk-sound-locos",{"string-mod-setting.honk-default-sound-"..group}},
      localised_description = {"mod-setting-description.honk-sound-locos"},
      setting_type = "runtime-global",
      default_value = loco_list,
      allow_blank = true,
      auto_trim = true,
      order = "g-"..group.."-ca"
    }
  }
end
