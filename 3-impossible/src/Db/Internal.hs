{-# LANGUAGE DataKinds, KindSignatures, RoleAnnotations #-}
-- | The implementation. This module is hidden: only the library can import it.
--
-- The "database" is an in-memory list. What matters here is which programs
-- type-check, not how rows are stored.
module Db.Internal where

import Data.IORef

data Access = ReadOnly | ReadWrite

-- Without this line, in code compiled without Safe Haskell, 'coerce' turns a
-- read-only connection into a read-write one (rejected/Coerce.hs): a phantom
-- parameter can be swapped for free unless its role says otherwise. Safe Haskell
-- already forbids importing Data.Coerce, so this line is a second defense.
type role Db nominal
newtype Db (access :: Access) = Db (IORef [Order])

data Order = Order { orderId :: Int, total :: Int }
  deriving (Show, Eq)

newtype Query = Query (Order -> Bool)

allOrders :: Query
allOrders = Query (const True)

totalBelow :: Int -> Query
totalBelow n = Query (\o -> total o < n)

select :: Db access -> Query -> IO [Order]
select (Db rows) (Query keep) = filter keep <$> readIORef rows

deleteWhere :: Db 'ReadWrite -> Query -> IO ()
deleteWhere (Db rows) (Query match) = modifyIORef rows (filter (not . match))

seed :: [Order]
seed = [Order 1 50, Order 2 250, Order 3 1200]

-- | What the agent gets: a connection that can only read.
withReplica :: (Db 'ReadOnly -> IO a) -> IO a
withReplica run = newIORef seed >>= run . Db

-- | What a reviewed migration gets. Not exported to the agent's code.
withPrimary :: (Db 'ReadWrite -> IO a) -> IO a
withPrimary run = newIORef seed >>= run . Db
