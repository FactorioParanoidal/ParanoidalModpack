local setting_list = {}
        -- Add/enable stuff
setting_list.BI_Solar_Additions = {
    type = "bool-setting",
    name = "BI_Solar_Additions",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-a[Solar_Farm]",
}

setting_list.BI_Bio_Fuel = {
    type = "bool-setting",
    name = "BI_Bio_Fuel",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-b[Bio_Fuel]",
}

setting_list.BI_Bigger_Wooden_Chests = {
    type = "bool-setting",
    name = "BI_Bigger_Wooden_Chests",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-b[Bigger_Wooden_Chests]",
}

        -- Game tweaks
setting_list.BI_Game_Tweaks_Emissions_Multiplier = {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Emissions_Multiplier",
    setting_type = "startup",
    default_value = true,
    order = "b[tweaks]-a[Fuel_emission_multiplier]",
    per_user = true,
}
setting_list.BI_Game_Tweaks_Stack_Size = {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Stack_Size",
    setting_type = "startup",
    default_value = true,
    order = "b[tweaks]-b[Stack_size]",
}
setting_list.BI_Game_Tweaks_Recipe = {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Recipe",
    setting_type = "startup",
    default_value = true,
    order = "b[tweaks]-c1[Recipe]",
}
setting_list.BI_Game_Tweaks_Production_Science = {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Production_Science",
    setting_type = "startup",
    default_value = true,
    order = "b[tweaks]-c3[Production_science]",
}
setting_list.BI_Game_Tweaks_Tree = {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Tree",
    setting_type = "startup",
    default_value = true,
    order = "b[tweaks]-d1[Trees]",
}
setting_list.BI_Game_Tweaks_Small_Tree_Collisionbox = {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Small_Tree_Collisionbox",
    setting_type = "startup",
    default_value = true,
    order = "b[tweaks]-d2[Tree_collision_box]",
}
setting_list.BI_Game_Tweaks_Player = {
    type = "bool-setting",
    name = "BI_Game_Tweaks_Player",
    setting_type = "startup",
    default_value = false,
    order = "b[tweaks]-e[Player_tweaks]",
}

-- Lua API global Variable Viewer (gvv)
if mods["gvv"] then
  setting_list.BI_Enable_gvv_support = {
      type = "bool-setting",
      name = "BI_Enable_gvv_support",
      setting_type = "startup",
      default_value = false,
      order = "c[compatibility]-c1[debugging_gvv]",
  }
end

--local list = {}
for name, setting in pairs(setting_list) do
  --~ list[#list + 1] = setting
  data:extend({setting})
end