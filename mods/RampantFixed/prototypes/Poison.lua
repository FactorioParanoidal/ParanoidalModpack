-- imports

local smokeUtils = require("utils/SmokeUtils")

-- constants

local poison = {}

-- imported functions

local makeCloud = smokeUtils.makeCloud

function poison.addFactionAddon(deathCloudNumeric)

    for i=1,10 do
		local cooldown = 20
		local damage = (cooldown/60)*deathCloudNumeric["dps"][i]		-- ["dps"] = {12, 24, 36, 48, 60, 72, 84, 96, 108, 120 } if maxlvl=10 (at 2021.12)
		local healing = -1*(cooldown/60)*deathCloudNumeric["hps"][i]	-- ["hps"] = {24, 48, 72, 96, 120, 144, 168, 192, 216, 240}
        makeCloud(
            {
                name = "poison-cloud-v" .. i,
                scale = 0.80 + (i * 0.15),
                wind = false,			--true,
                slowdown = -1.3,
                duration = deathCloudNumeric["duration"][i],		--10 * (i * 5),
                cooldown = cooldown									--5
            },
            {
                type = "direct",
                action_delivery =
                    {
                        type = "instant",
                        target_effects =
                            {
                                type = "nested-result",
                                action =
                                    {
                                        {
                                            type = "area",
                                            radius = deathCloudNumeric["radius"][i],		--2 + (i * 0.5),
                                            force = "ally",
                                            entity_flags = {"placeable-enemy"},
                                            action_delivery =
                                                {
                                                    type = "instant",
                                                    target_effects =
                                                        {
                                                            type = "damage",
                                                            damage = {amount = healing				--	-2 * i
																, type = "healing"}
                                                        }
                                                }
                                        },
                                        {
                                            type = "area",
                                            radius = deathCloudNumeric["radius"][i],		--2 + (i * 0.5),
                                            force = "not-same",
                                            action_delivery =
                                                {
                                                    type = "instant",
                                                    target_effects =
                                                        {
                                                            type = "damage",
                                                            damage = {amount = damage			--0.9 * i
																, type = "poison"}
                                                        }
                                                }
                                        }
                                    }
                            }
                    }
            }
        )
    end

end

function poison.createAttackPoisonClouds(poisonAttacksNumeric)
	local attackCooldown = 20
    for i=1,10 do
 
		makeCloud(
			{
				name = "poison-cloud-Dmg-Heal"..i,
	--                scale = 1,
				tint = { r = 0.2, g = 0.8, b = 0.5, a = 0.05},
				render_layer = "floor",
				wind = true,
				slowdown = -1.3,
				duration = 120,
				cooldown = attackCooldown
			},
			{
				type = "direct",
				action_delivery =
					{
						type = "instant",
						target_effects =
							{
								type = "nested-result",
								action =
									{
										{
											type = "area",
											radius = poisonAttacksNumeric["radius"][i],
											force = "ally",
											entity_flags = {"placeable-enemy"},
											action_delivery =
												{
													type = "instant",
													target_effects =
														{
															type = "damage",
															damage = { amount = -1*(attackCooldown/60)*poisonAttacksNumeric["hps"][i], type = "healing"}
														}
												}
										},
										{
											type = "area",
											radius = poisonAttacksNumeric["radius"][i],
											force = "not-same",
											action_delivery =
												{
													type = "instant",
													target_effects =
														{
															type = "damage",
															show_in_tooltip = true, 
															damage = {amount = (attackCooldown/60)*poisonAttacksNumeric["dps"][i], type = "poison"}
														}
												}
										}
									}
							}
					}
			}
		)
	end	
end

function poison.createFireClouds(fireCloudNumeric)
	local attackCooldown = 12
    for i=1,10 do
 
		makeCloud(
			{
				name = "fire-cloud-Dmg"..i,
	            scale = fireCloudNumeric["radius"][i]*0.5,
				tint = { r = 0.8, g = 0.5, b = 0.2, a = 0.05},
				wind = false,
				slowdown = -1.3,
				duration = 600,
				cooldown = attackCooldown
			},
			{
				type = "direct",
				action_delivery =
					{
						type = "instant",
						target_effects =
							{
								type = "nested-result",
								action =
									{
										{
											type = "area",
											radius = fireCloudNumeric["radius"][i],
											force = "not-same",
											action_delivery =
												{
													type = "instant",
													target_effects =
														{
															type = "damage",
															show_in_tooltip = true, 
															damage = {amount = (attackCooldown/60)*fireCloudNumeric["dps"][i], type = "fire"}
														}
												}
										}
									}
							}
					}
			}
		)
	end	
end

-- -----------------------
-- function poison.createPoisonProjectile()
  -- {
    -- type = "projectile",
    -- name = "poison-Projectile",
    -- flags = {"not-on-map"},
    -- acceleration = 0.005,
    -- action =
    -- {
      -- {
        -- type = "direct",
        -- action_delivery =
        -- {
          -- type = "instant",
          -- target_effects =
          -- {
            -- {
              -- type = "create-smoke",
              -- show_in_tooltip = true,
              -- entity_name = "poison-cloud",
              -- initial_height = 0
            -- },
            -- {
              -- type = "create-particle",
              -- particle_name = "poison-capsule-metal-particle",
              -- repeat_count = 8,
              -- initial_height = 1,
              -- initial_vertical_speed = 0.1,
              -- initial_vertical_speed_deviation = 0.05,
              -- offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
              -- speed_from_center = 0.05,
              -- speed_from_center_deviation = 0.01
            -- }
          -- }
        -- }
      -- }
    -- },
-- end	
 ------------------------

return poison
