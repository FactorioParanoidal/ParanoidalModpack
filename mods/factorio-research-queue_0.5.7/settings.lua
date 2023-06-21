data:extend{
  {
    type = 'bool-setting',
    name = 'rq-notifications',
    order = 'a',
    setting_type = 'runtime-per-user',
    default_value = true,
  },
  {
    type = 'bool-setting',
    name = 'rq-pause-game',
    order = 'b',
    setting_type = 'runtime-per-user',
    default_value = false,
  },
  {
    type = 'string-setting',
    name = 'rq-sync',
    order = 'a',
    setting_type = 'runtime-global',
    default_value = 'hybrid',
    allowed_values = {
      'disabled',
      'sync',-- keep in sync
      'wait',-- vanilla first
      'freeze',-- mod queue first, vanilla queue frozen
      'move-head',-- move vanilla queue to mod queue on UI close
      'move-tail',-- move vanilla queue to mod queue on UI close
      'hybrid' -- first 1+3 queue slots are synced to queue[:4], last are used for queue_head
    }
  }
}
