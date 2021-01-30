--Always set to false before uploading a release!
DEBUG=false

SHIELD_STEPS_NORMAL = 9
SHIELD_STEPS_LONG = 13

SHIELD_VALUE_ON_PREVIOUS_TICK=2 --in energy units, not shield HP!
HP_BAR=3
ORIENTATION=4
SHIELD_EFFECT_ENTITY=5
SHIELD_VALUE_ON_LAST_TICK=6
ELECTRIC_GRID_INTERFACE=7
TURRET_ENTITY=8
DMG_SINCE_LAST_TICK=9

--Number of ticks before a broken shield is allowed to absorb damage again.
--Used to allow damage to pass through to the entity underneath when a shield breaks.
SHIELD_BROKEN_REGEN_TIME = 10
ENERGY_PER_DMG_POINT = 1000 --1 dmg absorbed = 1 kj energy needed to absorb

GFX_NORMAL_HEIGHT=40
GFX_NORMAL_WIDTH=260

GFX_LIQUID_HEIGHT=40
GFX_LIQUID_WIDTH=388