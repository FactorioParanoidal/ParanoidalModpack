local ltnc = flib.copy_prototype(data.raw["constant-combinator"]["constant-combinator"], "ltn-combinator")
ltnc.icon = "__LTN_Combinator_Modernized__/graphics/ltn-combinator.png"
ltnc.icon_size = 32
ltnc.icon_mipmaps = nil
ltnc.next_upgrade = nil
ltnc.item_slot_count = 27
ltnc.fast_replaceable_group = "constant-combinator"
ltnc.sprites = make_4way_animation_from_spritesheet(
    { layers =
        {
            {
                filename = "__LTN_Combinator_Modernized__/graphics/ltn-combinator.png",
                width = 58,
                height = 52,
                frame_count = 1,
                shift = util.by_pixel(0, 5),
                hr_version = {
                    scale = 0.5,
                    filename = "__LTN_Combinator_Modernized__/graphics/hr-ltn-combinator.png",
                    width = 114,
                    height = 102,
                    frame_count = 1,
                    shift = util.by_pixel(0, 5),
                },
            },
            {
                filename = "__base__/graphics/entity/combinator/constant-combinator-shadow.png",
                width = 50,
                height = 30,
                frame_count = 1,
                shift = util.by_pixel(9,6),
                draw_as_shadow = true,
                hr_version = {
                  scale = 0.5,
                  filename = "__base__/graphics/entity/combinator/hr-constant-combinator-shadow.png",
                  width = 98,
                  height = 66,
                  frame_count = 1,
                  shift = util.by_pixel(8.5, 5.5),
                  draw_as_shadow = true,
                },
            },
        },
    })

local ltnc_item = flib.copy_prototype(data.raw["item"]["constant-combinator"], "ltn-combinator")
ltnc_item.icon = "__LTN_Combinator_Modernized__/graphics/ltn-combinator-item.png"
ltnc_item.icon_size = 64
ltnc_item.icon_mipmaps = 4

local ltnc_recipe = flib.copy_prototype(data.raw["recipe"]["constant-combinator"], "ltn-combinator")
ltnc_recipe.ingredients = {
    {"constant-combinator", 1},
    {"electronic-circuit", 1},
}

data:extend({
    ltnc,
    ltnc_item,
    ltnc_recipe,
})