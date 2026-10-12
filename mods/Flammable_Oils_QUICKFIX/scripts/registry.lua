-- Shared module table: modules attach themselves here and call each other at runtime,
-- which avoids require cycles. Holds functions only; all game state lives in storage.
return {}
