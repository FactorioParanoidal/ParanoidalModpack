my_light_custom = true -- if true, personal lights are changed according to the following parameters. If false, nothing is changed.

my_light_minimum_darkness = 0.2  -- darkness level when the personal lights are switched on (originally 0.3)

my_light_intensity = 0.7 -- intensity of the overall personal light (originally 0.4)
my_light_size = 100 -- size/radius of the overall personal light (originally 25)
my_light_cone_intensity = 0.8 -- intensity of the personal light cone (originally 0.6)

-- if on the contrary, you want more darkness, please try :

--my_light_intensity = 0.3 -- intensity of the overall personal light (originally 0.4)
--my_light_size = 8 -- size/radius of the overall personal light (originally 25)
--my_light_cone_intensity = 0.6 -- intensity of the personal light cone (originally 0.6)

my_light_locomotive_still = false -- loco lights does not depend on the player ridding it on not.
                                  -- so by default, when you enter a still locomotive, your personal lights are off 
								  -- and there is not much light around, until the locomotive moves forward.
                                  -- so if you choose "true", there will always be a light around a still loco.

my_light_bright = true -- set this to false if you want a dimmer gfx model of the lamp, less bright for some users...