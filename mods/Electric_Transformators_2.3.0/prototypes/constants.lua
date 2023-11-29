

TRAFOS_GRAPHICS_BASE = "__Electric_Transformators__/graphics"
TRAFOS_SOUND_BASE = "__Electric_Transformators__/sound"
TRAFOS_TIER_BLEND_MODE = "additive"


TRAFOS_TINT = {
	{r=0.925, g=0.253, b=0.253},
	{r=0.325, g=0.938, b=0.366},
	{r=0.318, g=0.906, b=0.949},
	{r=0.827, g=0.234, b=0.932},
	{r=0.961, g=0.907, b=0.360},
}	


-- https://wiki.factorio.com/Types/EntityPrototypeFlags
TRAFOS_INTERNAL_ENTITY_FLAGS = {
	"not-rotatable",
--	"placeable-player",
	"placeable-neutral",
--	"placeable-enemy",
--	"placeable-off-grid",
--	"player-creation",
--	"building-direction-8-way",
--	"filter-directions",
--	"fast-replaceable-no-build-while-moving",
--	"breaths-air",
	"not-repairable",
	"not-on-map",
	"not-blueprintable",
	"not-deconstructable",
	"hidden",
--	"hide-alt-info",-- added where required
--	"fast-replaceable-no-cross-type-while-moving",
--	"no-gap-fill-while-building",
	"not-flammable",
--	"no-automated-item-removal",
--	"no-automated-item-insertion",
	"no-copy-paste",
	"not-selectable-in-game",
	"not-upgradable",
	"not-in-kill-statistics",
}


TRAFOS_POLE_FLAGS = {
	"not-rotatable",
--	"placeable-player",
	"placeable-neutral",
--	"placeable-enemy",
--	"placeable-off-grid",
--	"player-creation",
--	"building-direction-8-way",
--	"filter-directions",
--	"fast-replaceable-no-build-while-moving",
--	"breaths-air",
	"not-repairable",
	"not-on-map",
	"not-blueprintable",
	"not-deconstructable",
	"hidden",
	"hide-alt-info",
--	"fast-replaceable-no-cross-type-while-moving",
--	"no-gap-fill-while-building",
	"not-flammable",
--	"no-automated-item-removal",
--	"no-automated-item-insertion",
	"no-copy-paste",
--	"not-selectable-in-game",
	"not-upgradable",
	"not-in-kill-statistics",
}


TRAFOS_INVISIBLE = {
	filename = "__core__/graphics/empty.png",
	width = 1, height = 1,
	direction_count = 1,
}


TRAFOS_PIPE_PICTURES = {
	straight_vertical_single = TRAFOS_INVISIBLE,
	straight_vertical = TRAFOS_INVISIBLE,
	straight_vertical_window = TRAFOS_INVISIBLE,
	straight_horizontal = TRAFOS_INVISIBLE,
	straight_horizontal_window = TRAFOS_INVISIBLE,
	corner_up_right = TRAFOS_INVISIBLE,
	corner_up_left = TRAFOS_INVISIBLE,
	corner_down_right = TRAFOS_INVISIBLE,
	corner_down_left = TRAFOS_INVISIBLE,
	t_up = TRAFOS_INVISIBLE,
	t_down = TRAFOS_INVISIBLE,
	t_right = TRAFOS_INVISIBLE,
	t_left = TRAFOS_INVISIBLE,
	cross = TRAFOS_INVISIBLE,
	ending_up = TRAFOS_INVISIBLE,
	ending_down = TRAFOS_INVISIBLE,
	ending_right = TRAFOS_INVISIBLE,
	ending_left = TRAFOS_INVISIBLE,
	horizontal_window_background = TRAFOS_INVISIBLE,
	vertical_window_background = TRAFOS_INVISIBLE,
	fluid_background = TRAFOS_INVISIBLE,
	low_temperature_flow = TRAFOS_INVISIBLE,
	middle_temperature_flow = TRAFOS_INVISIBLE,
	high_temperature_flow = TRAFOS_INVISIBLE,
	gas_flow = TRAFOS_INVISIBLE,
}

