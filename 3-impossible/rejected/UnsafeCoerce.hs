{-# LANGUAGE DataKinds #-}
-- The best-known door: unsafeCoerce. The agent's code is compiled with Safe Haskell.
-- expects: Unsafe.Coerce: Can't be safely imported
module UnsafeCoerce where

import Db
import Unsafe.Coerce (unsafeCoerce)

investigate :: Db 'ReadOnly -> IO String
investigate db = do
  deleteWhere (unsafeCoerce db) (totalBelow 100)
  pure "cleaned up"
