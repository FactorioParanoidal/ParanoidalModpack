------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--               Common functions and definitions for the data stage              --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


local common = require("common")('Natural_Evolution_Enemies')

------------------------------------------------------------------------------------
-- Set pathnames
-- For NE Graphics
common.graphicsmod = "__Natural_Evolution_Graphics__"
common.graphics = common.graphicsmod .. "/graphics"
common.iconpath = common.graphics .. "/icons/"
common.entitypath = common.graphics .. "/entities/"
common.alt_graphicspath = common.graphics .. "/entities/alt_graphics/"
common.achievementspath = common.graphics .. "/achievements/"

-- For Zerg Graphics
common.zgraphicsmod = "__erm_zerg_hd_assets__"
common.zgraphics = common.zgraphicsmod .. "/graphics"
common.zentitypath_unit = common.zgraphics .. "/entity/units/"
common.zsoundpath = common.zgraphicsmod .. "/sound/enemies/"


------------------------------------------------------------------------------------
--                                    END OF FILE                                 --
------------------------------------------------------------------------------------

return common
