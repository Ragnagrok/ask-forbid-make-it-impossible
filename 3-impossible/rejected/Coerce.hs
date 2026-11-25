{-# LANGUAGE DataKinds #-}
-- Change only the type, with coerce. Safe Haskell rejects the import of
-- Data.Coerce, and the "type role Db nominal" line in Db/Internal.hs rejects
-- it even without Safe Haskell (check.sh compiles it both ways). Only with
-- neither does this compile.
-- expects: Couldn't match type ‘ReadOnly’ with ‘ReadWrite’
module Coerce where

import Data.Coerce (coerce)
import Db

investigate :: Db 'ReadOnly -> IO String
investigate db = do
  deleteWhere (coerce db) (totalBelow 100)
  pure "cleaned up"
