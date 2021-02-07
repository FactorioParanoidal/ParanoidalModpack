--~ local BioInd = require('common')('Bio_Industries')

if BI.Settings.Bio_Cannon then
  data:extend({
    {
      type = "ammo-category",
      name = "Bio_Cannon_Ammo",
      order = "1"
    },
  })
end
