PClib_log("Entered file " .. debug.getinfo(1).source)

return function(mod_args)
  local common = _ENV[mod_args.mod_shortname]

  local calc = {}

  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------
  --                        CALCULATIONS FOR PATHING/DRIVING                        --
  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------

  calc.angle = function(posA, posB)
    --~ common.entered_function({posA, posB})

    local x1, y1 = posA.x, posA.y
    local x2, y2 = posB.x, posB.y
    -- +90 for factorio orientation
    local angle = (math.atan2(y2 - y1, x2 - x1) * 180/math.pi) + 90
  --~ common.show("angle", angle)

    return angle
  end


  -- Returns height or width of a box, depending on which dimension is larger
  calc.box_size = function(box)
    common.entered_function({box})

    local lt = common.normalize_position(box.left_top or box[1])
    local rb = common.normalize_position(box.right_bottom or box[2])
    local w = rb.x - lt.x
    local h = rb.y - lt.y
  --~ common.show("w", w)
  --~ common.show("h", h)
  --~ common.show("max(w, h)", max(w, h))

    return max(w, h)
  end

  -- Returns height or width of a box, depending on which dimension is smaller
  calc.box_width = function(box)
    common.entered_function({box})

    local lt = common.normalize_position(box.left_top or box[1])
    local rb = common.normalize_position(box.right_bottom or box[2])
    local w = rb.x - lt.x
    local h = rb.y - lt.y
  --~ common.show("w", w)
  --~ common.show("h", h)
  --~ common.show("min(w, h)", min(w, h))

    return min(w, h)
  end


  ------------------------------------------------------------------------------------
  -- Function to measure distance between two positions
  calc.get_distance = function(pos_a, pos_b)
    common.entered_function({pos_a, pos_b})

    pos_a = common.normalize_position(pos_a)
    pos_b = common.normalize_position(pos_b)

    local x, y = pos_a.x - pos_b.x, pos_a.y - pos_b.y
    local distance = sqrt(x*x + y*y)
common.show("Distance", distance)

    common.entered_function("leave")
    return distance
  end


  ------------------------------------------------------------------------------------
  -- Return true if the distance between pos_a and pos_b is greater than max_distance
  calc.distance_exceeds = function(pos_a, pos_b, max_distance)
    common.entered_function({pos_a, pos_b, max_distance})

    return calc.get_distance(pos_a, pos_b) > max_distance
  end


  ------------------------------------------------------------------------------------
  -- Return bounce speeds of two crashing entities
  -- new_speed_1 = ((m1 * v1) + m2*(2*v2 - v1)) / mass_total is the same thing as
  -- new_speed_1 = ((m1 * v1) + (2*m2*v2 - m2*v1)) / mass_total, but using the second
  -- version allows us to precalculate and reuse the impulses (m1*v1) and (m2*v2)
  calc.bounce_speeds = function(m_1, v_1, m_2, v_2)
    common.entered_function({m_1, v_1 * 216, m_2, v_2 * 216})

    local impulse_1, impulse_2 = (m_1 * v_1), (m_2 * v_2)
    local mass_total = m_1 + m_2
common.show("impulse_1", impulse_1)
common.show("impulse_2", impulse_2)
common.show("mass_total", mass_total)

common.show("impulse_1 + 2*impulse_2 - m_2 * v_1", impulse_1 + 2*impulse_2 - m_2 * v_1)
common.show("impulse_2 + 2*impulse_1 - m_1 * v_2", impulse_2 + 2*impulse_1 - m_1 * v_2)
    local bounce_1 = (impulse_1 + 2*impulse_2 - m_2 * v_1) / mass_total
    local bounce_2 = (impulse_2 + 2*impulse_1 - m_1 * v_2) / mass_total
common.show("bounce_1", bounce_1)
common.show("bounce_2", bounce_2)
    --~ common.show("bounce_1", bounce_1 * 216)
    --~ common.show("bounce_2", bounce_2 * 216)
    return bounce_1, bounce_2
  end


  -- Make sure speed is within the range -max_speed <= speed <= max_speed
  calc.cap_speed = function(speed, max_speed)
    common.entered_function({speed and speed * 216 or "nil",
                              max_speed and max_speed * 216 or "nil"})
    max_speed = abs(max_speed)
    return max(max_speed * -1, min(max_speed, speed))
  end

  ------------------------------------------------------------------------------------
  PClib_log("Leaving file "..debug.getinfo(1).source)
  return calc
end
