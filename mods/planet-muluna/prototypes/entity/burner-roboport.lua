local roboport = table.deepcopy(data.raw["roboport"]["roboport"])

roboport.name = "muluna-burner-roboport"
roboport.energy_usage = helpers.compare_versions(helpers.game_version,"2.1.12") < 0 and "0.001W" or "0W"
roboport.placeable_by = {item = "muluna-burner-roboport",count=1}
roboport.is_vacuum_roboport = true
roboport.recharging_animation.filename = "__muluna-graphics__/graphics/entity/burner-roboport/burner-roboport-recharging.png"
roboport.base.layers[1].filename = "__muluna-graphics__/graphics/entity/burner-roboport/burner-roboport-base.png"
roboport.base_patch.filename = "__muluna-graphics__/graphics/entity/burner-roboport/burner-roboport-base-patch.png"
roboport.logistics_radius = 50
roboport.construction_radius = 110
Muluna:extend{roboport}
