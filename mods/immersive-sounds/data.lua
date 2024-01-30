require("prototypes.sound")
require("prototypes.soundslib")

data:extend{
	
	-- KEYBOARD INPUTS

-- NEXT WEAPON

{
  type = "custom-input",
  name = "switch-gun-key",
  key_sequence = "",
  linked_game_control = "next-weapon"
},
{
  type = "custom-input",
  name = "switch-gun-key-tank",
  key_sequence = "",
  linked_game_control = "next-weapon"
},
{
  type = "custom-input",
  name = "switch-gun-key-car",
  key_sequence = "",
  linked_game_control = "next-weapon"
},
{
  type = "custom-input",
  name = "switch-gun-key-spider",
  key_sequence = "",
  linked_game_control = "next-weapon"
},

-- TANK
{
  type = "custom-input",
  name = "tank-moving-key-W",
  key_sequence = "",
  linked_game_control = "move-up"
},
{
  type = "custom-input",
  name = "tank-moving-key-A",
  key_sequence = "",
  linked_game_control = "move-left"
},
{
  type = "custom-input",
  name = "tank-moving-key-S",
  key_sequence = "",
  linked_game_control = "move-down"
},
{
  type = "custom-input",
  name = "tank-moving-key-D",
  key_sequence = "",
  linked_game_control = "move-right"
},

-- CAR
{
  type = "custom-input",
  name = "car-moving-key-W",
  key_sequence = "",
  linked_game_control = "move-up"
},
{
  type = "custom-input",
  name = "car-moving-key-A",
  key_sequence = "",
  linked_game_control = "move-left"
},
{
  type = "custom-input",
  name = "car-moving-key-S",
  key_sequence = "",
  linked_game_control = "move-down"
},
{
  type = "custom-input",
  name = "car-moving-key-D",
  key_sequence = "",
  linked_game_control = "move-right"
},

	-- TANK TRACK ENTITY -- Create tracks noises over the engine sounds. Not used yet in version 1.0
{
    type = "projectile",
    name = "tracks-noise",
	acceleration = 0,
    flags = { "not-on-map" },
	animation = {
      {
	  filename = "__immersive-sounds__/graphics/dummy.png",
      priority = "low",
      width = 32,
      height = 32,
      frame_count = 1,
      line_length = 1,
      animation_speed = 1
	  },
	},
	light = {intensity = 0, size = 0},
    working_sound = {
      apparent_volume = 1.0,
      sound = {
        {
          filename = "__immersive-sounds__/sound/driving/unused/tank-tracks-1.ogg",
          volume = 0.4
        },
		{
          filename = "__immersive-sounds__/sound/driving/unused/tank-tracks-2.ogg",
          volume = 0.4
        },
		{
          filename = "__immersive-sounds__/sound/driving/unused/tank-tracks-3.ogg",
          volume = 0.4
        },
      }
    }
},

	-- WEAPON SELECTIONS -- Not used right now.
	
{
  type = "sound",
  name = "select-cannon",
  variations = {
    {
	  filename = "__immersive-sounds__/sound/ui/select-cannon-1.ogg",
	  volume = 0.3
	},
	{
	  filename = "__immersive-sounds__/sound/ui/select-cannon-2.ogg",
	  volume = 0.3
	},
	{
	  filename = "__immersive-sounds__/sound/ui/select-cannon-3.ogg",
	  volume = 0.3
	}
},
},
{
  type = "sound",
  name = "select-smg",
  variations = {
    {
	  filename = "__immersive-sounds__/sound/ui/select-smg-1.ogg",
	  volume = 0.25
	},
	{
	  filename = "__immersive-sounds__/sound/ui/select-smg-2.ogg",
	  volume = 0.25
	},
	{
	  filename = "__immersive-sounds__/sound/ui/select-smg-3.ogg",
	  volume = 0.25
	}
},
},
{
  type = "sound",
  name = "select-machine-gun",
  variations = {
    {
	  filename = "__immersive-sounds__/sound/ui/select-machine-gun-1.ogg",
	  volume = 0.2
	},
	{
	  filename = "__immersive-sounds__/sound/ui/select-machine-gun-2.ogg",
	  volume = 0.2
	},
	{
	  filename = "__immersive-sounds__/sound/ui/select-machine-gun-3.ogg",
	  volume = 0.2
	}
},
},

	

	
	-- CAR ENGINE LOADS

{
  type = "sound",
  name = "car-engine-loads",
  variations = {
    {
	filename = "__immersive-sounds__/sound/driving/car-engine-load-1.ogg",
	volume = 0.55
    },
	{
	filename = "__immersive-sounds__/sound/driving/car-engine-load-2.ogg",
	volume = 0.55
    },
	{
	filename = "__immersive-sounds__/sound/driving/car-engine-load-3.ogg",
	volume = 0.55
    },
	{
	filename = "__immersive-sounds__/sound/driving/car-engine-load-4.ogg",
	volume = 0.55
    },
},
},
{
  type = "sound",
  name = "car-engine-loads-reverse",
  variations = {
    {
	filename = "__immersive-sounds__/sound/driving/car-engine-load-reverse-1.ogg",
	volume = 0.5
    },
	{
	filename = "__immersive-sounds__/sound/driving/car-engine-load-reverse-2.ogg",
	volume = 0.5
    },
	{
	filename = "__immersive-sounds__/sound/driving/car-engine-load-reverse-3.ogg",
	volume = 0.5
    },
	{
	filename = "__immersive-sounds__/sound/driving/car-engine-load-reverse-4.ogg",
	volume = 0.5
    },
  },
},
{
  type = "sound",
  name = "car-steering",
  variations = {
    {
	filename = "__immersive-sounds__/sound/driving/car-steer-1.ogg",
	volume = 0.4
    },
	{
	filename = "__immersive-sounds__/sound/driving/car-steer-2.ogg",
	volume = 0.4
    },
	{
	filename = "__immersive-sounds__/sound/driving/car-steer-3.ogg",
	volume = 0.4
    },
	{
	filename = "__immersive-sounds__/sound/driving/car-steer-4.ogg",
	volume = 0.4
    },
}
},


	-- TANK ENGINE LOADS
{
  type = "sound",
  name = "tank-engine-loads",
  variations = {
    {
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-1.ogg",
	volume = 0.5
    },
	{
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-2.ogg",
	volume = 0.5
    },
	{
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-3.ogg",
	volume = 0.5
    },
	{
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-4.ogg",
	volume = 0.5
    },
},
},
{
  type = "sound",
  name = "tank-engine-loads-reverse",
  variations = {
    {
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-reverse-1.ogg",
	volume = 0.3
    },
	{
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-reverse-2.ogg",
	volume = 0.3
    },
	{
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-reverse-3.ogg",
	volume = 0.3
    },
	{
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-reverse-4.ogg",
	volume = 0.3
    },
  },
},
{
  type = "sound",
  name = "tank-engine-loads-rotation",
  variations = {
    {
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-rotation-1.ogg",
	volume = 0.4
    },
	{
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-rotation-2.ogg",
	volume = 0.4
    },
	{
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-rotation-3.ogg",
	volume = 0.4
    },
	{
	filename = "__immersive-sounds__/sound/driving/tank-engine-load-rotation-4.ogg",
	volume = 0.4
    },
}	
}
}

       

