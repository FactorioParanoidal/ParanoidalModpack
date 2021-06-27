require("prototypes.override")
require("prototypes.icon-replace-functions")
if settings.startup["ASE-angels-coil-icons"].value==true then
  if mods["bobplates"] then
    ReplaceRollIcons("brass")
    ReplaceRollIcons("bronze")
    ReplaceRollIcons("nitinol")
  end
  --some of these are now actually vanilla angels rolls
  --ReplaceRollIcons("gold")
  --ReplaceRollIcons("lead")
  --ReplaceRollIcons("tin")
  --ReplaceRollIcons("silver")
  --ReplaceRollIcons("nickel")
  ReplaceRollIcons("tungsten")
end
