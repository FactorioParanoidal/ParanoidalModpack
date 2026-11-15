-- Bob's Warfare 2.x names (bob- prefix); Warheads 1.0.2 still used the 1.1 names and crashed the data stage.
weaponTypes["small-rocket"].base_item = "bob-rocket-body"
weaponTypes["small-rocket"].item = table.deepcopy(data.raw.ammo["bob-rocket"])
weaponTypes["small-rocket"].projectile = table.deepcopy(data.raw.projectile["bob-rocket"])

weaponTypes["big-rocket"].base_item = "bob-rocket-body"
weaponTypes["big-rocket"].item = table.deepcopy(data.raw.ammo["bob-rocket"])
weaponTypes["big-rocket"].projectile = table.deepcopy(data.raw.projectile["bob-rocket"])

weaponTypes["rocket"].base_item = "bob-rocket-body"
weaponTypes["rocket"].item = table.deepcopy(data.raw.ammo["bob-rocket"])
weaponTypes["rocket"].projectile = table.deepcopy(data.raw.projectile["bob-rocket"])
