require("prototypes.override")
require("prototypes.icon-replace-functions")
if settings.startup["ASE-angels-coil-icons"].value==true then
  if mods["bobplates"] then
    ASE_fun.ReplaceRollIcons("brass")
    ASE_fun.ReplaceRollIcons("bronze")
    ASE_fun.ReplaceRollIcons("nitinol")
  end
  --some of these are now actually vanilla angels rolls
  --ASE_fun.ReplaceRollIcons("gold")
  --ASE_fun.ReplaceRollIcons("lead")
  --ASE_fun.ReplaceRollIcons("tin")
  --ASE_fun.ReplaceRollIcons("silver")
  --ASE_fun.ReplaceRollIcons("nickel")
  ASE_fun.ReplaceRollIcons("tungsten")
end
