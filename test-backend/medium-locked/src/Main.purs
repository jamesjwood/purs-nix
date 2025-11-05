module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Erl.Atom (atom)
import Erl.Data.List as ErlList
import Erl.Data.Map as ErlMap

main :: Effect Unit
main = do
  log "Backend test: medium with Erlang packages"
  log $ "Test atom: " <> show (atom "test")
  log $ "Test list length: " <> show (ErlList.length (ErlList.fromFoldable [1, 2, 3]))
  log $ "Test map size: " <> show (ErlMap.size (ErlMap.empty :: ErlMap.Map String Int))
