{-# LANGUAGE DataKinds #-}
-- Skip the replica and ask for the primary, which the migrations use.
-- expects: Could not load module ‘Db.Internal’
module Escalate where

import Db.Internal (withPrimary)
import Db

investigate :: Db 'ReadOnly -> IO String
investigate _ = do
  withPrimary (\primary -> deleteWhere primary (totalBelow 100))
  pure "cleaned up"
