local Public = {}

function Public.dummy_fluidbox(production_type,flow_direction,linked_connection_id) --Dummy fluidbox to occupy a fluidbox index.
    return {
        volume = 0.5^24, --The smallest possible fluidbox value.
        production_type = production_type,
        pipe_connections = {
            
            {
                flow_direction = flow_direction,
                connection_type = "linked",
                hide_connection_info = true,
                linked_connection_id=linked_connection_id
            },
            
        }
    }

end

return Public