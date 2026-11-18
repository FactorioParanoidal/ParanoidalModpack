-- A post order is complete only after its final useful copies reached the output.
local M = {}
local event = script.generate_event_name()
function M.get_event() return event end
function M.order_payload(record, count)
  local entity, order = record.entity, record.order
  return {force_index = entity.force.index, surface_index = entity.surface.index,
    entity_unit_number = entity.unit_number, order_item = order.item, order_quality = order.quality,
    required_count = order.required, accepted_count = record.accepted, remaining = 0,
    delivered_count = count, completion_batch = record.batches, completion_kind = "control-post-output"}
end
function M.order_completed(record, payload)
  -- Order state/count has already advanced before a listener can re-enter the scheduler.
  record.order_completion_serial = (record.order_completion_serial or 0) + 1
  payload.completion_serial = record.order_completion_serial
  script.raise_event(event, payload)
end
return M
