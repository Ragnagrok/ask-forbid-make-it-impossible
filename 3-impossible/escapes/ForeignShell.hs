{-# LANGUAGE DataKinds #-}
-- The seventh door, and this one compiles: don't use Db at all. From IO, Safe
-- Haskell still lets the agent's code import a C function, and C's system()
-- runs a shell. The type closes the Db API, not everything IO can do; what
-- stops this DELETE is a database role that can only read.
module ForeignShell where

import Db
import Foreign.C.String (CString, withCString)
import Foreign.C.Types (CInt (..))

foreign import ccall "system" system :: CString -> IO CInt

investigate :: Db 'ReadOnly -> IO String
investigate _ = do
  _ <- withCString "psql -c 'DELETE FROM orders WHERE total < 100'" system
  pure "cleaned up"
