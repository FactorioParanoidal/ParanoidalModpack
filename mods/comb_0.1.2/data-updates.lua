local util = require "util"


data.raw["technology"]["circuit-network"].icon = "__comb__/graphics/icons/thumbnail_issled_128.png"

------------------------------------------------------------------------
--====================== АРИФМЕТИЧЕСКИЙ КОМБИНАТОР ============================================================================================================================--
------------------------------------------------------------------------

data.raw["item"]["arithmetic-combinator"].icon	= "__comb__/graphics/icons/arithmetic_combinator_icon_64.png"
data.raw["arithmetic-combinator"]["arithmetic-combinator"].icon	= "__comb__/graphics/icons/arithmetic_combinator_icon_64.png"
data.raw["arithmetic-combinator"]["arithmetic-combinator"].sprites =
make_4way_animation_from_spritesheet({ layers =
	{
		{
			filename = "__comb__/graphics/entity/arithmetic_combinator.png",
			width = 150,
			height = 129,
			frame_count = 1,
			shift = {0,0},
			scale = 0.50
		},
		{
			filename = "__comb__/graphics/entity/arithmetic_combinator_shadow.png",
			width = 150,
			height = 129,
			frame_count = 1,
			shift = util.by_pixel(21, 0),
			scale = 0.50,
			draw_as_shadow = true
		}
	}
})

data.raw["arithmetic-combinator"]["arithmetic-combinator"].input_connection_points =
	{
		{
			shadow =
			{
				red = util.by_pixel(35/2, 39/2),
				green = util.by_pixel(69/2, 39/2)
			},
			wire =
			{
				red = util.by_pixel(-16/2, 6/2), 
				green = util.by_pixel(16/2, 6/2) 
			}
		},
		{
			shadow =
			{
				red = util.by_pixel(-26/2, -18/2),
				green = util.by_pixel(-20/2, 9.5/2)
			},
			wire =
			{
				red = util.by_pixel(-45/2, -35/2),
				green = util.by_pixel(-45/2, -12/2)
			}
		},
		{
			shadow =
			{
				red = util.by_pixel(68/2, -20/2),
				green = util.by_pixel(34/2, -21/2)
			},
			wire =
			{
				red = util.by_pixel(15/2, -54/2),
				green = util.by_pixel(-16/2, -54/2)
			}
		},
		{
			shadow =
			{
				red = util.by_pixel(91/2, 21/2),
				green = util.by_pixel(91/2, -2/2)
			},
			wire =
			{
				red = util.by_pixel(45/2, -12/2),  
				green = util.by_pixel(45/2, -35/2)
			}
		}
	}

data.raw["arithmetic-combinator"]["arithmetic-combinator"].output_connection_points =
	{
		{
		shadow =
			{
				red = util.by_pixel(34/2, -21/2),
				green = util.by_pixel(68/2, -20/2)
			},
			wire =
			{
				red = util.by_pixel(-15/2, -54/2),
				green = util.by_pixel(16/2, -54/2)
			}
		},
		{
		shadow =
			{
				red = util.by_pixel(91/2, -2/2),
				green = util.by_pixel(91/2, 21/2)
			},
			wire =
			{
				red = util.by_pixel(45/2, -35/2),  
				green = util.by_pixel(45/2, -12/2)
			}
		},
		{
		shadow =
			{
				red = util.by_pixel(69/2, 39/2),
				green = util.by_pixel(35/2, 39/2)
			},
			wire =
			{
				red = util.by_pixel(16/2, 6/2), 
				green = util.by_pixel(-16/2, 6/2) 
			}
		},
		{
		shadow =
			{
				red = util.by_pixel(-26/2, 9.5/2),
				green = util.by_pixel(-20/2, -18/2)
			},
			wire =
			{
				red = util.by_pixel(-45/2, -12/2),
				green = util.by_pixel(-45/2, -35/2)
			}
		}
	}
	
	-- СИМВОЛЫ И ИХ ОТОБРАЖЕНИЕ НА ДИСПЛЕЕ
	-- МОЖНО СРАВНИТЬ С ВАНИЛЬЮ, МЕНЯТСЯ КАРТИНКИ БУДУТ ЗДЕСЬ, Я САМ ПОМЕНЯЮ ЕСЛИ ЧТО
data.raw["arithmetic-combinator"]["arithmetic-combinator"].plus_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
				
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["arithmetic-combinator"]["arithmetic-combinator"].minus_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["arithmetic-combinator"]["arithmetic-combinator"].multiply_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["arithmetic-combinator"]["arithmetic-combinator"].divide_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["arithmetic-combinator"]["arithmetic-combinator"].modulo_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["arithmetic-combinator"]["arithmetic-combinator"].power_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["arithmetic-combinator"]["arithmetic-combinator"].left_shift_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["arithmetic-combinator"]["arithmetic-combinator"].right_shift_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["arithmetic-combinator"]["arithmetic-combinator"].and_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["arithmetic-combinator"]["arithmetic-combinator"].or_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["arithmetic-combinator"]["arithmetic-combinator"].xor_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				y = 30,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}


------------------------------------------------------------------------
--====================== СРАВНИВАЮЩИЙ КОМБИНАТОР	============================================================================================================================--
------------------------------------------------------------------------

-- ИКОНКА

data.raw["item"]["decider-combinator"].icon	= "__comb__/graphics/icons/decider_combinator_icon_64.png"

data.raw["decider-combinator"]["decider-combinator"].icon	= "__comb__/graphics/icons/decider_combinator_icon_64.png"

-- КАРТИНКА - СПРАЙТ

data.raw["decider-combinator"]["decider-combinator"].sprites =
make_4way_animation_from_spritesheet({ layers =
	{
		{
			filename = "__comb__/graphics/entity/decider_combinator.png",
			width = 150,
			height = 129,
			frame_count = 1,
			shift = {0,0},
			scale = 0.50
		},
		{
			filename = "__comb__/graphics/entity/decider_combinator_shadow.png",
			width = 150,
			height = 129,
			frame_count = 1,
			shift = util.by_pixel(21, 0),
			scale = 0.50,
			draw_as_shadow = true
		}
	}
})

-- ПРОВОДА

data.raw["decider-combinator"]["decider-combinator"].input_connection_points =
	{
		{
			shadow =
			{
				red = util.by_pixel(35/2, 39/2),
				green = util.by_pixel(69/2, 39/2)
			},
			wire =
			{
				red = util.by_pixel(-16/2, 6/2), 
				green = util.by_pixel(16/2, 6/2) 
			}
		},
		{
			shadow =
			{
				red = util.by_pixel(-26/2, -18/2),
				green = util.by_pixel(-20/2, 9.5/2)
			},
			wire =
			{
				red = util.by_pixel(-45/2, -35/2),
				green = util.by_pixel(-45/2, -12/2)
			}
		},
		{
			shadow =
			{
				red = util.by_pixel(68/2, -20/2),
				green = util.by_pixel(34/2, -21/2)
			},
			wire =
			{
				red = util.by_pixel(15/2, -54/2),
				green = util.by_pixel(-16/2, -54/2)
			}
		},
		{
			shadow =
			{
				red = util.by_pixel(91/2, 21/2),
				green = util.by_pixel(91/2, -2/2)
			},
			wire =
			{
				red = util.by_pixel(45/2, -12/2),  
				green = util.by_pixel(45/2, -35/2)
			}
		}
	}

data.raw["decider-combinator"]["decider-combinator"].output_connection_points =
	{
		{
		shadow =
			{
				red = util.by_pixel(34/2, -21/2),
				green = util.by_pixel(68/2, -20/2)
			},
			wire =
			{
				red = util.by_pixel(-15/2, -54/2),
				green = util.by_pixel(16/2, -54/2)
			}
		},
		{
		shadow =
			{
				red = util.by_pixel(91/2, -2/2),
				green = util.by_pixel(91/2, 21/2)
			},
			wire =
			{
				red = util.by_pixel(45/2, -35/2),  
				green = util.by_pixel(45/2, -12/2)
			}
		},
		{
		shadow =
			{
				red = util.by_pixel(69/2, 39/2),
				green = util.by_pixel(35/2, 39/2)
			},
			wire =
			{
				red = util.by_pixel(16/2, 6/2), 
				green = util.by_pixel(-16/2, 6/2) 
			}
		},
		{
		shadow =
			{
				red = util.by_pixel(-26/2, 9.5/2),
				green = util.by_pixel(-20/2, -18/2)
			},
			wire =
			{
				red = util.by_pixel(-45/2, -12/2),
				green = util.by_pixel(-45/2, -35/2)
			}
		}
	}

-- СИМВОЛЫ СРАВНИВАЮЩЕГО КОМБИНАТОРА

data.raw["decider-combinator"]["decider-combinator"].greater_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["decider-combinator"]["decider-combinator"].less_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 40,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["decider-combinator"]["decider-combinator"].equal_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 80,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["decider-combinator"]["decider-combinator"].not_equal_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 120,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["decider-combinator"]["decider-combinator"].less_or_equal_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 160,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
data.raw["decider-combinator"]["decider-combinator"].greater_or_equal_symbol_sprites =
	{
		north =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		east =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		south =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			},
		west =
			{
				filename = "__comb__/graphics/entity/combinator-displays.png",
				x = 200,
				y = 58,
				width = 40,
				height = 30,
				shift = util.by_pixel(0, -15),
				scale = 0.50
			}
	}
	
	----------------------------------------------------------------
	--========== ОДНОКЛЕТОЧНЫЙ (ПОСТОЯННЫЙ) КОМБИНАТОР ============================================================================================================================--
	----------------------------------------------------------------

-- ИКОНКИ
data.raw["item"]["constant-combinator"].icon	= "__comb__/graphics/icons/constant_combinator_icon_64.png"

data.raw["constant-combinator"]["constant-combinator"].icon	= "__comb__/graphics/icons/constant_combinator_icon_64.png"

-- КАРТИНКА + ТЕНЬ

data.raw["constant-combinator"]["constant-combinator"].sprites =
	make_4way_animation_from_spritesheet({ layers =
	  {
		{
		  filename = "__comb__/graphics/entity/constant_combinator.png",
		  width = 150,
		  height = 129,
		  frame_count = 1,
		  shift = {0,0},
		  scale = 0.50
		},
		{
		  filename = "__comb__/graphics/entity/constant_combinator_shadow.png",
		  width = 150,
		  height = 129,
		  frame_count = 1,
		  shift = util.by_pixel(21, 0),
		  scale = 0.50,
		  draw_as_shadow = true
		}
	  }
	})
	
-- ПРОВОДА
data.raw["constant-combinator"]["constant-combinator"].circuit_wire_connection_points =
  {
	{
	  shadow =
	  {
		red = util.by_pixel(36/2, -4/2),
		green = util.by_pixel(68/2, -4/2)
	  },
	  wire =
	  {
		red = util.by_pixel(-16/2, -39/2),
		green = util.by_pixel(15/2, -39/2)
	  }
	},
	{
	  shadow =
	  {
		red = util.by_pixel(68/2, -1/2),
		green = util.by_pixel(68/2, 21/2)
	  },
	  wire =
	  {
		red = util.by_pixel(22/2, -36/2),
		green = util.by_pixel(22/2, -12/2)
	  }
	},
	{
	  shadow =
	  {
		red = util.by_pixel(68/2, 23/2),
		green = util.by_pixel(35/2, 23/2)
	  },
	  wire =
	  {
		red = util.by_pixel(15/2, -8/2),
		green = util.by_pixel(-16/2, -8/2)
	  }
	},
	{
	  shadow =
	  {
		red = util.by_pixel(49/2, 19/2),
		green = util.by_pixel(49/2, -2/2) 
	  },
	  wire =
	  {
		red = util.by_pixel(-22/2, -13/2),
		green = util.by_pixel(-22/2, -36/2)
	  }
	}
  }