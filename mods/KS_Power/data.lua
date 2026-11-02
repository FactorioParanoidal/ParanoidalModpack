require("prototypes.oil-boiler")
require("prototypes.turbine")
require("prototypes.burner-generator")
require("prototypes.diesel-generator")
do
  local entity = data.raw.generator["petroleum-generator"]
  if entity then
    -- Factorio 2.1: GeneratorPrototype::horizontal_animation/vertical_animation were moved to pictures (the old
    -- fields are silently ignored): east/west take the horizontal animation, north/south the vertical one.
    for direction, field in pairs({ north = "vertical_animation", east = "horizontal_animation", south = "vertical_animation", west = "horizontal_animation" }) do
      if entity[field] and not (entity.two_direction_only and (direction == "south" or direction == "west")) then
        entity.pictures = entity.pictures or {}
        entity.pictures[direction] = entity.pictures[direction] or {}
        entity.pictures[direction].animation = entity[field]
      end
    end
    entity.horizontal_animation, entity.vertical_animation = nil, nil
  end
end
require("prototypes.big-burner-generator")
