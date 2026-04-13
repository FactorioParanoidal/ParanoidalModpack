game.simulation.camera_position = { 0, 0.5 }
game.simulation.camera_alt_info = true
game.surfaces[1].create_entities_from_blueprint_string({
  string = "0eNq9ltuSmzAMht/F17Bjc3ZepdPJGFCop8QwtuluNsO7VySbBFKzcXJR7gzSJ8nSb3wkZTtAr6WyZHMksuqUIZsfR2Jko0Q7vVNiD2RDrBbK9J22YQmtJWNApKrhg2zYGDjM66GyodmLtp2ZRuPPgICy0ko4hzktDls17EvQyAou/lLtpMJPYS97IAHpO4NenZpCIIkz9pYG5IAu/C0dpxTuUNEVNRFC24WN7gZVf8eKqJsV+6ZVFPyCShEVXO23BqyVqjGzLXoXFuHIAF1hQNHAaQMs7PGNsIOe1kjbd/VkLmzYgjC49Y4ME+9qC06XKdZSQ3U2YJEDnT6BTlfRiYOcLcguXjbnOQh5MJ83F6E4+2ePsykWrLDtVOOYFcq8gdwPmHoDGV0SsQmgV6eaukt39pixV9RS3De5cKGjB12eAVekzG76gxZjaVmFoLD0Q4jnFuidqJzcrw3ArEg57Hagt0Z+TqKi18cVLXle7TH9r2pn6Qty/8rx4ShkL+j9X7ZzfnNvwccrJzG7Uyn2X/yGdeHHzCMt/ozyfYgRfUb6XkTmR+T+xGhJhI9fYjDWpaPIH3pTqhlKY8XJdFWaMXX+uRMvSMHzM6RwQtJXzoyC8wtzWes3JwheaSSqGAPdrlIB+QPanFzTLOIJ52kS0TxPsnH8C3FjERM=",
  position = { 0, 1 },
})

for _, duct in
  pairs(game.surfaces[1].find_entities_filtered({
    area = { left_top = { x = -7, y = 0 }, right_bottom = { x = 7, y = 4 } },
    name = "duct-long",
  }))
do
  local fluidbox = duct.fluidbox
  local capacity = fluidbox.get_capacity(1)
  fluidbox[1] = { name = "water", amount = capacity * 0.5 }
end
