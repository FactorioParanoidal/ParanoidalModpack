-- Stage 5: the rift at the first rocket. The fragment of the bridge of the Axiom-7 that falls out of it (a wreck of the
-- freeplay crash site, recoloured, with a space platform starter pack inside), its falling sprite and the sounds.
local shared = require("shared")
local warp_util = require("prototypes.util")

local TINT = {r = 0.8, g = 0.72, b = 1}
local base = data.raw.container["crash-site-spaceship-wreck-big-1"]

local prototypes = {
	{
		type = "sound",
		name = shared.rift_sound_open,
		filename = "__base__/sound/fight/nuclear-explosion-aftershock.ogg",
		volume = 0.8,
	},
	{
		type = "sound",
		name = shared.rift_sound_thunder,
		variations = {
			{filename = "__space-age__/sound/world/lightning/lightning-effect-6.ogg", volume = 0.6},
			{filename = "__space-age__/sound/world/lightning/lightning-effect-7.ogg", volume = 0.6},
		},
	},
	{
		type = "sound",
		name = shared.rift_sound_impact,
		variations = {
			{filename = "__base__/sound/fight/large-explosion-1.ogg", volume = 0.9},
			{filename = "__base__/sound/fight/large-explosion-2.ogg", volume = 0.9},
		},
	},
}

if base then
	local fragment = table.deepcopy(base)
	fragment.name = shared.fragment
	fragment.localised_name = nil
	fragment.hidden = nil
	fragment.icon = nil
	fragment.icons = warp_util.icons(base, TINT)
	fragment.inventory_size = 4
	fragment.minable = {mining_time = 6, results = {{type = "item", name = "steel-plate", amount_min = 20, amount_max = 40}}}
	fragment.placeable_by = nil
	warp_util.tint_layers(fragment.picture, TINT)
	prototypes[#prototypes + 1] = fragment

	-- The falling fragment: the wreck's picture without its shadow.
	local layer
	for _, candidate in pairs(base.picture and base.picture.layers or {base.picture}) do
		if candidate and candidate.filename and not candidate.draw_as_shadow and not layer then layer = candidate end
	end
	if layer then
		prototypes[#prototypes + 1] = {
			type = "sprite",
			name = shared.fragment,
			filename = layer.filename,
			width = layer.width,
			height = layer.height,
			scale = layer.scale or 1,
			shift = layer.shift,
			tint = TINT,
		}
	end
end

data:extend(prototypes)
