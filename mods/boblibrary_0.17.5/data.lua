if not bobmods then bobmods = {} end
if not bobmods.lib then bobmods.lib = {} end


require("functions")
require("item-functions")
require("technology-functions")
require("module-functions")
require("recipe-functions")
require("ore-functions")
require("category-functions")

require("auto-bottle")

require("resource-generator") -- new autoplace functions.
require("base-resources") -- replace the base game resources autoplace to use my new functions.

require("ore-icon-variations")
