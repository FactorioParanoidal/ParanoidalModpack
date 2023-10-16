if not NE_Enemies then
    NE_Enemies = {}
end
if not NE_Enemies.Settings then
    NE_Enemies.Settings = {}
end

NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value
NE_Enemies.Settings.NE_Alternative_Graphics = settings.startup["NE_Alternative_Graphics"].value



local sounds = require("__base__.prototypes.entity.sounds")
require ("prototypes.NE_Units.New_Biter_Graphics_Arachnids")
require ("prototypes.NE_Units.New_Biter_Graphics_Zerg")
require ("prototypes.NE_Units.New_Spitter_Graphics_Zerg")

--- Tint
--- Transparency
trans = 0.7

ne_blue_tint1 = {
    r = 0,
    g = 0,
    b = 1,
    a = trans
}
ne_blue_tint2 = {
    r = 0,
    g = 200 / 255,
    b = 1,
    a = trans
}

ne_fire_tint = {
    r = 1,
    g = 0,
    b = 0,
    a = trans
} -- Red
ne_fire_tint2 = {
    r = 1,
    g = 0,
    b = 50 / 255,
    a = 0.8
}

ne_green_tint = {
    r = 0,
    g = 204 / 255,
    b = 0,
    a = trans
}
ne_green_tint2 = {
    r = 204 / 255,
    g = 1,
    b = 153 / 255,
    a = trans
}

ne_pink_tint = {
    r = 1,
    g = 0,
    b = 200 / 255,
    a = trans
}

ne_yellow_tint = {
    r = 1,
    g = 1,
    b = 50 / 255,
    a = trans
}
ne_yellow_tint2 = {
    r = 1,
    g = 1,
    b = 100 / 255,
    a = 0.2
}

ne_orange_tint = {
    r = 1,
    g = 150 / 255,
    b = 0,
    a = trans
}

ne_purple_tint = {
    r = 150 / 255,
    g = 50 / 255,
    b = 1,
    a = trans
}
ne_black_tint = {
    r = 0,
    g = 0,
    b = 0,
    a = trans
}
ne_brown_tint = {
    r = 150 / 255,
    g = 100 / 255,
    b = 50 / 255,
    a = trans
}

ne_grey_tint = {
    r = 192 / 255,
    g = 192 / 255,
    b = 192 / 255,
    a = trans
}



if NE_Enemies.Settings.NE_Alternative_Graphics == true then


  function NE_Biter_Melee_Single_Attack_Breeder(data)
    return {
        type = "projectile",
        range = data.range,
        cooldown = data.cooldown,
        damage_modifier = data.damage_modifier or 1,
        ammo_category = "melee",
        ammo_type = {
            category = "melee",
            target_type = "entity",
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_1
                        }
                    }
                }
            }
        },
        sound = sounds.biter_roars(sound),
        animation = zerg_broodling_attackanimation("broodling", data.scale, data.tint2)
    }

end


  function NE_Biter_Melee_Double_Attack_Tank(data)
      return {
          type = "projectile",
          range = data.range,
          cooldown = data.cooldown,
          damage_modifier = data.damage_modifier or 1,
          ammo_category = "melee",
          ammo_type = {
              category = "melee",
              target_type = "entity",
              action = {
                  type = "direct",
                  action_delivery = {
                      type = "instant",
                      target_effects = {{
                          type = "damage",
                          damage = {
                              amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty,
                              type = data.damage_type_1
                          }
                      }, {
                          type = "damage",
                          damage = {
                              amount = data.damage_amount_2 + NE_Enemies.Settings.NE_Difficulty,
                              type = data.damage_type_2
                          }
                      }}
                  }
              }
          },
          sound = sounds.biter_roars(sound),
          animation = zerg_ultralisk_attackanimation("ultralisk", data.scale, data.tint2)
      }

    end



    function NE_Biter_Melee_Tripple_Attack_Wall(data)
      return {
          type = "projectile",
          range = data.range,
          cooldown = data.cooldown,
          damage_modifier = data.damage_modifier or 1,
          ammo_category = "melee",
          ammo_type = {
              category = "melee",
              target_type = "entity",
              action = {
                  type = "direct",
                  action_delivery = {
                      type = "instant",
                      target_effects = {{
                          type = "damage",
                          damage = {
                              amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty,
                              type = data.damage_type_1
                          }
                      }, {
                          type = "damage",
                          damage = {
                              amount = data.damage_amount_2 + NE_Enemies.Settings.NE_Difficulty,
                              type = data.damage_type_2
                          }
                      }, {
                          type = "damage",
                          damage = {
                              amount = data.damage_amount_3 + NE_Enemies.Settings.NE_Difficulty,
                              type = data.damage_type_3
                          }
                      }}
                  }
              }
          },
          sound = sounds.biter_roars(sound),
          animation = arachnids_attackanimation(data.scale, data.tint1, data.tint2)
      }
  
  end


else

  
function NE_Biter_Melee_Single_Attack_Breeder(data)
  return {
      type = "projectile",
      range = data.range,
      cooldown = data.cooldown,
      damage_modifier = data.damage_modifier or 1,
      ammo_category = "melee",
      ammo_type = {
          category = "melee",
          target_type = "entity",
          action = {
              type = "direct",
              action_delivery = {
                  type = "instant",
                  target_effects = {
                      type = "damage",
                      damage = {
                          amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty,
                          type = data.damage_type_1
                      }
                  }
              }
          }
      },
      sound = sounds.biter_roars(sound),
      animation = biterattackanimation(data.scale, data.tint1, data.tint2)
  }

  end

  function NE_Biter_Melee_Double_Attack_Tank(data)
    return {
        type = "projectile",
        range = data.range,
        cooldown = data.cooldown,
        damage_modifier = data.damage_modifier or 1,
        ammo_category = "melee",
        ammo_type = {
            category = "melee",
            target_type = "entity",
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {{
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_1
                        }
                    }, {
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_2 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_2
                        }
                    }}
                }
            }
        },
        sound = sounds.biter_roars(sound),
        animation = biterattackanimation(data.scale, data.tint1, data.tint2)
    }

 end

  function NE_Biter_Melee_Tripple_Attack_Wall(data)
    return {
        type = "projectile",
        range = data.range,
        cooldown = data.cooldown,
        damage_modifier = data.damage_modifier or 1,
        ammo_category = "melee",
        ammo_type = {
            category = "melee",
            target_type = "entity",
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {{
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_1
                        }
                    }, {
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_2 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_2
                        }
                    }, {
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_3 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_3
                        }
                    }}
                }
            }
        },
        sound = sounds.biter_roars(sound),
        animation = biterattackanimation(data.scale, data.tint1, data.tint2)
    }

  end

end


--- Biters
function ne_biter_run_animation(scale, tint1, tint2)
    return {
        layers = {{
            width = 169,
            height = 114,
            frame_count = 16,
            direction_count = 16,
            shift = {scale * 0.714844, scale * -0.246094},
            scale = scale,
            stripes = {{
                filename = "__base__/graphics/entity/biter/biter-run-1.png",
                width_in_frames = 8,
                height_in_frames = 16
            }, {
                filename = "__base__/graphics/entity/biter/biter-run-2.png",
                width_in_frames = 8,
                height_in_frames = 16
            }}
        }, {
            filename = "__base__/graphics/entity/biter/biter-run-mask1.png",
            flags = {"mask"},
            width = 105,
            height = 81,
            frame_count = 16,
            direction_count = 16,
            shift = {scale * 0.117188, scale * -0.867188},
            scale = scale,
            tint = tint1
        }, {
            filename = "__base__/graphics/entity/biter/biter-run-mask2.png",
            flags = {"mask"},
            line_length = 16,
            width = 95,
            height = 81,
            frame_count = 16,
            direction_count = 16,
            shift = {scale * 0.117188, scale * -0.855469},
            scale = scale,
            tint = tint2
        }}
    }
end




function NE_Biter_Melee_Single_Attack_Meg(data)
    return {
        type = "projectile",
        range = data.range,
        cooldown = data.cooldown,
        damage_modifier = data.damage_modifier or 1,
        ammo_category = "melee",
        ammo_type = {
            category = "melee",
            target_type = "entity",
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_1
                        }
                    }
                }
            }
        },
        sound = sounds.biter_roars(sound),
        animation = biterattackanimation(data.scale, data.tint1, data.tint2)
    }

end


function NE_Biter_Melee_Double_Attack(data)
    return {
        type = "projectile",
        range = data.range,
        cooldown = data.cooldown,
        damage_modifier = data.damage_modifier or 1,
        ammo_category = "melee",
        ammo_type = {
            category = "melee",
            target_type = "entity",
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {{
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_1
                        }
                    }, {
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_2 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_2
                        }
                    }}
                }
            }
        },
        sound = sounds.biter_roars(sound),
        animation = biterattackanimation(data.scale, data.tint1, data.tint2)
    }

end


function NE_Biter_Melee_Tripple_Attack(data)
    return {
        type = "projectile",
        range = data.range,
        cooldown = data.cooldown,
        damage_modifier = data.damage_modifier or 1,
        ammo_category = "melee",
        ammo_type = {
            category = "melee",
            target_type = "entity",
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {{
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_1
                        }
                    }, {
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_2 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_2
                        }
                    }, {
                        type = "damage",
                        damage = {
                            amount = data.damage_amount_3 + NE_Enemies.Settings.NE_Difficulty,
                            type = data.damage_type_3
                        }
                    }}
                }
            }
        },
        sound = sounds.biter_roars(sound),
        animation = biterattackanimation(data.scale, data.tint1, data.tint2)
    }

end

