--[[ Copyright (c) 2018 Optera
 * Part of Re-Stack
 *
 * See LICENSE.md in the project directory for license information.
--]]

--Walls and Gates
SelectItemByEntity("wall", settings.startup["ReStack-wall"].value, "wall")
SelectItemByEntity("gate", settings.startup["ReStack-wall"].value, "wall")

--Turrets and Artillery
SelectItemByEntity("turret", settings.startup["ReStack-turret"].value, "turret") -- worms in base, but mods might add this type
SelectItemByEntity("ammo-turret", settings.startup["ReStack-turret"].value, "turret")
SelectItemByEntity("electric-turret", settings.startup["ReStack-turret"].value, "turret")
SelectItemByEntity("artillery-turret", settings.startup["ReStack-turret"].value, "turret")