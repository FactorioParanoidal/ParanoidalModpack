if mods.angelsrefining and mods.extendedangels then

local washing_fluid_box = {
production_type = 'output',
pipe_covers = pipecoverspictures(),
base_level = 1,
pipe_connections = {{ type = "output", position = {-3, 0} }}
}
--добавляем в промывочные машины 3-4 дополнительный порт для сероводорода, который не добавляет Oberhaul
table.insert(data.raw['assembling-machine']['washing-plant-3'].fluid_boxes, washing_fluid_box)
table.insert(data.raw['assembling-machine']['washing-plant-4'].fluid_boxes, washing_fluid_box)
end
