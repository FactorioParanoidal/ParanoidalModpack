-- import

local fireUtils = require("FireUtils")
local stickerUtils = require("StickerUtils")
local streamUtils = require("StreamUtils")
local projectileUtils = require("ProjectileUtils")

-- constants

-- imported functions

local makeStream = streamUtils.makeStream
local makeSticker = stickerUtils.makeSticker
local makeProjectile = projectileUtils.makeProjectile
local makeClusterProjectile = projectileUtils.makeClusterProjectile
local makeAcidSplashFire = fireUtils.makeAcidSplashFire

local makeFire = fireUtils.makeFire
local makeSpreadOnceEffect = fireUtils.makeSpreadOnceEffect


-- dumb acid projectiles
local AttackBall = {}

function AttackBall.createAttackBall(attributes)
    local templateAOEDamage = { amount = attributes.damage * 0.75, type = attributes.damageType or "acid" }
    local templateDirectDamage = { amount = attributes.damage * 0.25, type = attributes.damageType or "acid" }
    local templateArea = {
        type = "area",
		force = "not-same",
        radius = attributes.radius,        
        ignore_collision_condition = true,
        action_delivery = (attributes.areaActionDelivery and attributes.areaActionDelivery(attributes)) or
            {
                {
                    type = "instant",
                    target_effects = (attributes.areaEffects and attributes.areaEffects(attributes)) or
                        {
                            {
                                type = "damage",
                                damage = templateAOEDamage
                            }
                        }
                }
            }
    }

    local targetEffects
    if attributes.attackPointEffects then
        targetEffects = (attributes.attackPointEffects and attributes.attackPointEffects(attributes))
    else
        local rec = {
            {
                type = "damage",
                damage = templateDirectDamage
            },
            {
                type = "create-entity",
                entity_name = "water-splash",
                tile_collision_mask = { "ground-tile" }
            },
            {
                type = "play-sound",
                sound =
                    {
                        {
                            filename = "__base__/sound/creatures/projectile-acid-burn-1.ogg",
                            volume = 0.25 + (attributes.effectiveLevel * 0.05)
                        },
                        {
                            filename = "__base__/sound/creatures/projectile-acid-burn-2.ogg",
                            volume = 0.25 + (attributes.effectiveLevel * 0.05)
                        },
                        {
                            filename = "__base__/sound/creatures/projectile-acid-burn-long-1.ogg",
                            volume = 0.25 + (attributes.effectiveLevel * 0.05)
                        },
                        {
                            filename = "__base__/sound/creatures/projectile-acid-burn-long-2.ogg",
                            volume = 0.25 + (attributes.effectiveLevel * 0.05)
                        }
                    }
            }
        }
        if not attributes.noAcidPuddle then
            rec[#rec+1] = {
                type="create-fire",
                entity_name = makeAcidSplashFire(attributes, attributes.stickerName or makeSticker(attributes)),
                check_buildability = true,
                initial_ground_flame_count = 1,
                show_in_tooltip = true
            }
        end
        targetEffects = rec
    end

    local templateActions = {
        templateArea,
        {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = targetEffects
            }
        }
    }

    local name
    -- local template
    if (attributes.attackType == "stream") then
        -- template = {
        --     name = attributes.name,
        --     tint = attributes.tint,
        --     particleVertialAcceleration = attributes.particleVertialAcceleration,
        --     particleHoizontalSpeed = attributes.particleHoizontalSpeed,
        --     particleHoizontalSpeedDeviation = attributes.particleHoizontalSpeedDeviation,
        --     actions = templateActions,
        --     scale = attributes.scale
        -- }
        attributes.actions = templateActions
        name = makeStream(attributes)
    else
		if attributes.clusterAttack then
			name = makeClusterProjectile(attributes, templateActions)			
		else
			name = makeProjectile(attributes, templateActions)
		end	
    end

    return name
end

function AttackBall.createSpitFire(attributes, animationProjectile, shadowProjectile)
 	local damageModifier = (attributes.attackModifiers and attributes.attackModifiers.damage) or 1
 	local fireDamageModifier = (attributes.attackModifiers and attributes.attackModifiers.fireDamage) or 1
	
    local spawnEntityName = makeSpreadOnceEffect({
            name = attributes.name,
            tint2 = attributes.tint2,
            fireDamagePerTick = attributes.fireDamagePerTick * fireDamageModifier,
            fireDamagePerTickType = attributes.fireDamagePerTickType,
    })
    local stickerName = makeSticker({
            name = attributes.name,
            spawnEntityName = spawnEntityName,
            stickerDuration = attributes.stickerDuration,
            stickerDamagePerTick = attributes.stickerDamagePerTick,
            stickerDamagePerTickType = attributes.stickerDamagePerTickType,
            stickerMovementModifier = attributes.stickerMovementModifier,
            tint2 = attributes.tint2,
            fireSpreadRadius = attributes.fireSpreadRadius
    })
    local fireName = makeFire({
            name = attributes.name,
            tint2 = attributes.tint2 or {r=0, g=0.9, b=0, a=0.5},
            spawnEntityName = spawnEntityName,
            fireDamagePerTick = attributes.fireDamagePerTick * fireDamageModifier,
            fireDamagePerTickType = attributes.fireDamagePerTickType,
            damageMaxMultipler = attributes.damageMaxMultipler,
            multiplerIncrease = attributes.multiplerIncrease,
            multiplerDecrease = attributes.multiplerDecrease,
            stickerName = stickerName
    })

    return makeProjectile(attributes,
                          {
                              {
                                  type = "area",
                                  radius = attributes.radius or 2.5,
                                  force = "not-same",
                                  action_delivery =
                                      {
                                          type = "instant",
                                          target_effects =
                                              {
                                                  {
                                                      type = "create-sticker",
                                                      sticker = stickerName,
                                                      check_buildability = true
                                                  },
                                                  {
                                                      type = "create-entity",
                                                      entity_name = "water-splash",
                                                      tile_collision_mask = { "ground-tile" }
                                                  },
                                                  {
                                                      type = "damage",
                                                      damage = { amount = attributes.damage*damageModifier, type = "acid" }
                                                  }
                                              }
                                      }
                              },
                              {
                                  type = "cluster",
                                  cluster_count = 2,
                                  distance = 2 + (0.1 * attributes.effectiveLevel),
                                  distance_deviation = 1.5,
                                  action_delivery = {
                                      type = "instant",
                                      target_effects = {
                                          {
                                              type="create-fire",
                                              entity_name = fireName,
                                              check_buildability = true,
                                              initial_ground_flame_count = 2,
                                              show_in_tooltip = true
                                          }
                                      }
                                  }
                              },
                              {
                                  type = "direct",
                                  action_delivery = {
                                      type = "instant",
                                      target_effects = {
                                          type= "create-fire",
                                          entity_name = fireName,
                                          check_buildability = true,
                                          show_in_tooltip = true
                                      }
                                  }
                              }
                          },
						  animationProjectile, shadowProjectile
    )
end

function AttackBall.generateVanilla()
    AttackBall.createAttackBall({name="acid-ball", scale=0.5, directionOnly=true, attackType="projectile", tint2={r=0, g=1, b=0.3, a=0.5}, damage=4, damagePerTick=0.1, stickerName="acid-sticker-small", radius=1.2, effectiveLevel=1})
    AttackBall.createAttackBall({name="acid-ball-1", scale=0.65, directionOnly=true, attackType="projectile", tint2={r=0, g=1, b=0.3, a=0.5}, damage=7.5, damagePerTick=0.2, stickerName="acid-sticker-medium", radius=1.3, effectiveLevel=3})

    AttackBall.createAttackBall({name="acid-ball-2-direction", scale=0.85, directionOnly=true, attackType="projectile", tint2={r=0, g=1, b=0.3, a=0.5}, damage=11.25, damagePerTick=0.03, stickerName="acid-sticker-big", radius=1.4, effectiveLevel=5})
    AttackBall.createAttackBall({name="acid-ball-3-direction", scale=1.0, directionOnly=true, attackType="projectile", tint2={r=0, g=1, b=0.3, a=0.5}, damage=15, damagePerTick=0.55, stickerName="acid-sticker-behemoth", radius=1.5, effectiveLevel=7})

    AttackBall.createAttackBall({name="acid-ball-2", scale=0.85,  attackType="projectile", tint2={r=0, g=1, b=0.3, a=0.5}, damage=11.25, damagePerTick=0.2, stickerName="acid-sticker-small", radius=1.4, effectiveLevel=3})
    AttackBall.createAttackBall({name="acid-ball-3", scale=1.0,  attackType="projectile", tint2={r=0, g=1, b=0.3, a=0.5}, damage=15, damagePerTick=0.5, stickerName="acid-sticker-medium", radius=1.5, effectiveLevel=5})
    AttackBall.createAttackBall({name="acid-ball-4", scale=1.2,  attackType="projectile", tint2={r=0, g=1, b=0.3, a=0.5}, damage=22.5, damagePerTick=0.75, stickerName="acid-sticker-big", radius=1.75, effectiveLevel=7})
    AttackBall.createAttackBall({name="acid-ball-5", scale=1.3,  attackType="projectile", tint2={r=0, g=1, b=0.3, a=0.5}, damage=32.5, damagePerTick=1, stickerName="acid-sticker-behemoth", radius=2, effectiveLevel=8})
end

return AttackBall
