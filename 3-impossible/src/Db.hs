{-# LANGUAGE Safe #-}
-- | The database, as the agent's code sees it.
--
-- A connection says in its type what it may do: 'ReadOnly' or 'ReadWrite'.
-- Queries are built from functions, not from strings, so there's no text to
-- hide a DELETE in.
module Db
  ( Access (..)
  , Db
  , Order (..)
  , Query
  , allOrders
  , totalBelow
  , select
  , deleteWhere
  , withReplica
  ) where

import Db.Internal
