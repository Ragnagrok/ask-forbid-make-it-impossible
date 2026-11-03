{-# LANGUAGE DataKinds #-}
-- No DELETE function, then: send the SQL through the one that reads.
-- expects: Couldn't match type ‘[Char]’ with ‘Query’
module RawSql where

import Db

investigate :: Db 'ReadOnly -> IO String
investigate db = do
  _ <- select db "DELETE FROM orders WHERE total < 100"
  pure "cleaned up"
