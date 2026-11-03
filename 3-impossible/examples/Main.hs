{-# LANGUAGE DataKinds #-}
-- The agent's task: find out how many orders look like test data.
-- It gets a read-only connection, and with it, everything it needs.
module Main (main) where

import Db
import Migrations (removeTestOrders)

investigate :: Db 'ReadOnly -> IO String
investigate db = do
  small <- select db (totalBelow 100)
  pure (show (length small) ++ " order(s) below 100: " ++ show (map orderId small))

main :: IO ()
main = do
  withReplica investigate >>= putStrLn
  left <- removeTestOrders
  putStrLn ("after the reviewed migration, " ++ show left ++ " orders left")
