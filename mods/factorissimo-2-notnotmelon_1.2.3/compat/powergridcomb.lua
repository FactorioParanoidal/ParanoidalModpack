local our_poles = {'factory-circuit-connector', 'factory-overflow-pole', 'factory-power-connection', 'factory-power-pole'}
data.raw['selection-tool']['power-grid-comb'].entity_filters = our_poles
data.raw['selection-tool']['power-grid-comb'].alt_entity_filters = our_poles
data.raw['selection-tool']['power-grid-comb'].entity_filter_mode = 'blacklist'
data.raw['selection-tool']['power-grid-comb'].alt_entity_filter_mode = 'blacklist'
