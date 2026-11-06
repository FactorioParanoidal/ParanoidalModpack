-- Alarm sounds of Premium BnL: the programmable speaker sounds of the game, used by the data stage
-- (sound prototypes pointing at the same files) and by the control stage (list, names, repeat).
-- every: seconds between repeats while the alarm rings, at least the length of the sound file.
-- The names come from the game locale of the speaker, section programmable-speaker-note.
return {
	{id = "alarm-1", file = "__base__/sound/programmable-speaker/alarm-1.ogg", every = 1},
	{id = "alarm-2", file = "__base__/sound/programmable-speaker/alarm-2.ogg", every = 1},
	{id = "buzzer-1", file = "__base__/sound/programmable-speaker/buzzer-1.ogg", every = 1},
	{id = "buzzer-2", file = "__base__/sound/programmable-speaker/buzzer-2.ogg", every = 1},
	{id = "buzzer-3", file = "__base__/sound/programmable-speaker/buzzer-3.ogg", every = 1},
	{id = "ring", file = "__base__/sound/programmable-speaker/ring.ogg", every = 4},
	{id = "siren", file = "__base__/sound/programmable-speaker/siren.ogg", every = 17},
	{id = "achievement-unlocked", file = "__core__/sound/achievement-unlocked.ogg", every = 5},
	{id = "alert-destroyed", file = "__core__/sound/alert-destroyed.ogg", every = 1},
	{id = "new-objective", file = "__core__/sound/new-objective.ogg", every = 3},
	{id = "research-completed", file = "__core__/sound/research-completed.ogg", every = 4},
	{id = "game-won", file = "__core__/sound/game-won.ogg", every = 7},
	{id = "game-lost", file = "__core__/sound/game-lost.ogg", every = 7},
}
