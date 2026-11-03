{-# LANGUAGE DataKinds #-}
-- The agent decides the test orders should go, and deletes them with what it has.
-- expects: Couldn't match type ‘ReadOnly’ with ‘ReadWrite’
module DeleteOnReplica where

import Db

investigate :: Db 'ReadOnly -> IO String
investigate db = do
  deleteWhere db (totalBelow 100)
  pure "cleaned up"
