require "strings"
require "sprites"

function copyObject(category, name, newname)
	log("Cloning object '" .. category .. "/" .. name .. "' into '" .. newname .. "'...")
	local base = data.raw[category][name]
	if not base then error("Object data.raw[" .. category .. "][" .. name .. "] does not exist!") end
    local obj = table.deepcopy(base)
    if obj.minable then
		obj.minable.result = newname
    end
	if obj.mineable then
		obj.mineable.result = newname
	end
	if obj.place_result then
		obj.place_result = newname
	end
	if obj.result then
		obj.result = newname
	end
	if obj.order then
		obj.order = literalReplace(obj.order, "[" .. obj.name .. "]", "[" .. newname .. "]")
	end
    obj.name = newname
	return obj
end

function createSignalOutput(modname, name, signalname)
	local obj = copyObject("constant-combinator", "constant-combinator", name)
	replaceSpritesDynamic(modname, "constant-combinator", obj)
	local item = copyObject("item", "constant-combinator", name)
	replaceSpritesDynamic(modname, "constant-combinator", item)
	local signal = copyObject("virtual-signal", "signal-everything", signalname)
	signal.icon = "__" .. modname .. "__/graphics/icons/" .. signalname .. ".png"
	return {entity = obj, item = item, signal = signal}
end

local function createCircuitConnections()
	local ret = {
        shadow = {
          red = {0.375, 0.5625},
          green = {-0.125, 0.5625}
        },
        wire = {
          red = {0.375, 0.15625},
          green = {-0.125, 0.15625}
        }
    }
	return ret
end

function createFixedSignalAnchor(name, spr)
	local obj = copyObject("constant-combinator", "constant-combinator", name)
	
	obj.sprites = {
      north = createCircuitSprite(),
      west = createCircuitSprite(),
      east = createCircuitSprite(),
      south = createCircuitSprite(),
    }

    obj.activity_led_sprites = {
	  north = createCircuitActivitySprite(),
      west = createCircuitActivitySprite(),
      east = createCircuitActivitySprite(),
      south = createCircuitActivitySprite(),
    }
	
	obj.circuit_wire_connection_points = {
      createCircuitConnections(),
      createCircuitConnections(),
      createCircuitConnections(),
      createCircuitConnections(),
    }
	
	--obj.selectable_in_game = false
	obj.destructible = false
	obj.collision_box = nil
	obj.max_health = 100
	obj.collision_mask = nil
	obj.minable = nil
	obj.order = "z"
	obj.flags = {"placeable-neutral", "player-creation", "not-on-map", "placeable-off-grid", "not-blueprintable", "not-deconstructable"}
	obj.selection_priority = 254
	
	return obj
end
