Forked from RealisticReactors due to bugs.

#### Migration from RealisticReactors

Migration from RealisticReactors is partially supported. Reactors and cooling towers should work, however intermediate states (starting or stopping) may not work as expected.

#### Original description

We introduce a nuclear reactor, a breeder reactor and a cooling tower. The nuclear reactor type has high power output while the breeder reactor type has medium power output and produces bonus materials. The thermal energy output of both reactor types as well as fuel efficiencies are dynamic and depend on operational temperature. The reactors have to be controlled with signals through the integrated circuit interface and depend on the cooling infrastructure through the Emergency Core Cooling System (ECCS) interface. Without cooling the reactor core will finally overheat and cause a meltdown. Cooling towers are designed to cool down hot water or steam coming from the ECCS or other parts of the plant. Physical layout of the power plant also plays a significant role. 


# Reactor operation
---------------------------------------------------------------------------------------------------------------------------------------------
#### Starting and stopping
To start a nuclear reactor insert fuel cells and send the ``Start Control Signal`` to the circuit interface of the reactor. The reactor will start up and produce heat at a certain efficiency (see the two corresponding signals on the circuit interface).
To shut down the reactor either let it run out of fuel cells or send the ``SCRAM Control Signal`` to the reactor circuit interface.
Be aware that the SCRAM process takes some time and the reactor will still produce heat until it is fully stopped.

#### The point of maximum output and efficiency
Power output and fuel efficiency are changing dynamically depending on the reactor core temperature and the number of connected neighbor reactors. Additionally, the output of extra empty fuel cells of the breeder reactor type changes according to the temperature. To connect a reactor neighbor simply connect them with heat-pipes into one heat network. The reactors don't have to touch each other.

There are two possible options how output and efficiency are calculated, which can be changed in the settings.
By default **Ownly's formulas** will be used. In short this means: the hotter, the better. The higher the reactor core temperature is, the higher power output and fuel efficiency will be. 
The alternative **Ingo's formulas** work a little different. Power output will also increase with higher core temperature, but efficiency will have a certain maximum, after which it will start to drop quickly again.

#### Reactor core meltdown
When the reactor core reaches 1000°C a reactor core meltdown is caused. The reactor explodes and leaves a ruin behind. That ruin  produces permanent radiation around and generates radioactive clouds. These clouds pollute large areas around the reactor ruin. The radiation effect is damage to all lifeforms in proximity. To stop the radiation spreading, a sarcophagus must be built over the reactor ruin, then the radiation will slowly decay.


# Supported languages
---------------------------------------------------------------------------------------------------------------------------------------------
* English
* German
* Russian
* Korean

# Supported mods
---------------------------------------------------------------------------------------------------------------------------------------------
* [GotLag's Nuclear Fuel](https://mods.factorio.com/mod/Nuclear%20Fuel)
* [JohnTheCoolingFan's Plutonium Energy](https://mods.factorio.com/mod/PlutoniumEnergy)
* [MadClown01's Nuclear Extension](https://mods.factorio.com/mod/Clowns-Nuclear)
* [BicycleEater's True Nukes](https://mods.factorio.com/mod/True-Nukes)
* [Nuclear Operators Utilities](https://mods.factorio.com/mod/Nuclear_Operators_Utilities)
* [Realistic Heat Glow](https://mods.factorio.com/mod/Realistic_Heat_Glow)


# Compatibility
---------------------------------------------------------------------------------------------------------------------------------------------
* limited compatibility with mods which modify the connections or sizes of heat-pipe entities (e.g. [Schall Pipe Scaling](https://mods.factorio.com/mod/SchallPipeScaling) and similar) – when using such mods with Unrealistic Reactors please make sure the vanilla heat-pipes are used for the reactor heat-pipe network
* blueprints made with RealisticReactors before version 3.0.0 need to be updated due to fixes in the reactor's combinator network interface
* please report on our mod discussion page if any incompatibilities are discovered


# Included materials
---------------------------------------------------------------------------------------------------------------------------------------------
* geiger counter sounds based on the [work by Mike Koenig](http://soundbible.com/1113-Radio-Active.html), under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)
* reactor sarcophagus graphic based on the [design by Anthony Garcellano](https://www.artstation.com/artwork/nbPvO)
* see the included license.txt file


# License
---------------------------------------------------------------------------------------------------------------------------------------------
This mod was made by [dodo.the.last](https://mods.factorio.com/user/dodo.the.last), [max2344](https://mods.factorio.com/user/max2344),  [IngoKnieto](https://mods.factorio.com/user/ingo), [OwnlyMe](https://mods.factorio.com/user/OwnlyMe) and published under the MIT license.


# Credits
---------------------------------------------------------------------------------------------------------------------------------------------
Original idea and implementation by [IngoKnieto](https://mods.factorio.com/user/IngoKnieto) and [OwnlyMe](https://mods.factorio.com/user/OwnlyMe).
Thanks to [GotLag](https://mods.factorio.com/mods/GotLag) for the [original reactors mod](https://mods.factorio.com/mods/GotLag/Reactors), which this mod is based upon.
Thanks to [Sigma1](https://mods.factorio.com/user/Sigma1) for making the awesome cooling tower picture.
The refactored version 3 was made by [dodo.the.last](https://mods.factorio.com/user/dodo.the.last) and [max2344](https://mods.factorio.com/user/max2344) who are currently maintaining the mod.
The Korean translation was made by [x2605](https://mods.factorio.com/user/x2605).

# Notes
---------------------------------------------------------------------------------------------------------------------------------------------
The information on this mod page represents the state of the current release and might be updated without prior notification or public announcement. Please refer to the «Documentation» section of this page for details.


# FAQ
---------------------------------------------------------------------------------------------------------------------------------------------

# Found a bug, issue or a missing feature?
---------------------------------------------------------------------------------------------------------------------------------------------
Please report bugs or issues to the [issue tracker](https://github.com/numberZero/factorio-unrealistic-reactors/issues).


# Why are blueprints placed with missing combinator network connections?
---------------------------------------------------------------------------------------------------------------------------------------------
Blueprints made with RealisticReactors before version 3.0.0 need to be updated due to fixes in the reactor's combinator network interface. When using blueprints or copy/paste in the game editor, the combinator connections aren't placed and need to be added manually, probably because not all events are sent in the editor.


# How to operate a reactor?
---------------------------------------------------------------------------------------------------------------------------------------------
To start a nuclear reactor insert fuel cells and send the ``Start Control Signal`` to the circuit interface of the reactor. The reactor will start up and produce heat at a certain efficiency (see the two corresponding signals on the circuit interface).
To shut down the reactor either let it run out of fuel cells or send the ``SCRAM Control Signal`` to the reactor circuit interface.
Be aware that the SCRAM process takes some time and the reactor will still produce heat until it is fully stopped.

# What is the point of maximum output and efficiency?
---------------------------------------------------------------------------------------------------------------------------------------------
Power output and fuel efficiency are changing dynamically depending on the reactor core temperature and the number of connected neighbor reactors. Additionally, the output of extra empty fuel cells of the breeder reactor type changes according to the temperature. To connect a reactor neighbor simply connect them with heat-pipes into one heat network. The reactors don't have to touch each other.

There are two possible options how output and efficiency are calculated, which can be changed in the settings.
By default **Ownly's formulas** will be used. In short this means: the hotter, the better. The higher the reactor core temperature is, the higher power output and fuel efficiency will be. 
The alternative **Ingo's formulas** work a little different. Power output will also increase with higher core temperature, but efficiency will have a certain maximum, after which it will start to drop quickly again.


# What is a reactor core meltdown?
---------------------------------------------------------------------------------------------------------------------------------------------
When the reactor core reaches 1000°C a reactor core meltdown is caused. The reactor explodes and leaves a ruin behind. That ruin  produces permanent radiation around and generates radioactive clouds. These clouds pollute large areas around the reactor ruin. The radiation effect is damage to all lifeforms in proximity. To stop the radiation spreading, a sarcophagus must be built over the reactor ruin, then the radiation will slowly decay.
