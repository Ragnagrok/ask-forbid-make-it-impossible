{-# LANGUAGE DataKinds #-}
-- | Code a person wrote and reviewed, and the only place that writes.
module Migrations (removeTestOrders) where

import Db.Internal

-- | Orders below 100 are test data. Returns how many are left.
removeTestOrders :: IO Int
removeTestOrders = withPrimary $ \db -> do
  deleteWhere db (totalBelow 100)
  length <$> select db allOrders
