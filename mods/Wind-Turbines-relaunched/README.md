[![](https://img.shields.io/factorio-mod-portal/factorio-version/Wind-Turbines-relaunched?label=factorio%20version&style=for-the-badge)](https://mods.factorio.com/mod/Wind-Turbines-relaunched) [![](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2FWind-Turbines-relaunched&style=for-the-badge)](https://mods.factorio.com/mod/Wind-Turbines-relaunched/downloads) [![](https://img.shields.io/factorio-mod-portal/v/Wind-Turbines-relaunched?style=for-the-badge&color=aqua)](https://mods.factorio.com/mod/Wind-Turbines-relaunched/changelog)

[![](https://img.shields.io/github/issues/xyzzycgn/Wind-Turbines-relaunched?label=Bug%20Reports&style=for-the-badge)](https://github.com/xyzzycgn/Wind-Turbines-relaunched/issues) [![](https://img.shields.io/github/issues-pr/xyzzycgn/Wind-Turbines-relaunched?label=Pull%20Requests&style=for-the-badge)](https://github.com/xyzzycgn/Wind-Turbines-relaunched/pulls) [![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/xyzzycgn/Wind-Turbines-relaunched/busted.yml?style=for-the-badge&label=tests)]()

# Wind Turbines relaunched
## Features
Wind Turbines produce free energy, but are expensive to build and don't have a steady output.
This mod adds 4 tiers of turbines, from a small wooden windmill to a giant steel and refined concrete turbine.

![wind turbines](https://github.com/xyzzycgn/Wind-Turbines-relaunched/blob/main/turbines.jpg?raw=true)
- Alternative/complement to solar panel arrays, similar large upfront cost but free energy after
- The higher tier versions save a lot of space compared to solar panel arrays
- You can walk around the base tower, but you cannot build there to avoid objects getting hidden behind the 
  large graphics (depends on settings)

## Configuration options
There are several options you can use to configure behaviour of this mod.
- Wind strength factor  
  Multiplier for energy production. Allowed range is 1 - 10, defaults to 1.

- Enable the Giant turbine  
  Allows disabling the Giant wind turbine for low-end computers where the large graphics might cause problems. 
  Giant wind turbine is enabled by default.

- Determination of wind strength (since version 2.1.1, extended from 2.1.0)  
  Here you can choose how this mod calculates the wind strength (and thus the energy yield). There are three different modes:
  - _classical_  
    Use of the original (periodic) function with identical values of wind strength on all surfaces
  - _surface_  
    Uses wind strength determined by the surface (individual for each surface) changing in a more random based manner
  - _surface + pressure_ (since version 2.1.1)  
    Wind strength is determined like in mode _surface_, but additionally the energy yield is influenced by atmospheric 
    pressure of the planet/moon (increases at higher pressure and decreases at lower pressure). The change is based on 
    the ratio of air pressure compared to nauvis. This is the default. If mod 
    [Space Exploration](https://mods.factorio.com/mod/space-exploration) is loaded, this option is **not available** 
    (_surface_ becomes default), because Space Exploration lacks the necessary information about planetary pressures.

- Wind turbines take up more space (since version 2.1.0)    
  If enabled, the space behind the wind turbines is reserved so that nothing can be built there (classical behaviour, 
  **disabled** by default).

- higher construction costs (since version 2.2.1)
  If enabled, construction of turbines requires more resources (**disabled** by default)


## Quality
Quality (introduced by SPA) is supported. The different quality tiers offer increased health and energy output.
Increase of energy output is analogous to that of a solar panel.

## Supported locales
As of version 2.0.1 several locales are supported. Currently these are:
- čeština (cs)
- deutsch (de)
- ελληνικά (el)
- english (en) – default
- español (es-ES)
- suomi (fi)
- français (fr)
- magyar (hu)
- italiano (it)
- 日本語 (ja)
- 한국인 (ko)
- nederlands (nl)
- norsk (no)
- polski (pl)
- português (pt-BR)
- русский (ru)
- svenska (sv-SE)
- türkçe (tr)
- українська (uk)
- 简体中文 (zh-CN)
- 繁體中文 (zh-TW)

## Contributors
- Onseshigo: adjustments in locale ru
- Yottagarasu: Thx for fixing the issues #43 + #44

----
## Relaunch of Wind Turbines from wavtrex with the necessary patches for V 2.0 of factorio.
This mod is intended as an inplace replacement for [Wind_Generator-gfxrestyle](https://mods.factorio.com/mod/Wind_Generator-gfxrestyle) 
which is no longer compatible with V 2.0 of factorio.
