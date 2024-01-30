remote.add_interface(
    "blueprint-sandboxes",
    {
        space_exploration_delete_surface = function(event)
            local surface = game.surfaces[event.surface_index]
            if SpaceExploration.IsSandbox(surface) then
                return {
                    allow_delete = false,
                    message = {"bpsb-messages.space-exploration-delete-sandbox"},
                }
            end
        end,
    }
)
