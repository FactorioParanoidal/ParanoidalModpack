bobicon("electric-furnace","assembling-machine",1,3,0)

if data.raw["furnace"]["electric-furnace-2"] then
	data.raw["furnace"]["electric-furnace"]["animation"]["layers"] = {
      {
        filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-furnace-base-1.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        hr_version = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-furnace-1.png",
          priority = "high",
          width = 239,
          height = 219,
          frame_count = 1,
          shift = util.by_pixel(0.75, 5.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        draw_as_shadow = true,
        hr_version = {
          filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
          priority = "high",
          width = 227,
          height = 171,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(11.25, 7.75),
          scale = 0.5
        }
      }
      }
	data.raw["furnace"]["electric-furnace"]["working_visualisations"][1]["animation"] = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-furnace-heater-1.png",
          priority = "high",
          width = 25,
          height = 15,
          frame_count = 12,
          animation_speed = 0.5,
          shift = {0.015625, 0.890625},
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-furnace-heater-1.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(1.75, 32.75),
            scale = 0.5
          }
        }
	data.raw["furnace"]["electric-furnace-2"]["animation"]["layers"] = {
      {
        filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-furnace-base-2.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        hr_version = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-furnace-2.png",
          priority = "high",
          width = 239,
          height = 219,
          frame_count = 1,
          shift = util.by_pixel(0.75, 5.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        draw_as_shadow = true,
        hr_version = {
          filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
          priority = "high",
          width = 227,
          height = 171,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(11.25, 7.75),
          scale = 0.5
        }
      }
      }
	data.raw["furnace"]["electric-furnace-2"]["working_visualisations"][1]["animation"] = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-furnace-heater-2.png",
          priority = "high",
          width = 25,
          height = 15,
          frame_count = 12,
          animation_speed = 0.5,
          shift = {0.015625, 0.890625},
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-furnace-heater-2.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(1.75, 32.75),
            scale = 0.5
          }
        }
	data.raw["furnace"]["electric-furnace-3"]["animation"]["layers"] = {
      {
        filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-furnace-base-3.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        hr_version = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-furnace-3.png",
          priority = "high",
          width = 239,
          height = 219,
          frame_count = 1,
          shift = util.by_pixel(0.75, 5.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        draw_as_shadow = true,
        hr_version = {
          filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
          priority = "high",
          width = 227,
          height = 171,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(11.25, 7.75),
          scale = 0.5
        }
      }
      }
	data.raw["furnace"]["electric-furnace-3"]["working_visualisations"][1]["animation"] = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-furnace-heater-3.png",
          priority = "high",
          width = 25,
          height = 15,
          frame_count = 12,
          animation_speed = 0.5,
          shift = {0.015625, 0.890625},
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-furnace-heater-3.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(1.75, 32.75),
            scale = 0.5
          }
        }		
end


if settings.startup["new-furnaces"].value == true then
if data.raw["assembling-machine"]["chemical-furnace"] then
bobicon("chemical-furnace","assembling-machine",1,1,0)
	data.raw["assembling-machine"]["chemical-furnace"]["animation"]["layers"] = {
      {
        filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-chem.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        hr_version = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-chem.png",
          priority = "high",
          width = 239,
          height = 219,
          frame_count = 1,
          shift = util.by_pixel(0.75, 5.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        draw_as_shadow = true,
        hr_version = {
          filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
          priority = "high",
          width = 227,
          height = 171,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(11.25, 7.75),
          scale = 0.5
        }
      }
      }
	data.raw["assembling-machine"]["chemical-furnace"]["working_visualisations"][1]["animation"] = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-furnace-heater-1.png",
          priority = "high",
          width = 25,
          height = 15,
          frame_count = 12,
          animation_speed = 0.5,
          shift = {0.015625, 0.890625},
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-furnace-heater-1.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(1.75, 32.75),
            scale = 0.5
          }
        }
end

if data.raw["assembling-machine"]["electric-mixing-furnace"] then
bobicon("electric-mixing-furnace","assembling-machine",1,1,0)
	data.raw["assembling-machine"]["electric-mixing-furnace"]["animation"]["layers"] = {
      {
        filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-mix.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        hr_version = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-mix.png",
          priority = "high",
          width = 239,
          height = 219,
          frame_count = 1,
          shift = util.by_pixel(0.75, 5.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        draw_as_shadow = true,
        hr_version = {
          filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
          priority = "high",
          width = 227,
          height = 171,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(11.25, 7.75),
          scale = 0.5
        }
      }
      }
	data.raw["assembling-machine"]["electric-mixing-furnace"]["working_visualisations"][1]["animation"] = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-furnace-heater-1.png",
          priority = "high",
          width = 25,
          height = 15,
          frame_count = 12,
          animation_speed = 0.5,
          shift = {0.015625, 0.890625},
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-furnace-heater-1.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(1.75, 32.75),
            scale = 0.5
          }
        }
end

if data.raw["assembling-machine"]["electric-chemical-mixing-furnace"] then
bobicon("electric-chemical-mixing-furnace","assembling-machine",1,2,-1)	
	data.raw["assembling-machine"]["electric-chemical-mixing-furnace"]["animation"]["layers"] = {
      {
        filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-multi-1.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        hr_version = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-multi-1.png",
          priority = "high",
          width = 239,
          height = 219,
          frame_count = 1,
          shift = util.by_pixel(0.75, 5.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        draw_as_shadow = true,
        hr_version = {
          filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
          priority = "high",
          width = 227,
          height = 171,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(11.25, 7.75),
          scale = 0.5
        }
      }
      }
	data.raw["assembling-machine"]["electric-chemical-mixing-furnace"]["working_visualisations"][1]["animation"] = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-furnace-heater-2.png",
          priority = "high",
          width = 25,
          height = 15,
          frame_count = 12,
          animation_speed = 0.5,
          shift = {0.015625, 0.890625},
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-furnace-heater-2.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(1.75, 32.75),
            scale = 0.5
          }
        }		
end


if data.raw["assembling-machine"]["electric-chemical-mixing-furnace-2"] then
-- bobicon("electric-furnace","assembling-machine",1,3,0)	
	data.raw["assembling-machine"]["electric-chemical-mixing-furnace-2"]["animation"]["layers"] = {
      {
        filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-multi-2.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        hr_version = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-multi-2.png",
          priority = "high",
          width = 239,
          height = 219,
          frame_count = 1,
          shift = util.by_pixel(0.75, 5.75),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
        priority = "high",
        width = 129,
        height = 100,
        frame_count = 1,
        shift = {0.421875, 0},
        draw_as_shadow = true,
        hr_version = {
          filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
          priority = "high",
          width = 227,
          height = 171,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(11.25, 7.75),
          scale = 0.5
        }
      }
      }
	data.raw["assembling-machine"]["electric-chemical-mixing-furnace-2"]["working_visualisations"][1]["animation"] = {
          filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/electric-furnace-heater-3.png",
          priority = "high",
          width = 25,
          height = 15,
          frame_count = 12,
          animation_speed = 0.5,
          shift = {0.015625, 0.890625},
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/electric-furnace/hr-electric-furnace-heater-3.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(1.75, 32.75),
            scale = 0.5
          }
        }		
end
end



if data.raw["assembling-machine"]["chemical-steel-furnace"] then
    data.raw["item"]["chemical-steel-furnace"].icon = "__ShinyBobGFX__/graphics/entity/chemical-steel-furnace/icon/steel-furnace-chem.png"
    data.raw["assembling-machine"]["chemical-steel-furnace"].icon = "__ShinyBobGFX__/graphics/entity/chemical-steel-furnace/icon/steel-furnace-chem.png"
    data.raw["assembling-machine"]["chemical-steel-furnace"]["animation"] = {
        layers = {
            {
                filename = "__ShinyBobGFX__/graphics/entity/chemical-steel-furnace/steel-furnace-chem.png",
                priority = "high",
                width = 85,
                height = 87,
                frame_count = 1,
                shift = util.by_pixel(-1.5, 1.5),
                hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/chemical-steel-furnace/hr-steel-furnace-chem.png",
                    priority = "high",
                    width = 171,
                    height = 174,
                    frame_count = 1,
                    shift = util.by_pixel(-1.25, 2),
                    scale = 0.5
                }
            },
            {
                filename = "__base__/graphics/entity/steel-furnace/steel-furnace-shadow.png",
                priority = "high",
                width = 139,
                height = 43,
                frame_count = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(39.5, 11.5),
                hr_version = {
                    filename = "__base__/graphics/entity/steel-furnace/hr-steel-furnace-shadow.png",
                    priority = "high",
                    width = 277,
                    height = 85,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(39.25, 11.25),
                    scale = 0.5
                }
            },
        },
    }
end

if data.raw["assembling-machine"]["mixing-steel-furnace"] then
    data.raw["item"]["mixing-steel-furnace"].icon = "__ShinyBobGFX__/graphics/entity/mixing-steel-furnace/icon/steel-furnace-mixer.png"
    data.raw["assembling-machine"]["mixing-steel-furnace"].icon = "__ShinyBobGFX__/graphics/entity/mixing-steel-furnace/icon/steel-furnace-mixer.png"
    data.raw["assembling-machine"]["mixing-steel-furnace"]["animation"] = {
        layers = {
            {
                filename = "__ShinyBobGFX__/graphics/entity/mixing-steel-furnace/steel-furnace-mixer.png",
                priority = "high",
                width = 85,
                height = 87,
                frame_count = 1,
                shift = util.by_pixel(-1.5, 1.5),
                hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/mixing-steel-furnace/hr-steel-furnace-mixer.png",
                    priority = "high",
                    width = 171,
                    height = 174,
                    frame_count = 1,
                    shift = util.by_pixel(-1.25, 2),
                    scale = 0.5
                }
            },
            {
                filename = "__base__/graphics/entity/steel-furnace/steel-furnace-shadow.png",
                priority = "high",
                width = 139,
                height = 43,
                frame_count = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(39.5, 11.5),
                hr_version = {
                    filename = "__base__/graphics/entity/steel-furnace/hr-steel-furnace-shadow.png",
                    priority = "high",
                    width = 277,
                    height = 85,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(39.25, 11.25),
                    scale = 0.5
                }
            },
        },
    }
end
