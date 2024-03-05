require("prototypes.override")
require("prototypes.icon-replace-functions")

if settings.startup["ASE-angels-coil-icons"].value == true then
  ASE.functions.ReplaceRollIcons("tungsten")
  if mods["bobplates"] then
    ASE.functions.ReplaceRollIcons("brass")
    ASE.functions.ReplaceRollIcons("bronze")
    ASE.functions.ReplaceRollIcons("nitinol")
  end
end
