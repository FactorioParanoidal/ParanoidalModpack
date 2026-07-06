-- data-final-fixes

require("prototypes.style.gui")

require("prototypes.signal.final-fixes")

if DECT.DEBUG then
	local function log_tiles()
		log("[Dectorio] Tile layers:")
		local log_data = {}
		for _, tile in pairs(data.raw.tile) do
			log_data["layer " .. tile.layer] =
				log_data["layer " .. tile.layer] and log_data["layer " .. tile.layer] .. ", " .. tile.name or tile.name
		end
		log(serpent.block(log_data, {comment = false, numformat = "%1.8g"}))
	end
	log_tiles()
end
