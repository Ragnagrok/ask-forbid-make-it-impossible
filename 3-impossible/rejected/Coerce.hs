{-# LANGUAGE DataKinds #-}
-- Change only the type, with coerce. Outside Safe Haskell and without the
-- "type role Db nominal" line in Db/Internal.hs, this compiles.
-- expects: Couldn't match type ‘ReadOnly’ with ‘ReadWrite’
module Coerce where

import Data.Coerce (coerce)
import Db

investigate :: Db 'ReadOnly -> IO String
investigate db = do
  deleteWhere (coerce db) (totalBelow 100)
  pure "cleaned up"
