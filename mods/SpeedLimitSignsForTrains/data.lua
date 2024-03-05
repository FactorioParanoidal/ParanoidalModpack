require("prototypes.items")
require("prototypes.recipes")

table.insert(data.raw["technology"]["rail-signals"].effects, {type="unlock-recipe", recipe="electronic-train-limit"})
table.insert(data.raw["technology"]["rail-signals"].effects, {type="unlock-recipe", recipe="electronic-train-unlimit"})
