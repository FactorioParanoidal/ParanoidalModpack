# Additional documentation and manual

## Station colors

* Green - Normal Operation
* Yellow - Pending delivery operation. Station is either requester or provider.
* Blue - Train is parked at the stop.
* White - Station is not initialized.
* Red - Station is in error state.
* Cyan - Station is a refuel station.

All station colors can be read on the circuit network by connecting a green wire to the station lamp:

* Virtual Signal "green" - 1 - Normal Operation
* Virtual Signal "yellow" - n - Pending delivery operation. n is the number of trains using this stop.
* Virtual Signal "blue" - n - Train parked at the stop. n is the number of trains
* Virtual Signal "white" - Train stop is not initialized (error)
* Virtual Signal "red" - 1 - "short circuit", input (lamp), output (combinator) or the train stop connector are connected to each other
* Virtual Signal "red" - 2 - "disabled". The train stop has been disabled (e.g. through a circuit condition).
* Virtual Signal "cyan" - Train stop is a refuel station.

When using a single combinator for multiple stations (e.g. for a depot), the combinator should connect to the train stop inputs (lamps) using the *red* wire connection. This ensures that the different station lamps function correctly. When using a green wire, the virtual signals will be sent from one stop to the other and the lamps will not show the correct state. The stations will continue to function correctly, only the lamp color will be incorrect.
