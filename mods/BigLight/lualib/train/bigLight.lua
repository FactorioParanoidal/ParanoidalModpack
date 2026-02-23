function train_stop(name)

    local LuaEntityPrototype = data.raw["train-stop"][name]

    local color = settings.startup["ritnmods-bl-02"].value
    local value = settings.startup["ritnmods-bl-03"].value / 2

    if color == true then
    LuaEntityPrototype.light1 = require("lualib/train/green/light1")
    LuaEntityPrototype.light2 = require("lualib/train/green/light2")
    else
    LuaEntityPrototype.light1 = require("lualib/train/yelow/light1")
    LuaEntityPrototype.light2 = require("lualib/train/yelow/light2")
    end



    LuaEntityPrototype.light1.picture.north.layers[2].scale = value
    --LuaEntityPrototype.light1.picture.north.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light1.picture.west.layers[2].scale = value
    --LuaEntityPrototype.light1.picture.west.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light1.picture.south.layers[2].scale = value
    --LuaEntityPrototype.light1.picture.south.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light1.picture.east.layers[2].scale = value
    --LuaEntityPrototype.light1.picture.east.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light1.red_picture.north.layers[2].scale = value
    --LuaEntityPrototype.light1.red_picture.north.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light1.red_picture.west.layers[2].scale = value
    --LuaEntityPrototype.light1.red_picture.west.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light1.red_picture.south.layers[2].scale = value
    --LuaEntityPrototype.light1.red_picture.south.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light1.red_picture.east.layers[2].scale = value
    --LuaEntityPrototype.light1.red_picture.east.layers[2].hr_version.scale = value / 2

    LuaEntityPrototype.light2.picture.north.layers[2].scale = value
    --LuaEntityPrototype.light2.picture.north.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light2.picture.west.layers[2].scale = value
    --LuaEntityPrototype.light2.picture.west.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light2.picture.south.layers[2].scale = value
    --LuaEntityPrototype.light2.picture.south.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light2.picture.east.layers[2].scale = value
    --LuaEntityPrototype.light2.picture.east.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light2.red_picture.north.layers[2].scale = value
    --LuaEntityPrototype.light2.red_picture.north.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light2.red_picture.west.layers[2].scale = value
    --LuaEntityPrototype.light2.red_picture.west.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light2.red_picture.south.layers[2].scale = value
    --LuaEntityPrototype.light2.red_picture.south.layers[2].hr_version.scale = value / 2
    LuaEntityPrototype.light2.red_picture.east.layers[2].scale = value
    --LuaEntityPrototype.light2.red_picture.east.layers[2].hr_version.scale = value / 2

    return LuaEntityPrototype
end