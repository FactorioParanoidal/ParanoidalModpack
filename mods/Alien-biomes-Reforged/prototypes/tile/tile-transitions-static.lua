function alien_biomes_beach_transitions()
  return {
        {
          to_tiles = {
            "water",
            "deepwater",
            "water-green",
            "deepwater-green",
            "water-shallow",
            "water-mud",
            "water-wube"
          },
          transition_group = 1,
          spritesheet = "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/beach.png",
          layout = {
            overlay = {
              inner_corner = {
                count = 16,
                line_length = 16,
                scale = 0.5,
                tile_height = 1,
                x = 0,
                y = 0,
              },
              o_transition = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                tile_height = 1,
                x = 0,
                y = 2304,
              },
              outer_corner = {
                count = 16,
                line_length = 16,
                scale = 0.5,
                tile_height = 1,
                x = 0,
                y = 576,
              },
              side = {
                count = 16,
                line_length = 16,
                scale = 0.5,
                tile_height = 1,
                x = 0,
                y = 1152,
              },
              u_transition = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                tile_height = 1,
                x = 0,
                y = 1728,
              }
            },
            background = {
              inner_corner = {
                count = 16,
                line_length = 16,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 0,
              },
              o_transition = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 2304,
              },
              outer_corner = {
                count = 16,
                line_length = 16,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 576,
              },
              side = {
                count = 16,
                line_length = 16,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 1152,
              },
              u_transition = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 1728,
              }
            },
            mask = {
              inner_corner = {
                count = 16,
                line_length = 16,
                scale = 0.5,
                x = 2176,
                y = 0,
              },
              o_transition = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                x = 2176,
                y = 2304,
              },
              outer_corner = {
                count = 16,
                line_length = 16,
                scale = 0.5,
                x = 2176,
                y = 576,
              },
              side = {
                count = 16,
                line_length = 16,
                scale = 0.5,
                x = 2176,
                y = 1152,
              },
              u_transition = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                x = 2176,
                y = 1728,
              }
            },
          },
        },
        {
          to_tiles = {
            "out-of-map"
          },
          transition_group = 2,
          background_layer_group = "zero",
          background_layer_offset = 1,
          offset_background_layer_by_tile_layer = true,
          spritesheet = "__base__/graphics/terrain/out-of-map-transition/out-of-map-transition.png",
          layout = {
            background = {
              inner_corner = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 0,
              },
              o_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 2304,
              },
              outer_corner = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 576,
              },
              side = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1728,
              },
            },
            mask = {
              inner_corner = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                x = 2176,
                y = 0,
              },
              o_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                x = 2176,
                y = 2304,
              },
              outer_corner = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                x = 2176,
                y = 576,
              },
              side = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                x = 2176,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                x = 2176,
                y = 1728,
              },
            },
          },
        }
      }
end

function alien_biomes_beach_transitions_between_transitions()
  return {
        {
          --transition_group = 0,
          transition_group1 = 0,
          transition_group2 = 1,
          spritesheet = "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/beach-transition.png",
          layout = {
            overlay = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 1,
                x = 0,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 1,
                x = 0,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 1,
                x = 0,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 1728,
              }
            },
            background = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1728,
              }
            },
            mask = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                x = 2176,
                y = 1728,
              }
            },
          },
          water_patch = {
            filename = "__base__/graphics/terrain/water-transitions/water-patch.png",
            height = 64,
            scale = 0.5,
            width = 64
          }
        },
        {
          --transition_group = 0,
          transition_group1 = 0,
          transition_group2 = 2,
          background_layer_group = "zero",
          background_layer_offset = 1,
          offset_background_layer_by_tile_layer = true,
          spritesheet = "__base__/graphics/terrain/out-of-map-transition/sand-out-of-map-transition.png",
          layout = {
            background = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1728,
              }
            },
            mask = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                x = 2176,
                y = 1728,
              }
            },
          },
        },
        {
          --transition_group = 1,
          transition_group1 = 1,
          transition_group2 = 2,
          background_layer_group = "zero",
          background_layer_offset = 1,
          offset_background_layer_by_tile_layer = true,
          spritesheet = "__base__/graphics/terrain/out-of-map-transition/sand-shore-out-of-map-transition.png",
          layout = {
            overlay = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 1728,
              }
            },
            background = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1728,
              }
            },
            mask = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                x = 2176,
                y = 1728,
              }
            },
          },
          water_patch = nil
        }
      }
end

function alien_biomes_cliff_transitions()
  return {
        {
          to_tiles = {
            "water",
            "deepwater",
            "water-green",
            "deepwater-green",
            "water-shallow",
            "water-mud",
            "water-wube"
          },
          transition_group = 1,
          spritesheet = "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/cliff.png",
          layout = {
            overlay = {
              inner_corner = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 0,
              },
              o_transition = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                tile_height = 1,
                x = 0,
                y = 2304,
              },
              outer_corner = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 576,
              },
              side = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 1152,
              },
              u_transition = {
                count = 2,
                line_length = 2,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 1728,
              }
            },
            background = {
              inner_corner = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 0,
              },
              o_transition = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 2304,
              },
              outer_corner = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 576,
              },
              side = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1152
              },
              u_transition = {
                count = 2,
                line_length = 2,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1728,
              }
            },
            mask = {
              inner_corner = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                x = 2176,
                y = 0,
              },
              o_transition = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                x = 2176,
                y = 2304,
              },
              outer_corner = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                x = 2176,
                y = 576,
              },
              side = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                x = 2176,
                y = 1152,
              },
              u_transition = {
                count = 2,
                line_length = 2,
                scale = 0.5,
                x = 2176,
                y = 1728,
              }
            },
          },
        },
        {
          to_tiles = {
            "out-of-map"
          },
          transition_group = 2,
          spritesheet = "__base__/graphics/terrain/out-of-map-transition/out-of-map-transition.png",
          background_layer_group = "zero",
          background_layer_offset = 1,
          offset_background_layer_by_tile_layer = true,
          layout = {
            background = {
              inner_corner = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 0
              },
              o_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 1,
                x = 1088,
                y = 2304,
              },
              outer_corner = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 576,
              },
              side = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1728,
              }
            },
            mask = {
              inner_corner = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                x = 2176,
                y = 0,
              },
              o_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                x = 2176,
                y = 2304,
              },
              outer_corner = {
                count = 4,
                line_length = 4,
                scale = 0.5,
                x = 2176,
                y = 576,
              },
              side = {
                count = 8,
                line_length = 8,
                scale = 0.5,
                x = 2176,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                x = 2176,
                y = 1728,
              }
            },
          },
        }
      }

end

function alien_biomes_cliff_transitions_between_transitions()
  return {
        {
          --transition_group = 0,
          transition_group1 = 0,
          transition_group2 = 1,
          spritesheet = "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/cliff-transition.png",
          layout = {
            overlay = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 1728,
              }
            },
            background = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1728,
              }
            },
            mask = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                x = 2176,
                y = 1728,
              }
            },
          },
          water_patch = {
            filename = "__base__/graphics/terrain/water-transitions/water-patch.png",
            height = 64,
            scale = 0.5,
            width = 64
          }
        },
        {
          --transition_group = 0,
          transition_group1 = 0,
          transition_group2 = 2,
          background_layer_group = "zero",
          background_layer_offset = 1,
          offset_background_layer_by_tile_layer = true,
          spritesheet = "__base__/graphics/terrain/out-of-map-transition/dirt-out-of-map-transition.png",
          layout = {
            background = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1728,
              }
            },
            mask = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                x = 2176,
                y = 1728,
              }
            },
          },
          water_patch = nil
        },
        {
          --transition_group = 1,
          transition_group1 = 1,
          transition_group2 = 2,
          background_layer_group = "zero",
          background_layer_offset = 1,
          offset_background_layer_by_tile_layer = true,
          spritesheet = "__base__/graphics/terrain/out-of-map-transition/dark-dirt-shore-out-of-map-transition.png",
          layout = {
            overlay = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 0,
                y = 1728,
              }
            },
            background = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                tile_height = 2,
                x = 1088,
                y = 1728,
              }
            },
            mask = {
              inner_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 0,
              },
              outer_corner = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 576,
              },
              side = {
                count = 3,
                line_length = 3,
                scale = 0.5,
                x = 2176,
                y = 1152,
              },
              u_transition = {
                count = 1,
                line_length = 1,
                scale = 0.5,
                x = 2176,
                y = 1728,
              }
            },
          },
          water_patch = nil
        }
      }
end

return {
  beach_transitions = alien_biomes_beach_transitions,
  beach_transitions_between_transitions = alien_biomes_beach_transitions_between_transitions,
  cliff_transitions = alien_biomes_cliff_transitions,
  cliff_transitions_between_transitions = alien_biomes_cliff_transitions_between_transitions,
}
