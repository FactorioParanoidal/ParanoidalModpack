data:extend({
  --Разброс вещей из сундуков
  {type = "bool-setting", name = "item-drop", setting_type = "startup", default_value = true, order = "b"},
  --Ресурсы на дефолте х5 богатство
  {type = "bool-setting", name = "newbie_resourse", setting_type = "startup", default_value = true, order = "c"},
 -------------------------------------------------------------------------------------------------
 --рескин покрытия кирпичем
 {type = "bool-setting", name = "stone-path-concrete", setting_type = "startup", default_value = true, order = "2"},
 -------------------------------------------------------------------------------------------------
 --фитолампы в биофермах
 {type = "bool-setting", name = "fitolamps", setting_type = "startup", default_value = true, order = "1"},
 -------------------------------------------------------------------------------------------------
 --рескин поездов
 {type = "bool-setting", name = "res_loc_1", setting_type = "startup", default_value = true, order = "3"},
 {type = "bool-setting", name = "res_loc_2", setting_type = "startup", default_value = true, order = "4"},
 {type = "bool-setting", name = "res_loc_3", setting_type = "startup", default_value = true, order = "5"},
 {type = "bool-setting", name = "res_loc_e", setting_type = "startup", default_value = true, order = "6"},
 -------------------------------------------------------------------------------------------------
 --рескин проводов
 {type = "bool-setting", name = "wire", setting_type = "startup", default_value = true, order = "7"},
 {type = "bool-setting", name = "copper_wire", setting_type = "startup", default_value = true, order = "8"},
 -------------------------------------------------------------------------------------------------
 --стрелки атаки
   {
     type = "double-setting",
     name = "baa-arrow-scale",
     setting_type = "startup",
     minimum_value = 0,
     maximum_value = 1,
     default_value = 0.2
   },
   {
     type = "string-setting",
     name = "baa-arrow-tint",
     setting_type = "startup",
     default_value = "FF9F1C"
   },
   {
     type = "double-setting",
     name = "paranoidal-miniloader-energy-multiplier",
     setting_type = "startup",
     default_value = 4,
     minimum_value = 0.01,
     maximum_value = 100,
     order = "d"
   },
   {
     type = "double-setting",
     name = "paranoidal-flowfix-min-time",
     setting_type = "startup",
     default_value = 0.5,
     minimum_value = 0.5,
     maximum_value = 100,
     order = "e"
   },
   --Рассказываем как показать тонкие настройки
 {type = "bool-setting", name = "zzz-settings", setting_type = "startup", default_value = true, order = "f"}
 })
 
 if mods.research_evolution_factor then
   data:extend
   {
     {
       type = "bool-setting",
       name = "paranoidal-disable-vanilla-evolution",
       setting_type = "runtime-global",
       default_value = true,
       order = "a"
     }
   }
 end