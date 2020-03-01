--[[ Copyright (c) 2018 Optera
 * Part of Train Overhaul
 *
 * See LICENSE.md in the project directory for license information.
--]]

local base_loco = data.raw["item-with-entity-data"]["locomotive"]
base_loco.icon = "__TrainOverhaul__/graphics/icons/diesel-locomotive.png"
base_loco.order = "a[train-system]-f[locomotive]"

local heavy_loco = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["locomotive"], "heavy-locomotive")
heavy_loco.icon = "__TrainOverhaul__/graphics/icons/heavy-locomotive.png"
heavy_loco.order = "a[train-system]-fc[locomotive]"

local express_loco = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["locomotive"], "express-locomotive")
express_loco.icon = "__TrainOverhaul__/graphics/icons/express-locomotive.png"
express_loco.order = "a[train-system]-fd[locomotive]"

local nuclear_loco = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["locomotive"], "nuclear-locomotive")
nuclear_loco.icon = "__TrainOverhaul__/graphics/icons/nuclear-locomotive.png"
nuclear_loco.order = "a[train-system]-fe[locomotive]"

data:extend({
  heavy_loco,
  express_loco,
	nuclear_loco,
})

local base_cargo_wagon = data.raw["item-with-entity-data"]["cargo-wagon"]
base_cargo_wagon.icon = "__TrainOverhaul__/graphics/icons/cargo-wagon.png"
base_cargo_wagon.order = "a[train-system]-g[cargo-wagon]"

local base_fluid_wagon = data.raw["item-with-entity-data"]["fluid-wagon"]
base_fluid_wagon.icon = "__TrainOverhaul__/graphics/icons/fluid-wagon.png"
base_fluid_wagon.order = "a[train-system]-h[fluid-wagon]"

local heavy_cargo_wagon = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["cargo-wagon"], "heavy-cargo-wagon")
heavy_cargo_wagon.icon = "__TrainOverhaul__/graphics/icons/heavy-cargo-wagon.png"
heavy_cargo_wagon.order = "a[train-system]-gc[cargo-wagon]"

local heavy_fluid_wagon = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["fluid-wagon"], "heavy-fluid-wagon")
heavy_fluid_wagon.icon = "__TrainOverhaul__/graphics/icons/heavy-fluid-wagon.png"
heavy_fluid_wagon.order = "a[train-system]-hc[fluid-wagon]"

local express_cargo_wagon = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["cargo-wagon"], "express-cargo-wagon")
express_cargo_wagon.icon = "__TrainOverhaul__/graphics/icons/express-cargo-wagon.png"
express_cargo_wagon.order = "a[train-system]-gd[cargo-wagon]"

local express_fluid_wagon = optera_lib.copy_prototype(data.raw["item-with-entity-data"]["fluid-wagon"], "express-fluid-wagon")
express_fluid_wagon.icon = "__TrainOverhaul__/graphics/icons/express-fluid-wagon.png"
express_fluid_wagon.order = "a[train-system]-hd[fluid-wagon]"

data:extend({
  heavy_cargo_wagon,
  heavy_fluid_wagon,
  express_cargo_wagon,
  express_fluid_wagon,
})
