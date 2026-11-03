{-# LANGUAGE DataKinds #-}
-- Unwrap the connection and wrap it again as read-write.
-- expects: Illegal term-level use of the type constructor ‘Db’
module OpenTheConnection where

import Db

promote :: Db 'ReadOnly -> Db 'ReadWrite
promote (Db rows) = Db rows
