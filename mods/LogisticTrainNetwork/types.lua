---@meta

---------------------------------------------------------
--- LTN data types
---------------------------------------------------------

--- storage layout
---@class ltn.Storage
---@field tick_state            ltn.TickState
---@field tick_interval_start   integer
---@field tick_stop_index       integer?
---@field Dispatcher            ltn.Dispatcher
---@field LogisticTrainStops    table<integer, ltn.TrainStop>
---@field ConnectedSurfaces     table<ltn.EntityPairKey, table<ltn.EntityPairKey, ltn.SurfaceConnection>>
---@field StoppedTrains         table<integer, ltn.StoppedTrain>
---@field StopDistances         table<string, ltn.StopDistance>
---@field WagonCapacity         table<string, number>
---@field FuelStations          ltn.TrainStop[][]
---@field Depots                ltn.TrainStop[][]

---------------------------------------------------------
--- Type aliases
---------------------------------------------------------

--- A shipment, consisting of comma-separated description strings and an amount.
---@alias ltn.Shipment table<ltn.ItemIdentifier, number>

--- typed string for the item identifiers
---@alias ltn.ItemIdentifier string

--- typed string for surface connection identifier
---@alias ltn.EntityPairKey string

---@alias ltn.LoadingList ltn.LoadingElement[]

---@alias ltn.AlertType ('cargo-warning'|'cargo-alert'|'depot-warning'|'depot-empty')

---@alias ltn.ItemFluid ('item'|'fluid')

---@alias ltn.InventoryType table<string, ItemWithQualityCount>
---@alias ltn.FluidInventoryType table<string, number>

---------------------------------------------------------
--- Main types
---------------------------------------------------------

--- The event dispatcher.
---@class ltn.Dispatcher
---@field availableTrains                      table<integer, ltn.Train>
---@field availableTrains_total_capacity       number
---@field availableTrains_total_fluid_capacity number
---@field Provided                             table<ltn.ItemIdentifier, table<integer, integer>> -- request-type -> stop id -> count
---@field Provided_by_Stop                     table<integer, ltn.Shipment> -- stop id -> request-type -> count
---@field Requests                             ltn.Request[]
---@field Requests_by_Stop                     table<integer, ltn.Shipment>
---@field RequestAge                           table<string, integer>
---@field Deliveries                           table<integer, ltn.Delivery>
---@field new_Deliveries                       integer[]
---@field knownTrains                          table<integer, ltn.KnownTrain>

--- LTN stop information
---@class ltn.TrainStop
---@field active_deliveries           integer[]   List of train ids that are either requesting or providing to this stop
---@field entity                      LuaEntity  The Train stop entity itself
---@field input                       LuaEntity  The Lamp entity (input) of the Train stop
---@field output                      LuaEntity  The combinator entity (output) of the Train stop
---@field lamp_control                LuaEntity  Hidden combinator that controls the input lamp
---@field error_code                  integer     Current error state of the stop
---@field is_depot                    boolean    True if the stop is a depot
---@field is_fuel_station             boolean    True if the stop is a fuel station
---@field depot_priority              integer     Depot priority value
---@field network_id                  integer     Encoded network id for the stop
---@field min_carriages               integer     minimum train length for this stop
---@field max_carriages               integer     maximum train length for this stop
---@field max_trains                  integer     maximum number of trains allowed to this stop
---@field providing_threshold         number     Provider threshold value (items and fluids)
---@field providing_threshold_stacks  integer     Provider stack threshold value (for items only)
---@field provider_priority           integer     Provider priority value
---@field requesting_threshold        number     Requester threshold value (items and fluids)
---@field requesting_threshold_stacks integer     Requester stack threshold value (for items only)
---@field requester_priority          integer     Requester priority value
---@field locked_slots                integer     Locked slots per wagon for this stop
---@field no_warnings                 boolean    If true, warnings are disabled for this stop
---@field parked_train                LuaTrain?  The currently parked train at this stop
---@field parked_train_id             integer?    The train id of the currently parked train
---@field parked_train_faces_stop     boolean?   True if the train faces the stop, false otherwise
---@field fuel_signals                (CircuitCondition[])? Fuel Signals for a fuel station, used to create refuel interrupt condition

--- LTN Train information
---@class ltn.Train
---@field train             LuaTrain
---@field force             LuaForce
---@field capacity          number
---@field fluid_capacity    number
---@field surface           LuaSurface
---@field depot_priority    integer
---@field network_id        integer
---@field select_count      integer     How often the train was selected for a delivery

--- LTN Train memory
---@class ltn.KnownTrain
---@field train             LuaTrain
---@field select_count      integer?    How often the train was selected for a delivery
---@field invalid_tick      integer?


--- LTN Train information
---@class ltn.StoppedTrain
---@field train             LuaTrain
---@field name              string?
---@field force             LuaForce?
---@field stopID            integer

--- A request for a shipment.
---@class ltn.Request
---@field age               integer
---@field stopID            integer
---@field priority          integer
---@field item              ltn.ItemIdentifier
---@field count             integer

--- A scheduled delivery
---@class ltn.Delivery
---@field force                LuaForce
---@field train                LuaTrain
---@field from                 string
---@field from_id              integer
---@field to                   string
---@field to_id                integer
---@field network_id           integer
---@field started              integer
---@field surface_connections  ltn.SurfaceConnection[]
---@field shipment             ltn.Shipment
---@field pickupDone           boolean?

---@class ltn.LoadingElement
---@field type             ltn.ItemFluid 'item' or 'fluid'
---@field name             string        Item or fluid name
---@field quality          string?       *Since 2.1.0* Requested quality. If missing, 'normal' quality was requested
---@field localname        string        Localized name
---@field count            integer       number of elements
---@field stacks           integer       stack size for items


---@class ltn.SurfaceConnection
---@field entity1    LuaEntity
---@field entity2    LuaEntity
---@field network_id integer

---@class ltn.StopDistance
---@field distance number
---@field tick integer

---------------------------------------------------------
--- Internal types used in various methods
---------------------------------------------------------

---@class ltn.Provider
---@field stop                        ltn.TrainStop
---@field network_id                  integer
---@field priority                    integer
---@field activeDeliveryCount         integer
---@field item                        ltn.ItemIdentifier
---@field count                       integer
---@field providing_threshold         number
---@field providing_threshold_stacks  integer
---@field min_carriages               integer
---@field max_carriages               integer
---@field locked_slots                integer
---@field surface_connections         ltn.SurfaceConnection[]
---@field surface_connections_count   integer

---@class ltn.FreeTrain
---@field train                 LuaTrain
---@field surface               LuaSurface
---@field inventory_size        integer
---@field depot_priority        integer
---@field provider_distance     number?
---@field surface_connections   (ltn.SurfaceConnection[])?
---@field select_count          integer

---@class ltn.ItemLoadingElement
---@field item      SignalID
---@field localname string   Localized name
---@field count     integer  number of elements
---@field stacks    integer  stack size for items

---@class ltn.SignalState
---@field is_depot                    boolean
---@field is_fuel_station             boolean
---@field depot_priority              integer
---@field network_id                  integer
---@field min_carriages               integer
---@field max_carriages               integer
---@field max_trains                  integer
---@field requesting_threshold        number
---@field requesting_threshold_stacks integer
---@field requester_priority          integer
---@field no_warnings                 boolean
---@field providing_threshold         number
---@field providing_threshold_stacks  integer
---@field provider_priority           integer
---@field locked_slots                integer

---------------------------------------------------------
--- Event payloads
---------------------------------------------------------

---@class ltn.EventData.on_stops_updated
---@field logistic_train_stops  table<integer, ltn.TrainStop> All train stops known to LTN

---@class ltn.EventData.on_dispatcher_updated
---@field update_interval       integer time in ticks LTN needed to run all updates, varies depending on number of stops and requests
---@field provided_by_stop      table<integer, ltn.Shipment>
---@field requests_by_stop      table<integer, ltn.Shipment>
---@field new_deliveries        integer[]
---@field deliveries            table<integer, ltn.Delivery>
---@field available_trains      table<integer, ltn.Train>

---@alias ltn.EventData.no_train_found (ltn.EventData.no_train_found_item|ltn.EventData.no_train_found_shipment)

---@class ltn.EventData.no_train_found_item
---@field to               string? Target stop
---@field to_id            integer  Target stop id
---@field network_id       integer  Network id
---@field item             ltn.ItemIdentifier? The item to deliver

---@class ltn.EventData.no_train_found_shipment
---@field from             string?          Source stop
---@field from_id          integer?          Source stop id
---@field to               string?          Target stop
---@field to_id            integer           Target stop id
---@field network_id       integer           Network id
---@field min_carriages    integer?          Minimum train length
---@field max_carriages    integer?          Maximum train length
---@field shipment         ltn.LoadingList? The loading list to deliver

---@class ltn.EventData.delivery_pickup_complete
---@field train            LuaTrain
---@field train_id         integer
---@field planned_shipment ltn.Shipment
---@field actual_shipment  ltn.Shipment

---@class ltn.EventData.delivery_complete
---@field train            LuaTrain
---@field train_id         integer
---@field shipment         ltn.Shipment

---@class ltn.EventData.on_delivery_failed
---@field train_id         integer        The Train Id that failed the delivery
---@field shipment         ltn.Shipment  The failed shipment

--- Event raised when a delivery is reassigned from one train to another
---@class ltn.EventData.on_delivery_reassigned
---@field old_train_id     integer         Old train id
---@field new_train_id     integer         New train id
---@field shipment         ltn.Shipment   The shipment which got moved

---@class ltn.EventData.provider_missing_cargo
---@field train            LuaTrain
---@field station          LuaEntity
---@field planned_shipment ltn.Shipment
---@field actual_shipment  ltn.Shipment

---@class ltn.EventData.unscheduled_cargo
---@field train             LuaTrain
---@field station           LuaEntity
---@field planned_shipment  ltn.Shipment
---@field unscheduled_load  ltn.Shipment

---@class ltn.EventData.requester_remaining_cargo
---@field train           LuaTrain
---@field station         LuaEntity
---@field remaining_load  ltn.Shipment
